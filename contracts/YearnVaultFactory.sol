// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./interfaces/IVaultFactory.sol";
import "./YearnVault.sol";

/// @notice Helper contract for YearnVaultGovernance that can create new Yearn Vaults.
contract YearnVaultFactory is IVaultFactory {
    IVaultGovernance public vaultGovernance;

    /// @notice Creates a new contract
    /// @param vaultGovernance_ Reference to VaultGovernance of this VaultKind
    constructor(IVaultGovernance vaultGovernance_) {
        vaultGovernance = vaultGovernance_;
    }

    /// @inheritdoc IVaultFactory
    function deployVault(address[] memory vaultTokens, bytes memory) external returns (IVault) {
        require(msg.sender == address(vaultGovernance), "VG");
        YearnVault vault = new YearnVault(vaultGovernance, vaultTokens);
        return IVault(vault);
    }
}