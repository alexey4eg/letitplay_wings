var crowdsale = artifacts.require("./Crowdsale.sol");

module.exports = function(deployer) {
  deployer.deploy(crowdsale, 20, 30, 5, token.address);
};
