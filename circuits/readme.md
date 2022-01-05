```sh
rm -rf circuit_* circuit.r1cs circuit.sym witness.wtns *.ptau *.zkey *.sol proof.json public.json verification_key.json \
  && circom circuit.circom --r1cs --wasm --sym --c \
  && node circuit_js/generate_witness.js circuit_js/circuit.wasm input.json witness.wtns \
  && snarkjs powersoftau new bn128 12 pot12_0000.ptau -v \
  && snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v \
  && snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v \
  && snarkjs groth16 setup circuit.r1cs pot12_final.ptau circuit_0000.zkey \
  && snarkjs groth16 setup circuit.r1cs pot12_final.ptau sample_0000.zkey \
  && snarkjs zkey contribute sample_0000.zkey sample_0001.zkey --name="1st Contributor Name" -v \
  && snarkjs zkey export verificationkey sample_0001.zkey verification_key.json \
  && snarkjs groth16 prove sample_0001.zkey witness.wtns proof.json public.json \
  && snarkjs zkey export solidityverifier sample_0001.zkey verifier.sol
```