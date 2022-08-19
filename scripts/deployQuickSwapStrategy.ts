import { ethers } from "hardhat";

const hre = require("hardhat");

// const me = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";

const Web3 = require("web3");
const dotenv = require("dotenv");

dotenv.config();

const web3 = new Web3(process.env.ALCHEMY_POLYGON_PROVIDER_URL);
web3.eth.accounts.wallet.add(
  "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
);

const me = web3.eth.accounts.wallet[0];

const approveAmount = web3.utils.toBN(1000000000000000000);

async function main() {
  const QuickSwapStrategy = await hre.ethers.getContractFactory(
    "QuickSwapStrategy"
  );

  const DAI_WHALE = "0xd6b26861139a52877Cd7adc437Edd7c5383fF585";
  const USDC_WHALE = "0xB60C61DBb7456f024f9338c739B02Be68e3F545C";
  const USDT_WHALE = "0xF977814e90dA44bFA03b6295A0616a897441aceC";

  const quickSwapStrategy = await QuickSwapStrategy.deploy();

  const contract = await quickSwapStrategy.deployed();

  await hre.network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [USDC_WHALE],
  });

  await hre.network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [USDT_WHALE],
  });

  const usdcSigner = await ethers.getSigner(USDC_WHALE);
  const usdTSigner = await ethers.getSigner(USDT_WHALE);

  const USDC = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174";
  const USDT = "0xc2132D05D31c914a87C6611C10748AEb04B58e8F";

  const usdcContract = await ethers.getContractAt("IERC20", USDC);
  const usdTContract = await ethers.getContractAt("IERC20", USDT);

  const balance = await usdcContract.balanceOf(me.address);

  await usdcContract.connect(usdcSigner).transfer(me.address, 100 * 10 ** 6);
  await usdTContract.connect(usdTSigner).transfer(me.address, 100 * 10 ** 6);

  const afterBalance = await usdcContract.balanceOf(me.address);

  await usdcContract.approve(quickSwapStrategy.address, 1000 * 10 ** 6);
  await usdTContract.approve(quickSwapStrategy.address, 1000 * 10 ** 6);

  const result = await contract.addLiquidity(
    USDT,
    USDC,
    10 * 10 ** 6,
    10 * 10 ** 6
  );

  console.log("result");
  console.log(result);

  console.log("QuickSwapStrategy deployed to:", quickSwapStrategy.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
