pragma solidity ^0.8.9;

import {ILendingPool} from "./interfaces/ILendingPool.sol";
import {ISmLpToken} from "./interfaces/ISmLpToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LendingPool is ILendingPool {
    ISmLpToken[] smLpTokens;
    mapping(address => address) smLpTokenAddresses;

    function getLpDebts(address asset)
        external
        view
        override
        returns (uint256 _debt)
    {
        // TODO iterate smLpTokens and aggregate total debt
    }

    function depositERC20LpToken(
        address lpTokenAddress,
        uint256 amount,
        address onBehalfOf
    ) external override {
        // TODO transfer lpTokenAddress from msg.sender to smLpTokenAddress
        // TODO call smLpToken to mint token
        // IERC20(smLpTokenAddresses[lpTokenAddress]).mint();
    }

    function withdrawERC20LpToken(
        address lpTokenAddress,
        uint256 amount,
        address to
    ) external override returns (uint256) {
        // TODO transfer lpTokenAddress from
    }

    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf
    ) external override {
        // TODO
    }

    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external override returns (uint256) {
        // TODO
    }

    function borrow(
        address asset,
        uint256 amount,
        address onBehalfOf
    ) external override {
        // TODO
    }

    function repay(
        address asset,
        uint256 amount,
        address onBehalfOf
    ) external override returns (uint256) {
        // TODO
    }
}
