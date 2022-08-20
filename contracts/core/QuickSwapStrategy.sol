// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IStrategy.sol";
import "./interfaces/IUniswapV2Pair.sol";
import './libraries/Math.sol';
import "./libraries/SafeMath.sol";

// TODO Evan
// TODO: need to use modifier
contract QuickSwapStrategy is IStrategy, Ownable {
    using SafeMath  for uint;

    address public QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET;

    IUniswapV2Router02 uniswapV2Router02;

    uint public constant MINIMUM_LIQUIDITY = 10**3;

    constructor(address _QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET) {
        QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET = _QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET;
        uniswapV2Router02 = IUniswapV2Router02(
            QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET
        );
    }

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
        )
    {
        IERC20(_tokenA).transferFrom(
            msg.sender,
            address(this),
            _amountADesired
        );
        IERC20(_tokenB).transferFrom(
            msg.sender,
            address(this),
            _amountBDesired
        );

        IERC20(_tokenA).approve(
            QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET,
            _amountADesired
        );
        IERC20(_tokenB).approve(
            QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET,
            _amountBDesired
        );

        (amountA, amountB, liquidity) = uniswapV2Router02.addLiquidity(
            _tokenA,
            _tokenB,
            _amountADesired,
            _amountBDesired,
            1,
            1,
            recipient,
            block.timestamp
        );

        emit Log("amountA", amountA);
        emit Log("amountB", amountB);
        emit Log("liquidity", liquidity);
    }

    function burn(
        address _tokenA,
        address _tokenB,
        address liquidityToken,
        address recipient
        uint liquidity
    ) external returns (uint amountA, uint amountB) {
        require(liquidity < IERC20(liquidityToken).balanceOf(address(this)), "Insufficient Liquidity");

        IERC20(liquidityToken).approve(
            QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET,
            liquidity
        );

        (amountA, amountB) = IUniswapV2Router02(uniswapV2Router02)
            .removeLiquidity(
                _tokenA,
                _tokenB,
                liquidity,
                1,
                1,
                recipient,
                block.timestamp
            );

        emit Log("amountA", amountA);
        emit Log("amountB", amountB);
    }

    //TODO: add functions for add/remove liquidity with ETH

    function setRouter(address _newRouterAddress) public onlyOwner {
        QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET = _newRouterAddress;
    }

    function getEstimatedLpTokenAmount(address _liquidityToken, uint _amountADesired, uint _amountBDesired) public view returns(uint liquidity) {
        uint liquidityTokenTotalSupply = IUniswapV2Pair(_liquidityToken).totalSupply();
        (uint112 _reserve0, uint112 _reserve1,) = IUniswapV2Pair(_liquidityToken).getReserves();
        if (liquidityTokenTotalSupply == 0) {
            liquidity = Math.sqrt(_amountADesired.mul(_amountBDesired)).sub(MINIMUM_LIQUIDITY);
        } else {
            liquidity = Math.min(_amountADesired.mul(liquidityTokenTotalSupply) / _reserve0, _amountBDesired.mul(liquidityTokenTotalSupply) / _reserve1);
        }
        require(liquidity > 0, 'UniswapV2: INSUFFICIENT_LIQUIDITY_MINTED');
    }
}
