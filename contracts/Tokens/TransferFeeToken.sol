// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

// Third Party
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract TokenFeeToken is ERC20 {
    address public admin;

    constructor() ERC20('Fee Token', 'FEE') {
        _mint(msg.sender, 10000 * 10**18);
        admin = msg.sender;
    }
}