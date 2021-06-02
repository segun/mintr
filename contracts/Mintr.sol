//SPDX-License-Identifier: MIT-0
pragma solidity >=0.7.0 <0.9.0;

import "./Token.sol";
import './console.sol';

contract Mintr {
    address owner;

    mapping(uint256 => mapping (uint256 => address)) tokenUserIdMapping;
    mapping(address => mapping (uint256 => address)) tokenUserAddressMapping;
    mapping(uint256 => uint256) cardEditionMapping;

    constructor(address _dbilia) {
        owner = _dbilia;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only Dbilia can call this method");
        _;
    }

    function mintWithUSD(
        uint256 _userId,
        uint256 _cardId,
        uint256 _edition,
        string memory _tokenUri
    ) public onlyOwner {
        require(_userId > 0, "User ID can not be  0");
        require(_cardId > 0, "Card ID can not be  0");
        address tokenAddress = tokenUserIdMapping[_userId][_edition];
        require(tokenAddress == address(0), 'Token with edition already exists');
        address tokenOwner = msg.sender;
        cardEditionMapping[_cardId] = _edition;
        Token t = new Token(_tokenUri);
        t.mint(owner, _edition);
        tokenUserIdMapping[_userId][_edition] = address(t);
        tokenUserAddressMapping[tokenOwner][_edition] = address(t);
    }

    function mintWithETH(
        uint256 _cardId,
        uint256 _edition,
        string memory _tokenUri        
    ) public payable {
        require(msg.value == 0.2 ether, 'Must Pay Fees');
        require(_cardId > 0, "Card ID can not be  0");   
        address tokenOwner = msg.sender;
        address tokenAddress = tokenUserAddressMapping[tokenOwner][_edition];
        require(tokenAddress == address(0), 'Token with edition already exists');                
        cardEditionMapping[_cardId] = _edition;
        Token t = new Token(_tokenUri);
        t.mint(tokenOwner, _edition);   
        tokenUserAddressMapping[tokenOwner][_edition] = address(t);              
    }

    // get Token address from userId
    function getTokenAddressFromUserId(uint256 _userId, uint256 _edition) public view returns (address) {
        address tokenAddress = tokenUserIdMapping[_userId][_edition];
        require(tokenAddress != address(0), 'Dbilia is not the custodian of token');
        Token t = Token(tokenAddress);
        require(t.tokenId() != 0, 'Token ID can not be found from Token  Address');
        require(t.owner() != address(0), 'Owner Address can not be found from Token Address');
        return tokenAddress;
    }

    // get Token address from owner
    function getTokenAddressFromOwner(address _owner, uint256 _edition) public view returns (address) {
        address tokenAddress = tokenUserAddressMapping[_owner][_edition];
        require(tokenAddress != address(0), 'No Token found for Address');
        Token t = Token(tokenAddress);
        require(t.tokenId() != 0, 'Token ID can not be found from Token  Address');
        require(t.owner() != address(0), 'Owner Address can not be found from Token Address');
        return tokenAddress;
    }    
}
