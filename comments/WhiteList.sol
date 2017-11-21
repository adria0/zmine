/**
 * @title WhiteList
 * @dev The WhiteList contract has whiteListed addresses, and provides basic whiteListStatus control
 * functions, this simplifies the implementation of "multiple user permissions".
 */
contract WhiteList is Authorizable {
  mapping(address => bool) whiteListed;
  
  event WhiteListSet(address addressWhiteListed, bool whiteListStatus);

  /**
   * @dev The WhiteList constructor sets the first `whiteListed` of the contract to the sender
   * account.
   */ 
  function WhiteList() public {
	  whiteListed[msg.sender] = true;
  }

  /**
   * @dev Throws if called by any account other than the whiteListed.
   */
  modifier onlyWhiteListed() {
    require(whiteListed[msg.sender]);
    _;
  }

  function isWhiteListed(address _address) public constant returns(bool) {
    return whiteListed[_address];
  }

 /**
   * @dev Allows the current owner to set an whiteListStatus.
   * @param addressWhiteListed The address to change whiteListStatus.
   */
  function setwhiteListed(address addressWhiteListed, bool whiteListStatus) onlyAuthorized public {
    require(whiteListed[addressWhiteListed] != whiteListStatus);
    WhiteListSet(addressWhiteListed, whiteListStatus);
    whiteListed[addressWhiteListed] = whiteListStatus;
  }
  
}
