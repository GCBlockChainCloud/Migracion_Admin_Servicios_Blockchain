const express = require("express");
const os = require("os");
const { ethers } = require("ethers");

const app = express();
const port = Number(process.env.PORT || 8000);
const appVersion = process.env.APP_VERSION || "desconocida";
const blockchainRpcUrl =
  process.env.BLOCKCHAIN_RPC_URL || "http://ganache:8545";

app.get("/health", (_request, response) => {
  response.json({
    status: "ok",
    pod: process.env.POD_NAME || os.hostname()
  });
});

app.get("/version", (_request, response) => {
  response.json({
    contract: "AcademicCertificateRegistry",
    version: appVersion,
    pod: process.env.POD_NAME || os.hostname()
  });
});

app.get("/blockchain", async (_request, response) => {
  try {
    const provider = new ethers.JsonRpcProvider(blockchainRpcUrl);
    const [network, blockNumber] = await Promise.all([
      provider.getNetwork(),
      provider.getBlockNumber()
    ]);

    response.json({
      connected: true,
      chainId: network.chainId.toString(),
      blockNumber,
      rpc: blockchainRpcUrl,
      pod: process.env.POD_NAME || os.hostname()
    });
  } catch (error) {
    response.status(503).json({
      connected: false,
      error: error.message,
      pod: process.env.POD_NAME || os.hostname()
    });
  }
});

app.listen(port, "0.0.0.0", () => {
  console.log(
    `Contract service ${appVersion} ejecutandose en el puerto ${port}`
  );
});
