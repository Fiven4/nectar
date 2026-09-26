#!/usr/bin/env python3
"""Генерирует web/catalog-translations.js из lib/data/catalog_translations.dart,
чтобы английские названия каталога хранились в одном месте (в Dart-файле)."""
import json
import os
import re

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
source = open(os.path.join(ROOT, "lib", "data", "catalog_translations.dart"), encoding="utf-8").read()


def block(name):
    match = re.search(rf"const Map<String, CatalogTranslation> {name} = \{{(.*?)\n\}};", source, re.S)
    entries = {}
    for item in re.finditer(r"'([a-z0-9-]+)': CatalogTranslation\((.*?)\),\n", match.group(1) + "\n", re.S):
        parts = re.findall(r"'((?:[^'\\]|\\.)*)'|\"((?:[^\"\\]|\\.)*)\"", item.group(2))
        values = [(a or b).replace("\\'", "'") for a, b in parts]
        entries[item.group(1)] = {
            "name": values[0],
            "description": values[1],
            "composition": values[2] if len(values) > 2 else "",
        }
    return entries


output = (
    "// Файл создается скриптом tool/sync_web_translations.py — не редактируйте вручную.\n"
    f"export const categoryTranslations = {json.dumps(block('categoryTranslations'), ensure_ascii=False, indent=2)};\n\n"
    f"export const productTranslations = {json.dumps(block('productTranslations'), ensure_ascii=False, indent=2)};\n"
)
open(os.path.join(ROOT, "web", "catalog-translations.js"), "w", encoding="utf-8").write(output)
print("ok")
