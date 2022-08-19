const dotenv = require("dotenv");
import * as hre from "hardhat";
import { ethers } from "hardhat";

dotenv.config();

const accountZero = "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266";

describe("Quick Swap Test", () => {
  it("should be operated addLiquidity Method", async () => {
    const QuickSwapStrategy = await hre.ethers.getContractFactory(
      "QuickSwapStrategy"
    );

    const USDC_WHALE_ADDRESS_IN_POLYGON =
      "0xB60C61DBb7456f024f9338c739B02Be68e3F545C";
    const USDT_WHALE_ADDRESS_IN_POLYGON =
      "0xF977814e90dA44bFA03b6295A0616a897441aceC";

    const quickSwapStrategy = await QuickSwapStrategy.deploy();

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

    const quickSwapStrategy = await QuickSwapStrategy.deploy();

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
});
