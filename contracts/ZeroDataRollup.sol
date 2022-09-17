// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Storage.sol";
import "./MerkleVerifier.sol";

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

        depositQueue[coinId] = depositDetails;
        usedCoinIds[coinId][block.number] = _l2Receiver;

        emit DepositInitiated(msg.sender, _l2Receiver, coinId, msg.value);
    }

    function withdraw(
        uint256 _coinId,
        uint256 _l1BlockNumber,
        bytes32[] calldata _path,
        uint256 _index,
        bytes32 _itemHash,
        uint256 _blockNumber
    ) external notExodus {
      bytes32 actualRoot = MerkleVerifier.calculateRoot(
            _path,
            _index,
            _itemHash
        );

        require(actualRoot == merkleRoots[_blockNumber]);

        require(usedCoinIds[_coinId][_l1BlockNumber] == msg.sender);

        uint256 currentWithdrawals = processedForceWithdrawals;
        processedForceWithdrawals++;
        forceWithdrawsQueue[currentWithdrawals] = WithdrawDetails(
            currentWithdrawals,
            msg.sender,
            _coinId,
            _l1BlockNumber,
            _index,
            _itemHash
        );

        emit WithdrawRequestAccepted(msg.sender, _coinId, _blockNumber);
    }

    function finalizeWithdraw(uint256 withdrawId) external notExodus {
        if(block.number <  WITHDRAW_WAITING_TIME + forceWithdrawsQueue[withdrawId].l1BlockNumber){

        } else{
            isExodus = true;
            startExodus();
        }

    }

    function startExodus() internal {
        

    }

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
        // todo: remove deposit records from depositQueue and update processedDepositAmount
        // todo: verify(prevMerkleRoot, newMerkleRoot, proof);

    }

    function verify(
        uint256[] memory public_inputs,
        uint256[] memory serialized_proof
    ) public view returns (bool) {
        return true;
    }
}
