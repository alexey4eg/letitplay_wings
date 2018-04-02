import expectThrow from "zeppelin-solidity/test/helpers/expectThrow.js";
const MINIMAL_GOAL = 1000
const HARD_CAP = 2000
const TOKEN_PRICE = 2

let LetItPlayToken = artifacts.require("./LetItPlayToken.sol");
let Crowdsale = artifacts.require("./Crowdsale.sol");

contract("Crowdsale", async function(accounts) {
  let crowdsale, token;
  let user = accounts[2];
  let manager = accounts[0];
  let fundingAddress = accounts[3];

  beforeEach('setup contract for each test', async function () {
      token = await LetItPlayToken.new();
      crowdsale = await Crowdsale.new(MINIMAL_GOAL, HARD_CAP, TOKEN_PRICE, token.address);
      token.setCrowdsale(crowdsale.address);
      user = accounts[2];
    });

  it("initialization check", async function() {
    let minGoal = await crowdsale.minimalGoal();
    assert.equal(minGoal, MINIMAL_GOAL);
    let hardCap = await crowdsale.hardCap();
    assert.equal(hardCap, HARD_CAP);
    /*let tokenPrice = await crowdsale.tokenPrice();
    assert.equal(tokenPrice, TOKEN_PRICE);*/
  });

  it("whitelist", async function() {
    let currenttime = Date.now() / 1000;
    console.log("current time: ", currenttime);
    await crowdsale.start(currenttime, currenttime + 3600 * 24 * 15, fundingAddress);
    await expectThrow(crowdsale.sendTransaction({from:user, value: 10}));
    await crowdsale.AddToWhiteList(user);
    await crowdsale.sendTransaction({from:user, value: 10});
  });

  it("selltoken", async function() {
    let currenttime = Date.now() / 1000;
    console.log("current time: ", currenttime);

    let totalCollectedBefore = await crowdsale.totalCollected();
    let totalSoldBefore = await crowdsale.totalSold();

    await crowdsale.start(currenttime, currenttime + 3600 * 24 * 15, fundingAddress);
    await crowdsale.AddToWhiteList(user);
    await crowdsale.sendTransaction({from:user, value: 10});
    let balance = await token.balanceOf(user);
    console.log("user token balance: ", balance.toNumber());
    let ethBalance = web3.eth.getBalance(crowdsale.address).toNumber();
    let totalSold = await crowdsale.totalSold();
    let totalCollected = await crowdsale.totalCollected();

    assert.equal(10 / TOKEN_PRICE, balance.toNumber());
    assert.equal(10, ethBalance);
    assert.equal(10, totalCollected - totalCollectedBefore);
    assert.equal(10 / TOKEN_PRICE, totalSold - totalSoldBefore);
  });

  
});
