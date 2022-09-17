// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Bridge {

    function deposit(
        address _l2Receiver,
        address _l1Token,
        uint256 _amount)
    external payable nonReentrant returns (bytes32 txHash) {
        require(_l1Token == CONVENTIONAL_ETH_ADDRESS);

        // Will revert if msg.value is less than the amount of the deposit
        uint256 fee = msg.value - _amount;
        bytes memory l2TxCalldata = _getDepositL2Calldata(msg.sender, _l2Receiver, _amount);
        txHash = Mailbox.requestL2Transaction{value: fee}(
            l2Bridge,
            0,
            l2TxCalldata,
            DEPOSIT_ERGS_LIMIT,
            new bytes[](0)
        );

        // Save deposit amount, to claim funds back if the L2 transaction will failed
        depositAmount[msg.sender][txHash] = _amount;

        emit DepositInitiated(msg.sender, _l2Receiver, _l1Token, _amount);
    }

    /**
     * @dev Return value 
     * @return value of 'number'
     */
    function retrieve() public view returns (uint256){
        return number;
    }
}
