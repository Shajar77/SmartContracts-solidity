// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Crowdfunding {
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 goal;
        uint256 deadline;
        uint256 raised;
        bool approved;
        bool claimed;
        string image;
        mapping(address => uint256) contributions;
    }

    mapping(uint256 => Campaign) public campaigns;
    uint256 public campaignCount;

    address public owner;
    address public daoAddress;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier onlyDAO() {
        require(msg.sender == daoAddress, "Only DAO");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setDAOAddress(address _dao) external onlyOwner {
        daoAddress = _dao;
    }

    function createCampaign(
        string memory _title,
        string memory _description,
        uint256 _goal,
        uint256 _duration,
        string memory _image
    ) external {
        require(_goal > 0, "Goal must be > 0");

        campaignCount++;
        Campaign storage c = campaigns[campaignCount];
        c.owner = msg.sender;
        c.title = _title;
        c.description = _description;
        c.goal = _goal;
        c.deadline = block.timestamp + _duration;
        c.image = _image;
        c.approved = false;
        c.claimed = false;
    }

    function approveCampaign(uint256 _id) external onlyDAO {
        require(_id <= campaignCount, "Invalid ID");
        Campaign storage c = campaigns[_id];
        require(!c.approved, "Already approved");
        c.approved = true;
    }

    function fundCampaign(uint256 _id) external payable {
        require(_id <= campaignCount, "Invalid ID");
        Campaign storage c = campaigns[_id];
        require(c.approved, "Campaign not approved");
        require(block.timestamp < c.deadline, "Deadline passed");
        require(msg.value > 0, "Must send ETH");

        c.contributions[msg.sender] += msg.value;
        c.raised += msg.value;
    }

    function claimFunds(uint256 _id) external {
        Campaign storage c = campaigns[_id];
        require(msg.sender == c.owner, "Not owner");
        require(block.timestamp >= c.deadline, "Deadline not passed");
        require(c.raised >= c.goal, "Goal not met");
        require(!c.claimed, "Already claimed");

        c.claimed = true;
        payable(c.owner).transfer(c.raised);
    }

    function getContribution(uint256 _id, address _addr) external view returns (uint256) {
        return campaigns[_id].contributions[_addr];
    }

    function getCampaign(uint256 _id) external view returns (
        address, string memory, string memory,
        uint256, uint256, uint256,
        bool, bool, string memory
    ) {
        Campaign storage c = campaigns[_id];
        return (
            c.owner, c.title, c.description,
            c.goal, c.deadline, c.raised,
            c.approved, c.claimed, c.image
        );
    }
}
