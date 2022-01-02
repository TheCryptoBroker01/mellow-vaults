// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./IIntegrationVault.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

interface IUniV3Vault is IERC721Receiver, IIntegrationVault {
    /// @notice Initialized a new contract.
    /// @dev Can only be initialized by vault governance
    /// @param vaultTokens_ ERC20 tokens that will be managed by this Vault
    /// @param nft_ NFT of the vault in the VaultRegistry
    /// @param fee_ Fee of the UniV3 pool
    function initialize(
        address[] memory vaultTokens_,
        uint256 nft_,
        uint24 fee_
    ) external;
}
