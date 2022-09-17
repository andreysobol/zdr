# SPEC

## Contract

List of functions:

- `deposit()`
- `withdraw()`
- `processWithdraw()`
- `executeBlock()`
- `startExodus()`

### Deposit

Deposit ETH to the contract. This function should:
1. Increase number of `mintedCoinsCounter`. 
2. Use this `mintedCoinsCounter` as `coinId` for the `Deposit` event.
3. Mint event `Deposit` with the amount of ETH deposited and address of the sender.
4. Add deposit to map of address to amount of ETH, `coinId` and `L1BlockNumber` of the deposit.
5. Increase unprocessed deposits amount.

### Withdraw

If exodus is not started:
1. Get `merkleRoot` from `merkleRoots` by `L2blockNumber` 
2. Verify that `merklePath` from arguments is valid merkle path to `merkleRoot`
3. Verify that `coinId` is not used before. If it's used - check that `coinId` > current `coinId` from `usedCoinIds`
5. Remove previous withdraw from `WaitingForWithdrawals`
6. Emmit `WaitingForWithdraw` event with `amount` and `address` of the sender
7. Add this withdraw to `WaitingForWithdrawals` map. Set `amount` and `address` and `L1BlockNumber` and `merklePosition` and `coinId` of the deposit.

### ProcessWithdraw

1. Check that `withdrawId` in `WaitingForWithdraw` structure.
2. Check that `L1BlockNumber` + `WITHDRAW_WAITING_TIME` of the deposit is less than current `L1BlockNumber`
3. Start exodus if it's not started.

### ExecuteBlock

1. Set `prevMerkleRoot` as value from `merkleRoots` by key `lastL2blockNumber`
2. Calculate `hash(DepositsBytes)`
3. Calculate `hash(WithdrawsBytes)`
4. Verify proof with `prevMerkleRoot`, `newMerkleRoot`, `hash(DepositsBytes)`, `hash(WithdrawsBytes)` and `proof`
5. Remove all elements of `DepositsBytes` from some magic structure of the deposits
6. Send ETH to all `WithdrawsBytes`
7. Remove all elements of `WithdrawsBytes` from `WaitingForWithdrawals` map
8. Emmit `BlockExecuted` event with `L2blockNumber`, `newMerkleRoot`, `hash(DepositsBytes)`, `hash(WithdrawsBytes)`

TODO PART: publish coinId in Withdrawals, ProcessWithdraw

### StartExodus

1. Check that `exodusStarted` is false
2. Set `censouredDeposits` as value from some magic structure of the deposits with key `censouredDepositId`
3. Check that L1BlockNumber from `censouredDeposits` + `DEPOSIT_WAITING_TIME` is less than current `L1BlockNumber`
4. Emmit `ExodusStarted` event
5. `exodusStarted` = true

## Circuit

Circuit separetadet do 4 parts:
- Contract withdraw parts
- Deposit parts
- Transfer commitment parts
- Transfer execution parts

Public inputs:
- `initallStateRoot`
- `finalStateRoot`
- `hash(contractWithdrawals)`
- `hash(withdrawals)`
- `markle_root(wrongWithdrawals)`
- `hash(deposits)`

### Contract withdraw parts

```
hash(contractWithdrawals) = contractWithdrawals
accomulatorWrongWithdrawals = empty_merkle_tree
initallStateRoot == state
```

for every contractWithdrawal:
```
contractWithdrawal = (coinId, amount, address, merklePosition)
(stateCoinId, stateAmount, stateAddress) = state_tree[merklePosition]
check this statment:
    (
        coinId == stateCoinId
        amount == stateAmount
        address == stateAddress
        state == removeElement(state, merklePosition)
    ) or 
    (
        nextCccomulatorWrongWithdrawals = addOneToMerkleTree(prevAccomulatorWrongWithdrawals, withdrawal)
    )
```

and check that `accomulatorWrongWithdrawals == markle_root(wrongWithdrawals)`

save final state to `stateAfterWithdrawals`

### Deposit parts

```
hash(deposits) = deposits
state = stateAfterWithdrawals
```

for every deposit:
```
deposit = (coinId, amount, address)
state = addOneToMerkleTree(state, deposit)
```

save final state to `stateAfterDeposit`

### Transfer commitment parts

```
hash(transactions) = transactions_hash
transferAccomulator = empty_merkle_tree
```

for every transaction:

```
transaction = (from_address, to_address, amount, coin_id, signature)
verify merkle proof of note from transaction
savedAmount + fee = amount
operatorFee = fee + operatorFee
check(signature, from_address)
state = addOneToMerkleTree(state, from_address, to_address, amount, coin_id, signature)
transferAccomulator = addOneToMerkleTree(transferAccomulator, transaction)
```

### Commit part

for every withdrawal:

```
state == removeElement(state, withdrawal)
transferAccomulator == removeElement(transferAccomulator, withdrawal)
```

for every transaction_confirmation:

```
transaction_confirmation = (transaction, signature)
transaction = (from_address, to_address, amount, coin_id, signature)
check(signature, to_address)
transferAccomulator == removeElement(transferAccomulator, transaction)
```

in the end check that `transferAccomulator == empty_merkle_tree`

```