pragma solidity ^0.8.9;

import {ISmLpToken} from "./interfaces/ISmLpToken.sol";

contract LendingPoolStorage {
    // ERC20
    struct ReserveData {
        uint256 depositAmount;
        uint256 availAmount;
        uint256 borrowAmount;
        address smTokenAddress;
        address reserveAddress;
        uint8 reserveDecimals;
    }

    mapping(address => ReserveData) internal _reserves; // reserve => reserve data

    function addSmToken(
        address smTokenAddress,
        address asset,
        uint8 reserveDecimals
    ) external {
        _reserves[asset] = ReserveData(
            0,
            0,
            0,
            smTokenAddress,
            asset,
            reserveDecimals
        );
        smTokenMap[asset] = smTokenAddress;
    }

    function addSmLpToken(
        address lpTokenAddress,
        address smLpTokenAddress,
        address tokenX,
        address tokenY
    ) external {
        smLpTokenMap[lpTokenAddress] = smLpTokenAddress;
        smLpTokenListPerAsset[tokenX].push(smLpTokenAddress);
        smLpTokenListPerAsset[tokenY].push(smLpTokenAddress);
    }

    // ERC20
    struct UserDebtData {
        uint256 borrowedAmount;
        bool wasBorrowed;
    }

    mapping(address => mapping(address => UserDebtData))
        internal _userDebtDatas; // reserve => user => user debt data

    mapping(address => address[]) internal smLpTokenDepositListPerUser;
    mapping(address => address[]) internal reserveBorrowListPerUser;

    mapping(address => address) smLpTokenMap; // left-hand: underlying token; right-hand: cd Token address
    mapping(address => address) smTokenMap; // left-hand: underlying token; right-hand: cd Token address
    mapping(address => address[]) smLpTokenListPerAsset; // smLpToken list of certain asset
}
