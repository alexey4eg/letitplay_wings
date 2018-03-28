var crowdsale = artifacts.require("./Crowdsale.sol");
var token = artifacts.require("./LetItPlayToken.sol");

module.exports = function(deployer) {
  deployer.deploy(crowdsale, 20, 30, 5, token.address);
};
