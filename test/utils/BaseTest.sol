// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";

contract BaseTest is Test {
    function setUp() public virtual {
        // run the pre setup hook
        preSetupHook();

        // run the post setup hook
        postSetupHook();
    }

    function testRun() public {
        // run the exploit
        runExploit();

        // verify the exploit
        runCheckCompletion();
    }

    function preSetupHook() internal virtual {
        /* IMPLEMENT YOUR POST SETUP */
    }

    function postSetupHook() internal virtual {
        /* IMPLEMENT YOUR POST SETUP */
    }

    function runExploit() internal virtual {
        /* IMPLEMENT YOUR EXPLOIT */
    }

    function runCheckCompletion() internal virtual {
        /* IMPLEMENT YOUR EXPLOIT */
    }
}
