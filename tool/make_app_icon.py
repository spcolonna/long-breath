#!/usr/bin/env python3
"""Genera el ícono de la app (iOS) y la imagen de la pantalla de carga.

Uso:
  python3 tool/make_app_icon.py icon <fuente.png>   # ícono, todos los tamaños
  python3 tool/make_app_icon.py launch              # pantalla de carga desde el logo

El ícono no puede tener transparencia: se aplana sobre el papel (#F6EEDC).
La fuente ideal es cuadrada, de 1024×1024 o más.
"""

import json
import os
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ICONSET = os.path.join(ROOT, 'ios/Runner/Assets.xcassets/AppIcon.appiconset')
LAUNCH = os.path.join(ROOT, 'ios/Runner/Assets.xcassets/LaunchImage.imageset')
LOGO = os.path.join(ROOT, 'assets/art/ui/logo.webp')
PAPER = (0xF6, 0xEE, 0xDC)
LAUNCH_PT = 170  # lado del logo en puntos en la pantalla de carga


def _square(img):
    w, h = img.size
    s = min(w, h)
    return img.crop(((w - s) // 2, (h - s) // 2, (w + s) // 2, (h + s) // 2))


def make_icon(src):
    img = _square(Image.open(src).convert('RGBA'))
    flat = Image.new('RGB', img.size, PAPER)
    flat.paste(img, mask=img.split()[3])
    with open(os.path.join(ICONSET, 'Contents.json')) as f:
        images = json.load(f)['images']
    for i in images:
        pt = float(i['size'].split('x')[0])
        px = round(pt * int(i['scale'][0]))
        out = flat.resize((px, px), Image.LANCZOS)
        out.save(os.path.join(ICONSET, i['filename']), optimize=True)
        print(f"{i['filename']}: {px}px")


def make_launch():
    logo = Image.open(LOGO).convert('RGBA')
    for scale, name in ((1, 'LaunchImage.png'), (2, 'LaunchImage@2x.png'),
                        (3, 'LaunchImage@3x.png')):
        px = min(LAUNCH_PT * scale, logo.width)
        logo.resize((px, px), Image.LANCZOS).save(
            os.path.join(LAUNCH, name), optimize=True)
        print(f'{name}: {px}px')


if __name__ == '__main__':
    if len(sys.argv) >= 3 and sys.argv[1] == 'icon':
        make_icon(sys.argv[2])
    elif len(sys.argv) >= 2 and sys.argv[1] == 'launch':
        make_launch()
    else:
        print(__doc__)
        sys.exit(1)
