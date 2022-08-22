import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-deploy";

require("dotenv").config();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    hardhat: {
      chainId: 137,
      forking: {
        url: `${process.env.ALCHEMY_POLYGON_PROVIDER_URL!}`,
      },
      accounts: [
        {
          privateKey: process.env.ACCXOUNT_ZERO_PRIVATE_KEY!,
          balance: "1000000000000000000000",
        },
        {
          privateKey: process.env.ACCXOUNT_ONE_PRIVATE_KEY!,
          balance: "1000000000000000000000",
        },
      ],
      allowUnlimitedContractSize: true,
    },
    mumbai: {
      url: `${process.env.POLYGON_MUMBAI_NODE_URL}`,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY!],
      allowUnlimitedContractSize: true,
    },
    polygon: {
      url: `${process.env.POLYGON_MAINNET_NODE_URL}`,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY!],
      allowUnlimitedContractSize: true,
    },
  },
};

export default config;
