// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IPlugin} from "@1inch/token-plugins/contracts/interfaces/IPlugin.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Plugin} from "@1inch/token-plugins/contracts/Plugin.sol";
import {SafeERC20} from "@1inch/solidity-utils/contracts/libraries/SafeERC20.sol";
import {AddressArray, AddressSet} from "@1inch/solidity-utils/contracts/libraries/AddressSet.sol";
import {IERC20Plugins} from "@1inch/token-plugins/contracts/interfaces/IERC20Plugins.sol";

contract MultiFactoringPlugin is Plugin {
    using SafeERC20 for IERC20;
    error ZeroFarmableTokenAddress();
    error ZeroRewardsTokenAddress();
    error RewardsTokenAlreadyAdded();
    error RewardsTokensLimitTooHigh(uint256);
    error RewardsTokensLimitReached();
    error RewardsTokenNotFound();
    error InsufficientFunds();
    error ZeroInvestmentPoolAddress();

    using Address for address payable;
    using AddressSet for AddressSet.Data;
    using AddressArray for AddressArray.Data;
    uint256 public immutable rewardsTokensLimit;

    IERC20 private _farmableToken;
    address public investmentPoolAddress;

    constructor(
        IERC20 farmableToken_,
        IERC20Plugins investmentPoolAddress_
    ) Plugin(investmentPoolAddress_) {
        if (address(farmableToken_) == address(0))
            revert ZeroFarmableTokenAddress();

        _farmableToken = farmableToken_;
        address investmentPoolAddresslocal;
        assembly {
            investmentPoolAddresslocal := investmentPoolAddress_
        }
        rewardsTokensLimit = 0; // Initialize the rewardsTokensLimit variable
        investmentPoolAddress = investmentPoolAddresslocal; // Initialize the investmentPoolAddress variable
    }

    function _updateBalances(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        if (from != address(0)) {
            _farmableToken.safeTransferFrom(from, address(this), amount);
        }
        if (to != address(0)) {
            _farmableToken.safeTransfer(to, amount);
        }
    }

    //     function _updateBalances(address from, address to, uint256 amount) internal virtual override {
    //     super._updateBalances(from, to, amount);

    //     // Case when tokens are transferred to this contract (Investment into the pool)
    //     if (to == address(this)) {
    //         // Approve the investment pool to pull the specified amount of tokens
    //         _farmableToken.safeApprove(investmentPoolAddress, amount);

    //         // Call investInPool function to handle the investment logic
    //         IInvestmentPool(investmentPoolAddress).investInPool(from, amount);
    //     }
    //     // Case when tokens are transferred from this contract (Redistribution or returns)
    //     else if (from == address(this)) {
    //         // Logic to handle distribution of returns or redemption of tokens
    //         // This might involve updating internal accounting to track the distribution of profits/returns
    //         // Or handling the redemption process for investors
    //     }

    //     // Additional logic for other invoice factoring related scenarios
    //     // This could include handling fees, penalties, or specific conditions related to invoice factoring
    // }
}
