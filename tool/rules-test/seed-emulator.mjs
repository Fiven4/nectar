// Наполняет запущенные эмуляторы Auth и Firestore тестовыми данными для ручной
// проверки веб-панели: http://localhost:8090/?emulator=1 (см. README, «Эмуляторы»).
// Запуск: firebase emulators:start --only auth,firestore --project nectar-41848
//         node seed-emulator.mjs
import { readFileSync } from "node:fs";
import { initializeTestEnvironment } from "@firebase/rules-unit-testing";
import { doc, setDoc, Timestamp } from "firebase/firestore";

const AUTH = "http://127.0.0.1:9099";
const PASSWORD = "Test1234";

async function createAuthUser(email) {
  const response = await fetch(`${AUTH}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=demo-key`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password: PASSWORD, returnSecureToken: true }),
  });
  const data = await response.json();
  if (!data.localId) throw new Error(`Не удалось создать ${email}: ${JSON.stringify(data)}`);
  return data.localId;
}

// SEED_DEMO=1: красивые демо-данные (каталог из lib/data, обычные имена) для скриншотов.
// Без флага: тестовые данные с XSS-нагрузкой в именах для проверки экранирования.
const demo = process.env.SEED_DEMO === "1";
const catalog = demo ? JSON.parse(readFileSync(new URL("./catalog.json", import.meta.url), "utf8")) : null;

// SEED_MINIMAL=1 (вместе с SEED_DEMO=1): только администратор, каталог и промокод —
// остальных пользователей и заказы создают вручную через приложение и панель.
const minimal = process.env.SEED_MINIMAL === "1";

const allPeople = [
  { key: "admin", email: "admin@nectar.test", role: "admin", displayName: "Админ Админов" },
  { key: "manager", email: "manager@nectar.test", role: "manager", displayName: "Мария Менеджер" },
  { key: "courier", email: "courier@nectar.test", role: "courier", displayName: "Кирилл Курьер", phoneNumber: "+7 900 111-22-33" },
  { key: "buyer", email: "buyer@nectar.test", role: "buyer", displayName: "Борис Покупатель", addresses: ["Москва, Тверская 1"], cards: ["**** **** **** 1111"] },
  { key: "xss", email: "xss@nectar.test", role: "buyer", displayName: demo ? "Анна Смирнова" : `<img src=x onerror="window.__xss=1">Хакер` },
  { key: "legacy", email: "legacy@nectar.test", role: "customer", displayName: "Легаси Клиент" },
  { key: "blocked", email: "blocked@nectar.test", role: "buyer", displayName: "Заблокированный", isDeleted: true, deletedBy: "admin" },
  { key: "outsider", email: "outsider@nectar.test", role: "buyer", displayName: "Посторонний", isDeleted: false },
];
const people = minimal ? allPeople.filter((person) => person.key === "admin") : allPeople;


const env = await initializeTestEnvironment({
  projectId: process.env.EMULATOR_PROJECT || "nectar-41848",
  firestore: { host: "127.0.0.1", port: 8080 },
});

const ids = {};
for (const person of people) ids[person.key] = await createAuthUser(person.email);

await env.withSecurityRulesDisabled(async (context) => {
  const db = context.firestore();
  const now = Timestamp.now();
  const daysAgo = (days) => Timestamp.fromDate(new Date(Date.now() - days * 86400000));

  for (const person of people) {
    const { key, ...data } = person;
    await setDoc(doc(db, "users", ids[key]), {
      uid: ids[key],
      login: key,
      loginNormalized: key,
      phoneNumber: "+7 900 000-00-00",
      isDeleted: false,
      ...data,
      ...(data.deletedBy ? { deletedBy: ids[data.deletedBy] } : {}),
    });
  }

  if (demo) {
    for (const category of catalog.categories) {
      const { id, ...data } = category;
      await setDoc(doc(db, "categories", id), { ...data, nameNormalized: data.name.toLowerCase() });
    }
    for (const manufacturer of catalog.manufacturers) {
      const { id, ...data } = manufacturer;
      await setDoc(doc(db, "manufacturers", id), { ...data, nameNormalized: data.name.toLowerCase() });
    }
    for (const product of catalog.products) {
      const { id, ...data } = product;
      await setDoc(doc(db, "products", id), { ...data, nameNormalized: data.name.toLowerCase(), minStock: 5, isDeleted: false, createdAt: now, updatedAt: now });
    }
    await setDoc(doc(db, "suppliers", "s1"), { name: "ООО Поставка Маркет", nameNormalized: "ооо поставка маркет", taxId: "7707083893", address: "Москва, ул. Складская, 5", contactPhone: "+7 495 000-00-00", email: "supply@example.com" });
  } else {
    await setDoc(doc(db, "categories", "dairy"), { name: "Молочные", nameNormalized: "молочные", nameEn: "Dairy", description: "Молоко и сыр" });
    await setDoc(doc(db, "categories", "bakery"), { name: "Выпечка", nameNormalized: "выпечка", description: "" });
    await setDoc(doc(db, "manufacturers", "m1"), { name: "Данон", nameNormalized: "данон", country: "Франция", contactPhone: "+33 1 23 45 67 89" });
    await setDoc(doc(db, "suppliers", "s1"), { name: "ООО Поставка", nameNormalized: "ооо поставка", taxId: "7707083893", address: "Москва", contactPhone: "+7 495 000-00-00", email: "s@example.com" });

    const product = (id, name, categoryId, categoryName, price, stock, extra = {}) =>
      setDoc(doc(db, "products", id), {
        name, nameNormalized: name.toLowerCase(), price, stockQuantity: stock, qty: "1 шт", categoryId, categoryName,
        manufacturerId: "m1", manufacturerName: "Данон", isDeleted: false, imageUrl: "", ...extra,
      });
    await product("milk", "Молоко", "dairy", "Молочные", 89.9, 20);
    await product("bread", "Хлеб", "bakery", "Выпечка", 45, 3);
    await product("xss", `<script>window.__xss=1</script>Товар`, "dairy", "Молочные", 10, 5);
    await product("hidden", "Скрытый товар", "dairy", "Молочные", 10, 5, { isDeleted: true });

  }
  await setDoc(doc(db, "promoCodes", "sale10"), {
    code: "SALE10", codeNormalized: "SALE10", discountPercent: 10, isActive: true, usageCount: 2,
    expiresAt: Timestamp.fromDate(new Date(Date.now() + 30 * 86400000)),
  });

  const order = (id, userKey, statusId, extra = {}) =>
    setDoc(doc(db, "orders", id), {
      number: `ORD-${id}`, userId: ids[userKey], customerName: people.find((p) => p.key === userKey).displayName,
      totalAmount: 250, statusId, statusName: statusId, courierId: null, createdAt: daysAgo(2),
      items: demo
        ? catalog.products.slice(0, 3).map((product, index) => ({ id: product.id, name: product.name, nameEn: product.nameEn, price: product.price, quantity: index + 1 }))
        : [{ id: "milk", name: "Молоко", price: 89.9, quantity: 2 }, { id: "bread", name: "Хлеб", price: 45, quantity: 1 }],
      address: "Москва, Тверская 1, кв. 12", paymentMethod: "Наличными", deliverySlot: "Как можно скорее (до 60 минут)", customerPhone: "+7 900 123-45-67",
      ...extra,
    });
  if (!minimal) {
  await order("new1", "buyer", "new");
  await order("assigned1", "xss", "assigned", { courierId: ids.courier, courierName: "Кирилл Курьер" });
  await order("delivered1", "buyer", "delivered", { courierId: ids.courier, courierName: "Кирилл Курьер", totalAmount: 100 });
  await order("cancelled1", "buyer", "cancelled", { totalAmount: 999 });
  await setDoc(doc(db, "notifications", "n1"), { userId: ids.buyer, text: "Привет", createdAt: now });
  }
});

await env.cleanup();
console.log("Готово. Пароль у всех тестовых пользователей:", PASSWORD);
console.log(people.map((person) => `  ${person.email} (${person.role})`).join("\n"));
