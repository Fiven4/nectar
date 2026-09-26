// Чистые функции веб-панели: экранирование HTML и проверка данных форм.
// Модуль не зависит от DOM и Firebase, поэтому проверяется юнит-тестами
// (tool/web-test). Все тексты ошибок русские: перевод берется из i18n.js.

const HTML_ESCAPES = { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" };

/** Экранирует значение для вставки в HTML-текст и в атрибуты. */
export function esc(value) {
  return String(value ?? "").replace(/[&<>"']/g, (char) => HTML_ESCAPES[char]);
}

export const LIMITS = {
  name: 100,
  productName: 255,
  description: 2000,
  categoryDescription: 500,
  address: 300,
  maxStock: 9999,
  maxPrice: 1_000_000,
  maxNutrition: 10_000,
  minPasswordLength: 6,
  maxPasswordLength: 128,
};

export function validateText(value, label, { required = false, max = LIMITS.name } = {}) {
  const text = String(value ?? "").trim();
  if (!text) return required ? `Поле «${label}» обязательно.` : null;
  if (text.length > max) return `Поле «${label}» не должно превышать ${max} символов.`;
  return null;
}

export function validatePhone(value, { required = true } = {}) {
  const text = String(value ?? "").trim();
  if (!text) return required ? "Введите телефон." : null;
  const digits = text.replace(/\D/g, "");
  if (!/^\+?[\d\s\-()]+$/.test(text) || digits.length < 10 || digits.length > 15) {
    return "Телефон: от 10 до 15 цифр, допустимы +, пробелы, скобки и дефис.";
  }
  return null;
}

export function validateEmail(value, { required = false } = {}) {
  const text = String(value ?? "").trim();
  if (!text) return required ? "Введите email." : null;
  if (text.length > 100 || !/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(text)) {
    return "Некорректный email.";
  }
  return null;
}

export function validateTaxId(value) {
  const text = String(value ?? "").trim();
  if (!text) return "Введите ИНН.";
  if (!/^\d{10}(\d{2})?$/.test(text)) return "ИНН должен содержать 10 или 12 цифр.";
  return null;
}

export function validatePromoCode(value) {
  const code = String(value ?? "").trim().toUpperCase();
  if (!code) return "Введите код промокода.";
  if (code.length > 30) return "Код промокода не должен превышать 30 символов.";
  if (!/^[A-Z0-9]+$/.test(code)) return "Код промокода: только латинские буквы и цифры.";
  return null;
}

export function validateDiscount(value) {
  const number = Number(value);
  if (String(value ?? "").trim() === "" || !Number.isInteger(number) || number < 1 || number > 99) {
    return "Скидка должна быть целым числом от 1 до 99.";
  }
  return null;
}

export function validateUrl(value, { required = false } = {}) {
  const text = String(value ?? "").trim();
  if (!text) return required ? "Введите ссылку." : null;
  try {
    const url = new URL(text);
    if (!["http:", "https:"].includes(url.protocol)) throw new Error("protocol");
  } catch {
    return "Ссылка на изображение должна начинаться с http:// или https://.";
  }
  if (text.length > 2000) return "Ссылка слишком длинная.";
  return null;
}

/** Разбирает значение <input type="date"> как локальную дату; возвращает null для мусора. */
export function parseDateInput(value) {
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(String(value ?? "").trim());
  if (!match) return null;
  const [, year, month, day] = match.map(Number);
  const date = new Date(year, month - 1, day);
  if (date.getFullYear() !== year || date.getMonth() !== month - 1 || date.getDate() !== day) return null;
  return date;
}

/** Конец выбранного дня по местному времени: промокод действует весь этот день. */
export function endOfDay(value) {
  const date = parseDateInput(value);
  if (!date) return null;
  date.setHours(23, 59, 59, 0);
  return date;
}

/** Значение для <input type="date"> из даты Firestore ({seconds}) или Date, по местному времени. */
export function toDateInputValue(value) {
  const date = value?.seconds ? new Date(value.seconds * 1000) : value instanceof Date ? value : null;
  if (!date || Number.isNaN(date.getTime())) return "";
  const pad = (number) => String(number).padStart(2, "0");
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`;
}

function validateNumber(value, label, { min = 0, max, integer = false, required = false } = {}) {
  const text = String(value ?? "").trim().replace(",", ".");
  if (text === "") return required ? `Поле «${label}» обязательно.` : null;
  const number = Number(text);
  if (!Number.isFinite(number)) return `Поле «${label}» должно быть числом.`;
  if (integer && !Number.isInteger(number)) return `Поле «${label}» должно быть целым числом.`;
  if (number < min || (max !== undefined && number > max)) {
    return max === undefined
      ? `Поле «${label}» не может быть меньше ${min}.`
      : `Поле «${label}» должно быть от ${min} до ${max}.`;
  }
  return null;
}

/** Проверка формы товара; возвращает текст первой ошибки или null. */
export function validateProductForm(values) {
  const price = Number(String(values.price ?? "").trim().replace(",", "."));
  if (String(values.price ?? "").trim() === "" || !Number.isFinite(price) || price <= 0) {
    return "Цена должна быть больше нуля.";
  }
  if (price > LIMITS.maxPrice) return `Цена не может превышать ${LIMITS.maxPrice}.`;

  return (
    validateText(values.name, "Название", { required: true, max: LIMITS.productName }) ||
    validateNumber(values.stockQuantity, "Количество", { min: 0, max: LIMITS.maxStock, integer: true, required: true }) ||
    validateText(values.qty, "Единица", { required: true, max: 50 }) ||
    (values.categoryId ? null : "Выберите категорию товара.") ||
    (values.manufacturerId ? null : "Выберите производителя товара.") ||
    validateUrl(values.imageUrl) ||
    validateText(values.country, "Страна происхождения", { max: LIMITS.name }) ||
    validateText(values.composition, "Состав", { max: LIMITS.description }) ||
    validateText(values.description, "Описание", { max: LIMITS.description }) ||
    validateText(values.nameEn, "Название (English)", { max: LIMITS.productName }) ||
    validateText(values.compositionEn, "Состав (English)", { max: LIMITS.description }) ||
    validateText(values.descriptionEn, "Описание (English)", { max: LIMITS.description }) ||
    (String(values.expiryDate ?? "").trim() && !parseDateInput(values.expiryDate) ? "Некорректный срок годности." : null) ||
    validateNumber(values.calories, "Калорийность", { max: LIMITS.maxNutrition }) ||
    validateNumber(values.proteins, "Белки", { max: LIMITS.maxNutrition }) ||
    validateNumber(values.fats, "Жиры", { max: LIMITS.maxNutrition }) ||
    validateNumber(values.carbs, "Углеводы", { max: LIMITS.maxNutrition })
  );
}

/**
 * Проверка формы справочника (categories, manufacturers, suppliers, promoCodes).
 * `today` передается для тестов.
 */
export function validateEntityForm(section, values, { today = new Date() } = {}) {
  switch (section) {
    case "categories":
      return (
        validateText(values.name, "Название", { required: true }) ||
        validateText(values.nameEn, "Название (English)") ||
        validateText(values.description, "Описание", { max: LIMITS.categoryDescription })
      );
    case "manufacturers":
      return (
        validateText(values.name, "Название", { required: true }) ||
        validateText(values.country, "Страна", { required: true }) ||
        validatePhone(values.contactPhone)
      );
    case "suppliers":
      return (
        validateText(values.name, "Название", { required: true }) ||
        validateTaxId(values.taxId) ||
        validateText(values.address, "Адрес", { required: true, max: LIMITS.address }) ||
        validatePhone(values.contactPhone) ||
        validateEmail(values.email)
      );
    case "promoCodes": {
      const error = validatePromoCode(values.code) || validateDiscount(values.discountPercent);
      if (error) return error;
      const expiresAt = endOfDay(values.expiresAt);
      if (!expiresAt) return "Укажите корректный срок действия.";
      if (expiresAt < today) return "Срок действия промокода уже истек.";
      return null;
    }
    default:
      return null;
  }
}

export function validateNewPassword(newPassword, currentPassword, confirmation) {
  if (newPassword.length < LIMITS.minPasswordLength || !/[A-Za-zА-Яа-яЁё]/.test(newPassword) || !/\d/.test(newPassword)) {
    return "Новый пароль: минимум 6 символов, буквы и цифры.";
  }
  if (newPassword.length > LIMITS.maxPasswordLength) return "Пароль не должен превышать 128 символов.";
  if (/\s/.test(newPassword)) return "Пароль не должен содержать пробелы.";
  if (newPassword !== confirmation) return "Пароли не совпадают.";
  if (newPassword === currentPassword) return "Новый пароль совпадает с текущим.";
  return null;
}

const FINISHED_STATUSES = ["delivered", "cancelled"];
const COURIER_STATUSES = ["assigned", "delivering", "delivered"];

export function isFinishedStatus(statusId) {
  return FINISHED_STATUSES.includes(statusId);
}

/** Проверка смены статуса заказа; возвращает текст ошибки или null. */
export function validateOrderChange(order, { statusId, courierId }) {
  if (isFinishedStatus(order.statusId) && (statusId !== order.statusId || (courierId || null) !== (order.courierId || null))) {
    return "Завершенный или отмененный заказ изменить нельзя.";
  }
  if (COURIER_STATUSES.includes(statusId) && !courierId) {
    return "Для этого статуса назначьте курьера.";
  }
  return null;
}

/** Сколько единиц каждого товара вернуть на склад при отмене заказа. */
export function stockRestorations(order) {
  const totals = new Map();
  (Array.isArray(order.items) ? order.items : []).forEach((item) => {
    const quantity = Math.trunc(Number(item?.quantity));
    if (!item?.id || !Number.isFinite(quantity) || quantity <= 0) return;
    totals.set(item.id, (totals.get(item.id) || 0) + quantity);
  });
  return [...totals].map(([id, quantity]) => ({ id, quantity }));
}

/** Переводит ошибку Firebase в понятное сообщение (без технических деталей). */
export function friendlyError(error) {
  const code = error?.code || "";
  if (code === "permission-denied" || code === "auth/insufficient-permission") {
    return "Недостаточно прав для этого действия.";
  }
  if (["unavailable", "auth/network-request-failed", "deadline-exceeded"].includes(code)) {
    return "Нет соединения с сервером. Проверьте интернет и повторите.";
  }
  if (code === "auth/too-many-requests") return "Слишком много попыток. Попробуйте позже.";
  if (code === "auth/requires-recent-login") return "Войдите заново и повторите действие.";
  if (code === "auth/weak-password") return "Пароль слишком простой.";
  if (code === "not-found") return "Запись не найдена: возможно, ее уже удалили. Обновите данные.";
  return error?.userMessage || "Не удалось выполнить действие. Повторите попытку.";
}

/** Ошибка с заранее подготовленным для пользователя текстом. */
export class UserError extends Error {
  constructor(message) {
    super(message);
    this.userMessage = message;
  }
}

/** Значения для дашборда: выручка без отмененных заказов, месяцы по порядку. */
export function computeDashboard({ users, products, orders, catalogLabel = (item) => item.name }) {
  const active = orders.filter((order) => order.statusId !== "cancelled");
  const monthlySales = {};
  active.forEach((order) => {
    if (!order.createdAt?.seconds) return;
    const date = new Date(order.createdAt.seconds * 1000);
    const key = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}`;
    monthlySales[key] = (monthlySales[key] || 0) + (Number(order.totalAmount) || 0);
  });

  const popularity = {};
  active.forEach((order) => {
    (order.items || []).forEach((item) => {
      const product = products.find((candidate) => candidate.id === item.id);
      const label = (product && catalogLabel(product)) || item.name || "—";
      popularity[label] = (popularity[label] || 0) + (Number(item.quantity) || 0);
    });
  });

  return {
    buyersCount: users.filter((user) => ["buyer", "customer"].includes(user.role)).length,
    lowStockCount: products.filter((product) => !product.isDeleted && Number(product.stockQuantity || 0) <= 5).length,
    activeOrdersCount: orders.filter((order) => !isFinishedStatus(order.statusId)).length,
    totalSales: active.reduce((sum, order) => sum + (Number(order.totalAmount) || 0), 0),
    monthlySales: Object.entries(monthlySales).sort(([left], [right]) => left.localeCompare(right)),
    topProducts: Object.entries(popularity)
      .sort((left, right) => right[1] - left[1])
      .slice(0, 5),
  };
}
