export async function suite(h) {
  const token = await h.token();
  const c = await h.deploy("BudgetTreasury", [
    token.target,
    100,
    h.addresses[0],
  ]);
  await h.tx(token.approve(c.target, 1000));
  await h.tx(c.fund(1000));
  await h.test("only owner configures budget", () =>
    h.revert(() =>
      c.connect(h.signers[1]).configureBudget(h.addresses[1], 100, true),
    ),
  );
  await h.tx(c.configureBudget(h.addresses[1], 100, true));
  await h.tx(c.setRecipient(h.addresses[2], true));
  await h.test("operator pays permitted recipient", async () => {
    await h.tx(c.connect(h.signers[1]).pay(h.addresses[2], 60));
    h.eq(await token.balanceOf(h.addresses[2]), 60n);
  });
  await h.test("epoch budget cannot be exceeded", () =>
    h.revert(() => c.connect(h.signers[1]).pay(h.addresses[2], 41)),
  );
  await h.test("unapproved recipient rejected", () =>
    h.revert(() => c.connect(h.signers[1]).pay(h.addresses[3], 1)),
  );
  await h.test("epoch rolls over", async () => {
    await h.mine(101);
    h.eq(await c.availableBudget(h.addresses[1]), 100n);
  });
  await h.test("pause blocks payments", async () => {
    await h.tx(c.setPaused(true));
    await h.revert(() => c.connect(h.signers[1]).pay(h.addresses[2], 1));
  });
}
