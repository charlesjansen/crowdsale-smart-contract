pragma solidity ^0.4.11;


import './crowdsale/FinalizableCrowdsale.sol';
import './math/SafeMath.sol';
import './SirinSmartToken.sol';


contract SirinCrowdsale is FinalizableCrowdsale {

    address public walletFounder;
    address public walletDeveloper;
    address public walletBounties;
    address public walletReserve;

    uint256 public constant MAX_TOKEN_GRANTEES = 100;
    address[] public granteesMapKeys;
    mapping (address => uint256) public granteesMap;

    event GrantAdded(address indexed _grantee, uint256 _amount);
    event GrantUpdated(address indexed _grantee, uint256 _oldAmount, uint256 _newAmount);
    event GrantDeleted(address indexed _grantee, uint256 _hadAmount);

    // =================================================================================================================
    //                                      Impl LimitedTransferToken
    // =================================================================================================================

    function SirinCrowdsale(uint256 _startTime,
    uint256 _endTime,
    address _wallet,
    address _walletFounder,
    address _walletDeveloper,
    address _walletBounties,
    address _walletReserve) Crowdsale(_startTime, _endTime, 1, _wallet){
        walletFounder = _walletFounder;
        walletDeveloper = _walletDeveloper;
        walletBounties = _walletBounties;
        walletReserve = _walletReserve;
    }

    // =================================================================================================================
    //                                      Impl Crowdsale
    // =================================================================================================================

    // @return the crowdsale rate with bonus
    //
    // @Override
    function getRate() internal returns (uint256) {
        uint256 newRate = rate;

        if (now < (24 hours)) {
            newRate = 1000;
        }else if (now < 2 days) {
            newRate = 950;
        }else if (now < 3 days) {
            newRate = 900;
        }else if (now < 4 days) {
            newRate = 855;
        }else if (now < 5 days) {
            newRate = 810;
        }else if (now < 6 days) {
            newRate = 770;
        }else if (now < 7 days) {
            newRate = 730;
        }else if (now < 8 days) {
            newRate = 690;
        }else if (now < 9 days) {
            newRate = 650;
        }else if (now < 10 days) {
            newRate = 615;
        }else if (now < 11 days) {
            newRate =580;
        }else if (now < 12 days) {
            newRate = 550;
        }else if (now < 13 days) {
            newRate = 525;
        }else if (now < 14 days) {
            newRate = 500;
        }else{
            newRate = 500;
        }
        return rate;
    }

    // =================================================================================================================
    //                                      Impl FinalizableCrowdsale
    // =================================================================================================================

    //@Override
    function finalization()  internal {

        //granting bonuses for the pre-ico grantees:
        for(uint i=0; i < granteesMapKeys.length; i++){
            token.issue(granteesMapKeys[i], granteesMap[granteesMapKeys[i]]);
        }

        uint256 newTotalSupply = SafeMath.div(SafeMath.mul(token.totalSupply(), 250), 100);

        //25% from totalSupply which is 10% of the total number of SRN tokens will be allocated to the founders and
        //team and will be gradually vested over a 12-month period
        token.issue(walletFounder,SafeMath.div(SafeMath.mul(newTotalSupply, 10),100));

        //25% from totalSupply which is 10% of the total number of SRN tokens will be allocated to OEM’s, Operating System implementation,
        //SDK developers and rebate to device and Shield OS™ users
        token.issue(walletDeveloper,SafeMath.div(SafeMath.mul(newTotalSupply, 10),100));

        //12.5% from totalSupply which is 5% of the total number of SRN tokens will be allocated to professional fees and Bounties
        token.issue(walletBounties, SafeMath.div(SafeMath.mul(newTotalSupply, 5), 100));

        //87.5% from totalSupply which is 35% of the total number of SRN tokens will be allocated to SIRIN LABS,
        //and as a reserve for the company to be used for future strategic plans for the created ecosystem,
        token.issue(walletReserve, SafeMath.div(SafeMath.mul(newTotalSupply, 35), 100));

        // Re-enable transfers after the token sale.
        token.disableTransfers(false);

        isFinalized = true;
    }

    // =================================================================================================================
    //                                      External Methods
    // =================================================================================================================
    /// @dev Adds/Updates address for  granted tokens.
    /// @param _grantee address The address of the token grantee.
    /// @param _value uint256 The value of the grant.
    function addUpdateGrantee(address _grantee, uint256 _value) external onlyOwner {
        require(_grantee != address(0));
        require(_value > 0);
        require(granteesMapKeys.length + 1 <= MAX_TOKEN_GRANTEES);

        //Adding new key if not presented:
        if(granteesMap[_grantee] == 0){
            granteesMapKeys.push(_grantee);
            GrantAdded(_grantee, _value);
        }
        else{
            GrantUpdated(_grantee,granteesMap[_grantee],_value);
        }

        granteesMap[_grantee] = _value;
    }

    /// @dev deletes address for granted tokens.
    /// @param _grantee address The address of the token grantee
    function deleteGrantee(address _grantee) external onlyOwner {
        require(_grantee != address(0));
        require(granteesMap[_grantee] != 0);

        GrantDeleted(_grantee, granteesMap[_grantee]);
        //delete from the map:
        delete granteesMap[_grantee];

        //delete from the array (keys):
        uint index;
        for(uint i=0; i < granteesMapKeys.length; i++){
            if(granteesMapKeys[i] == _grantee)
            {
                index = i;
                break;
            }
        }
        granteesMapKeys[index] = granteesMapKeys[granteesMapKeys.length-1];
        delete granteesMapKeys[granteesMapKeys.length-1];
        granteesMapKeys.length--;
    }
}
