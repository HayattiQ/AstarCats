import { task, types } from "hardhat/config";
import { BigNumber, ethers } from "ethers";
import { getContract, getEnvVariable, getProvider } from "./helpers";
import fs from "fs";
import readline from "readline";
import { getContractAt } from "@nomiclabs/hardhat-ethers/internal/helpers";

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

task("checksum", "Change address to checksum address")
  .addParam("address", "wallet address")
  .setAction(async (taskArgs, hre) => {
    console.log(ethers.utils.getAddress(taskArgs.address));
  });

task("pushWL", "Push WhiteList from JSON file")
  .addOptionalParam("filename", "WhiteList txt file name", "./scripts/whitelist_import.txt")
  .setAction(async (taskArgs, hre) => {
    let whitelist: string[] = [];

    const rl = readline.createInterface({
      input: fs.createReadStream(taskArgs.filename, { encoding: 'utf8' }),
      crlfDelay: Infinity
    });

    for await (const line of rl) {
      if (!ethers.utils.isAddress(line)) throw Error(line + "is not valid.");
      whitelist.push(line);
    }

    const contract = await getContract(getEnvVariable("CONTRACT_NAME"), hre, getProvider(hre));
    const transactionResponse = await contract["pushMultiWL"](whitelist, {
      gasLimit: 14900000
    });
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
  });

task("ownerMint", "Mints from the NFT contract. (only Owner)")
  .addParam("number", "Ownermint Number")
  .setAction(async function (taskArguments, hre) {
    const contract = await getContract(getEnvVariable("CONTRACT_NAME"), hre, getProvider(hre));
    const transactionResponse = await contract["ownerMint"](taskArguments.number);
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
  });

task("isPaused", "Check pause status")
  .setAction(async function (taskArguments, hre) {

    const contract = await getContract(getEnvVariable("CONTRACT_NAME"), hre, getProvider(hre));
    const transactionResponse = await contract["is_paused"]();
    console.log(`isPaused: ${transactionResponse}`);
  });

task("pause", "Pause Sale")
  .setAction(async function (taskArguments, hre) {
    const contract = await getContract(getEnvVariable("CONTRACT_NAME"), hre, getProvider(hre));
    const transactionResponse = await contract["pause"](true);
    console.log(`Sale Pause status changed. hash: ${transactionResponse.hash}`);
  });

task("unpause", "Un Pause Sale")
  .setAction(async function (taskArguments, hre) {
    const contract = await getContract(getEnvVariable("CONTRACT_NAME"), hre, getProvider(hre));
    console.log(`call contract.address ${contract.address}.`);
    const transactionResponse = await contract["pause"](false);
    console.log(`Sale Pause status changed. hash: ${transactionResponse.hash}`);
  });

  task("ownerOf", "Show Token Owner Of")
  .addParam("id", "token ID")
  .setAction(async function (taskArguments, hre) {
    const contract = await getContract(getEnvVariable("CONTRACT_NAME"), hre, getProvider(hre));
    console.log(`call contract.address ${contract.address}.`);
    const transactionResponse = await contract["ownerOf"](taskArguments.id);
    console.log(`owner address: ${transactionResponse}`);
  });


task("totalSupply", "Show Total Supply")
  .setAction(async function (taskArguments, hre) {
    const contract = await getContract(getEnvVariable("CONTRACT_NAME"), hre, getProvider(hre));
    console.log(`call contract.address ${contract.address}.`);
    const transactionResponse = await contract["totalSupply"]();
    console.log(`totalSupply: ${transactionResponse}`);
  });

task("snapshot", "BulkSend Account NFT")
  .addOptionalParam("filename", "White txt file name", "./scripts/snapshot.csv", types.string)
  .addOptionalParam("start", "Start ID", 1, types.int)
  .setAction(async function (taskArguments, hre) {
    const contract = await getContract(getEnvVariable("CONTRACT_NAME"), hre, getProvider(hre));
    const totalSupply: number = Number(await contract["totalSupply"]());
    console.log(`totalSupply: ${totalSupply}`);
    if (fs.existsSync(taskArguments.filename)) fs.truncateSync(taskArguments.filename);
    for (let i = taskArguments.start; i <= totalSupply; i++) {
      const ownerOf = await contract["ownerOf"](i);
      console.log(`ID:${i} owner:${ownerOf}`);
      fs.appendFileSync(taskArguments.filename, [i, ownerOf].join(",") + "\n");
    }

    console.log("done");
  });
