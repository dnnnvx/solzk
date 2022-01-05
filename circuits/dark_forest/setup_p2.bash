#!/bin/bash

# generate witness from our input arguments

echo "{\"x\": $1, \"y\": $2}" > 'input_p2.json'
node init_js/generate_witness.js init_js/init.wasm input_p2.json witness.wtns

# we use groth16 instead of plonk for the setup
# the phase 2 ceremony is almost the same as the one in phase 2, with zkey instad of ptau files
snarkjs groth16 setup init.r1cs pot12_final.ptau init_p2_0000.zkey
snarkjs zkey contribute init_p2_0000.zkey init_p2_0001.zkey --name="First Contributor Name" -v -e="Another random ciao"
snarkjs zkey contribute init_p2_0001.zkey init_p2_0002.zkey --name="Second contribution Name" -v -e="Another random ciao ciao"

# verify the final key
snarkjs zkey verify init.r1cs pot12_final.ptau init_p2_0002.zkey

# apply a random bracon
snarkjs zkey beacon init_p2_0002.zkey init_p2_final.zkey 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon phase 2"

# verify beacon key
snarkjs zkey verify init.r1cs pot12_final.ptau init_p2_final.zkey

# export the verification key
snarkjs zkey export verificationkey init_p2_final.zkey verification_key.json

# create the proof
snarkjs groth16 prove init_p2_final.zkey witness.wtns proof.json public.json

# verify the proof
snarkjs groth16 verify verification_key.json public.json proof.json

# print the params for the sc (use it in remix ide to test -> return true)
snarkjs generatecall # or snarkjs zkey export soliditycalldata public.json proof.json