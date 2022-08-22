// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {ILendingPool} from "./interfaces/ILendingPool.sol";
import {IPriceOracle} from "./interfaces/IPriceOracle.sol";
import {IFactory} from "./interfaces/IFactory.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

// change name into factory
contract Factory is Ownable, IFactory {
    ILendingPool public lendingPool;
    IPriceOracle public priceOracle;

    function getLendingPool() external view returns (address) {
        return address(lendingPool);
    }

    function setLendingPool(address _lpPoolAddress) external onlyOwner {
        lendingPool = ILendingPool(_lpPoolAddress);
        emit SetLendingPool(_lpPoolAddress);
    }

    function setPriceOracle(address _priceOracleAddress) external onlyOwner {
        priceOracle = IPriceOracle(_priceOracleAddress);
        emit SetPriceOracle(_priceOracleAddress);
    }

    function getPriceOracle() external view returns (address) {
        return address(priceOracle);
    }
}
