# Escrow Smart Contract — Foundry Project

This repository contains a simple **Escrow smart contract** written in Solidity and fully tested using **Foundry**.

The project demonstrates core smart contract concepts such as access control, ETH handling, state management, custom errors, unit testing, and fuzz testing.

---

## Contract Overview

The `Escrow` contract implements a basic escrow mechanism between a **buyer** and a **seller**:

- The buyer deposits an exact amount of ETH into the contract
- The ETH is locked until the buyer either:
  - releases the funds to the seller, or
  - cancels the deal and receives a refund

Only the buyer can interact with the escrow lifecycle.

---

## Roles

- **Buyer**
  - Deposits ETH
  - Releases funds to the seller
  - Requests a refund

- **Seller**
  - Receives ETH only if the buyer releases the funds

---

## State Variables

- `buyer`: address allowed to control the escrow
- `seller`: address that receives the ETH on release
- `transactAmount`: exact ETH amount required for the deposit
- `funded`: indicates whether the escrow has been funded
- `completed`: indicates whether the escrow has been finalized

---

## Contract Functions

### `deposit()` (payable)
- Can only be called by the buyer
- Requires the exact `transactAmount`
- Reverts if:
  - caller is not the buyer
  - escrow is already funded or completed
  - incorrect ETH amount is sent
- Marks the escrow as funded

### `release()`
- Can only be called by the buyer
- Requires the escrow to be funded and not completed
- Transfers ETH to the seller
- Marks the escrow as completed

### `refund()`
- Can only be called by the buyer
- Requires the escrow to be funded and not completed
- Refunds ETH back to the buyer
- Marks the escrow as completed

---

## Events

- `Deposited(address buyer, uint256 amount)`
- `Released(address seller, uint256 amount)`
- `Refunded(address buyer, uint256 amount)`

---

## Error Handling

The contract uses **custom errors** for gas-efficient reverts:

- `NotBuyer`
- `WrongAmount`
- `InvalidState`
- `TransferFailed`

---

## Testing (Foundry)

The project includes **unit tests and fuzz tests** written using Foundry.

### Unit Tests Covered

- Correct initialization of `transactAmount`
- Successful deposit by the buyer with the correct amount
- Deposit reverts if the caller is not the buyer
- Release reverts if called by a non-buyer
- Successful release updates state and transfers ETH
- Refund reverts if called by a non-buyer
- Successful refund updates state and returns ETH
- Escrow cannot be both released and refunded

---

### Fuzz Tests Covered

- Deposit reverts for any ETH amount different from `transactAmount`
- Deposit reverts for any address different from the buyer
- Escrow cannot be funded more than once

Fuzz tests are used to validate contract behavior across a wide range of inputs and edge cases.

---

## Project Structure

src/
└── Escrow.sol

test/
└── EscrowTest.t.sol

foundry.toml
README.md

---

## Running the Tests

Install Foundry:
https://book.getfoundry.sh/

Run all unit and fuzz tests:
forge test

Run fuzz tests with increased iterations:
forge test --fuzz-runs 1000

---

## Notes

- This contract is intentionally minimal and designed for learning purposes
- No arbiter or third-party dispute resolution is included
- ETH transfers use low-level `.call` with explicit success checks

---

## Author

Personal learning project focused on **Solidity smart contract development and testing with Foundry**.

