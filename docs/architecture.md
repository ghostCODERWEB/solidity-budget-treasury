# Architecture

## Domain

Role-scoped ERC20 treasury with epoch budgets, recipient permissions and delayed administrator ownership.

## Trust and economic model

Only configured operators can spend, and only to approved recipients. Budgets reset on UTC-like epoch boundaries derived from block.timestamp. Owner can change permissions immediately; ownership transfers require acceptance. No arbitrary execution or emergency asset sweep.

## Components

`BudgetTreasury` holds domain state and exposes transitions. `SuiteBase` provides two-step ownership, pause control and reentrancy protection to administrative suites. `AssetFlow` verifies exact incoming token balance changes and performs checked native payouts. OpenZeppelin supplies token standards, math, safe transfers, Merkle verification and NFT reception.

`test/contracts/TestAssets.sol` contains unrestricted mint helpers, a fee-burning token and a rejecting native receiver. These are excluded from the deployment guide's primary contract and must never be used as real assets.

## Units and timing

All amounts are base units. ERC20 decimals are not automatically normalized. Timestamps use block.timestamp in seconds; tests advance the local chain explicitly. Integer operations round down except where OpenZeppelin defines standard ERC4626 rounding. Externally supplied amounts must account for dust and slippage.

## Failure semantics

A failed precondition or external transfer reverts the whole transaction. Accounting and settlement flags revert with it. Events report completed transitions. Off-chain clients should verify successful receipts and retain relevant event IDs.

## Build reproducibility

Pinned npm dependencies, exact compiler version, optimizer settings and explicit Cancun EVM target. Compilation includes storage layouts and deployed-bytecode size validation against EIP-170. Generated build output is not committed.
