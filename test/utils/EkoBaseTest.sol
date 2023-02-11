// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./BaseTest.sol";

import "src/ChallengeFactory.sol";

contract EkoBaseTest is BaseTest {
    address player;
    ChallengeFactory factory;
    address[] challenges;

    function preSetupHook() internal virtual override {
        // Init the challenge
        player = makeAddr("player");
    }

    function runCheckCompletion() internal override {
        assertTrue(factory.isComplete(challenges), "challenge not completed!");
    }
}
