import { ethers } from "hardhat";
import Web3 from "web3";

const hre = require("hardhat");
const dotenv = require("dotenv");

dotenv.config();

const web3 = new Web3(process.env.ALCHEMY_POLYGON_PROVIDER_URL!!);

const accountZeroPrivateKey =
  process.env.FORKING_NETWORK_ACCOUNT_ZERO_PRIVATE_KEY!!;

web3.eth.accounts.wallet.add(accountZeroPrivateKey);

const accountZero = web3.eth.accounts.wallet[0];

async function main() {
  const QuickSwapStrategy = await hre.ethers.getContractFactory(
    "QuickSwapStrategy"
  );

  const USDC_WHALE_ADDRESS_IN_POLYGON =
    "0xB60C61DBb7456f024f9338c739B02Be68e3F545C";
  const USDT_WHALE_ADDRESS_IN_POLYGON =
    "0xF977814e90dA44bFA03b6295A0616a897441aceC";

  const quickSwapStrategy = await QuickSwapStrategy.deploy(
    "0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff"
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

  await usdcContract
    .connect(usdcSigner)
    .transfer(accountZero.address, 100 * 10 ** 6);
  await usdTContract
    .connect(usdtSigner)
    .transfer(accountZero.address, 100 * 10 ** 6);

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
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
