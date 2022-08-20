pragma solidity ^0.8.9;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ISmLpToken is IERC20 {
    function debt(address tokenAddress) external view;

    function getPotentialOnSale(address asset)
        external
        view
        returns (bool sign, uint256 _potentialOnSale);

    function getPendingOnSale(address asset)
        external
        view
        returns (bool sign, uint256 _pendingOnSale);

    function getPositionValue(address user) external view;

    function LP_TOKEN_CONTRACT_ADDRESS() external view returns (address);

    function tokenX() external view returns (address);

    function tokenY() external view returns (address);
}
