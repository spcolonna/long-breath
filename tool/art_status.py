"""Lista de imágenes que el juego busca contra lo que hay en assets/art.

Genera docs/arte/checklist.md. Se corre antes de pasar prompts y cada vez
que llega arte nuevo:

    python3 tool/art_status.py

Estados:
- propio:    el archivo existe con arte propio.
- recoloreo: existe, pero lo genera tool/recolor_enemies.py desde otro.
- falta:     no existe; el juego muestra el reemplazo indicado.
"""

import json
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ART = os.path.join(ROOT, "assets", "art")
OUT = os.path.join(ROOT, "docs", "arte", "checklist.md")


def read(path):
    with open(os.path.join(ROOT, path), encoding="utf-8") as f:
        return f.read()


def recolors():
    """{variante: base} según VARIANTS de tool/recolor_enemies.py."""
    src = read("tool/recolor_enemies.py")
    block = src[src.index("VARIANTS = {"):]
    return dict(re.findall(r'^\s+"(\w+)": \("(\w+)"', block, re.M))


def scene_files():
    """{escena: tramo} según _sceneFiles en combat_screen.dart."""
    src = read("lib/delivery/screens/combat_screen.dart")
    block = src[src.index("const _sceneFiles = {"):]
    block = block[: block.index("};")]
    return dict(re.findall(r"'(\w+)': '(\w+)'", block))


def prompted(rel):
    """True si prompts.md tiene un prompt para el archivo: por su ruta o, en
    los enemigos, por un título con su nombre (`### Nombre (`art`, ...`)."""
    docs = read("docs/arte/prompts.md")
    if rel.startswith("enemies/"):
        name = os.path.splitext(os.path.basename(rel))[0]
        return re.search(rf"^###.*\(`{name}`,(?!.*hecho)", docs, re.M) is not None
    return rel in docs or rel.replace("stages/", "") in docs


def main():
    balance = json.loads(read("assets/data/game_balance.json"))
    enemies = json.loads(read("assets/data/enemies.json"))
    enemies = enemies if isinstance(enemies, list) else enemies["enemies"]
    stages = balance["run"]["stages"]
    tramos = scene_files()
    variants = recolors()

    rows = []  # (sección, ruta, para qué, reemplazo)

    def add(section, rel, use, fallback):
        rows.append((section, rel, use, fallback))

    for s in stages:
        sid = s["id"]
        base = f"stages/{sid}/combat_bg.png"
        add(sid, base, "combate (fondo general)", "cielo dibujado")
        scenes = set(s.get("scenes", []))
        types = set()
        for floor in s.get("floors", []):
            types |= set(floor.get("types", {}))
            if floor.get("scene"):
                scenes.add(floor["scene"])
        for tramo in sorted({tramos[x] for x in scenes if x in tramos}):
            names = sorted(x for x in scenes if tramos.get(x) == tramo)
            add(sid, f"stages/{sid}/combat_bg_{tramo}.png",
                f"combate: {', '.join(names)}", base)
        add(sid, f"stages/{sid}/map_bg.png", "mapa y evento",
            "montaña dibujada" if sid == "qianyunshan"
            else "stages/qianyunshan/map_bg.png")
        for kind, f, use in (("fountain", "fountain_bg.png", "fuente"),
                             ("shrine", "shrine_bg.png", "santuario")):
            if kind not in types:
                continue
            add(sid, f"stages/{sid}/{f}", use,
                "papel" if sid == "qianyunshan" else f"stages/qianyunshan/{f}")

    add("ui", "stages/qianyunshan/school_wall.png", "registro y derrota", "papel")
    add("ui", "ui/stage_clear_bg.png", "etapa superada", "papel")
    add("ui", "stages/qianyunshan/map_node_stone.png",
        "textura de los sellos del mapa (opcional)", "disco con degradado")
    add("npc", "npc/master.png", "maestro", "vacío")
    add("npc", "npc/merchant.png", "mercader", "vacío")
    for p in ("novice", "tiger", "snake", "crane"):
        add("héroe", f"player/hero_{p}.png", f"héroe ({p})", "vacío")

    by_art = {}
    for e in enemies:
        by_art.setdefault(e.get("art", e["id"]), []).append(e)
    rank_order = {"boss": 0, "elite": 1, "common": 2}
    for art, es in sorted(by_art.items(),
                          key=lambda kv: (min(rank_order.get(e.get("rank"), 3)
                                              for e in kv[1]), kv[0])):
        who = ", ".join(f"{e['id']} ({e.get('rank', '?')})" for e in es)
        add("enemigos", f"enemies/{art}.png", who, "enemies/placeholder.png")

    counts = {"propio": 0, "recoloreo": 0, "falta": 0}
    lines = [
        "# Checklist de arte",
        "",
        "**Generado por `python3 tool/art_status.py`: no editar a mano.** "
        "Se vuelve a correr antes de pasar prompts y cada vez que llega arte.",
        "",
        "- ✅ propio: ya está, no se vuelve a pedir.",
        "- 🎨 recoloreo: existe, pero es otro enemigo teñido "
        "(`tool/recolor_enemies.py`). Arte propio lo reemplaza.",
        "- ❌ falta: el archivo no existe; se ve el reemplazo.",
        "",
    ]
    section = None
    for sec, rel, use, fallback in rows:
        if sec != section:
            section = sec
            lines += ["", f"## {sec}", "",
                      "| Estado | Archivo | Para qué | Si falta se ve | Prompt |",
                      "|---|---|---|---|---|"]
        name = os.path.splitext(os.path.basename(rel))[0]
        exists = os.path.exists(os.path.join(ART, rel))
        if not exists:
            state = "❌ falta"
            counts["falta"] += 1
        elif rel.startswith("enemies/") and name in variants:
            state = f"🎨 recoloreo de `{variants[name]}`"
            counts["recoloreo"] += 1
        else:
            state = "✅ propio"
            counts["propio"] += 1
        p = "—" if state == "✅ propio" else ("listo" if prompted(rel) else "no")
        lines.append(f"| {state} | `assets/art/{rel}` | {use} | {fallback} | {p} |")

    lines[4:4] = [
        f"Total: {len(rows)} · ✅ {counts['propio']} · "
        f"🎨 {counts['recoloreo']} · ❌ {counts['falta']}",
        "",
    ]
    with open(OUT, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    print(lines[4])


if __name__ == "__main__":
    main()
