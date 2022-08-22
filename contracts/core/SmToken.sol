pragma solidity ^0.8.9;
import {ISmToken} from "./interfaces/ISmToken.sol";
import {ILendingPool} from "./interfaces/ILendingPool.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IFactory} from "./interfaces/IFactory.sol";
import {ITokenDecimal} from "./interfaces/ITokenDecimal.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";

// TODO: Noah
contract SmToken is ISmToken, Ownable, ERC20 {
    using SafeMath for uint256;

    string private _name;
    string private _symbol;
    address public override UNDERLYING_ASSET_ADDRESS;
    uint8 underlyingDecimal;
    address public factory;

    constructor(
        string memory name_,
        string memory symbol_,
        address underlyingAsset,
        address factory_,
        uint8 underlyingDecimal_
    ) ERC20(name_, symbol_) {
        _name = name_;
        _symbol = symbol_;
        UNDERLYING_ASSET_ADDRESS = underlyingAsset;
        underlyingDecimal = underlyingDecimal_;
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
        uint256 amountToMint;
        if (totalSupply() == 0) {
            amountToMint = amount.mul(10**18).div(10**underlyingDecimal);
        } else {
            amountToMint = totalSupply().mul(amount).div(liquidityIndex);
        }
        console.log("amountToMint", amountToMint);
        _mint(user, amountToMint);
    }

    function burn(
        address user,
        uint256 amount, // underlying unit
        uint256 liquidityIndex
    ) external onlyLendingPool {
        // burn token with exchange rate
        uint256 amountToBurn = totalSupply().mul(amount).div(liquidityIndex);
        _burn(user, amountToBurn);
    }

    function getUserDepositAmount(address user, uint256 liquidityIndex)
        external
        view
        returns (uint256 _depositAmount)
    {
        if (totalSupply() == 0) {
            _depositAmount = 0;
        } else {
            console.log("liquidity", liquidityIndex);
            _depositAmount = liquidityIndex.mul(balanceOf(user)).div(
                totalSupply()
            );
        }
    }

    function approveLendingPool() public {
        IERC20(UNDERLYING_ASSET_ADDRESS).approve(
            IFactory(factory).getLendingPool(),
            type(uint256).max
        );
    }
}
