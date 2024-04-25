
// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Setup} from "./Setup.sol";

abstract contract BeforeAfter is Setup {

//     struct Vars {
//         // Auditor
//         uint256 auditor_accountMarkets;
//         uint256 auditor_checkLiquidation;
//         address auditor_marketList;

//         // Market
//         uint256 market_balanceOf;
//         uint256 market_earningsAccumulator;
//         uint256 market_fixedPoolBorrowed;
//         uint256 market_floatingAssets;
//         uint256 market_floatingAssetsAverage;
//         uint256 market_floatingBackupBorrowed;
//         uint256 market_floatingDebt;
//         uint32 market_lastAccumulatorAccrual;
//         uint32 market_lastAverageUpdate;
//         uint32 market_lastFloatingDebtUpdate;
//         uint256 market_previewBorrow;
//         uint256 market_previewDebt;
//         uint256 market_previewDeposit;
//         uint256 market_previewFloatingAssetsAverage;
//         uint256 market_previewMint;
//         uint256 market_previewRedeem;
//         uint256 market_previewRefund;
//         uint256 market_previewRepay;
//         uint256 market_previewWithdraw;
//         uint256 market_totalAssets;
//         uint256 market_totalFloatingBorrowAssets;
//         uint256 market_totalFloatingBorrowShares;
//         uint256 market_totalSupply;

//         // RewardsController
//         uint256 rewardsController_allClaimable;
//         tuple[] rewardsController_allMarketsOperations;
//         address[] rewardsController_allRewards;
//         uint256 rewardsController_availableRewardsCount;
//         uint256 rewardsController_claimable;
//         address rewardsController_marketList;
//         uint256 rewardsController_nonces;
//         tuple rewardsController_rewardConfig;
//         bool rewardsController_rewardEnabled;
//         address rewardsController_rewardList;

//         // EscrowedEXA
//         uint256 escrowedEXA_balanceOf;
//         uint48 escrowedEXA_clock;
//         uint256 escrowedEXA_reserves;
//         uint256 escrowedEXA_totalSupply;
//     }

//     Vars internal _before;
//     Vars internal _after;

//     function __before() internal {
//         _before.auditor_accountMarkets = auditor.accountMarkets();
//         _before.auditor_checkLiquidation = auditor.checkLiquidation();
//         _before.auditor_marketList = auditor.marketList();

//         _before.market_balanceOf = marketDAI.balanceOf();
//         _before.market_earningsAccumulator = marketDAI.earningsAccumulator();
//         _before.market_fixedPoolBorrowed = marketDAI.fixedPoolBorrowed();
//         _before.market_floatingAssets = marketDAI.floatingAssets();
//         _before.market_floatingAssetsAverage = marketDAI.floatingAssetsAverage();
//         _before.market_floatingBackupBorrowed = marketDAI.floatingBackupBorrowed();
//         _before.market_floatingDebt = marketDAI.floatingDebt();
//         _before.market_lastAccumulatorAccrual = marketDAI.lastAccumulatorAccrual();
//         _before.market_lastAverageUpdate = marketDAI.lastAverageUpdate();
//         _before.market_lastFloatingDebtUpdate = marketDAI.lastFloatingDebtUpdate();
//         _before.market_previewBorrow = marketDAI.previewBorrow();
//         _before.market_previewDebt = marketDAI.previewDebt();
//         _before.market_previewDeposit = marketDAI.previewDeposit();
//         _before.market_previewFloatingAssetsAverage = marketDAI.previewFloatingAssetsAverage();
//         _before.market_previewMint = marketDAI.previewMint();
//         _before.market_previewRedeem = marketDAI.previewRedeem();
//         _before.market_previewRefund = marketDAI.previewRefund();
//         _before.market_previewRepay = marketDAI.previewRepay();
//         _before.market_previewWithdraw = marketDAI.previewWithdraw();
//         _before.market_totalAssets = marketDAI.totalAssets();
//         _before.market_totalFloatingBorrowAssets = marketDAI.totalFloatingBorrowAssets();
//         _before.market_totalFloatingBorrowShares = marketDAI.totalFloatingBorrowShares();
//         _before.market_totalSupply = marketDAI.totalSupply();

//         _before.rewardsController_allClaimable = rewardsController.allClaimable();
//         _before.rewardsController_allMarketsOperations = rewardsController.allMarketsOperations();
//         _before.rewardsController_allRewards = rewardsController.allRewards();
//         _before.rewardsController_availableRewardsCount = rewardsController.availableRewardsCount();
//         _before.rewardsController_claimable = rewardsController.claimable();
//         _before.rewardsController_marketList = rewardsController.marketList();
//         _before.rewardsController_nonces = rewardsController.nonces();
//         _before.rewardsController_rewardConfig = rewardsController.rewardConfig();
//         _before.rewardsController_rewardEnabled = rewardsController.rewardEnabled();
//         _before.rewardsController_rewardList = rewardsController.rewardList();

//         _before.escrowedEXA_balanceOf = escrowedEXA.balanceOf();
//         _before.escrowedEXA_clock = escrowedEXA.clock();
//         _before.escrowedEXA_reserves = escrowedEXA.reserves();
//         _before.escrowedEXA_totalSupply = escrowedEXA.totalSupply();
//     }

//     function __after() internal {
//         _after.auditor_accountMarkets = auditor.accountMarkets();
//         _after.auditor_checkLiquidation = auditor.checkLiquidation();
//         _after.auditor_marketList = auditor.marketList();

//         _after.market_balanceOf = marketDAI.balanceOf();
//         _after.market_earningsAccumulator = marketDAI.earningsAccumulator();
//         _after.market_fixedPoolBorrowed = marketDAI.fixedPoolBorrowed();
//         _after.market_floatingAssets = marketDAI.floatingAssets();
//         _after.market_floatingAssetsAverage = marketDAI.floatingAssetsAverage();
//         _after.market_floatingBackupBorrowed = marketDAI.floatingBackupBorrowed();
//         _after.market_floatingDebt = marketDAI.floatingDebt();
//         _after.market_lastAccumulatorAccrual = marketDAI.lastAccumulatorAccrual();
//         _after.market_lastAverageUpdate = marketDAI.lastAverageUpdate();
//         _after.market_lastFloatingDebtUpdate = marketDAI.lastFloatingDebtUpdate();
//         _after.market_previewBorrow = marketDAI.previewBorrow();
//         _after.market_previewDebt = marketDAI.previewDebt();
//         _after.market_previewDeposit = marketDAI.previewDeposit();
//         _after.market_previewFloatingAssetsAverage = marketDAI.previewFloatingAssetsAverage();
//         _after.market_previewMint = marketDAI.previewMint();
//         _after.market_previewRedeem = marketDAI.previewRedeem();
//         _after.market_previewRefund = marketDAI.previewRefund();
//         _after.market_previewRepay = marketDAI.previewRepay();
//         _after.market_previewWithdraw = marketDAI.previewWithdraw();
//         _after.market_totalAssets = marketDAI.totalAssets();
//         _after.market_totalFloatingBorrowAssets = marketDAI.totalFloatingBorrowAssets();
//         _after.market_totalFloatingBorrowShares = marketDAI.totalFloatingBorrowShares();
//         _after.market_totalSupply = marketDAI.totalSupply();

//         _after.rewardsController_allClaimable = rewardsController.allClaimable();
//         _after.rewardsController_allMarketsOperations = rewardsController.allMarketsOperations();
//         _after.rewardsController_allRewards = rewardsController.allRewards();
//         _after.rewardsController_availableRewardsCount = rewardsController.availableRewardsCount();
//         _after.rewardsController_claimable = rewardsController.claimable();
//         _after.rewardsController_marketList = rewardsController.marketList();
//         _after.rewardsController_nonces = rewardsController.nonces();
//         _after.rewardsController_rewardConfig = rewardsController.rewardConfig();
//         _after.rewardsController_rewardEnabled = rewardsController.rewardEnabled();
//         _after.rewardsController_rewardList = rewardsController.rewardList();

//         _after.escrowedEXA_balanceOf = escrowedEXA.balanceOf();
//         _after.escrowedEXA_clock = escrowedEXA.clock();
//         _after.escrowedEXA_reserves = escrowedEXA.reserves();
//         _after.escrowedEXA_totalSupply = escrowedEXA.totalSupply();
//     }
}
