# Uniswap v4 Core

[![Lint](https://github.com/Uniswap/v4-core/actions/workflows/lint.yml/badge.svg)](https://github.com/Uniswap/v4-core/actions/workflows/lint.yml)
[![Tests](https://github.com/Uniswap/v4-core/actions/workflows/tests.yml/badge.svg)](https://github.com/Uniswap/v4-core/actions/workflows/tests.yml)

Uniswap v4 is a new automated market maker protocol that provides extensible and customizable pools. `v4-core` hosts the core pool logic for creating pools and executing pool actions like swapping and providing liquidity.

This repository preserves a February 2024 draft of v4-core. The examples below use the interfaces and lock mechanism in this checkout.

## Contributing

If you’re interested in contributing please see our [contribution guidelines](./CONTRIBUTING.md)!

## Whitepaper

A more detailed description of Uniswap v4 Core can be found in the draft of the [Uniswap v4 Core Whitepaper](./docs/whitepaper-v4.pdf).

## Architecture

`v4-core` uses a singleton-style architecture, where all pool state is managed in the `PoolManager.sol` contract. Pool actions can be taken by acquiring a lock on the contract and implementing the `lockAcquired` callback to then proceed with any of the following actions on the pools:

- `swap`
- `modifyLiquidity`
- `donate`
- `take`
- `settle`
- `mint`
- `burn`

Only the net balances owed to the pool (positive) or to the user (negative) are tracked throughout the duration of a lock. `PoolManager.currencyDelta` records these balances by locker and currency. Any number of actions can be run on the pools, as long as the deltas accumulated during the lock reach zero before the outermost lock is released. This lock and call style architecture gives callers maximum flexibility in integrating with the core code.

Additionally, a pool may be initialized with a hook contract, that can implement any of the following callbacks in the lifecycle of pool actions:

- {before,after}Initialize
- {before,after}AddLiquidity
- {before,after}RemoveLiquidity
- {before,after}Swap
- {before,after}Donate

For pools configured with a dynamic swap fee, the hook implements `IDynamicFeeManager.getFee`.

The fee values, or callback logic, may be updated by the hooks dependent on their implementation. However _which_ callbacks are executed on a pool, including the type of fee or lack of fee, cannot change after pool initialization.

## Repository Structure

Core contracts are in [`src/`](./src/), test helpers are in [`src/test/`](./src/test/), and Foundry tests are in [`test/`](./test/).

## Local deployment and Usage

Use this checkout as the dependency and map `v4-core/` to its root. See the [setup instructions](./CONTRIBUTING.md#setup) to initialize the dependencies.

```solidity
import {IPoolManager} from 'v4-core/src/interfaces/IPoolManager.sol';
import {ILockCallback} from 'v4-core/src/interfaces/callback/ILockCallback.sol';

contract MyContract is ILockCallback {
    IPoolManager public immutable poolManager;

    constructor(IPoolManager manager) {
        poolManager = manager;
    }

    function doSomethingWithPools(bytes calldata data) external returns (bytes memory) {
        return poolManager.lock(address(this), data);
    }

    function lockAcquired(address lockCaller, bytes calldata data) external override returns (bytes memory) {
        require(msg.sender == address(poolManager) && lockCaller == address(this));
        // Perform pool actions and settle any outstanding deltas here.
        return data;
    }
}
```

## License

The primary license for Uniswap V4 Core is the Business Source License 1.1 (`BUSL-1.1`), see [LICENSE](https://github.com/Uniswap/v4-core/blob/main/LICENSE). Minus the following exceptions:

- Some [libraries](./src/libraries) have a GPL license
- Both [FullMath.sol](./src/libraries/FullMath.sol) and [Hooks.sol](./src/libraries/Hooks.sol) have an MIT License
- [Interfaces](./src/interfaces) and [types](./src/types/) have an MIT license

Each of these files states their license type.
