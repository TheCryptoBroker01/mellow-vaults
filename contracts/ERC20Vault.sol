// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./Vault.sol";

contract ERC20Vault is Vault {
    constructor(
        address[] memory tokens,
        uint256[] memory limits,
        IVaultManager vaultManager
    ) Vault(tokens, limits, vaultManager) {}

    function tvl() public view override returns (address[] memory tokens, uint256[] memory tokenAmounts) {
        tokens = vaultTokens();
        tokenAmounts = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            tokenAmounts[i] = IERC20(tokens[i]).balanceOf(address(this));
        }
    }

    function _push(uint256[] memory tokenAmounts) internal pure override returns (uint256[] memory actualTokenAmounts) {
        // no-op, tokens are already on balance
        return tokenAmounts;
    }

    function _pull(address to, uint256[] memory tokenAmounts)
        internal
        override
        returns (uint256[] memory actualTokenAmounts)
    {
        for (uint256 i = 0; i < tokenAmounts.length; i++) {
            IERC20(vaultTokens()[i]).transfer(to, tokenAmounts[i]);
        }
        actualTokenAmounts = tokenAmounts;
    }

    function _collectEarnings(address, address[] memory tokens)
        internal
        pure
        override
        returns (uint256[] memory collectedEarnings)
    {
        // no-op, no earnings here
        collectedEarnings = new uint256[](tokens.length);
    }

    function _postReclaimTokens(address, address[] memory tokens) internal view override {
        for (uint256 i = 0; i < tokens.length; i++) {
            require(!isVaultToken(tokens[i]), "OWT"); // vault token is part of TVL
        }
    }
}
