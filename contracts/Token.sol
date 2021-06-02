//SPDX-License-Identifier: MIT-0
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Token is ERC721 {
    string public uri;
    uint256 public tokenId;
    address public owner;

    constructor(string memory _uri) ERC721("Dbilia Token", "DBT") {
        uri = _uri;
    }

    function mint(address _to, uint256 _tokenId) public {
        _mint(_to, _tokenId);
        tokenId = _tokenId;
        owner = _to;
    }

    function _baseURI() override internal view returns(string memory) {
        return uri;
    }
}