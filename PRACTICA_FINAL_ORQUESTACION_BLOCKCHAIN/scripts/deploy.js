const hre = require("hardhat");

async function main() {
  const Registry = await hre.ethers.getContractFactory(
    "AcademicCertificateRegistry"
  );
  const registry = await Registry.deploy();
  await registry.waitForDeployment();

  const address = await registry.getAddress();
  const version = await registry.version();

  console.log("AcademicCertificateRegistry desplegado correctamente");
  console.log(`Direccion del contrato: ${address}`);
  console.log(`Version del contrato: ${version}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
