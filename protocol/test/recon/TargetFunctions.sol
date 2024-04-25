
// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "./BeforeAfter.sol";
import {Properties} from "./Properties.sol";
import {vm} from "@chimera/Hevm.sol";

import {Market} from "../../contracts/Market.sol";
import {ERC20, RewardsController, ClaimPermit} from "../../contracts/RewardsController.sol";

abstract contract TargetFunctions is BaseTargetFunctions, Properties, BeforeAfter {
    /////////////////////////////////////////////////
    //////////////  Utility functions ///////////////
    /////////////////////////////////////////////////
    function mockPriceFeed_setDaiPrice(int256 price_) public {
      daiPriceFeed.setPrice(price_);
    }

    function OnehoursPassed() public {
      vm.warp(block.timestamp + 3600);
    }

    function OneDayPassed() public {
      vm.warp(block.timestamp + 86400);
    }

    function OneWeekPassed() public {
      vm.warp(block.timestamp + 86400 * 7);
    }

    //////////////////////////////////////////////////////////
    ////////////// Auditor's Wrapper Functions ///////////////
    //////////////////////////////////////////////////////////

    function auditor_checkBorrow(address market, address borrower) public {
      auditor.checkBorrow(Market(market), borrower);
    }

    function auditor_enterMarket(address market) public {
      auditor.enterMarket(Market(market));
    }

    function auditor_exitMarket(address market) public {
      auditor.exitMarket(Market(market));
    }

    function auditor_handleBadDebt(address account) public {
      auditor.handleBadDebt(account);
    }

    //////////////////////////////////////////////////////////
    ///////////// DAI Market's Wrapper Functions /////////////
    //////////////////////////////////////////////////////////
    function market_approve(address spender, uint256 amount) public {
      marketDAI.approve(spender, amount);
    }

    function market_borrow(uint256 assets, address receiver, address borrower) public {
      marketDAI.borrow(assets, receiver, borrower);
    }

    function market_borrowAtMaturity(uint256 maturity, uint256 assets, uint256 maxAssets, address receiver, address borrower) public {
      marketDAI.borrowAtMaturity(maturity, assets, maxAssets, receiver, borrower);
    }


    function market_deposit(uint256 assets, address receiver) public {
      marketDAI.deposit(assets, receiver);
    }

    function market_depositAtMaturity(uint256 maturity, uint256 assets, uint256 minAssetsRequired, address receiver) public {
      marketDAI.depositAtMaturity(maturity, assets, minAssetsRequired, receiver);
    }

    function market_liquidate(address borrower, uint256 maxAssets, address seizeMarket) public {
      marketDAI.liquidate(borrower, maxAssets, Market(seizeMarket));
    }

    function market_mint(uint256 shares, address receiver) public {
      marketDAI.mint(shares, receiver);
    }

    function market_permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
      marketDAI.permit(owner, spender, value, deadline, v, r, s);
    }

    function market_redeem(uint256 shares, address receiver, address owner) public {
      marketDAI.redeem(shares, receiver, owner);
    }

    function market_refund(uint256 borrowShares, address borrower) public {
      marketDAI.refund(borrowShares, borrower);
    }


    function market_repay(uint256 assets, address borrower) public {
      marketDAI.repay(assets, borrower);
    }

    function market_repayAtMaturity(uint256 maturity, uint256 positionAssets, uint256 maxAssets, address borrower) public {
      marketDAI.repayAtMaturity(maturity, positionAssets, maxAssets, borrower);
    }

    function market_transfer(address to, uint256 shares) public {
      marketDAI.transfer(to, shares);
    }

    function market_transferFrom(address from, address to, uint256 shares) public {
      marketDAI.transferFrom(from, to, shares);
    }

    function market_withdraw(uint256 assets, address receiver, address owner) public {
      marketDAI.withdraw(assets, receiver, owner);
    }

    function market_withdrawAtMaturity(uint256 maturity, uint256 positionAssets, uint256 minAssetsRequired, address receiver, address owner) public {
      marketDAI.withdrawAtMaturity(maturity, positionAssets, minAssetsRequired, receiver, owner);
    }

    //////////////////////////////////////////////////////////
    ///////////// ETH Market's Wrapper Functions /////////////
    //////////////////////////////////////////////////////////


    ///////////////////////////////////////////////////////////////
    ///////////// RewardsController Wrapper Functions /////////////
    ///////////////////////////////////////////////////////////////

    function rewardsController_claimPermit(uint256 numOfOperations, uint256 randAccount) public {
      numOfOperations = (numOfOperations % markets.length) + 1;

      /// prepare marketOps
      RewardsController.MarketOperation[] memory marketOps = new RewardsController.MarketOperation[](numOfOperations);
      
      for (uint8 i = 0; i < numOfOperations; i++) {
        bool[] memory ops = new bool[](2); // 2 is based on source code. You are only rewarded for borrows and deposits
        ops[0] = true;
        ops[1] = false;
        marketOps[i] = RewardsController.MarketOperation({ market: markets[i], operations: ops });
      }
      
      /// prepare permit
      randAccount = randAccount % 5;
      uint256 accountKey;
      if (randAccount == 0){
        accountKey = 0x01;
      }else if (randAccount == 1){
        accountKey = 0x02;
      }else if (randAccount == 2){
        accountKey = 0x03;
      }else if (randAccount == 3){
        accountKey = 0x04;
      }else{
        accountKey = 0x05;
      }

      ClaimPermit memory permit;
      permit.owner = vm.addr(accountKey);
      permit.assets = rewards;
      permit.deadline = block.timestamp;
      (permit.v, permit.r, permit.s) = vm.sign(
        accountKey,
        keccak256(
          abi.encodePacked(
            "\x19\x01",
            rewardsController.DOMAIN_SEPARATOR(),
            keccak256(
              abi.encode(
                keccak256("ClaimPermit(address owner,address spender,address[] assets,uint256 deadline)"),
                permit.owner,
                msg.sender,
                permit.assets,
                rewardsController.nonces(permit.owner),
                permit.deadline
              )
            )
          )
        )
      );


      vm.prank(msg.sender);
      rewardsController.claim(marketOps, permit);
    }

    function rewardsController_claim(uint256 numOfOperations) public {
      numOfOperations = (numOfOperations % markets.length) + 1;

      RewardsController.MarketOperation[] memory marketOps = new RewardsController.MarketOperation[](numOfOperations);
      
      for (uint8 i = 0; i < numOfOperations; i++) {
        bool[] memory ops = new bool[](2);
        ops[0] = true;
        ops[1] = false;
        marketOps[i] = RewardsController.MarketOperation({ market: markets[i], operations: ops });
      }

      vm.prank(msg.sender);
      rewardsController.claim(marketOps, msg.sender, rewards);
    }

    function rewardsController_claimAll(address to) public {
      rewardsController.claimAll(to);
    }


    function rewardsController_handleBorrow(address account) public {
      rewardsController.handleBorrow(account);
    }

    function rewardsController_handleDeposit(address account) public {
      rewardsController.handleDeposit(account);
    }


    function rewardsController_renounceRole(bytes32 role, address account) public {
      rewardsController.renounceRole(role, account);
    }

    function rewardsController_revokeRole(bytes32 role, address account) public {
      rewardsController.revokeRole(role, account);
    }

    ////////////////////////////////////////////////////////////////
    ///////////// InstallmentsRouter Wrapper Functions /////////////
    ////////////////////////////////////////////////////////////////


}
