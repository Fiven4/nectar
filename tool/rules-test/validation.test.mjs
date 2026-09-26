// Юнит-тесты чистой логики веб-панели (web/validation.js). Запуск: npm run test:unit
import assert from "node:assert/strict";
import { describe, it } from "node:test";

import {
  computeDashboard,
  endOfDay,
  esc,
  friendlyError,
  isFinishedStatus,
  parseDateInput,
  stockRestorations,
  toDateInputValue,
  validateDiscount,
  validateEmail,
  validateEntityForm,
  validateNewPassword,
  validateOrderChange,
  validatePhone,
  validateProductForm,
  validatePromoCode,
  validateTaxId,
  validateUrl,
} from "../../web/validation.js";

const goodProduct = {
  name: "Молоко",
  price: "89,90",
  stockQuantity: "12",
  qty: "1 л",
  categoryId: "c1",
  manufacturerId: "m1",
  imageUrl: "https://example.com/milk.jpg",
  calories: "60",
  proteins: "3",
  fats: "3.5",
  carbs: "4.7",
};

describe("esc", () => {
  it("экранирует HTML и кавычки атрибутов", () => {
    assert.equal(esc(`<img src=x onerror="alert(1)">`), "&lt;img src=x onerror=&quot;alert(1)&quot;&gt;");
    assert.equal(esc(`a&b'c`), "a&amp;b&#39;c");
    assert.equal(esc(null), "");
    assert.equal(esc(undefined), "");
    assert.equal(esc(0), "0");
  });
});

describe("телефон, email, ИНН, промокод, скидка, ссылка", () => {
  it("телефон", () => {
    assert.equal(validatePhone("+7 (900) 123-45-67"), null);
    assert.notEqual(validatePhone("123"), null);
    assert.notEqual(validatePhone("hello 89001234567"), null);
    assert.notEqual(validatePhone(""), null);
    assert.equal(validatePhone("", { required: false }), null);
  });

  it("email", () => {
    assert.equal(validateEmail("a@b.co"), null);
    assert.equal(validateEmail(""), null);
    assert.notEqual(validateEmail("", { required: true }), null);
    assert.notEqual(validateEmail("a@b"), null);
    assert.notEqual(validateEmail("a b@c.de"), null);
  });

  it("ИНН: 10 или 12 цифр", () => {
    assert.equal(validateTaxId("7707083893"), null);
    assert.equal(validateTaxId("770708389312"), null);
    assert.notEqual(validateTaxId("77070838"), null);
    assert.notEqual(validateTaxId("77070838ab"), null);
    assert.notEqual(validateTaxId(""), null);
  });

  it("промокод", () => {
    assert.equal(validatePromoCode("nectar20"), null);
    assert.notEqual(validatePromoCode("bad code!"), null);
    assert.notEqual(validatePromoCode("СКИДКА"), null);
    assert.notEqual(validatePromoCode(" "), null);
  });

  it("скидка 1..99, целое", () => {
    assert.equal(validateDiscount("10"), null);
    assert.equal(validateDiscount(99), null);
    for (const bad of ["", "0", "100", "-5", "10.5", "abc"]) assert.notEqual(validateDiscount(bad), null, bad);
  });

  it("ссылка только http(s)", () => {
    assert.equal(validateUrl(""), null);
    assert.equal(validateUrl("https://a.b/c.png"), null);
    assert.notEqual(validateUrl("javascript:alert(1)"), null);
    assert.notEqual(validateUrl("not a url"), null);
  });
});

describe("даты", () => {
  it("разбор и конец дня по местному времени", () => {
    assert.equal(parseDateInput("2027-02-30"), null);
    assert.equal(parseDateInput("abc"), null);
    assert.equal(parseDateInput(""), null);
    const end = endOfDay("2027-05-10");
    assert.equal(end.getHours(), 23);
    assert.equal(end.getDate(), 10);
  });

  it("значение для input не смещается на день", () => {
    const local = new Date(2027, 4, 10, 23, 59, 59);
    assert.equal(toDateInputValue({ seconds: Math.floor(local.getTime() / 1000) }), "2027-05-10");
    assert.equal(toDateInputValue(null), "");
  });
});

describe("validateProductForm", () => {
  it("корректный товар проходит", () => {
    assert.equal(validateProductForm(goodProduct), null);
  });

  it("отклоняет некорректные значения", () => {
    const cases = [
      [{ name: "  " }, "Название"],
      [{ price: "0" }, "Цена"],
      [{ price: "-1" }, "Цена"],
      [{ price: "abc" }, "Цена"],
      [{ price: "" }, "Цена"],
      [{ price: "1e9" }, "Цена"],
      [{ stockQuantity: "-1" }, "Количество"],
      [{ stockQuantity: "1.5" }, "Количество"],
      [{ stockQuantity: "10000" }, "Количество"],
      [{ stockQuantity: "" }, "Количество"],
      [{ qty: "" }, "Единица"],
      [{ categoryId: "" }, "категорию"],
      [{ manufacturerId: "" }, "производителя"],
      [{ imageUrl: "javascript:alert(1)" }, "http"],
      [{ expiryDate: "2027-13-45" }, "срок годности"],
      [{ calories: "-3" }, "Калорийность"],
      [{ proteins: "x" }, "Белки"],
      [{ name: "я".repeat(256) }, "255"],
    ];
    for (const [patch, hint] of cases) {
      const error = validateProductForm({ ...goodProduct, ...patch });
      assert.ok(error && error.includes(hint), `${JSON.stringify(patch)} -> ${error}`);
    }
  });
});

describe("validateEntityForm", () => {
  const today = new Date(2026, 0, 15, 12, 0, 0);

  it("категории и производители", () => {
    assert.equal(validateEntityForm("categories", { name: "Молочные", description: "" }), null);
    assert.notEqual(validateEntityForm("categories", { name: "" }), null);
    assert.notEqual(validateEntityForm("categories", { name: "x", description: "x".repeat(501) }), null);
    assert.equal(validateEntityForm("manufacturers", { name: "Данон", country: "Франция", contactPhone: "+33 1 23 45 67 89" }), null);
    assert.notEqual(validateEntityForm("manufacturers", { name: "Данон", country: "", contactPhone: "+7 900 123 45 67" }), null);
    assert.notEqual(validateEntityForm("manufacturers", { name: "Данон", country: "FR", contactPhone: "12" }), null);
  });

  it("поставщики", () => {
    const supplier = { name: "ООО", taxId: "7707083893", address: "Москва", contactPhone: "+7 900 123-45-67", email: "" };
    assert.equal(validateEntityForm("suppliers", supplier), null);
    assert.equal(validateEntityForm("suppliers", { ...supplier, email: "a@b.co" }), null);
    assert.notEqual(validateEntityForm("suppliers", { ...supplier, taxId: "123" }), null);
    assert.notEqual(validateEntityForm("suppliers", { ...supplier, email: "bad" }), null);
    assert.notEqual(validateEntityForm("suppliers", { ...supplier, address: "" }), null);
  });

  it("промокоды", () => {
    const promo = { code: "sale10", discountPercent: "10", expiresAt: "2026-01-15" };
    assert.equal(validateEntityForm("promoCodes", promo, { today }), null, "сегодняшний день еще действует");
    assert.notEqual(validateEntityForm("promoCodes", { ...promo, expiresAt: "2026-01-14" }, { today }), null);
    assert.notEqual(validateEntityForm("promoCodes", { ...promo, expiresAt: "" }, { today }), null);
    assert.notEqual(validateEntityForm("promoCodes", { ...promo, expiresAt: "2026-02-31" }, { today }), null);
    assert.notEqual(validateEntityForm("promoCodes", { ...promo, discountPercent: "100" }, { today }), null);
    assert.notEqual(validateEntityForm("promoCodes", { ...promo, code: "плохо" }, { today }), null);
  });
});

describe("пароль", () => {
  it("правила смены пароля", () => {
    assert.equal(validateNewPassword("abcde1", "old", "abcde1"), null);
    assert.notEqual(validateNewPassword("abc1", "old", "abc1"), null);
    assert.notEqual(validateNewPassword("abcdef", "old", "abcdef"), null);
    assert.notEqual(validateNewPassword("123456", "old", "123456"), null);
    assert.notEqual(validateNewPassword("abcde1", "old", "abcde2"), null);
    assert.notEqual(validateNewPassword("abcde1", "abcde1", "abcde1"), null);
    assert.notEqual(validateNewPassword("abc de1", "old", "abc de1"), null);
  });
});

describe("заказы", () => {
  it("завершенные заказы неизменяемы", () => {
    assert.ok(isFinishedStatus("delivered"));
    assert.ok(isFinishedStatus("cancelled"));
    assert.ok(!isFinishedStatus("new"));
    assert.notEqual(validateOrderChange({ statusId: "cancelled", courierId: null }, { statusId: "new", courierId: "" }), null);
    assert.notEqual(validateOrderChange({ statusId: "delivered", courierId: "c1" }, { statusId: "delivering", courierId: "c1" }), null);
    assert.equal(validateOrderChange({ statusId: "delivered", courierId: "c1" }, { statusId: "delivered", courierId: "c1" }), null);
  });

  it("статусы курьера требуют курьера", () => {
    for (const statusId of ["assigned", "delivering", "delivered"]) {
      assert.notEqual(validateOrderChange({ statusId: "new" }, { statusId, courierId: "" }), null, statusId);
      assert.equal(validateOrderChange({ statusId: "new" }, { statusId, courierId: "c1" }), null, statusId);
    }
    assert.equal(validateOrderChange({ statusId: "new" }, { statusId: "processing", courierId: "" }), null);
    assert.equal(validateOrderChange({ statusId: "new" }, { statusId: "cancelled", courierId: "" }), null);
  });

  it("возврат остатков при отмене суммирует одинаковые товары и пропускает мусор", () => {
    const items = [
      { id: "p1", quantity: 2 },
      { id: "p1", quantity: "3" },
      { id: "p2", quantity: 1 },
      { id: "p3", quantity: 0 },
      { id: "p4", quantity: -2 },
      { quantity: 5 },
      { id: "p5", quantity: "abc" },
    ];
    assert.deepEqual(stockRestorations({ items }), [
      { id: "p1", quantity: 5 },
      { id: "p2", quantity: 1 },
    ]);
    assert.deepEqual(stockRestorations({}), []);
  });
});

describe("friendlyError", () => {
  it("не показывает технические тексты", () => {
    assert.equal(friendlyError({ code: "permission-denied", message: "Missing or insufficient permissions." }), "Недостаточно прав для этого действия.");
    assert.match(friendlyError({ code: "unavailable" }), /соединения/);
    assert.match(friendlyError(new Error("boom")), /Не удалось/);
    assert.equal(friendlyError({ userMessage: "Свой текст" }), "Свой текст");
  });
});

describe("computeDashboard", () => {
  const seconds = (y, m, d) => Math.floor(new Date(y, m - 1, d, 12).getTime() / 1000);
  const orders = [
    { statusId: "delivered", totalAmount: 100, createdAt: { seconds: seconds(2026, 1, 5) }, items: [{ id: "p1", name: "Milk", quantity: 2 }] },
    { statusId: "new", totalAmount: 50, createdAt: { seconds: seconds(2026, 3, 5) }, items: [{ id: "p2", name: "Bread", quantity: 1 }] },
    { statusId: "cancelled", totalAmount: 999, createdAt: { seconds: seconds(2026, 2, 5) }, items: [{ id: "p1", name: "Milk", quantity: 50 }] },
    { statusId: "new", totalAmount: 10, items: [] },
  ];
  const result = computeDashboard({
    orders,
    users: [{ role: "buyer" }, { role: "customer" }, { role: "admin" }],
    products: [
      { id: "p1", name: "Milk", stockQuantity: 3 },
      { id: "p2", name: "Bread", stockQuantity: 50 },
      { id: "p3", name: "Old", stockQuantity: 0, isDeleted: true },
    ],
  });

  it("выручка и активные заказы без отмененных", () => {
    assert.equal(result.totalSales, 160);
    assert.equal(result.activeOrdersCount, 2);
    assert.equal(result.buyersCount, 2);
    assert.equal(result.lowStockCount, 1);
  });

  it("месяцы по порядку, заказ без даты не попадает в месяц, топ без отмененных", () => {
    assert.deepEqual(result.monthlySales, [["2026-01", 100], ["2026-03", 50]]);
    assert.deepEqual(result.topProducts, [["Milk", 2], ["Bread", 1]]);
  });
});
