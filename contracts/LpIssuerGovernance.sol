// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./interfaces/IProtocolGovernance.sol";
import "./interfaces/ILpIssuerGovernance.sol";
import "./interfaces/ILpIssuer.sol";
import "./libraries/CommonLibrary.sol";
import "./VaultGovernance.sol";

/// @notice Governance that manages all Lp Issuers params and can deploy a new LpIssuer Vault.
contract LpIssuerGovernance is IERC721Receiver, ILpIssuerGovernance, VaultGovernance {
    /// @notice Creates a new contract.
    /// @param internalParams_ Initial Internal Params
    constructor(InternalParams memory internalParams_) VaultGovernance(internalParams_) {}

    /// @inheritdoc IVaultGovernance
    function strategyTreasury(uint256) external pure override(IVaultGovernance, VaultGovernance) returns (address) {
        return address(0);
    }

    /// @notice Strategy Params, i.e. Params that could be changed by Strategy or Protocol Governance immediately.
    /// @param nft Nft of the vault
    function strategyParams(uint256 nft) external view returns (StrategyParams memory) {
        if (_strategyParams[nft].length == 0) {
            return StrategyParams({tokenLimitPerAddress: 0});
        }
        return abi.decode(_strategyParams[nft], (StrategyParams));
    }

    /// @notice Stage Strategy Params.
    /// @param nft Nft of the vault
    /// @param params New params
    function stageDelayedStrategyParams(uint256 nft, StrategyParams calldata params) external {
        _stageDelayedStrategyParams(nft, abi.encode(params));
        emit SetStrategyParams(tx.origin, msg.sender, nft, params);
    }

    function commitDelayedStrategyParams(uint256 nft) external {
        _commitDelayedStrategyParams(nft);
    }

    function setStrategyParams(uint256 nft, StrategyParams calldata params) external {
        _setStrategyParams(nft, abi.encode(params));
        emit SetStrategyParams(tx.origin, msg.sender, nft, params);
    }

    /// @notice Required for intermediate vault token transfer in deploy
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external view returns (bytes4) {
        IVaultRegistry registry = _internalParams.registry;
        require(msg.sender == address(registry), "NFTVR");
        return this.onERC721Received.selector;
    }

    /// @notice Deploy a new vault.
    /// @param vaultTokens ERC20 tokens under vault management
    /// @param options Abi encoded uint256 - an nfts of the gateway subvault. It is required that nft subvault is approved by the caller to this address and that it is a gateway vault
    /// @return vault Address of the new vault
    /// @return nft Nft of the vault in the vault registry
    function deployVault(
        address[] memory vaultTokens,
        bytes memory options,
        address
    ) public override(VaultGovernance, IVaultGovernance) returns (IVault vault, uint256 nft) {
        (uint256 subvaultNft, string memory name, string memory symbol) = abi.decode(
            options,
            (uint256, string, string)
        );
        (vault, nft) = super.deployVault(vaultTokens, abi.encode(name, symbol), msg.sender);
        // TODO - add IERC165 check of the subvault interface == gateway vault interface
        IVaultRegistry registry = _internalParams.registry;
        ILpIssuer(address(vault)).addSubvault(subvaultNft);
        registry.safeTransferFrom(msg.sender, address(vault), subvaultNft);
    }

    /// @notice Emitted when new StrategyParams are set.
    /// @param origin Origin of the transaction
    /// @param sender Sender of the transaction
    /// @param nft VaultRegistry NFT of the vault
    /// @param params New params that are set
    event SetStrategyParams(address indexed origin, address indexed sender, uint256 indexed nft, StrategyParams params);
}
