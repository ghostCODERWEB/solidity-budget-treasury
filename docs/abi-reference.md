# ABI reference

Generated from the successfully compiled primary contract. Includes inherited OpenZeppelin methods. Authorization requirements and economic semantics are in the Solidity source and architecture guide.

| Signature | Type | Mutability | Return values |
|---|---|---|---|
| `constructor(address asset,uint64 duration,address admin)` | constructor | nonpayable |  |
| `EnforcedPause()` | error |  |  |
| `ExpectedPause()` | error |  |  |
| `OwnableInvalidOwner(address owner)` | error |  |  |
| `OwnableUnauthorizedAccount(address account)` | error |  |  |
| `ReentrancyGuardReentrantCall()` | error |  |  |
| `SafeERC20FailedOperation(address token)` | error |  |  |
| `BudgetConfigured(address operator,uint256 limit,bool enabled)` | event |  |  |
| `OwnershipTransferStarted(address previousOwner,address newOwner)` | event |  |  |
| `OwnershipTransferred(address previousOwner,address newOwner)` | event |  |  |
| `Paused(address account)` | event |  |  |
| `Payment(address operator,address recipient,uint256 amount,uint256 epoch)` | event |  |  |
| `RecipientConfigured(address recipient,bool allowed)` | event |  |  |
| `Unpaused(address account)` | event |  |  |
| `acceptOwnership()` | function | nonpayable |  |
| `availableBudget(address operator)` | function | view | uint256  |
| `budgets(address )` | function | view | uint256 limit, uint256 spent, uint256 epoch, bool enabled |
| `configureBudget(address operator,uint256 limit,bool enabled)` | function | nonpayable |  |
| `epochLength()` | function | view | uint64  |
| `fund(uint256 amount)` | function | nonpayable |  |
| `owner()` | function | view | address  |
| `paused()` | function | view | bool  |
| `pay(address recipient,uint256 amount)` | function | nonpayable |  |
| `pendingOwner()` | function | view | address  |
| `recipients(address )` | function | view | bool  |
| `renounceOwnership()` | function | nonpayable |  |
| `setPaused(bool value)` | function | nonpayable |  |
| `setRecipient(address recipient,bool allowed)` | function | nonpayable |  |
| `token()` | function | view | address  |
| `transferOwnership(address newOwner)` | function | nonpayable |  |
