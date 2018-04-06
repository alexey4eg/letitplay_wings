import expectThrow from "zeppelin-solidity/test/helpers/expectThrow.js";
const MINIMAL_GOAL = 1000
const HARD_CAP = 2000
const TOKEN_PRICE = 2

let LetItPlayToken = artifacts.require("./LetItPlayToken.sol");
let Crowdsale = artifacts.require("./Crowdsale.sol");

const timeTravel = function (time) {
  return new Promise((resolve, reject) => {
    web3.currentProvider.sendAsync({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [time], // 86400 is num seconds in day
      id: new Date().getTime()
    }, (err, result) => {
      if(err){ return reject(err) }
      return resolve(result)
    });
  })
}

contract("Crowdsale", async function(accounts) {
  let crowdsale, token;
  let user = accounts[2];
  let manager = accounts[0];
  let fundingAddress = accounts[3];
  let currenttime;

  beforeEach('setup contract for each test', async function () {
      token = await LetItPlayToken.new(accounts[4], accounts[5], accounts[6], accounts[7], accounts[8], accounts[9]);
      crowdsale = await Crowdsale.new(MINIMAL_GOAL, HARD_CAP, TOKEN_PRICE, token.address);
      token.setCrowdsale(crowdsale.address);
      user = accounts[2];
      currenttime = web3.eth.getBlock('latest').timestamp;
    });

  it("initialization check", async function() {
    let minGoal = await crowdsale.minimalGoal();
    assert.equal(minGoal, MINIMAL_GOAL);
    let hardCap = await crowdsale.hardCap();
    assert.equal(hardCap, HARD_CAP);
  });

  it("whitelist", async function() {
    await crowdsale.start(currenttime + 2, currenttime + 3600 * 24 * 15, fundingAddress);
    await expectThrow(crowdsale.sendTransaction({from:user, value: 10}));
    await crowdsale.AddToWhiteList(user);
    timeTravel(3);
    await crowdsale.sendTransaction({from:user, value: 10});
  });

  const init_wl_and_donate = async function(amount) {
    //return new Promise(()=>{})
    await crowdsale.start(currenttime + 2, currenttime + 3600 * 24 * 15, fundingAddress);
    await crowdsale.AddToWhiteList(user);
    timeTravel(3);
    await crowdsale.sendTransaction({from:user, value: amount});
  }

  it("selltoken", async function() {
    let totalCollectedBefore = await crowdsale.totalCollected();
    let totalSoldBefore = await crowdsale.totalSold();
    await init_wl_and_donate(20);
    let balance = await token.balanceOf(user);
    console.log("user token balance: ", balance.toNumber());
    let ethBalance = web3.eth.getBalance(crowdsale.address).toNumber();
    let totalSold = await crowdsale.totalSold();
    let totalCollected = await crowdsale.totalCollected();
    let givenTokens = 20 / TOKEN_PRICE;
    givenTokens += givenTokens * 3 / 10;
    assert.equal(givenTokens, balance.toNumber());
    assert.equal(20, ethBalance);
    assert.equal(20, totalCollected - totalCollectedBefore);
    assert.equal(givenTokens, totalSold - totalSoldBefore);
  });

  it("crowdsale success", async function() {
    await init_wl_and_donate(MINIMAL_GOAL);
    timeTravel(3600 * 24 * 15 + 2);
    let succ = await crowdsale.isSuccessful();
    assert.equal(true, succ);
    console.log(web3.eth.getBalance(crowdsale.address));
    await crowdsale.withdraw(web3.eth.getBalance(crowdsale.address));
    assert(MINIMAL_GOAL, web3.eth.getBalance(fundingAddress));
  });

  it("crowdsale failed", async function() {
    await init_wl_and_donate(MINIMAL_GOAL/2);
    timeTravel(3600 * 24 * 15 + 2);
    await expectThrow(crowdsale.withdraw(web3.eth.getBalance(crowdsale.address)));
  });
});
