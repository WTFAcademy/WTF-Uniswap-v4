# Uniswap v4 Core v4.0.0

This project uses the official v4 Core release, pinned to commit
`e50237c43811bd9b526eff40f26772152a42daba`. From this directory, with Foundry v1.10.0:

```sh
git clone https://github.com/Uniswap/v4-core.git lib/v4-core
git -C lib/v4-core checkout e50237c43811bd9b526eff40f26772152a42daba
git -C lib/v4-core submodule update --init lib/solmate
forge test
```

The pinned upstream `PoolManager` uses Solidity 0.8.26 and the Cancun EVM.
The test deploys that contract locally, initializes a no-hook pool at a raw
price of 1, and calls `PoolManager.unlock` with the pool ID. The manager invokes
`unlockCallback` on the caller. The callback checks the sender, reads the pool
price and tick through `StateLibrary.getSlot0`, and returns them to the caller.

This callback reads state, so it has zero currency deltas when it returns.
Applications can read pool slots directly. When an application uses an unlock
session to swap or modify liquidity, it must settle every nonzero currency delta
before the callback returns.
