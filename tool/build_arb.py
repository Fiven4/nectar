#!/usr/bin/env python3
"""Собирает lib/l10n/app_ru.arb и app_en.arb из tool/strings/*.py.

Каждый файл в tool/strings объявляет словарь STRINGS = {ключ: (русский, английский)}.
Плейсхолдеры пишутся как {name}; тип по умолчанию String, числовые задаются
суффиксом в имени: {count:int}, {amount:double}.
"""
import glob
import importlib.util
import json
import os
import re

ROOT = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(ROOT, "..", "lib", "l10n")


def load_strings():
    merged = {}
    for path in sorted(glob.glob(os.path.join(ROOT, "strings", "*.py"))):
        spec = importlib.util.spec_from_file_location(os.path.basename(path)[:-3], path)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        for key, value in module.STRINGS.items():
            if key in merged:
                raise SystemExit(f"duplicate key: {key}")
            merged[key] = value
    return merged


def convert(text):
    """Возвращает (текст ICU, список (имя, тип))."""
    placeholders = []

    def replace(match):
        name, _, kind = match.group(1).partition(":")
        placeholders.append((name, kind or "String"))
        return "{" + name + "}"

    return re.sub(r"\{([A-Za-z_]+(?::[a-z]+)?)\}", replace, text), placeholders


def build(index, locale):
    arb = {"@@locale": locale}
    for key, (ru, en) in load_strings().items():
        text, placeholders = convert((ru, en)[index])
        arb[key] = text
        if index == 0:
            meta = {}
            if placeholders:
                meta["placeholders"] = {name: {"type": kind} for name, kind in placeholders}
            arb["@" + key] = meta
    return arb


if __name__ == "__main__":
    strings = load_strings()
    for index, locale in enumerate(("ru", "en")):
        arb = build(index, locale)
        with open(os.path.join(OUT, f"app_{locale}.arb"), "w", encoding="utf-8") as handle:
            json.dump(arb, handle, ensure_ascii=False, indent=2)
            handle.write("\n")
    print(f"{len(strings)} strings written")
