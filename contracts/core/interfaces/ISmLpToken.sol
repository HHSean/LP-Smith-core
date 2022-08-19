pragma solidity ^0.8.9;

interface ISmLpToken {
    function debt(address tokenAddress) external view;

    function getPositionValue(address user) external view;

    function LP_TOKEN_CONTRACT_ADDRESS() external view returns (address);
}
