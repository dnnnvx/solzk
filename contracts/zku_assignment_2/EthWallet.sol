// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

interface IMerkleTree {
    function verify(bytes32[] memory proof, bytes32 leaf, uint index, uint rootIndex) external pure returns (bool);
    function appendTx(bytes32 _hash) external;
}

contract EtherWallet {

    // 0x address of the owner
    address public owner;

    // 0x address of the external merkle tree
    address merkleTree;

    // event emitter for when receiving eth
    event Log(uint amount, uint gas);

    // set the ownership to the sc creator/deployer,
    // and save the 0x address of the external merkle tree
    // in order to use it to store the transactions
    constructor(address _merkleTree) {
        merkleTree = _merkleTree;
        owner = payable(msg.sender);
    }

    // general function to hash the tx data and store it in the
    // merkle tree using the interface utility in Solidity
    function storeTx(address _sender, address _receiver, uint256 _value) public {
        bytes32 hash = keccak256(abi.encodePacked(_sender, _receiver, _value));
        IMerkleTree(merkleTree).appendTx(hash);
    }

    // Anyone can send eth to the smart contract
    // and we store the tx in the merkle tree
    receive() external payable {
        storeTx(msg.sender, address(this), msg.value);
        emit Log(msg.value, gasleft());
    }

    // transfer out of the sc an amount of eth, only the owner can do it
    // and we store the tx in the merkle tree
    function send(address payable _to, uint _amount) external payable {
        require(msg.sender == owner, "caller is not owner");
        // I've use "transfer" instead of "send" for simplicity,
        // and it automatically revert the tx; I don't need to
        // return anything, like the bool of the send function.
        _to.transfer(_amount);
        storeTx(address(this), _to, _amount);
    }

    // the onwer can withdraw from the wallet
    // and obv we store the tx in the merkle tree
    function withdraw(uint _amount) external {
        require(msg.sender == owner, "caller is not owner");
        payable(msg.sender).transfer(_amount);
        storeTx(address(this), msg.sender, _amount);
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }
}
