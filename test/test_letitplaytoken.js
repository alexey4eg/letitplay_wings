import expectThrow from "zeppelin-solidity/test/helpers/expectThrow.js";
const FOR_SALE = 600000000;
const PRESALE_TOKENS = 100000;
const TEAM = 50000000;

var LetItPlayToken = artifacts.require("./LetItPlayToken.sol");
contract("LetItPlayToken", function(accounts) {
  var crowdsale = accounts[1];

  var user = accounts[2];
  let forSale = accounts[4];
  let eco = accounts[5];
  let founders = accounts[6];
  let team = accounts[7];
  let advisers = accounts[8];
  let bounty = accounts[9];
  let presale = accounts[0];
  let token, decimals, shift;

  beforeEach('setup contract for each test', async function () {
    token = await LetItPlayToken.new(forSale, eco, founders, team, advisers, bounty, presale, PRESALE_TOKENS);
    decimals = await token.decimals();
    shift = Math.pow(10, decimals);
  });

  it("initial distribution", async function() {
      var balance = await token.balanceOf(forSale);
      assert.equal((FOR_SALE - PRESALE_TOKENS)*shift, balance.toNumber(), "wrong for sale");
      balance = await token.balanceOf(eco);
      assert.equal(150000000 * shift, balance, "wrong for eco");
      balance = await token.balanceOf(founders);
      assert.equal(150000000 * shift, balance, "wrong for founders");
      balance = await token.balanceOf(team);
      assert.equal(50000000 * shift, balance, "wrong for team");
      balance = await token.balanceOf(advisers);
      assert.equal(30000000 * shift, balance, "wrong for advisers");
      balance = await token.balanceOf(bounty);
      assert.equal(20000000 * shift, balance, "wrong for bounty");
      balance = await token.balanceOf(presale);
      assert.equal(PRESALE_TOKENS * shift, balance, "wrong for presale");

      let decimals = await token.decimals();
      assert.equal(decimals.toNumber(), 8);
  });

  it("setCrowdsale", async function() {
    await expectThrow(token.setCrowdsale(user, {from:user}));

    await token.setCrowdsale(crowdsale);
    var instanceCrowdsale = await token.crowdsaleContract();
    assert.equal(crowdsale, instanceCrowdsale);

    await expectThrow(token.setCrowdsale(user, {from:crowdsale}));
  });

  it("transferByCrowdsale", async function() {
      await token.setCrowdsale(crowdsale);
      await token.transferByCrowdsale(user, 100, {from:crowdsale});
      let balance = await token.balanceOf(user);
      assert.equal(100, balance);
      balance = await token.balanceOf(forSale);
      assert.equal((FOR_SALE - PRESALE_TOKENS) * shift - 100, balance.toNumber());

      await expectThrow(token.transferByCrowdsale(user, 100, {from:user}));
      await expectThrow(token.transferByCrowdsale(user, 100));
  });

  it("transferByOwner", async function() {
      await token.setCrowdsale(crowdsale);
      await token.transferByOwner(forSale, user, 100);
      let balance = await token.balanceOf(user);
      assert.equal(100, balance);
      balance = await token.balanceOf(forSale);
      assert.equal((FOR_SALE - PRESALE_TOKENS) * shift - 100, balance.toNumber());

      await expectThrow(token.transferByOwner(forSale, user, 100, {from:user}));
      await expectThrow(token.transferByOwner(forSale, user, 100, {from:crowdsale}));
    });

    it("release", async function() {
      await token.setCrowdsale(crowdsale);
      await token.transferByOwner(forSale, user, 100);
      await token.approve(user, 150, {from:founders});
      await expectThrow(token.transfer(team, 50, {from:user}));
      await expectThrow(token.transferFrom(founders, team, 150, {from:user}));
      await expectThrow(token.releaseForTransfer({from:user}));
      await token.releaseForTransfer({from:crowdsale});
      await token.transfer(team, 50, {from:user});
      let balance = await token.balanceOf(user);
      assert.equal(50, balance.toNumber());
      await token.transferFrom(founders, team, 150, {from:user});
      balance = await token.balanceOf(team);
      assert.equal(200 + TEAM * shift, balance.toNumber());
    });
});
