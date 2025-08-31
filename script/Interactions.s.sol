// FUND & WITHDRAW INTERACTIONS

// SPDX-License-Identifier: MIT

// This script provides interaction functions to fund and withdraw from the FundMe contract.
// It uses the DevOpsTools library to fetch the most recently deployed FundMe contract
// and performs funding and withdrawal operations.

pragma solidity 0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract FundInteractions is Script {
    uint256 constant SEND_VALUE = 0.1 ether;

    function FundFundMe(address MostRecentlyDeployed) public {
        FundMe(payable(MostRecentlyDeployed)).fund{value: SEND_VALUE}();
        console.log("Funded FundMe with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        FundMe fundMe = FundMe(mostRecentlyDeployed);
        
        vm.startBroadcast();
        FundFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}

contract WithdrawInteractions is Script {
    uint256 constant SEND_VALUE = 0.1 ether;

    function WithdrawFundMe(address MostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(MostRecentlyDeployed)).Withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        FundMe fundMe = FundMe(mostRecentlyDeployed);
        
        vm.startBroadcast();
        WithdrawFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }


}