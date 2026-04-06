#!/usr/bin/env python3

from __future__ import annotations

import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SUPPORTED_LOCALES = (
    "deDE",
    "enUS",
    "esES",
    "esMX",
    "frFR",
    "itIT",
    "koKR",
    "ptBR",
    "ruRU",
    "zhCN",
    "zhTW",
)
KEY_RE = re.compile(r'^L\["([^"]+)"\]\s*=', re.MULTILINE)
LEGACY_MARKER = "@localization"


def fail(errors: list[str], message: str) -> None:
    errors.append(message)


def validate_locale_dir(errors: list[str], addon_dir: str, require_sorted: bool = False) -> None:
    locale_dir = ROOT / addon_dir / "Locales"
    expected_files = {f"{locale}.lua" for locale in SUPPORTED_LOCALES}
    actual_files = {path.name for path in locale_dir.glob("*.lua")}

    missing = sorted(expected_files - actual_files)
    extra = sorted(actual_files - expected_files)

    if missing:
        fail(errors, f"{locale_dir.relative_to(ROOT)} is missing locale files: {', '.join(missing)}")
    if extra:
        fail(errors, f"{locale_dir.relative_to(ROOT)} has unexpected locale files: {', '.join(extra)}")

    baseline_keys: list[str] | None = None
    baseline_name: str | None = None

    for locale in SUPPORTED_LOCALES:
        file_path = locale_dir / f"{locale}.lua"
        if not file_path.exists():
            continue

        content = file_path.read_text(encoding="utf-8")
        if LEGACY_MARKER in content:
            fail(errors, f"{file_path.relative_to(ROOT)} still contains the legacy packager localization marker")

        keys = KEY_RE.findall(content)
        if require_sorted and keys != sorted(keys):
            fail(errors, f"{file_path.relative_to(ROOT)} keys are not alphabetically sorted")

        if baseline_keys is None:
            baseline_keys = keys
            baseline_name = file_path.name
            continue

        if keys != baseline_keys:
            fail(
                errors,
                f"{file_path.relative_to(ROOT)} keys do not match {baseline_name} in {locale_dir.relative_to(ROOT)}",
            )


def validate_module_locale_dirs(errors: list[str]) -> None:
    modules_dir = ROOT / "EnhanceQoL" / "Modules"
    locale_dirs = sorted(path.relative_to(ROOT) for path in modules_dir.rglob("Locales") if path.is_dir())
    if locale_dirs:
        fail(
            errors,
            "Module locale directories are not allowed under EnhanceQoL/Modules: "
            + ", ".join(str(path) for path in locale_dirs),
        )


def main() -> int:
    errors: list[str] = []

    validate_locale_dir(errors, "EnhanceQoL")
    validate_locale_dir(errors, "EnhanceQoLSharedMedia", require_sorted=True)
    validate_module_locale_dirs(errors)

    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1

    print("Locale validation passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
