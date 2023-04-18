// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import './IERC20.sol';

contract ERC20 is IERC20 {
    uint totalTokens;
    address owner;
    mapping(address => uint ) balances;
    mapping(address => mapping(address => uint)) allowances;
    string _name;
    string _symbol;

    function name() external view returns(string memory){
        return _name;
    }

    function symbol()  external view returns(string memory){
        return _symbol;
    }

    function decimals()  external pure returns(uint){
        return 18; // 1 token = 1 wei
    }

    function totalSupply() external view returns(uint)  {
        return totalTokens;
    }



    modifier onlyOwner() {
        require(msg.sender == owner, "not an owner");
        _;
    }

    modifier enoughTokens(address _from, uint _amount){
        require(balanceOf(_from) >= _amount, "not enough tokens");
        _;
    }

    constructor(string memory name_, string memory symbol_, uint initialSupply, address shop) {
        _name = name_;
        _symbol = symbol_;
        owner = msg.sender;
        mint(initialSupply, shop);
    }

    function balanceOf(address account) public view returns(uint)  {
        return balances[account];
    }

    function mint(uint amount, address shop) public onlyOwner {
        balances[shop] += amount;
        totalTokens += amount;
        emit Transfer(address(0), shop, amount);
    }

    function transfer(address to, uint amount)  external enoughTokens(msg.sender, amount){
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function allowance(address _owner, address spender)  public view returns(uint){
               return allowances[_owner][spender];
    }

    function approve(address spender, uint amount)  public{
        allowances[msg.sender][spender] = amount;
        emit Approve(msg.sender, spender, amount);
    }

    function transferFrom(address sender,address recipient ,uint amount)  external enoughTokens(sender, amount){
        allowances[sender][recipient] -= amount; // если значение 0, то отняв любое число вылетит ошибка и ничего не произойдет
        balances[sender] -=amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function burn(address _from, uint amount) public onlyOwner enoughTokens(_from, amount){
        balances[_from] -= amount;
        totalTokens -= amount;
    }
}


contract RatToken is ERC20 {
    constructor(address shop) ERC20("RatToken", "Rat", 1000, shop){}

}

contract Rat20Shop {
    IERC20 public token;
    address  payable public owner;
    event Bought(uint _amount, address indexed _buyer);
    event Sold(uint _amount, address indexed _seller);

    modifier onlyOwner() {
        require(msg.sender == owner, "not an owner");
        _;
    }


    constructor() {
        token = new RatToken(address(this));
        owner = payable(msg.sender);
    }

    function sell(uint _amountToSell) external  {
        require(
        _amountToSell > 0 &&
        token.balanceOf(msg.sender) >= _amountToSell,
        "incorrect amount"
        );
        uint allowance = token.allowance(msg.sender, address(this));
        require(allowance >= _amountToSell, "check allowance");

        token.transferFrom(msg.sender, address(this), _amountToSell);

        payable(msg.sender).transfer(_amountToSell);

        emit Sold(_amountToSell, msg.sender);
    }

    receive() external payable{
        uint  tokensToBuy = msg.value; // 1token = 1 wei
        require(tokensToBuy > 0, 'not enough funds');

        require(tokenBalance() >= tokensToBuy, "not enough tokens");

        token.transfer(msg.sender, tokensToBuy);

        emit Bought(tokensToBuy, msg.sender);
    }

    function tokenBalance() public view returns(uint) {
      return  token.balanceOf(address(this));
    }

     function userBalance() public view returns(uint) {
      return  token.balanceOf(address(msg.sender));
    }
}