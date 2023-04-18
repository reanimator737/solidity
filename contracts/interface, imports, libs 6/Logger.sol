// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Logger {
    mapping(address => uint[]) payments;
    function log(address _from, uint _amount) public {
        require(_from != address(0), "zero address");
        payments[_from].push(_amount);
    }

    function getEntry(address _from, uint _index) public view returns(uint){
        return  payments[_from][_index];
    }
}
