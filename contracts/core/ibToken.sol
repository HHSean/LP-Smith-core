pragma solidity ^0.8.9;
import "./interfaces/IibToken.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ibToken is IibToken {
    using SafeERC20 for IERC20;
}
