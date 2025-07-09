const HDWalletProvider = require("@truffle/hdwallet-provider");
const { Web3 } = require("web3");
const compiledFactory = require("./Build/CampaignFactory.json");

const provider = new HDWalletProvider(
  "flower limb swarm flag mirror omit february broken camera aisle leg mystery",
  "https://sepolia.infura.io/v3/53adcb5b841347f6ad32e493ee2513c1"
);

const web3 = new Web3(provider);

const deploy = async () => {
  const accounts = await web3.eth.getAccounts();

  console.log("Attempting to deploy from account", accounts[0]);

  const result = await new web3.eth.Contract(
    JSON.parse(compiledFactory.interface)
  )
    .deploy({ data: compiledFactory.bytecode })
    .send({ gas: "1000000", from: accounts[0] });

  console.log("Contract deployed to", result.options.address);
  provider.engine.stop();
};
deploy();
