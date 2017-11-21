contract TreasureBox {
  // ERC20 basic token contract being held
  /// #amb -> public variable
  ZMINE token;
  // beneficiary of tokens after they are released
  address public beneficiary;
  // timestamp where token release is enabled
  uint public releaseTime;

  function TreasureBox(ZMINE _token, address _beneficiary, uint _releaseTime) public {
    // require(_releaseTime > now); // prevent error
    /// #amb -> comments are confusing, why this precondition is removed?
    ///         add checks, e.g. _beneficiary or _token is ZERO
    ///         TreasureBox is well built but correctness is not self-embeded*
    token = _token;
    beneficiary = _beneficiary;
    releaseTime = _releaseTime;
  }

  function claim() external {
    // require(msg.sender == beneficiary); // any one can claim
    /// #amb -> in general is better not to let functions open
    require(now >= releaseTime);

    uint amount = token.balanceOf(this);
    require(amount > 0);

    token.transfer(beneficiary, amount);
  }

  function avalible() public constant returns (bool) {
    return (now >= releaseTime);
  }

  function amount() public constant returns (uint256) {
    return token.balanceOf(this);
  }
}
