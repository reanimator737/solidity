const  { expect } = require('chai')
const  { ethers } = require('hardhat')

describe("Payments", () => {
    let acc1, acc2
    let payments
    beforeEach(async () => {
        [acc1, acc2] = await ethers.getSigners()
        const Payments = await ethers.getContractFactory("Payments", acc1)
        payments = await Payments.deploy()
        await payments.deployed()
    })

    it('Should be deployed', () => {
        expect(acc1.address).to.be.properAddress
        expect(payments.address).to.be.properAddress
    })

    it('Check balance (zero)', async () => {
        const balance = await payments.currentBalance()
        expect(balance).to.equal(0)
    })

    it('Should be possible to send', async () => {
        const tx = await payments.connect(acc2).pay('Test payment', {value: 100})
        await expect(() => tx)
            .to.be.changeEtherBalance(acc2, -100)
        await expect(() => tx)
            .to.be.changeEtherBalances([acc2, payments], [-100, 100])
        await tx.wait()

        const newPayment = await payments.getPayment(acc2.address, 0)
        expect(newPayment.message).to.equal('Test payment')
    })
})