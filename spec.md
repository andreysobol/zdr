# SPEC

## Contract

List of functions:

- `deposit()`
- `withdraw()`
- `executeBlock()`
- `startExodus()`
- `withdrawInExodus()`

### Deposit

Deposit ETH to the contract. This function should:
1. Mint event `Deposit` with the amount of ETH deposited and address of the sender.
2. Add deposit to some magic structure of the deposit. Mb it's will be maping of address to amount of ETH.
3. Increase unprocessed deposits amount.

## Circuit
