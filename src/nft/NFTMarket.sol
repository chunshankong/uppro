pragma solidity >=0.7.0 <0.9.0;

import "src/nft/ERC721.sol";
import "src/erc20/BaseERC20.sol";

// list() : 实现上架功能，NFT 持有者可以设定一个价格（需要多少个 Token 购买该 NFT）并上架 NFT 到 NFT 市场。
// buyNFT() : 实现购买 NFT 功能，用户转入所定价的 token 数量，获得对应的 NFT。

contract NFTMarket {
    // 列出 NFT 的结构体，包含卖家的地址和价格
    struct Listing {
        address seller;
        uint256 price;
    }

    // tokenId 到 Listing 结构体的映射，用于存储所有上架的 NFT
    mapping(uint256 => Listing) public listings;

    IERC20 public immutable tokenContract;
    IERC721 public immutable nftContract;

    event NFTListed(uint256 indexed tokenId, address indexed seller, uint256 price);
    
    event NFTBought(uint256 indexed tokenId, address indexed seller, address indexed buyer, uint256 price);


    constructor(address nftAddress,address tokenAddress){
        nftContract = IERC721(nftAddress);
        tokenContract = IERC20(tokenAddress);
    }

    function list(
        uint256 tokenId,
        uint256 price
    ) public {
        require(
            nftContract.ownerOf(tokenId) == msg.sender,
            "Not the owner"
        );
        // 确保市场合约被授权转移该 NFT
        require(
            nftContract.getApproved(tokenId) == address(this),
            "NFT not approved"
        );
        listings[tokenId] = Listing(msg.sender, price);
        emit NFTListed(tokenId, msg.sender, price);
    }

    function buyNFT(
        uint256 tokenId
    ) public {
        Listing memory listing = listings[tokenId];
        require(listing.seller != address(0), "NFT not listed");
        require(
            nftContract.ownerOf(tokenId) == listing.seller,
            "Owner has been transferred"
        );

        tokenContract.transferFrom(
            msg.sender,
            listing.seller,
            listing.price
        );

        nftContract.safeTransferFrom(
            listing.seller,
            msg.sender,
            tokenId
        );

        // 从 listings 映射中删除该 NFT 的信息
        delete listings[tokenId];
        emit NFTBought(tokenId, listing.seller, msg.sender, listing.price);
    }
    
    function getListSeller(uint256 tokenId) public view returns(address){
        return listings[tokenId].seller;
    }

}

