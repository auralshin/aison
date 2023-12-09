// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract TradeFinance is AccessControl {
    bytes32 public constant BANK_ROLE = keccak256("BANK_ROLE");
    bytes32 public constant BUYER_ROLE = keccak256("BUYER_ROLE");
    bytes32 public constant SELLER_ROLE = keccak256("SELLER_ROLE");
    bytes32 public constant FINANCIER_ROLE = keccak256("FINANCIER_ROLE");

    struct Trade {
        uint256 tradeId;
        bytes32 merkleRoot;
        string documentID;
        bytes32[] merkleProof;
        bool isVerified;
        bool isSettled;
    }

    uint256 private nextTradeId = 1;
    mapping(uint256 => Trade) public trades;

    event TradeCreated(uint256 indexed tradeId);
    event TradeVerified(uint256 indexed tradeId);
    event RoleGranted(bytes32 indexed role, address indexed account);
    event TradeSettled(uint256 indexed tradeId);
    event TradeUpdated(uint256 indexed tradeId);
    event DisputeRaised(uint256 indexed tradeId, string reason);
    event DisputeResolved(uint256 indexed tradeId);
    event PaymentMade(uint256 indexed tradeId, uint256 amount, address by);

    constructor(address initialOwner) {
        _grantRole(DEFAULT_ADMIN_ROLE, initialOwner);
    }

    function createTrade(
        bytes32 _merkleRoot,
        string memory _documentID,
        bytes32[] memory _merkleProof
    ) public {
        trades[nextTradeId] = Trade({
            tradeId: nextTradeId,
            merkleRoot: _merkleRoot,
            documentID: _documentID,
            merkleProof: _merkleProof,
            isVerified: false,
            isSettled: false
        });

        emit TradeCreated(nextTradeId);
        nextTradeId++;
    }

    function verifyTradeDocument(uint256 _tradeId) public {
        Trade storage trade = trades[_tradeId];
        require(_tradeId > 0, "Trade ID must be greater than zero.");
        require(!trade.isVerified, "Trade document already verified.");

        bytes32 leaf = keccak256(abi.encodePacked(trade.documentID));
        require(
            MerkleProof.verify(trade.merkleProof, trade.merkleRoot, leaf),
            "Invalid Merkle proof."
        );

        trade.isVerified = true;
        emit TradeVerified(_tradeId);
    }

    // Access Control Management
    function addBankRole(address _bank) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(BANK_ROLE, _bank);
        emit RoleGranted(BANK_ROLE, _bank);
    }

    function addBuyerRole(address _buyer) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(BUYER_ROLE, _buyer);
        emit RoleGranted(BUYER_ROLE, _buyer);
    }

    function addSellerRole(
        address _seller
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(SELLER_ROLE, _seller);
        emit RoleGranted(SELLER_ROLE, _seller);
    }

    function addFinancierRole(
        address _financier
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(FINANCIER_ROLE, _financier);
        emit RoleGranted(FINANCIER_ROLE, _financier);
    }

    function settleTrade(uint256 _tradeId) public onlyRole(BANK_ROLE) {
        Trade storage trade = trades[_tradeId];
        require(
            trade.isVerified,
            "Trade must be verified before it can be settled."
        );
        require(!trade.isSettled, "Trade is already settled.");

        // Here you would implement the logic to transfer funds or assets as per trade agreement
        // For example, transferring tokens if using a cryptocurrency

        trade.isSettled = true;
        emit TradeSettled(_tradeId);
    }

    function updateTrade(
        uint256 _tradeId,
        bytes32 _newMerkleRoot,
        string calldata _newDocumentID,
        bytes32[] calldata _newMerkleProof
    ) public {
        Trade storage trade = trades[_tradeId];
        require(
            hasRole(SELLER_ROLE, msg.sender) || hasRole(BANK_ROLE, msg.sender),
            "Only the seller or bank can update the trade."
        );
        require(!trade.isVerified, "Verified trades cannot be updated.");

        trade.merkleRoot = _newMerkleRoot;
        trade.documentID = _newDocumentID;
        trade.merkleProof = _newMerkleProof;

        emit TradeUpdated(_tradeId);
    }

    function raiseDispute(uint256 _tradeId, string memory reason) public {
        require(
            hasRole(BUYER_ROLE, msg.sender) || hasRole(SELLER_ROLE, msg.sender),
            "Only buyer or seller can raise a dispute."
        );

        // Logic for raising a dispute
        // This can include pausing the trade, notifying other parties, etc.

        emit DisputeRaised(_tradeId, reason);
    }

    function resolveDispute(uint256 _tradeId) public onlyRole(BANK_ROLE) {
        // Logic for resolving the dispute
        // This can include unpausing the trade, making necessary adjustments, etc.

        emit DisputeResolved(_tradeId);
    }

    function makePayment(uint256 _tradeId, uint256 _amount) public payable {
        Trade storage trade = trades[_tradeId];
        require(
            hasRole(BUYER_ROLE, msg.sender),
            "Only the buyer can make payments."
        );

        
        // Logic to handle payments
        // This can include transferring cryptocurrency or tokens to the seller or an escrow

        emit PaymentMade(_tradeId, _amount, msg.sender);
    }
}
