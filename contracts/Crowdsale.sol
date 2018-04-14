pragma solidity ^0.4.19;
import "wings-integration/contracts/BasicCrowdsale.sol";
import "./LetItPlayToken.sol";
import "./WithBonusPeriods.sol";
import "./Whitelist.sol";

contract Crowdsale is BasicCrowdsale, Whitelist, WithBonusPeriods {

  struct Investor {
    uint256 weiDonated;
    uint256 tokensGiven;
  }

  mapping(address => Investor) participants;

  uint256 tokenRateWei;
  LetItPlayToken token;

  // Ctor. In this example, minimalGoal, hardCap, and price are not changeable.
  // In more complex cases, those parameters may be changed until start() is called.
  function Crowdsale(
    uint256 _minimalGoal,
    uint256 _hardCap,
    uint256 _tokenRateWei,
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
    tokenRateWei = _tokenRateWei;
    token = LetItPlayToken(_token);
  }

  /*function initPresaleItem(address addr, uint256 eth, uint256 tokens) internal{
        participants[addr].weiDonated += eth;
        participants[addr].tokensGiven += tokens;
        token.transferByCrowdsale(addr, tokens);
  }

  function initPresale() public onlyOwner() {
        initPresaleItem(0xa4dba833494db5a101b82736bce558c05d78479,  1, 10);
        initPresaleItem(0xb0b5594fb4ff44ac05b2ff65aded3c78a8a6b5a5, 3, 30);
  }*/

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
    token.transferByCrowdsale(_contract, _amount);
  }

  // transfers crowdsale token from mintable to transferrable state
  function releaseTokens()
    public
    onlyManager()             // manager is CrowdsaleController instance
    hasntStopped()            // crowdsale wasn't cancelled
    whenCrowdsaleSuccessful() // crowdsale was successful
  {
    // see token example
    token.releaseForTransfer();
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

    uint256 tokensSold = _value / tokenRateWei;
    updateCurrentBonusPeriod();
    if (currentBonusPeriod.fromTimestamp != INVALID_FROM_TIMESTAMP)
      tokensSold += tokensSold * currentBonusPeriod.bonusNumerator / currentBonusPeriod.bonusDenominator;

    token.transferByCrowdsale(_recepient, tokensSold);
    participants[_recepient].weiDonated += _value;
    participants[_recepient].tokensGiven += tokensSold;
    totalCollected += _value;
    totalSold += tokensSold;
  }

  // project's owner withdraws ETH funds to the funding address upon successful crowdsale
  function withdraw(uint256 _amount) public // can be done partially
    onlyOwner() // project's owner
    hasntStopped()  // crowdsale wasn't cancelled
    whenCrowdsaleSuccessful() // crowdsale completed successfully
  {
    require(_amount <= address(this).balance);
    fundingAddress.transfer(_amount);
  }

  // backers refund their ETH if the crowdsale was cancelled or has failed
  function refund() public
  {
    // either cancelled or failed
    require(stopped || isFailed());

    uint256 weiDonated = participants[msg.sender].weiDonated;
    uint256 tokens = participants[msg.sender].tokensGiven;

    // prevent from doing it twice
    require(weiDonated > 0);
    //DEBUG(weiDonated);
    participants[msg.sender].weiDonated = 0;
    participants[msg.sender].tokensGiven = 0;

    msg.sender.transfer(weiDonated);

    //this must be approved by investor
    token.transferFromByCrowdsale(msg.sender, token.forSale(), tokens);
  }
}
