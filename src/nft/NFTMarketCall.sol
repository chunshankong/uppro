pragma solidity >=0.7.0 <0.9.0;

import "src/nft/ERC721.sol";
import "src/erc20/ERC1363.sol";

// list() : 实现上架功能，NFT 持有者可以设定一个价格（需要多少个 Token 购买该 NFT）并上架 NFT 到 NFT 市场。
// buyNFT() : 实现购买 NFT 功能，用户转入所定价的 token 数量，获得对应的 NFT。

contract NFTMarketCall is IERC1363Receiver, IERC721Receiver {

    struct Listing {
        address seller;
        uint256 price;
    }

    mapping(uint256 => Listing) public listings;

    IERC20 public immutable tokenContract;
    IERC721 public immutable nftContract;

    constructor(address nftAddress,address tokenAddress){
        nftContract = IERC721(nftAddress);
        tokenContract = IERC20(tokenAddress)  ;
    }

    //收到NFT回调意味着卖家已转入合约，需要列出
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) override  external returns (bytes4) {
        require(msg.sender == address(nftContract), "Invalid NFT contract");
        uint256 price = abi.decode(data, (uint256));
        listings[tokenId] = Listing(from, price);
        return IERC721Receiver.onERC721Received.selector;
    }

    //收到代币回调意味着买家已转入合约，需要将代币转给卖家，NFT转给买家
    function tokensReceived(
        address from,
        uint256 amount,
        bytes calldata exData
    ) override external returns (bool) {
        
        require(msg.sender == address(tokenContract), "Invalid token contract");

        uint256 tokenId = abi.decode(exData, (uint256));

        Listing memory listing = listings[tokenId];

        require(
            amount == listing.price,
            "price error"
        );

        tokenContract.transfer(
            listing.seller,
            listing.price
        );

        nftContract.safeTransferFrom(
            address(this),
            from,
            tokenId
        );

        // 从 listings 映射中删除该 NFT 的信息
        delete listings[tokenId];
        return true;
    }

    function list(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    ) public {
        require(
            IERC721(nftAddress).ownerOf(tokenId) == msg.sender,
            "Not the owner"
        );
        // 确保市场合约被授权转移该 NFT
        require(
            IERC721(nftAddress).getApproved(tokenId) == address(this),
            "NFT not approved"
        );
        listings[tokenId] = Listing(msg.sender, price);
    }

    function buyNFT(
        address nftAddress,
        address tokenAddress,
        uint256 tokenId
    ) public {
        Listing memory listing = listings[tokenId];
        require(
            IERC721(nftAddress).ownerOf(tokenId) == listing.seller,
            "Owner has been transferred"
        );

        IERC20(tokenAddress).transferFrom(
            msg.sender,
            listing.seller,
            listing.price
        );

        IERC721(nftAddress).safeTransferFrom(
            listing.seller,
            msg.sender,
            tokenId
        );

        // 从 listings 映射中删除该 NFT 的信息
        delete listings[tokenId];
    }
    
}
