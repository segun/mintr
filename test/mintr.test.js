const { assert } = require("chai");
const { ethers } = require("hardhat");

describe('Mintr', function () {
    let mintr;
    let accounts = [];
    let dbilia;
    let user1;
    let user2;
    let address0 = "0x0000000000000000000000000000000000000000";

    before(async () => {
        accounts = await ethers.getSigners();
        dbilia = accounts[0];
        user1 = accounts[1];
        user2 = accounts[2];
        const Mintr = await ethers.getContractFactory("Mintr");
        mintr = await Mintr.deploy(dbilia.address);
        await mintr.deployed();
        console.log("Mintr deployed to:", mintr.address);        
    });  
    
    it('should mint with usd', async () => {
        let userId = 1;
        let cardId = 1;
        let edition = 1001;
        let tokenUri = `http://dbilia/com/${edition}`;
        await mintr.mintWithUSD(userId, cardId, edition, tokenUri);  
        let tokenAddress = await mintr.getTokenAddressFromUserId(userId, edition);
        assert.notEqual(tokenAddress, address0);
    });

    it('should not mint with usd if the sender is not dbilia', async () => {
        let userId = 1;
        let cardId = 1;
        let edition = 1001;
        let tokenUri = `http://dbilia/com/${edition}`;
        let mintr2 = await mintr.connect(user1);
        try {
            await mintr2.mintWithUSD(userId, cardId, edition, tokenUri);  
        } catch (e) {            
            assert.notEqual(e, undefined);
            assert.isTrue(e.toString().indexOf('Only Dbilia can call this method') > 0);
        }
    });

    it('should mint with ETH', async () => {
        let toSend = "0.2" // fees

        let overrides = {
            value: ethers.utils.parseEther(toSend + "")
        };

        let cardId = 2;
        let edition = 1002;
        let tokenUri = `http://dbilia/com/${edition}`;
        let mintr2 = await mintr.connect(user1);        
        await mintr2.mintWithETH(cardId, edition, tokenUri, overrides);  
        let tokenAddress = await mintr.getTokenAddressFromOwner(user1.address, edition);
        assert.notEqual(tokenAddress, address0);
    });

    it('should not mint same token twice', async () => {
        let userId = 1;
        let cardId = 1;
        let edition = 1001;
        let tokenUri = `http://dbilia/com/${edition}`;
        try {
            await mintr.mintWithUSD(userId, cardId, edition, tokenUri);  
        } catch(e) {
            assert.notEqual(e, undefined);
            assert.isTrue(e.toString().indexOf('Token with edition already exists') > 0);            
        }
    });
});