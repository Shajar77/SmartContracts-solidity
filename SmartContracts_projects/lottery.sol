// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract lottery{
    address public owner;
    address payable[] public players;

    constructor(){owner = msg.sender;}

    function alreadyEntered() private view returns(bool){
        for(uint i=0;i<players.length;i++){
            if(players[i]==msg.sender){
                return true;
            }
        }
        return false;
        }

    function enter() public payable {
        require(msg.sender != owner,"Owner cannot participate");
        require(alreadyEntered() == false,"Already entered");
        require (msg.value >= 1 ether, "Entry must be paid");
        players.push(payable(msg.sender));
        }
    
    function random() private view returns(uint) {
      return uint(sha256(abi.encode(block.prevrandao,block.number,players)));
    }

    function pickwinner() public{
        require(msg.sender==owner,"Only owner can pick");
        uint index = random()%players.length;
        address ContractAddress= address(this);
        players[index].transfer(ContractAddress.balance);
        players= new address payable[] (0);
    }
    function getPlayers() public view returns(address payable [] memory){
        return players;
    }

}

