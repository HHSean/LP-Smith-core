// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./interfaces/chainlink/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PriceOracle is Ownable {
    mapping(address => address) public assetToDollarPriceFeed;

    constructor() {}

    function getAssetPrice(address asset) public view returns (int256) {
        (
            uint80 roundID,
            int256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint80 answeredInRound
        ) = AggregatorV3Interface(assetToDollarPriceFeed[asset])
                .latestRoundData();
        return price * 1e10;
    }

    function setAssetToPriceFeed(address _token, address _dollarPriceFeed)
        public
        onlyOwner
    {
        assetToDollarPriceFeed[_token] = _dollarPriceFeed;
    }
}
