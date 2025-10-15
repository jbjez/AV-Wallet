#!/usr/bin/env python3
from pathlib import Path
import re, json

repo = Path(__file__).resolve().parents[1]
lib = repo / "lib"
arb_dir = lib / "l10n"

dart_files = [p for p in lib.rglob("*.dart") if "generated" not in p.parts]

# 1) AppLocalizations.of(context)!.key
re_direct_getter = re.compile(r"AppLocalizations\.of\([^)]*\)!\.(\w+)\b(?!\s*\()")
# 2) alias loc: final loc = AppLocalizations.of(context)!;  loc.key / loc.func(...)
re_alias_decl = re.compile(r"\b([a-zA-Z_]\w*)\s*=\s*AppLocalizations\.of\([^)]*\)!\s*;")
def re_alias_getter(alias): return re.compile(rf"\b{alias}\.(\w+)\b(?!\s*\()")
def re_alias_call(alias):   return re.compile(rf"\b{alias}\.(\w+)\s*\(([^)]*)\)")
# 3) direct function call: AppLocalizations.of(context)!.func(...)
re_direct_call = re.compile(r"AppLocalizations\.of\([^)]*\)!\.(\w+)\s*\(([^)]*)\)")

# Collecte: {key: max_argc}
keys = {}
def add_key(name, argc=0):
    if not name or name.startswith("@@"): return
    keys[name] = max(keys.get(name, 0), argc)

for p in dart_files:
    s = p.read_text(encoding="utf-8", errors="ignore")
    for k in re_direct_getter.findall(s):
        add_key(k, 0)
    for m in re_direct_call.finditer(s):
        k, args = m.group(1), m.group(2)
        argc = 0 if args.strip()=="" else len([a for a in args.split(",") if a.strip()!=""])
        add_key(k, argc)
    for alias in set(re_alias_decl.findall(s)):
        for k in re_alias_getter(alias).findall(s):
            add_key(k, 0)
        for m in re_alias_call(alias).finditer(s):
            k, args = m.group(1), m.group(2)
            argc = 0 if args.strip()=="" else len([a for a in args.split(",") if a.strip()!=""])
            add_key(k, argc)

def humanize(k: str) -> str:
    # "settingsPage_ok" -> "Settings Page Ok"
    parts = re.findall(r"[A-Z]?[a-z]+|[A-Z]+(?![a-z])|\d+", k)
    return " ".join(parts).strip() or k

locales = [
    ("en", "English"),
    ("fr", "Français"),
    ("es", "Español"),
    ("de", "Deutsch"),
    ("it", "Italiano"),
]

def ensure_arb(locale):
    path = arb_dir / f"app_{locale}.arb"
    if not path.exists():
        path.write_text('{\n  "@@locale": "'+locale+'"\n}\n', encoding="utf-8")
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except Exception as e:
        raise SystemExit(f"Invalid JSON in {path}: {e}")
    return path, data

added_counts = {}

for locale, _ in locales:
    path, data = ensure_arb(locale)
    added = 0
    for k, argc in sorted(keys.items()):
        if k in data:  # ne pas écraser une traduction existante
            # si la clé existante est "simple" mais on a besoin de placeholders, ajoute la section @
            if argc > 0 and f"@{k}" not in data:
                data[f"@{k}"] = {"description": "auto-added placeholders", "placeholders": { f"arg{i+1}": {} for i in range(argc) }}
            continue
        if argc == 0:
            data[k] = humanize(k)
            data[f"@{k}"] = {"description": "auto-added from code scan"}
        else:
            # construit un message avec placeholders {arg1}, {arg2}, …
            args = ", ".join([f"{{arg{i+1}}}" for i in range(argc)])
            data[k] = f"{humanize(k)}: {args}"
            data[f"@{k}"] = {"description": "auto-added with placeholders",
                             "placeholders": { f"arg{i+1}": {} for i in range(argc) }}
        added += 1
    (arb_dir / f"app_{locale}.arb").write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    added_counts[locale] = added

print("TOTAL KEYS FOUND:", len(keys))
for locale, _ in locales:
    print(f"{locale}: added {added_counts[locale]} keys")