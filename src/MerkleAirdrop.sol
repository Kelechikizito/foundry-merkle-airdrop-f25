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
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title MerkleAirdrop
 * @author Kelechi Kizito Ugwu
 */
contract MerkleAirdrop is EIP712, ReentrancyGuard {
    // Some List of Addresses
    // Allow someone in the list to claim tokens

    ///////////////////////
    //   Libraries   /////
    ///////////////////////
    using SafeERC20 for IERC20;

    ///////////////////
    /// Errors      ///
    ///////////////////
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    //////////////////////////////
    /// Type Declarations      ///
    /////////////////////////////
    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    ////////////////////////
    //   State Variables  //
    ////////////////////////
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address claimer => bool claimed) private s_hasClaimed;
    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account,uint256 amount)");

    ////////////////////////
    //   Events        /////
    ////////////////////////
    event Claim(address indexed account, uint256 amount);

    ///////////////////
    //   Functions   //
    ///////////////////

    constructor(bytes32 merkleRoot, IERC20 airdropToken) EIP712("MerkleAirdrop", "1") {
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
     * @param v The recovery id of the signature.
     * @param r The r value of the signature.
     * @param s The s value of the signature.
     */
    function claim(address account, uint256 amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s)
        external
        nonReentrant
    {
        // CHECKS
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }

        if (!_isValidSignature(account, getMessageHash(account, amount), v, r, s)) {
            revert MerkleAirdrop__InvalidSignature();
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
    //   Private & Internal View Functions   //
    //////////////////////////////////////////
    /**
     * @notice Checks if the signature is valid for the given account and digest.
     * @param account The address of the account to check.
     * @param digest The hash of the message that was signed.
     * @param v The recovery id of the signature.
     * @param r The r value of the signature.
     * @param s The s value of the signature.
     * @return bool Returns true if the signature is valid, false otherwise.
     */
    function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s)
        internal
        pure
        returns (bool)
    {
        (address actualSigner,,) = ECDSA.tryRecover(digest, v, r, s);
        return actualSigner == account;
    }

    ///////////////////////////////////////////
    //   Public & External View Functions   //
    //////////////////////////////////////////
    /**
     * @notice Returns the hash of the message that is used for signing.
     * @param account The address of the account claiming tokens.
     * @param amount The amount of tokens to claim.
     * @return bytes32 Returns the hash of the message.
     */
    function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
        return
            _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount: amount}))));
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }
}
