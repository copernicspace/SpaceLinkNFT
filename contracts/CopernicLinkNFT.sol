// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract CopernicSpaceLink is ERC721, FunctionsClient, ConfirmedOwner, ERC721URIStorage {
    using FunctionsRequest for FunctionsRequest.Request;

    string internal constant SOURCE = 
        "const state = args[0]"
        "const distance_from_earth = args[1]"
        "const distance_to_moon = args[2]"
        "const speed = args[3]"
        "const nearest_crater = args[4]"
        "const landing_time = args[5]"

        "const apiURL = 'http://192.168.74.229:5000/status'"

        "const apiRequest = Functions.makeHttpRequest({"
        "  url: apiURL,"
        "  method: 'GET',"
        "  params: {"
        "    state: state,"
        "    'distance_from_earth': distance_from_earth,"
        "    'distance_to_moon': distance_to_moon,"
        "    'speed': speed,"
        "    'nearest_crater': nearest_crater,"
        "    'landing_time': landing_time"
        "  }"
        "})"

        "const apiResponse = await apiRequest"

        "if (apiResponse.error) {"
        "  console.error(apiResponse.error)"
        "  throw Error('Request failed, try checking the API endpoint')"
        "}"

        "console.log(apiResponse)"

        "const data = apiResponse.data"

        "let result = { state: data.state }"

        "if (data.state === 'In transit') {"
        "  result = {"
        "    state: data.state,"
        "    distance_from_earth: data.distance_from_earth,"
        "    distance_to_moon: data.distance_to_moon,"
        "    speed: data.speed,"
        "  }"
        "} else if (data.state === 'On the moon') {"
        "  result = {"
        "    state: data.state,"
        "    nearest_crater: data.nearest_crater,"
        "    landing_time: data.landing_time,"
        "  }"
        "}"

        "// Use JSON.stringify() to convert from JSON object to JSON string"
        "// Finally, use the helper Functions.encodeString() to encode from string to bytes"
        "return Functions.encodeString(JSON.stringify(result))";

    uint256 public tokenCounter;
    bytes32 public donId; // DON ID for the Functions DON to which the requests are sent
    uint64 private subscriptionId; // Subscription ID for the Chainlink Functions
    uint32 private gasLimit; // Gas limit for the Chainlink Functions callbacks

    // Mapping of request IDs to rocket data
    mapping(bytes32 => RocketData) public requests;
    mapping(uint256 => RocketData) public tokenIdToRocketData;
    mapping(bytes32 => uint256) private requestIdToTokenId;
    mapping(uint256 => string) private _tokenURIs;

    struct RocketData {
        string state;
        uint256 distanceFromEarth;
        uint256 distanceToMoon;
        uint256 speed;
        string nearestCrater;
        string landingTime;
        string tokenURI;
    }

    function generateTokenURI(string memory state, uint256 distanceFromEarth, uint256 distanceToMoon, uint256 speed, string memory nearestCrater, string memory landingTime) private returns (string memory) {
        string memory json = string(
            abi.encodePacked(
                '{"name": "Rocket NFT", "state": "',
                state,
                '", "distance_from_earth": ',
                distanceFromEarth,
                ', "distance_to_moon": ',
                distanceToMoon,
                ', "speed": ',
                speed,
                ', "nearest_crater": "',
                nearestCrater,
                '", "landing_time": "',
                landingTime,
                '"}'
            )
        );

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(bytes(json))
            )
        );
    }

    event RocketDataRequested(bytes32 indexed requestId, string state, uint256 distanceFromEarth, uint256 distanceToMoon, uint256 speed, string nearestCrater, string landingTime);
    event RocketDataReceived(bytes32 indexed requestId, string state, uint256 distanceFromEarth, uint256 distanceToMoon, uint256 speed, string nearestCrater, string landingTime);
    event RequestFailed(bytes error);    
    event RequestFulfilled(bytes32 indexed requestId, uint256 indexed tokenId);

    constructor(
        address router, // polygonAmoy router 0xC22a79eBA640940ABB6dF0f7982cc119578E11De / mainnet 0xdc2AAF042Aeff2E68B3e8E33F19e4B9fA7C73F10 
        bytes32 _donId,
        uint64 _subscriptionId,
        uint32 _gasLimit,
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) ERC721URIStorage() FunctionsClient(router) ConfirmedOwner(msg.sender) {
        donId = _donId;
        subscriptionId = _subscriptionId;
        gasLimit = _gasLimit;
        tokenCounter = 0;
    }

    function createNFT(string memory state, uint256 distanceFromEarth, uint256 distanceToMoon, uint256 speed, string memory nearestCrater, string memory landingTime) public onlyOwner returns (uint256) {
        uint256 newItemId = tokenCounter;
        _safeMint(msg.sender, newItemId);
        string memory initialTokenURI = generateTokenURI(state, distanceFromEarth, distanceToMoon, speed, nearestCrater, landingTime);
        tokenIdToRocketData[newItemId] = RocketData(state, distanceFromEarth, distanceToMoon, speed, nearestCrater, landingTime, initialTokenURI);
        _setTokenURI(newItemId, initialTokenURI);
        tokenCounter += 1;
        return newItemId;
    }

    function requestRocketData(string calldata state, uint256 distance_from_earth, uint256 distance_to_moon, uint256 speed, string calldata nearest_crater, string calldata landing_time) external {
    string[] memory args = new string[](6);
    args[0] = state;
    args[1] = Strings.toString(distance_from_earth);
    args[2] = Strings.toString(distance_to_moon);
    args[3] = Strings.toString(speed);
    args[4] = nearest_crater;
    args[5] = landing_time;
    bytes32 requestId = _sendRequest(args);

    requests[requestId] = RocketData({state: state, distanceFromEarth: distance_from_earth, distanceToMoon: distance_to_moon, speed: speed, nearestCrater: nearest_crater, landingTime: landing_time, tokenURI: ""});
    requestIdToTokenId[requestId] = tokenCounter; // Track the request ID to token ID
    emit RocketDataRequested(requestId, state, distance_from_earth, distance_to_moon, speed, nearest_crater, landing_time);
}
   /*
    function requestRocketData(string calldata state, uint256 calldata distance_from_earth, uint256 calldata distance_to_moon, uint256 calldata speed, string calldata nearest_crater, string calldata landing_time) external {
        string[] memory args = new string[](6);
        args[0] = state;
        args[1] = distance_from_earth;
        args[2] = distance_to_moon;
        args[3] = speed;
        args[4] = nearest_crater;
        args[5] = landing_time;
        bytes32 requestId = _sendRequest(args);

        requests[requestId] = RocketData({state: state, distanceFromEarth: distance_from_earth, distanceToMoon: distance_to_moon, speed: speed, nearestCrater: nearest_crater, landingTime: landing_time, tokenURI: ""});
        requestIdToTokenId[requestId] = tokenCounter; // Track the request ID to token ID
        emit RocketDataRequested(requestId, state, distance_from_earth, distance_to_moon, speed, nearest_crater, landing_time);
    }
 */
    /**
     * @notice Process the response from the executed Chainlink Functions script
     * @param requestId The request ID
     * @param response The response from the Chainlink Functions script
     * We are having an issue here I need to simplify it.
     */
    function _processResponse(bytes32 requestId, bytes memory response) private {
        string memory rocketState = string(response);
        uint256 distanceFromEarth;
        uint256 distanceToMoon;
        uint256 speed;
        string memory nearestCrater;
        string memory landingTime;

        if (keccak256(bytes(rocketState)) == keccak256(bytes("On Earth")) || keccak256(bytes(rocketState)) == keccak256(bytes("LOS"))) {
            tokenIdToRocketData[requestIdToTokenId[requestId]] = RocketData(rocketState, 0, 0, 0, "", "", generateTokenURI(rocketState, 0, 0, 0, "", ""));
            _setTokenURI(requestIdToTokenId[requestId], tokenIdToRocketData[requestIdToTokenId[requestId]].tokenURI);
        } else if (keccak256(bytes(rocketState)) == keccak256(bytes("In transit"))) {
            (
                string memory state,
                uint256 _distanceFromEarth,
                uint256 _distanceToMoon,
                uint256 _speed
            ) = abi.decode(response, (string, uint256, uint256, uint256));
            distanceFromEarth = _distanceFromEarth;
            distanceToMoon = _distanceToMoon;
            speed = _speed;
            tokenIdToRocketData[requestIdToTokenId[requestId]] = RocketData(state, distanceFromEarth, distanceToMoon, speed, "", "", generateTokenURI(state, distanceFromEarth, distanceToMoon, speed, "", ""));
            _setTokenURI(requestIdToTokenId[requestId], tokenIdToRocketData[requestIdToTokenId[requestId]].tokenURI);
        } else if (keccak256(bytes(rocketState)) == keccak256(bytes("On the moon"))) {
            (
                string memory state,
                string memory _nearestCrater,
                string memory _landingTime
            ) = abi.decode(response, (string, string, string));
            nearestCrater = _nearestCrater;
            landingTime = _landingTime;
            tokenIdToRocketData[requestIdToTokenId[requestId]] = RocketData(state, 0, 0, 0, nearestCrater, landingTime, generateTokenURI(state, 0, 0, 0, nearestCrater, landingTime));
            _setTokenURI(requestIdToTokenId[requestId], tokenIdToRocketData[requestIdToTokenId[requestId]].tokenURI);
        }

        emit RocketDataReceived(requestId, rocketState, distanceFromEarth, distanceToMoon, speed, nearestCrater, landingTime);
    }

    // CHAINLINK FUNCTIONS

    /**
     * @notice Triggers an on-demand Functions request
     * @param args String arguments passed into the source code and accessible via the global variable `args`
     */
    function _sendRequest(string[] memory args) internal returns (bytes32 requestId) {
        FunctionsRequest.Request memory req;
        req.initializeRequest(FunctionsRequest.Location.Inline, FunctionsRequest.CodeLanguage.JavaScript, SOURCE);
        if (args.length > 0) {
            req.setArgs(args);
        }
        requestId = _sendRequest(req.encodeCBOR(), subscriptionId, gasLimit, donId);
    }

    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        if (err.length > 0) {
            emit RequestFailed(err);
            return;
        }

        uint256 tokenId = requestIdToTokenId[requestId];
        _processResponse(requestId, response);
    }

    /**
     * @notice Set the DON ID
     * @param newDonId New DON ID
     */
    function setDonId(bytes32 newDonId) external onlyOwner {
        donId = newDonId;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // The following functions are overrides required by Solidity.
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}