// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

library StringUtils {
    // Existing code for string comparison and equality omitted for brevity
    // ...

    // New function for concatenating two strings
    function concatenate(string memory _a, string memory _b) internal pure returns (string memory) {
        return string(abi.encodePacked(_a, _b));
    }
}

contract PhotoSharing is ERC721 {
    using Counters for Counters.Counter;
    using StringUtils for string;

    struct Photo {
        string ipfsHash;
        string description;
        uint256[] comments;
        address[] likes;
        uint256 time;
        address owner;
        bool isAuctioned;
        uint256 auctionEndTime;
        uint256 highestBid;
        address highestBidder;
        uint256 royaltyPercentage;
    }

    struct Comment {
        string text;
        address author;
    }

    struct ReturnComment {
        string text;
        string username;
    }

    struct AuctionBid {
        uint256 photoId;
        uint256 bidAmount;
    }

    struct PhotoCollection {
        string name;
        uint256[] photoIds;
        address owner;
    }

    mapping(uint256 => Photo) private photos;
    mapping(uint256 => Comment) private commentsById;
    mapping(address => string) private usernames;
    mapping(string => bool) private usernameExists;
    mapping(address => bool) private hasUsername;
    mapping(address => uint256[]) private userAuctions;
    mapping(uint256 => PhotoCollection) private photoCollections;
    mapping(uint256 => bool) private isPhotoInCollection;
    mapping(uint256 => uint256) private photoVotes;

    Counters.Counter private _tokenIdCounter;
    Counters.Counter private _commentIdCounter;
    Counters.Counter private _collectionIdCounter;

    event PhotoUploaded(uint256 indexed photoId, address indexed owner);
    event CommentAdded(uint256 indexed photoId, address indexed author, uint256 indexed commentId);
    event PhotoLiked(uint256 indexed photoId, address indexed liker);
    event UsernameRegistered(address indexed user, string username);
    event PhotoAuctionStarted(uint256 indexed photoId, uint256 auctionEndTime);
    event PhotoAuctionEnded(uint256 indexed photoId, address indexed winner, uint256 winningBid);
    event PhotoLicensed(uint256 indexed photoId, address indexed licensee, uint256 licenseFee);
    event PhotoCollectionCreated(uint256 indexed collectionId, string name, address indexed owner);
    event PhotoAddedToCollection(uint256 indexed photoId, uint256 indexed collectionId);
    event PhotoVoted(uint256 indexed photoId, address indexed voter, uint256 votes);

    constructor() ERC721("PhotoSharing", "PS") {}

    function uploadPhoto(string memory _ipfsHash, string memory _description) public onlyUser {
        require(bytes(_ipfsHash).length > 0, "Invalid IPFS hash");
        require(bytes(_description).length > 0, "Invalid description");

        _tokenIdCounter.increment();
        uint256 newPhotoId = _tokenIdCounter.current();
        _mint(msg.sender, newPhotoId);

        Photo storage newPhoto = photos[newPhotoId];
        newPhoto.ipfsHash = _ipfsHash;
        newPhoto.owner = msg.sender;
        newPhoto.description = _description;
        newPhoto.time = block.timestamp;

        emit PhotoUploaded(newPhotoId, msg.sender);
    }

    function addComment(uint256 _photoId, string memory _text) public onlyUser photoExists(_photoId) {
        require(bytes(_text).length > 0, "Invalid comment text");

        _commentIdCounter.increment();
        uint256 newCommentId = _commentIdCounter.current();

        Comment storage newComment = commentsById[newCommentId];
        newComment.text = _text;
        newComment.author = msg.sender;

        photos[_photoId].comments.push(newCommentId);

        emit CommentAdded(_photoId, msg.sender, newCommentId);
    }

    function getComments(uint256 _photoId) public view returns (ReturnComment[] memory) {
        require(_exists(_photoId), "Invalid photo ID");

        Photo storage photo = photos[_photoId];
        ReturnComment[] memory result = new ReturnComment[](photo.comments.length);

        for (uint256 i = 0; i < photo.comments.length; i++) {
            Comment storage comment = commentsById[photo.comments[i]];
            result[i].text = comment.text;
            result[i].username = usernames[comment.author];
        }

        return result;
    }

    function likePhoto(uint256 _photoId) public onlyUser photoExists(_photoId) {
        Photo storage photo = photos[_photoId];
        address[] storage likes = photo.likes;
        for (uint256 i = 0; i < likes.length; i++) {
            require(likes[i] != msg.sender, "Already liked");
        }

        likes.push(msg.sender);

        emit PhotoLiked(_photoId, msg.sender);
    }

    function registerUsername(string memory _username) public {
        require(bytes(_username).length > 0, "Invalid username");
        require(!hasUsername[msg.sender], "Username already registered");
        require(!usernameExists[_username], "Username already taken");

        hasUsername[msg.sender] = true;
        usernames[msg.sender] = _username;
        usernameExists[_username] = true;

        emit UsernameRegistered(msg.sender, _username);
    }

    function startPhotoAuction(uint256 _photoId, uint256 _auctionEndTime) public onlyUser photoExists(_photoId) {
        require(msg.sender == ownerOf(_photoId), "Only the photo owner can start an auction");
        require(!photos[_photoId].isAuctioned, "Photo is already in an auction");
        require(_auctionEndTime > block.timestamp, "Invalid auction end time");

        photos[_photoId].isAuctioned = true;
        photos[_photoId].auctionEndTime = _auctionEndTime;
        userAuctions[msg.sender].push(_photoId);

        emit PhotoAuctionStarted(_photoId, _auctionEndTime);
    }

    function placeBid(uint256 _photoId) public payable onlyUser photoExists(_photoId) {
        require(photos[_photoId].isAuctioned, "Photo is not in an auction");
        require(block.timestamp < photos[_photoId].auctionEndTime, "Auction has ended");
        require(msg.value > photos[_photoId].highestBid, "Bid amount must be higher");

        if (photos[_photoId].highestBidder != address(0)) {
            // Refund the previous highest bidder
            payable(photos[_photoId].highestBidder).transfer(photos[_photoId].highestBid);
        }

        photos[_photoId].highestBid = msg.value;
        photos[_photoId].highestBidder = msg.sender;

        emit PhotoAuctionEnded(_photoId, msg.sender, msg.value);
    }

    function endPhotoAuction(uint256 _photoId) public onlyUser photoExists(_photoId) {
        require(photos[_photoId].isAuctioned, "Photo is not in an auction");
        require(block.timestamp >= photos[_photoId].auctionEndTime, "Auction has not ended");

        address winner = photos[_photoId].highestBidder;
        uint256 winningBid = photos[_photoId].highestBid;

        photos[_photoId].isAuctioned = false;
        photos[_photoId].auctionEndTime = 0;
        photos[_photoId].highestBid = 0;
        photos[_photoId].highestBidder = address(0);

        payable(ownerOf(_photoId)).transfer(winningBid);
        _transfer(ownerOf(_photoId), winner, _photoId);

        emit PhotoAuctionEnded(_photoId, winner, winningBid);
    }

    function licensePhoto(uint256 _photoId, uint256 _licenseFee, uint256 _royaltyPercentage) public payable onlyUser photoExists(_photoId) {
        require(msg.sender != ownerOf(_photoId), "You cannot license your own photo");
        require(msg.value >= _licenseFee, "Insufficient payment");
        require(_royaltyPercentage <= 100, "Invalid royalty percentage");

        address owner = ownerOf(_photoId);

        // Transfer license fee to the photo owner
        payable(owner).transfer(_licenseFee);

        // Calculate and transfer royalty fee to the photo owner
        uint256 royaltyFee = (_licenseFee * _royaltyPercentage) / 100;
        payable(owner).transfer(royaltyFee);

        // Transfer the photo to the licensee
        _transfer(owner, msg.sender, _photoId);

        // Update photo details
        photos[_photoId].owner = msg.sender;
        photos[_photoId].royaltyPercentage = _royaltyPercentage;

        emit PhotoLicensed(_photoId, msg.sender, _licenseFee);
    }

    function createPhotoCollection(string memory _name) public onlyUser {
        require(bytes(_name).length > 0, "Invalid collection name");

        _collectionIdCounter.increment();
        uint256 newCollectionId = _collectionIdCounter.current();

        PhotoCollection storage newCollection = photoCollections[newCollectionId];
        newCollection.name = _name;
        newCollection.owner = msg.sender;

        emit PhotoCollectionCreated(newCollectionId, _name, msg.sender);
    }

    function addToPhotoCollection(uint256 _photoId, uint256 _collectionId) public onlyUser photoExists(_photoId) collectionExists(_collectionId) {
        require(msg.sender == photoCollections[_collectionId].owner, "Only the collection owner can add photos");

        photoCollections[_collectionId].photoIds.push(_photoId);
        isPhotoInCollection[_photoId] = true;

        emit PhotoAddedToCollection(_photoId, _collectionId);
    }

    function voteForPhoto(uint256 _photoId) public onlyUser photoExists(_photoId) {
        require(!photos[_photoId].isAuctioned, "Cannot vote for an auctioned photo");

        photoVotes[_photoId]++;

        emit PhotoVoted(_photoId, msg.sender, photoVotes[_photoId]);
    }

    function getPhoto(uint256 _photoId) public view photoExists(_photoId) returns (string memory, string memory, uint256, uint256, bool, uint256, address) {
        Photo storage photo = photos[_photoId];
        return (photo.ipfsHash, photo.description, photo.comments.length, photo.likes.length, photo.isAuctioned, photo.auctionEndTime, photo.owner);
    }

    function getPhotoLikes(uint256 _photoId) public view photoExists(_photoId) returns (address[] memory) {
        return photos[_photoId].likes;
    }

    function getUsername(address _userAddress) public view returns (string memory) {
        return usernames[_userAddress];
    }

    function getAuctions(address _userAddress) public view returns (uint256[] memory) {
        return userAuctions[_userAddress];
    }

    function getPhotoCollection(uint256 _collectionId) public view collectionExists(_collectionId) returns (string memory, uint256[] memory, address) {
        PhotoCollection storage collection = photoCollections[_collectionId];
        return (collection.name, collection.photoIds, collection.owner);
    }

    function getPhotoCollectionsByOwner(address _owner) public view returns (uint256[] memory) {
        uint256[] storage collectionIds = userCollections[_owner];
        return collectionIds;
    }

    modifier onlyUser() {
        require(hasUsername[msg.sender], "User does not have a registered username");
        _;
    }

    modifier photoExists(uint256 _photoId) {
        require(_exists(_photoId), "Photo does not exist");
        _;
    }

    modifier collectionExists(uint256 _collectionId) {
        require(_collectionId > 0 && _collectionId <= _collectionIdCounter.current(), "Collection does not exist");
        _;
    }
}
