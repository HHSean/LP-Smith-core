// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./interfaces/chainlink/AggregatorV3Interface.sol";

contract ChainLinkPriceOracle {

    AggregatorV3Interface internal priceFeed;

    constructor() {
        priceFeed = AggregatorV3Interface(0xF9680D99D6C9589e2a93a78A04A279e509205945);
    }

    function getLatestPrice() public view returns (int) {
    (
        uint80 roundID,
        int price,
        uint startedAt,
        uint timeStamp,
        uint80 answeredInRound
    ) = priceFeed.latestRoundData();
    return price / 1e8;
    }



}