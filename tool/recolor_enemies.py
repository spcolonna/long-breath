"""Genera las variantes de enemigos de las etapas 2 y 3 recoloreando los
sprites de la etapa 1 (assets/art/enemies/<base>.webp → <variante>.webp).

Cada variante es una lista de reglas que se aplican en orden sobre los
píxeles opacos:
  ("hue", desde, hasta, tono, sat, luz): los píxeles saturados con tono entre
      desde..hasta (grados) pasan al tono dado; sat multiplica la
      saturación y luz suma brillo (0..1).
  ("gray", tono, sat, luz): tiñe los píxeles casi grises (piedra, blancos).
Uso: python3 tool/recolor_enemies.py  (se puede volver a correr: pisa las
variantes; los originales no se tocan).
"""

from pathlib import Path

import numpy as np
from PIL import Image

from recolor_hero import hsv_to_rgb, rgb_to_hsv, smooth

ROOT = Path(__file__).resolve().parent.parent
DIR = ROOT / "assets/art/enemies"

VARIANTS = {
    # Vacío: todos los enemigos tienen arte propio (lion_celadon y
    # dragon_reflection lo recibieron el 13/11). Si vuelve a hacer falta un
    # recoloreo, se agrega acá: "variante": ("base", [reglas]).
}


def in_range(h, a, b):
    return (h >= a) & (h <= b) if a <= b else (h >= a) | (h <= b)


def recolor(base, rules):
    img = Image.open(DIR / f"{base}.webp").convert("RGBA")
    arr = np.asarray(img).astype(np.float64) / 255
    rgb, alpha = arr[..., :3], arr[..., 3:]
    h, s, v = rgb_to_hsv(rgb)
    for rule in rules:
        if rule[0] == "hue":
            _, a, b, to, sat, light = rule
            w = in_range(h, a, b) * smooth(s, 0.12, 0.3)
            h = np.where(w > 0.5, to, h)
            s = s * (1 - w) + np.clip(s * sat, 0, 1) * w
            v = np.clip(v + light * w, 0, 1)
        else:
            _, to, sat, light = rule
            w = 1 - smooth(s, 0.16, 0.36)
            h = np.where(w > 0.5, to, h)
            s = s * (1 - w) + sat * w * np.clip(v, 0.2, 1)
            v = np.clip(v + light * w, 0, 1)
    out = np.concatenate([hsv_to_rgb(h, s, v), alpha], -1)
    return Image.fromarray((np.clip(out, 0, 1) * 255).astype(np.uint8), "RGBA")


if __name__ == "__main__":
    for name, (base, rules) in VARIANTS.items():
        img = recolor(base, rules)
        # Las variantes salen a 1024 px de alto: alcanza para la pantalla y
        # pesan la mitad que los originales.
        img.thumbnail((1024, 1024), Image.LANCZOS)
        img.save(DIR / f"{name}.webp", quality=85, method=6)
        print(name)
