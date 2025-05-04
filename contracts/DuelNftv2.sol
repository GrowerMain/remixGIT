// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";           // drop Enumerable if you don't need on‐chain enumeration
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

using Address for address payable;

contract DuelNFT is ERC721, Ownable {
    uint256 public tokenIdCounter;
    mapping(uint256 => uint256) public cooldownEndTimestamp;
    mapping(uint256 => uint256) public tokenRarity;

    struct Rarity {
        string name;
        uint256 weight;
        string uri;         // ← an IPFS URI (e.g. "ipfs://Qm…/common.json")
    }
    Rarity[] public rarities;
    uint256 public totalWeight;

    IERC20 public immutable usdtToken;

    event Minted(address indexed minter, uint256 indexed tokenId, string rarity, bool paidInETH);
    event RarityAdded(uint256 indexed id, string name, uint256 weight, string uri);
    event RarityUpdated(uint256 indexed id, string name, uint256 weight, string uri);

    constructor(address _usdtToken) ERC721("Predictive Duel NFT", "PDNFT") {
        usdtToken = IERC20(_usdtToken);

        // seed rarities with their IPFS metadata pointers
        _addRarity("Common",    7_000, "ipfs://QmAAA/common.json");
        _addRarity("Rare",      2_000, "ipfs://QmBBB/rare.json");
        _addRarity("Epic",        800, "ipfs://QmCCC/epic.json");
        _addRarity("Legendary",   200, "ipfs://QmDDD/legendary.json");
        _addRarity("Mythic",   100, "ipfs://QmEEE/mythic.json");
    }

    function _addRarity(string memory name, uint256 weight, string memory uri) internal {
        rarities.push(Rarity(name, weight, uri));
        totalWeight += weight;
        emit RarityAdded(rarities.length - 1, name, weight, uri);
    }

    /// @notice owner can add new rarity classes (with their own IPFS URI)
    function addRarity(string calldata name, uint256 weight, string calldata uri) external onlyOwner {
        _addRarity(name, weight, uri);
    }

    /// @notice tweak an existing rarity (including its metadata pointer)
    function updateRarity(
        uint256 id,
        string calldata name,
        uint256 weight,
        string calldata uri
    ) external onlyOwner {
        require(id < rarities.length, "Invalid rarity ID");
        totalWeight = totalWeight - rarities[id].weight + weight;
        rarities[id].name   = name;
        rarities[id].weight = weight;
        rarities[id].uri    = uri;
        emit RarityUpdated(id, name, weight, uri);
    }

    // … your mintWithETH / mintWithUSDT / _performMint / randomness / cooldown / withdrawal logic …

    /// @dev returns the metadata URI for a token based on its assigned rarity
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: nonexistent token");
        uint256 rid = tokenRarity[tokenId];
        return rarities[rid].uri;
    }
}
