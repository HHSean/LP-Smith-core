pragma solidity ^0.8.9;
import {ISmLpToken} from "./interfaces/ISmLpToken.sol";
import {ILendingPool} from "./interfaces/ILendingPool.sol";
import {IUniswapV2Pair} from "./interfaces/IUniswapV2Pair.sol";
import {IStrategy} from "./interfaces/IStrategy.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// TODO Oliver
contract QuickSwapSmLpToken is ISmLpToken, ERC20, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address _pool;

    address public override LENDING_POOL_CONTRACT_ADDRESS;
    address public override LP_TOKEN_CONTRACT_ADDRESS;
    address public override STRATEGY_CONTRACT_ADDRESS;
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
        address lendingPoolContractAddress,
        address lpTokenContractAddress,
        address strategyContractAddress
    ) {
        _name = name_;
        _symbol = symbol_;
        LENDING_POOL_CONTRACT_ADDRESS = lendingPoolContractAddress;
        LP_TOKEN_CONTRACT_ADDRESS = lpTokenContractAddress;
        STRATEGY_CONTRACT_ADDRESS = strategyContractAddress;
        tokenX = IUniswapV2Pair(LP_TOKEN_CONTRACT_ADDRESS).token0();
        tokenY = IUniswapV2Pair(LP_TOKEN_CONTRACT_ADDRESS).token1();
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
        uint256 amount, // LP token
        uint256 index
    ) external onlyLendingPool returns (uint256 _amountX, uint256 _amountY) {
        require(
            liquidity <
                IERC20(LP_TOKEN_CONTRACT_ADDRESS).balanceOf(address(this)),
            "Insufficient Liquidity"
        );
        (_amountX, _amountY) = _beforeMint(amount);

        userStatus[user].totalLpToken = userStatus[user].totalLpToken.add(
            amount
        );
        userStatus[user].unrealizedLpToken = userStatus[user]
            .unrealizedLpToken
            .add(amount);
        userStatus[user].initX = userStatus[user].initX.add(_amountX);
        userStatus[user].initY = userStatus[user].initY.add(_amountY);
        _mint(user, amount);
    }

    function burn(
        address user,
        address receiverOfUnderlying,
        uint256 amount, // LP token
        uint256 index
    ) external onlyLendingPool {
        // TODO _beforeBurn() mints lp token. Recipient of lp token is smLpToken
        // TODO reduce initX, initY proportionally
        // TODO reduce unrealisedLpToken
        // TODO reduce totalLpToken
        // TODO burn token same qty with amount
        _burn(user, amount);
    }

    function _addLiquidity() returns (uint liquidity) {}

    function _removeLiquidity() returns (uint amountX, uint amountY) {}

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
        override
        returns (uint256 _debt)
    {
        // TODO
    }

    function getPositionValue(address user) external view override {
        // TODO
    }

    function getPotentialOnSale(address asset)
        external
        view
        override
        returns (bool sign, uint256 _potentialOnSale)
    {}

    function getPositionValue(address user) external view override {
        // TODO
    }

    function _beforeMint(uint256 liquidity)
        internal
        returns (uint256 _amountX, uint256 _amountY)
    {
        IERC20(LP_TOKEN_CONTRACT_ADDRESS).transfer(
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

        IERC20(tokenX).transfer(LENDING_POOL_CONTRACT_ADDRESS, _amountX);
        IERC20(tokenY).transfer(LENDING_POOL_CONTRACT_ADDRESS, _amountY);
    }
}
