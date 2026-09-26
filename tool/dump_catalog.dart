// Выгружает стартовый каталог (lib/data) в JSON для демо-данных эмулятора:
//   dart run tool/dump_catalog.dart > tool/rules-test/catalog.json
import 'dart:convert';
import 'dart:io';

import 'package:nectar/data/catalog_translations.dart';
import 'package:nectar/data/product_catalog.dart';

void main() {
  final output = {
    'categories': [
      for (final category in catalogCategories)
        {
          'id': category.id,
          'name': category.name,
          'nameEn': categoryTranslations[category.id]?.name ?? '',
          'description': category.description,
          'imageUrl': category.imageUrl,
        },
    ],
    'manufacturers': [
      for (final manufacturer in catalogManufacturers)
        {
          'id': manufacturer.id,
          'name': manufacturer.name,
          'country': manufacturer.country,
          'contactPhone': manufacturer.contactPhone,
        },
    ],
    'products': [
      for (final product in catalogProducts)
        {
          'id': product.id,
          'name': product.name,
          'nameEn': productTranslations[product.id]?.name ?? '',
          'description': product.description,
          'descriptionEn': productTranslations[product.id]?.description ?? '',
          'composition': product.composition,
          'country': product.country,
          'price': product.price,
          'qty': product.qty,
          'stockQuantity': product.stock,
          'imageUrl': product.imageUrl,
          'categoryId': product.categoryId,
          'categoryName': catalogCategories.firstWhere((c) => c.id == product.categoryId).name,
          'categoryNameEn': categoryTranslations[product.categoryId]?.name ?? '',
          'manufacturerId': product.manufacturerId,
          'manufacturerName': catalogManufacturers.firstWhere((m) => m.id == product.manufacturerId).name,
          'calories': product.calories,
          'proteins': product.proteins,
          'fats': product.fats,
          'carbs': product.carbs,
          'popularity': product.popularity,
        },
    ],
  };
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(output));
}
