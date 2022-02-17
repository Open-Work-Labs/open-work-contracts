const { ethers } = require('hardhat');
const { optionalSleep } = require('./utils');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env.contracts') });

async function fundBounties() {
	console.log('\n------------------------------------------');
	console.log('FUNDING BOUNTIES with MOCK LINK and DUMMY ERC20');
	console.log('------------------------------------------');
	const MockLink = await ethers.getContractFactory('MockLink');
	const mockLink = await MockLink.attach(process.env.MOCK_LINK_TOKEN_ADDRESS);

	const MockDai = await ethers.getContractFactory('MockDai');
	const mockDai = await MockDai.attach(process.env.MOCK_DAI_TOKEN_ADDRESS);

	const OpenQ = await ethers.getContractFactory('OpenQV0');
	const openQ = await OpenQ.attach(process.env.OPENQ_ADDRESS);

	const githubIssueIds = ['I_kwDOE5zs-M480ik8', 'I_kwDOGAqhQc48U54v', 'I_kwDOGAqhQc48U5_r', 'I_kwDOGWnnz84-qyDq', 'I_kwDOGWnnz85CZwGJ', 'I_kwDOGWnnz85AkiDt'];
	const githubIssueIdsOtherOrgs = ['I_kwDOCHE8585AYvGo', 'I_kwDOGWnnz85AkkDW'];

	const bounty1Address = await openQ.bountyIdToAddress(githubIssueIdsOtherOrgs[0]);
	const bounty2Address = await openQ.bountyIdToAddress(githubIssueIds[1]);
	const bounty3Address = await openQ.bountyIdToAddress(githubIssueIds[5]);


	// Pre-load with some deposits
	const tenth = ethers.BigNumber.from('100000000000000000');
	const one = ethers.BigNumber.from('1000000000000000000');
	const two = ethers.BigNumber.from('2000000000000000000');
	const four = ethers.BigNumber.from('4000000000000000000');

	await mockLink.approve(bounty1Address, four);
	await optionalSleep(5000);

	await mockDai.approve(bounty1Address, four);
	await optionalSleep(5000);

	await mockLink.approve(bounty2Address, four);
	await optionalSleep(5000);

	await mockDai.approve(bounty2Address, four);
	await optionalSleep(5000);

	await mockLink.approve(bounty3Address, four);
	await optionalSleep(5000);

	await mockDai.approve(bounty3Address, four);
	await optionalSleep(5000);

	console.log('Funding approved for Client 1');
	await openQ.fundBountyToken(bounty1Address, mockLink.address, tenth, 1);
	await optionalSleep(5000);
	console.log('Funded  for Client 1');

	await openQ.fundBountyToken(bounty1Address, mockLink.address, tenth, 1);
	await optionalSleep(5000);

	await openQ.fundBountyToken(bounty1Address, mockDai.address, tenth, 1);
	await optionalSleep(5000);

	await openQ.fundBountyToken(bounty2Address, mockLink.address, tenth, 1);
	await optionalSleep(5000);

	await openQ.fundBountyToken(bounty2Address, mockDai.address, tenth, 1);
	await optionalSleep(5000);

	//await openQ.fundBountyToken(bounty2Address, ethers.constants.AddressZero, tenth, 1, { value: two });
	//await optionalSleep(5000);

	console.log('Funding for Client 1...');
	//await openQ.fundBountyToken(bounty3Address, ethers.constants.AddressZero, tenth, 1, { value: two });
	//await optionalSleep(5000);

	//await openQ.fundBountyToken(bounty3Address, ethers.constants.AddressZero, tenth, 1, { value: two });
	//await optionalSleep(5000);

	//await openQ.fundBountyToken(bounty3Address, mockDai.address, tenth, 1);
	//await optionalSleep(5000);

	//await openQ.fundBountyToken(bounty3Address, mockLink.address, tenth, 1);
	//await optionalSleep(5000);

	console.log('Funding succeeded for Client 1');

	// Contributor 2
	const [, contributor] = await ethers.getSigners();

	console.log('Transferring LINK and DERC20 to Client 2');
	await mockDai.transfer(contributor.address, one);
	await optionalSleep(5000);

	await mockLink.transfer(contributor.address, one);
	await optionalSleep(5000);
	console.log('Transfer to Client 2 succeeded');

	await mockLink.connect(contributor).approve(bounty1Address, one);
	await optionalSleep(5000);

	await mockDai.connect(contributor).approve(bounty1Address, two);
	await optionalSleep(5000);

	await mockLink.connect(contributor).approve(bounty2Address, one);
	await optionalSleep(5000);

	await mockDai.connect(contributor).approve(bounty2Address, two);
	await optionalSleep(5000);

	console.log('Funding approved for Client 2');

	await openQ.connect(contributor).fundBountyToken(bounty1Address, mockLink.address, one, 1);
	await optionalSleep(5000);

	await openQ.connect(contributor).fundBountyToken(bounty1Address, mockDai.address, two, 1);
	await optionalSleep(5000);

	await openQ.connect(contributor).fundBountyToken(bounty2Address, mockLink.address, one, 1);
	await optionalSleep(5000);

	await openQ.connect(contributor).fundBountyToken(bounty2Address, mockDai.address, two, 1);
	await optionalSleep(5000);

	console.log('Funding succeeded for Client 2');

	console.log('\nBounties funded successfully!\n');
}

async function main() {
	await fundBounties();
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});

module.exports = fundBounties;