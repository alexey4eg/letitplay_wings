pragma solidity ^0.4.19;
import "zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
contract Crowdsaled is Ownable, StandardToken {
        address public crowdsaleContract = address(0);
        function Crowdsaled(){
        }

        modifier onlyCrowdsale{
          require(msg.sender == crowdsaleContract);
          _;
        }

        modifier onlyCrowdsaleOrOwner {
          require((msg.sender == crowdsaleContract) || (msg.sender == owner));
          _;
        }

        function setCrowdsale(address crowdsale) onlyOwner {
                crowdsaleContract = crowdsale;
        }
}
