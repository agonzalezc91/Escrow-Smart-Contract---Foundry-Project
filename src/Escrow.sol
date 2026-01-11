// SPDX-License-Identifier: MIT

// solidity version
pragma solidity 0.8.30;

// Contract

error NotBuyer();
error WrongAmount();
error InvalidState();
error TransferFailed();

contract Escrow {

    // variables
    address public buyer;
    address public seller;
    uint256 public transactAmount;
    bool public funded;
    bool public completed;

    // events
    event Deposited(address buyer, uint256 transactAmount);
    event Released(address seller, uint256 transactAmount);
    event Refunded(address buyer, uint256 transactAmount);

    // constructor
    constructor(address buyer_, address seller_, uint256 transactAmount_) {
        require(buyer_ != address(0), "Zero Buyer");
        require(seller_ != address(0), "Zero Seller");
        require(buyer_ != seller_, "Same Address");
        require((transactAmount_ > 0), "Amount Zero");
        
        buyer = buyer_;
        seller = seller_;
        transactAmount = transactAmount_;
    }

    // Modifiers
    modifier onlyBuyer() {
        if(msg.sender != buyer) revert NotBuyer();
        _;
    }

    // functions
    // Buyer deposits the exact ETH amount

    function deposit() public payable onlyBuyer {
        if(funded == true || completed == true) revert InvalidState();
        if(msg.value != transactAmount) revert WrongAmount();

        funded = true;
        emit Deposited(msg.sender, msg.value);
    }

    // Buyer confirms service/goods were provided. Then, release ETH to seller
    function release() public onlyBuyer {
        if(funded == false || completed == true) revert InvalidState();

        completed = true;

        (bool ok, ) = payable(seller).call{value: transactAmount}("");
        if(!ok) revert TransferFailed();

        emit Released(seller, transactAmount);
    }

    // Buyer cancels and gets refund
    function refund() public onlyBuyer {
        if(funded == false || completed == true) revert InvalidState();

        completed = true;

        (bool ok, ) = payable(buyer).call{value: transactAmount}("");
        if(!ok) revert TransferFailed();

        emit Refunded(buyer, transactAmount);
    }
}