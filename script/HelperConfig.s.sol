// SPDX-License-Identifier: MIT
// This script sets up network configurations for different Ethereum networks,
// including Sepolia, Mainnet, and local Anvil instances. It deploys a mock
// price feed contract for local testing and provides the appropriate price
// feed address based on the active network.
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/MockV3Aggregator.sol";

contract HelperConfig is Script {
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER = 2000e8;
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address ethUsdPriceFeed;
    }
    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = GetSepoliaEthUsdPriceFeed();
        } else if (block.chainid == 1) {
            activeNetworkConfig = GetEthMainnetPriceFeed();
        } else {
            activeNetworkConfig = GetOrAnvilEthUsdPriceFeed();
        }
    }
    function GetSepoliaEthUsdPriceFeed() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({ethUsdPriceFeed: 
        0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    } 
    function GetOrAnvilEthUsdPriceFeed() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.ethUsdPriceFeed != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({ethUsdPriceFeed: 
        address(mockPriceFeed)});
        return anvilConfig;
    }
    function GetEthMainnetPriceFeed() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethMainnetConfig = NetworkConfig({ethUsdPriceFeed: 
        0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return ethMainnetConfig;
    }
}