pragma solidity ^0.8.9;

interface ILendingPoolStorage {
    function addSmToken(
        address smTokenAddress,
        address asset,
        uint8 reserveDecimals
    ) external;

    function addSmLpToken(
        address lpTokenAddress,
        address smLpTokenAddress,
        address tokenX,
        address tokenY
    ) external;
}
