// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;


/**
 * @title ERC721
 * @dev ERC721 is the standard interface for non-fungible tokens (NFTs).
 * It provides basic functionality to manage and transfer NFTs.
 * This contract is imported from the OpenZeppelin Contracts library.
 */
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title Counters
 * @dev Provides counters that can be used to track and generate unique identifiers.
 * This library is imported from the OpenZeppelin Contracts library.
 */
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title StringUtils
 * @dev A library that provides string manipulation functions.
 */
library StringUtils {

     /**
     * @dev Does a byte-by-byte lexicographical comparison of two strings.
     * @param _a The first string to compare.
     * @param _b The second string to compare.
     * @return A negative number if `_a` is smaller, zero if they are equal, and a positive number if `_b` is smaller.
     */
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



    /**
     * @dev Compares two strings and returns true if they are equal.
     * @param _a The first string to compare.
     * @param _b The second string to compare.
     * @return A boolean indicating whether the two strings are equal.
     */
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

    /**
    * @dev Structure representing photo information.
    *
    * @param ipfsHash IPFS hash of the photo.
    * @param description Description of the photo.
    * @param id Unique identifier for the photo.
    * @param likes Array of addresses that liked the photo.
    * @param author Username of the photo's owner.
    * @param time Timestamp indicating when the photo was uploaded.
    * @param comments Array of comments associated with the photo.
    */
    struct PhotoInfo {
        string ipfsHash;
        string description;
        uint256 id;
        address[] likes;
        string author;
        uint256 time;
        ReturnComment[] comments;
    }

    /**
    * @dev Mapping to store photo information by photo ID.
    *
    * photos Mapping where the key is the photo ID and the value is the corresponding Photo struct.
    */
    mapping(uint256 => Photo) private photos;

    /**
    * @dev Mapping to store comment information by comment ID.
    *
    * commentsById Mapping where the key is the comment ID and the value is the corresponding Comment struct.
    */
    mapping(uint256 => Comment) private commentsById;

    /**
    * @dev Mapping to store usernames by address.
    *
    * usernames Mapping where the key is the user's address and the value is the corresponding username string.
    */
    mapping(address => string) private usernames;

    /**
    * @dev Mapping to track the existence of usernames.
    *
    * usernameExists Mapping where the key is the username string and the value indicates whether the username exists (true) or not (false).
    */
    mapping(string => bool) private usernameExists;

    /**
    * @dev Mapping to track whether an address has a registered username.
    *
    * hasUsername Mapping where the key is the user's address and the value indicates whether the address has a registered username (true) or not (false).
    */
    mapping(address => bool) private hasUsername;

    /**
    * @dev Counter for generating unique token IDs.
    *
    * _tokenIdCounter Counter used to generate unique token IDs.
    */
    Counters.Counter private _tokenIdCounter;

    /**
     * @dev Counter for generating unique comment IDs.
     *
     *_commentIdCounter Counter used to generate unique comment IDs.
    */
    Counters.Counter private _commentIdCounter;

    /**
    * @dev Event emitted when a photo is uploaded.
    *
    * @param photoId The ID of the uploaded photo.
    * @param owner The address of the photo owner.
    */
    event PhotoUploaded(uint256 indexed photoId, address indexed owner);

    /**
    * @dev Event emitted when a comment is added to a photo.
    *
    * @param photoId The ID of the photo the comment is added to.
    * @param author The address of the comment author.
    * @param commentId The ID of the added comment.
    */
    event CommentAdded(uint256 indexed photoId, address indexed author, uint256 indexed commentId);

    /**
    * @dev Event emitted when a photo is liked.
    *
    * @param photoId The ID of the liked photo.
    * @param liker The address of the user who liked the photo.
    */
    event PhotoLiked(uint256 indexed photoId, address indexed liker);

    /**
    * @dev Constructor function for the PhotoSharing contract.
    * It initializes the contract and sets the ERC721 token name and symbol.    
    */

    /**
     * @dev Event emitted when a username is registered.
     *
     * @param user The address of the user who registered the username.
     * @param username The registered username.
    */
    event UsernameRegistered(address indexed user, string username);

    constructor() ERC721("PhotoSharing", "PS") {}

    /**
    * @dev Uploads a new photo to the contract.
    *
    * @param _ipfsHash The IPFS hash of the photo.
    * @param description The description of the photo.
    * 
    * Requirements:
    * - The IPFS hash must not be an empty string.
    * - The description must not be an empty string.
    */
    function uploadPhoto(string memory _ipfsHash, string memory description) public onlyUser {

        require(bytes(_ipfsHash).length > 0, "Invalid IPFS hash");
        require(bytes(description).length > 0, "Invalid description");
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

    /**
    * @dev Checks if the address has a registered username.
    *
    * @return A boolean indicating whether the address has a registered username or not.
    * 
    * Requirements:
    * - The caller's address must be valid (not zero address).
    */
    function checkAddress() public view returns(bool){
        require(msg.sender != address(0), "Invalid caller address");
        return hasUsername[msg.sender];
    }

    /**
    * @dev Checks if a username exists.
    *
    * @param username The username to check.
    * @return A boolean indicating whether the username exists or not.
    * 
    * Requirements:
    * - The username must not be an empty string.
    */
    function checkUsername(string memory username) public view returns(bool){
        require(bytes(username).length > 0, "Invalid username");
        return usernameExists[username];
    }

    /**
    * @dev Modifier to check if the caller has a registered username.
    * 
    * Requirements:
    * - The caller's address must be valid (not zero address).
    * - The caller must have a registered username.
    */
    modifier onlyUser {
        require(msg.sender != address(0), "Invalid caller address");
        require(checkAddress(), "Register Your Username");
        _;
    }

    /**
    * @dev Adds a comment to a photo.
    *
    * @param _photoId The ID of the photo to add the comment to.
    * @param _comment The text of the comment.
    * 
    * Requirements:
    * - The photo with the given ID must exist.
    */
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

    /**
    * @dev Likes a photo.
    *
    * @param _photoId The ID of the photo to like.
    * 
    * Requirements:
    * - The photo with the given ID must exist.
    */
    function likePhoto(uint256 _photoId) public onlyUser {
        require(_exists(_photoId), "Photo does not exist");
        photos[_photoId].likes.push(msg.sender);
        emit PhotoLiked(_photoId, msg.sender);
    }

    /**
    * @dev Checks if a username is valid.
    *
    * @param _username The username to validate.
    * @return A boolean indicating whether the username is valid or not.
    */
    function isValidUsername(string memory _username) internal pure returns (bool) {
        
        bytes memory usernameBytes = bytes(_username);
        if (usernameBytes.length < 3 || usernameBytes.length > 20) {
            return false;
        }
        
        // Validate any additional restrictions or criteria here
        
        return true;
    }


    /**
    * @dev Sets a username for the calling user.
    *
    * @param _username The username to set.
    * 
    * Requirements:
    * - The user must not have already registered a username.
    * - The username must not already be taken.
    * - The username must be valid.
    */
    function setUsername(string memory _username) public {
        require(!checkAddress(),"Cannot Register Twice");
        require(!checkUsername(_username),"Choose Another Name");
        require(isValidUsername(_username), "Invalid Username");
        usernames[msg.sender] = _username;
        usernameExists[_username] = true;
        hasUsername[msg.sender] = true;
        emit UsernameRegistered(msg.sender, _username);
    }


    /**
    * @dev Retrieves all the photos stored in the contract.
    *
    * @return An array of `PhotoInfo` structs representing the photos.
    */
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
