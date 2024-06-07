// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./AutomatedFunctionsConsumer.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CopernicSpaceLink is ERC721, AutomatedFunctionsConsumer, Ownable {
    using Functions for Functions.Request;

    uint256 public tokenCounter;
    string public apiUrl;
    bytes32 private immutable jobId;
    uint256 private immutable fee;

    struct RocketData {
        uint256 distanceFromEarth;
        uint256 distanceToMoon;
        uint256 speed;
        string state;
    }

    mapping(uint256 => RocketData) public tokenIdToRocketData;
    mapping(uint256 => string) private _tokenURIs;
    mapping(bytes32 => uint256) private requestIdToTokenId;  // Mapping to track request IDs to token IDs

    event RequestFulfilled(bytes32 indexed requestId, uint256 indexed tokenId);

    constructor(
        address _link,
        address _oracle,
        bytes32 _jobId,
        uint256 _fee,
        string memory _apiUrl
    ) ERC721("CopernicSpaceLink", "CSL") AutomatedFunctionsConsumer(_oracle) {
        setChainlinkToken(_link);
        jobId = _jobId;
        fee = _fee;
        apiUrl = _apiUrl;
        tokenCounter = 0;
    }

    function createNFT(string memory tokenURI) public onlyOwner returns (uint256) {
        uint256 newItemId = tokenCounter;
        _safeMint(msg.sender, newItemId);
        setTokenURI(newItemId, tokenURI); // Set initial token URI with IPFS image
        tokenCounter += 1;
        return newItemId;
    }

    function requestData(uint256 tokenId) public onlyOwner returns (bytes32 requestId) {
        Functions.Request memory req;
        req.initializeRequestForGet(apiUrl);
        req.add("path", "distance_from_earth,distance_to_moon,speed,state");
        req.addUint("tokenId", tokenId);
        
        requestId = sendRequest(req, fee);
        requestIdToTokenId[requestId] = tokenId; // Track the request ID to token ID
        return requestId;
    }

    function fulfillRequest(
        bytes32 requestId,
        uint256 distanceFromEarth,
        uint256 distanceToMoon,
        uint256 speed,
        string memory state
    ) internal override {
        uint256 tokenId = requestIdToTokenId[requestId];  // Retrieve the token ID
        tokenIdToRocketData[tokenId] = RocketData(distanceFromEarth, distanceToMoon, speed, state);
        emit RequestFulfilled(requestId, tokenId);
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public onlyOwner {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }
}
