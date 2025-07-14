## 📦 Foundry Merkle Airdrop

**Core Purpose:**
A sophisticated airdrop smart contract using Foundry. An efficient system for token distribution that allows for eligibility verification via Merkle proofs and authorized, potentially gasless, claims using cryptographic signatures.

---

### 🔑 Key Features

* **ERC-20 Support**: Compatible with any standard ERC-20 token.
* **Merkle Proof Verification**: Automatically generated Merkle tree via [Murky](https://github.com/dmfxyz/murky) `makemerkle` script.
* **Signature-Based Claims**: Uses EIP-712 signatures (`v, r, s`) from OpenZeppelin to authorize third-party claim execution on behalf of original recipients.
* **Gas Sponsorship Ready**: Claimants can delegate gas payment to a relayer.

---

### 🛠️ Tech Stack & Dependencies

* **Foundry** — Solidity development toolkit for compiling, testing, and scripting.
* **foundry-devops** — Deployment and scripting utilities from Cyfrin Updraft via Foundry-DevOps.
* **Murky** — Merkle tree generation and proof tooling (`makemerkle`).
* **OpenZeppelin Contracts** — EIP-712 and ERC-20 implementations.

---

### 🤔 Next Step

To continue, could you share the **installation and setup** steps you followed? (e.g., cloning the repo, installing dependencies)
