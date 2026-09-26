// Тесты правил безопасности на локальном эмуляторе (боевой проект не затрагивается).
// Запуск: cd tool/rules-test && npm install && npm test
import { readFileSync } from "node:fs";
import { after, before, beforeEach, describe, it } from "node:test";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from "@firebase/rules-unit-testing";
import {
  addDoc,
  collection,
  deleteDoc,
  deleteField,
  doc,
  getDoc,
  getDocs,
  increment,
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
  writeBatch,
} from "firebase/firestore";

const projectId = "demo-nectar";
let env;

const emailOf = (uid) => `${uid}@example.com`;

before(async () => {
  env = await initializeTestEnvironment({
    projectId,
    firestore: { rules: readFileSync("../../firestore.rules", "utf8") },
  });
});

after(async () => {
  await env.cleanup();
});

const seedUsers = {
  admin1: { role: "admin" },
  mgr1: { role: "manager" },
  buyer1: { role: "buyer" },
  buyer2: { role: "buyer" },
  courier1: { role: "courier" },
  blocked1: { role: "buyer", isDeleted: true, deletedBy: "admin1" },
  selfDeleted1: { role: "buyer", isDeleted: true, deletedBy: "selfDeleted1" },
};

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    for (const [uid, data] of Object.entries(seedUsers)) {
      await setDoc(doc(db, "users", uid), {
        uid,
        email: emailOf(uid),
        displayName: uid,
        isDeleted: false,
        ...data,
      });
    }
    await setDoc(doc(db, "products", "p1"), { name: "Milk", price: 100, stockQuantity: 10, isDeleted: false });
    await setDoc(doc(db, "categories", "c1"), { name: "Dairy" });
    await setDoc(doc(db, "suppliers", "s1"), { name: "Supplier" });
    await setDoc(doc(db, "promoCodes", "promo1"), { code: "SALE10", discountPercent: 10, usageCount: 0 });
    await setDoc(doc(db, "loginIndex", "buyer1login"), { uid: "buyer1", email: emailOf("buyer1") });
    const base = { totalAmount: 100, userId: "buyer1", items: [] };
    await setDoc(doc(db, "orders", "new1"), { ...base, statusId: "new", courierId: null });
    await setDoc(doc(db, "orders", "assigned1"), { ...base, statusId: "assigned", courierId: "courier1" });
    await setDoc(doc(db, "orders", "delivering1"), { ...base, statusId: "delivering", courierId: "courier1" });
    await setDoc(doc(db, "orders", "delivered1"), { ...base, statusId: "delivered", courierId: "courier1" });
    await setDoc(doc(db, "orders", "cancelled1"), { ...base, statusId: "cancelled", courierId: "courier1" });
    await setDoc(doc(db, "orders", "other1"), { ...base, userId: "buyer2", statusId: "assigned", courierId: null });
    await setDoc(doc(db, "notifications", "n1"), { userId: "buyer1", text: "hi" });
  });
});

const as = (uid, extra = {}) => env.authenticatedContext(uid, { email: emailOf(uid), ...extra }).firestore();
const guest = () => env.unauthenticatedContext().firestore();

describe("users", () => {
  it("владелец читает свой профиль, чужой недоступен, менеджер читает всех", async () => {
    await assertSucceeds(getDoc(doc(as("buyer1"), "users", "buyer1")));
    await assertFails(getDoc(doc(as("buyer1"), "users", "buyer2")));
    await assertSucceeds(getDoc(doc(as("mgr1"), "users", "buyer2")));
    await assertFails(getDoc(doc(guest(), "users", "buyer1")));
  });

  it("покупатель меняет имя, но не роль и не uid", async () => {
    await assertSucceeds(updateDoc(doc(as("buyer1"), "users", "buyer1"), { displayName: "Ivan", updatedAt: serverTimestamp() }));
    await assertFails(updateDoc(doc(as("buyer1"), "users", "buyer1"), { role: "admin" }));
    await assertFails(updateDoc(doc(as("buyer1"), "users", "buyer1"), { uid: "buyer2" }));
  });

  it("самостоятельная регистрация только как покупатель и не «удаленным»", async () => {
    await assertSucceeds(setDoc(doc(as("new1"), "users", "new1"), { uid: "new1", role: "buyer", isDeleted: false }));
    await assertFails(setDoc(doc(as("new2"), "users", "new2"), { uid: "new2", role: "admin" }));
    await assertFails(setDoc(doc(as("new3"), "users", "new3"), { uid: "new3", role: "buyer", isDeleted: true }));
    await assertFails(setDoc(doc(as("new4"), "users", "buyer1"), { uid: "buyer1", role: "buyer" }));
  });

  it("заблокированный администратором не может снять блокировку и менять профиль", async () => {
    await assertFails(updateDoc(doc(as("blocked1"), "users", "blocked1"), { isDeleted: false }));
    await assertFails(updateDoc(doc(as("blocked1"), "users", "blocked1"), { displayName: "x" }));
  });

  it("самоудаление: пометить и вернуть обратно может только сам владелец", async () => {
    await assertSucceeds(updateDoc(doc(as("buyer1"), "users", "buyer1"), { isDeleted: true, deletedBy: "buyer1" }));
    await assertSucceeds(updateDoc(doc(as("buyer1"), "users", "buyer1"), { isDeleted: false, deletedBy: deleteField() }));
    await assertFails(updateDoc(doc(as("buyer1"), "users", "buyer1"), { isDeleted: true, deletedBy: "admin1" }));
    await assertFails(updateDoc(doc(as("buyer1"), "users", "buyer1"), { isDeleted: true }));
    await assertSucceeds(updateDoc(doc(as("selfDeleted1"), "users", "selfDeleted1"), { isDeleted: false }));
  });

  it("роли меняет только администратор", async () => {
    await assertFails(updateDoc(doc(as("mgr1"), "users", "buyer1"), { role: "courier" }));
    await assertFails(updateDoc(doc(as("mgr1"), "users", "buyer1"), { isDeleted: true }));
    await assertSucceeds(updateDoc(doc(as("admin1"), "users", "buyer1"), { role: "courier" }));
    await assertSucceeds(updateDoc(doc(as("admin1"), "users", "buyer1"), { isDeleted: true, deletedBy: "admin1" }));
  });

  it("аватар хранится в профиле: до ~150 КБ можно, больше нельзя", async () => {
    await assertSucceeds(updateDoc(doc(as("buyer1"), "users", "buyer1"), { photoData: "A".repeat(200000) }));
    await assertFails(updateDoc(doc(as("buyer1"), "users", "buyer1"), { photoData: "A".repeat(250000) }));
  });

  it("пользователей нельзя удалять физически", async () => {
    await assertFails(deleteDoc(doc(as("admin1"), "users", "buyer1")));
    await assertFails(deleteDoc(doc(as("buyer1"), "users", "buyer1")));
  });
});

describe("loginIndex", () => {
  it("get доступен гостю, list закрыт", async () => {
    await assertSucceeds(getDoc(doc(guest(), "loginIndex", "buyer1login")));
    await assertFails(getDocs(collection(guest(), "loginIndex")));
  });

  it("создать запись можно только для себя и со своей почтой", async () => {
    await assertSucceeds(setDoc(doc(as("new1"), "loginIndex", "fresh"), { uid: "new1", email: emailOf("new1") }));
    await assertFails(setDoc(doc(as("new2"), "loginIndex", "fresh2"), { uid: "buyer1", email: emailOf("new2") }));
    await assertFails(setDoc(doc(as("new3"), "loginIndex", "fresh3"), { uid: "new3", email: "victim@example.com" }));
    await assertFails(setDoc(doc(as("new4"), "loginIndex", "fresh4"), { uid: "new4", email: emailOf("new4"), extra: 1 }));
    await assertFails(setDoc(doc(guest(), "loginIndex", "fresh5"), { uid: "x", email: "x@example.com" }));
  });

  it("чужую запись перезаписать нельзя, свою удалить можно (освобождение логина)", async () => {
    await assertFails(setDoc(doc(as("buyer2"), "loginIndex", "buyer1login"), { uid: "buyer2", email: emailOf("buyer2") }));
    await assertFails(deleteDoc(doc(as("buyer2"), "loginIndex", "buyer1login")));
    await assertSucceeds(deleteDoc(doc(as("buyer1"), "loginIndex", "buyer1login")));
  });
});

describe("products", () => {
  it("читают только авторизованные", async () => {
    await assertSucceeds(getDoc(doc(as("buyer1"), "products", "p1")));
    await assertFails(getDoc(doc(guest(), "products", "p1")));
  });

  it("покупатель может только уменьшить остаток и не больше чем на 99 за раз", async () => {
    await assertSucceeds(updateDoc(doc(as("buyer1"), "products", "p1"), { stockQuantity: 7, updatedAt: serverTimestamp() }));
    await assertFails(updateDoc(doc(as("buyer1"), "products", "p1"), { stockQuantity: 11 }));
    await assertFails(updateDoc(doc(as("buyer1"), "products", "p1"), { stockQuantity: -1 }));
    await assertFails(updateDoc(doc(as("buyer1"), "products", "p1"), { price: 1 }));
    await env.withSecurityRulesDisabled((c) => updateDoc(doc(c.firestore(), "products", "p1"), { stockQuantity: 1000 }));
    await assertFails(updateDoc(doc(as("buyer1"), "products", "p1"), { stockQuantity: 0 }));
    await assertSucceeds(updateDoc(doc(as("buyer1"), "products", "p1"), { stockQuantity: 901 }));
  });

  it("курьер не меняет товары", async () => {
    await assertFails(updateDoc(doc(as("courier1"), "products", "p1"), { stockQuantity: 5 }));
  });

  it("менеджер редактирует, удаляет только администратор", async () => {
    await assertSucceeds(updateDoc(doc(as("mgr1"), "products", "p1"), { price: 120 }));
    await assertSucceeds(setDoc(doc(as("mgr1"), "products", "p2"), { name: "Bread", price: 30, stockQuantity: 5 }));
    await assertFails(deleteDoc(doc(as("mgr1"), "products", "p1")));
    await assertSucceeds(deleteDoc(doc(as("admin1"), "products", "p1")));
  });

  it("товар нельзя создать с некорректной ценой или остатком", async () => {
    await assertFails(setDoc(doc(as("mgr1"), "products", "bad1"), { name: "X", price: -5, stockQuantity: 5 }));
    await assertFails(setDoc(doc(as("mgr1"), "products", "bad2"), { name: "X", price: 5, stockQuantity: -1 }));
    await assertFails(setDoc(doc(as("mgr1"), "products", "bad3"), { name: "", price: 5, stockQuantity: 1 }));
  });
});

describe("справочники", () => {
  it("категории: читают все авторизованные, пишет персонал", async () => {
    await assertSucceeds(getDoc(doc(as("buyer1"), "categories", "c1")));
    await assertFails(setDoc(doc(as("buyer1"), "categories", "c2"), { name: "x" }));
    await assertSucceeds(setDoc(doc(as("mgr1"), "categories", "c2"), { name: "x" }));
  });

  it("поставщики: менеджер только читает, администратор пишет, покупатель не видит", async () => {
    await assertSucceeds(getDoc(doc(as("mgr1"), "suppliers", "s1")));
    await assertFails(updateDoc(doc(as("mgr1"), "suppliers", "s1"), { name: "New" }));
    await assertFails(deleteDoc(doc(as("mgr1"), "suppliers", "s1")));
    await assertSucceeds(updateDoc(doc(as("admin1"), "suppliers", "s1"), { name: "New" }));
    await assertFails(getDoc(doc(as("buyer1"), "suppliers", "s1")));
  });
});

describe("promoCodes", () => {
  it("покупатель может только увеличить счетчик ровно на 1", async () => {
    await assertSucceeds(updateDoc(doc(as("buyer1"), "promoCodes", "promo1"), { usageCount: increment(1), updatedAt: serverTimestamp() }));
    await assertFails(updateDoc(doc(as("buyer1"), "promoCodes", "promo1"), { usageCount: increment(5) }));
    await assertFails(updateDoc(doc(as("buyer1"), "promoCodes", "promo1"), { discountPercent: 99 }));
  });

  it("менеджер создает корректный промокод, некорректный отклоняется", async () => {
    await assertSucceeds(setDoc(doc(as("mgr1"), "promoCodes", "ok"), { code: "NEW5", discountPercent: 5, isActive: true }));
    await assertFails(setDoc(doc(as("mgr1"), "promoCodes", "bad1"), { code: "BAD", discountPercent: 100 }));
    await assertFails(setDoc(doc(as("mgr1"), "promoCodes", "bad2"), { code: "BAD", discountPercent: 0 }));
    await assertFails(setDoc(doc(as("mgr1"), "promoCodes", "bad3"), { code: "BAD", discountPercent: "10" }));
  });
});

describe("orders", () => {
  const newOrder = (extra = {}) => ({
    userId: "buyer1",
    statusId: "new",
    courierId: null,
    totalAmount: 250,
    subtotalAmount: 250,
    discountPercent: 0,
    promoCodeId: null,
    items: [{ id: "p1", quantity: 1, price: 250 }],
    createdAt: serverTimestamp(),
    ...extra,
  });

  it("покупатель создает только свой заказ в статусе new без курьера", async () => {
    await assertSucceeds(addDoc(collection(as("buyer1"), "orders"), newOrder()));
    await assertFails(addDoc(collection(as("buyer1"), "orders"), newOrder({ userId: "buyer2" })));
    await assertFails(addDoc(collection(as("buyer1"), "orders"), newOrder({ statusId: "delivered" })));
    await assertFails(addDoc(collection(as("buyer1"), "orders"), newOrder({ courierId: "courier1" })));
    await assertFails(addDoc(collection(as("buyer1"), "orders"), newOrder({ totalAmount: -1 })));
    await assertFails(addDoc(collection(as("buyer1"), "orders"), newOrder({ items: [] })));
    await assertFails(addDoc(collection(guest(), "orders"), newOrder()));
    await assertFails(addDoc(collection(as("courier1"), "orders"), newOrder({ userId: "courier1" })));
    await assertFails(addDoc(collection(as("blocked1"), "orders"), newOrder({ userId: "blocked1" })));
  });

  it("скидка в заказе обязана совпадать с промокодом", async () => {
    await assertSucceeds(addDoc(collection(as("buyer1"), "orders"), newOrder({ promoCodeId: "promo1", discountPercent: 10 })));
    await assertFails(addDoc(collection(as("buyer1"), "orders"), newOrder({ promoCodeId: "promo1", discountPercent: 90 })));
    await assertFails(addDoc(collection(as("buyer1"), "orders"), newOrder({ promoCodeId: "nope", discountPercent: 10 })));
    await assertFails(addDoc(collection(as("buyer1"), "orders"), newOrder({ discountPercent: 50 })));
  });

  it("оформление заказа целиком: заказ + остаток + счетчик промокода одним батчем", async () => {
    const db = as("buyer1");
    const batch = writeBatch(db);
    batch.set(doc(collection(db, "orders")), newOrder({ promoCodeId: "promo1", discountPercent: 10 }));
    batch.update(doc(db, "products", "p1"), { stockQuantity: 9, updatedAt: serverTimestamp() });
    batch.update(doc(db, "promoCodes", "promo1"), { usageCount: increment(1), updatedAt: serverTimestamp() });
    await assertSucceeds(batch.commit());
  });

  it("чтение: владелец, назначенный курьер и персонал", async () => {
    await assertSucceeds(getDoc(doc(as("buyer1"), "orders", "assigned1")));
    await assertFails(getDoc(doc(as("buyer1"), "orders", "other1")));
    await assertSucceeds(getDoc(doc(as("courier1"), "orders", "assigned1")));
    await assertFails(getDoc(doc(as("courier1"), "orders", "new1")));
    await assertSucceeds(getDoc(doc(as("mgr1"), "orders", "other1")));
    await assertSucceeds(getDocs(query(collection(as("buyer1"), "orders"), where("userId", "==", "buyer1"))));
    await assertSucceeds(getDocs(query(collection(as("courier1"), "orders"), where("courierId", "==", "courier1"))));
    await assertFails(getDocs(collection(as("buyer1"), "orders")));
  });

  it("покупатель подтверждает получение только у заказа в доставке", async () => {
    await assertSucceeds(updateDoc(doc(as("buyer1"), "orders", "assigned1"), { userConfirmed: true, updatedAt: serverTimestamp() }));
    await assertSucceeds(updateDoc(doc(as("buyer1"), "orders", "delivering1"), { userConfirmed: true }));
    await assertFails(updateDoc(doc(as("buyer1"), "orders", "new1"), { userConfirmed: true }));
    await assertFails(updateDoc(doc(as("buyer1"), "orders", "cancelled1"), { userConfirmed: true }));
    await assertFails(updateDoc(doc(as("buyer2"), "orders", "assigned1"), { userConfirmed: true }));
  });

  it("покупатель скрывает только завершенные заказы и не меняет статус", async () => {
    await assertSucceeds(updateDoc(doc(as("buyer1"), "orders", "delivered1"), { hiddenByUser: true }));
    await assertSucceeds(updateDoc(doc(as("buyer1"), "orders", "cancelled1"), { hiddenByUser: true }));
    await assertFails(updateDoc(doc(as("buyer1"), "orders", "assigned1"), { hiddenByUser: true }));
    await assertFails(updateDoc(doc(as("buyer1"), "orders", "assigned1"), { statusId: "delivered" }));
    await assertFails(updateDoc(doc(as("buyer1"), "orders", "new1"), { totalAmount: 0 }));
  });

  it("курьер двигает статус только своих активных заказов", async () => {
    const patch = (statusId) => ({ statusId, statusName: statusId, courierId: "courier1", updatedAt: serverTimestamp() });
    await assertSucceeds(updateDoc(doc(as("courier1"), "orders", "assigned1"), patch("delivering")));
    await assertSucceeds(updateDoc(doc(as("courier1"), "orders", "delivering1"), patch("delivered")));
    await assertFails(updateDoc(doc(as("courier1"), "orders", "cancelled1"), patch("delivering")));
    await assertFails(updateDoc(doc(as("courier1"), "orders", "delivered1"), patch("delivering")));
    await assertFails(updateDoc(doc(as("courier1"), "orders", "other1"), patch("delivering")));
    await assertFails(updateDoc(doc(as("courier1"), "orders", "assigned1"), { statusId: "delivering", courierId: "buyer1" }));
    await assertFails(updateDoc(doc(as("courier1"), "orders", "assigned1"), { statusId: "cancelled" }));
    await assertFails(updateDoc(doc(as("courier1"), "orders", "assigned1"), { totalAmount: 1 }));
  });

  it("персонал меняет заказы, удалять их нельзя никому", async () => {
    await assertSucceeds(updateDoc(doc(as("mgr1"), "orders", "new1"), { statusId: "processing", courierId: "courier1" }));
    await assertSucceeds(updateDoc(doc(as("admin1"), "orders", "new1"), { statusId: "cancelled" }));
    await assertFails(deleteDoc(doc(as("admin1"), "orders", "new1")));
    await assertFails(deleteDoc(doc(as("buyer1"), "orders", "new1")));
  });
});

describe("notifications", () => {
  const note = (extra = {}) => ({
    userId: "buyer1",
    text: "Заказ доставлен",
    textEn: "Delivered",
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
    ...extra,
  });

  it("создают курьер и персонал, покупатель нет, лишние поля и длинный текст запрещены", async () => {
    await assertSucceeds(addDoc(collection(as("courier1"), "notifications"), note()));
    await assertSucceeds(addDoc(collection(as("mgr1"), "notifications"), note()));
    await assertFails(addDoc(collection(as("buyer1"), "notifications"), note()));
    await assertFails(addDoc(collection(as("mgr1"), "notifications"), note({ extra: 1 })));
    await assertFails(addDoc(collection(as("courier1"), "notifications"), note({ text: "x".repeat(501) })));
    await assertFails(addDoc(collection(as("courier1"), "notifications"), note({ text: 5 })));
  });

  it("читает и удаляет только адресат", async () => {
    await assertSucceeds(getDoc(doc(as("buyer1"), "notifications", "n1")));
    await assertFails(getDoc(doc(as("buyer2"), "notifications", "n1")));
    await assertFails(deleteDoc(doc(as("buyer2"), "notifications", "n1")));
    await assertSucceeds(deleteDoc(doc(as("buyer1"), "notifications", "n1")));
    await assertFails(updateDoc(doc(as("admin1"), "notifications", "n1"), { text: "x" }));
  });
});

describe("прочее", () => {
  it("неизвестные коллекции закрыты", async () => {
    await assertFails(setDoc(doc(as("admin1"), "secrets", "x"), { a: 1 }));
    await assertFails(getDoc(doc(as("admin1"), "secrets", "x")));
  });

  it("роли и статусы заказов правит только администратор", async () => {
    await assertFails(setDoc(doc(as("mgr1"), "roles", "r1"), { name: "x" }));
    await assertSucceeds(setDoc(doc(as("admin1"), "roles", "r1"), { name: "x" }));
    await assertFails(setDoc(doc(as("mgr1"), "orderStatuses", "s1"), { name: "x" }));
    await assertSucceeds(getDoc(doc(as("buyer1"), "orderStatuses", "s1")));
  });
});
