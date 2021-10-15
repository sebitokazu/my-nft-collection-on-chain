// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";
// We first import some OpenZeppelin Contracts.
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// We need to import the helper functions from the contract that we copy/pasted.
import { Base64 } from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {

  // Magic given to us by OpenZeppelin to help us keep track of tokenIds.
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  uint256 constant public MAX_SUPPLY = 100;


    // This is our SVG code. All we need to change is the word that's displayed. Everything else stays the same.
  // So, we make a baseSvg variable here that all our NFTs can use.
  string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><defs><pattern id='pattern' width='40' height='40' viewBox='0 0 40 40' patternUnits='userSpaceOnUse' patternTransform='rotate(0)'>";

  string wordsFilter = "<filter x='0' y='0' width='1' height='1' id='solid'><feFlood flood-color='black' result='bg' /><feMerge><feMergeNode in='bg'/><feMergeNode in='SourceGraphic'/></feMerge></filter>";
  string textStyleOpenSvg = "</defs><rect fill='url(#pattern)' height='200%' width='200%'/><style>.base {fill: white; font-family: Ubuntu; font-size: 14px; font-weight: 700; background-color:black;}</style><text filter='url(#solid)' x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";
  string closeSvg="</text></svg>";

  // Pick some random funny words, names of anime characters, foods you like, whatever!
  // Patterns from "https://doodad.dev/pattern-generator/"
  string[] bgs = [
    "<rect width='100%' height='100%' fill='#2a4365'/><path d='M0 29a 9-9 0 0 0 9-9a 11-11 0 0 1 11-11v2a-9 9 0 0 0-9 9a-11 11 0 0 1-11 11zM0 69a 9-9 0 0 0 9-9a 11-11 0 0 1 11-11v2a-9 9 0 0 0-9 9a-11 11 0 0 1-11 11z' fill='#1a202c'/><path d='M20 29.5a 9.5-9.5 0 0 0 9.5-9.5a 10.5-10.5 0 0 1 10.5-10.5v1a-9.5 9.5 0 0 0-9.5 9.5a-10.5 10.5 0 0 1-10.5 10.5z' fill='#ecc94b'/></pattern>",
    "<rect width='100%' height='100%' fill='#2d3748'/><circle cx='34' cy='20' r='4' fill='#4a5568'/><circle cx='6' cy='20' r='4' fill='#4a5568'/><circle cx='20' cy='34' r='4' fill='#4a5568'/><circle cx='20' cy='6' r='4' fill='#4a5568'/><circle cx='34' cy='6' r='4' fill='#1a202c'/><circle cx='6' cy='34' r='4' fill='#1a202c'/><circle cx='34' cy='34' r='4' fill='#1a202c'/><circle cx='6' cy='6' r='4' fill='#1a202c'/></pattern>",
    "<rect width='100%' height='100%' fill='#5D4037'/><path d='M0 40h-10v-60h60L40 0L34 6h-28v28z' fill='#3E2723'/><path d='M40 0v10h60v60L0 40L6 34h28v-28z' fill='#795548'/><path d='M40 0v10h60v60L0 40L0 40h40v-40z' fill='#3E2723'/><path d='M0 40h-10v-60h60L40 0L40 0h-40v40z' fill='#795548'/></pattern>",
    "<rect width='100%' height='100%' fill='#1c7ed6'/><path d='M-10 30h60v4h-60zM-10-10h60v4h-60' fill='#fcc419'/><path d='M-10 18h60v4h-60zM-10-22h60v4h-60z' fill='#1864ab'/></pattern>",
    "<rect width='100%' height='100%' fill='#702459'/><path d='M0 8.5a 11.5 11.5 0 0 1 11.5 11.5a 8.5 8.5 0 0 0 8.5 8.5v3a-11.5-11.5 0 0 1-11.5-11.5a-8.5-8.5 0 0 0-8.5-8.5z' fill='#f6e05e'/><path d='M20 28.5a 8.5-8.5 0 0 0 8.5-8.5a 11.5-11.5 0 0 1 11.5-11.5v3a-8.5 8.5 0 0 0-8.5 8.5a-11.5 11.5 0 0 1-11.5 11.5zM20 68.5a 8.5-8.5 0 0 0 8.5-8.5a 11.5-11.5 0 0 1 11.5-11.5v3a-8.5 8.5 0 0 0-8.5 8.5a-11.5 11.5 0 0 1-11.5 11.5z' fill='#d69e2e'/></pattern>"
  ];
  string[] firstWords = ["Bullish", "Bearish", "Epic", "Rocket", "Dip"];
  string[] secondWords = ["ETH", "BTC", "DOT", "LUNA", "VET"];

  event NewEpicNFTMinted(address sender, uint256 tokenId);

  // We need to pass the name of our NFTs token and it's symbol.
  constructor() ERC721 ("MochiNFT", "MOCHI") {
    console.log("Guau!");
  }

    // I create a function to randomly pick a word from each array.
  function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
    // I seed the random generator. More on this in the lesson. 
    uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
    // Squash the # between 0 and the length of the array to avoid going out of bounds.
    rand = rand % firstWords.length;
    return firstWords[rand];
  }

  function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
    rand = rand % secondWords.length;
    return secondWords[rand];
  }

    function pickRandomBackground(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("BACKGROUND", Strings.toString(tokenId))));
    rand = rand % bgs.length;
    return bgs[rand];
  }

  function random(string memory input) internal pure returns (uint256) {
      return uint256(keccak256(abi.encodePacked(input)));
  }

    // A function our user will hit to get their NFT.
  function makeAnEpicNFT() public {
     // Get the current tokenId, this starts at 0.
    uint256 newItemId = _tokenIds.current();

    require(newItemId < MAX_SUPPLY, "All NFTs were minted");


    // We go and randomly grab one word from each of the three arrays.
    string memory background = pickRandomBackground(newItemId);
    string memory first = pickRandomFirstWord(newItemId);
    string memory second = pickRandomSecondWord(newItemId);
    string memory combinedWord = string(abi.encodePacked(first, second));


   // I concatenate it all together, and then close the <text> and <svg> tags.
    string memory finalSvg = string(abi.encodePacked(baseSvg, background, wordsFilter,textStyleOpenSvg, first, second, closeSvg));
    // Get all the JSON metadata in place and base64 encode it.
    string memory json = Base64.encode(
        bytes(
            string(
                abi.encodePacked(
                    '{"name": "',
                    // We set the title of our NFT as the generated word.
                    combinedWord,
                    '", "description": "A random feeling on some tokens", "image": "data:image/svg+xml;base64,',
                    // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                    Base64.encode(bytes(finalSvg)),
                    '"}'
                )
            )
        )
    );

    // Just like before, we prepend data:application/json;base64, to our data.
    string memory finalTokenUri = string(
        abi.encodePacked("data:application/json;base64,", json)
    );

    console.log("\n--------------------");
    console.log(finalTokenUri);
    console.log("--------------------\n");

    _safeMint(msg.sender, newItemId);
    
    // Update your URI!!!
    _setTokenURI(newItemId, finalTokenUri);

    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

    // Increment the counter for when the next NFT is minted.
    _tokenIds.increment();

    emit NewEpicNFTMinted(msg.sender, newItemId);
  }

    function getTotalNFTsMinted() public view returns(uint256){
      return _tokenIds.current();
    }
}