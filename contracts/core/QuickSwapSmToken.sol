pragma solidity ^0.8.9;
import {ISmLpToken} from "./interfaces/ISmLpToken.sol";
import {ILendingPool} from "./interfaces/ILendingPool.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract QuickSwapSmToken is ISmLpToken, IERC20, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    string private _name;
    string private _symbol;
    address _pool;
    address public override LP_TOKEN_CONTRACT_ADDRESS;

    uint256 public override totalSupply;
    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    constructor(
        string memory name_,
        string memory symbol_,
        address lpTokenContractAddress
    ) {
        _name = name_;
        _symbol = symbol_;
        LP_TOKEN_CONTRACT_ADDRESS = lpTokenContractAddress;
    }

    modifier onlyLendingPool() {
        require(msg.sender == address(_pool), "Not called by lending pool");
        _;
    }

    function setLendingPool(address pool_) external onlyOwner {
        _pool = pool_;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(to, amount);
    }

    function _transfer(address to, uint256 amount) internal returns (bool) {
        // TODO validate the aTokens between two users. Validate the transfer
        // TODO if health factor is still good after the transfer, it's allowed to transfer
    }

    function approve(
        address owner,
        address spender,
        uint256 amount
    ) external returns (bool) {
        _approve(owner, spender, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal returns (bool) {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

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
    }

    function mint(
        address user,
        uint256 amount,
        uint256 index
    ) external onlyLendingPool returns (bool) {
        // TODO mint token with exchange rate
    }

    function burn(
        address user,
        address receiverOfUnderlying,
        uint256 amount,
        uint256 index
    ) external onlyLendingPool {
        // TODO burn token with exchange rate
    }

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

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {}

    function debt(address tokenAddress) external view override {
        // TODO
    }

    function getPositionValue(address user) external view override {
        // TODO
    }
}
