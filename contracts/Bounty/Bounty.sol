// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

// Third Party
import '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol';

abstract contract Bounty is
    ReentrancyGuardUpgradeable,
    IERC721ReceiverUpgradeable
{
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    enum BountyStatus {
        OPEN,
        SELECTED,
        CLOSED
    }

    // OpenQ Proxy Contract
    address public openQ;

    // Bounty Metadata
    string public bountyId;
    uint256 public bountyCreatedTime;
    uint256 public bountySelectedTime;
    uint256 public bountyClosedTime;
    address public issuer;
    string public organization;
    address public closer;
    BountyStatus public status;

    // Deposit Data - A Deconstructed Deposit Struct
    mapping(bytes32 => address) public funder;
    mapping(bytes32 => address) public tokenAddress;
    mapping(bytes32 => uint256) public volume;
    mapping(bytes32 => uint256) public depositTime;
    mapping(bytes32 => bool) public refunded;
    mapping(bytes32 => bool) public claimed;
    mapping(bytes32 => address) public payoutAddress;
    mapping(bytes32 => uint256) public tokenId;
    mapping(bytes32 => uint256) public expiration;
    mapping(bytes32 => bool) public isNFT;
    mapping(bytes32 => address) public submissionIdToAddress;
    address[] public submitters;

    // Deposit Count and IDs
    bytes32[] public deposits;

    function initialize(
        string memory _bountyId,
        address _issuer,
        string memory _organization,
        address _openQ
    ) public initializer {
        require(bytes(_bountyId).length != 0, 'NO_EMPTY_BOUNTY_ID');
        require(bytes(_organization).length != 0, 'NO_EMPTY_ORGANIZATION');
        bountyId = _bountyId;
        issuer = _issuer;
        organization = _organization;
        openQ = _openQ;
        bountyCreatedTime = block.timestamp;
        __ReentrancyGuard_init();
    }

    function receiveFunds(
        address _funder,
        address _tokenAddress,
        uint256 _volume,
        uint256 _expiration
    ) public payable virtual returns (bytes32, uint256);

    function receiveNft(
        address _sender,
        address _tokenAddress,
        uint256 _tokenId,
        uint256 _expiration
    ) public virtual returns (bytes32);

    function refundDeposit(bytes32 _depositId, address _funder)
        external
        virtual
        returns (bool success);

    function submit() external virtual returns (bytes32 submissionId);

    function claim(address _payoutAddress, bytes32 depositId)
        external
        virtual
        returns (bool success);

    function close(address _payoutAddress)
        external
        virtual
        returns (bool success);

    // require check senders address
    function setSubmittal(bytes32 submittalId, address submitter)
        external
        virtual
    {
        submissionIdToAddress[submittalId] = submitter;
    }

    function select(bytes32 submissionId, string calldata _bountyId)
        external
        virtual
        returns (address _payoutAddress);

    function makeSelection() external virtual returns (bool success);

    // Transfer Helpers
    function _receiveERC20(
        address _tokenAddress,
        address _funder,
        uint256 _volume
    ) internal returns (uint256) {
        uint256 balanceBefore = getERC20Balance(_tokenAddress);
        IERC20 token = IERC20(_tokenAddress);
        token.safeTransferFrom(_funder, address(this), _volume);
        uint256 balanceAfter = getERC20Balance(_tokenAddress);
        require(balanceAfter >= balanceBefore, 'TOKEN_TRANSFER_IN_OVERFLOW');

        /* The reason we take the balanceBefore and balanceAfter rather than the raw volume
           is because certain ERC20 contracts ( e.g. USDT) take fees on transfers.
					 Therefore the volume received after transferFrom can be lower than the raw volume sent by the sender */
        return balanceAfter.sub(balanceBefore);
    }

    function _transferERC20(
        address _tokenAddress,
        address _payoutAddress,
        uint256 _volume
    ) internal {
        IERC20 token = IERC20(_tokenAddress);
        token.safeTransfer(_payoutAddress, _volume);
    }

    function _transferProtocolToken(address _payoutAddress, uint256 _volume)
        internal
    {
        payable(_payoutAddress).transfer(_volume);
    }

    function _receiveNft(
        address _tokenAddress,
        address _sender,
        uint256 _tokenId
    ) internal {
        IERC721 nft = IERC721(_tokenAddress);
        nft.safeTransferFrom(_sender, address(this), _tokenId);
    }

    function _transferNft(
        address _tokenAddress,
        address _payoutAddress,
        uint256 _tokenId
    ) internal {
        IERC721 nft = IERC721(_tokenAddress);
        nft.safeTransferFrom(address(this), _payoutAddress, _tokenId);
    }

    // Modifiers
    modifier onlyOpenQ() {
        require(msg.sender == openQ, 'Method is only callable by OpenQ');
        _;
    }

    // View Methods
    function _generateDepositId(address _sender, address _tokenAddress)
        internal
        view
        returns (bytes32)
    {
        return keccak256(abi.encode(_sender, _tokenAddress, deposits.length));
    }

    function _generateSubmissionId(address _sender)
        public
        view
        returns (bytes32)
    {
        // require (needs to be accessed by openQ and bountyV0)
        return
            keccak256(abi.encode(_sender, submitters.length, block.timestamp)); // add block.timestamp ?
    }

    function getERC20Balance(address _tokenAddress)
        public
        view
        returns (uint256 balance)
    {
        IERC20 token = IERC20(_tokenAddress);
        return token.balanceOf(address(this));
    }

    function getDeposits() public view returns (bytes32[] memory) {
        return deposits;
    }

    // changing the state
    function addSubmitter(address submitter) external {
        submitters.push(submitter);
    }

    function getSubmitters() public view returns (address[] memory) {
        return submitters;
    }

    // Revert any attempts to send unknown calldata
    fallback() external {
        revert();
    }

    receive() external payable {
        // React to receiving protocol token
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        return
            bytes4(
                keccak256('onERC721Received(address,address,uint256,bytes)')
            );
    }
}
