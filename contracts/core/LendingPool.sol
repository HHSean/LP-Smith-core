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
        // TODO call smLpToken to mint token
        // IERC20(smLpTokenAddresses[lpTokenAddress]).mint();
    }

    function withdrawERC20LpToken(
        address lpTokenAddress,
        uint256 amount, // lp token qty (not sm lp token)
        address to
    ) external override returns (uint256) {
        // TODO check if user has LP token generated
        // TODO if don't, mint LP token and transfer to recipient
        // TODO burn smLpToken
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
        // TODO mint smToken
    }

    /**
     * protocol erc20 withdraw
     */
    function withdraw(
        address asset,
        uint256 amount, // asset unit (not smToken unit)
        address to
    ) external override returns (uint256) {
        // TODO burn smToken
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
        // TODO
    }

    /**
     * protocol erc20 repay
     */
    function repay(
        address asset,
        uint256 amount,
        address onBehalfOf
    ) external override returns (uint256) {
        // TODO
    }
}
