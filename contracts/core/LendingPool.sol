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
        _transferReserveToSmToken(tokenX, smLpTokenAddress, amountX, true);

        address tokenY = ISmLpToken(smLpTokenAddress).tokenY();
        _transferReserveToSmToken(tokenY, smLpTokenAddress, amountY, true);
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
        // TODO mint smToken -> debt calculation held inside here (to get smToken exchage rate)
    }

    /**
     * protocol erc20 withdraw
     */
    function withdraw(
        address asset,
        uint256 amount // asset unit (not smToken unit)
    ) external override validWithdrawal returns (uint256) {
        // TODO burn smToken -> debt calculation held inside here (to get smToken exchange rate)
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
        // transfer asset to smToken
        _transferReserveToSmToken(asset, msg.sender, amount, false);
        // update borrowed amount of user
        _userDebtDatas[asset][msg.sender].borrowedAmount -= amount;
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
}
