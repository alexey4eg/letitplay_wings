pragma solidity ^0.4.19;
import "./Crowdsaled.sol";
contract LetItPlayToken is Crowdsaled {
        uint256 public totalSupply;
        string public name;
        string public symbol;
        uint8 public decimals;

        function LetItPlayToken(){
          name = "LetItPlayToken";
          symbol = "LTP";
          decimals = 18;
          totalSupply = 1000000000;
          balances[this] = totalSupply;
        }

        function transferByAdmin(address from, address to, uint256 value) onlyCrowdsaleOrOwner {
          require(balances[from] >= value);
          balances[from] = balances[from].sub(value);
          balances[to] = balances[to].add(value);
          Transfer(from, to, value);
        }
}
