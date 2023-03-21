import {Demo2} from "../typechain-types";
import {SignerWithAddress} from "@nomiclabs/hardhat-ethers/src/signers";
import {TransactionResponse} from "@ethersproject/abstract-provider/src.ts";
const  { expect } = require('chai')
const  { ethers } = require('hardhat')

describe("Demo2", () => {
    let owner: SignerWithAddress, user: SignerWithAddress
    let demo: Demo2
    beforeEach(async () => {
        [owner, user] = await ethers.getSigners()
        const DemoContract = await ethers.getContractFactory("Demo2", owner)
        demo = await DemoContract.deploy()
        await demo.deployed()
    })

    async function sendMoney (_from: SignerWithAddress): Promise<[TransactionResponse, number]>{
        const amount = 100
        const txData = {
            to: demo.address,
            value: amount,
        }

        const tx = await _from.sendTransaction(txData)
        await tx.wait()
        return [tx, amount]
    }

    it('Should allow to send money', async () => {
        const [sendMoneyTx, amount] = await sendMoney(user)
        await expect(sendMoneyTx)
            .to.changeEtherBalance(demo, amount)
        const timestamp = (await ethers.provider.getBlock(sendMoneyTx.blockNumber)).timestamp
        await expect(sendMoneyTx)
            .to.emit(demo, "NewTransaction")
            .withArgs(user.address, amount, timestamp)
    })

    it('Should allow to withdraw for owner', async () => {
       const [_, amount] = await sendMoney(user);
       const tx = await demo.withdraw4(owner.address);
       await expect(() => tx).to.changeEtherBalances([demo, owner], [-amount, amount])
    })

    it('Should not allow to withdraw for owner', async () => {
        await sendMoney(user);
        await expect(demo.connect(user).withdraw4(owner.address))
            .to.be.revertedWith('U aren`t an owner')
    })
})