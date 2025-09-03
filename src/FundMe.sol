// SPDX-License-Identifier: MIT
// This source code is for the FundMe contract, which allows users to fund the contract
// with ETH. It uses Chainlink price feeds to convert ETH to USD and ensures that
// a minimum funding amount is met. The contract owner can withdraw the funds.

// 1. Pragma
pragma solidity 0.8.19;

// 2. Imports
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

// 3. Interfaces, Libraries, Contracts
error FundMe__NotOwner();
error FundMe__NotEnoughEth();

contract FundMe {
    // Type Declarations
    using PriceConverter for uint256;

    // State variables
    uint256 public constant MINIMUM_USD = 5 * 1e18;
    address private immutable i_owner;
    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    AggregatorV3Interface private immutable i_priceFeed;

    // Events (we have none!)

    // Modifiers
    modifier onlyOwner() {
        // require(msg.sender == i_owner);
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    // Functions Order:
    //// constructor
    //// receive
    //// fallback
    //// external
    //// public
    //// internal
    //// private
    //// view / pure

    constructor(address ethUsdPriceFeed) {
        i_priceFeed = AggregatorV3Interface(ethUsdPriceFeed);
        i_owner = msg.sender;
    }

    function fund() external payable {
        if (msg.value.getConversionRate(i_priceFeed) < MINIMUM_USD) {
            revert FundMe__NotEnoughEth();
        }
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function Withdraw() external onlyOwner {
        address[] memory funders = s_funders;
        uint256 fundersLength = funders.length;
        for (uint256 i = 0; i < fundersLength; ) {
            s_addressToAmountFunded[funders[i]] = 0;
            unchecked {
                ++i;
            }
        }
        delete s_funders;
        (bool success,) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

    function getAddressToAmountFunded(address fundingAddress) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getVersion() external view returns (uint256) {
        return i_priceFeed.version();
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getPriceFeed() external view returns (AggregatorV3Interface) {
        return i_priceFeed;
    }
}