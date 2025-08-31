// SPDX-License-Identifier: MIT
// This script deploys the FundMe contract to the Ethereum network. It uses the
// HelperConfig contract to determine the appropriate price feed address based on
// the active network (e.g., Sepolia, Mainnet, or local Anvil).
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";


contract DeployFundMe is Script {

    function run() external returns (FundMe, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        (address ethUsdPriceFeed) = helperConfig.activeNetworkConfig();
        // Before Vm is simulated environment
        vm.startBroadcast();
        // After Vm is a real environment
        // Replace 'constructorArgument' with the actual argument required by FundMe's constructor
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return (fundMe, helperConfig);
    }
}
