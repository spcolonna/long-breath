# Tipografías

Las tres son libres (SIL Open Font License 1.1) y salen del repositorio `google/fonts`.
Van recortadas a los caracteres que usa el juego, para que pesen poco (~860 KB en total).

| Familia en el código | Fuente | Uso | Archivos |
|---|---|---|---|
| `Fonts.body` = `Alegreya` | Alegreya (Juan Pablo del Peral, Huerta Tipográfica) | todo el texto | `assets/fonts/Alegreya-{400,600,700,800}.ttf`, `Alegreya-Italic.ttf` |
| `Fonts.display` = `Cormorant` | Cormorant Garamond (Christian Thalmann) | títulos (≥ 20 pt) | `assets/fonts/CormorantGaramond-{600,700}.ttf` |
| `Fonts.brush` = `MaShanZheng` | Ma Shan Zheng | hanzi; es el respaldo global, así que cualquier carácter chino sale a pincel | `assets/fonts/MaShanZheng-subset.ttf` |

## Regenerar (si se agregan hanzi o hace falta otro peso)
1. Bajar las variables de `github.com/google/fonts/tree/main/ofl/{alegreya,cormorantgaramond,mashanzheng}`.
2. `fonttools varLib.instancer <var>.ttf wght=<peso>` para cada peso estático (Flutter no mapea `FontWeight` al eje `wght`).
3. Latín: `pyftsubset --unicodes="U+0020-007E,U+00A0-00FF,U+0152-0153,U+2010-2027,U+2030-203A,U+20AC,U+2190-2193,U+2212,U+00B7,U+2022,U+221E,U+00D7" --layout-features='*'`.
4. Hanzi: juntar los caracteres de `lib/`, `assets/` y `tool/` (rango U+4E00–U+9FFF y signos CJK) y `pyftsubset --text-file=<archivo>`.
   Si un hanzi nuevo no está en el recorte, sale con la fuente del sistema: volver a recortar.
