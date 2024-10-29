// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title KYC Verifier
 * @dev Handles KYC verification for EmpoweriaToken.
 */

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IKYCVerifier.sol";

contract KYCVerifier is IKYCVerifier, Ownable {
    mapping(address => bool) private _kycStatus;

    event KYCStatusUpdated(address indexed account, bool status);

    /**
     * @dev Updates the KYC status of an account.
     * Can only be called by the owner.
     */
    function updateKYCStatus(address account, bool status) external onlyOwner {
        _kycStatus[account] = status;
        emit KYCStatusUpdated(account, status);
    }

    /**
     * @dev Returns the KYC status of an account.
     */
    function isKYCCompleted(address account) external view override returns (bool) {
        return _kycStatus[account];
    }
}
