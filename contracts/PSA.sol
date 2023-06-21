// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
library StringUtils {
    /// @dev Does a byte-by-byte lexicographical comparison of two strings.
    /// @return a negative number if `_a` is smaller, zero if they are equal
    /// and a positive numbe if `_b` is smaller.
    function compare(string memory _a, string memory _b) internal  pure returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        //@todo unroll the loop into increments of 32 and do full 32 byte comparisons
        for (uint i = 0; i < minLength; i ++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        if (a.length < b.length)
            return -1;
        else if (a.length > b.length)
            return 1;
        else
            return 0;
    }
    /// @dev Compares two strings and returns true iff they are equal.
    function equal(string memory _a, string memory _b) internal pure returns (bool) {
        return compare(_a, _b) == 0;
    }
}
contract PhotoSharing is ERC721 {
    using Counters for Counters.Counter;
    struct Photo {
        string ipfsHash;
        string description;
        uint256[] comments;
        address[] likes;
        uint256 time;
        address owner;
    }

    struct Comment {
        string text;
        address author;
    }
    
    struct ReturnComment{
        string text;
        string username;
    }

    struct PhotoInfo {
        string ipfsHash;
        string description;
        uint256 id;
        address[] likes;
        string author;
        uint256 time;
        ReturnComment[] comments;
    }

    mapping(uint256 => Photo) private photos;
    mapping(uint256 => Comment) private commentsById;
    mapping(address => string) private usernames;
    mapping(string => bool) private usernameExists;
    mapping(address => bool) private hasUsername;
    // string[] uName;
    Counters.Counter private _tokenIdCounter;
    Counters.Counter private _commentIdCounter;

    event PhotoUploaded(uint256 indexed photoId, address indexed owner);
    event CommentAdded(uint256 indexed photoId, address indexed author, uint256 indexed commentId);
    event PhotoLiked(uint256 indexed photoId, address indexed liker);

    constructor() ERC721("PhotoSharing", "PS") {}

    function uploadPhoto(string memory _ipfsHash, string memory description) public onlyUser {
        _tokenIdCounter.increment();
        uint256 newPhotoId = _tokenIdCounter.current();
        _mint(msg.sender, newPhotoId);
        Photo storage newPhoto = photos[newPhotoId];
        newPhoto.ipfsHash = _ipfsHash;
        newPhoto.owner = msg.sender;
        newPhoto.description = description;
        newPhoto.time = block.timestamp;
        emit PhotoUploaded(newPhotoId, msg.sender);
    }

    function checkAddress() public view returns(bool){
        return hasUsername[msg.sender];
    }

    function checkUsername(string memory username) public view returns(bool){
        return usernameExists[username];
    }

    modifier onlyUser {
        require(checkAddress(), "Register Your Username");
        _;
    }

    function addComment(uint256 _photoId, string memory _comment) public onlyUser {
        require(_exists(_photoId), "Photo does not exist");
        _commentIdCounter.increment();
        uint256 newCommentId = _commentIdCounter.current();
        Comment storage newComment = commentsById[newCommentId];
        newComment.text = _comment;
        newComment.author = msg.sender;
        photos[_photoId].comments.push(newCommentId);
        emit CommentAdded(_photoId, msg.sender, newCommentId);
    }

    function likePhoto(uint256 _photoId) public onlyUser {
        require(_exists(_photoId), "Photo does not exist");
        photos[_photoId].likes.push(msg.sender);
        emit PhotoLiked(_photoId, msg.sender);
    }

    function isValidUsername(string memory _username) internal pure returns (bool) {
        bytes memory usernameBytes = bytes(_username);
        if (usernameBytes.length < 3 || usernameBytes.length > 20) {
            return false;
        }
        
        // Validate any additional restrictions or criteria here
        
        return true;
    }


    function setUsername(string memory _username) public {
        require(!checkAddress(),"Cannot Register Twice");
        require(!checkUsername(_username),"Choose Another Name");
        require(isValidUsername(_username), "Invalid Username");
        usernames[msg.sender] = _username;
        usernameExists[_username] = true;
        hasUsername[msg.sender] = true;
    }

    function getAllPhotos() public onlyUser view returns (PhotoInfo[] memory) {
        uint256 numPhotos = _tokenIdCounter.current();
        PhotoInfo[] memory photosInfo = new PhotoInfo[](numPhotos);
        for (uint256 i = 0; i < numPhotos; i++) {
            if (_exists(i + 1)) {
                Photo storage photo = photos[i + 1];
                ReturnComment[] memory comments = new ReturnComment[](photo.comments.length);
                for (uint256 j = 0; j < photo.comments.length; j++) {
                    uint256 commentId = photo.comments[j];
                    Comment storage comment = commentsById[commentId];
                    comments[j] = ReturnComment(comment.text, usernames[comment.author]);
                }
                photosInfo[i] = PhotoInfo(photo.ipfsHash, photo.description, i + 1, photo.likes, usernames[photo.owner], photo.time, comments);
            }
        }
        return photosInfo;
    }

}
