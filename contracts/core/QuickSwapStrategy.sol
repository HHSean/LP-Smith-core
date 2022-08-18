// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IUniswapV2Router02.sol";

contract QuickSwapStrategy {

    address public QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;

    IUniswapV2Router02 uniswapV2Router02 = IUniswapV2Router02(QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET);

    event Log(string message, uint val);

    function addLiquidity(
        address _tokenA,
        address _tokenB,
        uint _amountADesired,
        uint _amountBDesired
    ) external returns (uint amountA, uint amountB, uint liquidity) {

        IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountADesired);
        IERC20(_tokenB).transferFrom(msg.sender, address(this), _amountBDesired);

        IERC20(_tokenA).approve(QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET, _amountADesired);
        IERC20(_tokenB).approve(QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET, _amountBDesired);

        (uint _amountA, uint _amountB, uint _liquidity) =
            uniswapV2Router02.addLiquidity(
                _tokenA,
                _tokenB,
                _amountADesired,
                _amountBDesired,
                1,
                1,
                address(this),
                block.timestamp
            );

        amountA = _amountA;
        amountB = _amountB;
        liquidity = _liquidity;

        emit Log("amountA", amountA);
        emit Log("amountB", amountB);
        emit Log("liquidity", liquidity);
    }

    function removeLiquidity(address _tokenA, address _tokenB, address liquidityToken) external {

        uint liquidity = IERC20(liquidityToken).balanceOf(address(this));

        IERC20(liquidityToken).approve(QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET, liquidity);

        (uint amountA, uint amountB) =
        IUniswapV2Router02(uniswapV2Router02).removeLiquidity(
            _tokenA,
            _tokenB,
            liquidity,
            1,
            1,
            address(this),
            block.timestamp
        );

        emit Log("amountA", amountA);
        emit Log("amountB", amountB);
    }
}
