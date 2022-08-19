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
  const ChainLinkPriceOracle = await hre.ethers.getContractFactory(
    "ChainLinkPriceOracle"
  );

  const priceOracleContract = await ChainLinkPriceOracle.deploy();
  const result = await priceOracleContract.getLatestPrice();
  console.log(result.toNumber());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
