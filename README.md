# Foundry Merkle Airdrop

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

A sophisticated airdrop smart contract using Foundry. Our goal is to build an efficient system for token distribution that allows for eligibility verification via Merkle proofs and authorized, potentially gasless, claims using cryptographic signatures.

---

## Table of Contents

- [Foundry Merkle Airdrop](#foundry-merkle-airdrop)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Motivation \& Problem](#motivation--problem)
  - [Tech Stack](#tech-stack)
  - [Key Features](#key-features)
  - [Testing](#testing)
  - [Security Considerations](#security-considerations)
  - [License](#license)

---

## Overview

This project implements a **Merkle‑based airdrop** using Foundry. It lets you:

* Verify user eligibility with **Merkle proofs** (instead of large on‑chain arrays).
* Authenticate claims via **EIP‑712 signatures**, enabling gas sponsors (relayers) to pay fees.
* Prevent double‑claims and ensure only authorized recipients receive tokens.

---

## Motivation & Problem

Airdrops traditionally use arrays of addresses on‑chain, which can be expensive and unwieldy. By combining Merkle trees and off‑chain signatures, this contract:

* **Reduces gas costs** by storing only a single Merkle root on‑chain.
* **Prevents ineligible or duplicate claims** via cryptographic proofs and signature checks.
* **Enables gasless UX**, where a third‑party relayer can submit the claim transaction on behalf of the user.

This was built as a proof‑of‑concept following Ciara Nightingale’s [Cyfrin Updraft tutorial](https://github.com/ciaranightingale).

---

## Tech Stack

* **Solidity ^0.8.24**
* **Foundry** (`forge-std`, `forge script`) for development, scripting, and testing
* **OpenZeppelin** for ERC‑20, `ECDSA`, `EIP712`, and `ReentrancyGuard`
* **Murky** for generating Merkle trees, leaves, and proofs

---

## Key Features

* **Merkle‑Proof Eligibility**: Verify accounts and amounts against a single on‑chain Merkle root.
* **EIP‑712 Signature Authentication**: Off‑chain signing of structured claim messages ensures claim authenticity.
* **Gas Sponsorship (Meta‑Transactions)**: Any relayer can pay gas to submit a user’s claim.
* **Double‑Claim Prevention**: Tracks claimed addresses to prevent repeat redemptions.

---

## Testing

* **Unit tests** cover:

  * Merkle proof verification and edge cases
  * EIP‑712 digest creation and signature recovery
  * Double‑claim and invalid‑proof reverts
* **Foundry scripts** emulate deployment and gas‑sponsored claims

Tests live in `test/MerkleAirdropTest.sol` and run via:

```bash
forge test -vv
```

---

## Security Considerations

* **ReentrancyGuard** protects critical claim logic
* Claims require both valid Merkle proof **and** valid signature
* On‑chain state tracks claimed addresses to prevent reuse
* Proofs and signatures must match off‑chain generated Merkle tree and EIP‑712 domain

---

## License

This project is licensed under the MIT License.
