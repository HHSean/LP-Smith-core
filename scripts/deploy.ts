import * as hre from "hardhat";

const QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET =
  "0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff";

// ERC20 Token Whale Address

const USDC_WHALE_ADDRESS_IN_POLYGON =
  "0xB60C61DBb7456f024f9338c739B02Be68e3F545C";

const USDT_WHALE_ADDRESS_IN_POLYGON =
  "0xF977814e90dA44bFA03b6295A0616a897441aceC";

const MATIC_WHALE_ADDRESS_IN_POLYGON =
  "0x742d35Cc6634C0532925a3b844Bc454e4438f44e";

const WMATIC_WHALE_ADDRESS_IN_POLYGON =
  "0xB1F7FEd0131FF6d42366A20eE747854444c05C71";

const WETH_WHALE_ADDRESS_IN_POLYGON =
  "0x72A53cDBBcc1b9efa39c834A540550e23463AAcB";

const WBTC_WHALE_ADDRESS_IN_POLYGON =
  "0xb3d5368E933373eAEB5bd4b17bFbA1fE84a1B119";

// LP Token Whale Address

const QUICKSWAP_ETH_USDC_LP_TOKEN_WHALE =
  "0x625d6E3F15c8C42a04D342d18937c6167f71e521";

const QUICKSWAP_BTC_USDC_LP_TOKEN_WHALE =
  "0x2f3B5C897f69c69F0C76421b7c68a76E036C0b8f";

const QUICKSWAP_ETH_BTC_LP_TOKEN_WHALE =
  "0xDC36fcb1497dd6E0Ea23d22Ce942B433cfAF0660";

// LP Token Address

const QUICKSWAP_ETH_USDC_POOL_IN_POLYGON =
  "0x853Ee4b2A13f8a742d64C8F088bE7bA2131f670d";

const QUICKSWAP_BTC_USDC_POOL_IN_POLYGON =
  "0xf6a637525402643b0654a54bead2cb9a83c8b498";

const QUICKSWAP_ETH_BTC_POOL_IN_POLYGON =
  "0xdc9232e2df177d7a12fdff6ecbab114e2231198d";

// ERC20 Token Address

const USDC = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174";

const USDT = "0xc2132D05D31c914a87C6611C10748AEb04B58e8F";

const WETH = "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619";

const WMATIC = "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270";

const WBTC = "0x1bfd67037b42cf73acf2047067bd4f2c47d9bfd6";

const QUICKSWAP_USDC_USDT_POOL_IN_POLYGON =
  "0x2cf7252e74036d1da831d11089d326296e64a728";

const delay = async (ms: number) => {
  return new Promise((resolve) => setTimeout(resolve, ms));
};

async function deploy() {
  const QuickSwapStrategy = await hre.ethers.getContractFactory(
    "QuickSwapStrategy"
  );
  const quickSwapStrategy = await QuickSwapStrategy.deploy(
    QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET
  );
  await quickSwapStrategy.deployed();
  await delay(3000);

  const ChainLinkPriceOracle = await hre.ethers.getContractFactory(
    "PriceOracle"
  );
  const chainLinkPriceOracle = await ChainLinkPriceOracle.deploy();
  await chainLinkPriceOracle.deployed();
  await delay(3000);

  await chainLinkPriceOracle.setAssetToPriceFeed(
    WETH,
    "0xF9680D99D6C9589e2a93a78A04A279e509205945"
  );
  await delay(3000);

  await chainLinkPriceOracle.setAssetToPriceFeed(
    USDC,
    "0xfE4A8cc5b5B2366C1B58Bea3858e81843581b2F7"
  );
  await delay(3000);

  const GeneralLogic = await hre.ethers.getContractFactory("GeneralLogic");
  const generalLogic = await GeneralLogic.deploy();
  await generalLogic.deployed();
  await delay(3000);

  const Factory = await hre.ethers.getContractFactory("Factory");
  const factory = await Factory.deploy();
  await factory.deployed();
  await delay(3000);

  const LendingPool = await hre.ethers.getContractFactory("LendingPool", {
    libraries: {
      GeneralLogic: generalLogic.address,
    },
  });
  const lendingPool = await LendingPool.deploy(factory.address);
  await lendingPool.deployed();
  await delay(3000);

  await factory.setPriceOracle(chainLinkPriceOracle.address);
  await delay(3000);

  await factory.setLendingPool(lendingPool.address);
  await delay(3000);

  const wethContract = await hre.ethers.getContractAt("IERC20", WETH);

  const ethUSDCLpTokenContract = await hre.ethers.getContractAt(
    "IERC20",
    QUICKSWAP_ETH_USDC_POOL_IN_POLYGON
  );

  const TokenDecimal = await hre.ethers.getContractFactory("TokenDecimal");
  const tokenDecimal = await TokenDecimal.deploy();
  await tokenDecimal.deployed();
  await delay(3000);

  const QuickSwapSmLpToken = await hre.ethers.getContractFactory(
    "QuickSwapSmLpToken"
  );
  const quickSwapSmLpToken = await QuickSwapSmLpToken.deploy(
    "ETH_USDC_POOL",
    "smQuickSwapETHUSDC",
    7000,
    factory.address,
    QUICKSWAP_ETH_USDC_POOL_IN_POLYGON,
    quickSwapStrategy.address,
    tokenDecimal.address
  );
  await quickSwapSmLpToken.deployed();
  await delay(3000);
  
  await lendingPool.addSmLpToken(
    QUICKSWAP_ETH_USDC_POOL_IN_POLYGON,
    quickSwapSmLpToken.address,
    quickSwapSmLpToken.tokenX(),
    quickSwapSmLpToken.tokenY()
  );
  await delay(3000);

  console.log("checkpoint");
  const ETH_SM_TOKEN = await hre.ethers.getContractFactory("SmToken");
  const USDC_SM_TOKEN = await hre.ethers.getContractFactory("SmToken");

  const ethSmTokenContract = await ETH_SM_TOKEN.deploy(
    "ETHSMToken",
    "smETH",
    WETH,
    factory.address,
    18
  );
  await delay(3000);
  await ethSmTokenContract.deployed();
  await delay(3000);

  const usdcSmTokenContract = await USDC_SM_TOKEN.deploy(
    "USDCSMToken",
    "smUSDC",
    USDC,
    factory.address,
    6
  );
  await delay(3000);
  await usdcSmTokenContract.deployed();
  await delay(3000);

  // TODO
  await lendingPool.addSmToken(ethSmTokenContract.address, WETH, 18);
  await delay(3000);
  await lendingPool.addSmToken(usdcSmTokenContract.address, USDC, 6);
  await delay(3000);

  await ethSmTokenContract.approveLendingPool();
  await delay(3000);
  await usdcSmTokenContract.approveLendingPool();
  await delay(3000);

  console.log("Deployed Factory Address: ", factory.address);
  console.log(
    "Deployed Chainlink Price Oracle Address: ",
    chainLinkPriceOracle.address
  );
  console.log("Deployed Lending Pool Address: ", lendingPool.address);
  console.log(
    "Deployed ETH/USDC QuickSwapSmLpToken Contract Address: ",
    quickSwapSmLpToken.address
  );
  console.log("Deployed SM ETH Token Address: ", ethSmTokenContract.address);
  console.log("Deployed SM USDC Token Address: ", usdcSmTokenContract.address);

  return {
    lendingPool,
    wethContract,
    ethUSDCLpTokenContract,
  };
}

deploy()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
