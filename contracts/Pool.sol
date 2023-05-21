// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import '../interface/IERC20.sol';
import "./Token.sol";

contract Pool {
    IERC20 token;
    uint totalPosts;
    event GenerateNewPost(uint indexed _id, address indexed _owner, uint value);

    struct Comment{
        address owner;

    }

    struct Post{
        uint value;
        bool isActive;
        uint createdAt;
        uint lifeTime;
    }

    mapping(address => mapping(int => Post)) usersPosts;

    constructor(){
        token = new SecretToken(msg.sender);
    }

    function createNewPost(uint _value, uint lifeTime) external {
        require(token.balanceOf(msg.sender) > _value && _value > 0, "incorrect value");
        uint allowance = token.allowance(msg.sender, address(this));
        require(allowance >= _value, "check allowance");
        token.transferFrom(msg.sender, address(this), _value);
        totalPosts += 1;
        emit GenerateNewPost(totalPosts, msg.sender, _value);
    }

    struct UserActivity {
        uint likes;
        uint dislikes;
        bool hasOwnerLike;
        address user;
    }

    function withdraw(uint _totalLikes, uint _totalDislikes, uint _totalOwnerLike, UserActivity[] memory _userActivity, Post memory _post) external{
        require(_post.createdAt - block.timestamp < _post.lifeTime, 'Too little time has passed');
        uint ownerLikeGives = _totalLikes / 2 > 5 ? _totalLikes / 2 : 5;
        uint total = _totalLikes - _totalDislikes + ownerLikeGives * _totalOwnerLike;

        for(uint i; i < _userActivity.length; i++){
            uint value = _userActivity[i].likes - _userActivity[i].dislikes + (_userActivity[i].hasOwnerLike ? ownerLikeGives : 0);
            token.transferFrom(_userActivity[i].user, address(this), value/total);
        }
    }
}
