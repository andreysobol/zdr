# SPEC

## Contract

List of functions:

- `deposit()`
- `withdraw()`
- `processWithdraw()`
- `executeBlock()`
- `startExodus()`
- `withdrawInExodus()`

### Deposit

Deposit ETH to the contract. This function should:
1. Increase number of `mintedCoinsCounter`. 
2. Use this `mintedCoinsCounter` as `coinId` for the `Deposit` event.
3. Mint event `Deposit` with the amount of ETH deposited and address of the sender.
4. Add deposit to some magic structure of the deposit. Mb it's will be maping of address to amount of ETH and `coinId` of the deposit.
5. Increase unprocessed deposits amount.

### Withdraw

If exodus is not started:
1. Get `merkleRoot` from `merkleRoots` by `L2blockNumber` 
2. Verify that `merklePath` from arguments is valid merkle path to `merkleRoot`
3. Emmit `WaitingForWithdraw` event with `amount` and `address` of the sender
4. Add this withdraw to `WaitingForWithdrawals` map. Set `amount` and `address` and `L1BlockNumber` of the deposit.

### ProcessWithdraw

1. Check that `withdrawId` in `WaitingForWithdraw` structure.
2. Check that `L1BlockNumber` + `WITHDRAW_WAITING_TIME` of the deposit is less than current `L1BlockNumber`

### ExecuteBlock

1. Set `prevMerkleRoot` as value from `merkleRoots` by key `lastL2blockNumber`  
2. Verify proof with `prevMerkleRoot` and `newMerkleRoot` and `proof`

## Circuit
