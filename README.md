## UniLender Protocol
UniLender is a money market that supports Uniswap V3 LP token as collateral.

### Deploy
```
anvil --fork-url=$ETH_RPC_URL
forge script script/Depoly.s.sol:DeployScript --fork-url http://localhost:8545 --broadcast -vvvv
```

