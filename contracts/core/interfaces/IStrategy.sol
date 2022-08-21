// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IStrategy {
    event Log(string message, uint val);

    function mint(
        address _tokenA,
        address _tokenB,
        uint _amountADesired,
        uint _amountBDesired,
        address recipient
    )
        external
        returns (
            uint amountA,
            uint amountB,
            uint liquidity
        );

    function burn(
        address _tokenA,
        address _tokenB,
        address liquidityToken,
        address recipient,
        uint liquidity
    ) external returns (uint amountA, uint amountB);

    function setRouter(address _newRouterAddress) external;
}
