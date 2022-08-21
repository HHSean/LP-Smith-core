pragma solidity ^0.8.9;
import {ISmLpToken} from "./interfaces/ISmLpToken.sol";
import {ILendingPool} from "./interfaces/ILendingPool.sol";
import {IUniswapV2Pair} from "./interfaces/IUniswapV2Pair.sol";
import {IStrategy} from "./interfaces/IStrategy.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IFactory} from "./interfaces/IFactory.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

// TODO Oliver
contract QuickSwapSmLpToken is ISmLpToken, ERC20, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    string private _name;
    string private _symbol;

    uint256 public collateralRate; //bp

    address public override UNDERLYING_ASSET_ADDRESS;
    address public STRATEGY_CONTRACT_ADDRESS;
    address public FACTORY_CONTRACT_ADDRESS;
    address public override tokenX;
    address public override tokenY;

    uint256 public totalInitX;
    uint256 public totalInitY;

    uint256 public onSaleX;
    uint256 public onSaleY;

    struct UserStatus {
        uint256 totalLpToken;
        uint256 realizedLpToken;
        uint256 initX;
        uint256 initY;
    }

    mapping(address => UserStatus) userStatus;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 _collateralRate,
        address factoryContractAddress,
        address lpTokenContractAddress,
        address strategyContractAddress
    ) ERC20(name_, symbol_) {
        _name = name_;
        _symbol = symbol_;
        collateralRate = _collateralRate;
        FACTORY_CONTRACT_ADDRESS = factoryContractAddress;
        UNDERLYING_ASSET_ADDRESS = lpTokenContractAddress;
        STRATEGY_CONTRACT_ADDRESS = strategyContractAddress;
        tokenX = IUniswapV2Pair(UNDERLYING_ASSET_ADDRESS).token0();
        tokenY = IUniswapV2Pair(UNDERLYING_ASSET_ADDRESS).token1();
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

        totalInitX = totalInitX.add(_amountX);
        totalInitY = totalInitY.add(_amountY);

        _mint(user, amount);
    }

    function burn(
        address user,
        uint256 amount // LP token
    ) external onlyLendingPool returns (bool _isCloseAll) {
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
            user,
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

        userStatus[user].totalLpToken = userStatus[user].totalLpToken.sub(
            amount
        );
        userStatus[user].realizedLpToken = _amountToMint == 0
            ? userStatus[user].realizedLpToken.sub(amount)
            : uint(0);
        userStatus[user].initX = userStatus[user].initX.sub(_reducedX);
        userStatus[user].initY = userStatus[user].initY.sub(_reducedY);

        _isCloseAll = userStatus[user].totalLpToken == 0;

        _burn(address(this), amount);
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

    function getDebt(address tokenAddress)
        external
        view
        returns (uint256 _debt)
    {
        // TODO
    }

    function getPotentialOnSale(address asset)
        external
        view
        returns (bool sign, uint256 _potentialOnSale)
    {}

    function getPendingOnSale(address asset)
        external
        view
        override
        returns (bool sign, uint256 _pendingOnSale)
    {}

    function getDepositValue(address user) public view returns (uint256) {
        // TODO
    }

    function getBorrowableValue(address user) public view returns (uint256) {}

    function _beforeMint(uint256 liquidity)
        internal
        returns (uint256 _amountX, uint256 _amountY)
    {
        (_amountX, _amountY) = _removeLiquidity(liquidity);

        address lendingPoolAddress = IFactory(FACTORY_CONTRACT_ADDRESS)
            .getLendingPool();

        IERC20(tokenX).transfer(lendingPoolAddress, _amountX);
        IERC20(tokenY).transfer(lendingPoolAddress, _amountY);
    }
}
