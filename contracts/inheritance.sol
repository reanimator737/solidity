// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Ownable {
    address owner;
    constructor(address _owner){
        owner = _owner == address(0) ? _owner : msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "not an owner");
        _;
    }

    function withdraw(address payable _to ) public virtual onlyOwner {
        //payable(owner).transfer(address(this).balance);
    }
}

//Абстрактный контракт нельзя развернуть, но множно наследоватся.
abstract contract Balances is Ownable{
    function getBalance() public view onlyOwner returns(uint){
        return address(this).balance;
    }

    function withdraw(address payable _to ) public override virtual onlyOwner {
        _to.transfer(address(this).balance);
    }
}

//Самый высокоуровневый контракт стоит на 1 месте и далее по цепочке

//Значение адресса пробросит в конструктор Ownable
contract Inheritance is Ownable(0xcBbCEB2C58a4eacF971c09D0c8CdD10f5923f01B), Balances{

    function withdraw(address payable _to ) public override(Ownable,Balances )  onlyOwner {
        Balances.withdraw(_to);
        //super поднимается на 1 порядок выше и триггерит метод из Balances. То бишь это 1 и тоже
        super.withdraw(_to);
    }
}

contract Inheritance2 is Ownable, Balances{

    constructor(address _owner) Ownable(_owner){

    }

  function withdraw(address payable _to ) public override(Ownable,Balances )  onlyOwner {
        Balances.withdraw(_to);
        //super поднимается на 1 порядок выше и триггерит метод из Balances. То бишь это 1 и тоже
        super.withdraw(_to);
    }

}
/////////////////////////////////////////////////////////////////////////////

contract Ownable2 {
    address owner;
    constructor(){
        owner =  msg.sender;
    }
}

contract Inheritance3 is Ownable, Balances{
    constructor(address _owner) Ownable(_owner){
        //Но так дороже, да и ошибку возвращает.
        owner = _owner;
    }

    
    function withdraw(address payable _to ) public override(Ownable,Balances )  onlyOwner {
        Balances.withdraw(_to);
        //super поднимается на 1 порядок выше и триггерит метод из Balances. То бишь это 1 и тоже
        super.withdraw(_to);
    }

}