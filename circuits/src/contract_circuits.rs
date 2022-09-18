use super::*;
use franklin_crypto::plonk::circuit::Assignment;

pub const HASH_PREIM_SIZE: usize = 136 * 1;
pub const STATE_DEPTH: usize = 32;
pub const NUM_TX: usize = 32;

pub struct MainContractCircuit<E: Engine> {
    // Public Inputs
    pub initall_state_root: [Option<E::Fr>; 2],
    pub final_state_root: [Option<E::Fr>; 2],

    pub hash_of_contract_withdrawals: [Option<E::Fr>; 2],
    pub hash_of_withdrawals: [Option<E::Fr>; 2],
    pub hash_of_wrong_withdrawals: [Option<E::Fr>; 2],
    pub hash_of_deposits: [Option<E::Fr>; 2],
    pub hash_of_order: [Option<E::Fr>; 2],
    // Witness
    pub merkle_passes: [[([Option<E::Fr>; 2], bool); STATE_DEPTH + 1]; NUM_TX],

    pub contract_withdrawals_inner: [Option<u8>; HASH_PREIM_SIZE],
    pub withdrawals_inner: [Option<u8>; HASH_PREIM_SIZE],
    pub wrong_withdrawals_inner: [Option<u8>; HASH_PREIM_SIZE],
    pub deposits_inner: [Option<u8>; HASH_PREIM_SIZE],
    pub order_inner: [Option<u8>; HASH_PREIM_SIZE],

    pub transfers: [Option<u8>; HASH_PREIM_SIZE],
}

impl<E: Engine> Circuit<E> for MainContractCircuit<E> {
    type MainGate = Width4MainGateWithDNext;

    fn synthesize<CS: ConstraintSystem<E>>(&self, cs: &mut CS) -> Result<(), SynthesisError> {
        let mut current_state_root = alloc_input_hash(cs, &self.initall_state_root)?;
        let final_state_root = alloc_input_hash(cs, &self.final_state_root)?;
        // Unwraping hashes
        let (contract_withdrawals_inner, contract_withdrawals_len) = unwrap_input_hash(
            cs,
            &self.hash_of_contract_withdrawals,
            &self.contract_withdrawals_inner,
        )?;

        let (withdrawals_inner, withdrawals_len) = unwrap_input_hash(
            cs,
            &self.hash_of_withdrawals,
            &self.withdrawals_inner,
        )?;

        let (wrong_withdrawals_inner, wrong_withdrawals_len) = unwrap_input_hash(
            cs,
            &self.hash_of_wrong_withdrawals,
            &self.wrong_withdrawals_inner,
        )?;

        let (deposits_inner, deposits_len) = unwrap_input_hash(
            cs,
            &self.hash_of_deposits,
            &self.deposits_inner,
        )?;

        let (order_inner, order_len) = unwrap_input_hash(
            cs,
            &self.hash_of_order,
            &self.order_inner,
        )?;

        let transfers = alloc_preimage(cs, &self.transfers)?;

        let num_tx = Num::<E>::Constant(E::Fr::from_str(&format!("{}", NUM_TX)).unwrap());
        order_len.enforce_equal(cs, &num_tx)?;

        let merkle_passes = alloc_merkle_passes(cs, &self.merkle_passes)?;

        let mut state = [Num::zero(); 5];

        for tx_number in 0..NUM_TX {
            prove_tx(
                cs,
                tx_number,
                &mut state,
                &mut current_state_root,
                &contract_withdrawals_inner,
                &contract_withdrawals_len,
                &withdrawals_inner,
                &withdrawals_len,
                &wrong_withdrawals_inner,
                &wrong_withdrawals_len,
                &deposits_inner,
                &deposits_len,
                &order_inner,
                &transfers,
                &merkle_passes[tx_number]
            )?;
        }

        current_state_root[0].enforce_equal(cs, &final_state_root[0])?;
        current_state_root[1].enforce_equal(cs, &final_state_root[1])?;

        Ok(())
    }
}


pub fn alloc_input_hash<E: Engine, CS: ConstraintSystem<E>> (
    cs: &mut CS,
    input: &[Option<E::Fr>; 2],
) -> Result<[Num<E>; 2], SynthesisError> {
    let num_0 = AllocatedNum::alloc_input(cs, || Ok(*input[0].get()?))?;
    let num_1 = AllocatedNum::alloc_input(cs, || Ok(*input[1].get()?))?;
    Ok([Num::Variable(num_0), Num::Variable(num_1)])
}

pub fn alloc_merkle_passes<E: Engine, CS: ConstraintSystem<E>> (
    cs: &mut CS,
    merkle_passes: &[[([Option<E::Fr>; 2], bool); STATE_DEPTH + 1]; NUM_TX],
) -> Result<[[([Num<E>; 2], Boolean); STATE_DEPTH + 1]; NUM_TX], SynthesisError> {

    // TODO

    Ok([[([Num::zero(); 2], Boolean::Constant(false)); STATE_DEPTH + 1]; NUM_TX])
}

pub fn alloc_preimage<E: Engine, CS: ConstraintSystem<E>> (
    cs: &mut CS,
    input: &[Option<u8>; HASH_PREIM_SIZE],
) -> Result<[Byte<E>; HASH_PREIM_SIZE], SynthesisError> {
    let mut result = [Byte::zero(); HASH_PREIM_SIZE];

    for (i, el) in input.iter().enumerate() {
        result[i] = Byte{
            inner: Num::alloc(cs, E::Fr::from_str(&format!("{}", el.unwrap())))?
        }

        // TODO add byte check
    }

    Ok(result)
}

pub fn unwrap_input_hash<E: Engine, CS: ConstraintSystem<E>> (
    cs: &mut CS,
    hash: &[Option<E::Fr>; 2],
    preimage: &[Option<u8>; HASH_PREIM_SIZE],
) -> Result<([Byte<E>; HASH_PREIM_SIZE], Num<E>), SynthesisError> {
    let hash = alloc_input_hash(cs, hash)?;
    let preimage = alloc_preimage(cs, preimage)?;

    let length = check_keccak(cs, &hash, &preimage)?;

    Ok((preimage, length))
}

fn check_keccak<E: Engine, CS: ConstraintSystem<E>> (
    cs: &mut CS,
    hash: &[Num<E>; 2],
    preimage: &[Byte<E>; HASH_PREIM_SIZE],
) -> Result<Num<E>, SynthesisError> {

    // TODO

    Ok(Num::Constant(E::Fr::from_str("32").unwrap()))
}

fn check_merkle_tree_keccak<E: Engine, CS: ConstraintSystem<E>> (
    cs: &mut CS,
    hash: &[Num<E>; 2],
    preimage: &[Byte<E>; 2],
) -> Result<Num<E>, SynthesisError> {
    
    // TODO

    Ok(Num::zero())
}

//deposit
//contract withdrowal
//wrong withdrowal
//tx
//withdrowal

// order[tx_number]:
// 0 => contract withdrowal
// 1 => withdrowal
// check signature
// set values to zero
// 2 => wrong withdrowal
// check something wrong
// 3 => transfer
// check signature
// change owner
// 4 => deposit
// check if zero
// set correct values

// Total: 85 bytes
// signature - 32 bytes
// adress - 20 bytes
// amount - 32 bytes
// token id - 1 byte
pub fn prove_tx<E: Engine, CS: ConstraintSystem<E>> (
    cs: &mut CS,
    tx_number: usize,
    state: &mut [Num<E>; 5],
    current_state_root: &mut [Num<E>; 2],
    contract_withdrawals_inner: &[Byte<E>; HASH_PREIM_SIZE],
    contract_withdrawals_len: &Num<E>,
    withdrawals_inner: &[Byte<E>; HASH_PREIM_SIZE],
    withdrawals_len: &Num<E>,
    wrong_withdrawals_inner: &[Byte<E>; HASH_PREIM_SIZE],
    wrong_withdrawals_len: &Num<E>,
    deposits_inner: &[Byte<E>; HASH_PREIM_SIZE],
    deposits_len: &Num<E>,
    order_inner: &[Byte<E>; HASH_PREIM_SIZE],
    transfers: &[Byte<E>; HASH_PREIM_SIZE],
    merkle_pass: &[([Num<E>; 2], Boolean); STATE_DEPTH + 1]
) -> Result<(), SynthesisError> {
    let zero = Num::<E>::zero();
    let one = Num::<E>::one();
    let two = Num::<E>::Constant(E::Fr::from_str("2").unwrap());
    let three = Num::<E>::Constant(E::Fr::from_str("3").unwrap());

    update_state(cs, tx_number, state, order_inner)?;

    Ok(())
}

fn less<E: Engine, CS: ConstraintSystem<E>> (
    cs: &mut CS,
    a: &Byte<E>,
    b: &Byte<E>,
) -> Result<Boolean, SynthesisError> {

    // TODO

    Ok(Boolean::Constant(false))
}

fn check_that_byte<E: Engine, CS: ConstraintSystem<E>> (
    cs: &mut CS,
    byte: &Num<E>
) -> Result<(), SynthesisError> {

    // TODO

    Ok(())
}

fn check_signature<E: Engine, CS: ConstraintSystem<E>> (
    cs: &mut CS,
    byte: &Num<E>
) -> Result<(), SynthesisError> {

    // TODO

    Ok(())
}

fn update_state<E: Engine, CS: ConstraintSystem<E>> (
    cs: &mut CS,
    tx_number: usize,
    state: &mut [Num<E>; 5],
    order_inner: &[Byte<E>; HASH_PREIM_SIZE],
) -> Result<(), SynthesisError> {

    // TODO

    Ok(())
}
