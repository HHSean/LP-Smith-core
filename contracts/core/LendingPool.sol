pragma solidity ^0.8.9;

import {ILendingPool} from "./interfaces/ILendingPool.sol";
import {ISmLpToken} from "./interfaces/ISmLpToken.sol";
import {ISmToken} from "./interfaces/ISmToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IFactory} from "./interfaces/IFactory.sol";
import {LendingPoolStorage} from "./LendingPoolStorage.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// TODO Noah
contract LendingPool is ILendingPool, LendingPoolStorage {
    using SafeMath for uint256;

    // mapping(address => address) cdTokenMap; // CD: Certificate of Deposit; left-hand: underlying token; right-hand: cd Token address
    mapping(address => address) smLpTokenMap; // left-hand: underlying token; right-hand: cd Token address
    mapping(address => address) smTokenMap; // left-hand: underlying token; right-hand: cd Token address
    mapping(address => ISmLpToken[]) smLpTokenListPerAsset; // smLpToken list of certain asset

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
        uint256 amount // lp token qty
    ) external override {
        address smLpTokenAddress = address(smLpTokenMap[lpTokenAddress]);
        // transfer lpToken from msg.sender to smLpTokenAddress
        IERC20(lpTokenAddress).transferFrom(
            msg.sender,
            smLpTokenAddress,
            amount
        );
        // call smLpToken to mint token (disperse LP token is held here)
        (uint256 amountX, uint256 amountY, bool isFirstDeposit) = ISmLpToken(
            smLpTokenAddress
        ).mint(msg.sender, amount);
        if (isFirstDeposit) {
            smLpTokenDepositListPerUser[msg.sender].push(smLpTokenAddress); // TODO check this... If I can push user like this
        }

        address tokenX = ISmLpToken(smLpTokenAddress).tokenX();
        address tokenY = ISmLpToken(smLpTokenAddress).tokenY();

        _transferUnderlyingToSmToken(tokenX, amountX);
        _transferUnderlyingToSmToken(tokenY, amountY);
    }

    function _transferUnderlyingToSmToken(address token, uint256 amount)
        private
    {
        address smToken = smTokenMap[token];
        IERC20(token).transfer(smToken, amount);
        ReserveData storage reserve = _reserves[smToken];
        reserve.depositedAmount += amount;
    }

    function getDepositedLpValue(address user)
        public
        returns (uint256 _depositValue)
    {
        // TODO
        address[] storage smLpTokenList = smLpTokenDepositListPerUser[user];
        uint256 length = smLpTokenList.length;
        for (uint i = 0; i < length; i++) {
            /*
            (bool sign, uint256 pendingOnSale) = ISmLpToken(
                smLpTokenList[i]
            )*/
        }
    }

    function getBorrowableValue(address user)
        public
        returns (uint256 _borrowableValue)
    {
        // TODO
    }

    function getBorrowedValue() public returns (uint256 _borrowedValue) {
        // TODO
    }

    function withdrawERC20LpToken(
        address lpTokenAddress,
        uint256 amount // lp token qty (not sm lp token)
    ) external override returns (uint256) {
        // TODO check if it's withdrawable
        // TODO get deposit value of user

        // TODO get borrow value of user

        address smLpTokenAddress = address(smLpTokenMap[lpTokenAddress]);
        // TODO burn smLpToken
        ISmLpToken(smLpTokenAddress).burn(msg.sender, amount);
        // TODO transfer token X, token Y to smLpToken
        // TODO burn smLpToken (mint LP token is held here)
    }

    /**
     * protocol erc20 deposit
     */
    function deposit(
        address asset,
        uint256 amount // asset unit
    ) external override {
        // TODO transfer asset to smToken
        // TODO mint smToken -> debt calculation held inside here (to get smToken exchage rate)
    }

    /**
     * protocol erc20 withdraw
     */
    function withdraw(
        address asset,
        uint256 amount // asset unit (not smToken unit)
    ) external override returns (uint256) {
        // TODO burn smToken -> debt calculation held inside here (to get smToken exchange rate)
        // TODO transfer asset from smToken to "to"
    }

    /**
     * protocol erc20 borrow
     */
    function borrow(address asset, uint256 amount) external override {
        // TODO 1. validate if user can borrow asset
        // TODO 1-1. should calculate user's deposit value
        // TODO 1-2. make sure it doesn't exceed liquidation threshold
        // TODO 2. transfer asset to user and update borrowed amount
    }

    /**
     * protocol erc20 repay
     */
    function repay(address asset, uint256 amount)
        external
        override
        returns (uint256)
    {
        // TODO transfer asset to smToken
        // TODO update borrowed amount of user
    }

    function requestFund(address asset, uint256 amount)
        external
        onlySmLpToken(asset)
    {
        address smTokenAddress = smTokenMap[asset];
        ReserveData storage reserve = _reserves[smTokenAddress];
        require(
            reserve.depositedAmount.sub(reserve.borrowedAmount) > amount,
            "Not enough fund to pass"
        );
        IERC20(asset).transferFrom(smTokenAddress, msg.sender, amount);
        reserve.depositedAmount -= amount;
    }
}
