import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import "hardhat-deploy";
import { ALL_NETWORKS, TRANSACTION_GAS_LIMITS } from "./0000_utils";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments, getNamedAccounts } = hre;
    const { deploy, get } = deployments;
    const protocolGovernance = await get("ProtocolGovernance");
    const { deployer, uniswapV2Router02, uniswapV2Factory } =
        await getNamedAccounts();
    await deploy("UniV2Validator", {
        from: deployer,
        args: [protocolGovernance.address, uniswapV2Router02, uniswapV2Factory],
        log: true,
        autoMine: true,
        ...TRANSACTION_GAS_LIMITS,
    });
};
export default func;
func.tags = ["UniV2Validator", "core", "mainnet"];
func.dependencies = ["ProtocolGovernance"];
