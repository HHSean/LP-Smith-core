pragma solidity ^0.8.9;
import {ISmLpToken} from "./interfaces/ISmLpToken.sol";
import {ILendingPool} from "./interfaces/ILendingPool.sol";
import {IUniswapV2Pair} from "./interfaces/IUniswapV2Pair.sol";
import {IStrategy} from "./interfaces/IStrategy.sol";
import {IPriceOracle} from "./interfaces/IPriceOracle.sol";
import {ITokenDecimal} from "./interfaces/ITokenDecimal.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IFactory} from "./interfaces/IFactory.sol";
import {UnsignedCalc} from "./libraries/UnsignedCalc.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "hardhat/console.sol";

// TODO Oliver
contract QuickSwapSmLpToken is ISmLpToken, ERC20, Ownable {
    using SafeMath for uint256;
    using SafeMath for uint112;
    using SafeERC20 for IERC20;

    string private _name;
    string private _symbol;

    uint256 public collateralRate; //bp

    address public override UNDERLYING_ASSET_ADDRESS;
    address public STRATEGY_CONTRACT_ADDRESS;
    address public FACTORY_CONTRACT_ADDRESS;
    address public TOKEN_DECIMAL_CONTRACT_ADDRESS;
    address public override tokenX;
    address public override tokenY;
    uint256 tokenXDecimal;
    uint256 tokenYDecimal;

    uint256 public pendingOnSaleX;
    uint256 public pendingOnSaleY;

    struct UserStatus {
        uint256 totalLpToken;
        uint256 realizedLpToken;
        uint256 initX;
        uint256 initY;
    }

    mapping(address => UserStatus) userStatus;
    UserStatus public totalStatus;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 _collateralRate,
        address factoryContractAddress,
        address lpTokenContractAddress,
        address strategyContractAddress,
        address tokenDecimalContractAddress
    ) ERC20(name_, symbol_) {
        _name = name_;
        _symbol = symbol_;
        collateralRate = _collateralRate;
        FACTORY_CONTRACT_ADDRESS = factoryContractAddress;
        UNDERLYING_ASSET_ADDRESS = lpTokenContractAddress;
        STRATEGY_CONTRACT_ADDRESS = strategyContractAddress;
        TOKEN_DECIMAL_CONTRACT_ADDRESS = tokenDecimalContractAddress;

        tokenX = IUniswapV2Pair(UNDERLYING_ASSET_ADDRESS).token0();
        tokenY = IUniswapV2Pair(UNDERLYING_ASSET_ADDRESS).token1();
        tokenXDecimal = ITokenDecimal(TOKEN_DECIMAL_CONTRACT_ADDRESS)
            .getDecimal(tokenX);
        tokenYDecimal = ITokenDecimal(TOKEN_DECIMAL_CONTRACT_ADDRESS)
            .getDecimal(tokenY);
    }

    modifier onlyLendingPool() {
        require(
            msg.sender ==
                address(IFactory(FACTORY_CONTRACT_ADDRESS).getLendingPool()),
            "Not called by lending pool"
        );
        _;
    }

    //Backlog
    /*
    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(to, amount);
    }*/

    /*
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        _transfer(to, amount);
        _approve(
            from,
            msg.sender,
            allowance[from][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        emit Transfer(from, to, amount);
        return true;
    }*/

    //Backlog: should apply user status for recipient
    function _transfer(address to, uint256 amount) internal returns (bool) {
        // TODO validate the aTokens between two users. Validate the transfer
        // TODO if health factor is still good after the transfer, it's allowed to transfer
    }

    function mint(
        address user,
        uint256 amount // LP token
    )
        external
        onlyLendingPool
        returns (
            uint256 _amountX,
            uint256 _amountY,
            bool _isFirstDeposit
        )
    {
        (_amountX, _amountY) = _beforeMint(amount);

        _isFirstDeposit = userStatus[user].totalLpToken == 0 ? true : false;

        userStatus[user].totalLpToken = userStatus[user].totalLpToken.add(
            amount
        );
        userStatus[user].initX = userStatus[user].initX.add(_amountX);
        userStatus[user].initY = userStatus[user].initY.add(_amountY);

        totalStatus.totalLpToken = totalStatus.totalLpToken.add(amount);
        totalStatus.initX = totalStatus.initX.add(_amountX);
        totalStatus.initY = totalStatus.initY.add(_amountY);

        _mint(user, amount);
    }

    function burn(
        address user,
        address recipient,
        uint256 amount // LP token
    ) public onlyLendingPool returns (bool _isCloseAll) {
        require(amount <= balanceOf(address(this)), "Insufficient smLpToken");

        uint256 _amountToMint = amount > userStatus[user].realizedLpToken
            ? amount.sub(userStatus[user].realizedLpToken)
            : uint256(0);

        (
            uint256 _amountX,
            uint256 _amountY,
            uint256 _mintedAmount
        ) = _amountToMint == 0
                ? (uint256(0), uint256(0), uint256(0))
                : _addLiquidity(_amountToMint);

        IERC20(UNDERLYING_ASSET_ADDRESS).transfer(
            recipient,
            Math.min(userStatus[user].realizedLpToken, amount).add(
                _mintedAmount
            )
        );

        uint256 _reducedX = userStatus[user].initX.mul(amount).div(
            userStatus[user].totalLpToken
        );
        uint256 _reducedY = userStatus[user].initY.mul(amount).div(
            userStatus[user].totalLpToken
        );

        if (_amountX < _reducedX) {
            pendingOnSaleX = pendingOnSaleX.add(_reducedX.sub(_amountX));
        }
        if (_amountY < _reducedY) {
            pendingOnSaleY = pendingOnSaleY.add(_reducedY.sub(_amountY));
        }

        userStatus[user].totalLpToken = userStatus[user].totalLpToken.sub(
            amount
        );

        uint256 prevRealizedLpToken = userStatus[user].realizedLpToken;

        userStatus[user].realizedLpToken = _amountToMint == 0
            ? userStatus[user].realizedLpToken.sub(amount)
            : uint(0);
        userStatus[user].initX = userStatus[user].initX.sub(_reducedX);
        userStatus[user].initY = userStatus[user].initY.sub(_reducedY);

        totalStatus.initX = totalStatus.initX.sub(_reducedX);
        totalStatus.initY = totalStatus.initY.sub(_reducedY);
        totalStatus.totalLpToken = totalStatus.totalLpToken.sub(amount);
        totalStatus.realizedLpToken = totalStatus.realizedLpToken.sub(
            prevRealizedLpToken.sub(userStatus[user].realizedLpToken)
        );

        _isCloseAll = userStatus[user].totalLpToken == 0;

        _burn(address(this), amount);
    }

    function liquidate(
        address liquidator,
        address user,
        uint256 repaidValue
    ) external onlyLendingPool returns (uint256 _returnAmount) {
        (, , uint256 lpPrice) = _getDebt();
        _returnAmount = repaidValue.mul(10500).div(10000).div(lpPrice).mul(
            10**18
        );
        require(
            userStatus[user].totalLpToken >= _returnAmount,
            "Insufficient Collateral"
        );
        burn(user, liquidator, _returnAmount);
    }

    function realizeLp(
        address user,
        uint256 amount // LP token
    ) external onlyLendingPool {
        require(
            amount <=
                userStatus[user].totalLpToken.sub(
                    userStatus[user].realizedLpToken
                ),
            "Exceed Amount"
        );

        uint256 _amountX;
        uint256 _amountY;
        (_amountX, _amountY, amount) = _addLiquidity(amount);

        uint256 _reducedX = userStatus[user].initX.mul(amount).div(
            userStatus[user].totalLpToken
        );
        uint256 _reducedY = userStatus[user].initY.mul(amount).div(
            userStatus[user].totalLpToken
        );

        if (_amountX < _reducedX) {
            pendingOnSaleX = pendingOnSaleX.add(_reducedX.sub(_amountX));
        }
        if (_amountY < _reducedY) {
            pendingOnSaleY = pendingOnSaleY.add(_reducedY.sub(_amountY));
        }

        userStatus[user].realizedLpToken = userStatus[user].realizedLpToken.add(
            amount
        );
        userStatus[user].initX = userStatus[user].initX.sub(_reducedX);
        userStatus[user].initY = userStatus[user].initY.sub(_reducedY);

        totalStatus.initX = totalStatus.initX.sub(_reducedX);
        totalStatus.initY = totalStatus.initY.sub(_reducedY);
        totalStatus.realizedLpToken = totalStatus.realizedLpToken.add(amount);
    }

    function _addLiquidity(uint256 liquidity)
        internal
        returns (
            uint256 _amountX,
            uint256 _amountY,
            uint256 _liquidity
        )
    {
        (uint256 amountX, uint256 amountY) = IStrategy(
            STRATEGY_CONTRACT_ADDRESS
        ).getInputAmountsForLpToken(UNDERLYING_ASSET_ADDRESS, liquidity);

        ILendingPool(IFactory(FACTORY_CONTRACT_ADDRESS).getLendingPool())
            .requestFund(tokenX, amountX);
        ILendingPool(IFactory(FACTORY_CONTRACT_ADDRESS).getLendingPool())
            .requestFund(tokenY, amountY);

        IERC20(tokenX).approve(STRATEGY_CONTRACT_ADDRESS, amountX);
        IERC20(tokenY).approve(STRATEGY_CONTRACT_ADDRESS, amountY);

        (_amountX, _amountY, _liquidity) = IStrategy(STRATEGY_CONTRACT_ADDRESS)
            .mint(tokenX, tokenY, amountX, amountY, address(this));
    }

    function _removeLiquidity(uint256 liquidity)
        internal
        returns (uint _amountX, uint _amountY)
    {
        require(
            liquidity <=
                IERC20(UNDERLYING_ASSET_ADDRESS).balanceOf(address(this)),
            "Insufficient Liquidity"
        );

        IERC20(UNDERLYING_ASSET_ADDRESS).approve(
            STRATEGY_CONTRACT_ADDRESS,
            liquidity
        );

        (_amountX, _amountY) = IStrategy(STRATEGY_CONTRACT_ADDRESS).burn(
            tokenX,
            tokenY,
            UNDERLYING_ASSET_ADDRESS,
            address(this),
            liquidity
        );
    }

    // Not needed, this contract doesn't have assets
    /*
    function transferOnLiquidation(
        address from,
        address to,
        uint256 value
    ) external {
        // TODO
    }
    function transferUnderlyingTo(address user, uint256 amount)
        external
        returns (uint256)
    {
        // TODO
    }
    */

    function getDebt(address tokenAddress) public view returns (uint256 _debt) {
        require(
            tokenAddress == tokenX || tokenAddress == tokenY,
            "Invalid Token Address"
        );
        if (tokenAddress == tokenX) {
            (_debt, , ) = _getDebt();
        } else {
            (, _debt, ) = _getDebt();
        }
    }

    function _getDebt()
        internal
        view
        returns (
            uint256 _debtTokenX,
            uint256 _debtTokenY,
            uint256 _usdcValuePerLp
        )
    {
        (uint112 _reserve0, uint112 _reserve1, ) = IUniswapV2Pair(
            UNDERLYING_ASSET_ADDRESS
        ).getReserves();

        IPriceOracle _priceOracle = IPriceOracle(
            IFactory(FACTORY_CONTRACT_ADDRESS).getPriceOracle()
        );

        uint256 _totalSupply = IUniswapV2Pair(UNDERLYING_ASSET_ADDRESS)
            .totalSupply();
 
        uint256 _usdcPriceX = _priceOracle.getAssetPrice(tokenX);
        uint256 _usdcPriceY = _priceOracle.getAssetPrice(tokenY);

        uint256 liquidity = Math.sqrt(_reserve0.mul(_reserve1));

        uint256 _virtualX;
        uint256 _virtualY;

        if (tokenXDecimal > tokenYDecimal) {
            uint256 _multiplier = Math.sqrt(
                10**(tokenXDecimal.sub(tokenYDecimal))
            );
            _virtualX = liquidity
                .mul(Math.sqrt(_usdcPriceY.div(_usdcPriceX)))
                .mul(_multiplier);
            _virtualY = liquidity
                .mul(Math.sqrt(_usdcPriceX.div(_usdcPriceY)))
                .div(_multiplier);
        } else {
            uint256 _multiplier = Math.sqrt(
                10**(tokenYDecimal.sub(tokenXDecimal))
            );
            _virtualX = liquidity
                .mul(Math.sqrt(_usdcPriceY.div(_usdcPriceX)))
                .div(_multiplier);
            _virtualY = liquidity
                .mul(Math.sqrt(_usdcPriceX.div(_usdcPriceY)))
                .mul(_multiplier);
        }

        _debtTokenX = _virtualX
            .mul(totalStatus.totalLpToken.sub(totalStatus.realizedLpToken))
            .div(_totalSupply);
        _debtTokenY = _virtualY
            .mul(totalStatus.totalLpToken.sub(totalStatus.realizedLpToken))
            .div(_totalSupply);
        _usdcValuePerLp = liquidity
            .mul(2)
            .mul(Math.sqrt(_usdcPriceX.mul(_usdcPriceY)))
            .mul(10**18)
            .div(_totalSupply)
            .div(Math.sqrt(10**(tokenXDecimal.add(tokenYDecimal))));
    }

    function getPotentialOnSale(address asset)
        public
        view
        returns (bool _isPositive, uint256 _potentialOnSale)
    {
        require(asset == tokenX || asset == tokenY, "Invalid Token Address");
        uint256 debt;
        uint256 pairDebt;
        uint256 initDebt;
        uint256 initPairDebt;
        uint256 assetPrice;
        uint256 pairPrice;
        if (asset == tokenX) {
            (debt, pairDebt, ) = _getDebt();
            initDebt = totalStatus.initX;
            initPairDebt = totalStatus.initY;
            assetPrice = IPriceOracle(
                IFactory(FACTORY_CONTRACT_ADDRESS).getPriceOracle()
            ).getAssetPrice(tokenX);
            pairPrice = IPriceOracle(
                IFactory(FACTORY_CONTRACT_ADDRESS).getPriceOracle()
            ).getAssetPrice(tokenY);
        } else {
            (pairDebt, debt, ) = _getDebt();
            initDebt = totalStatus.initY;
            initPairDebt = totalStatus.initX;
            assetPrice = IPriceOracle(
                IFactory(FACTORY_CONTRACT_ADDRESS).getPriceOracle()
            ).getAssetPrice(tokenY);
            pairPrice = IPriceOracle(
                IFactory(FACTORY_CONTRACT_ADDRESS).getPriceOracle()
            ).getAssetPrice(tokenX);
        }

        if (initDebt > debt) {
            _isPositive = false;
            _potentialOnSale = initDebt.sub(debt);
        } else {
            _isPositive = true;
            if (tokenX == asset) {
                _potentialOnSale = initPairDebt
                    .sub(pairDebt)
                    .mul(pairPrice)
                    .div(assetPrice)
                    .mul(10**tokenXDecimal)
                    .div(10**tokenYDecimal);
            } else {
                _potentialOnSale = initPairDebt
                    .sub(pairDebt)
                    .mul(pairPrice)
                    .div(assetPrice)
                    .mul(10**tokenYDecimal)
                    .div(10**tokenXDecimal);
            }
        }
    }

    function getPendingOnSale(address asset)
        public
        view
        returns (bool _isPositive, uint256 _pendingOnSale)
    {
        uint256 tokenXPrice = IPriceOracle(
            IFactory(FACTORY_CONTRACT_ADDRESS).getPriceOracle()
        ).getAssetPrice(tokenX);
        uint256 tokenYPrice = IPriceOracle(
            IFactory(FACTORY_CONTRACT_ADDRESS).getPriceOracle()
        ).getAssetPrice(tokenY);

        require(asset == tokenX || asset == tokenY, "Invalid Token Address");
        if (asset == tokenX) {
            _isPositive =
                pendingOnSaleY.mul(tokenYPrice).mul(10**tokenXDecimal) >
                pendingOnSaleX.mul(tokenXPrice).mul(10**tokenYDecimal);
            if (_isPositive) {
                _pendingOnSale = (
                    (pendingOnSaleY.mul(tokenYPrice).mul(10**tokenXDecimal))
                        .sub(
                            pendingOnSaleX.mul(tokenXPrice).mul(
                                10**tokenYDecimal
                            )
                        )
                ).div(tokenXPrice).div(10**tokenYDecimal);
            } else {
                _pendingOnSale = (
                    (pendingOnSaleX.mul(tokenXPrice).mul(10**tokenYDecimal))
                        .sub(
                            (
                                pendingOnSaleY.mul(tokenYPrice).mul(
                                    10**tokenXDecimal
                                )
                            )
                        )
                ).div(tokenXPrice).div(10**tokenYDecimal);
            }
        } else {
            _isPositive =
                pendingOnSaleY.mul(tokenYPrice).mul(10**tokenXDecimal) <
                pendingOnSaleX.mul(tokenXPrice).mul(10**tokenYDecimal);
            if (_isPositive) {
                _pendingOnSale = (
                    (pendingOnSaleX.mul(tokenXPrice).mul(10**tokenYDecimal))
                        .sub(
                            pendingOnSaleY.mul(tokenYPrice).mul(
                                10**tokenXDecimal
                            )
                        )
                ).div(tokenYPrice).div(10**tokenXDecimal);
            } else {
                _pendingOnSale = (
                    (pendingOnSaleY.mul(tokenYPrice).mul(10**tokenXDecimal))
                        .sub(
                            (
                                pendingOnSaleX.mul(tokenXPrice).mul(
                                    10**tokenYDecimal
                                )
                            )
                        )
                ).div(tokenYPrice).div(10**tokenXDecimal);
            }
        }
    }

    function decreasePendingOnSale(address asset, uint256 saledAmount)
        public
        onlyLendingPool
    {
        require(asset == tokenX || asset == tokenY, "Invalid Token Address");
        if (asset == tokenX) {
            pendingOnSaleX = pendingOnSaleX.sub(saledAmount);
        } else {
            pendingOnSaleY = pendingOnSaleY.sub(saledAmount);
        }
    }

    function getDepositValue(address user) public view returns (uint256) {
        (, , uint256 lpPrice) = _getDebt();
        return userStatus[user].totalLpToken.mul(lpPrice).div(10**18);
    }

    function getBorrowableValue(address user) public view returns (uint256) {
        return getDepositValue(user).mul(collateralRate).div(10000);
    }

    function _beforeMint(uint256 liquidity)
        internal
        returns (uint256 _amountX, uint256 _amountY)
    {
        (_amountX, _amountY) = _removeLiquidity(liquidity);

        address lendingPoolAddress = IFactory(FACTORY_CONTRACT_ADDRESS)
            .getLendingPool();

        IERC20(tokenX).approve(lendingPoolAddress, _amountX);
        IERC20(tokenY).approve(lendingPoolAddress, _amountY);
    }

    function getLpTokenData(address user)
        external
        view
        returns (
            uint256 _totalDeposit,
            uint _userDeposit,
            uint256 _totalValue,
            uint256 _userValue
        )
    {
        _totalDeposit = totalStatus.totalLpToken;
        _userDeposit = userStatus[user].totalLpToken;
        (, , uint256 lpPrice) = _getDebt();
        _totalValue = _totalDeposit.mul(lpPrice);
        _userValue = _userDeposit.mul(lpPrice);
    }
}
