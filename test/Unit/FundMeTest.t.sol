// SPDX-License-Identifier: MIT
// This is a unit test for the FundMe contract, which tests various functionalities
// such as funding, withdrawing, and access control. It uses the Forge testing framework
// to simulate different scenarios and ensure the contract behaves as expected.

pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    HelperConfig helperConfig;
    address ethUsdPriceFeed;
    address USER = makeAddr("user");
    uint256 public constant c_AMOUNT = 10 ether;
    uint256 public constant STARTING_BALANCE = 100 ether;
    uint256 constant GAS_PRICE = 1 gwei;

    modifier Funded() {
        vm.prank(USER);
        fundMe.fund{value: c_AMOUNT}();
        _;
    }
//------------------------------------------------------------
    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        (fundMe, helperConfig) = deployFundMe.run();
        (ethUsdPriceFeed) = helperConfig.activeNetworkConfig();
        vm.deal(USER, STARTING_BALANCE);
    }
//------------------------------------------------------------    
    function testMinimumUSDisFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }
//------------------------------------------------------------
    function testIfOwnerIsMsgSender () public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }
//------------------------------------------------------------
    function testPriceFeedIsSetCorrectly() public view {
        address actualPriceFeed = address(fundMe.getPriceFeed());
        assertEq(actualPriceFeed, ethUsdPriceFeed);
    }
//------------------------------------------------------------
    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getPriceFeed().version();
        console.log(version);
        assertEq(version, 4);
    }
//------------------------------------------------------------
    function testFundFailsWithoutEnoughETH() public {
        console.log(address(fundMe).balance);
        vm.expectRevert();
        fundMe.fund();
    }
//------------------------------------------------------------
    function testFundPassWithEnoughEth() public Funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        console.log(address(fundMe).balance);
        assertEq(amountFunded, c_AMOUNT);
    }
//------------------------------------------------------------
    function testOnlyOwnerCanWithdraw() public { 
        vm.prank(USER);
        vm.expectRevert();
        fundMe.Withdraw();
    }
//------------------------------------------------------------
    function testIfAddressToAmountFundedWorks() public Funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, c_AMOUNT);

    }
//------------------------------------------------------------
    function testGetFunderWorks() public Funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);

    }
//------------------------------------------------------------
    function testGetOwnerWorks() public view {
        address owner = fundMe.getOwner();
        assertEq(owner, msg.sender);
    }
//------------------------------------------------------------
    function testWithdrawWorks() public Funded {
        // Arrange: fund contract from USER

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act: withdraw as owner
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.Withdraw();

        // Assert: contract balance is zero, owner's balance increased
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        assert(endingFundMeBalance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == endingOwnerBalance);
    }
//------------------------------------------------------------
    function testHelperConfigWorks() public view {
        assert(ethUsdPriceFeed == helperConfig.activeNetworkConfig());
    }
//------------------------------------------------------------
    function testWithManyFundersWithdrawWorks() public Funded {
        uint160 numberOfFunders = 10; // if you want to store addresses in array, max is 160
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank(address(i));
            //vm.deal(address(i), c_AMOUNT);
            hoax(address(i), c_AMOUNT);
            fundMe.fund{value: c_AMOUNT}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act: withdraw as owner
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.Withdraw();
        vm.stopPrank();
        // Assert: contract balance is zero, owner's balance increased
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        assert(endingFundMeBalance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == endingOwnerBalance);

    }
//------------------------------------------------------------

}
