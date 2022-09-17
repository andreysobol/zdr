// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 */
contract Storage {
    event DepositInitiated(
        address from,
        address to,
        uint256 coinId,
        uint256 amount
    );

    event WithdrawRequestAccepted(
        address from,
        uint256 coinId,
        uint256 blockNumber
    );

    struct DepositDetails {
        address receiver;
        uint256 amount;
        uint256 l1BlockNumber;
    }

    struct WithdrawDetails {
        uint256 withdtawId;
        address receiver;
        uint256 amount;
        uint256 l1BlockNumber;
        uint256 merklePosition;
        bytes32 itemHash;
    }

    uint256 processedDepositAmount;
    mapping(uint256 => DepositDetails) depositQueue;

    uint256 processedForceWithdrawals;
    mapping(uint256 => WithdrawDetails) forceWithdrawsQueue;

    uint256 currentBlockNumber;
    mapping(uint256 => bytes32) merkleRoots;

    mapping(uint256 => mapping(uint256 => address)) usedCoinIds;

    uint256 mintedCoinsCounter;
    bool isExodus;


   uint16 WITHDRAW_WAITING_TIME = 1000;
}
