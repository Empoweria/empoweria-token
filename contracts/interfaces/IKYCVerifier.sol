// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IKYCVerifier Interface
 * @dev Interface for KYC verification.
 */

interface IKYCVerifier {
    function isKYCCompleted(address account) external view returns (bool);
}
