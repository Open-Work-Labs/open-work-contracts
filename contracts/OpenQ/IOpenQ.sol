// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import '../Bounty/Bounty.sol';

interface IOpenQ {
    // Events
    event BountyCreated(
        string bountyId,
        string organization,
        address issuerAddress,
        address indexed bountyAddress,
        uint256 bountyMintTime
    );

    event BountyClosed(
        string bountyId,
        address indexed bountyAddress,
        string organization,
        address closer,
        uint256 bountyClosedTime
    );

    event TokenDepositReceived(
        bytes32 depositId,
        address indexed bountyAddress,
        string bountyId,
        string organization,
        address tokenAddress,
        uint256 receiveTime,
        address sender,
        uint256 expiration,
        uint256 volume
    );

    event NFTDepositReceived(
        bytes32 depositId,
        address indexed bountyAddress,
        string bountyId,
        string organization,
        address tokenAddress,
        uint256 receiveTime,
        address sender,
        uint256 expiration,
        uint256 tokenId
    );

    event DepositRefunded(
        bytes32 depositId,
        string bountyId,
        address indexed bountyAddress,
        string organization,
        uint256 refundTime
    );

    event DepositClaimed(
        bytes32 depositId,
        string bountyId,
        address indexed bountyAddress,
        string organization,
        address closer,
        uint256 payoutTime
    );

    event WinnerSelected(
        address _payoutAddress,
        address _funder,
        string bountyId,
        address indexed bountyAddress,
        uint256 selectionTime
    );

    function mintBounty(string calldata, string calldata)
        external
        returns (address);

    function fundBountyNFT(
        address,
        address,
        uint256,
        uint256
    ) external returns (bool);

    function fundBountyToken(
        address,
        address,
        uint256,
        uint256
    ) external payable returns (bool success);

    function claimBounty(string calldata, address) external;

    function submitMethod(string calldata, address) external returns (bytes32);

    function selectWinner(address, bytes32) external returns (address);

    function refundDeposit(bytes32, address) external returns (bool);

    function bountyIsOpen(string memory) external view returns (bool);
}
