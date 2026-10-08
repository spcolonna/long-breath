"""Genera las variantes de enemigos de las etapas 2 y 3 recoloreando los
sprites de la etapa 1 (assets/art/enemies/<base>.png → <variante>.png).

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
    # Etapa 2: Monasterio Colgado (bronce, azafrán, ceniza, hierro, jade, oro).
    "bat_bronze": ("bat", [("hue", 150, 215, 30, 1.5, -0.1)]),
    "golem_bronze": ("golem", [
        ("gray", 30, 0.5, -0.1),
        ("hue", 60, 150, 40, 0.9, -0.08),
        ("hue", 160, 210, 18, 1.0, 0.0),
    ]),
    "disciple_saffron": ("disciple", [("hue", 120, 200, 352, 0.85, -0.02)]),
    "salamander_ash": ("salamander", [("hue", 0, 50, 265, 0.18, -0.08)]),
    "monk_iron": ("monk", [("hue", 240, 310, 212, 0.3, -0.06)]),
    "lion_jade": ("lion", [
        ("gray", 160, 0.38, -0.06),
        ("hue", 60, 140, 160, 1.0, -0.06),
    ]),
    "monk_gold": ("monk", [("hue", 240, 310, 34, 1.35, 0.14)]),
    # Etapa 3: Cumbre del Dragón Dormido (nieve, escarcha, viento).
    "monkey_snow": ("monkey", [
        ("hue", 25, 60, 40, 0.12, 0.18),
        ("hue", 340, 360, 208, 0.75, 0.0),
        ("hue", 0, 18, 208, 0.75, 0.0),
    ]),
    "golem_ice": ("golem", [
        ("gray", 205, 0.16, 0.06),
        ("hue", 60, 150, 200, 0.3, 0.12),
    ]),
    "disciple_wind": ("disciple", [("hue", 120, 200, 205, 0.9, 0.02)]),
    "bat_frost": ("bat", [("hue", 150, 215, 212, 0.45, 0.1)]),
    "fan_wind": ("fan", [("hue", 250, 360, 188, 0.85, 0.0)]),
    "lion_snow": ("lion", [
        ("gray", 210, 0.14, 0.1),
        ("hue", 60, 140, 205, 0.25, 0.15),
    ]),
    "dragon_azure": ("dragon", [("hue", 150, 210, 228, 1.0, -0.05)]),
    # Reflejo del Dragón (élite de la etapa 2): se queda con este recoloreo
    # cuando el Dragón Dormido tenga arte propio.
    "dragon_reflection": ("dragon", [("hue", 150, 210, 228, 1.0, -0.05)]),
}


def in_range(h, a, b):
    return (h >= a) & (h <= b) if a <= b else (h >= a) | (h <= b)


def recolor(base, rules):
    img = Image.open(DIR / f"{base}.png").convert("RGBA")
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
        img.save(DIR / f"{name}.png", optimize=True)
        print(name)
