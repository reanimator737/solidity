// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import './ILogger.sol';

abstract contract Demo is ILogger{
    ILogger logger;

    constructor(address _logger){
        logger = ILogger(_logger);
    }

    function payment(address _from, uint _number) public view returns(uint){
        return logger.getEntry(_from, _number);
    }

    receive() external payable{
        //call to log smartcontract
        logger.log(msg.sender, msg.value);
    }

}