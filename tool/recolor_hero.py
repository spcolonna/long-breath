"""Genera las variantes del héroe (novicio y un estilo por camino) a partir de assets/art/player/hero.png.

Solo recolorea la tela bermellón (tono rojo muy saturado); piel, pelo, oro y
blanco quedan igual. Uso: python3 tool/recolor_hero.py
"""

from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "assets/art/player/hero.png"

# Tono destino (grados), ajuste de saturación y aclarado por estilo.
STYLES = {
    "novice": (34, 0.32, 0.12),  # tela sin teñir: todavía no eligió camino
    "tiger": None,  # el original ya es bermellón
    "snake": (272, 0.85, 0),  # violeta
    "crane": (218, 0.95, 0),  # cobalto
}


def rgb_to_hsv(rgb):
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    mx = rgb.max(-1)
    mn = rgb.min(-1)
    d = mx - mn
    h = np.zeros_like(mx)
    m = d > 1e-6
    rm = m & (mx == r)
    gm = m & (mx == g) & ~rm
    bm = m & ~rm & ~gm
    h[rm] = ((g - b)[rm] / d[rm]) % 6
    h[gm] = (b - r)[gm] / d[gm] + 2
    h[bm] = (r - g)[bm] / d[bm] + 4
    h = h * 60
    s = np.where(mx > 1e-6, d / np.maximum(mx, 1e-6), 0)
    return h, s, mx


def hsv_to_rgb(h, s, v):
    c = v * s
    hp = (h % 360) / 60
    x = c * (1 - np.abs(hp % 2 - 1))
    z = np.zeros_like(h)
    conds = [hp < 1, hp < 2, hp < 3, hp < 4, hp < 5, hp >= 5]
    rs = [c, x, z, z, x, c]
    gs = [x, c, c, x, z, z]
    bs = [z, z, x, c, c, x]
    r = np.select(conds, rs)
    g = np.select(conds, gs)
    b = np.select(conds, bs)
    mm = v - c
    return np.stack([r + mm, g + mm, b + mm], -1)


def smooth(x, a, b):
    t = np.clip((x - a) / (b - a), 0, 1)
    return t * t * (3 - 2 * t)


def main():
    im = Image.open(SRC).convert("RGBA")
    # En pantalla se ve a menos de 400 pt de alto: 1152 px alcanza.
    im = im.resize((768, 1152), Image.LANCZOS)
    arr = np.asarray(im).astype(np.float32) / 255
    rgb, alpha = arr[..., :3], arr[..., 3:]
    h, s, v = rgb_to_hsv(rgb)
    # Distancia angular al rojo (0°): la tela está entre -20° y 15°; la piel
    # (≈25°) y el oro (≈45°) quedan afuera.
    dist = np.minimum(np.abs(h), 360 - np.abs(h))
    signed = np.where(h > 180, h - 360, h)
    mask = (1 - smooth(dist, 12, 20)) * smooth(s, 0.35, 0.5) * smooth(v, 0.15, 0.3)
    for name, cfg in STYLES.items():
        out = ROOT / f"assets/art/player/hero_{name}.png"
        if cfg is None:
            im.save(out, optimize=True)
            continue
        hue, sat, lift = cfg
        nh = hue + signed * 0.6
        nv = v + (1 - v) * lift
        nrgb = hsv_to_rgb(nh, np.clip(s * sat, 0, 1), nv)
        mixed = rgb * (1 - mask[..., None]) + nrgb * mask[..., None]
        res = np.concatenate([mixed, alpha], -1)
        Image.fromarray((res * 255).round().astype(np.uint8), "RGBA").save(out, optimize=True)
        print("ok", out.name)


if __name__ == "__main__":
    main()
