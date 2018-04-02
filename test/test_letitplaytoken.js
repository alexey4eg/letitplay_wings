import expectThrow from "zeppelin-solidity/test/helpers/expectThrow.js";

var LetItPlayToken = artifacts.require("./LetItPlayToken.sol");
contract("LetItPlayToken", function(accounts) {
  var crowdsale = accounts[1];
  var user = accounts[2];

  it("initial supply = 1000000000", function() {
    return LetItPlayToken.deployed().then(async function(instance) {
      var balance = await instance.balanceOf(LetItPlayToken.address);
      assert.equal(balance, 1000000000, "wrong initial supply");
    });
  });

  it("setCrowdsale", async function() {
    var instance = await LetItPlayToken.deployed();

    await expectThrow(instance.setCrowdsale(user, {from:user}));

    await instance.setCrowdsale(crowdsale);
    var instanceCrowdsale = await instance.crowdsaleContract();
    assert.equal(crowdsale, instanceCrowdsale);

    await expectThrow(instance.setCrowdsale(user, {from:crowdsale}));
  });

  it("transferByAdmin", function() {
    return LetItPlayToken.deployed().then(async function(instance) {
      await instance.setCrowdsale(crowdsale);
      await instance.transferByAdmin(instance.address, user, 100);
      var balance = await instance.balanceOf(user);
      assert.equal(100, balance);

      await instance.transferByAdmin(instance.address, user, 100, {from:crowdsale});
      var balance = await instance.balanceOf(user);
      assert.equal(200, balance);

      await expectThrow(instance.transferByAdmin(instance.address, user, 100, {from:user}));
    });
  });
});
