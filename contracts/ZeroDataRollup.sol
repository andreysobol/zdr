// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract ZeroDataRollup {

    uint256 public mintedCoinsCounter; // default 0
    uint256 public unprocessedDepositAmount; // default 0
    mapping(address => hereWillBeStructure) public mintedCoins; // default 0

    function deposit(
        address _l2Receiver,
        address _l1Token,
        uint256 _amount)
    // TODO: remove nonReentrant
    external payable nonReentrant returns (bytes32 txHash) {

        /*

        Deposit ETH to the contract. This function should:
        1. Increase number of `mintedCoinsCounter`. 
        2. Use this `mintedCoinsCounter` as `coinId` for the `Deposit` event.
        3. Mint event `Deposit` with the amount of ETH deposited and address of the sender.
        4. Add deposit to some magic structure of the deposit. Mb it's will be maping of address to amount of ETH, `coinId` and `L1BlockNumber` of the deposit.
        5. Increase unprocessed deposits amount.

        */

        uint256 coinId = mintedCoinsCounter;

        mintedCoinsCounter = mintedCoinsCounter + 1;

        message.sender

        // TODO intoduce Deposit event
        // TODO Check the amount of ETH 
        Deposit(coinId, message.sender, message.value.amount);

        mintedCoins = message.sender : {
            coinId: coinId,
            amount: message.value.amount,
            l1BlockNumber: block.number,
        }

        unprocessedDepositAmount = unprocessedDepositAmount + 1;

    }

    /**
     * @dev Return value 
     * @return value of 'number'
     */
    function retrieve() public view returns (uint256){
        return number;
    }
}
