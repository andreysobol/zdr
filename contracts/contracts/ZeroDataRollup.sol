// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Storage.sol";
import "./MerkleVerifier.sol";

/**
 * @title ZeroDataRollup
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy.ts
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
        usedCoinIds[coinId] = 1;

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
        require(usedCoinIds[_coinId] != 0);
        require(usedCoinIds[_coinId] < _blockNumber);

        uint256 currentWithdrawals = processedForceWithdrawals;
        processedForceWithdrawals++;
        forceWithdrawsQueue[currentWithdrawals] = WithdrawDetails(
            currentWithdrawals,
            msg.sender,
            _coinId,
            _l1BlockNumber,
            _index,
            _itemHash,
            _coinId
        );

        usedCoinIds[_coinId] = _blockNumber;

        emit WithdrawRequestAccepted(currentWithdrawals, msg.sender, _coinId, _blockNumber);
    }

    function processWithdraw(uint256 withdrawId) external notExodus {
        require(forceWithdrawsQueue[withdrawId].l1BlockNumber != 0);
        require(block.number <  WITHDRAW_WAITING_TIME + forceWithdrawsQueue[withdrawId].l1BlockNumber);
        isExodus = true;

        address payable receiver = payable(forceWithdrawsQueue[withdrawId].receiver);
        uint256 amount = forceWithdrawsQueue[withdrawId].amount;
        uint256 coinId = forceWithdrawsQueue[withdrawId].coinId;

        delete forceWithdrawsQueue[withdrawId];
        delete usedCoinIds[coinId];
        receiver.transfer(amount);
    }

    function startExodus(uint256 censouredDepositId) external notExodus {
        DepositDetails memory censouredDeposits = depositQueue[censouredDepositId];
        require(DEPOSIT_WAITING_TIME + censouredDeposits.l1BlockNumber < block.number);
        isExodus = true;
    }

    function toBytes32(bytes memory _bytes, uint256 _start) internal pure returns (bytes32) {
        require(_bytes.length >= _start + 32, "toBytes32_outOfBounds");
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }

    function toBytes20(bytes memory _bytes, uint256 _start) internal pure returns (bytes20) {
        require(_bytes.length >= _start + 20, "toBytes32_outOfBounds");
        bytes20 tempBytes20;

        assembly {
            tempBytes20 := mload(add(add(_bytes, 0x14), _start))
        }

        return tempBytes20;
    }

    function executeBlock(
        uint256 newMerkleRoot,
        bytes calldata depositsBytes,
        bytes calldata withdrawsBytes,
        uint256[] calldata proof
    ) external notExodus {
        currentBlockNumber++; // currentBlockNumber will start from 1

        // Genesis is a zero
        bytes32 prevMerkleRoot = merkleRoots[currentBlockNumber];
        bytes32 hashedDeposits = keccak256(depositsBytes);
        bytes32 hashedWithdraws = keccak256(withdrawsBytes);

        uint256[] memory public_inputs = new uint256[](3);
        public_inputs[0] = uint256(prevMerkleRoot);
        public_inputs[1] = uint256(newMerkleRoot);
        public_inputs[2] = uint256(hashedDeposits);
        public_inputs[3] = uint256(hashedWithdraws);

        verify(public_inputs, proof);

        for (uint256 i = 0; i < depositsBytes.length; i += 32*3) {
            uint256 coinId = uint256(toBytes32(depositsBytes, i));
            delete depositQueue[coinId];
        }

        for (uint256 i = 0; i < withdrawsBytes.length; i += 32*6) {
            address payable receiver = payable(address(toBytes20(depositsBytes, i)));
            uint256 amount = uint256(toBytes32(depositsBytes, i+20));
            uint256 coinId = uint256(toBytes32(depositsBytes, i+20+32));
            uint256 processedForceWithdrawals = uint256(toBytes32(depositsBytes, i+20+32*2));

            delete forceWithdrawsQueue[processedForceWithdrawals];
            delete usedCoinIds[coinId];
            receiver.transfer(amount);
        }

    }

    function verify(
        uint256[] memory public_inputs,
        uint256[] memory serialized_proof
    ) public view returns (bool) {
        return true;
    }
}
