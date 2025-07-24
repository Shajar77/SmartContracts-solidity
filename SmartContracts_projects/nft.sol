// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract SimpleNFTMarket is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private tokenCounter;

    struct NFTListing {
        uint256 price;
        address seller;
        bool isActive;
    }

    mapping(uint256 => NFTListing) public marketplace;

    constructor() ERC721("SimpleNFT", "SNFT") {}

    function mintNFT(string memory tokenURI) external {
        tokenCounter.increment();
        uint256 newTokenId = tokenCounter.current();
        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
    }

    function listNFT(uint256 tokenId, uint256 price) external {
        require(ownerOf(tokenId) == msg.sender, "You don't own this NFT");
        require(price > 0, "Price must be greater than 0");

        marketplace[tokenId] = NFTListing({
            price: price,
            seller: msg.sender,
            isActive: true
        });

        approve(address(this), tokenId);
    }

    function cancelListing(uint256 tokenId) external {
        NFTListing storage listing = marketplace[tokenId];
        require(listing.seller == msg.sender, "You didn't list this NFT");
        listing.isActive = false;
    }

    function buyNFT(uint256 tokenId) external payable {
        NFTListing memory listing = marketplace[tokenId];
        require(listing.isActive, "NFT is not for sale");
        require(msg.value >= listing.price, "Not enough ETH sent");

        marketplace[tokenId].isActive = false;

        _transfer(listing.seller, msg.sender, tokenId);
        payable(listing.seller).transfer(listing.price);
    }

    function isNFTListed(uint256 tokenId) external view returns (bool) {
        return marketplace[tokenId].isActive;
    }
}
