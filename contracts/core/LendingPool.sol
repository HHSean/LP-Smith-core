pragma solidity ^0.8.9;

import {ILendingPool} from "./interfaces/ILendingPool.sol";
import {ISmLpToken} from "./interfaces/ISmLpToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IFactory} from "./interfaces/IFactory.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// TODO Noah
contract LendingPool is ILendingPool {
    using SafeMath for uint256;

    // mapping(address => address) cdTokenMap; // CD: Certificate of Deposit; left-hand: underlying token; right-hand: cd Token address
    mapping(address => address) smLpTokenMap; // left-hand: underlying token; right-hand: cd Token address
    mapping(address => address) smTokenMap; // left-hand: underlying token; right-hand: cd Token address
    mapping(address => ISmLpToken[]) smLpTokenListPerAsset; // smLpToken list of certain asset

    mapping(address => uint256) assetLockedPerCdToken;

    modifier onlySmLpToken(address asset) {
        ISmLpToken[] storage smLpTokenList = smLpTokenListPerAsset[asset];
        uint256 length = smLpTokenList.length;
        bool flag = false;
        for (uint80 i = 0; i < length; i++) {
            if (address(smLpTokenList[i]) == msg.sender) {
                flag = true;
            }
        }
        require(flag, "Your not smLpToken");
        _;
    }

    function getLpDebts(address asset)
        external
        view
        override
        returns (uint256 _debt)
    {
        // iterate smLpTokens and aggregate total debt
        ISmLpToken[] storage smLpTokenList = smLpTokenListPerAsset[asset];
        uint256 length = smLpTokenList.length;
        for (uint i = 0; i < length; i++) {
            _debt += ISmLpToken(address(smLpTokenList[i])).getDebt(asset);
        }
    }

    function getPotentialOnSale(address asset)
        external
        view
        returns (bool _sign, uint256 _potentialOnSale)
    {
        // iterate smLpTokens and sum up potential on sale
        ISmLpToken[] storage smLpTokenList = smLpTokenListPerAsset[asset];
        uint256 length = smLpTokenList.length;
        uint256 positivePotentialOnSale;
        uint256 negativePotentialOnSale;
        for (uint i = 0; i < length; i++) {
            (bool sign, uint256 potentialOnSale) = ISmLpToken(
                address(smLpTokenList[i])
            ).getPotentialOnSale(asset);
            if (sign == true) {
                positivePotentialOnSale += potentialOnSale;
            } else {
                negativePotentialOnSale += potentialOnSale;
            }
        }
        if (positivePotentialOnSale >= negativePotentialOnSale) {
            // positive sign
            _potentialOnSale = positivePotentialOnSale.sub(
                negativePotentialOnSale
            );
            _sign = true;
        } else {
            // negative sign
            _potentialOnSale = negativePotentialOnSale.sub(
                positivePotentialOnSale
            );
            _sign = false;
        }
    }

    function getPendingOnSale(address asset)
        external
        view
        returns (bool _sign, uint256 _pendingOnSale)
    {
        // iterate smLpTokens and sum up potential on sale
        ISmLpToken[] storage smLpTokenList = smLpTokenListPerAsset[asset];
        uint256 length = smLpTokenList.length;
        uint256 positivePendingOnSale;
        uint256 negativePendingOnSale;
        for (uint i = 0; i < length; i++) {
            (bool sign, uint256 pendingOnSale) = ISmLpToken(
                address(smLpTokenList[i])
            ).getPendingOnSale(asset);
            if (sign == true) {
                positivePendingOnSale += pendingOnSale;
            } else {
                negativePendingOnSale += pendingOnSale;
            }
        }
        if (positivePendingOnSale >= negativePendingOnSale) {
            // positive sign
            _pendingOnSale = positivePendingOnSale.sub(negativePendingOnSale);
            _sign = true;
        } else {
            // negative sign
            _pendingOnSale = negativePendingOnSale.sub(positivePendingOnSale);
            _sign = false;
        }
    }

    function depositERC20LpToken(
        address lpTokenAddress,
        uint256 amount, // lp token qty
        address onBehalfOf
    ) external override {
        // TODO transfer lpToken from msg.sender to smLpTokenAddress
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

    function requestFund(address asset, uint256 amount)
        external
        onlySmLpToken(asset)
    {
        require(
            assetLockedPerCdToken[smTokenMap[asset]] > amount,
            "Not enough fund to pass"
        );
        IERC20(asset).transferFrom(smTokenMap[asset], msg.sender, amount);
        assetLockedPerCdToken[smTokenMap[asset]] -= amount;
    }
}
