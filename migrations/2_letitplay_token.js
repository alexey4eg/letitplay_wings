var token = artifacts.require("./LetItPlayToken.sol");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(token, accounts[4], accounts[5], accounts[6], accounts[7], accounts[8], accounts[9]);
};
