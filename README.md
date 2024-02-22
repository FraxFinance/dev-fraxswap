# Frax Template

## Optional Setup
Add:
```
function profile() {
  FOUNDRY_PROFILE=$1 "${@:2}"}
```
To easily execute specific foundry profiles like `profile test forge test -w`

## Installation
`pnpm i`

## Compile
`forge build`

## Test
`profile test forge test`

`profile test forge test -w` watch for file changes

`profile test forge test -vvv` show stack traces for failed tests

## Deploy
- Update environment variables
  - If deploying to networks other than mainnet/polygon, also update the bottom of `foundry.toml`
- Edit `package.json` scripts of `deploy` to your desired configuration
  - NOTE: to dry-run only, remove all flags after `-vvvv`
- `source .env`
- `npm run deploy:{network}`

FORGE FLATTENING
forge flatten --output src/flattened-pair.sol src/contracts/core/FraxswapPair.sol
forge flatten --output src/flattened-router.sol src/contracts/periphery/FraxswapRouter.sol
forge flatten --output src/flattened-factory.sol src/contracts/core/FraxswapFactory.sol
forge flatten --output src/flattened-router-multihop.sol src/contracts/periphery/FraxswapRouterMultihop.sol
sed -i '/SPDX-License-Identifier/d' ./src/flattened-pair.sol &&
sed -i '/pragma solidity/d' ./src/flattened-pair.sol &&
sed -i '1s/^/\/\/ SPDX-License-Identifier: GPL-2.0-or-later\npragma solidity >=0.8.0;\n\n/' ./src/flattened-pair.sol 
sed -i '/SPDX-License-Identifier/d' ./src/flattened-factory.sol &&
sed -i '/pragma solidity/d' ./src/flattened-factory.sol &&
sed -i '1s/^/\/\/ SPDX-License-Identifier: GPL-2.0-or-later\npragma solidity >=0.8.0;\n\n/' ./src/flattened-factory.sol 
sed -i '/SPDX-License-Identifier/d' ./src/flattened-router.sol &&
sed -i '/pragma solidity/d' ./src/flattened-router.sol &&
sed -i '1s/^/\/\/ SPDX-License-Identifier: GPL-2.0-or-later\npragma solidity >=0.8.0;\n\n/' ./src/flattened-router.sol 
sed -i '/SPDX-License-Identifier/d' ./src/flattened-router-multihop.sol &&
sed -i '/pragma solidity/d' ./src/flattened-router-multihop.sol &&
sed -i '1s/^/\/\/ SPDX-License-Identifier: GPL-2.0-or-later\npragma solidity >=0.8.0;\n\n/' ./src/flattened-router-multihop.sol 


## Tooling
This repo uses the following tools:
- frax-standard-solidity for testing and scripting helpers
- forge fmt & prettier for code formatting
- lint-staged & husky for pre-commit formatting checks
- solhint for code quality and style hints
- foundry for compiling, testing, and deploying
