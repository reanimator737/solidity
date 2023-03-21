// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Demo2 {
    address owner;
   
   constructor() {
       owner = msg.sender;
   }
    // -------------------------------------------------------------------------------------
    //Ивенты создают запись в журнале событий (хранитится не на блокчейне). На этот журнал можно подписатся извне.
    //Запись в журнал стоит дешевле. Смарт контракт доступа к журналу не имеет. Можно юзать его как бд
    //События можно индексировать для удобного поиска
    event NewTransaction(address indexed _from, uint _ammount, uint _timestamp);

    function pay() public payable{
       emit NewTransaction(msg.sender, msg.value, block.timestamp);
   }

    // -------------------------------------------------------------------------------------

    receive() external payable{
        pay();
    }

   function withdraw(address payable _to) external payable{
       require(msg.sender == owner, "U aren`t an owner");
       //Если условие не выполняется код дальше не пойдет
       _to.transfer(address(this).balance);
   }

     function withdraw2(address payable _to) external payable{
         if(msg.sender != owner){
            revert("U aren`t an owner");
         }
       //Если условие выполняется код дальше не пойдет
       _to.transfer(address(this).balance);
   }

     function withdraw3(address payable _to) external payable{
     assert(msg.sender == owner);
       //Если условие не выполняется код дальше не пойдет. Выкинет ошибку типа Panic.
       // Если честно хз зачем он вообще нужен
       _to.transfer(address(this).balance);
    }

    modifier onlyOwner(address payable _to) {
        require(msg.sender == owner, "U aren`t an owner");
        require(_to != address(0), "Empty address");
        //Это запись выхода из модификатора
        _;
    }

    //Тут кастомный модификатор onlyOwner сделает проверку сендера и отправителя, если не пройдет проверку до кода даже не дойдет
    function withdraw4(address payable _to) external payable onlyOwner(_to){
        _to.transfer(address(this).balance);
    }
}
