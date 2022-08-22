pragma solidity ^0.8.9;
import {ISmToken} from "./interfaces/ISmToken.sol";
import {ILendingPool} from "./interfaces/ILendingPool.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IFactory} from "./interfaces/IFactory.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// TODO: Noah
contract SmToken is ISmToken, Ownable, ERC20 {
    using SafeMath for uint256;

    string private _name;
    string private _symbol;
    address public override UNDERLYING_ASSET_ADDRESS;
    address public factory;

    constructor(
        string memory name_,
        string memory symbol_,
        address underlyingAsset,
        address factory_
    ) ERC20(name_, symbol_) {
        _name = name_;
        _symbol = symbol_;
        UNDERLYING_ASSET_ADDRESS = underlyingAsset;
        factory = factory_;
    }

    modifier onlyLendingPool() {
        require(
            msg.sender == IFactory(factory).getLendingPool(),
            "Not called by lending pool"
        );
        _;
    }

    function mint(
        address user,
        uint256 amount, // underlying unit
        uint256 liquidityIndex
    ) external onlyLendingPool {
        // mint token with exchange rate
        uint256 amountToMint = totalSupply().mul(amount).div(liquidityIndex);
        _mint(user, amountToMint);
    }

    function burn(
        address user,
        uint256 amount, // underlying unit
        uint256 liquidityIndex
    ) external onlyLendingPool {
        // burn token with exchange rate
        uint256 amountToBurn = totalSupply().mul(amount).div(liquidityIndex);
        _mint(user, amountToBurn);
    }

    function getUserDepositAmount(address user, uint256 liquidityIndex)
        external
        view
        returns (uint256 _depositAmount)
    {
        _depositAmount = liquidityIndex.mul(balanceOf(user)).div(totalSupply());
    }
}
