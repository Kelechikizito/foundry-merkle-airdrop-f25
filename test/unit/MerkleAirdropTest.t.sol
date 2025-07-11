// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {BagelToken} from "src/BagelToken.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol"; // If using foundry-devops
import {DeployMerkleAirdrop} from "script/DeployMerkleAirdrop.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    MerkleAirdrop public airdrop;
    BagelToken public token;

    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;
    bytes32 proofElementOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofElementTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [proofElementOne, proofElementTwo];
    address public gasPayer;
    address user;
    uint256 userPrivKey;

    function setUp() public {
        if (!isZkSyncChain()) {
            // This check is from ZkSyncChainChecker
            // Deploy with the script
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.deployMerkleAirdrop();
        } else {
            token = new BagelToken();
            airdrop = new MerkleAirdrop(ROOT, token);
            token.mint(token.owner(), AMOUNT_TO_SEND);
            token.transfer(address(airdrop), AMOUNT_TO_SEND);
        }
        (user, userPrivKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    ///////////////////////////////////////////
    //   Airdrop Claim Function Tests   //
    //////////////////////////////////////////
    function testUsersCanClaim() public {
        // ARRANGE
        uint256 startingBalance = token.balanceOf(user);
        console.log(address(user));
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);

        // ACT
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest);

        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);
        uint256 endingBalance = token.balanceOf(user);
        console.log("Ending Balance: ", endingBalance);

        // ASSERT
        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }

    function testUsersCannotClaimTwice() public {
        // ARRANGE / ACT
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest);
        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);

        // ASSERT
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__AlreadyClaimed.selector);
        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);
    }

    function testRevertIfInvalidProof() public {
        // ARRANGE
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM + AMOUNT_TO_CLAIM);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest);

        // ACT / ASSERT
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__InvalidProof.selector);
        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM + AMOUNT_TO_CLAIM, PROOF, v, r, s);
    }

    function testRevertsIfInvalidSignature() public {
        // ARRANGE
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest);
        address invalidUser = makeAddr("invalidUser");

        // ACT / ASSERT
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__InvalidSignature.selector);
        vm.prank(gasPayer);
        airdrop.claim(invalidUser, AMOUNT_TO_CLAIM, PROOF, v, r, s);
    }

    ///////////////////////////////////////////
    //  Getter Functions Tests               //
    //////////////////////////////////////////
    function testGetMerkleRoot() public view {
        // ASSERT
        assertEq(airdrop.getMerkleRoot(), ROOT);
    }

    function testGetAirdropToken() public view {
        // ASSERT
        assertEq(address(airdrop.getAirdropToken()), address(token));
    }
}
