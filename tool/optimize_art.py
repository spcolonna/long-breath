"""Pasa el arte de assets/art a WebP del tamaño en que se muestra.

Se corre cada vez que llega arte nuevo (los generadores entregan PNG):

    python3 tool/optimize_art.py

Convierte cada `.png` de assets/art en un `.webp` con el mismo nombre y borra
el PNG. Los originales quedan en el historial de git (`git log -- <ruta>`),
así que hay que commitear el PNG antes de correrlo si se quiere conservar.
Los fondos no se achican (ya vienen a la medida de la pantalla); los sprites
sí, hasta el alto que tienen en pantalla a 3x.
"""

import os
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ART = os.path.join(ROOT, "assets", "art")

# Lado mayor máximo, por carpeta o por archivo (None: sin achicar).
LIMITS = {
    "enemies": 1024,
    "npc": 1280,
    "player": 1280,
    "stages": None,
    "ui/stage_clear_bg.png": None,
    "ui/lotus_seed.png": 512,
    "ui/reward_chest.png": 768,
    "ui/lore_scroll.png": None,
    "ui/title_bg.png": None,
    "ui/event_bg.png": None,
    "ui/victory_bg.png": None,
    "ui/epilogue_bg.png": None,
    "vfx": 640,
    "stages/qianyunshan/map_node_stone.png": 256,
    "ui/logo.png": 512,
    "icons": 256,
    "cards": 768,
}
SPRITE_QUALITY = 85
BACKGROUND_QUALITY = 82


def limit(rel):
    if rel in LIMITS:
        return LIMITS[rel]
    return LIMITS.get(rel.split("/")[0], 1024)


def convert(rel):
    src = os.path.join(ART, rel)
    dst = os.path.splitext(src)[0] + ".webp"
    im = Image.open(src)
    im.load()
    alpha = im.mode in ("RGBA", "LA") or "transparency" in im.info
    im = im.convert("RGBA" if alpha else "RGB")
    side = limit(rel)
    if side and max(im.size) > side:
        im.thumbnail((side, side), Image.LANCZOS)
    quality = SPRITE_QUALITY if alpha else BACKGROUND_QUALITY
    im.save(dst, "WEBP", quality=quality, method=6)
    before, after = os.path.getsize(src), os.path.getsize(dst)
    os.remove(src)
    return before, after


def main():
    total = [0, 0]
    for folder, _, files in sorted(os.walk(ART)):
        for f in sorted(files):
            if not f.endswith(".png"):
                continue
            rel = os.path.relpath(os.path.join(folder, f), ART)
            before, after = convert(rel)
            total[0] += before
            total[1] += after
            print(f"{rel}: {before // 1024} KB → {after // 1024} KB")
    if total[0]:
        print(f"Total: {total[0] / 2**20:.1f} MB → {total[1] / 2**20:.1f} MB")
    else:
        print("No hay PNG nuevos en assets/art.")


if __name__ == "__main__":
    sys.exit(main())
