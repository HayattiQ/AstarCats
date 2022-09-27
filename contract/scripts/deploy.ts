import hre from "hardhat";
import { getEnvVariable } from "./helpers";

async function main() {
  const AstarCats = await hre.ethers.getContractFactory("CatsDappsNFT");
  console.log('Deploying AstarCats ERC721 token...');
  const token = await AstarCats.deploy({ gasPrice: 100000000000 });

  await token.deployed();
  console.log("AstarCats deployed to:", token.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });