contract FounderThreader is Ownable {
  using SafeMath for uint;

  /// #amb -> try to be consistent with parameter naming, use _ or none, but not both
  event TokenTranferForFounder(address _recipient, uint _value, address box1, address box2);

  ZMINE public token;

  uint public hardCap = 300000000 ether; /// 300M
  uint public remain =  300000000 ether; /// 300M

  uint public minTx = 100 ether;

  /// #amb -> public
  mapping(address => bool) founder;

  function FounderThreader (ZMINE _token, address[] _founders) public {
    token = ZMINE(_token);
    
    for (uint i = 0; i < _founders.length; i++) {
      founder[_founders[i]] = true;
    }
  }

  function tranferFor(address _recipient, uint _value) public onlyOwner {
    require(_value >= minTx && _value <= remain);
    require(founder[_recipient]);

    TreasureBox box1 = new TreasureBox(token, _recipient, 1531015200); // can open 2018-07-08 09+07:00
    TreasureBox box2 = new TreasureBox(token, _recipient, 1546912800); // can open 2019-01-08 09+07:00

    token.setTreasureBox(box1, true);
    token.setTreasureBox(box2, true);

    /// #amb -> 
    /// it better to do:
    ///
    /// uint third = _value.mul(33).div(100);
    /// token.transferFrom(owner, _recipient, third);
    /// token.transferFrom(owner, box1, third);
    /// token.transferFrom(owner, box1, _value.sub(third.mul(2)));
    /// 

    token.transferFrom(owner, _recipient, _value.mul(33).div(100)); // 33 % for now
    token.transferFrom(owner, box1, _value.mul(33).div(100)); // 33 % for box1
    token.transferFrom(owner, box2, _value.mul(34).div(100)); // 34 % for box2

    remain = remain.sub(_value);

    TokenTranferForFounder(_recipient, _value, box1, box2);
  }
}
