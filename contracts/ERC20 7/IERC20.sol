// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IERC20 {
    function name() external view returns(string memory);

    function symbol()  external view returns(string memory);

    function decimals()  external pure returns(uint);

    //req
    function totalSupply()  external view returns(uint);

    //req
    function balanceOf(address account)  external view returns(uint);

    //req
    function transfer(address to, uint amount)  external;

    //req
    function allowance(address _owner, address spender)  external view returns(uint);

    //req
    function approve(address spender, uint amount)  external;

    //req
    function transferFrom(address sender,address recipient ,uint amount)  external;

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approve(address indexed owner, address indexed to, uint amount);
}