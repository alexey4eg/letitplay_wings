var token = artifacts.require("./LetItPlayToken.sol");

module.exports = function(deployer) {
  deployer.deploy(token);
};
