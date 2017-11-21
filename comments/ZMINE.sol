pragma solidity ^0.4.11;

contract ZMINE is AirDropToken {
  string public name = "ZMINE Token";
  string public symbol = "ZMN"; 

  /// #amb EIP20 says decimals is an uint8
  uint public decimals = 18;

  uint256 public totalSupply = 1000000000 ether; // 1,000,000,000 ^ 18 %amb checked constant

  function ZMINE() public {
    balances[owner] = totalSupply;
  }

  /**
   * burn token if token is not sold out after ico
   * #amb -> the burning is not enforced by the contract logic
   */
  function burn(uint _amount) public onlyOwner {
    require(balances[owner] >= _amount);
    balances[owner] = balances[owner] - _amount; /// #amb use safemath
    totalSupply = totalSupply - _amount;
    /// #amb : generate Transfer event log Transfer(onwer,0x0,_amount)
  }
}
