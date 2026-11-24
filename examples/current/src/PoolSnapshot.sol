// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {IUnlockCallback} from "v4-core/src/interfaces/callback/IUnlockCallback.sol";
import {StateLibrary} from "v4-core/src/libraries/StateLibrary.sol";
import {PoolId} from "v4-core/src/types/PoolId.sol";

contract PoolSnapshot is IUnlockCallback {
    using StateLibrary for IPoolManager;

    error CallerIsNotPoolManager();

    IPoolManager private immutable manager;

    constructor(IPoolManager manager_) {
        manager = manager_;
    }

    function snapshotInCallback(PoolId id) external returns (uint160 sqrtPriceX96, int24 tick) {
        bytes memory result = manager.unlock(abi.encode(id));
        return abi.decode(result, (uint160, int24));
    }

    function unlockCallback(bytes calldata data) external view returns (bytes memory) {
        if (msg.sender != address(manager)) revert CallerIsNotPoolManager();
        PoolId id = abi.decode(data, (PoolId));
        (uint160 sqrtPriceX96, int24 tick,,) = manager.getSlot0(id);
        return abi.encode(sqrtPriceX96, tick);
    }
}
