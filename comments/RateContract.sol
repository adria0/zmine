contract RateContract is Authorizable {
  uint rate = 6000 ether;

  function updateRate (uint _rate) public onlyAuthorized {
    require(rate != _rate);
    rate = _rate;
  }

  function getRate () public constant returns (uint) {
    return rate;
  }
}