const { ethers } = require('hardhat');
require('dotenv').config();
const compiledContract = require('../artifacts/contracts/NIToken.sol/NI.json');
const { EtherSymbol } = require('ethers');

async function main() {
    const provider = new ethers.JsonRpcProvider(process.env.TEST_NET_RPC_URL);
    console.log(process.env.TEST_NET_RPC_URL);
    const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
    console.log(await provider.getSigner(0));
    //ethers.getContractFactory("NIToken", compiledContract.abi, compiledContract.bytecode);
}


main().catch(error => {
    console.log(error);
    process.exitCode = 1;
})