pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {NFTMarket} from "../src/nft/NFTMarket.sol";
import {BaseERC20} from "../src/erc20/BaseERC20.sol";
import {MyNFT} from "../src/nft/ERC721.sol";
/**
上架NFT：测试上架成功和失败情况，要求断言错误信息和上架事件。
购买NFT：测试购买成功、自己购买自己的NFT、NFT被重复购买、支付Token过多或者过少情况，要求断言错误信息和购买事件。
模糊测试：测试随机使用 0.01-10000 Token价格上架NFT，并随机使用任意Address购买NFT
「可选」不可变测试：测试无论如何买卖，NFTMarket合约中都不可能有 Token 持仓
 */
contract NFTMarketTest is Test {
    NFTMarket public market;
    MyNFT public nft;
    BaseERC20 public token;

    function setUp() public {
        token = new BaseERC20();
        nft = new MyNFT();
        market = new NFTMarket(address(nft), address(token));
    }

    function test_list() public {
        address seller = address(0x37D5F39EB1F63B471D30b1Ede3F8d6eeBc3aFC47);
        // 为之后的一系列调用设置 msg.sender
        vm.startPrank(seller);

        // 停止上次的设置
        // vm.stopPrank()

        //mint nft
        uint256 tid = nft.mint();
        assertEq(nft.balanceOf(seller), 1, "Wrong balance");
        //list nft
        assertEq(nft.ownerOf(tid), seller, "owner error");

        nft.approve(address(market), tid);
        uint256 price = 100000;
        vm.expectEmit(true, true, true, true);
        emit NFTMarket.NFTListed(tid, seller, price);
        market.list(tid, price);

        assertEq(market.getListSeller(tid), seller, "list failed");
    }

    function test_buy() public {
        address seller = address(0x37D5F39EB1F63B471D30b1Ede3F8d6eeBc3aFC47);
        // 为之后的一系列调用设置 msg.sender
        vm.startPrank(seller);

        //mint nft
        uint256 tid = nft.mint();
        assertEq(nft.balanceOf(seller), 1, "Wrong balance");
        //list nft
        assertEq(nft.ownerOf(tid), seller, "owner error");

        nft.approve(address(market), tid);
        uint256 price = 100000;
        vm.expectEmit(true, true, true, true);
        emit NFTMarket.NFTListed(tid, seller, price);
        market.list(tid, price);

        assertEq(market.getListSeller(tid), seller, "list failed");

        // 停止上次的设置
        vm.stopPrank();

        //buy nft
        address buyer = address(0xa3A7a52Ffd0a44Eacf276Af28657DAfB424805F1);
        // 为之后的一系列调用设置 msg.sender
        vm.startPrank(buyer);
        token.issuance(buyer, price); //发币
        token.approve(address(market), price);
        vm.expectEmit(true, true, true, true);
        emit NFTMarket.NFTBought(tid, seller, buyer, price);
        market.buyNFT(tid);
        //check balance
        assertEq(nft.ownerOf(tid), buyer, "owner error");
        assertEq(token.balanceOf(seller), price, "price error");
    }

    //重复购买
    function test_repeatBuy() public {
        address seller = address(0x37D5F39EB1F63B471D30b1Ede3F8d6eeBc3aFC47);
        // 为之后的一系列调用设置 msg.sender
        vm.startPrank(seller);

        //mint nft
        uint256 tid = nft.mint();
        assertEq(nft.balanceOf(seller), 1, "Wrong balance");
        //list nft
        assertEq(nft.ownerOf(tid), seller, "owner error");

        nft.approve(address(market), tid);
        uint256 price = 100000;
        vm.expectEmit(true, true, true, true);
        emit NFTMarket.NFTListed(tid, seller, price);
        market.list(tid, price);

        assertEq(market.getListSeller(tid), seller, "list failed");

        // 停止上次的设置
        vm.stopPrank();

        //buy nft
        address buyer = address(0xa3A7a52Ffd0a44Eacf276Af28657DAfB424805F1);
        // 为之后的一系列调用设置 msg.sender
        vm.startPrank(buyer);
        token.issuance(buyer, price); //发币
        token.approve(address(market), price);
        vm.expectEmit(true, true, true, true);
        emit NFTMarket.NFTBought(tid, seller, buyer, price);
        market.buyNFT(tid);
        //check balance
        assertEq(nft.ownerOf(tid), buyer, "owner error");
        assertEq(token.balanceOf(seller), price, "price error");

        //买家2尝试购买
        address buyer2 = address(0xc29899f3A9D3E4d2FbBb9d53D4d98A78109C3Ec3);
        // 停止上次的设置
        vm.stopPrank();
        // 为之后的一系列调用设置 msg.sender
        vm.startPrank(buyer2);
        token.issuance(buyer2, price); //发币
        token.approve(address(market), price);
        vm.expectRevert("NFT not listed");
        market.buyNFT(tid);
    }

function test_buy_not_enough() public {
        address seller = address(0x37D5F39EB1F63B471D30b1Ede3F8d6eeBc3aFC47);
        // 为之后的一系列调用设置 msg.sender
        vm.startPrank(seller);

        //mint nft
        uint256 tid = nft.mint();
        assertEq(nft.balanceOf(seller), 1, "Wrong balance");
        //list nft
        assertEq(nft.ownerOf(tid), seller, "owner error");

        nft.approve(address(market), tid);
        uint256 price = 100000;
        vm.expectEmit(true, true, true, true);
        emit NFTMarket.NFTListed(tid, seller, price);
        market.list(tid, price);

        assertEq(market.getListSeller(tid), seller, "list failed");

        // 停止上次的设置
        vm.stopPrank();

        //buy nft
        address buyer = address(0xa3A7a52Ffd0a44Eacf276Af28657DAfB424805F1);
        // 为之后的一系列调用设置 msg.sender
        vm.startPrank(buyer);
        token.issuance(buyer, price-100); //发币
        token.approve(address(market), price-100);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        market.buyNFT(tid);
        
    }

    function test_FuzzBuy(address buyer, uint256 price) public {
        vm.assume(buyer != address(0));
        vm.assume(price > 0.00000000001 ether && price < 0.00001 ether);

        address seller = address(0x37D5F39EB1F63B471D30b1Ede3F8d6eeBc3aFC47);
        // 为之后的一系列调用设置 msg.sender
        vm.startPrank(seller);

        //mint nft
        uint256 tid = nft.mint();
        assertEq(nft.balanceOf(seller), 1, "Wrong balance");
        //list nft
        assertEq(nft.ownerOf(tid), seller, "owner error");

        nft.approve(address(market), tid);

        vm.expectEmit(true, true, true, true);
        emit NFTMarket.NFTListed(tid, seller, price);
        market.list(tid, price);

        assertEq(market.getListSeller(tid), seller, "list failed");

        // 停止上次的设置
        vm.stopPrank();

        //buy nft

        // 为之后的一系列调用设置 msg.sender
        vm.startPrank(buyer);
        token.issuance(buyer, price); //发币
        token.approve(address(market), price);
        // vm.expectEmit(true, true, true, true);
        // emit NFTMarket.NFTBought(tid, seller, buyer, price);
        market.buyNFT(tid);
        //check balance
        assertEq(nft.ownerOf(tid), buyer, "owner error");
        assertEq(token.balanceOf(seller), price, "price error");
    }


}
