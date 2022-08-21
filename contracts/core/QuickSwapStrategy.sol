// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IStrategy.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

// TODO Evan
// TODO: need to use modifier
contract QuickSwapStrategy is IStrategy, Ownable {
    using SafeMath for uint256;

    address public QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET;

    IUniswapV2Router02 uniswapV2Router02;

    uint256 public constant MINIMUM_LIQUIDITY = 10**3;

    constructor(address _QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET) {
        QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET = _QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET;
        uniswapV2Router02 = IUniswapV2Router02(
            QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET
        );
    }

    function mint(
        address _tokenA,
        address _tokenB,
        uint256 _amountADesired,
        uint256 _amountBDesired,
        address recipient
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        )
    {
        require(
            _amountADesired <= IERC20(_tokenA).balanceOf(msg.sender),
            "Insufficient TokenX"
        );
        require(
            _amountBDesired <= IERC20(_tokenB).balanceOf(msg.sender),
            "Insufficient TokenY"
        );

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

    function mintWithETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to
    )
        public
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        )
    {
        IERC20(token).approve(
            QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET,
            amountTokenDesired
        );

        (amountToken, amountETH, liquidity) = uniswapV2Router02.addLiquidityETH{
            value: msg.value
        }(
            token,
            amountTokenDesired,
            amountTokenMin,
            amountETHMin,
            to,
            block.timestamp
        );
    }

    function burn(
        address _tokenA,
        address _tokenB,
        address _liquidityToken,
        address _recipient,
        uint256 _liquidity
    ) external returns (uint256 amountA, uint256 amountB) {
        require(
            _liquidity <= IERC20(_liquidityToken).balanceOf(msg.sender),
            "Insufficient Liquidity"
        );

        IERC20(_liquidityToken).transferFrom(
            msg.sender,
            address(this),
            _liquidity
        );

        IERC20(_liquidityToken).approve(
            QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET,
            _liquidity
        );

        (amountA, amountB) = IUniswapV2Router02(uniswapV2Router02)
            .removeLiquidity(
                _tokenA,
                _tokenB,
                _liquidity,
                1,
                1,
                _recipient,
                block.timestamp
            );

        emit Log("amountA", amountA);
        emit Log("amountB", amountB);
    }

    function burnWithETH(
        address _token,
        address _liquidityToken,
        uint256 _amountTokenMin,
        uint256 _amountETHMin,
        address _recipient,
        uint256 _liquidity
    ) external returns (uint256 amountToken, uint256 amountETH) {
        require(
            _liquidity <= IERC20(_liquidityToken).balanceOf(msg.sender),
            "Insufficient Liquidity"
        );

        IERC20(_liquidityToken).transferFrom(
            msg.sender,
            address(this),
            _liquidity
        );

        IERC20(_liquidityToken).approve(
            QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET,
            _liquidity
        );

        (amountToken, amountETH) = IUniswapV2Router02(uniswapV2Router02)
            .removeLiquidityETH(
                _token,
                _liquidity,
                1,
                1,
                _recipient,
                block.timestamp
            );
    }

    //TODO: add functions for add/remove liquidity with ETH

    function setRouter(address _newRouterAddress) public onlyOwner {
        QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET = _newRouterAddress;
    }

    function getEstimatedLpTokenAmount(
        address _liquidityToken,
        uint256 _amountADesired,
        uint256 _amountBDesired
    ) public view returns (uint256 liquidity) {
        uint256 liquidityTokenTotalSupply = IUniswapV2Pair(_liquidityToken)
            .totalSupply();
        (uint112 _reserve0, uint112 _reserve1, ) = IUniswapV2Pair(
            _liquidityToken
        ).getReserves();
        if (liquidityTokenTotalSupply == 0) {
            liquidity = Math.sqrt(_amountADesired.mul(_amountBDesired)).sub(
                MINIMUM_LIQUIDITY
            );
        } else {
            liquidity = Math.min(
                _amountADesired.mul(liquidityTokenTotalSupply) / _reserve0,
                _amountBDesired.mul(liquidityTokenTotalSupply) / _reserve1
            );
        }
        require(liquidity > 0, "UniswapV2: INSUFFICIENT_LIQUIDITY_MINTED");
    }

    function getInputAmountsForLpToken(
        address lpTokenAddress,
        uint256 outputAmount
    ) public view returns (uint256 _amountA, uint256 _amountB) {
        uint256 liquidityTokenTotalSupply = IUniswapV2Pair(lpTokenAddress)
            .totalSupply();
        (uint112 _reserve0, uint112 _reserve1, ) = IUniswapV2Pair(
            lpTokenAddress
        ).getReserves();

        _amountA = outputAmount.mul(_reserve0).div(liquidityTokenTotalSupply);
        _amountB = outputAmount.mul(_reserve1).div(liquidityTokenTotalSupply);
    }

    receive() external payable {}
}
