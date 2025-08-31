// SPDX-License-Identifier: MIT
// This is an integration test for the FundMe contract, which tests the funding and withdrawal
// functionalities using the FundInteractions and WithdrawInteractions scripts. It sets up
// the contract, funds it with a user account, and then withdraws the funds to ensure
// everything works as expected.

pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {FundInteractions, WithdrawInteractions} from "../../script/interactions.s.sol";

contract FundMeTestIntergation is Test {
    FundMe fundMe;
    HelperConfig helperConfig;
    address ethUsdPriceFeed;
    address USER = makeAddr("user");
    uint256 public constant c_AMOUNT = 10 ether;
    uint256 public constant STARTING_BALANCE = 100 ether;
    uint256 constant GAS_PRICE = 1 gwei;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        (fundMe, helperConfig) = deployFundMe.run();
        (ethUsdPriceFeed) = helperConfig.activeNetworkConfig();
        vm.deal(USER, STARTING_BALANCE);

    }
    function testUserCanFundInteractions() public {
        FundInteractions fundInteractions = new FundInteractions();
        vm.deal(address(fundInteractions), 1 ether); // Give the contract enough ETH
        fundInteractions.FundFundMe(address(fundMe));

        WithdrawInteractions withdrawInteractions = new WithdrawInteractions();
        withdrawInteractions.WithdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
        
    }
}
