// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract EvolvingNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    struct EvolutionRecord {
        string cid;
        bytes32 contentHash;
        uint256 timestamp;
    }

    mapping(uint256 => EvolutionRecord[]) public evolutionHistory;

    mapping(uint256 => string) private _tokenURIs;

    event EvolutionCommitted(uint256 indexed tokenId, string newCid, bytes32 newHash);

    event EvolutionSignal(uint256 indexed tokenId, string signalType, uint256 signalValue);

    constructor(address initialOwner)
        ERC721("EvolvingArt", "EVOLV")
        Ownable(initialOwner)
    {}

function safeMint(address to, string memory initialCid, bytes32 initialHash)
    public
    onlyOwner
    returns (uint256) 
{
    uint256 tokenId = _tokenIdCounter.current();
    _tokenIdCounter.increment();

    _safeMint(to, tokenId); 
    _commitEvolution(tokenId, initialCid, initialHash);

    return tokenId; 
}


    function commitEvolution(uint256 tokenId, string memory newCid, bytes32 newHash)
        public
        onlyOwner
        returns (bool)
    {
        require(_ownerOf(tokenId) != address(0), "EvolvingNFT: Token does not exist");
        
        _commitEvolution(tokenId, newCid, newHash);
        return true;
    }

    function _commitEvolution(uint256 tokenId, string memory newCid, bytes32 newHash)
        internal
    {
        _tokenURIs[tokenId] = newCid;

        evolutionHistory[tokenId].push(
            EvolutionRecord({
                cid: newCid,
                contentHash: newHash,
                timestamp: block.timestamp
            })
        );

        emit EvolutionCommitted(tokenId, newCid, newHash);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        
        ownerOf(tokenId); 
        return _tokenURIs[tokenId];
    }

    function getEvolutionHistory(uint256 tokenId)
        public
        view
        returns (EvolutionRecord[] memory)
    {
        return evolutionHistory[tokenId];
    }
    
    function signalEvolutionInterest(uint256 tokenId, uint256 votePower) public {
        emit EvolutionSignal(tokenId, "VOTE_INTEREST", votePower);
    }
}
