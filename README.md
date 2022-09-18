# Zero Data Rollup

![Horse and car](imgs/horsecartext.jpg)

Zero Data Rollup: it's a protocol with rollup security properties and off-chain data availability. 

How can it be possible?

We need to use an interactive protocol where the sender, receiver, and operator should cooperate to make a transaction.

# How it works

We introduce a coinId concept from [Plasma Cash](https://ethresear.ch/t/plasma-cash-plasma-with-much-less-per-user-data-checking/1298). Every ether inside our protocol is a note - note with indivisible unique coinID which can be transferred holistically. In other words, it's a UTXO model with 1 input and 1 output per transaction.

When a user deposits a coin - the protocol creates a unique coinId. After that operator can send this note with coinID on L2 to the receiver. The receiver should get the Merkle path of the new state and sign the transaction. Otherwise, the transaction will create a withdrawal with this coinId to L1.

So every owner and past owner of the coin knows the Merkle path of this coin in some previous state. And there is some simple dispute resolution protocol for dispute - who is the owner of this coin - latest Merkle path to the state with this coin is the owner. And every user has incentives to keep his data and monitor L1. And participate in the dispute resolution protocol.

# Limitations

- indivisible notes: no UTXO splitting, no accounts
- no Turing-complete smart contracts (only bitcoin script is possible)
- interactive communication
- user should keep data and monitor L1

# NFT

Indivisible notes can be NFT. So it's perfect feet for NFT marketplaces and NFT games.

![NFT](imgs/nft.jpeg)

# Atomic transaction and atomic swaps

We can introduce an atomic transaction where 2 user exchanges a few indivisible notes. It's trivial.

# Propreties in table

|                                | rollup | zk-sidechain/validium | zero data rollup |
|--------------------------------|--------|-----------------------|------------------|
| on-chain data size             | O(n)   | O(1)                  | O(1)             |
| operator can freeze            | NO     | YES                   | NO               |
| need interactive communication | NO     | NO                    | YES              |
| can be Turing Complete         | YES    | YES                   | NO               |

# What we implemented

- [X] Spec
    - [X] Smart contract spec
    - [X] Circuit spec
    - [x] Operator node spec
    - [ ] Client spec 
- [x] Smart contract
- [x] Circuit
    - [x] Main circuit
    - [x] Run all types of transaction function
    - [x] Test with real block example
    - [x] State and merle tree
    - [x] VK for main circuit
    - [ ] Proof of preimage of non algebraic hash
    - [ ] Transaction parser
- [ ] Operator node
- [ ] UI for client
- [x] ETH support
- [ ] ERC20 support
- [ ] NFT support
- [ ] Atomic swap support

# Tech stack

- [plonk](https://eprint.iacr.org/2019/953.pdf): prove system with universal trusted setup
- [belman_ce](https://github.com/matter-labs/bellman): fork of original belman with plonk
- [franklin-crypto](https://github.com/matter-labs/franklin-crypto): Gadget library for PLONK/Plookup
- [solidity plonk verifier](https://github.com/andreysobol/solidity_plonk_verifier) solidity plonk verifier with lookup tables
- [rescue poseidon](https://github.com/matter-labs/rescue-poseidon): Rescue and Poseidon argebraic hash circuit implementation 
- [hardhat](https://hardhat.org/): Eth contract toolkit

# How to use it

install rust and cargo

```
cd circuit
cargo build
```

run tested block and other tests

```
cd circuit
cargo test
```

Generate Solidity Plonk Verifier using verification key

```
cd circuit/solidity_plonk_verifier/
cargo build --release
./target/release/solidity_plonk_verifier --verification-key ../vk.txt
cat ./hardhat/contracts/VerificationKey.sol | sed 's%import "hardhat/console.sol";% %g' > PATH_TO_SC/VerificationKey.sol
```

Compile Smart Contracts

```
cd contracts
npx hardhat compile
```

Deploy Smart Contracts

```
npx hardhat run scripts/deploy.js
```

# Demo

TODO