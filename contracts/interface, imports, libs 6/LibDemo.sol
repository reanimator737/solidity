// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library StrExt{
    function eq(string memory str1, string memory str2) public pure returns(bool) {
        return keccak256(abi.encode(str1)) == keccak256(abi.encode(str1));
    }
}


contract LibDemo {
    using  StrExt for string;

    function runnerStr (string memory str1, string memory str2) public pure returns(bool){
        StrExt.eq(str1, str2);
        //одно и тоже
        return str1.eq(str2);
    }
}
