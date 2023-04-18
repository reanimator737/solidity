import {Rat20Shop} from "../../typechain-types";
import {RatToken} from "../../typechain-types";

import {SignerWithAddress} from "@nomiclabs/hardhat-ethers/src/signers";
const tokenJSON = require('../../artifacts/contracts/ERC20 7/ERC20.sol/RatToken.json')
const {expect} = require('chai');
const {ethers} = require('hardhat');

describe('Shop', () => {
    let owner: SignerWithAddress;
    let buyer: SignerWithAddress;
    let shop: Rat20Shop;
    let ratToken: RatToken;

    beforeEach(async () => {
        [owner, buyer] = await ethers.getSigners();
        const RatShop = await ethers.getContractFactory('Rat20Shop', owner);
        shop = await RatShop.deploy();
        await shop.deployed();

        ratToken = new ethers.Contract(await shop.token(), tokenJSON.abi, owner)
    })

    it('Should have owner and token', async () =>{
        expect(await shop.owner()).to.eq(owner.address);
        expect(await shop.token()).to.be.properAddress;
    })

    it('Allows to buy', async () => {
        const amount = 100;
        const txData = {
            value: amount,
            to: shop.address
        }
        const tx = await buyer.sendTransaction(txData);
        await tx.wait()

        expect(await ratToken.balanceOf(buyer.address)).to.eq(amount)

        expect(tx).to.changeEtherBalance(shop, amount)

        expect(tx)
            .to.emit(shop, 'Bought')
            .withArgs(amount, buyer.address)

    })


    it('Allows to sell', async () => {
        const amount = 100;
        const txData = {
            value: amount,
            to: shop.address
        }
        const tx = await buyer.sendTransaction(txData);
        await tx.wait()

        const sellAmount = 50;

        const approve = await ratToken.connect(buyer).approve(shop.address, sellAmount)
        await  approve.wait();

        const sellTx = await shop.connect(buyer).sell(sellAmount)
        await sellTx.wait()
        expect(await ratToken.balanceOf(buyer.address)).to.eq(amount - sellAmount);
        expect(sellTx).to.changeEtherBalance(shop, -sellAmount)
        expect(sellTx)
            .to.emit(shop, 'Sold')
            .withArgs(sellAmount, buyer.address)
    })

})