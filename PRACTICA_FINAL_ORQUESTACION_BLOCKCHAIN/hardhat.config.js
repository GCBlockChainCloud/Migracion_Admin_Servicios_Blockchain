require("@nomicfoundation/hardhat-toolbox");

const blockchainRpcUrl =
  process.env.BLOCKCHAIN_RPC_URL || "http://ganache:8545";
const deployerPrivateKey = process.env.DEPLOYER_PRIVATE_KEY;

module.exports = {
  paths: {
    sources: process.env.CONTRACTS_PATH || "./contracts"
  },
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    kubernetes: {
      url: blockchainRpcUrl,
      accounts: deployerPrivateKey ? [deployerPrivateKey] : []
    }
  }
};
