const dotenv = require("dotenv");
import * as hre from "hardhat";
import { ethers } from "hardhat";
import { BigNumber } from "bignumber.js";

dotenv.config();

const accountZero = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";

const QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET =
  "0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff";

const USDC = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174";
const USDT = "0xc2132D05D31c914a87C6611C10748AEb04B58e8F";
const USDC_USDT_LP = "0x2cF7252e74036d1Da831d11089D326296e64a728";

describe("Quick Swap Test", () => {
  it("test", async () => {
    const QuickSwapStrategy = await hre.ethers.getContractFactory(
      "QuickSwapStrategy"
    );
    const contract = await QuickSwapStrategy.deploy(
      QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET
    );
    await contract.deployed();
    await setTimeout(() => {}, 3000);
    const res = await contract.getInputAmountsForLpToken(
      USDC_USDT_LP,
      ethers.utils.parseUnits("1", 18)
    );
    console.log(
      new BigNumber(res._amountA.toString()).toFixed(),
      new BigNumber(res._amountB.toString()).toFixed()
    );
    await setTimeout(() => {}, 3000);
    const res2 = await contract.getEstimatedLpTokenAmount(
      USDC_USDT_LP,
      res._amountA,
      res._amountB
    );
    console.log(new BigNumber(res2.toString()).toFixed());
  });

  it("should be operated addLiquidity Method", async () => {
    const QuickSwapStrategy = await hre.ethers.getContractFactory(
      "QuickSwapStrategy"
    );

    const USDC_WHALE_ADDRESS_IN_POLYGON =
      "0xB60C61DBb7456f024f9338c739B02Be68e3F545C";
    const USDT_WHALE_ADDRESS_IN_POLYGON =
      "0xF977814e90dA44bFA03b6295A0616a897441aceC";

    const quickSwapStrategy = await QuickSwapStrategy.deploy(
      QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET
    );

    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [USDC_WHALE_ADDRESS_IN_POLYGON],
    });

    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [USDT_WHALE_ADDRESS_IN_POLYGON],
    });

    const usdcSigner = await ethers.getSigner(USDC_WHALE_ADDRESS_IN_POLYGON);
    const usdtSigner = await ethers.getSigner(USDT_WHALE_ADDRESS_IN_POLYGON);

    const USDC = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174";
    const USDT = "0xc2132D05D31c914a87C6611C10748AEb04B58e8F";

    const usdcContract = await ethers.getContractAt("IERC20", USDC);
    const usdTContract = await ethers.getContractAt("IERC20", USDT);

    await usdcContract.connect(usdcSigner).transfer(accountZero, 100 * 10 ** 6);
    await usdTContract.connect(usdtSigner).transfer(accountZero, 100 * 10 ** 6);

    await usdcContract.approve(quickSwapStrategy.address, 1000 * 10 ** 6);
    await usdTContract.approve(quickSwapStrategy.address, 1000 * 10 ** 6);

    const addLiquidityResult = await quickSwapStrategy.mint(
      USDT,
      USDC,
      10 * 10 ** 6,
      10 * 10 ** 6,
      quickSwapStrategy.address
    );

    console.log("QuickSwapStrategy deployed to:", quickSwapStrategy.address);

    console.log("addLiquidityResult");
    console.log(addLiquidityResult);
  });

  it("should be operated removeLiquidity Method", async () => {
    const QuickSwapStrategy = await hre.ethers.getContractFactory(
      "QuickSwapStrategy"
    );

    const USDC_WHALE_ADDRESS_IN_POLYGON =
      "0xB60C61DBb7456f024f9338c739B02Be68e3F545C";
    const USDT_WHALE_ADDRESS_IN_POLYGON =
      "0xF977814e90dA44bFA03b6295A0616a897441aceC";

    const quickSwapStrategy = await QuickSwapStrategy.deploy(
      QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET
    );

    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [USDC_WHALE_ADDRESS_IN_POLYGON],
    });

    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [USDT_WHALE_ADDRESS_IN_POLYGON],
    });

    const usdcSigner = await ethers.getSigner(USDC_WHALE_ADDRESS_IN_POLYGON);
    const usdtSigner = await ethers.getSigner(USDT_WHALE_ADDRESS_IN_POLYGON);

    const USDC = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174";
    const USDT = "0xc2132D05D31c914a87C6611C10748AEb04B58e8F";

    const usdcContract = await ethers.getContractAt("IERC20", USDC);
    const usdTContract = await ethers.getContractAt("IERC20", USDT);
    const lpTokenContract = await ethers.getContractAt(
      "IERC20",
      "0x2cf7252e74036d1da831d11089d326296e64a728"
    );

    await usdcContract
      .connect(usdcSigner)
      .transfer(accountZero, 1000 * 10 ** 6);
    await usdTContract
      .connect(usdtSigner)
      .transfer(accountZero, 1000 * 10 ** 6);

    await usdcContract.approve(quickSwapStrategy.address, 10000 * 10 ** 6);
    await usdTContract.approve(quickSwapStrategy.address, 10000 * 10 ** 6);

    const addLiquidityResult = await quickSwapStrategy.mint(
      USDT,
      USDC,
      10 * 10 ** 6,
      10 * 10 ** 6,
      accountZero
    );

    await lpTokenContract.approve(quickSwapStrategy.address, 10000 * 10 ** 6);

    console.log("QuickSwapStrategy deployed to:", quickSwapStrategy.address);

    console.log("addLiquidityResult");
    console.log(addLiquidityResult);
    const removeLiquidityResult = await quickSwapStrategy.burn(
      USDT,
      USDC,
      "0x2cf7252e74036d1da831d11089d326296e64a728",
      quickSwapStrategy.address,
      "100000"
    );

    console.log("removeLiquidityResult");
    console.log(removeLiquidityResult);
  });

  it("should be calculated Estimated LP Token Amount", async () => {
    const QuickSwapStrategy = await hre.ethers.getContractFactory(
      "QuickSwapStrategy"
    );

    const quickSwapStrategy = await QuickSwapStrategy.deploy(
      QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET
    );

    const result = await quickSwapStrategy.getEstimatedLpTokenAmount(
      "0x2cF7252e74036d1Da831d11089D326296e64a728",
      "10000000",
      "10000000"
    );

    console.log("LP Token Amount");
    console.log(result);
  });

  it("should be operated mintWithETH Method", async () => {
    const QuickSwapStrategy = await hre.ethers.getContractFactory(
      "QuickSwapStrategy"
    );

    const MATIC_WHALE_ADDRESS_IN_POLYGON =
      "0x742d35Cc6634C0532925a3b844Bc454e4438f44e";

    const WMATIC_WHALE_ADDRESS_IN_POLYGON =
      "0xB1F7FEd0131FF6d42366A20eE747854444c05C71";

    const WETH_WHALE_ADDRESS_IN_POLYGON =
      "0x72A53cDBBcc1b9efa39c834A540550e23463AAcB";

    const USDC_WHALE_ADDRESS_IN_POLYGON =
      "0xB60C61DBb7456f024f9338c739B02Be68e3F545C";

    const quickSwapStrategy = await QuickSwapStrategy.deploy(
      QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET
    );

    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [MATIC_WHALE_ADDRESS_IN_POLYGON],
    });

    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [WETH_WHALE_ADDRESS_IN_POLYGON],
    });

    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [USDC_WHALE_ADDRESS_IN_POLYGON],
    });

    const wethSigner = await ethers.getSigner(WETH_WHALE_ADDRESS_IN_POLYGON);

    const usdcSigner = await ethers.getSigner(USDC_WHALE_ADDRESS_IN_POLYGON);

    const WETH = "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619";
    const WMATIC = "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270";
    const USDC = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174";

    const wethContract = await ethers.getContractAt("IERC20", WETH);
    const wmaticContract = await ethers.getContractAt("IERC20", WMATIC);
    const usdcContract = await ethers.getContractAt("IERC20", USDC);

    await wethContract
      .connect(wethSigner)
      .transfer(quickSwapStrategy.address, 10000 * 10 ** 6);

    await usdcContract
      .connect(usdcSigner)
      .transfer(quickSwapStrategy.address, 10000 * 10 ** 6);

    await wethContract.approve(quickSwapStrategy.address, 10000 * 10 ** 6);

    await usdcContract.approve(quickSwapStrategy.address, 10000 * 10 ** 6);

    const addLiquidityResult = await quickSwapStrategy.mintWithETH(
      USDC,
      10 * 10 ** 6,
      0,
      0,
      quickSwapStrategy.address,
      {
        value: ethers.BigNumber.from((10 * 10 ** 18).toString()),
      }
    );

    console.log("QuickSwapStrategy deployed to:", quickSwapStrategy.address);

    console.log("addLiquidityResult");
    console.log(addLiquidityResult);
  });

  it("should be operated removeLiquidityWithETH Method", async () => {
    const QuickSwapStrategy = await hre.ethers.getContractFactory(
      "QuickSwapStrategy"
    );

    const USDC_WHALE_ADDRESS_IN_POLYGON =
      "0xB60C61DBb7456f024f9338c739B02Be68e3F545C";

    const quickSwapStrategy = await QuickSwapStrategy.deploy(
      QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET
    );

    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [USDC_WHALE_ADDRESS_IN_POLYGON],
    });

    const usdcSigner = await ethers.getSigner(USDC_WHALE_ADDRESS_IN_POLYGON);

    const USDC = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174";

    const usdcContract = await ethers.getContractAt("IERC20", USDC);
    const lpTokenContract = await ethers.getContractAt(
      "IERC20",
      "0x6e7a5fafcec6bb1e78bae2a1f0b612012bf14827"
    );

    await usdcContract
      .connect(usdcSigner)
      .transfer(quickSwapStrategy.address, 1000 * 10 ** 6);

    await usdcContract.approve(quickSwapStrategy.address, 10000 * 10 ** 6);

    const addLiquidityResult = await quickSwapStrategy.mintWithETH(
      USDC,
      10 * 10 ** 6,
      0,
      0,
      accountZero,
      {
        value: ethers.BigNumber.from((10 * 10 ** 18).toString()),
      }
    );

    await lpTokenContract.approve(
      quickSwapStrategy.address,
      10000000 * 10 ** 6
    );

    console.log("QuickSwapStrategy deployed to:", quickSwapStrategy.address);

    console.log("addLiquidityResult");
    console.log(addLiquidityResult);
    const removeLiquidityResult = await quickSwapStrategy.burnWithETH(
      USDC,
      "0x6e7a5fafcec6bb1e78bae2a1f0b612012bf14827",
      "100000",
      "100000",
      quickSwapStrategy.address,
      "3060630597540"
    );

    console.log("removeLiquidityResult");
    console.log(removeLiquidityResult);
  });

  it("should be operated If user is Owner", async () => {
    const QuickSwapStrategy = await hre.ethers.getContractFactory(
      "QuickSwapStrategy"
    );

    const quickSwapStrategy = await QuickSwapStrategy.deploy(
      QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET
    );
    const otherSigner = await ethers.getSigner(
      "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"
    );

    const notOwnerUserCallSetRouterMethod = await quickSwapStrategy
      .connect(otherSigner)
      .setRouter("0x70997970C51812dc3A010C7d01b50e0d17dc79C8");

    console.log(notOwnerUserCallSetRouterMethod);

    const result = await quickSwapStrategy.owner();

    console.log(result);
  });
});
