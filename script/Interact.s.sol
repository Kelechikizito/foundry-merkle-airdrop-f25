// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";

contract ClaimAirdrop is Script {
    error ClaimAirdrop__InvalidSignatureLength();

    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 CLAIMING_AMOUNT = 25 * 1e18;
    bytes32 proofElementOne = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 proofElementTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] proof = [proofElementOne, proofElementTwo];
    bytes private SIGNATURE =
        hex"12e145324b60cd4d302bfad59f72946d45ffad8b9fd608e672fd7f02029de7c438cfa0b8251ea803f361522da811406d441df04ee99c3dc7d65f8550e12be2ca1c";

    function claimAirdrop(address airdropContractAddress) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE); // Using 0 as the private key for simplicity, r
        MerkleAirdrop(airdropContractAddress).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, proof, v, r, s); // I DIDN'T KNOW WE COULD USE A CONTRACT LIKE THIS ALMOST LIKE AN INTERFACE, GOOGLE OTHER WAYS YOU CAN USE IT W/O INSTANTIATING IT

        vm.stopBroadcast();
    }

    /**
     * @notice Splits a 65-byte concatenated signature (r, s, v) into its components.
     * @param sig The concatenated signature as bytes.
     * @return v The recovery identifier (1 byte).
     * @return r The r value of the signature (32 bytes).
     * @return s The s value of the signature (32 bytes).
     */
    function splitSignature(bytes memory sig) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        // Standard ECDSA signatures are 65 bytes long:
        // r (32 bytes) + s (32 bytes) + v (1 byte)
        if (sig.length != 65) {
            revert ClaimAirdrop__InvalidSignatureLength();
        }
        // Accessing bytes data in assembly requires careful memory management.
        // `sig` in assembly points to the length of the byte array.
        // The actual data starts 32 bytes after this pointer.
        assembly {
            // Load the first 32 bytes (r)
            r := mload(add(sig, 0x20)) // 0x20 is 32 in hexadecimal
            // Load the next 32 bytes (s)
            s := mload(add(sig, 0x40)) // 0x40 is 64 in hexadecimal
            // Load the last byte (v)
            // v is the first byte of the 32-byte word starting at offset 96 (0x60)
            v := byte(0, mload(add(sig, 0x60))) // 0x60 is 96 in hexadecimal
        }
        // Note: Further adjustment to 'v' might be needed depending on the signing library/scheme (see section below).
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(mostRecentlyDeployed);
    }
}
