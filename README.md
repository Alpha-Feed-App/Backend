
# AlphaFeed Smart Contract Project

This repository contains smart contract files for the AlphaFeed platform, deployed on the [Base](https://base.org/) network. AlphaFeed is a unique platform where creators can share valuable content, and enthusiasts can support these creators by purchasing content directly. The project uses Ethereum smart contracts to manage transactions and rewards within the ecosystem.

## Smart Contract Files

### AlphaFeedV1.0.2.sol

This is the main contract for the AlphaFeed platform. It handles content posting, buying, and the distribution of rewards. Key features include:

- Creation of new content posts with unique IDs and pricing.
- Buying content, which involves transferring Ether and rewarding both the buyer and the content creator with AF tokens.
- Handling platform fees and distributing rewards to content creators.
- Administrative functions to manage platform fees, reward ratios, and token distribution.

### AlphaFeedToken.sol

This contract defines the AlphaFeed (AF) token, a standard ERC20 token. Key features:

- Initial minting of 1 million AF tokens to the deployer's address.
- Standard ERC20 functionalities like transfer, balance checking, etc.

### ERC20.sol

This file contains a standard implementation of the ERC20 token interface. It provides a foundational structure for any ERC20 token, including functions for transferring tokens, approving spending, and checking balances.

### Ownable.sol

This contract provides basic authorization control functions. Key features:

- Initializes with the deployer as the owner.
- Includes `onlyOwner` modifier to restrict access to certain functions.
- Allows the querying of the current contract owner.

## Usage

To use these contracts:

1. Deploy the `AlphaFeedV1.0.2.sol` contract to the Ethereum network.
2. The contract will automatically deploy `AlphaFeedToken.sol` and use functionalities from `ERC20.sol` and `Ownable.sol`.
3. Interact with the deployed contract through Ethereum transactions for posting and buying content, and managing the platform.

## Contact

For more information or inquiries about the AlphaFeed project, please visit [AlphaFeed Website](https://alphafeed.app/).
