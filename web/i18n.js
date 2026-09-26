// Локализация веб-панели. Исходный язык интерфейса — русский, второй язык — английский.
// Русские тексты в разметке остаются как есть: при выбранном английском языке
// готовый DOM переводится по словарю ниже. Динамические сообщения (уведомления,
// ошибки) проходят через t().

const STORAGE_KEY = "nectar-admin-language";

const en = {
  // Общие
  "Nectar Admin": "Nectar Admin",
  "Панель управления магазином": "Store control panel",
  "Вход доступен только ролям «Администратор» и «Менеджер».": "Sign-in is available only to the “Administrator” and “Manager” roles.",
  "Email": "Email",
  "Пароль": "Password",
  "Введите пароль": "Enter your password",
  "Войти": "Sign in",
  "Выйти": "Sign out",
  "Обновить": "Refresh",
  "Сменить пароль": "Change password",
  "Store Control Center": "Store Control Center",
  "Все изменения сохраняются прямо в Cloud Firestore.": "All changes are saved directly to Cloud Firestore.",
  "Отмена": "Cancel",
  "Сохранить": "Save",
  "Добавить": "Add",
  "Редактировать": "Edit",
  "Удалить": "Delete",
  "Действия": "Actions",
  "Только просмотр": "View only",
  "Не выбран": "Not selected",
  "Не назначен": "Not assigned",

  // Разделы
  "Дашборд": "Dashboard",
  "Товары": "Products",
  "Категории": "Categories",
  "Производители": "Manufacturers",
  "Поставщики": "Suppliers",
  "Промокоды": "Promo codes",
  "Заказы": "Orders",
  "Пользователи": "Users",

  // Дашборд
  "Мониторинг клиентов, заказов и товаров магазина.": "Monitoring of customers, orders and products.",
  "Покупатели": "Customers",
  "Активные заказы": "Active orders",
  "Товары с низким остатком": "Low-stock products",
  "Общая выручка": "Total revenue",
  "Продажи по месяцам": "Sales by month",
  "ТОП-5 товаров": "Top 5 products",
  "Пока недостаточно данных.": "Not enough data yet.",

  // Товары
  "Создание, редактирование и мягкое удаление товаров.": "Create, edit and hide products (soft delete).",
  "Добавить товар": "Add product",
  "Редактировать товар": "Edit product",
  "Поиск по названию товара": "Search by product name",
  "Название": "Name",
  "Категория": "Category",
  "Цена": "Price",
  "Остаток": "Stock",
  "Статус": "Status",
  "Скрыт": "Hidden",
  "Активен": "Active",
  "Товары не найдены.": "No products found.",
  "Количество": "Quantity",
  "Единица": "Unit",
  "Производитель": "Manufacturer",
  "Поставщик": "Supplier",
  "Ссылка на изображение": "Image URL",
  "Страна происхождения": "Country of origin",
  "Срок годности до": "Best before",
  "Калорийность, ккал / 100 г": "Calories, kcal / 100 g",
  "Белки, г": "Protein, g",
  "Жиры, г": "Fat, g",
  "Углеводы, г": "Carbs, g",
  "Состав": "Ingredients",
  "Описание": "Description",
  "Дозаполнить английские переводы каталога": "Fill in missing English catalog translations",
  "Переводы уже загружены.": "Translations are already loaded.",
  "Название (English)": "Name (English)",
  "Состав (English)": "Ingredients (English)",
  "Описание (English)": "Description (English)",

  // Справочники
  "Страна": "Country",
  "Телефон": "Phone",
  "ИНН": "Tax ID",
  "Адрес": "Address",
  "Код": "Code",
  "Скидка, %": "Discount, %",
  "Срок действия": "Valid until",

  // Заказы
  "Смена статуса и назначение курьера.": "Change status and assign a courier.",
  "Номер": "Number",
  "Клиент": "Customer",
  "Сумма": "Amount",
  "Курьер": "Courier",
  "Новый": "New",
  "В сборке": "Being packed",
  "Передан курьеру": "Handed to courier",
  "В пути": "On the way",
  "Доставлен": "Delivered",
  "Отменен": "Cancelled",

  // Пользователи
  "Просмотр карточек пользователей и смена ролей.": "View users and change their roles.",
  "Имя": "Name",
  "Логин": "Login",
  "Роль": "Role",
  "Администратор": "Administrator",
  "Менеджер": "Manager",
  "Покупатель": "Customer",
  "Сохранить роль": "Save role",
  "Отключить": "Disable",
  "Пользователь": "User",

  // Смена пароля
  "Смена пароля": "Change password",
  "Текущий пароль": "Current password",
  "Новый пароль (минимум 6 символов, буквы и цифры)": "New password (at least 6 characters, letters and digits)",
  "Повторите новый пароль": "Repeat the new password",

  // Сообщения
  "Данные обновлены.": "Data refreshed.",
  "Недостаточно прав для входа в web-панель.": "You do not have permission to use the web panel.",
  "Вход доступен только администратору и менеджеру.": "Only administrators and managers can sign in.",
  "Не удалось выполнить вход. Проверьте email и пароль.": "Could not sign in. Check your email and password.",
  "Товар скрыт из каталога.": "Product hidden from the catalog.",
  "Запись удалена.": "Record deleted.",
  "Заказ обновлен.": "Order updated.",
  "Роль пользователя обновлена.": "User role updated.",
  "Пользователь отключен.": "User disabled.",
  "Изменения сохранены.": "Changes saved.",
  "Товар сохранен.": "Product saved.",
  "Выберите категорию товара.": "Select a product category.",
  "Цена должна быть больше нуля.": "The price must be greater than zero.",
  "Новый пароль: минимум 6 символов, буквы и цифры.": "New password: at least 6 characters, letters and digits.",
  "Пароли не совпадают.": "Passwords do not match.",
  "Новый пароль совпадает с текущим.": "The new password is the same as the current one.",
  "Неверный текущий пароль.": "The current password is incorrect.",
  "Пароль успешно изменен.": "Password changed successfully.",
  "Не удалось сохранить данные.": "Could not save the data.",

  // Проверки и сообщения панели
  "Восстановить": "Restore",
  "Это вы": "This is you",
  "Заказ завершен": "Order completed",
  "Заказов пока нет.": "No orders yet.",
  "Записей пока нет.": "No records yet.",
  "Пользователей нет.": "No users.",
  "Показывать отключенных": "Show disabled users",
  "Калорийность": "Calories",
  "Белки": "Protein",
  "Жиры": "Fat",
  "Углеводы": "Carbs",
  "Введите email и пароль.": "Enter your email and password.",
  "Учетная запись отключена. Обратитесь к администратору.": "The account is disabled. Contact an administrator.",
  "Введите email.": "Enter an email.",
  "Введите ИНН.": "Enter the tax ID.",
  "Введите код промокода.": "Enter the promo code.",
  "Введите ссылку.": "Enter a link.",
  "Введите телефон.": "Enter a phone number.",
  "Войдите заново и повторите действие.": "Sign in again and repeat the action.",
  "Выберите производителя товара.": "Select a product manufacturer.",
  "Для этого статуса назначьте курьера.": "Assign a courier for this status.",
  "Завершенный или отмененный заказ изменить нельзя.": "A completed or cancelled order cannot be changed.",
  "Заказ не найден. Обновите данные.": "Order not found. Refresh the data.",
  "Запись не найдена: возможно, ее уже удалили. Обновите данные.": "Record not found: it may have been deleted. Refresh the data.",
  "ИНН должен содержать 10 или 12 цифр.": "The tax ID must contain 10 or 12 digits.",
  "Изменений нет.": "No changes.",
  "Категория с таким названием уже существует.": "A category with this name already exists.",
  "Код промокода не должен превышать 30 символов.": "The promo code must not exceed 30 characters.",
  "Код промокода: только латинские буквы и цифры.": "Promo code: Latin letters and digits only.",
  "Курьер не найден или отключен. Обновите данные.": "Courier not found or disabled. Refresh the data.",
  "Не удалось выполнить действие. Повторите попытку.": "The action failed. Please try again.",
  "Недостаточно прав для этого действия.": "You do not have permission for this action.",
  "Некорректный email.": "Invalid email.",
  "Некорректный срок годности.": "Invalid best-before date.",
  "Нельзя изменить собственную роль.": "You cannot change your own role.",
  "Нельзя отключить последнего администратора.": "The last administrator cannot be disabled.",
  "Нельзя отключить собственную учетную запись.": "You cannot disable your own account.",
  "Нельзя снять роль с последнего администратора.": "The last administrator's role cannot be removed.",
  "Нельзя удалить категорию: к ней привязаны товары.": "Cannot delete the category: products are linked to it.",
  "Нельзя удалить поставщика: к нему привязаны товары.": "Cannot delete the supplier: products are linked to it.",
  "Нельзя удалить производителя: к нему привязаны товары.": "Cannot delete the manufacturer: products are linked to it.",
  "Нельзя удалить промокод: он используется в незавершенных заказах.": "Cannot delete the promo code: it is used in unfinished orders.",
  "Нет соединения с сервером. Проверьте интернет и повторите.": "No connection to the server. Check your internet and try again.",
  "Отключить пользователя? Он не сможет войти в приложение.": "Disable this user? They will not be able to sign in to the app.",
  "Отменить заказ? Товары вернутся на склад, статус нельзя будет изменить.": "Cancel the order? The items will return to stock and the status can no longer be changed.",
  "Пароль не должен превышать 128 символов.": "The password must not exceed 128 characters.",
  "Пароль не должен содержать пробелы.": "The password must not contain spaces.",
  "Пароль слишком простой.": "The password is too weak.",
  "Пользователь восстановлен.": "User restored.",
  "Пользователь не найден. Обновите данные.": "User not found. Refresh the data.",
  "Поставщик с таким названием уже существует.": "A supplier with this name already exists.",
  "Производитель с таким названием уже существует.": "A manufacturer with this name already exists.",
  "Промокод с таким кодом уже существует.": "A promo code with this code already exists.",
  "Скидка должна быть целым числом от 1 до 99.": "The discount must be a whole number from 1 to 99.",
  "Скрыть товар из каталога? Его можно будет восстановить.": "Hide the product from the catalog? It can be restored later.",
  "Слишком много попыток. Попробуйте позже.": "Too many attempts. Try again later.",
  "Срок действия промокода уже истек.": "The promo code has already expired.",
  "Ссылка на изображение должна начинаться с http:// или https://.": "The image link must start with http:// or https://.",
  "Ссылка слишком длинная.": "The link is too long.",
  "Телефон: от 10 до 15 цифр, допустимы +, пробелы, скобки и дефис.": "Phone: 10 to 15 digits; +, spaces, parentheses and hyphens are allowed.",
  "Товар снова доступен в каталоге.": "The product is available in the catalog again.",
  "У пользователя есть незавершенные заказы: отключение сейчас невозможно.": "The user has unfinished orders: cannot be disabled right now.",
  "У пользователя есть незавершенные заказы: смена роли сейчас невозможна.": "The user has unfinished orders: the role cannot be changed right now.",
  "Удалить запись? Это действие нельзя отменить.": "Delete the record? This cannot be undone.",
  "Укажите корректный срок действия.": "Enter a valid expiry date.",
};

const patterns = [
  [/^Обновлено записей: (\d+)$/, (count) => `Records updated: ${count}`],
  [/^Справочник коллекции (.+)\.$/, (title) => `Reference list: ${translate(title.charAt(0).toUpperCase() + title.slice(1)).toLowerCase()}.`],
  [/^Редактировать: (.+)$/, (title) => `Edit: ${translate(title)}`],
  [/^Добавить: (.+)$/, (title) => `Add: ${translate(title)}`],
  [/^Поле «(.+)» обязательно\.$/, (label) => `The “${translate(label)}” field is required.`],
  [/^Поле «(.+)» не должно превышать (\d+) символов\.$/, (label, max) => `The “${translate(label)}” field must not exceed ${max} characters.`],
  [/^Поле «(.+)» должно быть числом\.$/, (label) => `The “${translate(label)}” field must be a number.`],
  [/^Поле «(.+)» должно быть целым числом\.$/, (label) => `The “${translate(label)}” field must be a whole number.`],
  [/^Поле «(.+)» не может быть меньше (.+)\.$/, (label, min) => `The “${translate(label)}” field cannot be less than ${min}.`],
  [/^Поле «(.+)» должно быть от (.+) до (.+)\.$/, (label, min, max) => `The “${translate(label)}” field must be from ${min} to ${max}.`],
  [/^Цена не может превышать (\d+)\.$/, (max) => `The price cannot exceed ${max}.`],
];

let language = readStoredLanguage();

function readStoredLanguage() {
  try {
    return localStorage.getItem(STORAGE_KEY) === "en" ? "en" : "ru";
  } catch (error) {
    return "ru";
  }
}

export function getLanguage() {
  return language;
}

export function setLanguage(nextLanguage) {
  try {
    localStorage.setItem(STORAGE_KEY, nextLanguage);
  } catch (error) {
    // Язык просто не запомнится.
  }
  window.location.reload();
}

function translate(text) {
  if (language !== "en") return text;
  const trimmed = text.trim();
  if (!trimmed) return text;

  let translated = en[trimmed];
  if (translated === undefined) {
    for (const [pattern, build] of patterns) {
      const match = trimmed.match(pattern);
      if (match) {
        translated = build(...match.slice(1));
        break;
      }
    }
  }
  if (translated === undefined) return text;
  return text.replace(trimmed, translated);
}

export function t(text) {
  return translate(text);
}

const translatedAttributes = ["placeholder", "title", "aria-label"];

function translateNode(node) {
  if (node.nodeType === Node.TEXT_NODE) {
    const parent = node.parentElement;
    if (parent && ["SCRIPT", "STYLE", "TEXTAREA"].includes(parent.tagName)) return;
    const translated = translate(node.nodeValue);
    if (translated !== node.nodeValue) node.nodeValue = translated;
    return;
  }

  if (node.nodeType !== Node.ELEMENT_NODE) return;
  translatedAttributes.forEach((attribute) => {
    if (node.hasAttribute(attribute)) {
      const value = node.getAttribute(attribute);
      const translated = translate(value);
      if (translated !== value) node.setAttribute(attribute, translated);
    }
  });
  node.childNodes.forEach(translateNode);
}

function installLanguageSwitcher() {
  const wrapper = document.createElement("div");
  wrapper.className = "language-switch";
  wrapper.setAttribute("role", "group");
  wrapper.setAttribute("aria-label", language === "en" ? "Language" : "Язык");

  [["ru", "RU"], ["en", "EN"]].forEach(([code, label]) => {
    const button = document.createElement("button");
    button.type = "button";
    button.textContent = label;
    button.className = code === language ? "active" : "";
    button.setAttribute("aria-pressed", String(code === language));
    button.addEventListener("click", () => {
      if (code !== language) setLanguage(code);
    });
    wrapper.appendChild(button);
  });

  document.body.appendChild(wrapper);
}

export function initLocalization() {
  document.documentElement.lang = language;
  installLanguageSwitcher();
  if (language !== "en") return;

  document.title = translate(document.title);
  translateNode(document.body);
  new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
      if (mutation.type === "characterData") {
        translateNode(mutation.target);
      } else if (mutation.type === "attributes") {
        translateNode(mutation.target);
      } else {
        mutation.addedNodes.forEach(translateNode);
      }
    });
  }).observe(document.body, {
    subtree: true,
    childList: true,
    characterData: true,
    attributes: true,
    attributeFilter: translatedAttributes,
  });
}
