pragma solidity ^0.8.9;

import {ILendingPool} from "./interfaces/ILendingPool.sol";
import {IPriceOracle} from "./interfaces/IPriceOracle.sol";
import {ISmLpToken} from "./interfaces/ISmLpToken.sol";
import {ISmToken} from "./interfaces/ISmToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IFactory} from "./interfaces/IFactory.sol";
import {GeneralLogic} from "./libraries/GeneralLogic.sol";
import {LendingPoolStorage} from "./LendingPoolStorage.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";

// TODO Noah
contract LendingPool is ILendingPool, LendingPoolStorage {
    using SafeMath for uint256;

    // mapping(address => address) cdTokenMap; // CD: Certificate of Deposit; left-hand: underlying token; right-hand: cd Token address
    mapping(address => address) smLpTokenMap; // left-hand: underlying token; right-hand: cd Token address
    mapping(address => address) smTokenMap; // left-hand: underlying token; right-hand: cd Token address
    mapping(address => ISmLpToken[]) smLpTokenListPerAsset; // smLpToken list of certain asset
    address public factory;
    uint80 constant HF_DECIMALS = 1000000;

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

    modifier validWithdrawal() {
        _;
        require(
            getBorrowableValue(msg.sender) > getBorrowedValue(msg.sender),
            "LP token not withdrawable"
        );
    }

    function getHealthFactor(address user)
        public
        view
        returns (
            uint256 _healthFactor // decimal 6
        )
    {
        uint256 borrowedAmount = getBorrowedValue(user);
        if (borrowedAmount == 0) {
            _healthFactor = type(uint256).max;
        } else {
            _healthFactor = getBorrowableValue(user).mul(HF_DECIMALS).div(
                borrowedAmount
            );
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
            smLpTokenDepositListPerUser[msg.sender].push(smLpTokenAddress);
        }

        address tokenX = ISmLpToken(smLpTokenAddress).tokenX();
        _transferReserveToSmToken(tokenX, smLpTokenAddress, amountX, true);

        address tokenY = ISmLpToken(smLpTokenAddress).tokenY();
        _transferReserveToSmToken(tokenY, smLpTokenAddress, amountY, true);
    }

    function withdrawERC20LpToken(
        address lpTokenAddress,
        uint256 amount // lp token qty (not sm lp token)
    ) external override validWithdrawal returns (uint256) {
        address smLpTokenAddress = address(smLpTokenMap[lpTokenAddress]);
        ISmLpToken(smLpTokenAddress).burn(msg.sender, amount);
    }

    /**
     * protocol erc20 deposit
     */
    function deposit(
        address asset,
        uint256 amount // asset unit
    ) external override {
        // transfer asset to smToken
        _transferReserveToSmToken(asset, msg.sender, amount, true);
        address smTokenAddress = address(smLpTokenMap[asset]);
        uint256 liquidityIndex = getLiquidityIndex(asset);
        ISmToken(smTokenAddress).mint(msg.sender, amount, liquidityIndex);
    }

    /**
     * protocol erc20 withdraw
     */
    function withdraw(
        address asset,
        uint256 amount // asset unit (not smToken unit)
    ) external override validWithdrawal returns (uint256) {
        uint256 liquidityIndex = getLiquidityIndex(asset);
        address smTokenAddress = smTokenMap[asset];
        ISmToken(smTokenAddress).burn(msg.sender, amount, liquidityIndex);
        // transfer asset from smToken to "to"
        _transferReserveFromSmToken(asset, msg.sender, amount, true);
    }

    /**
     * protocol erc20 borrow
     */
    function borrow(address asset, uint256 amount)
        external
        override
        validWithdrawal
    {
        _transferReserveFromSmToken(asset, msg.sender, amount, false);
        UserDebtData storage debtData = _userDebtDatas[asset][msg.sender];
        if (!debtData.wasBorrowed) {
            debtData.wasBorrowed = true;
            reserveBorrowListPerUser[msg.sender].push(asset);
        }
        debtData.borrowedAmount += amount;
    }

    /**
     * protocol erc20 repay
     */
    function repay(address asset, uint256 amount)
        external
        override
        returns (uint256)
    {
        _repay(msg.sender, asset, amount);
    }

    function _repay(
        address user,
        address asset,
        uint256 amount
    ) internal returns (uint256) {
        // transfer asset to smToken
        _transferReserveToSmToken(asset, user, amount, false);
        // update borrowed amount of user
        _userDebtDatas[asset][user].borrowedAmount -= amount;
    }

    function requestFund(address asset, uint256 amount)
        external
        onlySmLpToken(asset)
    {
        _transferReserveFromSmToken(asset, msg.sender, amount, true);
    }

    function _transferReserveToSmToken(
        address asset,
        address from,
        uint256 amount,
        bool isDeposit
    ) private {
        address smToken = smTokenMap[asset];
        require(
            IERC20(asset).balanceOf(from) > amount,
            "Not enough fund to pass"
        );
        IERC20(asset).transferFrom(from, smToken, amount);
        ReserveData storage reserve = _reserves[smToken];
        reserve.availAmount += amount;
        if (isDeposit) {
            reserve.depositAmount += amount;
        } else {
            reserve.borrowAmount -= amount;
        }
    }

    function _transferReserveFromSmToken(
        address asset,
        address to,
        uint256 amount,
        bool isWithdraw
    ) private {
        address smTokenAddress = smTokenMap[asset];
        ReserveData storage reserve = _reserves[smTokenAddress];
        require(reserve.availAmount > amount, "Not enough fund to pass");
        IERC20(asset).transferFrom(smTokenAddress, to, amount);
        reserve.availAmount -= amount;
        if (isWithdraw) {
            reserve.depositAmount -= amount;
        } else {
            reserve.borrowAmount += amount;
        }
    }

    function getDepositedLpValue(address user)
        public
        view
        returns (uint256 _depositValue)
    {
        address[] storage smLpTokenList = smLpTokenDepositListPerUser[user];
        uint256 length = smLpTokenList.length;
        for (uint i = 0; i < length; i++) {
            _depositValue += ISmLpToken(smLpTokenList[i]).getDepositValue(user);
        }
    }

    function getBorrowableValue(address user)
        public
        view
        returns (uint256 _borrowableValue)
    {
        address[] storage smLpTokenList = smLpTokenDepositListPerUser[user];
        uint256 length = smLpTokenList.length;
        for (uint i = 0; i < length; i++) {
            _borrowableValue += ISmLpToken(smLpTokenList[i]).getBorrowableValue(
                    user
                );
        }
    }

    function getBorrowedValue(address user)
        public
        view
        returns (uint256 _borrowedValue)
    {
        IPriceOracle priceOracle = IPriceOracle(
            IFactory(factory).getPriceOracle()
        );
        address[] storage borrowList = reserveBorrowListPerUser[user];
        uint256 length = borrowList.length;
        for (uint256 i = 0; i < length; i++) {
            address asset = borrowList[i];
            uint256 price = priceOracle.getAssetPrice(asset);
            _borrowedValue += GeneralLogic.getUnderlyingValue(
                uint248(_userDebtDatas[asset][user].borrowedAmount),
                _reserves[asset].reserveDecimals,
                price
            );
        }
    }

    function _getLpDebts(address asset, ISmLpToken[] storage smLpTokenList)
        internal
        view
        returns (uint256 _debt)
    {
        // iterate smLpTokens and aggregate total debt
        uint256 length = smLpTokenList.length;
        for (uint i = 0; i < length; i++) {
            _debt += ISmLpToken(address(smLpTokenList[i])).getDebt(asset);
        }
    }

    function _getPotentialOnSale(
        address asset,
        ISmLpToken[] storage smLpTokenList
    ) internal view returns (bool _sign, uint256 _potentialOnSale) {
        // iterate smLpTokens and sum up potential on sale
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

    function _getPendingOnSale(
        address asset,
        ISmLpToken[] storage smLpTokenList
    ) internal view returns (bool _sign, uint256 _pendingOnSale) {
        // iterate smLpTokens and sum up potential on sale
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

    function getLiquidityIndex(address asset)
        public
        view
        returns (uint256 _liquidityIndex)
    {
        ReserveData storage reserve = _reserves[asset];
        ISmLpToken[] storage smLpTokenList = smLpTokenListPerAsset[asset];
        _liquidityIndex = reserve.depositAmount;
        _liquidityIndex -= _getLpDebts(asset, smLpTokenList);
        (bool sign0, uint256 potentialOnSale) = _getPotentialOnSale(
            asset,
            smLpTokenList
        );
        if (sign0) {
            _liquidityIndex += potentialOnSale;
        } else {
            _liquidityIndex -= potentialOnSale;
        }
        (bool sign1, uint256 pendingOnSale) = _getPendingOnSale(
            asset,
            smLpTokenList
        );
        if (sign1) {
            _liquidityIndex += pendingOnSale;
        } else {
            _liquidityIndex -= pendingOnSale;
        }
    }

    function swap(
        address lpTokenAddress,
        address tokenFrom,
        address tokenTo,
        uint256 amount,
        uint256 minimumReceive
    ) external returns (uint256 _swapOutput) {
        _transferReserveToSmToken(tokenFrom, msg.sender, amount, true);

        IPriceOracle priceOracle = IPriceOracle(
            IFactory(factory).getPriceOracle()
        );
        uint256 tokenFromPrice = priceOracle.getAssetPrice(tokenFrom);
        uint256 tokenToPrice = priceOracle.getAssetPrice(tokenTo);
        uint8 tokenFromDecimals = _reserves[tokenFrom].reserveDecimals;
        uint8 tokenToDecimals = _reserves[tokenTo].reserveDecimals;

        _swapOutput = amount
            .mul(tokenFromPrice)
            .mul(10**tokenToDecimals)
            .div(tokenToPrice)
            .div(10**tokenFromDecimals);

        _transferReserveFromSmToken(tokenTo, msg.sender, _swapOutput, true);
        // update onSale at ISmLpToken
        ISmLpToken(smLpTokenMap[lpTokenAddress]).decreasePendingOnSale(
            tokenFrom,
            amount
        );
        require(_swapOutput >= minimumReceive, "Received not much");
    }

    function liquidation(
        address user,
        address tokenToRepay,
        uint256 amountToRepay,
        address collateralToReceive
    ) external {
        uint256 prevHF = getHealthFactor(user);
        require(prevHF < HF_DECIMALS, "User not liquidatable");

        // repay amount to repay for user
        _repay(user, tokenToRepay, amountToRepay);

        // TODO liquidate position

        // check HF improvement
        uint256 postHF = getHealthFactor(user);
        require(postHF > prevHF, "No HF improvement after liquidation");
    }
}
