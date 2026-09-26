/// Стартовый каталог магазина: категории, производители и товары.
/// Все документы имеют фиксированные id, поэтому повторное заполнение базы
/// обновляет их, а не создает дубликаты.
class CatalogCategory {
  const CatalogCategory(this.id, this.name, this.description, this.emoji);

  final String id;
  final String name;
  final String description;
  final String emoji;

  String get imageUrl => catalogImageUrl(emoji);
}

class CatalogManufacturer {
  const CatalogManufacturer(this.id, this.name, this.country, this.contactPhone);

  final String id;
  final String name;
  final String country;
  final String contactPhone;
}

class CatalogProduct {
  const CatalogProduct(
    this.id,
    this.categoryId,
    this.name,
    this.qty,
    this.price,
    this.stock,
    this.emoji,
    this.description, {
    this.composition = '',
    this.country = 'Россия',
    this.manufacturerId = 'fresh-farm',
    this.calories = 0,
    this.proteins = 0,
    this.fats = 0,
    this.carbs = 0,
    this.shelfLifeDays = 7,
    this.popularity = 0,
  });

  final String id;
  final String categoryId;
  final String name;
  final String qty;
  final double price;
  final int stock;
  final String emoji;
  final String description;
  final String composition;
  final String country;
  final String manufacturerId;
  final double calories;
  final double proteins;
  final double fats;
  final double carbs;
  final int shelfLifeDays;
  final int popularity;

  String get imageUrl => catalogImageUrl(emoji);

  String get unit {
    final parts = qty.split(' ');
    return parts.length > 1 ? parts.last : 'шт';
  }
}

String catalogImageUrl(String emojiCodePoint) =>
    'https://fonts.gstatic.com/s/e/notoemoji/latest/$emojiCodePoint/512.png';

const List<CatalogCategory> catalogCategories = [
  CatalogCategory('fruits', 'Фрукты', 'Свежие фрукты и сезонные ягоды.', '1f34e'),
  CatalogCategory('vegetables', 'Овощи', 'Овощи, зелень и грибы для ежедневной готовки.', '1f955'),
  CatalogCategory('dairy', 'Молочные продукты', 'Молоко, сыр, яйца, творог и йогурты.', '1f95b'),
  CatalogCategory('meat', 'Мясо', 'Охлажденное мясо, птица и мясные деликатесы.', '1f969'),
  CatalogCategory('fish', 'Рыба и морепродукты', 'Свежая и охлажденная рыба, морепродукты.', '1f41f'),
  CatalogCategory('bakery', 'Хлеб и выпечка', 'Ежедневно свежий хлеб и выпечка.', '1f35e'),
  CatalogCategory('pantry', 'Бакалея', 'Крупы, макароны, масло, мед и специи.', '1f35a'),
  CatalogCategory('drinks', 'Напитки', 'Соки, вода, чай, кофе и лимонады.', '1f9c3'),
  CatalogCategory('sweets', 'Сладости и снеки', 'Шоколад, печенье, орехи и другие вкусности.', '1f36b'),
];

const List<CatalogManufacturer> catalogManufacturers = [
  CatalogManufacturer('fresh-farm', 'Fresh Farm', 'Россия', '+7 900 111-22-33'),
  CatalogManufacturer('green-valley', 'Green Valley', 'Беларусь', '+375 29 555-11-22'),
  CatalogManufacturer('milk-house', 'Milk House', 'Россия', '+7 900 333-44-55'),
  CatalogManufacturer('meat-master', 'Meat Master', 'Россия', '+7 900 222-33-44'),
  CatalogManufacturer('sea-catch', 'Sea Catch', 'Норвегия', '+47 22 33 44 55'),
  CatalogManufacturer('bake-house', 'Bake House', 'Россия', '+7 900 444-55-66'),
  CatalogManufacturer('grain-land', 'Grain Land', 'Россия', '+7 900 666-77-88'),
  CatalogManufacturer('juice-lab', 'Juice Lab', 'Россия', '+7 900 777-88-99'),
  CatalogManufacturer('sweet-time', 'Sweet Time', 'Россия', '+7 900 888-99-00'),
];

const List<CatalogProduct> catalogProducts = [
  // Фрукты
  CatalogProduct('apple-red', 'fruits', 'Красное яблоко', '1 кг', 120, 60, '1f34e',
      'Сочные хрустящие яблоки нового урожая.',
      composition: 'Яблоки свежие.', calories: 52, proteins: 0.3, fats: 0.2, carbs: 13.8, shelfLifeDays: 30, popularity: 95),
  CatalogProduct('banana', 'fruits', 'Бананы', '1 кг', 140, 80, '1f34c',
      'Спелые сладкие бананы, идеальный перекус.',
      composition: 'Бананы свежие.', country: 'Эквадор', calories: 89, proteins: 1.1, fats: 0.3, carbs: 22.8, shelfLifeDays: 7, popularity: 100),
  CatalogProduct('orange', 'fruits', 'Апельсины', '1 кг', 160, 55, '1f34a',
      'Сладкие апельсины с тонкой кожурой, много витамина C.',
      composition: 'Апельсины свежие.', country: 'Египет', calories: 47, proteins: 0.9, fats: 0.1, carbs: 11.8, shelfLifeDays: 21, popularity: 80),
  CatalogProduct('lemon', 'fruits', 'Лимоны', '500 г', 90, 40, '1f34b',
      'Ароматные лимоны для чая, выпечки и соусов.',
      composition: 'Лимоны свежие.', country: 'Турция', calories: 29, proteins: 1.1, fats: 0.3, carbs: 9.3, shelfLifeDays: 21, popularity: 60),
  CatalogProduct('grapes', 'fruits', 'Виноград без косточек', '500 г', 230, 30, '1f347',
      'Сладкий кишмиш без косточек.',
      composition: 'Виноград свежий.', country: 'Узбекистан', calories: 69, proteins: 0.7, fats: 0.2, carbs: 18.1, shelfLifeDays: 10, popularity: 55),
  CatalogProduct('strawberry', 'fruits', 'Клубника', '400 г', 320, 25, '1f353',
      'Ароматная спелая клубника.',
      composition: 'Клубника свежая.', country: 'Азербайджан', calories: 32, proteins: 0.7, fats: 0.3, carbs: 7.7, shelfLifeDays: 4, popularity: 70),
  CatalogProduct('watermelon', 'fruits', 'Арбуз', '1 кг', 75, 45, '1f349',
      'Сладкий сочный арбуз.',
      composition: 'Арбуз свежий.', calories: 30, proteins: 0.6, fats: 0.2, carbs: 7.6, shelfLifeDays: 14, popularity: 40),
  CatalogProduct('peach', 'fruits', 'Персики', '1 кг', 280, 35, '1f351',
      'Мягкие ароматные персики.',
      composition: 'Персики свежие.', country: 'Греция', calories: 39, proteins: 0.9, fats: 0.1, carbs: 9.5, shelfLifeDays: 7, popularity: 35),
  CatalogProduct('pear', 'fruits', 'Груши', '1 кг', 190, 40, '1f350',
      'Сочные груши сорта Конференция.',
      composition: 'Груши свежие.', country: 'Беларусь', calories: 57, proteins: 0.4, fats: 0.1, carbs: 15.2, shelfLifeDays: 20, manufacturerId: 'green-valley', popularity: 30),
  CatalogProduct('pineapple', 'fruits', 'Ананас', '1 шт', 280, 0, '1f34d',
      'Спелый сладкий ананас.',
      composition: 'Ананас свежий.', country: 'Коста-Рика', calories: 50, proteins: 0.5, fats: 0.1, carbs: 13.1, shelfLifeDays: 7, popularity: 45),
  CatalogProduct('kiwi', 'fruits', 'Киви', '500 г', 210, 50, '1f95d',
      'Кисло-сладкое киви, источник клетчатки.',
      composition: 'Киви свежее.', country: 'Италия', calories: 61, proteins: 1.1, fats: 0.5, carbs: 14.7, shelfLifeDays: 14, popularity: 38),
  CatalogProduct('mango', 'fruits', 'Манго', '1 шт', 250, 20, '1f96d',
      'Сладкое спелое манго.',
      composition: 'Манго свежее.', country: 'Индия', calories: 60, proteins: 0.8, fats: 0.4, carbs: 15, shelfLifeDays: 7, popularity: 42),
  CatalogProduct('cherry', 'fruits', 'Черешня', '500 г', 380, 3, '1f352',
      'Сладкая темная черешня. Осталось совсем немного.',
      composition: 'Черешня свежая.', country: 'Турция', calories: 63, proteins: 1.1, fats: 0.4, carbs: 16, shelfLifeDays: 5, popularity: 33),
  CatalogProduct('avocado', 'fruits', 'Авокадо', '1 шт', 150, 40, '1f951',
      'Спелое авокадо Хаас для салатов и тостов.',
      composition: 'Авокадо свежее.', country: 'Мексика', calories: 160, proteins: 2, fats: 14.7, carbs: 8.5, shelfLifeDays: 6, popularity: 65),

  // Овощи
  CatalogProduct('tomato', 'vegetables', 'Помидоры', '1 кг', 220, 50, '1f345',
      'Мясистые красные помидоры.',
      composition: 'Помидоры свежие.', calories: 20, proteins: 1.1, fats: 0.2, carbs: 3.7, shelfLifeDays: 7, popularity: 85),
  CatalogProduct('cucumber', 'vegetables', 'Огурцы', '1 кг', 170, 60, '1f952',
      'Хрустящие огурцы для салатов.',
      composition: 'Огурцы свежие.', calories: 15, proteins: 0.8, fats: 0.1, carbs: 2.8, shelfLifeDays: 8, popularity: 75),
  CatalogProduct('carrot', 'vegetables', 'Морковь', '1 кг', 60, 90, '1f955',
      'Сладкая сочная морковь.',
      composition: 'Морковь свежая.', calories: 41, proteins: 0.9, fats: 0.2, carbs: 9.6, shelfLifeDays: 30, popularity: 50),
  CatalogProduct('potato', 'vegetables', 'Картофель', '2 кг', 110, 120, '1f954',
      'Молодой картофель для варки и жарки.',
      composition: 'Картофель свежий.', calories: 77, proteins: 2, fats: 0.4, carbs: 16.3, shelfLifeDays: 45, popularity: 88),
  CatalogProduct('onion', 'vegetables', 'Лук репчатый', '1 кг', 50, 100, '1f9c5',
      'Классический репчатый лук.',
      composition: 'Лук репчатый.', calories: 40, proteins: 1.1, fats: 0.1, carbs: 9.3, shelfLifeDays: 60, popularity: 45),
  CatalogProduct('garlic', 'vegetables', 'Чеснок', '200 г', 70, 70, '1f9c4',
      'Ароматный острый чеснок.',
      composition: 'Чеснок свежий.', calories: 149, proteins: 6.4, fats: 0.5, carbs: 33, shelfLifeDays: 90, popularity: 30),
  CatalogProduct('broccoli', 'vegetables', 'Брокколи', '400 г', 180, 30, '1f966',
      'Свежая брокколи, полезный гарнир.',
      composition: 'Капуста брокколи.', calories: 34, proteins: 2.8, fats: 0.4, carbs: 6.6, shelfLifeDays: 7, popularity: 40),
  CatalogProduct('pepper', 'vegetables', 'Болгарский перец', '500 г', 250, 35, '1fad1',
      'Сладкий красный болгарский перец.',
      composition: 'Перец сладкий.', country: 'Турция', calories: 27, proteins: 1, fats: 0.3, carbs: 5.3, shelfLifeDays: 10, popularity: 55),
  CatalogProduct('corn', 'vegetables', 'Кукуруза', '2 шт', 120, 40, '1f33d',
      'Сладкая молодая кукуруза в початках.',
      composition: 'Кукуруза початки.', calories: 96, proteins: 3.4, fats: 1.5, carbs: 21, shelfLifeDays: 6, popularity: 28),
  CatalogProduct('eggplant', 'vegetables', 'Баклажаны', '500 г', 130, 30, '1f346',
      'Свежие баклажаны для рагу и запекания.',
      composition: 'Баклажаны свежие.', calories: 24, proteins: 1.2, fats: 0.1, carbs: 4.5, shelfLifeDays: 8, popularity: 25),
  CatalogProduct('lettuce', 'vegetables', 'Салат Айсберг', '1 шт', 110, 45, '1f96c',
      'Хрустящий салат Айсберг.',
      composition: 'Салат Айсберг.', manufacturerId: 'green-valley', country: 'Беларусь', calories: 14, proteins: 0.9, fats: 0.1, carbs: 1.8, shelfLifeDays: 5, popularity: 35),
  CatalogProduct('mushroom', 'vegetables', 'Шампиньоны', '400 г', 170, 25, '1f344',
      'Свежие шампиньоны.',
      composition: 'Шампиньоны свежие.', calories: 27, proteins: 4.3, fats: 1, carbs: 0.1, shelfLifeDays: 6, popularity: 32),

  // Молочные продукты
  CatalogProduct('milk-32', 'dairy', 'Молоко 3.2%', '1 л', 90, 80, '1f95b',
      'Пастеризованное коровье молоко.',
      composition: 'Молоко нормализованное.', manufacturerId: 'milk-house', calories: 60, proteins: 2.9, fats: 3.2, carbs: 4.7, shelfLifeDays: 10, popularity: 98),
  CatalogProduct('kefir', 'dairy', 'Кефир 2.5%', '900 мл', 85, 60, '1f95b',
      'Классический кефир.',
      composition: 'Молоко, кефирная закваска.', manufacturerId: 'milk-house', calories: 50, proteins: 3, fats: 2.5, carbs: 4, shelfLifeDays: 10, popularity: 50),
  CatalogProduct('cheese-cheddar', 'dairy', 'Сыр Чеддер', '200 г', 450, 40, '1f9c0',
      'Выдержанный сыр с насыщенным вкусом.',
      composition: 'Молоко, соль, закваска, фермент.', manufacturerId: 'milk-house', calories: 403, proteins: 25, fats: 33, carbs: 1.3, shelfLifeDays: 60, popularity: 70),
  CatalogProduct('cheese-russian', 'dairy', 'Сыр Российский', '300 г', 380, 45, '1f9c0',
      'Полутвердый сыр для бутербродов и запекания.',
      composition: 'Молоко, соль, закваска.', manufacturerId: 'milk-house', calories: 363, proteins: 23, fats: 30, carbs: 0.3, shelfLifeDays: 45, popularity: 52),
  CatalogProduct('eggs-10', 'dairy', 'Куриные яйца С1', '10 шт', 110, 100, '1f95a',
      'Столовые куриные яйца первой категории.',
      composition: 'Яйцо куриное.', calories: 157, proteins: 12.7, fats: 11.5, carbs: 0.7, shelfLifeDays: 25, popularity: 96),
  CatalogProduct('butter', 'dairy', 'Масло сливочное 82.5%', '180 г', 210, 50, '1f9c8',
      'Сладко-сливочное масло высшего сорта.',
      composition: 'Сливки пастеризованные.', manufacturerId: 'milk-house', calories: 748, proteins: 0.5, fats: 82.5, carbs: 0.8, shelfLifeDays: 60, popularity: 60),
  CatalogProduct('cottage-cheese', 'dairy', 'Творог 5%', '350 г', 130, 40, '1f963',
      'Нежный зернистый творог.',
      composition: 'Молоко, закваска.', manufacturerId: 'milk-house', calories: 121, proteins: 17, fats: 5, carbs: 1.8, shelfLifeDays: 7, popularity: 48),
  CatalogProduct('yogurt', 'dairy', 'Йогурт натуральный', '350 г', 75, 60, '1f963',
      'Густой йогурт без добавок.',
      composition: 'Молоко, закваска.', manufacturerId: 'milk-house', calories: 66, proteins: 5, fats: 3.2, carbs: 3.5, shelfLifeDays: 14, popularity: 44),

  // Мясо
  CatalogProduct('steak', 'meat', 'Мясной стейк Рибай', '400 г', 890, 20, '1f969',
      'Мраморная говядина для стейков.',
      composition: 'Говядина охлажденная.', manufacturerId: 'meat-master', calories: 291, proteins: 24, fats: 21, carbs: 0, shelfLifeDays: 5, popularity: 62),
  CatalogProduct('chicken-fillet', 'meat', 'Куриное филе', '1 кг', 420, 50, '1f357',
      'Охлажденное филе куриной грудки.',
      composition: 'Мясо цыпленка-бройлера.', manufacturerId: 'meat-master', calories: 113, proteins: 23.6, fats: 1.9, carbs: 0.4, shelfLifeDays: 5, popularity: 90),
  CatalogProduct('minced-beef', 'meat', 'Фарш говяжий', '500 г', 360, 35, '1f356',
      'Охлажденный говяжий фарш.',
      composition: 'Говядина.', manufacturerId: 'meat-master', calories: 254, proteins: 17.2, fats: 20, carbs: 0, shelfLifeDays: 4, popularity: 58),
  CatalogProduct('bacon', 'meat', 'Бекон нарезка', '150 г', 210, 40, '1f953',
      'Копченый бекон в нарезке.',
      composition: 'Свинина, соль, специи.', manufacturerId: 'meat-master', calories: 541, proteins: 12, fats: 55, carbs: 0, shelfLifeDays: 30, popularity: 36),
  CatalogProduct('sausage', 'meat', 'Сосиски молочные', '450 г', 240, 55, '1f32d',
      'Нежные сосиски из свинины и говядины.',
      composition: 'Свинина, говядина, молоко.', manufacturerId: 'meat-master', calories: 266, proteins: 11, fats: 24, carbs: 1.6, shelfLifeDays: 20, popularity: 47),
  CatalogProduct('turkey', 'meat', 'Индейка филе', '600 г', 520, 25, '1f983',
      'Диетическое филе индейки.',
      composition: 'Мясо индейки.', manufacturerId: 'meat-master', calories: 84, proteins: 19.2, fats: 0.7, carbs: 0, shelfLifeDays: 5, popularity: 41),

  // Рыба и морепродукты
  CatalogProduct('salmon', 'fish', 'Лосось охлажденный', '300 г', 690, 25, '1f41f',
      'Филе лосося на коже.',
      composition: 'Лосось атлантический.', country: 'Норвегия', manufacturerId: 'sea-catch', calories: 208, proteins: 20, fats: 13.6, carbs: 0, shelfLifeDays: 4, popularity: 68),
  CatalogProduct('trout', 'fish', 'Форель свежая', '400 г', 540, 20, '1f420',
      'Тушка радужной форели.',
      composition: 'Форель радужная.', country: 'Карелия', manufacturerId: 'sea-catch', calories: 148, proteins: 20.5, fats: 6.6, carbs: 0, shelfLifeDays: 4, popularity: 34),
  CatalogProduct('shrimp', 'fish', 'Креветки королевские', '500 г', 780, 30, '1f990',
      'Варено-мороженые креветки.',
      composition: 'Креветки, соль.', country: 'Эквадор', manufacturerId: 'sea-catch', calories: 87, proteins: 18, fats: 1.1, carbs: 0.2, shelfLifeDays: 180, popularity: 46),
  CatalogProduct('squid', 'fish', 'Кальмар тушка', '500 г', 350, 22, '1f991',
      'Очищенные тушки кальмара.',
      composition: 'Кальмар.', country: 'Вьетнам', manufacturerId: 'sea-catch', calories: 75, proteins: 18, fats: 0.3, carbs: 0, shelfLifeDays: 180, popularity: 22),
  CatalogProduct('tuna-can', 'fish', 'Тунец консервированный', '185 г', 190, 60, '1f96b',
      'Тунец в собственном соку.',
      composition: 'Тунец, соль, вода.', country: 'Таиланд', manufacturerId: 'sea-catch', calories: 96, proteins: 21, fats: 1, carbs: 0, shelfLifeDays: 720, popularity: 30),

  // Хлеб и выпечка
  CatalogProduct('bread', 'bakery', 'Хлеб пшеничный', '1 шт', 55, 70, '1f35e',
      'Свежий формовой хлеб.',
      composition: 'Мука, вода, дрожжи, соль.', manufacturerId: 'bake-house', calories: 242, proteins: 8, fats: 1.4, carbs: 49, shelfLifeDays: 4, popularity: 92),
  CatalogProduct('baguette', 'bakery', 'Багет французский', '1 шт', 65, 40, '1f956',
      'Хрустящий багет.',
      composition: 'Мука, вода, дрожжи, соль.', manufacturerId: 'bake-house', calories: 262, proteins: 8.9, fats: 1.5, carbs: 51, shelfLifeDays: 2, popularity: 54),
  CatalogProduct('croissant', 'bakery', 'Круассан сливочный', '1 шт', 85, 35, '1f950',
      'Слоеный круассан со сливочным маслом.',
      composition: 'Мука, масло, молоко, сахар.', manufacturerId: 'bake-house', calories: 406, proteins: 8.2, fats: 21, carbs: 45.8, shelfLifeDays: 3, popularity: 66),
  CatalogProduct('bagel', 'bakery', 'Бублик с маком', '4 шт', 95, 30, '1f96f',
      'Мягкие бублики с маком.',
      composition: 'Мука, вода, мак, соль.', manufacturerId: 'bake-house', calories: 250, proteins: 10, fats: 1.5, carbs: 50, shelfLifeDays: 5, popularity: 20),
  CatalogProduct('lavash', 'bakery', 'Лаваш тонкий', '3 шт', 70, 50, '1fad3',
      'Тонкий армянский лаваш.',
      composition: 'Мука, вода, соль.', manufacturerId: 'bake-house', calories: 236, proteins: 7.9, fats: 1, carbs: 49.6, shelfLifeDays: 15, popularity: 26),

  // Бакалея
  CatalogProduct('rice', 'pantry', 'Рис длиннозерный', '900 г', 130, 80, '1f35a',
      'Рассыпчатый рис для гарниров.',
      composition: 'Рис.', manufacturerId: 'grain-land', calories: 344, proteins: 6.7, fats: 0.7, carbs: 78.9, shelfLifeDays: 540, popularity: 72),
  CatalogProduct('pasta', 'pantry', 'Макароны спагетти', '450 г', 95, 90, '1f35d',
      'Спагетти из твердых сортов пшеницы.',
      composition: 'Мука из твердой пшеницы, вода.', country: 'Италия', manufacturerId: 'grain-land', calories: 344, proteins: 12, fats: 1.5, carbs: 71, shelfLifeDays: 720, popularity: 74),
  CatalogProduct('buckwheat', 'pantry', 'Гречка ядрица', '800 г', 140, 85, '1f33e',
      'Отборная гречневая крупа.',
      composition: 'Гречневая крупа.', manufacturerId: 'grain-land', calories: 313, proteins: 12.6, fats: 3.3, carbs: 62.1, shelfLifeDays: 540, popularity: 78),
  CatalogProduct('olive-oil', 'pantry', 'Оливковое масло Extra Virgin', '500 мл', 690, 30, '1fad2',
      'Нерафинированное масло холодного отжима.',
      composition: 'Масло оливковое.', country: 'Испания', manufacturerId: 'green-valley', calories: 884, proteins: 0, fats: 99.8, carbs: 0, shelfLifeDays: 540, popularity: 43),
  CatalogProduct('honey', 'pantry', 'Мед цветочный', '500 г', 480, 35, '1f36f',
      'Натуральный цветочный мед.',
      composition: 'Мед натуральный.', manufacturerId: 'grain-land', calories: 329, proteins: 0.8, fats: 0, carbs: 80.3, shelfLifeDays: 720, popularity: 39),
  CatalogProduct('salt', 'pantry', 'Соль морская', '500 г', 60, 100, '1f9c2',
      'Мелкая морская соль.',
      composition: 'Соль морская.', manufacturerId: 'grain-land', calories: 0, proteins: 0, fats: 0, carbs: 0, shelfLifeDays: 1500, popularity: 15),
  CatalogProduct('oatmeal', 'pantry', 'Овсяные хлопья', '500 г', 85, 70, '1f963',
      'Овсяные хлопья для каши и выпечки.',
      composition: 'Овес.', manufacturerId: 'grain-land', calories: 366, proteins: 11.9, fats: 7.2, carbs: 69.3, shelfLifeDays: 365, popularity: 49),

  // Напитки
  CatalogProduct('juice-orange', 'drinks', 'Апельсиновый сок', '1 л', 150, 60, '1f9c3',
      'Сок прямого отжима из апельсинов.',
      composition: 'Апельсиновый сок 100%.', manufacturerId: 'juice-lab', calories: 45, proteins: 0.7, fats: 0.2, carbs: 10.4, shelfLifeDays: 60, popularity: 82),
  CatalogProduct('juice-apple', 'drinks', 'Яблочный сок', '1 л', 130, 55, '1f9c3',
      'Осветленный яблочный сок.',
      composition: 'Яблочный сок 100%.', manufacturerId: 'juice-lab', calories: 46, proteins: 0.5, fats: 0.1, carbs: 10.7, shelfLifeDays: 60, popularity: 51),
  CatalogProduct('water', 'drinks', 'Вода питьевая негазированная', '1.5 л', 45, 150, '1f4a7',
      'Чистая питьевая вода.',
      composition: 'Вода питьевая.', manufacturerId: 'juice-lab', calories: 0, proteins: 0, fats: 0, carbs: 0, shelfLifeDays: 365, popularity: 85),
  CatalogProduct('tea', 'drinks', 'Чай черный', '100 г', 210, 45, '1f375',
      'Крупнолистовой черный чай.',
      composition: 'Чай черный.', country: 'Шри-Ланка', manufacturerId: 'juice-lab', calories: 1, proteins: 0, fats: 0, carbs: 0.3, shelfLifeDays: 720, popularity: 37),
  CatalogProduct('coffee', 'drinks', 'Кофе молотый', '250 г', 490, 30, '2615',
      'Свежеобжаренный молотый кофе арабика.',
      composition: 'Кофе арабика.', country: 'Бразилия', manufacturerId: 'juice-lab', calories: 200, proteins: 14, fats: 14, carbs: 4, shelfLifeDays: 365, popularity: 59),
  CatalogProduct('lemonade', 'drinks', 'Лимонад Цитрус', '1 л', 95, 65, '1f964',
      'Освежающий газированный лимонад.',
      composition: 'Вода, сахар, лимонная кислота, ароматизатор.', manufacturerId: 'juice-lab', calories: 42, proteins: 0, fats: 0, carbs: 10.5, shelfLifeDays: 180, popularity: 27),

  // Сладости и снеки
  CatalogProduct('chocolate', 'sweets', 'Молочный шоколад', '90 г', 110, 90, '1f36b',
      'Нежный молочный шоколад.',
      composition: 'Какао-масло, сахар, молоко сухое.', manufacturerId: 'sweet-time', calories: 535, proteins: 7.7, fats: 30, carbs: 56, shelfLifeDays: 365, popularity: 77),
  CatalogProduct('cookies', 'sweets', 'Овсяное печенье', '300 г', 120, 70, '1f36a',
      'Хрустящее печенье с овсяными хлопьями.',
      composition: 'Мука, овсяные хлопья, масло, сахар.', manufacturerId: 'sweet-time', calories: 437, proteins: 6.5, fats: 16, carbs: 68, shelfLifeDays: 180, popularity: 53),
  CatalogProduct('icecream', 'sweets', 'Мороженое пломбир', '450 г', 210, 40, '1f368',
      'Классический сливочный пломбир.',
      composition: 'Молоко, сливки, сахар.', manufacturerId: 'milk-house', calories: 232, proteins: 3.2, fats: 15, carbs: 20.8, shelfLifeDays: 365, popularity: 63),
  CatalogProduct('chips', 'sweets', 'Картофельные чипсы', '150 г', 130, 80, '1f35f',
      'Хрустящие чипсы с солью.',
      composition: 'Картофель, масло подсолнечное, соль.', manufacturerId: 'sweet-time', calories: 520, proteins: 6, fats: 33, carbs: 50, shelfLifeDays: 180, popularity: 31),
  CatalogProduct('candies', 'sweets', 'Конфеты ассорти', '300 г', 250, 50, '1f36c',
      'Ассорти шоколадных конфет.',
      composition: 'Сахар, какао, орехи, молоко.', manufacturerId: 'sweet-time', calories: 490, proteins: 5, fats: 25, carbs: 62, shelfLifeDays: 300, popularity: 24),
  CatalogProduct('peanuts', 'sweets', 'Арахис жареный', '200 г', 140, 60, '1f95c',
      'Жареный соленый арахис.',
      composition: 'Арахис, соль.', country: 'Аргентина', manufacturerId: 'sweet-time', calories: 626, proteins: 26, fats: 52, carbs: 13, shelfLifeDays: 240, popularity: 29),
];
