import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import * as hre from "hardhat";

// Fake Account
const FAKE_ACCOUNT_ZERO = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";

const FAKE_ACCOUNT_ONE = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8";

// Router Address
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

async function deploy() {
  const QuickSwapStrategy = await hre.ethers.getContractFactory(
    "QuickSwapStrategy"
  );

  const quickSwapStrategy = await QuickSwapStrategy.deploy(
    QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET
  );

  await quickSwapStrategy.deployed();
  /*
  const ChainLinkPriceOracle = await hre.ethers.getContractFactory(
    "ChainLinkPriceOracle"
  );

  const chainLinkPriceOracle = await ChainLinkPriceOracle.deploy();

  await chainLinkPriceOracle.deployed();
*/
  const ChainLinkPriceOracle = await hre.ethers.getContractFactory(
    "PriceOracle"
  );

  const chainLinkPriceOracle = await ChainLinkPriceOracle.deploy();

  await chainLinkPriceOracle.deployed();
  await chainLinkPriceOracle.setAssetPrice(
    WETH,
    hre.ethers.utils.parseUnits("1800", 18)
  );
  await chainLinkPriceOracle.setAssetPrice(
    USDC,
    hre.ethers.utils.parseUnits("1", 18)
  );

  const GeneralLogic = await hre.ethers.getContractFactory("GeneralLogic");

  const generalLogic = await GeneralLogic.deploy();

  await generalLogic.deployed();

  const LendingPool = await hre.ethers.getContractFactory("LendingPool", {
    libraries: {
      GeneralLogic: generalLogic.address,
    },
  });

  const lendingPool = await LendingPool.deploy();

  await lendingPool.deployed();

  const Factory = await hre.ethers.getContractFactory("Factory");

  const factory = await Factory.deploy();

  await factory.deployed();
  await factory.setPriceOracle(chainLinkPriceOracle.address);
  await factory.setLendingPool(lendingPool.address);

  const whaleArray = [
    USDC_WHALE_ADDRESS_IN_POLYGON,
    USDT_WHALE_ADDRESS_IN_POLYGON,
    MATIC_WHALE_ADDRESS_IN_POLYGON,
    WETH_WHALE_ADDRESS_IN_POLYGON,
    QUICKSWAP_ETH_USDC_LP_TOKEN_WHALE,
    QUICKSWAP_BTC_USDC_LP_TOKEN_WHALE,
    QUICKSWAP_ETH_BTC_LP_TOKEN_WHALE,
    WBTC_WHALE_ADDRESS_IN_POLYGON,
  ];

  const whaleRequestPromiseAll: any[] = [];

  for (let i = 0; i < whaleArray.length; i++) {
    whaleRequestPromiseAll.push(
      hre.network.provider.request({
        method: "hardhat_impersonateAccount",
        params: [whaleArray[i]],
      })
    );
  }

  await Promise.all(whaleRequestPromiseAll);

  const usdcSigner = await hre.ethers.getSigner(USDC_WHALE_ADDRESS_IN_POLYGON);
  const usdtSigner = await hre.ethers.getSigner(USDT_WHALE_ADDRESS_IN_POLYGON);
  const wethSigner = await hre.ethers.getSigner(WETH_WHALE_ADDRESS_IN_POLYGON);
  const wbtcSigner = await hre.ethers.getSigner(WBTC_WHALE_ADDRESS_IN_POLYGON);

  const ethUsdcLpTokenSigner = await hre.ethers.getSigner(
    QUICKSWAP_ETH_USDC_LP_TOKEN_WHALE
  );
  const btcUsdcLpTokenSigner = await hre.ethers.getSigner(
    QUICKSWAP_BTC_USDC_LP_TOKEN_WHALE
  );
  const ethBtcLpTokenSigner = await hre.ethers.getSigner(
    QUICKSWAP_ETH_BTC_LP_TOKEN_WHALE
  );

  const usdcContract = await hre.ethers.getContractAt("IERC20", USDC);
  const usdtContract = await hre.ethers.getContractAt("IERC20", USDT);
  const wethContract = await hre.ethers.getContractAt("IERC20", WETH);
  const wbtcContract = await hre.ethers.getContractAt("IERC20", WBTC);

  const ethUSDCLpTokenContract = await hre.ethers.getContractAt(
    "IERC20",
    QUICKSWAP_ETH_USDC_POOL_IN_POLYGON
  );
  const btcUsdcLpTokenContract = await hre.ethers.getContractAt(
    "IERC20",
    QUICKSWAP_BTC_USDC_POOL_IN_POLYGON
  );
  const ethBtcLpTokenContract = await hre.ethers.getContractAt(
    "IERC20",
    QUICKSWAP_ETH_BTC_POOL_IN_POLYGON
  );

  console.log("check");
  await ethUSDCLpTokenContract
    .connect(ethUsdcLpTokenSigner)
    .transfer(FAKE_ACCOUNT_ZERO, hre.ethers.utils.parseUnits("1", 12));
  console.log("checkf");
  await btcUsdcLpTokenContract
    .connect(btcUsdcLpTokenSigner)
    .transfer(FAKE_ACCOUNT_ZERO, hre.ethers.utils.parseUnits("10", 6));
  console.log("checkff");
  await ethBtcLpTokenContract
    .connect(ethBtcLpTokenSigner)
    .transfer(FAKE_ACCOUNT_ZERO, hre.ethers.utils.parseUnits("10", 6));
  console.log("checkk");
  await usdcContract
    .connect(usdcSigner)
    .transfer(FAKE_ACCOUNT_ONE, 100000 * 10 ** 6);

  await usdcContract
    .connect(usdcSigner)
    .transfer(FAKE_ACCOUNT_ZERO, 100000 * 10 ** 6);

  await usdcContract
    .connect(usdcSigner)
    .transfer(quickSwapStrategy.address, 100000 * 10 ** 6);

  await wethContract
    .connect(wethSigner)
    .transfer(FAKE_ACCOUNT_ONE, hre.ethers.utils.parseUnits("10", 18));
  await wethContract
    .connect(wethSigner)
    .transfer(FAKE_ACCOUNT_ZERO, hre.ethers.utils.parseUnits("10", 18));
  await wbtcContract.connect(wbtcSigner).transfer(FAKE_ACCOUNT_ONE, 10 ** 8);
  console.log("checkdk");
  await usdtContract
    .connect(usdtSigner)
    .transfer(FAKE_ACCOUNT_ZERO, 100000 * 10 ** 6);

  await wethContract
    .connect(await hre.ethers.getSigner(FAKE_ACCOUNT_ZERO))
    .approve(
      quickSwapStrategy.address,
      hre.ethers.utils.parseUnits("100000", 18)
    );
  await usdcContract
    .connect(await hre.ethers.getSigner(FAKE_ACCOUNT_ZERO))
    .approve(
      quickSwapStrategy.address,
      hre.ethers.utils.parseUnits("100000", 6)
    );
  await usdtContract.approve(quickSwapStrategy.address, 100000 * 10 ** 6);

  console.log("check");
  await quickSwapStrategy.mint(
    WETH,
    USDC,
    hre.ethers.utils.parseUnits("1", 18),
    hre.ethers.utils.parseUnits("100", 6),
    FAKE_ACCOUNT_ZERO
  );
  console.log("check2");
  /*
  const lpTokenContract = await hre.ethers.getContractAt(
    "IERC20",
    QUICKSWAP_ETH_USDC_POOL_IN_POLYGON
  );

  await lpTokenContract.approve(quickSwapStrategy.address, 10000 * 10 ** 6);
*/

  const ethUsdLpTokenContract = await hre.ethers.getContractAt(
    "IERC20",
    QUICKSWAP_ETH_USDC_POOL_IN_POLYGON
  );

  await ethUsdLpTokenContract.approve(
    quickSwapStrategy.address,
    hre.ethers.utils.parseUnits("100000000", 18)
  );

  const TokenDecimal = await hre.ethers.getContractFactory("TokenDecimal");

  const tokenDecimal = await TokenDecimal.deploy();

  await tokenDecimal.deployed();

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
  console.log("address", quickSwapSmLpToken.address);
  await lendingPool.addSmLpToken(
    QUICKSWAP_ETH_USDC_POOL_IN_POLYGON,
    quickSwapSmLpToken.address,
    quickSwapSmLpToken.tokenX(),
    quickSwapSmLpToken.tokenY()
  );
  const ETH_SM_TOKEN = await hre.ethers.getContractFactory("SmToken");

  const USDC_SM_TOKEN = await hre.ethers.getContractFactory("SmToken");

  const ethSmTokenContract = await ETH_SM_TOKEN.deploy(
    "ETHSMToken",
    "smETH",
    WETH,
    factory.address,
    18
  );
  await ethSmTokenContract.deployed();

  const usdcSmTokenContract = await USDC_SM_TOKEN.deploy(
    "USDCSMToken",
    "smUSDC",
    USDC,
    factory.address,
    6
  );

  await usdcSmTokenContract.deployed();

  // TODO
  await lendingPool.addSmToken(ethSmTokenContract.address, WETH, 18);
  await lendingPool.addSmToken(usdcSmTokenContract.address, USDC, 6);

  console.log("배포 완료");
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
  console.log("Deployed SM USDT Token Address: ", ethSmTokenContract.address);
  console.log("Deployed SM USDC Token Address: ", usdcSmTokenContract.address);

  console.log();
  console.log("Account 1 Balance");
  console.log("Public Address: ", "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
  console.log(
    "ETH/USDC LP Token Balance: ",
    (await ethUSDCLpTokenContract.balanceOf(FAKE_ACCOUNT_ZERO)).toNumber()
  );
  console.log(
    "BTC/USDC LP Token Balance: ",
    (await btcUsdcLpTokenContract.balanceOf(FAKE_ACCOUNT_ZERO)).toNumber()
  );
  console.log(
    "ETH/BTC LP Token Balance: ",
    (await ethBtcLpTokenContract.balanceOf(FAKE_ACCOUNT_ZERO)).toNumber()
  );

  console.log();
  console.log("Account 2 Balance");
  console.log("Public Address: ", "0x70997970C51812dc3A010C7d01b50e0d17dc79C8");
  /*
  console.log(
    "WETH Balance: ",
    (await wethContract.balanceOf(FAKE_ACCOUNT_ONE)).toNumber()
  );

  console.log(
    "BTC Balance: ",
    (await wbtcContract.balanceOf(FAKE_ACCOUNT_ONE)).toNumber()
  );

  console.log(
    "USDC Balance: ",
    (await usdcContract.balanceOf(FAKE_ACCOUNT_ONE)).toNumber()
  );*/
  return {
    lendingPool,
  };
}

describe("test", async () => {
  it("temp", async () => {
    const { lendingPool } = await loadFixture(deploy);
    await setTimeout(() => {}, 3000);
    //await lendingPool.
    const res = await lendingPool.getReserveData(FAKE_ACCOUNT_ZERO, WETH);
    console.log(res);
  });
});
