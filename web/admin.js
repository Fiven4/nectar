import { initializeApp } from "https://www.gstatic.com/firebasejs/10.12.5/firebase-app.js";
import {
  EmailAuthProvider,
  connectAuthEmulator,
  getAuth,
  onAuthStateChanged,
  reauthenticateWithCredential,
  signInWithEmailAndPassword,
  signOut,
  updatePassword,
} from "https://www.gstatic.com/firebasejs/10.12.5/firebase-auth.js";
import {
  collection,
  connectFirestoreEmulator,
  deleteDoc,
  deleteField,
  doc,
  getDoc,
  getDocs,
  getFirestore,
  increment,
  runTransaction,
  serverTimestamp,
  setDoc,
  updateDoc,
  writeBatch,
} from "https://www.gstatic.com/firebasejs/10.12.5/firebase-firestore.js";

import { categoryTranslations, productTranslations } from "./catalog-translations.js";
import { getLanguage, initLocalization, t } from "./i18n.js";
import {
  UserError,
  computeDashboard,
  endOfDay,
  esc,
  friendlyError,
  isFinishedStatus,
  stockRestorations,
  toDateInputValue,
  validateEntityForm,
  validateNewPassword,
  validateOrderChange,
  validateProductForm,
} from "./validation.js";

const firebaseConfig = {
  apiKey: "AIzaSyCfdsjRPSj_d6rqnv0VkTYqozj9mggUwbE",
  appId: "1:70969291340:web:464aa7206ce3067331fae9",
  messagingSenderId: "70969291340",
  projectId: "nectar-41848",
  authDomain: "nectar-41848.firebaseapp.com",
  storageBucket: "nectar-41848.firebasestorage.app",
  measurementId: "G-TR33KSG6WL",
};

// Локальная отладка: http://localhost:8080/?emulator=1 подключает панель к эмуляторам
// Firebase (tool/rules-test) и не трогает боевую базу. На других адресах параметр игнорируется.
const useEmulator =
  ["localhost", "127.0.0.1"].includes(window.location.hostname) &&
  new URLSearchParams(window.location.search).has("emulator");

const app = initializeApp(useEmulator ? { apiKey: "demo-key", projectId: firebaseConfig.projectId } : firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);
if (useEmulator) {
  connectAuthEmulator(auth, "http://127.0.0.1:9099", { disableWarnings: true });
  connectFirestoreEmulator(db, "127.0.0.1", 8080);
}

const state = {
  user: null,
  role: null,
  section: "dashboard",
  products: [],
  categories: [],
  manufacturers: [],
  suppliers: [],
  promoCodes: [],
  users: [],
  orders: [],
  productSearch: "",
  showDisabledUsers: false,
};

const sectionLabels = {
  dashboard: "Дашборд",
  products: "Товары",
  categories: "Категории",
  manufacturers: "Производители",
  suppliers: "Поставщики",
  promoCodes: "Промокоды",
  orders: "Заказы",
  users: "Пользователи",
};

const roleLabels = {
  admin: "Администратор",
  manager: "Менеджер",
  courier: "Курьер",
  buyer: "Покупатель",
};

const statusNames = {
  ru: {
    new: "Новый",
    processing: "В сборке",
    assigned: "Передан курьеру",
    delivering: "В пути",
    delivered: "Доставлен",
    cancelled: "Отменен",
  },
  en: {
    new: "New",
    processing: "Being packed",
    assigned: "Handed to courier",
    delivering: "On the way",
    delivered: "Delivered",
    cancelled: "Cancelled",
  },
};

const collectionConfigs = {
  categories: {
    collectionName: "categories",
    title: "Категории",
    fields: [
      { key: "name", label: "Название", required: true, maxLength: 100 },
      { key: "nameEn", label: "Название (English)", maxLength: 100 },
      { key: "description", label: "Описание", multiline: true, maxLength: 500 },
    ],
  },
  manufacturers: {
    collectionName: "manufacturers",
    title: "Производители",
    fields: [
      { key: "name", label: "Название", required: true, maxLength: 100 },
      { key: "country", label: "Страна", required: true, maxLength: 100 },
      { key: "contactPhone", label: "Телефон", required: true, type: "tel", maxLength: 30 },
    ],
  },
  suppliers: {
    collectionName: "suppliers",
    title: "Поставщики",
    fields: [
      { key: "name", label: "Название", required: true, maxLength: 100 },
      { key: "taxId", label: "ИНН", required: true, maxLength: 12 },
      { key: "address", label: "Адрес", required: true, multiline: true, maxLength: 300 },
      { key: "contactPhone", label: "Телефон", required: true, type: "tel", maxLength: 30 },
      { key: "email", label: "Email", type: "email", maxLength: 100 },
    ],
  },
  promoCodes: {
    collectionName: "promoCodes",
    title: "Промокоды",
    fields: [
      { key: "code", label: "Код", required: true, maxLength: 30 },
      { key: "discountPercent", label: "Скидка, %", required: true, type: "number", min: 1, max: 99, step: 1 },
      { key: "expiresAt", label: "Срок действия", required: true, type: "date" },
    ],
  },
};

const loginView = document.getElementById("login-view");
const adminView = document.getElementById("admin-view");
const loginForm = document.getElementById("login-form");
const loginError = document.getElementById("login-error");
const navTabs = document.getElementById("nav-tabs");
const currentUserName = document.getElementById("current-user-name");
const currentUserRole = document.getElementById("current-user-role");
const modalRoot = document.getElementById("modal-root");
const toastRoot = document.getElementById("toast-root");

initLocalization();

const isAdmin = () => state.role === "admin";

function localizedField(item, field = "name") {
  const value = item?.[field];
  if (getLanguage() === "en" && item?.[`${field}En`]) return item[`${field}En`];
  return value;
}

function getStatusName(statusId, language = "ru") {
  return statusNames[language][statusId] || statusNames[language].processing;
}

/** Легаси-роль customer показывается как покупатель. */
function normalizeRole(role) {
  return role === "customer" ? "buyer" : role || "buyer";
}

function userLabel(user) {
  return user?.displayName || user?.email || "-";
}

function orderTime(order) {
  return order.createdAt?.seconds || 0;
}

/**
 * Выполняет действие пользователя: блокирует кнопку на время работы, показывает
 * понятное сообщение об ошибке и не оставляет необработанных исключений.
 */
async function runGuarded(action, { button = null, success = null } = {}) {
  if (button?.disabled) return;
  if (button) button.disabled = true;
  try {
    const result = await action();
    if (success) showToast(success, "success");
    return result;
  } catch (error) {
    console.error(error);
    showToast(friendlyError(error), "error");
  } finally {
    if (button) button.disabled = false;
  }
}

function confirmAction(message) {
  return window.confirm(t(message));
}

// ---------- Авторизация ----------

loginForm.addEventListener("submit", handleLogin);
document.getElementById("logout-button").addEventListener("click", () => signOut(auth));
document.getElementById("password-button").addEventListener("click", openChangePasswordModal);
document.getElementById("refresh-button").addEventListener("click", (event) => {
  runGuarded(
    async () => {
      await reloadAndRender();
    },
    { button: event.currentTarget, success: "Данные обновлены." }
  );
});

let authRun = 0;

onAuthStateChanged(auth, async (user) => {
  const run = ++authRun;
  if (!user) {
    resetSession();
    return;
  }

  try {
    const profileDoc = await getDoc(doc(db, "users", user.uid));
    if (run !== authRun) return;

    const profileData = profileDoc.exists() ? profileDoc.data() : null;
    if (profileData?.isDeleted === true) {
      await denyAccess("Учетная запись отключена. Обратитесь к администратору.");
      return;
    }
    const role = profileData?.role || "buyer";
    if (!["admin", "manager"].includes(role)) {
      await denyAccess("Недостаточно прав для входа в web-панель.");
      return;
    }

    state.user = {
      uid: user.uid,
      email: user.email,
      displayName: profileData.displayName || user.displayName || "Пользователь",
    };
    state.role = role;
    currentUserName.textContent = state.user.displayName;
    currentUserRole.textContent = roleLabels[role];
    loginView.classList.remove("active");
    adminView.classList.add("active");
    buildNavigation();
    await loadAllData();
    if (run !== authRun) return;
    renderCurrentSection();
  } catch (error) {
    console.error(error);
    await denyAccess(friendlyError(error));
  }
});

async function denyAccess(message) {
  await signOut(auth);
  loginError.textContent = t(message);
  showToast(message, "error");
}

function resetSession() {
  state.user = null;
  state.role = null;
  state.section = "dashboard";
  Object.assign(state, {
    products: [],
    categories: [],
    manufacturers: [],
    suppliers: [],
    promoCodes: [],
    users: [],
    orders: [],
    productSearch: "",
    showDisabledUsers: false,
  });
  closeModal();
  document.querySelectorAll(".panel-section").forEach((section) => {
    section.innerHTML = "";
  });
  loginForm.reset();
  loginView.classList.add("active");
  adminView.classList.remove("active");
}

async function handleLogin(event) {
  event.preventDefault();
  const submitButton = loginForm.querySelector("button[type=submit]");
  loginError.textContent = "";
  const email = document.getElementById("login-email").value.trim();
  const password = document.getElementById("login-password").value;
  if (!email || !password) {
    loginError.textContent = t("Введите email и пароль.");
    return;
  }

  submitButton.disabled = true;
  try {
    await signInWithEmailAndPassword(auth, email, password);
  } catch (error) {
    const wrongCredentials = [
      "auth/invalid-credential",
      "auth/wrong-password",
      "auth/user-not-found",
      "auth/invalid-email",
    ].includes(error.code);
    const message = wrongCredentials ? "Не удалось выполнить вход. Проверьте email и пароль." : friendlyError(error);
    loginError.textContent = t(message);
  } finally {
    submitButton.disabled = false;
  }
}

// ---------- Навигация и загрузка ----------

function buildNavigation() {
  navTabs.innerHTML = "";
  Object.keys(sectionLabels).forEach((section) => {
    const button = document.createElement("button");
    button.type = "button";
    button.textContent = sectionLabels[section];
    button.className = state.section === section ? "active" : "";
    if (state.section === section) button.setAttribute("aria-current", "page");
    button.addEventListener("click", () => {
      state.section = section;
      buildNavigation();
      renderCurrentSection();
    });
    navTabs.appendChild(button);
  });
}

async function loadAllData() {
  const [products, categories, manufacturers, suppliers, promoCodes, users, orders] = await Promise.all([
    readCollection("products"),
    readCollection("categories"),
    readCollection("manufacturers"),
    readCollection("suppliers"),
    readCollection("promoCodes"),
    readCollection("users"),
    readCollection("orders"),
  ]);

  state.products = products;
  state.categories = sortByName(categories);
  state.manufacturers = sortByName(manufacturers);
  state.suppliers = sortByName(suppliers);
  state.promoCodes = promoCodes.sort((left, right) => String(left.code || "").localeCompare(String(right.code || "")));
  state.users = users;
  state.orders = orders.sort((left, right) => orderTime(right) - orderTime(left));
}

function sortByName(items) {
  return items.sort((left, right) => String(left.name || "").localeCompare(String(right.name || ""), "ru"));
}

async function readCollection(collectionName) {
  const snapshot = await getDocs(collection(db, collectionName));
  return snapshot.docs.map((documentSnapshot) => ({
    id: documentSnapshot.id,
    ...documentSnapshot.data(),
  }));
}

async function reloadAndRender() {
  await loadAllData();
  renderCurrentSection();
}

const activeUsers = () => state.users.filter((user) => user.isDeleted !== true);

function renderCurrentSection() {
  document.querySelectorAll(".panel-section").forEach((sectionElement) => {
    sectionElement.classList.add("hidden");
  });
  const currentSection = document.getElementById(`${state.section}-section`);
  if (!currentSection) return;
  currentSection.classList.remove("hidden");

  if (state.section === "dashboard") renderDashboard(currentSection);
  if (state.section === "products") renderProducts(currentSection);
  if (state.section === "orders") renderOrders(currentSection);
  if (state.section === "users") renderUsers(currentSection);
  if (["categories", "manufacturers", "suppliers", "promoCodes"].includes(state.section)) {
    renderGenericCollection(currentSection, state.section);
  }
}

// ---------- Дашборд ----------

function renderDashboard(container) {
  const dashboard = computeDashboard({
    users: activeUsers(),
    products: state.products,
    orders: state.orders,
    catalogLabel: (product) => localizedField(product),
  });

  container.innerHTML = `
    <div class="section-header">
      <div>
        <h2>Дашборд</h2>
        <p class="muted">Мониторинг клиентов, заказов и товаров магазина.</p>
      </div>
      <div class="section-actions">
        ${isAdmin() ? `<button class="ghost-button" type="button" id="sync-translations-button">Дозаполнить английские переводы каталога</button>` : ""}
      </div>
    </div>
    <div class="metrics-grid">
      <article class="metric-card">
        <div class="metric-card__label">Покупатели</div>
        <div class="metric-card__value">${dashboard.buyersCount}</div>
      </article>
      <article class="metric-card">
        <div class="metric-card__label">Активные заказы</div>
        <div class="metric-card__value">${dashboard.activeOrdersCount}</div>
      </article>
      <article class="metric-card">
        <div class="metric-card__label">Товары с низким остатком</div>
        <div class="metric-card__value">${dashboard.lowStockCount}</div>
      </article>
      <article class="metric-card">
        <div class="metric-card__label">Общая выручка</div>
        <div class="metric-card__value">₽${dashboard.totalSales.toFixed(2)}</div>
      </article>
    </div>
    <div class="stats-grid">
      <article class="chart-card">
        <h3>Продажи по месяцам</h3>
        <div class="chart-bars">
          ${renderBars(dashboard.monthlySales)}
        </div>
      </article>
      <article class="chart-card">
        <h3>ТОП-5 товаров</h3>
        <div class="chart-bars">
          ${renderBars(dashboard.topProducts)}
        </div>
      </article>
    </div>
  `;

  const syncButton = document.getElementById("sync-translations-button");
  syncButton?.addEventListener("click", () => runGuarded(syncCatalogTranslations, { button: syncButton }));
}

async function commitInChunks(operations) {
  const chunkSize = 400;
  for (let start = 0; start < operations.length; start += chunkSize) {
    const batch = writeBatch(db);
    operations.slice(start, start + chunkSize).forEach((apply) => apply(batch));
    await batch.commit();
  }
}

async function syncCatalogTranslations() {
  const operations = [];

  state.categories.forEach((category) => {
    const translation = categoryTranslations[category.id];
    if (translation && !category.nameEn) {
      operations.push((batch) =>
        batch.update(doc(db, "categories", category.id), {
          nameEn: translation.name,
          descriptionEn: translation.description,
          updatedAt: serverTimestamp(),
        })
      );
    }
  });

  state.products.forEach((product) => {
    const translation = productTranslations[product.id];
    if (translation && !product.nameEn) {
      operations.push((batch) =>
        batch.update(doc(db, "products", product.id), {
          nameEn: translation.name,
          descriptionEn: translation.description,
          compositionEn: translation.composition,
          categoryNameEn: categoryTranslations[product.categoryId]?.name || "",
          updatedAt: serverTimestamp(),
        })
      );
    }
  });

  if (operations.length > 0) {
    await commitInChunks(operations);
    await reloadAndRender();
  }
  showToast(operations.length > 0 ? `Обновлено записей: ${operations.length}` : "Переводы уже загружены.", "success");
}

function renderBars(entries) {
  if (!entries.length) {
    return `<p class="muted">Пока недостаточно данных.</p>`;
  }

  const maxValue = Math.max(...entries.map((entry) => Number(entry[1] || 0)), 1);
  return entries
    .map(([label, value]) => {
      const width = Math.max(8, (Number(value) / maxValue) * 100);
      return `
        <div class="bar-row">
          <span>${esc(label)}</span>
          <div class="bar-track">
            <div class="bar-fill" style="width:${width}%"></div>
          </div>
          <strong>${Number(value).toFixed(0)}</strong>
        </div>
      `;
    })
    .join("");
}

// ---------- Товары ----------

function renderProducts(container) {
  container.innerHTML = `
    <div class="section-header">
      <div>
        <h2>Товары</h2>
        <p class="muted">Создание, редактирование и мягкое удаление товаров.</p>
      </div>
      <div class="section-actions">
        <button class="primary-button" type="button" id="add-product-button">Добавить товар</button>
      </div>
    </div>
    <div class="table-card">
      <div class="toolbar">
        <input id="product-search" type="search" placeholder="Поиск по названию товара" value="${esc(state.productSearch)}" />
      </div>
      <table>
        <thead>
          <tr>
            <th>Название</th>
            <th>Категория</th>
            <th>Цена</th>
            <th>Остаток</th>
            <th>Статус</th>
            <th>Действия</th>
          </tr>
        </thead>
        <tbody id="products-body">${renderProductRows(filterProducts())}</tbody>
      </table>
    </div>
  `;

  document.getElementById("add-product-button").addEventListener("click", () => openProductModal());
  document.getElementById("product-search").addEventListener("input", (event) => {
    state.productSearch = event.target.value;
    document.getElementById("products-body").innerHTML = renderProductRows(filterProducts());
    bindProductActions();
  });
  bindProductActions();
}

function filterProducts() {
  const query = state.productSearch.trim().toLowerCase();
  if (!query) return state.products;
  return state.products.filter((product) => `${product.name || ""} ${product.nameEn || ""}`.toLowerCase().includes(query));
}

function categoryLabel(product) {
  const category = state.categories.find((item) => item.id === product.categoryId);
  return (category ? localizedField(category) : product.categoryName) || "-";
}

function renderProductRows(products) {
  if (!products.length) {
    return `<tr><td colspan="6" class="muted">Товары не найдены.</td></tr>`;
  }
  return products
    .map((product) => {
      const statusBadge = product.isDeleted
        ? `<span class="badge warning">Скрыт</span>`
        : `<span class="badge">Активен</span>`;
      const toggleButton = product.isDeleted
        ? `<button class="ghost-button" type="button" data-restore-product="${esc(product.id)}">Восстановить</button>`
        : `<button class="danger-button" type="button" data-delete-product="${esc(product.id)}">Удалить</button>`;
      return `
        <tr>
          <td>${esc(localizedField(product) || "-")}</td>
          <td>${esc(categoryLabel(product))}</td>
          <td>₽${Number(product.price || 0).toFixed(2)}</td>
          <td>${Number(product.stockQuantity || 0)}</td>
          <td>${statusBadge}</td>
          <td>
            <div class="table-actions">
              <button class="ghost-button" type="button" data-edit-product="${esc(product.id)}">Редактировать</button>
              ${toggleButton}
            </div>
          </td>
        </tr>
      `;
    })
    .join("");
}

function bindProductActions() {
  document.querySelectorAll("[data-edit-product]").forEach((button) => {
    button.addEventListener("click", () => {
      const product = state.products.find((item) => item.id === button.dataset.editProduct);
      if (product) openProductModal(product);
    });
  });

  document.querySelectorAll("[data-delete-product]").forEach((button) => {
    button.addEventListener("click", () => {
      if (!confirmAction("Скрыть товар из каталога? Его можно будет восстановить.")) return;
      setProductHidden(button, button.dataset.deleteProduct, true, "Товар скрыт из каталога.");
    });
  });

  document.querySelectorAll("[data-restore-product]").forEach((button) => {
    button.addEventListener("click", () => {
      setProductHidden(button, button.dataset.restoreProduct, false, "Товар снова доступен в каталоге.");
    });
  });
}

function setProductHidden(button, productId, isDeleted, successMessage) {
  return runGuarded(
    async () => {
      await updateDoc(doc(db, "products", productId), { isDeleted, updatedAt: serverTimestamp() });
      await reloadAndRender();
    },
    { button, success: successMessage }
  );
}

// ---------- Справочники ----------

function renderGenericCollection(container, section) {
  const config = collectionConfigs[section];
  const items = state[section];
  const canEdit = !(section === "suppliers" && !isAdmin());
  const title = config.title;

  container.innerHTML = `
    <div class="section-header">
      <div>
        <h2>${title}</h2>
        <p class="muted">Справочник коллекции ${title.toLowerCase()}.</p>
      </div>
      <div class="section-actions">
        ${canEdit ? `<button class="primary-button" type="button" id="add-${section}-button">Добавить</button>` : ""}
      </div>
    </div>
    <div class="table-card">
      <table>
        <thead>
          <tr>
            ${config.fields.map((field) => `<th>${field.label}</th>`).join("")}
            <th>Действия</th>
          </tr>
        </thead>
        <tbody>
          ${
            items.length
              ? items.map((item) => renderGenericRow(section, config, item, canEdit)).join("")
              : `<tr><td colspan="${config.fields.length + 1}" class="muted">Записей пока нет.</td></tr>`
          }
        </tbody>
      </table>
    </div>
  `;

  document.getElementById(`add-${section}-button`)?.addEventListener("click", () => openGenericModal(section));

  container.querySelectorAll("[data-edit-entity]").forEach((button) => {
    button.addEventListener("click", () => {
      const item = state[button.dataset.editEntity].find((entry) => entry.id === button.dataset.id);
      if (item) openGenericModal(button.dataset.editEntity, item);
    });
  });

  container.querySelectorAll("[data-delete-entity]").forEach((button) => {
    button.addEventListener("click", () => {
      if (!confirmAction("Удалить запись? Это действие нельзя отменить.")) return;
      runGuarded(
        async () => {
          await deleteEntity(button.dataset.deleteEntity, button.dataset.id);
          await reloadAndRender();
        },
        { button, success: "Запись удалена." }
      );
    });
  });
}

function renderGenericRow(section, config, item, canEdit) {
  const cells = config.fields
    .map((field) => {
      let value = item[field.key] || "-";
      if (field.type === "date") {
        value = item[field.key]?.seconds ? new Date(item[field.key].seconds * 1000).toLocaleDateString("ru-RU") : "-";
      }
      if (field.key === "discountPercent") value = `${item[field.key] ?? "-"}%`;
      return `<td>${esc(value)}</td>`;
    })
    .join("");

  const actions = canEdit
    ? `<div class="table-actions">
         <button class="ghost-button" type="button" data-edit-entity="${section}" data-id="${esc(item.id)}">Редактировать</button>
         <button class="danger-button" type="button" data-delete-entity="${section}" data-id="${esc(item.id)}">Удалить</button>
       </div>`
    : `<span class="muted">Только просмотр</span>`;
  return `<tr>${cells}<td>${actions}</td></tr>`;
}

const linkedProductField = {
  categories: "categoryId",
  manufacturers: "manufacturerId",
  suppliers: "supplierId",
};

const linkedProductError = {
  categories: "Нельзя удалить категорию: к ней привязаны товары.",
  manufacturers: "Нельзя удалить производителя: к нему привязаны товары.",
  suppliers: "Нельзя удалить поставщика: к нему привязаны товары.",
};

async function deleteEntity(section, itemId) {
  const linkField = linkedProductField[section];
  if (linkField) {
    // Актуальные товары читаем заново: список в памяти мог устареть.
    const products = await readCollection("products");
    if (products.some((product) => product[linkField] === itemId)) {
      throw new UserError(linkedProductError[section]);
    }
  }

  if (section === "promoCodes") {
    const orders = await readCollection("orders");
    if (orders.some((order) => order.promoCodeId === itemId && !isFinishedStatus(order.statusId))) {
      throw new UserError("Нельзя удалить промокод: он используется в незавершенных заказах.");
    }
  }

  await deleteDoc(doc(db, collectionConfigs[section].collectionName, itemId));
}

function openGenericModal(section, existingItem = null) {
  const config = collectionConfigs[section];
  const fieldsMarkup = config.fields
    .map((field) => {
      const rawValue = existingItem?.[field.key];
      let value = rawValue ?? "";
      if (field.type === "date") value = toDateInputValue(rawValue);
      const attributes = [
        `data-field="${field.key}"`,
        field.required ? "required" : "",
        field.maxLength ? `maxlength="${field.maxLength}"` : "",
        field.min !== undefined ? `min="${field.min}"` : "",
        field.max !== undefined ? `max="${field.max}"` : "",
        field.step !== undefined ? `step="${field.step}"` : "",
      ]
        .filter(Boolean)
        .join(" ");
      if (field.multiline) {
        return `
          <label class="full">
            <span>${field.label}</span>
            <textarea ${attributes}>${esc(value)}</textarea>
          </label>
        `;
      }
      return `
        <label>
          <span>${field.label}</span>
          <input ${attributes} type="${field.type || "text"}" value="${esc(value)}" />
        </label>
      `;
    })
    .join("");

  openModal({
    title: existingItem ? `Редактировать: ${config.title}` : `Добавить: ${config.title}`,
    body: `<div class="modal-grid">${fieldsMarkup}</div>`,
    onSubmit: async (modalElement) => {
      const values = {};
      config.fields.forEach((field) => {
        values[field.key] = modalElement.querySelector(`[data-field="${field.key}"]`).value.trim();
      });

      const error = validateEntityForm(section, values);
      if (error) throw new UserError(error);
      assertUnique(section, values, existingItem);

      const payload = buildEntityPayload(section, values, existingItem);
      payload.updatedAt = serverTimestamp();
      payload.createdAt = existingItem?.createdAt || serverTimestamp();

      await setDoc(doc(db, config.collectionName, existingItem?.id || doc(collection(db, config.collectionName)).id), payload, {
        merge: true,
      });
      if (existingItem) await propagateRename(section, existingItem, payload);
      await reloadAndRender();
      showToast("Изменения сохранены.", "success");
    },
  });
}

function buildEntityPayload(section, values, existingItem) {
  switch (section) {
    case "categories":
      return {
        name: values.name,
        nameNormalized: values.name.toLowerCase(),
        nameEn: values.nameEn,
        description: values.description,
      };
    case "manufacturers":
      return {
        name: values.name,
        nameNormalized: values.name.toLowerCase(),
        country: values.country,
        contactPhone: values.contactPhone,
      };
    case "suppliers":
      return {
        name: values.name,
        nameNormalized: values.name.toLowerCase(),
        taxId: values.taxId,
        address: values.address,
        contactPhone: values.contactPhone,
        email: values.email.toLowerCase(),
      };
    case "promoCodes": {
      const code = values.code.toUpperCase();
      return {
        code,
        codeNormalized: code,
        discountPercent: Number(values.discountPercent),
        expiresAt: endOfDay(values.expiresAt),
        isActive: existingItem?.isActive ?? true,
        usageCount: existingItem?.usageCount ?? 0,
      };
    }
    default:
      return { ...values };
  }
}

const uniqueMessages = {
  categories: "Категория с таким названием уже существует.",
  manufacturers: "Производитель с таким названием уже существует.",
  suppliers: "Поставщик с таким названием уже существует.",
  promoCodes: "Промокод с таким кодом уже существует.",
};

function assertUnique(section, values, existingItem) {
  const key = section === "promoCodes" ? "code" : "name";
  const wanted = values[key].trim().toLowerCase();
  const duplicate = state[section].some(
    (item) => item.id !== existingItem?.id && String(item[key] || "").trim().toLowerCase() === wanted
  );
  if (duplicate) throw new UserError(uniqueMessages[section]);
}

/** Название справочника дублируется в товарах: при переименовании обновляем и их. */
async function propagateRename(section, existingItem, payload) {
  const rename = {
    categories: { idField: "categoryId", changes: { categoryName: payload.name, categoryNameEn: payload.nameEn || "" } },
    manufacturers: { idField: "manufacturerId", changes: { manufacturerName: payload.name } },
    suppliers: { idField: "supplierId", changes: { supplierName: payload.name } },
  }[section];
  if (!rename || existingItem.name === payload.name) return;

  const operations = state.products
    .filter((product) => product[rename.idField] === existingItem.id)
    .map((product) => (batch) =>
      batch.update(doc(db, "products", product.id), { ...rename.changes, updatedAt: serverTimestamp() })
    );
  await commitInChunks(operations);
}

// ---------- Заказы ----------

function courierOptionsFor(order) {
  const couriers = activeUsers().filter((user) => user.role === "courier");
  const options = couriers.map((user) => ({ id: user.id, label: userLabel(user) }));
  if (order.courierId && !options.some((option) => option.id === order.courierId)) {
    options.push({ id: order.courierId, label: order.courierName || order.courierId });
  }
  return options
    .map(
      (option) =>
        `<option value="${esc(option.id)}" ${option.id === order.courierId ? "selected" : ""}>${esc(option.label)}</option>`
    )
    .join("");
}

function renderOrders(container) {
  const statusOptions = (order) =>
    Object.entries(statusNames.ru)
      .map(([id, name]) => `<option value="${id}" ${order.statusId === id ? "selected" : ""}>${name}</option>`)
      .join("");

  container.innerHTML = `
    <div class="section-header">
      <div>
        <h2>Заказы</h2>
        <p class="muted">Смена статуса и назначение курьера.</p>
      </div>
    </div>
    <div class="table-card">
      <table>
        <thead>
          <tr>
            <th>Номер</th>
            <th>Клиент</th>
            <th>Сумма</th>
            <th>Статус</th>
            <th>Курьер</th>
            <th>Действия</th>
          </tr>
        </thead>
        <tbody>
          ${
            state.orders.length
              ? state.orders
                  .map((order) => {
                    const locked = isFinishedStatus(order.statusId);
                    return `
                <tr>
                  <td>${esc(order.number || order.id)}</td>
                  <td>${esc(order.customerName || order.customerEmail || "-")}</td>
                  <td>₽${Number(order.totalAmount || 0).toFixed(2)}</td>
                  <td>
                    <select data-order-status="${esc(order.id)}" ${locked ? "disabled" : ""}>${statusOptions(order)}</select>
                  </td>
                  <td>
                    <select data-order-courier="${esc(order.id)}" ${locked ? "disabled" : ""}>
                      <option value="">Не назначен</option>
                      ${courierOptionsFor(order)}
                    </select>
                  </td>
                  <td>
                    ${
                      locked
                        ? `<span class="muted">Заказ завершен</span>`
                        : `<button class="primary-button" type="button" data-save-order="${esc(order.id)}">Сохранить</button>`
                    }
                  </td>
                </tr>
              `;
                  })
                  .join("")
              : `<tr><td colspan="6" class="muted">Заказов пока нет.</td></tr>`
          }
        </tbody>
      </table>
    </div>
  `;

  container.querySelectorAll("[data-save-order]").forEach((button) => {
    button.addEventListener("click", () => {
      const orderId = button.dataset.saveOrder;
      const statusId = container.querySelector(`[data-order-status="${orderId}"]`).value;
      const courierId = container.querySelector(`[data-order-courier="${orderId}"]`).value;
      if (statusId === "cancelled" && !confirmAction("Отменить заказ? Товары вернутся на склад, статус нельзя будет изменить.")) return;
      runGuarded(() => saveOrder(orderId, { statusId, courierId }), { button });
    });
  });
}

/**
 * Сохраняет заказ в транзакции: статус, курьер, уведомление покупателю и (при отмене)
 * возврат товаров на склад. Устаревшие данные на экране не могут перезаписать чужие
 * изменения, а остатки не вернутся дважды.
 */
async function saveOrder(orderId, { statusId, courierId }) {
  const orderRef = doc(db, "orders", orderId);
  const courier = activeUsers().find((user) => user.id === courierId);
  let outcome = "saved";

  await runTransaction(db, async (transaction) => {
    const orderSnapshot = await transaction.get(orderRef);
    if (!orderSnapshot.exists()) throw new UserError("Заказ не найден. Обновите данные.");
    const order = { id: orderSnapshot.id, ...orderSnapshot.data() };

    const error = validateOrderChange(order, { statusId, courierId });
    if (error) throw new UserError(error);

    const statusChanged = order.statusId !== statusId;
    const courierChanged = (order.courierId || null) !== (courierId || null);
    if (!statusChanged && !courierChanged) {
      outcome = "unchanged";
      return;
    }

    const restorations = statusChanged && statusId === "cancelled" ? stockRestorations(order) : [];
    const productRefs = restorations.map(({ id }) => doc(db, "products", id));
    const productSnapshots = await Promise.all(productRefs.map((ref) => transaction.get(ref)));

    if (courierChanged && courierId && !courier) throw new UserError("Курьер не найден или отключен. Обновите данные.");

    const courierUnchanged = !courierChanged;
    transaction.update(orderRef, {
      statusId,
      statusName: getStatusName(statusId),
      courierId: courierId || null,
      courierName: courierId ? (courier ? userLabel(courier) : courierUnchanged ? order.courierName || null : null) : null,
      courierPhone: courierId ? (courier ? courier.phoneNumber || null : courierUnchanged ? order.courierPhone || null : null) : null,
      statusChangedAt: statusChanged ? serverTimestamp() : order.statusChangedAt || null,
      statusChangedBy: statusChanged ? auth.currentUser.uid : order.statusChangedBy || null,
      updatedAt: serverTimestamp(),
    });

    restorations.forEach(({ quantity }, index) => {
      if (productSnapshots[index].exists()) {
        transaction.update(productRefs[index], { stockQuantity: increment(quantity), updatedAt: serverTimestamp() });
      }
    });

    if (courierChanged && courierId) {
      const number = order.number || orderId;
      transaction.set(doc(collection(db, "notifications")), {
        userId: courierId,
        text: `Вам назначен заказ №${number}`,
        textEn: `Order #${number} has been assigned to you`,
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
      });
    }

    if (statusChanged && order.userId) {
      const number = order.number || orderId;
      transaction.set(doc(collection(db, "notifications")), {
        userId: order.userId,
        text: `Заказ №${number}: статус изменен на «${getStatusName(statusId)}»`,
        textEn: `Order #${number}: status changed to “${getStatusName(statusId, "en")}”`,
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
      });
    }
  });

  await reloadAndRender();
  showToast(outcome === "unchanged" ? "Изменений нет." : "Заказ обновлен.", "success");
}

// ---------- Пользователи ----------

function hasActiveOrders(user) {
  const field = user.role === "courier" ? "courierId" : "userId";
  return state.orders.some((order) => order[field] === user.id && !isFinishedStatus(order.statusId));
}

function renderUsers(container) {
  const canManage = isAdmin();
  const users = state.users
    .filter((user) => state.showDisabledUsers || user.isDeleted !== true)
    .sort((left, right) => String(left.displayName || "").localeCompare(String(right.displayName || ""), "ru"));

  const roleCell = (user) => {
    const role = normalizeRole(user.role);
    if (!canManage || user.id === state.user.uid) return esc(roleLabels[role] || role);
    const known = Object.keys(roleLabels);
    const options = (known.includes(role) ? known : [...known, role])
      .map((id) => `<option value="${esc(id)}" ${role === id ? "selected" : ""}>${esc(roleLabels[id] || id)}</option>`)
      .join("");
    return `<select data-user-role="${esc(user.id)}">${options}</select>`;
  };

  const actionCell = (user) => {
    if (!canManage) return `<span class="muted">Только просмотр</span>`;
    if (user.id === state.user.uid) return `<span class="muted">Это вы</span>`;
    if (user.isDeleted === true) {
      return `<button class="ghost-button" type="button" data-restore-user="${esc(user.id)}">Восстановить</button>`;
    }
    return `<div class="table-actions">
      <button class="primary-button" type="button" data-save-user="${esc(user.id)}">Сохранить роль</button>
      <button class="danger-button" type="button" data-delete-user="${esc(user.id)}">Отключить</button>
    </div>`;
  };

  container.innerHTML = `
    <div class="section-header">
      <div>
        <h2>Пользователи</h2>
        <p class="muted">Просмотр карточек пользователей и смена ролей.</p>
      </div>
      ${
        canManage
          ? `<div class="section-actions">
               <label class="inline-check"><input type="checkbox" id="show-disabled-users" ${state.showDisabledUsers ? "checked" : ""} /> <span>Показывать отключенных</span></label>
             </div>`
          : ""
      }
    </div>
    <div class="table-card">
      <table>
        <thead>
          <tr>
            <th>Имя</th>
            <th>Логин</th>
            <th>Email</th>
            <th>Телефон</th>
            <th>Роль</th>
            <th>Действия</th>
          </tr>
        </thead>
        <tbody>
          ${
            users.length
              ? users
                  .map(
                    (user) => `
                <tr class="${user.isDeleted === true ? "row-disabled" : ""}">
                  <td>${esc(user.displayName || "-")}</td>
                  <td>${esc(user.login || "-")}</td>
                  <td>${esc(user.email || "-")}</td>
                  <td>${esc(user.phoneNumber || "-")}</td>
                  <td>${roleCell(user)}</td>
                  <td>${actionCell(user)}</td>
                </tr>`
                  )
                  .join("")
              : `<tr><td colspan="6" class="muted">Пользователей нет.</td></tr>`
          }
        </tbody>
      </table>
    </div>
  `;

  document.getElementById("show-disabled-users")?.addEventListener("change", (event) => {
    state.showDisabledUsers = event.target.checked;
    renderUsers(container);
  });

  container.querySelectorAll("[data-save-user]").forEach((button) => {
    button.addEventListener("click", () => {
      const user = state.users.find((item) => item.id === button.dataset.saveUser);
      const select = container.querySelector(`[data-user-role="${button.dataset.saveUser}"]`);
      runGuarded(() => changeUserRole(user, select.value), { button });
    });
  });

  container.querySelectorAll("[data-delete-user]").forEach((button) => {
    button.addEventListener("click", () => {
      const user = state.users.find((item) => item.id === button.dataset.deleteUser);
      if (!confirmAction("Отключить пользователя? Он не сможет войти в приложение.")) return;
      runGuarded(() => disableUser(user), { button });
    });
  });

  container.querySelectorAll("[data-restore-user]").forEach((button) => {
    button.addEventListener("click", () => {
      runGuarded(
        async () => {
          await updateDoc(doc(db, "users", button.dataset.restoreUser), {
            isDeleted: false,
            deletedBy: deleteField(),
            deletedAt: deleteField(),
            updatedAt: serverTimestamp(),
          });
          await reloadAndRender();
        },
        { button, success: "Пользователь восстановлен." }
      );
    });
  });
}

function otherActiveAdmins(user) {
  return activeUsers().filter((item) => item.role === "admin" && item.id !== user.id).length;
}

async function changeUserRole(user, role) {
  if (!user) throw new UserError("Пользователь не найден. Обновите данные.");
  if (user.id === state.user.uid) throw new UserError("Нельзя изменить собственную роль.");
  if (normalizeRole(user.role) === role) {
    showToast("Изменений нет.", "success");
    return;
  }
  if (user.role === "admin" && otherActiveAdmins(user) === 0) {
    throw new UserError("Нельзя снять роль с последнего администратора.");
  }
  if (hasActiveOrders(user)) {
    throw new UserError("У пользователя есть незавершенные заказы: смена роли сейчас невозможна.");
  }
  await updateDoc(doc(db, "users", user.id), { role, updatedAt: serverTimestamp() });
  await reloadAndRender();
  showToast("Роль пользователя обновлена.", "success");
}

async function disableUser(user) {
  if (!user) throw new UserError("Пользователь не найден. Обновите данные.");
  if (user.id === state.user.uid) throw new UserError("Нельзя отключить собственную учетную запись.");
  if (user.role === "admin" && otherActiveAdmins(user) === 0) {
    throw new UserError("Нельзя отключить последнего администратора.");
  }
  if (hasActiveOrders(user)) {
    throw new UserError("У пользователя есть незавершенные заказы: отключение сейчас невозможно.");
  }
  await updateDoc(doc(db, "users", user.id), {
    isDeleted: true,
    deletedBy: auth.currentUser.uid,
    deletedAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });
  await reloadAndRender();
  showToast("Пользователь отключен.", "success");
}

// ---------- Модальные окна ----------

function openProductModal(existingProduct = null) {
  const selectOptions = (items, selectedId, labelOf) =>
    items
      .map((item) => `<option value="${esc(item.id)}" ${selectedId === item.id ? "selected" : ""}>${esc(labelOf(item))}</option>`)
      .join("");

  const categoryOptions = selectOptions(state.categories, existingProduct?.categoryId, localizedField);
  const manufacturerOptions = selectOptions(state.manufacturers, existingProduct?.manufacturerId, (item) => item.name);
  const supplierOptions = `<option value="">Не выбран</option>${selectOptions(state.suppliers, existingProduct?.supplierId, (item) => item.name)}`;
  const stock = existingProduct?.stockQuantity ?? 0;

  openModal({
    title: existingProduct ? "Редактировать товар" : "Добавить товар",
    body: `
      <div class="modal-grid">
        <label><span>Название</span><input data-field="name" maxlength="255" value="${esc(existingProduct?.name)}" required /></label>
        <label><span>Цена</span><input data-field="price" type="number" min="0.01" max="1000000" step="0.01" value="${esc(existingProduct?.price)}" required /></label>
        <label><span>Количество</span><input data-field="stockQuantity" type="number" min="0" max="9999" step="1" value="${esc(stock)}" required /></label>
        <label><span>Единица</span><input data-field="qty" maxlength="50" value="${esc(existingProduct?.qty || "1 шт")}" required /></label>
        <label><span>Категория</span><select data-field="categoryId" required>${categoryOptions}</select></label>
        <label><span>Производитель</span><select data-field="manufacturerId" required>${manufacturerOptions}</select></label>
        <label><span>Поставщик</span><select data-field="supplierId">${supplierOptions}</select></label>
        <label><span>Ссылка на изображение</span><input data-field="imageUrl" type="url" maxlength="2000" value="${esc(existingProduct?.imageUrl)}" /></label>
        <label><span>Страна происхождения</span><input data-field="country" maxlength="100" value="${esc(existingProduct?.country)}" /></label>
        <label><span>Срок годности до</span><input data-field="expiryDate" type="date" value="${esc(toDateInputValue(existingProduct?.expiryDate))}" /></label>
        <label><span>Калорийность, ккал / 100 г</span><input data-field="calories" type="number" min="0" max="10000" step="0.1" value="${esc(existingProduct?.calories ?? 0)}" /></label>
        <label><span>Белки, г</span><input data-field="proteins" type="number" min="0" max="10000" step="0.1" value="${esc(existingProduct?.proteins ?? 0)}" /></label>
        <label><span>Жиры, г</span><input data-field="fats" type="number" min="0" max="10000" step="0.1" value="${esc(existingProduct?.fats ?? 0)}" /></label>
        <label><span>Углеводы, г</span><input data-field="carbs" type="number" min="0" max="10000" step="0.1" value="${esc(existingProduct?.carbs ?? 0)}" /></label>
        <label class="full"><span>Состав</span><textarea data-field="composition" maxlength="2000">${esc(existingProduct?.composition)}</textarea></label>
        <label class="full"><span>Описание</span><textarea data-field="description" maxlength="2000">${esc(existingProduct?.description)}</textarea></label>
        <label><span>Название (English)</span><input data-field="nameEn" maxlength="255" value="${esc(existingProduct?.nameEn)}" /></label>
        <label class="full"><span>Состав (English)</span><textarea data-field="compositionEn" maxlength="2000">${esc(existingProduct?.compositionEn)}</textarea></label>
        <label class="full"><span>Описание (English)</span><textarea data-field="descriptionEn" maxlength="2000">${esc(existingProduct?.descriptionEn)}</textarea></label>
      </div>
    `,
    onSubmit: async (modalElement) => {
      const readField = (key) => modalElement.querySelector(`[data-field="${key}"]`).value.trim();
      const values = Object.fromEntries(
        [
          "name", "price", "stockQuantity", "qty", "categoryId", "manufacturerId", "supplierId", "imageUrl", "country",
          "expiryDate", "calories", "proteins", "fats", "carbs", "composition", "description", "nameEn",
          "compositionEn", "descriptionEn",
        ].map((key) => [key, readField(key)])
      );

      const error = validateProductForm(values);
      if (error) throw new UserError(error);

      const category = state.categories.find((item) => item.id === values.categoryId);
      const manufacturer = state.manufacturers.find((item) => item.id === values.manufacturerId);
      const supplier = state.suppliers.find((item) => item.id === values.supplierId);
      if (!category) throw new UserError("Выберите категорию товара.");
      if (!manufacturer) throw new UserError("Выберите производителя товара.");

      const payload = {
        name: values.name,
        nameNormalized: values.name.toLowerCase(),
        nameEn: values.nameEn,
        price: Number(values.price.replace(",", ".")),
        stockQuantity: Number(values.stockQuantity),
        qty: values.qty,
        description: values.description,
        descriptionEn: values.descriptionEn,
        composition: values.composition,
        compositionEn: values.compositionEn,
        country: values.country,
        imageUrl: values.imageUrl,
        expiryDate: values.expiryDate ? endOfDay(values.expiryDate) : null,
        calories: Number(values.calories.replace(",", ".") || 0),
        proteins: Number(values.proteins.replace(",", ".") || 0),
        fats: Number(values.fats.replace(",", ".") || 0),
        carbs: Number(values.carbs.replace(",", ".") || 0),
        categoryId: category.id,
        categoryName: category.name || "",
        categoryNameEn: category.nameEn || "",
        manufacturerId: manufacturer.id,
        manufacturerName: manufacturer.name || "",
        supplierId: supplier?.id || null,
        supplierName: supplier?.name || null,
        isDeleted: existingProduct?.isDeleted || false,
        updatedAt: serverTimestamp(),
        createdAt: existingProduct?.createdAt || serverTimestamp(),
      };
      if (!existingProduct) {
        payload.minStock = 5;
        payload.popularity = 0;
      }

      await setDoc(doc(db, "products", existingProduct?.id || doc(collection(db, "products")).id), payload, { merge: true });
      await reloadAndRender();
      showToast("Товар сохранен.", "success");
    },
  });
}

function openChangePasswordModal() {
  openModal({
    title: "Смена пароля",
    body: `
      <div class="modal-grid">
        <label class="full"><span>Текущий пароль</span><input data-field="currentPassword" type="password" autocomplete="current-password" required /></label>
        <label class="full"><span>Новый пароль (минимум 6 символов, буквы и цифры)</span><input data-field="newPassword" type="password" autocomplete="new-password" minlength="6" maxlength="128" required /></label>
        <label class="full"><span>Повторите новый пароль</span><input data-field="confirmPassword" type="password" autocomplete="new-password" required /></label>
      </div>
    `,
    onSubmit: async (modalElement) => {
      const readField = (key) => modalElement.querySelector(`[data-field="${key}"]`).value;
      const currentPassword = readField("currentPassword");
      const newPassword = readField("newPassword");

      const error = validateNewPassword(newPassword, currentPassword, readField("confirmPassword"));
      if (error) throw new UserError(error);

      try {
        const credential = EmailAuthProvider.credential(auth.currentUser.email, currentPassword);
        await reauthenticateWithCredential(auth.currentUser, credential);
        await updatePassword(auth.currentUser, newPassword);
      } catch (authError) {
        if (["auth/wrong-password", "auth/invalid-credential"].includes(authError.code)) {
          throw new UserError("Неверный текущий пароль.");
        }
        throw authError;
      }
      showToast("Пароль успешно изменен.", "success");
    },
  });
}

let closeActiveModal = () => {};

function openModal({ title, body, onSubmit }) {
  closeModal();
  modalRoot.innerHTML = `
    <div class="modal-backdrop">
      <div class="modal-card" role="dialog" aria-modal="true" aria-labelledby="modal-title">
        <h3 id="modal-title">${title}</h3>
        <div class="muted" style="margin: 8px 0 20px;">Все изменения сохраняются прямо в Cloud Firestore.</div>
        <form id="modal-form">
          ${body}
          <div class="modal-actions">
            <button type="button" class="ghost-button" id="modal-cancel">Отмена</button>
            <button type="submit" class="primary-button">Сохранить</button>
          </div>
        </form>
      </div>
    </div>
  `;

  const modalForm = document.getElementById("modal-form");
  const submitButton = modalForm.querySelector("button[type=submit]");
  const onKeyDown = (event) => {
    if (event.key === "Escape") closeModal();
  };
  document.addEventListener("keydown", onKeyDown);
  closeActiveModal = () => document.removeEventListener("keydown", onKeyDown);

  document.getElementById("modal-cancel").addEventListener("click", closeModal);
  modalForm.addEventListener("submit", async (event) => {
    event.preventDefault();
    if (submitButton.disabled) return;
    submitButton.disabled = true;
    try {
      await onSubmit(modalForm);
      closeModal();
    } catch (error) {
      if (!(error instanceof UserError)) console.error(error);
      showToast(friendlyError(error), "error");
      submitButton.disabled = false;
    }
  });

  modalForm.querySelector("input, select, textarea")?.focus();
}

function closeModal() {
  closeActiveModal();
  closeActiveModal = () => {};
  modalRoot.innerHTML = "";
}

function showToast(message, type = "success") {
  const toast = document.createElement("div");
  toast.className = `toast ${type}`;
  toast.setAttribute("role", type === "error" ? "alert" : "status");
  toast.textContent = t(message);
  toastRoot.appendChild(toast);
  setTimeout(() => {
    toast.remove();
  }, type === "error" ? 6000 : 3200);
}
