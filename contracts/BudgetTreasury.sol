// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {SuiteBase, AssetFlow} from "./SuiteBase.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title Budgeted token treasury
/// @notice Role-scoped ERC20 treasury with epoch budgets, recipient permissions and delayed administrator ownership.
/// @dev Reference implementation; independent audit required before production.

contract BudgetTreasury is SuiteBase {
    using SafeERC20 for IERC20;
    IERC20 public immutable token;
    uint64 public immutable epochLength;
    struct Budget {
        uint256 limit;
        uint256 spent;
        uint256 epoch;
        bool enabled;
    }
    mapping(address => Budget) public budgets;
    mapping(address => bool) public recipients;
    event BudgetConfigured(
        address indexed operator,
        uint256 limit,
        bool enabled
    );
    event RecipientConfigured(address indexed recipient, bool allowed);
    event Payment(
        address indexed operator,
        address indexed recipient,
        uint256 amount,
        uint256 epoch
    );
    constructor(
        address asset,
        uint64 duration,
        address admin
    ) SuiteBase(admin) {
        require(asset.code.length > 0 && duration > 0, "config");
        token = IERC20(asset);
        epochLength = duration;
    }
    function configureBudget(
        address operator,
        uint256 limit,
        bool enabled
    ) external onlyOwner {
        require(operator != address(0), "operator");
        Budget storage b = budgets[operator];
        uint256 epoch = block.timestamp / epochLength;
        if (b.epoch != epoch) {
            b.spent = 0;
            b.epoch = epoch;
        }
        require(limit >= b.spent, "below spent");
        b.limit = limit;
        b.enabled = enabled;
        emit BudgetConfigured(operator, limit, enabled);
    }
    function setRecipient(address recipient, bool allowed) external onlyOwner {
        require(
            recipient != address(0) && recipient != address(this),
            "recipient"
        );
        recipients[recipient] = allowed;
        emit RecipientConfigured(recipient, allowed);
    }
    function fund(uint256 amount) external nonReentrant {
        AssetFlow.pullExact(token, msg.sender, amount);
    }
    function pay(
        address recipient,
        uint256 amount
    ) external nonReentrant whenNotPaused {
        require(recipients[recipient] && amount > 0, "payment");
        Budget storage b = budgets[msg.sender];
        require(b.enabled, "operator");
        uint256 epoch = block.timestamp / epochLength;
        if (b.epoch != epoch) {
            b.spent = 0;
            b.epoch = epoch;
        }
        require(amount <= b.limit - b.spent, "budget");
        b.spent += amount;
        token.safeTransfer(recipient, amount);
        emit Payment(msg.sender, recipient, amount, epoch);
    }
    function availableBudget(address operator) external view returns (uint256) {
        Budget memory b = budgets[operator];
        if (!b.enabled) return 0;
        return
            b.epoch == block.timestamp / epochLength
                ? b.limit - b.spent
                : b.limit;
    }
}
