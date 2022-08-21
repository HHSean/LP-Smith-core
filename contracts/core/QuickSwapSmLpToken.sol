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

// TODO Oliver
contract QuickSwapSmLpToken is ISmLpToken, ERC20, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    string private _name;
    string private _symbol;

    address _pool;

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
        uint256 unrealizedLpToken;
        uint256 initX;
        uint256 initY;
    }

    mapping(address => UserStatus) userStatus;

    constructor(
        string memory name_,
        string memory symbol_,
        address factoryContractAddress,
        address lpTokenContractAddress,
        address strategyContractAddress
    ) ERC20(name_, symbol_) {
        _name = name_;
        _symbol = symbol_;
        FACTORY_CONTRACT_ADDRESS = factoryContractAddress;
        UNDERLYING_ASSET_ADDRESS = lpTokenContractAddress;
        STRATEGY_CONTRACT_ADDRESS = strategyContractAddress;
        tokenX = IUniswapV2Pair(UNDERLYING_ASSET_ADDRESS).token0();
        tokenY = IUniswapV2Pair(UNDERLYING_ASSET_ADDRESS).token1();
    }

    modifier onlyLendingPool() {
        require(msg.sender == address(_pool), "Not called by lending pool");
        _;
    }

    function setLendingPool(address pool_) external onlyOwner {
        _pool = pool_;
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
    ) external onlyLendingPool returns (uint256 _amountX, uint256 _amountY, bool _isFirstDeposit) {
        (_amountX, _amountY) = _beforeMint(amount);

        _isFirstDeposit = userStatus[user].totalLpToken == 0 ? true : false;

        userStatus[user].totalLpToken = userStatus[user].totalLpToken.add(
            amount
        );
        userStatus[user].unrealizedLpToken = userStatus[user]
            .unrealizedLpToken
            .add(amount);
        userStatus[user].initX = userStatus[user].initX.add(_amountX);
        userStatus[user].initY = userStatus[user].initY.add(_amountY);

        totalInitX = totalInitX.add(_amountX);
        totalInitY = totalInitY.add(_amountY);

        _mint(user, amount);
    }

    function burn(
        address user,
        uint256 amount // LP token
    ) external onlyLendingPool returns(bool _isCloseAll){
        // TODO _beforeBurn() mints lp token. Recipient of lp token is smLpToken
        // TODO reduce initX, initY proportionally
        // TODO reduce unrealisedLpToken
        // TODO reduce totalLpToken
        // TODO burn token same qty with amount
        _burn(user, amount);
    }

    function _beforeBurn(uint256 amount)
        internal
        returns (uint256 _amountX, uint256 _amountY)
    {}

    function _addLiquidity(uint256 amountX, uint256 amountY)
        internal
        returns (
            uint256 _amountX,
            uint256,
            _amountY,
            uint256 _liquidity
        )
    {
        require(
            amountX <= IERC20(tokenX).balanceOf(address(this)),
            "Insufficient TokenX"
        );
        require(
            amountY <= IERC20(tokenY).balanceOf(address(this)),
            "Insufficient TokenY"
        );

        IERC20(tokenX).approve(STRATEGY_CONTRACT_ADDRESS, amountX);
        IERC20(tokenY).approve(STRATEGY_CONTRACT_ADDRESS, amountY);

        (_amountX, _amountY, _liquidity) = IStrategy(STRATEGY_CONTRACT_ADDRESS)
            .burn(
                tokenX,
                tokenY,
                LP_TOKEN_CONTRACT_ADDRESS,
                address(this),
                liquidity
            );
    }

    function _removeLiquidity(uint256 liquidity)
        internal
        returns (uint amountX, uint amountY)
    {
        require(
            liquidity <=
                IERC20(LP_TOKEN_CONTRACT_ADDRESS).balanceOf(address(this)),
            "Insufficient Liquidity"
        );

        IERC20(LP_TOKEN_CONTRACT_ADDRESS).approve(
            STRATEGY_CONTRACT_ADDRESS,
            liquidity
        );

        (_amountX, _amountY) = IStrategy(STRATEGY_CONTRACT_ADDRESS).burn(
            tokenX,
            tokenY,
            LP_TOKEN_CONTRACT_ADDRESS,
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

    function getPositionValue(address user) external view {
        // TODO
    }

    function _beforeMint(uint256 liquidity)
        internal
        returns (uint256 _amountX, uint256 _amountY)
    {
        _removeLiquidity(liquidity);

        address lendingPoolAddress = IFactory(FACTORY_CONTRACT_ADDRESS)
            .getLendingPool();

        IERC20(tokenX).transfer(lendingPoolAddress, _amountX);
        IERC20(tokenY).transfer(lendingPoolAddress, _amountY);
    }
}
