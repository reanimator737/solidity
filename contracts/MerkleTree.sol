// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


//Merkle tree - это дерево хешей. В классической вариации требует 2^n листьев.
//Никто не запращает использовать модификации. Нужно для пруфа транзакций
contract MerkleTree {
    bytes32[] public tree;
    string[4] data = [
        "1",
        "2",
        "3",
        "4"
    ];

    constructor(){
        for (uint i = 0; i < data.length; i++){
         tree.push(
             keccak256(
                 abi.encodePacked(data[i])
             ));
        }
        uint shift = 0;
        uint step = data.length;

        while(step != 1) {
            for (uint i = 0; i < step - 1; i += 2){
                tree.push(
                    keccak256(
                        abi.encodePacked(
                            tree[i+shift], tree[i+shift+1])
                    ));
            }
            shift += step;
            step = step / 2;
        }
    }

    function verify(string memory transaction, uint index, bytes32 root, bytes32[] memory proof) public pure returns(bool) {
        bytes32 hash = keccak256(abi.encodePacked(transaction));
        for(uint i = 0; i < proof.length; i++) {
            bytes32 element = proof[i];
            if(index % 2 == 0) {
                hash = keccak256(abi.encodePacked(hash, element));
            } else {
                hash = keccak256(abi.encodePacked(element, hash));
            }
            index = index / 2;
        }
        return hash == root;
    }
}

