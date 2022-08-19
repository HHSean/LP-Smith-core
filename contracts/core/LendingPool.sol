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
        uint256 amount, // lp token qty
        address onBehalfOf
    ) external override {
        // TODO transfer lpTokenAddress from msg.sender to smLpTokenAddress
        // TODO call smLpToken to mint token (disperse LP token is held here)
        // TODO transfer token X, token Y to lending pools here
    }

    function withdrawERC20LpToken(
        address lpTokenAddress,
        uint256 amount, // lp token qty (not sm lp token)
        address to
    ) external override returns (uint256) {
        // TODO get how much LP tokens should be minted(consider total LP token # - unrealised LP token #)
        // TODO get how much tokens are needed to mint that much LP token
        // TODO transfer token X, token Y to smLpToken
        // TODO burn smLpToken (mint LP token is held here)
    }

    /**
     * protocol erc20 deposit
     */
    function deposit(
        address asset,
        uint256 amount, // asset unit
        address onBehalfOf
    ) external override {
        // TODO transfer asset to smToken
        // TODO mint smToken -> debt calculation held inside here (to get smToken exchage rate)
    }

    /**
     * protocol erc20 withdraw
     */
    function withdraw(
        address asset,
        uint256 amount, // asset unit (not smToken unit)
        address to
    ) external override returns (uint256) {
        // TODO burn smToken -> debt calculation held inside here (to get smToken exchange rate)
        // TODO transfer asset from smToken to "to"
    }

    /**
     * protocol erc20 borrow
     */
    function borrow(
        address asset,
        uint256 amount,
        address onBehalfOf
    ) external override {
        // TODO 1. validate if user can borrow asset
        // TODO 1-1. should calculate user's deposit value
        // TODO 1-2. make sure it doesn't exceed liquidation threshold
        // TODO 2. transfer asset to user and update borrowed amount
    }

    /**
     * protocol erc20 repay
     */
    function repay(
        address asset,
        uint256 amount,
        address onBehalfOf
    ) external override returns (uint256) {
        // TODO transfer asset to smToken
        // TODO update borrowed amount of user
    }
}
