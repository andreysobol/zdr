# Zero Data Rollup

Zero Data Rollup: it's a protocol with rollup security properties and off-chain data availability. 

How can it possible?

We need to use interactive protocol where sender, receiver and operator should cooperate to make a transaction.

# How it works

We introduce a `coinId` concept from [Plasma Cash](https://ethresear.ch/t/plasma-cash-plasma-with-much-less-per-user-data-checking/1298). Every ether inside our protocol is a note - note with indivisible unique `coinID` which can be transfered holistically. Other words it's UTXO model with 1 input and 1 output per transaction.

When user deposit coin - protocol create unic `coinId`. After that user can send this note with `coinID` on L2 to reciver. Reciver should get merkle path of new state and sign the transaction. Otherwise transaction will create withdrawal with this `coinId` to L1.

So every owners and past owners of the coin know merkle path of this coin in some previus state. And there is some simple dispute resolution protocol for dispute - who is owner of this coin - latest merkle path to the state with this coin is owner. And every user have insentives to keep his data and monitor L1. And participate to the dispute resolution protocol.

# Propreties

|                                | rollup | zk-sidechain/validium | zero data rollup |
|--------------------------------|--------|-----------------------|------------------|
| on chain data size             | O(n)   | O(1)                  | O(1)             |
| operator can freeze            | NO     | YES                   | NO               |
| need interactive communication | NO     | NO                    | YES              |
| can be Turing Complete         | YES    | YES                   | NO               |