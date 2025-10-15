#!/usr/bin/env python3
from pathlib import Path
import re, json

repo = Path(__file__).resolve().parents[1]
lib = repo / "lib"

dart_files = [
    p for p in lib.rglob("*.dart")
    if "generated" not in p.parts and not (lib/"l10n").samefile(p.parent)  # ignore lib/generated et lib/l10n
]

# 1) Clés appelées comme: AppLocalizations.of(context)!.myKey
re_of_getter = re.compile(r"AppLocalizations\.of\([^)]*\)!\.(\w+)")
# 2) Alias: final loc = AppLocalizations.of(context)!; puis loc.myKey
re_alias_decl = re.compile(r"\b([a-zA-Z_]\w*)\s*=\s*AppLocalizations\.of\([^)]*\)!\s*;")

keys = set()

for p in dart_files:
    s = p.read_text(encoding="utf-8", errors="ignore")
    # getters directs
    keys.update(re_of_getter.findall(s))
    # alias -> loc.xxx
    for alias in set(re_alias_decl.findall(s)):
        keys.update(re.findall(rf"\b{alias}\.(\w+)", s))

def humanize(k: str) -> str:
    # "settingsPage_ok" -> "Settings Page Ok"
    parts = re.findall(r"[A-Z]?[a-z]+|[A-Z]+(?![a-z])|\d+", k)
    label = " ".join(parts).strip()
    return label or k

arb_dir = lib / "l10n"
for lang in ("en", "fr"):
    arb = arb_dir / f"app_{lang}.arb"
    data = {}
    if arb.exists():
        try:
            data = json.loads(arb.read_text(encoding="utf-8"))
        except Exception:
            print(f"!! {arb} is not valid JSON/ARB")
            raise
    added = 0
    for k in sorted(keys):
        if k.startswith("@@"):  # ignore meta
            continue
        if k not in data:
            value = humanize(k)
            data[k] = value
            data[f"@{k}"] = {"description": "auto-added from code scan"}
            added += 1
    # Conserve @@locale si déjà présent, sinon n'ajoute rien de plus
    arb.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"{lang}: added {added} keys")
print(f"total unique keys found: {len(keys)}")
