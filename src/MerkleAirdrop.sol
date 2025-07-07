// SPDX-License-Identifier: MIT

// Layout of the contract file:
// version
// imports
// interfaces, libraries, contract
// errors

// Inside Contract:
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private

// view & pure functions
pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 * @title MerkleAirdrop
 * @author Kelechi Kizito Ugwu
 * @dev This contract is a placeholder for a Merkle Airdrop implementation.
 * It currently does not contain any functionality.
 */
contract MerkleAirdrop {
    // Some List of Addresses
    // Allow someone in the list to claim tokens

    ///////////////////////
    //   Libraries    /////
    ///////////////////////
    using SafeERC20 for IERC20;

    ///////////////////
    /// Errors      ///
    ///////////////////
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();

    ////////////////////////
    //   State Variables  //
    ////////////////////////
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address claimer => bool claimed) private s_hasClaimed;

    ////////////////////////
    //   Events        /////
    ////////////////////////
    event Claim(address indexed account, uint256 amount);
    ///////////////////
    //   Functions   //
    ///////////////////

    constructor(bytes32 merkleRoot, IERC20 airdropToken) {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    ////////////////////////////
    //   External Functions   //
    ////////////////////////////
    /**
     * @notice Allows an account to claim tokens if they are in the Merkle tree. It follows the CEI pattern.
     * @param account The address of the account claiming tokens.
     * @param amount The amount of tokens to claim.
     * @param merkleProof The Merkle proof that verifies the account's eligibility.
     */
    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external {
        // CHECKS
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }

        // EFFECTS
        s_hasClaimed[account] = true;
        emit Claim(account, amount);

        // INTERACTIONS
        i_airdropToken.safeTransfer(account, amount);
    }

    ///////////////////////////////////////////
    //   Public & External View Functions   //
    //////////////////////////////////////////
    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }
}
