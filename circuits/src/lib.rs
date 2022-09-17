pub use franklin_crypto::{
    bellman::{
        kate_commitment::{Crs, CrsForMonomialForm},
        plonk::better_better_cs::{
            cs::{
                Assembly, Circuit, ConstraintSystem, Gate, GateInternal, LookupTableApplication,
                PlonkCsWidth4WithNextStepAndCustomGatesParams, PolyIdentifier, Setup, Width4MainGateWithDNext,
                TrivialAssembly, PlonkCsWidth4WithNextStepParams,
                ArithmeticTerm,
                MainGateTerm,
            },
            proof::Proof,
            setup::VerificationKey,
            verifier,
            gates::selector_optimized_with_d_next::SelectorOptimizedWidth4MainGateWithDNext,
            verifier::verify,
        },
        Engine, Field, PrimeField, ScalarEngine, SynthesisError,
        worker::Worker,
        plonk::commitments::transcript::{keccak_transcript::RollingKeccakTranscript, Transcript},
        compact_bn256::{Bn256, Fr},
    },
    plonk::circuit::{
        allocated_num::{AllocatedNum, Num},
        boolean::{AllocatedBit, Boolean},
        byte::Byte,
        custom_rescue_gate::Rescue5CustomGate,
    },
};
use itertools::Itertools;

pub use rescue_poseidon::{circuit_generic_hash, CustomGate, HashParams, RescueParams};

pub mod contract_circuits;

// pub mod generate;
// pub mod serialize;
// mod test_circuits;

use contract_circuits::*;
#[test]
fn test_main_circuit() {
    let mut circuit = MainContractCircuit::<Bn256> {
        initall_state_root: [Some(Fr::zero()); 2],
        final_state_root: [Some(Fr::zero()); 2],
    
        hash_of_contract_withdrawals: [Some(Fr::zero()); 2],
        hash_of_withdrawals: [Some(Fr::zero()); 2],
        hash_of_wrong_withdrawals: [Some(Fr::zero()); 2],
        hash_of_deposits: [Some(Fr::zero()); 2],
        hash_of_order: [Some(Fr::zero()); 2],

        merkle_passes: [[([Some(Fr::zero()); 2], false); STATE_DEPTH + 1]; NUM_TX],
    
        contract_withdrawals_inner: [Some(0); HASH_PREIM_SIZE],
        withdrawals_inner: [Some(0); HASH_PREIM_SIZE],
        wrong_withdrawals_inner: [Some(0); HASH_PREIM_SIZE],
        deposits_inner: [Some(0); HASH_PREIM_SIZE],
        order_inner: [Some(0); HASH_PREIM_SIZE],
    
        transfers: [Some(0); HASH_PREIM_SIZE],
    };

    let old_worker = Worker::new();

    let mut assembly = TrivialAssembly::<
        Bn256,
        PlonkCsWidth4WithNextStepParams,
        Width4MainGateWithDNext,
    >::new();

    circuit.synthesize(&mut assembly).expect("must work");
    assert!(assembly.is_satisfied());

    assembly.finalize();

    let domain_size = assembly.n().next_power_of_two();

    let crs_mons = Crs::<Bn256, CrsForMonomialForm>::crs_42(domain_size, &old_worker);

    let setup = assembly
        .create_setup::<MainContractCircuit<Bn256>>(&old_worker)
        .unwrap();


    let proof = assembly.clone()
        .create_proof::<MainContractCircuit<Bn256>, RollingKeccakTranscript<Fr>>(
            &old_worker,
            &setup,
            &crs_mons,
            None,
        )
        .unwrap();

    let vk = VerificationKey::from_setup(&setup, &old_worker, &crs_mons).unwrap();

    let valid =
        verify::<Bn256, MainContractCircuit<Bn256>, RollingKeccakTranscript<Fr>>(&vk, &proof, None)
            .unwrap();

    assert!(valid);
}
