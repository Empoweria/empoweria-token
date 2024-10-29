const EmpoweriaToken = artifacts.require("EmpoweriaToken");

contract("EmpoweriaToken", (accounts) => {
  const [owner, user1, user2] = accounts;

  let tokenInstance;

  beforeEach(async () => {
    tokenInstance = await EmpoweriaToken.new({ from: owner });
  });

  it("should have correct initial supply", async () => {
    const totalSupply = await tokenInstance.totalSupply();
    assert.equal(
      totalSupply.toString(),
      web3.utils.toWei("100000000", "ether"),
      "Initial supply is incorrect"
    );
  });

  it("should allow owner to verify KYC", async () => {
    await tokenInstance.verifyKYC(user1, { from: owner });
    const isVerified = await tokenInstance.isKYCVerified(user1);
    assert.isTrue(isVerified, "KYC verification failed");
  });

  it("should prevent non-KYC accounts from transferring tokens", async () => {
    await tokenInstance.transfer(user1, web3.utils.toWei("1000", "ether"), { from: owner });
    try {
      await tokenInstance.transfer(user2, web3.utils.toWei("500", "ether"), { from: user1 });
      assert.fail("Transfer should have failed");
    } catch (error) {
      assert.include(error.message, "Account is not KYC verified");
    }
  });

  it("should burn tokens on transfer", async () => {
    await tokenInstance.verifyKYC(user1, { from: owner });
    await tokenInstance.verifyKYC(user2, { from: owner });
    await tokenInstance.transfer(user1, web3.utils.toWei("1000", "ether"), { from: owner });

    const initialSupply = await tokenInstance.totalSupply();

    await tokenInstance.transfer(user2, web3.utils.toWei("500", "ether"), { from: user1 });

    const finalSupply = await tokenInstance.totalSupply();
    const burnedAmount = initialSupply.sub(finalSupply);

    assert.equal(
      burnedAmount.toString(),
      web3.utils.toWei("10", "ether"), // 2% of 500
      "Burned amount is incorrect"
    );
  });

  // Additional tests can be added here
});
