// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
//We use this pattern when we need to create a vote in which it is not clear what the vote is for until a certain point.
//To do this, we hash vote on the front-end, and then already decoded data comes from the front, which we hash and verify. Thus, nothing can be faked.
contract CommitReveal {
    address[] public CANDIDATES;
    uint public immutable START_AT;
    uint public immutable  VOTING_TIME;

    mapping(address => bytes32) listOfVote;
    mapping(address => uint)  votes;


    constructor(uint _time, address[] memory _candidates ){
        START_AT = block.timestamp;
        VOTING_TIME = _time;
        require(_candidates.length > 2, "Need more candidates");
        for (uint i = 0; i < _candidates.length; i++){
            CANDIDATES.push(_candidates[i]);
        }


    }

    //hash from front-end ethers.utils.solidityKeccak256(['address', bytes32, 'address'], [candidate, 'salt' in bytecode, msg.sender])
    //Same that keccak256(abi.encodePacked())
    function addVote(bytes32 _hash) external {
        require(block.timestamp < START_AT + VOTING_TIME, "Voting stopped");
        require(listOfVote[msg.sender] == bytes32(0), "Already voted");
        listOfVote[msg.sender] = _hash;
    }

    function removeVote() external  {
        require(listOfVote[msg.sender] != bytes32(0), "You haven`t voted yet");
        delete listOfVote[msg.sender];
    }

    function revealVote(address candidate, bytes32 salt ) external  {
        require(block.timestamp >= START_AT + VOTING_TIME, "Time has not yet come");
        require(listOfVote[msg.sender] != bytes32(0), "You haven`t voted yet");
        bytes32 hash = keccak256(abi.encodePacked(candidate, salt, msg.sender));
        require(hash == listOfVote[msg.sender], "Data did not match");
        delete listOfVote[msg.sender];
        votes[candidate]++;
    }
}
