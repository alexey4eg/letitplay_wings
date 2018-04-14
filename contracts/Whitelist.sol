pragma solidity ^0.4.19;
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
contract Whitelist is Ownable {
  mapping(address => bool) public whitelist;
  function AddToWhiteList(address _addr) public onlyOwner {
      whitelist[_addr] = true;
  }

  modifier whitelistedOnly {
    require(whitelist[msg.sender]);
    _;
  }
}
