import expectThrow from "zeppelin-solidity/test/helpers/expectThrow.js";
let MINIMAL_GOAL = web3.toWei(1, 'ether');
let HARD_CAP =     web3.toWei(2, 'ether');
const TOKEN_PRICE = web3.toWei(1, 'finney');
const PRESALE_TOKENS = 100000;
const COMMISSION_EPS = 0.01;

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
  let forSale = accounts[4];
  let currenttime;

  const init_wl_and_donate = async function(amount) {
    //return new Promise(()=>{})
    await crowdsale.start(currenttime + 2, currenttime + 3598 * 22 * 13, fundingAddress);
    await crowdsale.AddToWhiteList(user);
    timeTravel(3);
    await crowdsale.sendTransaction({from:user, value: amount});
  }

  beforeEach('setup contract for each test', async function () {
      token = await LetItPlayToken.new(forSale, accounts[5], accounts[6], accounts[7], accounts[8], accounts[9], accounts[0], PRESALE_TOKENS);
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

  it("selltoken", async function() {
    let totalCollectedBefore = await crowdsale.totalCollected();
    let totalSoldBefore = await crowdsale.totalSold();
    let toDonate = web3.toWei(40, 'finney');
    await init_wl_and_donate(toDonate);
    let balance = await token.balanceOf(user);
    console.log("user token balance: ", balance.toNumber());
    let ethBalance = web3.eth.getBalance(crowdsale.address).toNumber();
    let totalSold = await crowdsale.totalSold();
    let totalCollected = await crowdsale.totalCollected();
    let givenTokens = toDonate/ TOKEN_PRICE;
    givenTokens += givenTokens * 3 / 10;
    assert.equal(givenTokens, balance.toNumber());
    assert.equal(toDonate, ethBalance);
    assert.equal(toDonate, totalCollected - totalCollectedBefore);
    assert.equal(givenTokens, totalSold - totalSoldBefore);
  });

  it("crowdsale success", async function() {
    await init_wl_and_donate(MINIMAL_GOAL);
    timeTravel(3600 * 24 * 15 + 2);
    let succ = await crowdsale.isSuccessful();
    assert.equal(true, succ);
    console.log(web3.eth.getBalance(crowdsale.address));
    var befWithdraw = web3.eth.getBalance(fundingAddress);
    await crowdsale.withdraw(web3.eth.getBalance(crowdsale.address).toNumber());
    assert(MINIMAL_GOAL, web3.eth.getBalance(fundingAddress).toNumber() - befWithdraw.toNumber());
  });

  it("crowdsale failed", async function() {
    await init_wl_and_donate(MINIMAL_GOAL/2);
    timeTravel(3600 * 24 * 15 + 2);
    await expectThrow(crowdsale.withdraw(web3.eth.getBalance(crowdsale.address)));
  });

  it("refund", async function() {
      await init_wl_and_donate(MINIMAL_GOAL/2);
      crowdsale.stop();
      var ethBef = web3.eth.getBalance(user);
      var balance = await token.balanceOf(user);
      await token.approve(crowdsale.address, balance, {from:user});
      var beforeRefund = web3.eth.getBalance(user);
      console.log("before refund ", beforeRefund.toNumber());
      await crowdsale.refund({from:user});
      var ethAfter = web3.eth.getBalance(user);
      let err = Math.abs(MINIMAL_GOAL/2 - (ethAfter.toNumber() - ethBef.toNumber())) / web3.toWei(1, 'ether');
      console.log("err ", err);
      assert.equal(true, err < COMMISSION_EPS);
      balance = await token.balanceOf(user);
      assert.equal(0, balance.toNumber());
      balance = await token.balanceOf(forSale);
      assert.equal(600000000-PRESALE_TOKENS, balance.toNumber());
  });
});
