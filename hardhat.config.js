require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  networks: {
    rinkeby: {
      url: 'https://eth-rinkeby.alchemyapi.io/v2/Fx1zRjAR3AL_4RRJZX97CJQMlPKibg9n',
      accounts: ['1b4f4b1daac8799804f38fd7b607a52b0d54c35cc28b4546d201f94320447daf'],
    },
  },
  etherscan: {
    // npx hardhat verify YOUR_CONTRACT_ADDRESS --network rinkeby
    apiKey: "",
  }
};
