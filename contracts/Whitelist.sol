pragma solidity ^0.4.19;
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
contract Whitelist is Ownable {
  mapping(address => bool) public whitelist;
  address public whitelistManager;
  function AddToWhiteList(address _addr) public {
      require(msg.sender == whitelistManager || msg.sender == owner);
      whitelist[_addr] = true;
  }

  function AssignWhitelistManager(address _addr) public onlyOwner {
      whitelistManager = _addr;
  }

  modifier whitelistedOnly {
    require(whitelist[msg.sender]);
    _;
  }
}
