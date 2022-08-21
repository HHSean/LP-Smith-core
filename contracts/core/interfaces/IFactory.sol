// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IFactory {
    event SetLendingPool(address poolAddress);

    event SetPriceOracle(address priceOracleAddress);

    function getLendingPool() external view returns (address);

    function setLendingPool(address _lendingPoolAddress) external;

    function getPriceOracle() external view returns (address);

    function setPriceOracle(address _priceOracleAddress) external;
}
