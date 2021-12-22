// SPDX-License-Identifier: BSL-1.1
pragma solidity 0.8.9;

import "../interfaces/IVaultFactory.sol";
import "../interfaces/IVaultGovernance.sol";
import "./UniV3VaultTest.sol";
import "contracts/libraries/ExceptionsLibrary.sol";

contract UniV3VaultTestFactory is IVaultFactory {
    IVaultGovernance public vaultGovernance;

    constructor(IVaultGovernance vaultGovernance_) {
        vaultGovernance = vaultGovernance_;
    }

    function setVaultGovernance(address newVaultGovernance) public {
        vaultGovernance = IVaultGovernance(newVaultGovernance);
    }

    function deployVault(address[] memory vaultTokens, bytes memory options) external returns (IVault) {
        require(msg.sender == address(vaultGovernance), ExceptionsLibrary.SHOULD_BE_CALLED_BY_VAULT_GOVERNANCE);
        uint256 fee = abi.decode(options, (uint256));
        UniV3VaultTest vault = new UniV3VaultTest(vaultGovernance, vaultTokens, uint24(fee));
        return IVault(vault);
    }
}
