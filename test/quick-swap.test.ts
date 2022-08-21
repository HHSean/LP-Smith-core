const dotenv = require("dotenv");
import * as hre from "hardhat";
import { ethers } from "hardhat";
import { BigNumber } from "bignumber.js";

dotenv.config();

const accountZero = "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266";

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
  /*
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

    const addLiquidityResult = await quickSwapStrategy.addLiquidity(
      USDT,
      USDC,
      10 * 10 ** 6,
      10 * 10 ** 6
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

    await usdcContract.connect(usdcSigner).transfer(accountZero, 100 * 10 ** 6);
    await usdTContract.connect(usdtSigner).transfer(accountZero, 100 * 10 ** 6);

    await usdcContract.approve(quickSwapStrategy.address, 1000 * 10 ** 6);
    await usdTContract.approve(quickSwapStrategy.address, 1000 * 10 ** 6);

    const addLiquidityResult = await quickSwapStrategy.addLiquidity(
      USDT,
      USDC,
      10 * 10 ** 6,
      10 * 10 ** 6
    );

    console.log("QuickSwapStrategy deployed to:", quickSwapStrategy.address);

    console.log("addLiquidityResult");
    console.log(addLiquidityResult);
    const removeLiquidityResult = await quickSwapStrategy.removeLiquidity(
      USDT,
      USDC,
      "0x2cf7252e74036d1da831d11089d326296e64a728"
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
  });*/
});
