pragma solidity ^0.4.19;
import "wings-integration/contracts/BasicCrowdsale.sol";
import "./LetItplayToken.sol";
import "./WithBonusPeriods.sol";
import "./Whitelist.sol";

contract Crowdsale is BasicCrowdsale, Whitelist, WithBonusPeriods {

  mapping(address => uint256) participants;

  struct PresaleItem {
    uint256 eth;
    uint256 tokens;
  }

  mapping(address => PresaleItem) presale;
  address[] presaleAddresses;



  uint256 tokensPerEthPrice;
  LetItPlayToken token;

  uint256 forSale;
  uint256 ecoSystemFund;
  uint256 founders;
  uint256 team;
  uint256 advisers;
  uint256 bounty;
  uint256 forSaleLeft;

  // Ctor. In this example, minimalGoal, hardCap, and price are not changeable.
  // In more complex cases, those parameters may be changed until start() is called.
  function Crowdsale(
    uint256 _minimalGoal,
    uint256 _hardCap,
    uint256 _tokensPerEthPrice,
    address _token
  )
    public
    // simplest case where manager==owner. See onlyOwner() and onlyManager() modifiers
    // before functions to figure out the cases in which those addresses should differ
    BasicCrowdsale(msg.sender, msg.sender)
  {
    // just setup them once...
    minimalGoal = _minimalGoal;
    hardCap = _hardCap;
    tokensPerEthPrice = _tokensPerEthPrice;
    token = LetItPlayToken(_token);
    uint256 totalSupply = token.totalSupply();
    forSale = totalSupply * 6 / 10;
    forSaleLeft = forSale;
    ecoSystemFund = totalSupply * 15 / 100;
    founders = totalSupply * 15 / 100;
    team = totalSupply * 5 / 100;
    advisers = totalSupply * 3 / 100;
    bounty = totalSupply * 2 / 100;

    initPresale();
    initBonuses();
  }

  function initPresaleItem(address addr, uint256 eth, uint256 tokens) internal{
        presale[addr] = PresaleItem(eth, tokens);
        presaleAddresses.push(addr);
  }

  function initPresale() internal {
        initPresaleItem(0xa4dba833494db5a101b82736bce558c05d78479,  1, 10);
        initPresaleItem(0xb0b5594fb4ff44ac05b2ff65aded3c78a8a6b5a5, 3, 30);
        for(uint i = 0; i < presaleAddresses.length; i++){
                PresaleItem memory item = presale[presaleAddresses[i]];
                forSaleLeft -= item.tokens;
                totalCollected += item.eth;
                totalSold += item.tokens;
        }
  }

// Here goes ICrowdsaleProcessor implementation

  // returns address of crowdsale token. The token must be ERC20-compliant
  function getToken()
    public
    returns(address)
  {
    return address(token);
  }

  // called by CrowdsaleController to transfer reward part of
  // tokens sold by successful crowdsale to Forecasting contract.
  // This call is made upon closing successful crowdfunding process.
  function mintTokenRewards(
    address _contract,  // Forecasting contract
    uint256 _amount     // agreed part of totalSold which is intended for rewards
  )
    public
    onlyManager() // manager is CrowdsaleController instance
  {
    // crowdsale token is mintable in this example, tokens are created here
    forSaleLeft -= _amount;
    token.transferByAdmin(address(token), _contract, _amount);
  }

  // transfers crowdsale token from mintable to transferrable state
  function releaseTokens()
    public
    onlyManager()             // manager is CrowdsaleController instance
    hasntStopped()            // crowdsale wasn't cancelled
    whenCrowdsaleSuccessful() // crowdsale was successful
  {
    // see token example
    //token.release();
  }

  function () payable public {
    require(msg.value > 0);
    sellTokens(msg.sender, msg.value);
  }

  function sellTokens(address _recepient, uint256 _value)
    internal
    hasBeenStarted()
    hasntStopped()
    whenCrowdsaleAlive()
    whitelistedOnly()
  {
    uint256 newTotalCollected = totalCollected + _value;

    if (hardCap < newTotalCollected) {
      uint256 refund = newTotalCollected - hardCap;
      uint256 diff = _value - refund;
      _recepient.transfer(refund);
      _value = diff;
    }

    uint256 tokensSold = _value / tokensPerEthPrice;
    updateCurrentBonusPeriod();
    if (currentBonusPeriod.fromTimestamp != INVALID_FROM_TIMESTAMP)
      tokensSold += tokensSold * currentBonusPeriod.bonusNumerator / currentBonusPeriod.bonusDenominator;

    token.transferByAdmin(address(token), _recepient, tokensSold);
    participants[_recepient] += _value;
    totalCollected += _value;
    totalSold += tokensSold;
  }

  // project's owner withdraws ETH funds to the funding address upon successful crowdsale
  function withdraw(
    uint256 _amount // can be done partially
  )
    public
    onlyOwner() // project's owner
    hasntStopped()  // crowdsale wasn't cancelled
    whenCrowdsaleSuccessful() // crowdsale completed successfully
  {
    require(_amount <= this.balance);
    fundingAddress.transfer(_amount);
  }

  // backers refund their ETH if the crowdsale was cancelled or has failed
  function refund()
    public
  {
    // either cancelled or failed
    require(stopped || isFailed());

    uint256 amount = participants[msg.sender];

    // prevent from doing it twice
    require(amount > 0);
    participants[msg.sender] = 0;

    msg.sender.transfer(amount);
  }
}
