// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Все это называется модификатор

//public - можем вызвать из вне и внутри контракта
//external - можем вызвать из вне котракта
//internal - можем вызвать только изнутри и в наследовании
//private - можем вызвать только внутри смарт контракта, через наследование вызвать не можем

//view - функция может читать данные в блокчейне без модификации. Вызов работает через call и не стоит фи 
//pure - функция чистая и не умеет читать внешние данные


//payble - в функцию можно прислать деньги, деньги автоматически зачислятся на баланс ( если ничего не делать)

// returns(type)

contract Demo {
    //запись в блокчейн
    string message = "hello";

    //Обязательно делать external payable
    //Описание что делать с деньгами если они просто прелетели на адресс смарт контракта без указания метода
    receive() external payable{

    }

    //вызывается если у смартконтракта дернули не существующий метод
    fallback() external payable {

    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function getBalance2() public view returns(uint balance){
        balance = address(this).balance;
    }

    // Тут будет фи
    function setMassage(string memory newMessage) public {
        //запись в блокчейн
        message = newMessage;
    }

// view умеет читать переменные состояния, а вот pure нет
    //TypeError: Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".

//     function getMessage() external pure returns(string memory){
//         return message;
//     }
}