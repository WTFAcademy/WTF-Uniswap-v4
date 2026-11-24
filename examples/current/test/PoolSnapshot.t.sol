// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {PoolManager} from "v4-core/src/PoolManager.sol";
import {Currency} from "v4-core/src/types/Currency.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {PoolSnapshot} from "../src/PoolSnapshot.sol";

contract PoolSnapshotTest {
    using PoolIdLibrary for PoolKey;

    function testReadsInitializedPoolInCallback() public {
        PoolManager manager = new PoolManager(address(this));
        PoolSnapshot reader = new PoolSnapshot(manager);
        PoolKey memory key = PoolKey({
            currency0: Currency.wrap(address(0)),
            currency1: Currency.wrap(address(0x1234)),
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(0))
        });

        uint160 price = uint160(1) << 96;
        int24 initialTick = manager.initialize(key, price);
        (uint160 actualPrice, int24 actualTick) = reader.snapshotInCallback(key.toId());

        require(actualPrice == price, "price");
        require(initialTick == 0 && actualTick == initialTick, "tick");
    }

    function testRejectsDirectCallback() public {
        PoolManager manager = new PoolManager(address(this));
        PoolSnapshot reader = new PoolSnapshot(manager);
        (bool ok, bytes memory result) =
            address(reader).call(abi.encodeCall(reader.unlockCallback, (abi.encode(PoolId.wrap(bytes32(0))))));

        require(!ok, "callback succeeded");
        require(bytes4(result) == PoolSnapshot.CallerIsNotPoolManager.selector, "wrong error");
    }
}
