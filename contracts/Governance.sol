// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Governance Contract
 * @dev Manages proposals and voting for Empoweria.
 */

import "@openzeppelin/contracts/access/Ownable.sol";
import "./EmpoweriaToken.sol";

contract Governance is Ownable {
    EmpoweriaToken public token;

    struct Proposal {
        uint256 id;
        string description;
        uint256 voteCount;
        bool executed;
        mapping(address => bool) voters;
    }

    uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;

    event ProposalCreated(uint256 indexed id, string description);
    event Voted(address indexed voter, uint256 indexed proposalId, uint256 voteWeight);
    event ProposalExecuted(uint256 indexed id);

    constructor(address tokenAddress) {
        token = EmpoweriaToken(tokenAddress);
    }

    /**
     * @dev Allows KYC-verified token holders to create proposals.
     */
    function createProposal(string memory description) external {
        require(token.isKYCVerified(msg.sender), "Not KYC verified");

        proposalCount++;
        Proposal storage proposal = proposals[proposalCount];
        proposal.id = proposalCount;
        proposal.description = description;

        emit ProposalCreated(proposal.id, description);
    }

    /**
     * @dev Allows token holders to vote on proposals.
     */
    function vote(uint256 proposalId, uint256 voteWeight) external {
        require(token.isKYCVerified(msg.sender), "Not KYC verified");
        require(proposals[proposalId].id != 0, "Proposal does not exist");
        require(!proposals[proposalId].voters[msg.sender], "Already voted");
        require(
            voteWeight <= token.votingPower(msg.sender),
            "Insufficient voting power"
        );

        proposals[proposalId].voteCount += voteWeight;
        proposals[proposalId].voters[msg.sender] = true;

        emit Voted(msg.sender, proposalId, voteWeight);
    }

    /**
     * @dev Executes a proposal if certain conditions are met.
     */
    function executeProposal(uint256 proposalId) external onlyOwner {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.id != 0, "Proposal does not exist");
        require(!proposal.executed, "Proposal already executed");

        // Implement execution logic here
        proposal.executed = true;

        emit ProposalExecuted(proposalId);
    }
}
