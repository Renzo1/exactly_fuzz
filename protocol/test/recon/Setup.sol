// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseSetup} from "@chimera/BaseSetup.sol";

import { FixedPointMathLib } from "solmate/src/utils/FixedPointMathLib.sol";
import {Auditor} from "../../contracts/Auditor.sol";
import {WETH} from "solmate/src/tokens/WETH.sol";
import {MockERC20} from "solmate/src/test/utils/mocks/MockERC20.sol";
import {ERC4626} from "solmate/src/mixins/ERC4626.sol";
import {ERC20, RewardsController, ClaimPermit} from "../../contracts/RewardsController.sol";
import {InstallmentsRouter} from "../../contracts/periphery/InstallmentsRouter.sol";
import {PriceFeedDouble} from "../../contracts/PriceFeedDouble.sol";
import {IPriceFeed} from "../../contracts/utils/IPriceFeed.sol";
import {MockPriceFeed} from "../../contracts/mocks/MockPriceFeed.sol";
import {Market} from "../../contracts/Market.sol";
import {MarketETHRouter} from "../../contracts/MarketETHRouter.sol";
import {MockInterestRateModel} from "../../contracts/mocks/MockInterestRateModel.sol";
import {Parameters, InterestRateModel} from "../../contracts/InterestRateModel.sol";
import {PriceFeedPool} from "../../contracts/PriceFeedPool.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {PriceFeedWrapper} from "../../contracts/PriceFeedWrapper.sol";




interface IHevm {
  // Set block.timestamp to newTimestamp
  function warp(uint256 newTimestamp) external;

  // Set block.number to newNumber
  function roll(uint256 newNumber) external;

  // Add the condition b to the assumption base for the current branch
  // This function is almost identical to require
  function assume(bool b) external;

  // Sets the eth balance of usr to amt
  function deal(address usr, uint256 amt) external;

  // Loads a storage slot from an address
  function load(address where, bytes32 slot) external returns (bytes32);

  // Stores a value to an address' storage slot
  function store(address where, bytes32 slot, bytes32 value) external;

  // Signs data (privateKey, digest) => (v, r, s)
  function sign(uint256 privateKey, bytes32 digest) external returns (uint8 v, bytes32 r, bytes32 s);

  // Gets address for a given private key
  function addr(uint256 privateKey) external returns (address addr);

  // Performs a foreign function call via terminal
  function ffi(string[] calldata inputs) external returns (bytes memory result);

  // Performs the next smart contract call with specified `msg.sender`
  function prank(address newSender) external;

  // Creates a new fork with the given endpoint and the latest block and returns the identifier of the fork
  function createFork(string calldata urlOrAlias) external returns (uint256);

  // Takes a fork identifier created by createFork and sets the corresponding forked state as active
  function selectFork(uint256 forkId) external;

  // Returns the identifier of the current fork
  function activeFork() external returns (uint256);

  // Labels the address in traces
  function label(address addr, string calldata label) external;

  /// Sets an address' code.
  function etch(address target, bytes calldata newRuntimeBytecode) external;
}



// slither-disable-end shadowing-local



abstract contract Setup is BaseSetup {
    using FixedPointMathLib for uint256;
    using FixedPointMathLib for uint128;

    IHevm constant hevm = IHevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    
    /// Create Users 
    address internal BOB; // 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf
    address internal ALICE; // 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF
    address internal JAKE; // 0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69
    address internal LISA; // 0x1efF47bc3a10a45D4B230B5d10E37751FE6AA718
    address internal TOM; // 0xe1AB8145F7E55DC933d51a18c793F901A3A0b276


    /// Market Assets
    MockERC20 dai;
    WETH weth;
    
    
    /// Protocol Rewards
    MockERC20 internal opRewardAsset;
    MockERC20 internal exaRewardAsset;
    // MockStETH mockStETH;
    
    // Scope Contracts
    Market marketDAI; // dai market
    Market marketWETH;
    Auditor auditor;
    RewardsController rewardsController;
    InstallmentsRouter installmentsRouter;
    MarketETHRouter marketETHRouter;


    IPriceFeed priceFeed;
    MockPriceFeed internal daiPriceFeed;
    InterestRateModelHarness interestRateModel;
    
    Market[2] internal markets;
    ERC20[] internal rewards;
    address[5] internal users;

    function setup() internal virtual override {
      hevm.warp(0);
      // Create users
      BOB = hevm.addr(0x01); // 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf
      ALICE = hevm.addr(0x02); // 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF
      JAKE = hevm.addr(0x03); // 0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69
      LISA = hevm.addr(0x04); // 0x1efF47bc3a10a45D4B230B5d10E37751FE6AA718
      TOM = hevm.addr(0x05); // 0xe1AB8145F7E55DC933d51a18c793F901A3A0b276
      users[0] = BOB;
      users[1] = ALICE;
      users[2] = JAKE;
      users[3] = LISA;
      users[4] = TOM;

      assert(BOB == 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf);
      assert(ALICE == 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF);
      assert(JAKE == 0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69);
      assert(LISA == 0x1efF47bc3a10a45D4B230B5d10E37751FE6AA718);
      assert(TOM == 0xe1AB8145F7E55DC933d51a18c793F901A3A0b276);
      
      // Market Assets setup
      dai = new MockERC20("DAI", "DAI", 18);
      weth = new WETH();
      // mockStETH = new MockStETH();

      // Reward Assets setup
      opRewardAsset = new MockERC20("OP", "OP", 18);
      exaRewardAsset = new MockERC20("Exa Reward", "EXA", 18);
      rewards = new ERC20[](2);
      rewards[0] = ERC20(address(opRewardAsset));
      rewards[1] = ERC20(address(exaRewardAsset));

      assert(address(rewards[0]) == address(opRewardAsset));
      assert(address(rewards[1]) == address(exaRewardAsset));

      // Auditor setup
      auditor = Auditor(address(new ERC1967Proxy(address(new Auditor(18)), "")));
      auditor.initialize(Auditor.LiquidationIncentive(0.09e18, 0.01e18));
      hevm.label(address(auditor), "Auditor");

      (uint128 liqIncentive, uint128 lendIncentive) = auditor.liquidationIncentive();
      assert(uint256(liqIncentive) == 0.09e18);
      assert(uint256(lendIncentive) == 0.01e18);

      priceFeed = new MockPriceFeed(18, 1e18); // copied from AuditTest
      
      
      // Markets setup
      marketDAI = Market(address(new ERC1967Proxy(address(new Market(dai, auditor)), "")));
      marketDAI.initialize(
        "DAI",
        3,
        1e18,
        InterestRateModel(address(interestRateModel)),
        0.02e18 / uint256(1 days),
        1e17,
        0,
        0.0046e18,
        0.42e18
      );
      hevm.label(address(marketDAI), "MarketDAI");
      daiPriceFeed = new MockPriceFeed(18, 1e18);

      assert (address(marketDAI.interestRateModel()) == address(interestRateModel));
      assert (address(marketDAI.asset()) == address(dai));

      marketWETH = Market(address(new ERC1967Proxy(address(new Market(weth, auditor)), "")));
      marketWETH.initialize(
        "WETH",
        12,
        1e18,
        InterestRateModel(address(interestRateModel)),
        0.02e18 / uint256(1 days),
        1e17,
        0,
        0.0046e18,
        0.42e18
      );
      hevm.label(address(marketWETH), "MarketWETH");

      assert (address(marketWETH.interestRateModel()) == address(interestRateModel));
      assert (address(marketWETH.asset()) == address(weth));

      auditor.enableMarket(marketDAI, daiPriceFeed, 0.8e18);
      auditor.enableMarket(marketWETH, IPriceFeed(auditor.BASE_FEED()), 0.9e18);
      auditor.enterMarket(marketWETH);
      auditor.enterMarket(marketDAI); // experimenting with two ways deposit/borrow here -- test with commented out

      Market[] memory marketList = auditor.allMarkets();
      assert(marketList.length == 2);

      setupActors();
      markets[0] = marketDAI; 
      markets[1] = marketWETH;

      // InterestRateModel setup
      interestRateModel = setupDefaultInterestRateModel();

      assert(interestRateModel.growthSpeed() == 1.1e18);
      assert(interestRateModel.sigmoidSpeed() == 2.5e18);
      assert(interestRateModel.spreadFactor() == 0.2e18);
      assert(interestRateModel.maturitySpeed() == 0.5e18);

      // RewardController setup
      rewardsController = RewardsController(address(new ERC1967Proxy(address(new RewardsController()), "")));
      rewardsController.initialize();
      hevm.label(address(rewardsController), "RewardsController");
      configRewardsController();

      ERC20[] memory  rewardList = rewardsController.allRewards();
      assert(rewardList.length == 2);


      // InstallmentsRouter setup
      installmentsRouter = new InstallmentsRouter(auditor, marketWETH);
      marketDAI.approve(address(installmentsRouter), type(uint256).max);
      marketWETH.approve(address(installmentsRouter), type(uint256).max);
      hevm.deal(address(weth), 2_000_000e18);


      // MarketETHRouter setup
      marketETHRouter = new MarketETHRouter(marketWETH);
    }


    function setupDefaultInterestRateModel() private returns (InterestRateModelHarness){
      return
        new InterestRateModelHarness(
          Parameters({
            minRate: 3.5e16,
            naturalRate: 8e16,
            maxUtilization: 1.3e18,
            naturalUtilization: 0.75e18,
            growthSpeed: 1.1e18,
            sigmoidSpeed: 2.5e18,
            spreadFactor: 0.2e18,
            maturitySpeed: 0.5e18,
            timePreference: 0.01e18,
            fixedAllocation: 0.6e18,
            maxRate: 15_000e16
          }),
          Market(address(0))
        );
    }

    function setupActors() private {
      hevm.label(BOB, "Bob");
      hevm.label(ALICE, "Alice");
      hevm.label(JAKE, "Jake");
      hevm.label(LISA, "Lisa");
      hevm.label(TOM, "Tom");

      dai.mint(BOB, 50_000 ether);
      dai.mint(ALICE, 50_000 ether);
      dai.mint(JAKE, 50_000 ether);
      dai.mint(LISA, 50_000 ether);
      dai.mint(TOM, 50_000 ether);

      // check dai balances of Actors
      assert(dai.balanceOf(BOB) == 50_000 ether);
      assert(dai.balanceOf(ALICE) == 50_000 ether);
      assert(dai.balanceOf(JAKE) == 50_000 ether);
      assert(dai.balanceOf(LISA) == 50_000 ether);
      assert(dai.balanceOf(TOM) == 50_000 ether);

      hevm.deal(BOB, 50_000 ether);
      hevm.deal(ALICE, 50_000 ether);
      hevm.deal(JAKE, 50_000 ether);
      hevm.deal(LISA, 50_000 ether);
      hevm.deal(TOM, 50_000 ether);

      hevm.prank(BOB);   
      weth.deposit{ value: 30_000 ether }(); // 30_000 weth and 20_000 eth
      hevm.prank(ALICE);   
      weth.deposit{ value: 30_000 ether }();
      hevm.prank(JAKE);   
      weth.deposit{ value: 30_000 ether }();
      hevm.prank(LISA);   
      weth.deposit{ value: 30_000 ether }();
      hevm.prank(TOM);   
      weth.deposit{ value: 30_000 ether }();

      // check weth balances of Actors
      assert(weth.balanceOf(BOB) == 30_000 ether);
      assert(weth.balanceOf(ALICE) == 30_000 ether);
      assert(weth.balanceOf(JAKE) == 30_000 ether);
      assert(weth.balanceOf(LISA) == 30_000 ether);
      assert(weth.balanceOf(TOM) == 30_000 ether);

      // check eth balances of Actors
      assert(BOB.balance == 20_000 ether);
      assert(ALICE.balance == 20_000 ether);
      assert(JAKE.balance == 20_000 ether);
      assert(LISA.balance == 20_000 ether);
      assert(TOM.balance == 20_000 ether);


      dai.mint(address(this), 1_000_000 ether);
      hevm.deal(address(this), 2_000_000 ether);
      weth.deposit{ value: 1_000_000 ether }(); // 1_000_000 weth and 1_000_000 eth

      // check eth balances of this contract
      assert(weth.balanceOf(address(this)) == 1_000_000 ether);
      assert(dai.balanceOf(address(this)) == 1_000_000 ether);
      assert(address(this).balance == 1_000_000 ether);

      dai.approve(address(marketDAI), type(uint256).max);
      weth.approve(address(marketWETH), type(uint256).max);

      hevm.prank(BOB);
      dai.approve(address(marketDAI), type(uint256).max);
      hevm.prank(BOB);
      weth.approve(address(marketWETH), type(uint256).max);
      hevm.prank(ALICE);
      dai.approve(address(marketDAI), type(uint256).max);
      hevm.prank(ALICE);
      weth.approve(address(marketWETH), type(uint256).max);
      hevm.prank(JAKE);
      dai.approve(address(marketDAI), type(uint256).max);
      hevm.prank(JAKE);
      weth.approve(address(marketWETH), type(uint256).max);
      hevm.prank(LISA);
      dai.approve(address(marketDAI), type(uint256).max);
      hevm.prank(LISA);
      weth.approve(address(marketWETH), type(uint256).max);
      hevm.prank(TOM);
      dai.approve(address(marketDAI), type(uint256).max);
      hevm.prank(TOM);
      weth.approve(address(marketWETH), type(uint256).max);
    }
  
  function configRewardsController() private {
    RewardsController.Config[] memory configs = new RewardsController.Config[](3);
    configs[0] = RewardsController.Config({
      market: marketDAI,
      reward: opRewardAsset,
      priceFeed: MockPriceFeed(address(0)),
      targetDebt: 20_000e6,
      totalDistribution: 2_000 ether,
      start: uint32(block.timestamp),
      distributionPeriod: 12 weeks,
      undistributedFactor: 0.5e18,
      flipSpeed: 2e18,
      compensationFactor: 0.85e18,
      transitionFactor: 0.64e18,
      borrowAllocationWeightFactor: 0,
      depositAllocationWeightAddend: 0.02e18,
      depositAllocationWeightFactor: 0.01e18
    });
    configs[1] = RewardsController.Config({
      market: marketWETH,
      reward: opRewardAsset,
      priceFeed: IPriceFeed(address(0)),
      targetDebt: 20_000 ether,
      totalDistribution: 2_000 ether,
      start: uint32(block.timestamp),
      distributionPeriod: 12 weeks,
      undistributedFactor: 0.5e18,
      flipSpeed: 2e18,
      compensationFactor: 0.85e18,
      transitionFactor: 0.81e18,
      borrowAllocationWeightFactor: 0,
      depositAllocationWeightAddend: 0.02e18,
      depositAllocationWeightFactor: 0.01e18
    });
    configs[2] = RewardsController.Config({
      market: marketDAI,
      reward: exaRewardAsset,
      priceFeed: IPriceFeed(address(0)),
      targetDebt: 20_000e6,
      totalDistribution: 2_000 ether,
      start: uint32(block.timestamp),
      distributionPeriod: 3 weeks,
      undistributedFactor: 0.5e18,
      flipSpeed: 3e18,
      compensationFactor: 0.4e18,
      transitionFactor: 0.64e18,
      borrowAllocationWeightFactor: 0,
      depositAllocationWeightAddend: 0.025e18,
      depositAllocationWeightFactor: 0.01e18
    });

    rewardsController.config(configs);
    marketDAI.setRewardsController(rewardsController);
    marketWETH.setRewardsController(rewardsController);
    opRewardAsset.mint(address(rewardsController), 4_000 ether);
    exaRewardAsset.mint(address(rewardsController), 4_000 ether);
  }
}

contract InterestRateModelHarness is InterestRateModel {
  // solhint-disable-next-line no-empty-blocks
  constructor(Parameters memory p_, Market market_) InterestRateModel(p_, market_) {}

  function base(uint256 uFloating, uint256 uGlobal) external view returns (uint256) {
    return baseRate(uFloating, uGlobal);
  }
}


// struct FloatingParameters {
//   uint256 minRate;
//   uint256 naturalRate;
//   uint256 maxUtilization;
//   uint256 naturalUtilization;
//   uint256 growthSpeed;
//   uint256 sigmoidSpeed;
//   uint256 maxRate;
// }

// struct Vars {
//   uint256 rate;
//   uint256 refRate;
//   uint256 uFixed;
//   uint256 uFloating;
//   uint256 uGlobal;
//   uint256 backupBorrowed;
//   uint256 backupAmount;
// }
