import * as hre from "hardhat";

const dotenv = require("dotenv");

dotenv.config();

const FAKE_ACCOUNT_ZERO = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";

const FAKE_ACCOUNT_ONE = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8";

const QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET =
  "0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff";

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

const QUICKSWAP_ETH_USDC_POOL_IN_POLYGON =
  "0x6e7a5fafcec6bb1e78bae2a1f0b612012bf14827";

const USDC = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174";

const USDT = "0xc2132D05D31c914a87C6611C10748AEb04B58e8F";

const WETH = "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619";

const WMATIC = "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270";

const WBTC = "0x1bfd67037b42cf73acf2047067bd4f2c47d9bfd6";

const QUICKSWAP_USDC_USDT_POOL_IN_POLYGON =
  "0x2cf7252e74036d1da831d11089d326296e64a728";

describe("Quick Swap Test", () => {
  before(async () => {
    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [USDC_WHALE_ADDRESS_IN_POLYGON],
    });

    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [USDT_WHALE_ADDRESS_IN_POLYGON],
    });

    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [MATIC_WHALE_ADDRESS_IN_POLYGON],
    });

    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [WETH_WHALE_ADDRESS_IN_POLYGON],
    });
  });
  //
  // it("should be operated addLiquidity Method", async () => {
  //   // given
  //   const QuickSwapStrategy = await hre.ethers.getContractFactory(
  //     "QuickSwapStrategy"
  //   );
  //
  //   const quickSwapStrategy = await QuickSwapStrategy.deploy(
  //     QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET
  //   );
  //
  //   const usdcSigner = await ethers.getSigner(USDC_WHALE_ADDRESS_IN_POLYGON);
  //   const usdtSigner = await ethers.getSigner(USDT_WHALE_ADDRESS_IN_POLYGON);
  //
  //   const usdcContract = await ethers.getContractAt("IERC20", USDC);
  //   const usdTContract = await ethers.getContractAt("IERC20", USDT);
  //
  //   await usdcContract
  //     .connect(usdcSigner)
  //     .transfer(FAKE_ACCOUNT_ZERO, 100 * 10 ** 6);
  //   await usdTContract
  //     .connect(usdtSigner)
  //     .transfer(FAKE_ACCOUNT_ZERO, 100 * 10 ** 6);
  //
  //   await usdcContract.approve(quickSwapStrategy.address, 1000 * 10 ** 6);
  //   await usdTContract.approve(quickSwapStrategy.address, 1000 * 10 ** 6);
  //
  //   // when
  //   const addLiquidityResult = await quickSwapStrategy.mint(
  //     USDT,
  //     USDC,
  //     10 * 10 ** 6,
  //     10 * 10 ** 6,
  //     quickSwapStrategy.address
  //   );
  //
  //   // then
  //   expect(addLiquidityResult).to.not.throws;
  // });
  //
  // it("should be operated removeLiquidity Method", async () => {
  //   // given
  //   const QuickSwapStrategy = await hre.ethers.getContractFactory(
  //     "QuickSwapStrategy"
  //   );
  //
  //   const quickSwapStrategy = await QuickSwapStrategy.deploy(
  //     QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET
  //   );
  //
  //   const usdcSigner = await ethers.getSigner(USDC_WHALE_ADDRESS_IN_POLYGON);
  //   const usdtSigner = await ethers.getSigner(USDT_WHALE_ADDRESS_IN_POLYGON);
  //
  //   const usdcContract = await ethers.getContractAt("IERC20", USDC);
  //   const usdTContract = await ethers.getContractAt("IERC20", USDT);
  //
  //   const lpTokenContract = await ethers.getContractAt(
  //     "IERC20",
  //     QUICKSWAP_USDC_USDT_POOL_IN_POLYGON
  //   );
  //
  //   await usdcContract
  //     .connect(usdcSigner)
  //     .transfer(FAKE_ACCOUNT_ZERO, 1000 * 10 ** 6);
  //   await usdTContract
  //     .connect(usdtSigner)
  //     .transfer(FAKE_ACCOUNT_ZERO, 1000 * 10 ** 6);
  //
  //   await usdcContract.approve(quickSwapStrategy.address, 10000 * 10 ** 6);
  //   await usdTContract.approve(quickSwapStrategy.address, 10000 * 10 ** 6);
  //
  //   // when
  //   const addLiquidityResult = await quickSwapStrategy.mint(
  //     USDT,
  //     USDC,
  //     10 * 10 ** 6,
  //     10 * 10 ** 6,
  //     FAKE_ACCOUNT_ZERO
  //   );
  //
  //   await lpTokenContract.approve(quickSwapStrategy.address, 10000 * 10 ** 6);
  //
  //   const removeLiquidityResult = await quickSwapStrategy.burn(
  //     USDT,
  //     USDC,
  //     QUICKSWAP_USDC_USDT_POOL_IN_POLYGON,
  //     quickSwapStrategy.address,
  //     "100000"
  //   );
  //
  //   // then
  //   expect(addLiquidityResult).to.not.throws;
  //   expect(removeLiquidityResult).to.not.throws;
  // });
  //
  // it("should be calculated Estimated LP Token Amount", async () => {
  //   // given
  //   const QuickSwapStrategy = await hre.ethers.getContractFactory(
  //     "QuickSwapStrategy"
  //   );
  //
  //   const quickSwapStrategy = await QuickSwapStrategy.deploy(
  //     QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET
  //   );
  //
  //   // when
  //   const result = await quickSwapStrategy.getEstimatedLpTokenAmount(
  //     QUICKSWAP_USDC_USDT_POOL_IN_POLYGON,
  //     "10000000",
  //     "10000000"
  //   );
  //
  //   // then
  //   expect(result).to.not.throws;
  // });
  //
  // it("should be operated mintWithETH Method", async () => {
  //   // given
  //   const QuickSwapStrategy = await hre.ethers.getContractFactory(
  //     "QuickSwapStrategy"
  //   );
  //
  //   const quickSwapStrategy = await QuickSwapStrategy.deploy(
  //     QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET
  //   );
  //
  //   const wethSigner = await ethers.getSigner(WETH_WHALE_ADDRESS_IN_POLYGON);
  //
  //   const usdcSigner = await ethers.getSigner(USDC_WHALE_ADDRESS_IN_POLYGON);
  //
  //   const wethContract = await ethers.getContractAt("IERC20", WETH);
  //
  //   const usdcContract = await ethers.getContractAt("IERC20", USDC);
  //
  //   await wethContract
  //     .connect(wethSigner)
  //     .transfer(quickSwapStrategy.address, 10000 * 10 ** 6);
  //
  //   await usdcContract
  //     .connect(usdcSigner)
  //     .transfer(quickSwapStrategy.address, 10000 * 10 ** 6);
  //
  //   await wethContract.approve(quickSwapStrategy.address, 10000 * 10 ** 6);
  //
  //   await usdcContract.approve(quickSwapStrategy.address, 10000 * 10 ** 6);
  //
  //   // when
  //   const addLiquidityResult = await quickSwapStrategy.mintWithETH(
  //     USDC,
  //     10 * 10 ** 6,
  //     0,
  //     0,
  //     quickSwapStrategy.address,
  //     {
  //       value: ethers.BigNumber.from((10 * 10 ** 18).toString()),
  //     }
  //   );
  //
  //   // then
  //   expect(addLiquidityResult).to.not.throws;
  // });
  //
  // it("should be operated removeLiquidityWithETH Method", async () => {
  //   // given
  //   const QuickSwapStrategy = await hre.ethers.getContractFactory(
  //     "QuickSwapStrategy"
  //   );
  //
  //   const quickSwapStrategy = await QuickSwapStrategy.deploy(
  //     QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET
  //   );
  //
  //   const usdcSigner = await ethers.getSigner(USDC_WHALE_ADDRESS_IN_POLYGON);
  //
  //   const usdcContract = await ethers.getContractAt("IERC20", USDC);
  //
  //   const lpTokenContract = await ethers.getContractAt(
  //     "IERC20",
  //     QUICKSWAP_ETH_USDC_POOL_IN_POLYGON
  //   );
  //
  //   await usdcContract
  //     .connect(usdcSigner)
  //     .transfer(quickSwapStrategy.address, 1000 * 10 ** 6);
  //
  //   await usdcContract.approve(quickSwapStrategy.address, 10000 * 10 ** 6);
  //
  //   // when
  //   const addLiquidityResult = await quickSwapStrategy.mintWithETH(
  //     USDC,
  //     10 * 10 ** 6,
  //     0,
  //     0,
  //     FAKE_ACCOUNT_ZERO,
  //     {
  //       value: ethers.BigNumber.from((10 * 10 ** 18).toString()),
  //     }
  //   );
  //
  //   await lpTokenContract.approve(
  //     quickSwapStrategy.address,
  //     10000000 * 10 ** 6
  //   );
  //
  //   const removeLiquidityResult = await quickSwapStrategy.burnWithETH(
  //     USDC,
  //     QUICKSWAP_ETH_USDC_POOL_IN_POLYGON,
  //     "100000",
  //     "100000",
  //     quickSwapStrategy.address,
  //     "3060630597540"
  //   );
  //
  //   // then
  //   expect(addLiquidityResult).to.not.throws;
  //   expect(removeLiquidityResult).to.not.throws;
  // });
  //
  // it("should be not operated If user is not Owner", async () => {
  //   // given
  //   const QuickSwapStrategy = await hre.ethers.getContractFactory(
  //     "QuickSwapStrategy"
  //   );
  //
  //   const quickSwapStrategy = await QuickSwapStrategy.deploy(
  //     QUICK_SWAP_ROUTER_02_ADDRESS_IN_POLYGON_MAINNET
  //   );
  //   const otherSigner = await ethers.getSigner(FAKE_ACCOUNT_ONE);
  //
  //   // when
  //   const notOwnerUserCallSetRouterMethod = await quickSwapStrategy
  //     .connect(otherSigner)
  //     .setRouter(FAKE_ACCOUNT_ONE);
  //
  //   // then
  //   // TODO Chai With Hardhat don't provide Promise Assert.
  //   expect(notOwnerUserCallSetRouterMethod).to.be.throws();
  // });

  it("should be deployed with Setting Token Address and Data Feeds Address", async () => {
    const ChainLinkPriceOracle = await hre.ethers.getContractFactory(
      "ChainLinkPriceOracle"
    );

    const chainLinkPriceOracle = await ChainLinkPriceOracle.deploy();
    await chainLinkPriceOracle.setAssetToPriceFeed(
      WETH,
      "0xF9680D99D6C9589e2a93a78A04A279e509205945"
    );

    await chainLinkPriceOracle.setAssetToPriceFeed(
      USDC,
      "0xfE4A8cc5b5B2366C1B58Bea3858e81843581b2F7"
    );

    await chainLinkPriceOracle.setAssetToPriceFeed(
      WBTC,
      "0xc907E116054Ad103354f2D350FD2514433D57F6f"
    );

    const result = await chainLinkPriceOracle.getLatestPrice(WETH);
    const btc = await chainLinkPriceOracle.getLatestPrice(WBTC);
    const usdc = await chainLinkPriceOracle.getLatestPrice(USDC);
    console.log(result.toNumber());
    console.log(btc.toNumber());
    console.log(usdc.toNumber());
  });
});
