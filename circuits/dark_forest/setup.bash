#!/bin/bash

# start a new powers of tau ceremony
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
  
# contribute to the ceremony
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v -e="random ciao"
snarkjs powersoftau contribute pot12_0001.ptau pot12_0002.ptau --name="Second contribution" -v -e="random ciao ciao"
  
# at this point we can verify with:
snarkjs powersoftau verify pot12_0002.ptau

# cotribute applying a random beacon
#  \_ a random beacon is a source of public randomness that is not available before a fixed time.
#     The beacon itself can be a delayed hash function (e.g. 2^40 iterations of SHA256) evaluated
#     on some high entropy and publicly available data. Possible sources of data include:
#     the closing value of the stock market on a certain date in the future, the output of a selected
#     set of national lotteries, or the value of a block at a particular height in one or more
#     blockchains (e).g. the hash of the 11 millionth Ethereum block).
# snarkjs powersoftau beacon pot12_0002.ptau pot12_beacon.ptau 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon"

# prepare phase 2
snarkjs powersoftau prepare phase2 pot12_0002.ptau pot12_final.ptau -v

# verify the final tau
snarkjs powersoftau verify pot12_final.ptau

# circuit integration

# compile circom circuits (we use will js/wasm instead of c++)
circom init.circom --r1cs --wasm --sym

# view infos about the circuit
snarkjs r1cs info init.r1cs

# print the constraints
# snarkjs r1cs print init.r1cs init.sym

# export r1cs to json
snarkjs r1cs export json init.r1cs init.r1cs.json

# generate witness from our input arguments

echo "{\"x\": $1, \"y\": $2}" > 'input.json'
node init_js/generate_witness.js init_js/init.wasm input.json witness.wtns

# we use groth16 instead of plonk for the setup
# the phase 2 ceremony is almost the same as the one in phase 2, with zkey instad of ptau files
snarkjs groth16 setup init.r1cs pot12_final.ptau init_0000.zkey
snarkjs zkey contribute init_0000.zkey init_0001.zkey --name="First Contributor Name" -v -e="Another random ciao"
snarkjs zkey contribute init_0001.zkey init_0002.zkey --name="Second contribution Name" -v -e="Another random ciao ciao"

# verify the final key
snarkjs zkey verify init.r1cs pot12_final.ptau init_0002.zkey

# apply a random bracon
snarkjs zkey beacon init_0002.zkey init_final.zkey 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon phase 2"

# verify beacon key
snarkjs zkey verify init.r1cs pot12_final.ptau init_final.zkey

# export the verification key
snarkjs zkey export verificationkey init_final.zkey verification_key.json

# create the proof
snarkjs groth16 prove init_final.zkey witness.wtns proof.json public.json

# verify the proof
snarkjs groth16 verify verification_key.json public.json proof.json

# export the solidity contract
snarkjs zkey export solidityverifier init_0001.zkey verifier.sol

# print the params for the sc (use it in remix ide to test -> return true)
snarkjs generatecall # or snarkjs zkey export soliditycalldata public.json proof.json