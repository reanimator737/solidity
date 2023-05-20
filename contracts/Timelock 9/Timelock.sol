// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Timelock {
    address public owner;
    uint constant MINIMAL_DELAY =  1 hours;
    uint constant MAXIMAL_DELAY =  1 days;

    mapping( bytes32 => bool) public queue;


    event Queued(address _to, string _func, bytes _data, uint _value, uint _timestamp, bytes32 indexed _txId);
    event Discarded(bytes32 indexed _txId);


    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(){
        owner = msg.sender;
    }


    function addToQueue(address _to, string calldata _func, bytes _data, uint _value, uint _timestamp) external onlyOwner returns(bytes32)  {
        require(_timestamp > block.timestamp + MINIMAL_DELAY && _timestamp < block.timestamp + MINIMAL_DELAY, "invalid timestamp");
        bytes32 txId = keccak256(abi.encode(_to, _func,_data, _value, _timestamp));
        require(!queue[txId], "already queued");
        emit Queued(_to, _func, _data, _value, _timestamp, _txId);
        return txId;
    }

    function discard(bytes32 _txId) external onlyOwner  {
        require(queue[_txId], "not queued");
        delete queue[_txId];
        emit Discarded(_txId);
    }


    function exicute(address _to, string calldata _func, bytes _data, uint _value, uint _timestamp) payable external onlyOwner returns(bytes memory)  {
        require(_timestamp > block.timestamp + MINIMAL_DELAY && _timestamp < block.timestamp + MINIMAL_DELAY, "invalid timestamp");
        bytes32 txId = keccak256(abi.encode(_to, _func,_data, _value, _timestamp));
        require(queue[txId], "not queued");

        bytes memory data;

        if (bytes(_func).length > 0){
            data = abi.encodePacked(bytes4(keccak56(bytes(_func))), _data);
        } else {
            data = _data;
        }

        (bool success, bytes memory resp) = _to.call{value: _value}(data);
        require(success, "smth go wrong");

        return resp;
    }
}
