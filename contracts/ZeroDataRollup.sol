// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Storage.sol";

/**
 * @title ZeroDataRollup
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract ZeroDataRollup is Storage {
    modifier notExodus() {
        require(!isExodus, "Exodus activated");
        _;
    }

    function deposit(address _l2Receiver) external payable notExodus {
        require(msg.value > 0);

        uint256 coinId = mintedCoinsCounter;
        mintedCoinsCounter++;

        DepositDetails memory depositDetails = DepositDetails(
            _l2Receiver,
            msg.value,
            block.number
        );

        priorityQueue[coinId] = depositDetails;

        emit DepositInitiated(msg.sender, _l2Receiver, coinId, msg.value);
    }

    function withdraw(address _l1Receiver) external {}

    function ExecuteBlock(
        uint256 newMerkleRoot,
        bytes calldata depositsBytes,
        bytes calldata withdrawsBytes,
        uint256[] calldata proof
    ) external notExodus {
        bytes32 prevMerkleRoot = merkleRoots[currentBlockNumber];
        bytes32 hashedDeposits = keccak256(depositsBytes);
        bytes32 hashedWithdraws = keccak256(withdrawsBytes);

        currentBlockNumber++;
        // verify(prevMerkleRoot, newMerkleRoot, proof);
    }

    function verify(
        uint256[] memory public_inputs,
        uint256[] memory serialized_proof
    ) public view returns (bool) {
        return true;
    }
}
