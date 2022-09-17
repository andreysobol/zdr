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

    struct DepositDetails {
        address receiver;
        uint256 amount;
        uint256 l1BlockNumber;
    }

    mapping(uint256 => DepositDetails) priorityQueue;
    mapping(uint256 => bytes32) merkleRoots;

    uint256 currentBlockNumber;
    uint256 mintedCoinsCounter;
    uint256 processedDepositAmount;
    bool isExodus;
}
