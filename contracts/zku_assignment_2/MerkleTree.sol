// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

contract MerkleTree {

    // array of out transactions hashes, always between 0 and 8
    bytes32[] hashes;

    // array of our roots, every hash is the root of 8 transactions
    bytes32[] roots;

    // we decided that a merkle tree can store 8 transactions
    uint8 MAX_TX = 8;

    // verify function to prove that a tx is present in one of our merkle trees
    // so we need to provided the minimum amount of proof, leaf, index and root index
    // to retrieve our root hash in our stored roots array
    function verify(bytes32[] memory proof, bytes32 leaf, uint index, uint rootIndex) public view returns (bool) {
        bytes32 hash = leaf;
        for (uint i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (index % 2 == 0) {
                hash = keccak256(abi.encodePacked(hash, proofElement));
            } else {
                hash = keccak256(abi.encodePacked(proofElement, hash));
            }
            index = index / 2;
        }
        return hash == roots[rootIndex];
    }

    // append the tx to the list and if we reach the 8th one, we build
    // the tree and store the root in our roots list
    function appendTx(bytes32 _hash) public {
        hashes.push(_hash);
        uint n = hashes.length;
        uint offset = 0;
        // if our txs list has 8 txs, we build the tree
        if (n == MAX_TX) {
            while (n > 0) {
                for (uint i = 0; i < n-1; i += 2) {
                    hashes.push(keccak256(abi.encodePacked(hashes[offset+i], hashes[offset+i+1])));
                }
                offset += n;
                n = n/2;
            }
            // when we have finally reached the root element, we store the root hash in our array
            roots.push(hashes[hashes.length - 1]);
            // we can empty the txs list in order to start again from zero, and reach the next 8 txs
            delete hashes;
        }
    }

    function getRoot(uint _index) external view returns (bytes32) {
        return roots[_index];
    }

    function getNumberOfRoots() external view returns (uint) {
        return roots.length;
    }

    function getCurrentNumOfTx() external view returns (uint) {
        return hashes.length;
    }
}