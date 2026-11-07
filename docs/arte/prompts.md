# Prompts de arte

Prompts para **ChatGPT** (generador de imágenes), en inglés porque así sigue mejor las instrucciones. Son la
identidad visual de Long Breath. Antes de pasar un prompt, mirá [`relevamiento.md`](relevamiento.md) y
[`checklist.md`](checklist.md) (la genera `python3 tool/art_status.py`): ahí está qué existe, qué es recoloreo y qué falta.

**Regla general:** nada de fondos negros, marrones ni "versión dark". Es una pintura china vista a plena luz: papel
claro, color saturado y mucho aire.

**Cómo usarlos:**
- **Una imagen por mensaje.** Cada bloque gris es un prompt suelto: copialo entero y pegalo en ChatGPT (mejor en una
  conversación nueva). Arranca a generar sin preguntar. Los pedidos de a 10 en un solo mensaje no funcionan: ChatGPT
  repite la misma imagen o las junta en una sola.
- Cada prompt repite toda su descripción (formato, estilo, qué no incluir). Así sale consistente aunque la corras en
  otra conversación o en otra cuenta.
- Guardá cada PNG con el nombre que figura en el título del prompt (más `.png`), en la carpeta que se indica, y pedile
  a Claude que las integre.
- Al integrar: se corre `python3 tool/optimize_art.py` (lo pasa a `.webp` del tamaño en que se muestra y borra el
  PNG) y `python3 tool/art_status.py`; después se marca ✅ acá y se saca el prompt de «Para generar ahora». **El PNG
  nunca se commitea:** en git solo queda el `.webp`, para que el repositorio no pese. Los prompts nuevos van en su
  sección y, sueltos, en «Para generar ahora».

## Resumen: qué está y qué falta

- **Falta:** nada.
- **Recoloreos por diseño (2):** el Reflejo del Dragón (`dragon_reflection`) y el León de Celadón (`lion_celadon`), élites de la etapa 2, usan al dragón y al león teñidos. Se ven bien en el juego; arte propio sería un extra, no algo que falte.
- **Está todo lo demás:** enemigos de las 3 etapas (incluidos qilin y Músico del Guqin), héroe, NPC, fondos y mapas
  de las 3 etapas, sellos del mapa, efectos, rollo, pantallas, logo, 9 íconos, 5 marcos de carta y
  las 3 armas y 64 ilustraciones de cartas (Tigre, Serpiente, Grulla, las 6 de cadena y las 12 de arma). El detalle está en «Estado», más abajo.

## Paleta de referencia

| Rol | Hex | Uso en el juego |
|---|---|---|
| Papel | `#F6EEDC` | fondo principal |
| Jade claro | `#E3F1EC` | fondo alterno, degradados |
| Bermellón | `#E8453C` | Puño, Vida enemiga, jefe |
| Jade | `#1FA38A` | Técnica, Vida propia, enemigos comunes |
| Cobalto | `#3E7BE0` | Defensa, Guardia, Aliento, fuente |
| Oro | `#E59A12` | Patada, formas, recompensas |
| Violeta | `#9B5DE5` | Palma, Estructura, élite |
| Tinta | `#2B2A33` | texto |

---

# Para generar ahora

Nada: las 165 imágenes están integradas (los 2 recoloreos son por diseño). Los prompts nuevos van acá, sueltos, uno por imagen.

### Ícono: Vida (`icons/heart`) ✅ integrado

**Destino:** `assets/art/icons/heart.png`, cuadrado 256×256, fondo transparente. Se usa para: corazón de la Vida (barras, curas, fuente, eventos). **No es recoloreo.**

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The game shrinks it to 256×256 and shows it at about 32 pixels.

Game UI icon, transparent background, bold simple shape, readable at 32 pixels: a plump vermilion (#E8453C) heart with a small jade (#1FA38A) leaf and a soft white highlight, drawn like a lucky charm with a tiny gold knot at the top.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Ícono: Carga (`icons/charge`) ✅ integrado

**Destino:** `assets/art/icons/charge.png`, cuadrado 256×256, fondo transparente. Se usa para: el rival carga o acumula fuerza. **No es recoloreo.**

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The game shrinks it to 256×256 and shows it at about 32 pixels.

Game UI icon, transparent background, bold simple shape, readable at 32 pixels: a bold gold (#E59A12) lightning bolt wrapped by a short vermilion (#E8453C) ribbon of energy, slightly tilted, with two small spark dots.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Ícono: Jade robado (`icons/stolen`) ✅ integrado

**Destino:** `assets/art/icons/stolen.png`, cuadrado 256×256, fondo transparente. Se usa para: el mono te roba jade. **No es recoloreo.**

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The game shrinks it to 256×256 and shows it at about 32 pixels.

Game UI icon, transparent background, bold simple shape, readable at 32 pixels: a round jade (#1FA38A) coin with a square hole, tied to a small cobalt (#3E7BE0) cloth pouch, a little gold sparkle on the coin edge.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Ícono de la app (para TestFlight / App Store) ✅ integrado (fuente: `docs/arte/app_icon.webp`)

**Destino:** guardar el PNG donde quieras y correr `python3 tool/make_app_icon.py icon <archivo.png>`,
que lo aplana sobre papel y genera los 19 tamaños de `ios/Runner/Assets.xcassets/AppIcon.appiconset/`.
Cuadrado, 1024×1024, **sin transparencia y sin texto**. iOS redondea las esquinas solo: no dibujar bordes redondeados.

```
Square mobile game app icon, 1024x1024, full-bleed, no text, no letters, no rounded corners, no border.
Warm cream rice-paper background (#F6EEDC) with a subtle paper texture.
Centered: a bold vermilion (#E8453C) ink-brush ensō circle, slightly open at the top right,
framing a single jade-green (#1FA38A) mountain peak with three soft layered ridges and a thin wisp of
white cloud crossing it. From the summit rises one elegant cobalt-blue (#3E7BE0) breath swirl
that curls upward like a long exhale and ends in a small gold (#E59A12) spark.
Chinese ink-wash meets clean flat game art, bright and serene, nothing dark, high contrast,
large simple shapes that stay readable at 60 pixels, generous margin around the circle.
```


---

# Estado

⬜ = falta · ✅ = generado e integrado · 🎨 = existe, pero es otro enemigo recoloreado (el arte propio lo reemplaza) ·
⏸ = tiene prompt, sin uso. Los prompts de lo que ya está quedan abajo por si hay que regenerar algo.

## Enemigos — `assets/art/enemies/`

| Qué | Archivos | Cantidad | Estado |
|---|---|---|---|
| Etapa 1, con élites, jefe, muñeco y placeholder | `placeholder`, `dummy`, `bat`, `salamander`, `golem`, `disciple`, `monk`, `dragon`, `lion`, `fan`, `monkey`, `bandit`, `lingzhi` | 13 | ✅ |
| Etapas 2 y 3, arte propio | `bat_bronze`, `golem_bronze`, `disciple_saffron`, `salamander_ash`, `monk_iron`, `lion_jade`, `monk_gold`, `bell_keeper`, `fan_wind`, `lion_snow`, `dragon_azure`, `dragon_dream` | 12 | ✅ |
| Concepto nuevo | `opera_mask`, `pixiu`, `paper_crane`, `flying_sword`, `wooden_ox`, `nine_tail_fox`, `shadow_puppet` | 7 | ✅ |
| Etapa 3, arte propio | `qilin`, `disciple_wind`, `golem_ice`, `monkey_snow`, `bat_frost`, `guqin_player`, `monk_amber`, `monk_slate` | 8 | ✅ |
| Reserva de recoloreos | `dragon_reflection`, `lion_celadon` | 2 | 🎨 por diseño, sin prompt |

## Héroe y NPC

| Qué | Archivos | Estado |
|---|---|---|
| Héroe | `player/hero.png` → `hero_novice`, `hero_tiger`, `hero_snake`, `hero_crane` (recoloreo por diseño, `tool/recolor_hero.py`) | ✅ |
| Retratos | `npc/master`, `npc/merchant` | ✅ |

## Fondos y mapas — `assets/art/stages/`

| Etapa | Archivos | Estado |
|---|---|---|
| 1 `qianyunshan/` | `combat_bg` y sus 4 tramos, `map_bg`, `fountain_bg`, `shrine_bg`, `school_wall` | ✅ |
| 1 `qianyunshan/` | `map_node_stone` (sellos del mapa) | ✅ |
| 1 `qianyunshan/` | `combat_bg_fuente` (la fuente no tiene combate) | ⏸ |
| 2 `xuankongsi/` | `combat_bg` y sus 3 tramos, `map_bg`, `fountain_bg` | ✅ |
| 3 `wolongding/` | `combat_bg` y sus 4 tramos, `map_bg`, `fountain_bg` | ✅ |

## UI y efectos

| Qué | Archivos | Estado |
|---|---|---|
| Etapa superada, semilla de loto, cofre | `ui/stage_clear_bg`, `ui/lotus_seed`, `ui/reward_chest` | ✅ |
| Efectos | `vfx/hit_ink`, `vfx/guard_shield`, `vfx/break_shatter`, `vfx/qi_swirl`, `vfx/lotus_petals` | ✅ |
| Rollo de lectura | `ui/lore_scroll` | ✅ |
| Pantallas | `ui/title_bg`, `ui/event_bg`, `ui/victory_bg`, `ui/epilogue_bg` | ✅ |
| Logo | `ui/logo` (menú principal) | ✅ |

## Cartas e íconos

| Qué | Carpeta | Cantidad | Estado |
|---|---|---|---|
| Íconos | `assets/art/icons/` | 6 | ✅ |
| Marcos por tipo | `assets/art/cards/` | 5 | ✅ |
| Ilustraciones de cartas | `assets/art/cards/` | 64 | ✅ 64 (con las 12 de arma) |
| Armas | `assets/art/weapons/` | 3 | ✅ |

---

# Prompts individuales

## 0. Prioridad MVP (lo que el juego ya sabe usar)

Son las dos imágenes que el código ya busca. Si no existen, se usa una silueta dibujada y un degradado.

### Enemigo genérico ✅

**Destino:** `assets/art/enemies/placeholder.png`, vertical 2:3 (1024×1536) con fondo transparente.

Se usa para todos los enemigos hasta que cada uno tenga su imagen (`assets/art/enemies/<id>.png`). El juego le agrega un aura del color del rango (jade común, violeta élite, bermellón jefe), por eso la figura usa colores neutros.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer in a fighting stance, centered, transparent
background: a rival kung fu martial artist in a simple layered robe of soft jade and off-white
with a sash, hair tied up, calm but threatening expression, hands raised in guard, slight
low-angle heroic perspective, clean readable silhouette at small size, neutral colors that work
under a colored aura.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Fondo de arena de combate ✅

**Destino:** `assets/art/stages/qianyunshan/combat_bg.png`, vertical 6:7 (1200×1400). Ocupa la mitad superior de la pantalla y se recorta para cubrirla, así que lo importante va en el centro. El enemigo se para en el centro-derecha, a unos 3/4 de la altura; el héroe tapa la esquina inferior izquierda.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 6:7 aspect ratio (1200×1400), fully opaque (no transparency).

Mobile game battle background, vertical 6:7, no characters: a wide flat stone terrace on a
mountain ledge high above a sea of clouds. The terrace floor fills the lower third, a soft oval
of worn pale flagstones where two fighters will stand. A weathered vermilion wooden gate
(paifang) half visible at the left edge, a twisted pine and a few jade bamboo stalks at the
right edge. Behind, layered pastel mountain peaks fading into mist, a tiny temple on a far peak,
bright morning sky in pale blue fading to warm cream near the horizon. Center and lower center
empty and low-detail, soft focus in the distance, clear depth. No people, no animals, no
text.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
background (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

No hace falta video: el juego ya anima encima (héroe, enemigo, números). Si más adelante se quiere movimiento en el fondo, conviene separar las nubes en una capa PNG aparte y desplazarlas por código, que pesa mucho menos que un video en loop.

### Muñeco de madera (tutorial) ✅

**Destino:** `assets/art/enemies/dummy.png`, 2:3 y transparente. Ya integrado.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: a
traditional kung fu wooden training dummy (mu ren zhuang), a thick polished wooden trunk
with three wooden arms and one bent wooden leg sticking out, mounted on a low wooden frame,
warm honey-colored wood with darker grain, a faded red cloth sash tied around its "waist",
a few paper talismans with brush marks, slightly worn from years of practice, friendly and
iconic silhouette at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Héroe ✅

**Fuente:** `assets/art/player/hero.png`, 2:3 y transparente, de espaldas mirando hacia el enemigo. Ropa bermellón para que el recoloreo funcione. Después de cambiarla hay que correr `python3 tool/recolor_hero.py`, que genera `hero_novice.png` (lino crudo, antes del santuario), `hero_tiger.png`, `hero_snake.png` y `hero_crane.png`.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game player character, full body, three-quarter back view facing into the scene toward an
opponent, centered, transparent background: the hero, a kung fu disciple of the Sleeping Dragon
school, in a layered robe of vermilion and warm cream with gold trim and a gold sash, a small
red dragon emblem on the back, confident relaxed guard, breath visible as a thin golden swirl
around the hands.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

## 1. Pantalla de inicio

✅ Reemplazado por `ui/title_bg` (sección 9), que ya es el fondo del menú. No pedir este.

~~**Destino:** `assets/art/ui/home_bg.png`, vertical 9:19.5, con espacio libre en el centro para el logo.~~

```
Create ONE single image. Start immediately, without asking questions.

Create a tall PORTRAIT image with a 9:19.5 aspect ratio, fully opaque (no transparency).

Vertical mobile splash illustration: a young kung fu student in a flowing jade-and-white robe
standing on a floating rock at the foot of a colossal mountain wrapped in a thousand swirling
pastel clouds, dawn light in peach and gold, a faint golden dragon silhouette drawn by the clouds
themselves, wide empty sky area in the upper-middle for a logo.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
background (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

✅ **Logo:** `assets/art/ui/logo.png`, cuadrado y transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Logo emblem: the Chinese character 龙 painted in a single energetic vermilion brush stroke, with a
thin gold breath-like swirl wrapping around it, on transparent background, bold and readable at
small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

## 2. Etapa 1: Montaña de las Mil Nubes (千云山)

**Destino:** `assets/art/stages/qianyunshan/`

**El mapa ya se dibuja por código** (cielo que cambia con la altura, cordilleras en parallax, pinos, nubes, arco del santuario, estanque, pagoda, cumbre y dragón, sendero de escalones y sellos de piedra). Los dos assets de abajo son **opcionales**: si están, el código los suma sin tocar nada; si no, no pasa nada.

✅ Fondo del mapa (`map_bg.png`, opcional, **1080×4000**, vertical, se dibuja al 85% sobre las capas pintadas). Que no tenga sendero ni escalones propios (los pone el código) y que el centro quede despejado:

```
Create ONE single image. Start immediately, without asking questions.

Create a very tall PORTRAIT image (1080×4000), fully opaque (no transparency).

Tall vertical map background, 1080x4000 pixels (aspect ratio 27:100, very tall and narrow), of a green
mountain of a thousand clouds: mossy cliffs, small pagodas, pine trees, bamboo groves and thin
waterfalls rising through layers of fluffy pastel clouds, a stone memorial arch near the bottom, the
bottom in fresh morning jade tones gradually shifting to warm gold and pink near a misty summit at
the top, no visible path or stairs, lots of empty space along the middle for UI nodes.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
background (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, calm and luminous mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no characters, no text, no watermark.
```

✅ Textura de los sellos del mapa (`map_node_stone.png`, opcional, 512×512, PNG con transparencia; se recorta en círculo y se dibuja al 90% debajo del carácter tallado):

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Top-down view of a single round flat stone disc for a game map node, pale warm granite (#E2D3B6) with subtle mineral speckles and soft worn edges, light coming from the top left, centered, empty center (no carving, no symbol), no characters.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper cream tones (#F6EEDC) on the figure only, fully transparent background (real transparent PNG, no checkerboard, no paper behind the subject), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue (#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

Fondos de combate por tramo. Son opcionales y se toman solos, sin tocar código: si falta el del tramo, se usa `combat_bg.png`. La ladera es n1–n2, la bifurcación n3a/n3b, el templo n5 y la cumbre la pelea del jefe. La fuente no tiene combate: su fondo queda para cuando tenga pantalla propia.

**Formato:** la arena es casi cuadrada (la mitad de arriba de la pantalla; las cartas van abajo, sobre papel). Los fondos nuevos van **cuadrados 1:1** (1024×1024 o más), sin transparencia, con un suelo plano y despejado en el tercio inferior para que se paren los luchadores y el centro libre para el enemigo. Si llega uno vertical, se ve solo la franja del medio; `_variantFocus` en `combat_screen.dart` permite bajarla o subirla (el templo usa 0,45).

**Estado:** los 4 fondos de tramo (ladera, bifurcación, templo y cumbre) ya están en el juego.

#### Ladera (n1–n2) ✅

**Destino:** `assets/art/stages/qianyunshan/combat_bg_ladera.png`, cuadrado 1:1, sin transparencia.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), fully opaque (no transparency).

Mobile game combat background, square 1:1, no characters: a flat grassy clearing on a mountain slope, framed by a bamboo grove on the sides, soft morning mist and distant jade peaks behind, a few stone steps and a small vermilion lantern post at one edge, fresh jade and mint tones with touches of gold sunlight. Flat open ground across the lower third where two fighters stand, center open and uncluttered for a character. No people, no animals, no text.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
background (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Bifurcación (n3a / n3b) ✅

**Destino:** `assets/art/stages/qianyunshan/combat_bg_bifurcacion.png`, cuadrado 1:1, sin transparencia.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), fully opaque (no transparency).

Mobile game combat background, square 1:1, no characters: a wide flat rocky ledge where the mountain path splits in two, a weathered stone signpost at the fork, bright turquoise and cobalt quartz crystals growing from the cliffs on the sides, a softly glowing crack in the rock, pine trees and drifting clouds behind, turquoise, cobalt and jade tones in bright daylight. Flat open ground across the lower third where two fighters stand, center open and uncluttered for a character. No people, no animals, no text.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
background (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Fuente (n4) ⏸

**Destino:** `assets/art/stages/qianyunshan/combat_bg_fuente.png`, vertical 9:19.5, sin transparencia.

```
Create ONE single image. Start immediately, without asking questions.

Create a tall PORTRAIT image with a 9:19.5 aspect ratio, fully opaque (no transparency).

Mobile game combat background, vertical 9:19.5, no characters: serene spring pool under a blossoming tree, cobalt water, pink petals drifting. Upper third open and uncluttered for a character, lower half soft and low-contrast so cards remain readable. No people, no animals, no text.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
background (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Templo (n5) ✅

**Destino:** `assets/art/stages/qianyunshan/combat_bg_templo.png`, vertical 9:19.5, sin transparencia.

```
Create ONE single image. Start immediately, without asking questions.

Create a tall PORTRAIT image with a 9:19.5 aspect ratio, fully opaque (no transparency).

Mobile game combat background, vertical 9:19.5, no characters: open-air cliff temple with red pillars and hanging bronze bells, vermilion and gold tones. Upper third open and uncluttered for a character, lower half soft and low-contrast so cards remain readable. No people, no animals, no text.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
background (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Cumbre (n6) ✅

**Destino:** `assets/art/stages/qianyunshan/combat_bg_cumbre.png`, vertical 9:19.5, sin transparencia.

```
Create ONE single image. Start immediately, without asking questions.

Create a tall PORTRAIT image with a 9:19.5 aspect ratio, fully opaque (no transparency).

Mobile game combat background, vertical 9:19.5, no characters: wide flat stone summit platform with a few weathered carved railings and a small vermilion shrine gate at one side, high above an endless sea of fluffy white clouds, bright golden-hour sky in gold, coral and soft violet, faint swirling golden breath trails in the sky, distant mountain peaks poking through the clouds, epic and luminous final-battle feeling while staying bright and airy. Upper third open and uncluttered for a character, lower half soft and low-contrast so cards remain readable. No people, no animals, no text.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
background (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

## 3. Enemigos

**Destino:** `assets/art/enemies/<id>.png`, vertical 2:3 (1024×1536) con fondo transparente, figura completa y centrada, con los pies cerca del borde inferior (igual que el muñeco y el placeholder). El juego toma cada archivo solo, sin tocar código; mientras falte, usa `placeholder.png`.

El juego ya les agrega un aura del color del rango (jade común, violeta élite, bermellón jefe), así que no hace falta pintarla.

**Estado:** los 6 enemigos de la subida ya están en el juego (murciélago, salamandra, gólem, discípulo, monje y Eco del Dragón).

### Murciélago de Jade (`bat`, común) ✅

Ataca dos veces y chilla para hacerte descartar.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: a
mischievous mountain spirit bat the size of a child, wings spread wide, the wing membranes
made of rippling jade and mint sound rings like echoes on water, big round golden eyes,
small fangs, mouth open mid-screech with visible curved sound waves, hovering above the
ground with its feet tucked, playful but annoying, clear wide silhouette at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Salamandra de Brasa (`salamander`, común) ✅

Guardia que absorbe daño; se rompe con palmas y empujes.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: a
nimble fire salamander standing on its hind legs like a fighter, coral and gold scales, a
flickering orange flame on the tip of its tail, a thick glowing armor plate on its chest
and forearms like a natural shield, low crouch ready to leap, sly grin, sparks around its
feet, compact readable silhouette at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Gólem de Cuarzo (`golem`, común) ✅

Inamovible: hay que desequilibrarlo.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: a
heavy mountain golem built from pale stacked crystal stone with glowing turquoise veins,
very wide immovable horse stance, huge fists resting low, moss and tiny white flowers on its
shoulders, a calm ancient face carved in the rock, a faint crack on its chest where it can be
broken, massive blocky silhouette that fills the frame.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Discípulo Perdido (`disciple`, común) ✅

Castiga repetir la misma postura.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer in a fighting stance, centered,
transparent background: a young rival kung fu disciple who got lost on the mountain, torn
and patched jade training robe, messy tied-up hair with a loose headband, bandaged hands
raised in guard, determined but stubborn expression, one foot forward ready to copy your
moves, human proportions similar to the hero, clean silhouette at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Monje sin Rostro (`monk`, élite) ✅

Interrumpe tus formas si no lo desviás.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: an
elite wandering monk wearing a smooth blank white porcelain mask with no features, flowing
violet and gold layered robes, long prayer beads wrapped around one raised open palm, the
other hand hidden in the sleeve, a thin gold halo ring floating behind the head, perfectly
still and serene menace, tall elegant silhouette at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Eco del Dragón (`dragon`, jefe) ✅

Jefe final, con 3 fases: tiene **escamas** que restan daño a cada golpe (se caen al desequilibrarlo y le vuelven a crecer en la fase 3) y desde la fase 2 lanza el **Aliento del Dragón**. Por eso el prompt pide escamas de jade bien visibles en pecho y brazos y la boca abierta juntando aliento dorado.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game boss character, full body, facing the viewer, centered, transparent background: a
colossal dragon spirit made of swirling golden breath and soft white clouds, the head and
both front claws reaching toward the viewer, the long serpentine body coiling up and behind
in a clear S shape, a few large armored scales of bright jade and gold on its chest and
forearms like a natural breastplate, mouth half open gathering a glowing ball of golden
breath between its fangs, vermilion glowing eyes, flowing jade whiskers and white mane,
small pearls of light floating around it, majestic and awe-inspiring but colorful and bright,
fills most of the frame, iconic silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

## 4. Cartas

**Marcos por tipo.** Proporción 2:3, centro transparente.

#### Marco de Puño ✅

**Destino:** `assets/art/cards/frame_fist.png`, 2:3 (1024×1536), centro transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536), PNG where the center and the area outside the frame are fully transparent (real alpha channel, no checkerboard).

Playing card frame, 2:3 ratio, empty transparent center, ornamental Chinese cloud-pattern border painted in vermilion (#E8453C) with gold accents, rounded corners, a round slot in the top-left corner for the cost number.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Marco de Palma ✅

**Destino:** `assets/art/cards/frame_palm.png`, 2:3 (1024×1536), centro transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536), PNG where the center and the area outside the frame are fully transparent (real alpha channel, no checkerboard).

Playing card frame, 2:3 ratio, empty transparent center, ornamental Chinese cloud-pattern border painted in violet (#9B5DE5) with gold accents, rounded corners, a round slot in the top-left corner for the cost number.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Marco de Patada ✅

**Destino:** `assets/art/cards/frame_kick.png`, 2:3 (1024×1536), centro transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536), PNG where the center and the area outside the frame are fully transparent (real alpha channel, no checkerboard).

Playing card frame, 2:3 ratio, empty transparent center, ornamental Chinese cloud-pattern border painted in gold (#E59A12) with gold accents, rounded corners, a round slot in the top-left corner for the cost number.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Marco de Defensa ✅

**Destino:** `assets/art/cards/frame_defense.png`, 2:3 (1024×1536), centro transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536), PNG where the center and the area outside the frame are fully transparent (real alpha channel, no checkerboard).

Playing card frame, 2:3 ratio, empty transparent center, ornamental Chinese cloud-pattern border painted in cobalt blue (#3E7BE0) with gold accents, rounded corners, a round slot in the top-left corner for the cost number.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Marco de Técnica ✅

**Destino:** `assets/art/cards/frame_technique.png`, 2:3 (1024×1536), centro transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536), PNG where the center and the area outside the frame are fully transparent (real alpha channel, no checkerboard).

Playing card frame, 2:3 ratio, empty transparent center, ornamental Chinese cloud-pattern border painted in jade green (#1FA38A) with gold accents, rounded corners, a round slot in the top-left corner for the cost number.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

**Ilustración por carta.** Una por carta, cuadrada, mostrando el movimiento. El color de la estela es el del tipo de la carta.

#### Puñetazo a fondo 弓步冲拳 ✅

**Destino:** `assets/art/cards/gongbu_chongquan.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist in a deep bow stance, front knee bent and back leg straight, driving a straight punch forward at chest height, dynamic brush-stroke figure, motion trail in vermilion (#E8453C), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Puñetazo firme 马步冲拳 ✅

**Destino:** `assets/art/cards/mabu_chongquan.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist in a wide low horse stance, thighs parallel to the ground, firing a straight punch to the side, dynamic brush-stroke figure, motion trail in vermilion (#E8453C), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Patada látigo 弹腿 ✅

**Destino:** `assets/art/cards/tan_tui.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist snapping a fast whip-like front kick at waist height, the kicking foot pointed, arms balanced, dynamic brush-stroke figure, motion trail in gold (#E59A12), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Empujón de palma 推掌 ✅

**Destino:** `assets/art/cards/tui_zhang.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist pushing forward with an open palm, fingers up, a soft shockwave in front of the hand, dynamic brush-stroke figure, motion trail in violet (#9B5DE5), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Bloqueo y contragolpe 马步架打 ✅

**Destino:** `assets/art/cards/mabu_jiada.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist in horse stance raising one forearm to block overhead while punching with the other hand, dynamic brush-stroke figure, motion trail in cobalt blue (#3E7BE0), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Paso atrás 虚步亮掌 ✅

**Destino:** `assets/art/cards/xubu_liangzhang.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist in an empty stance, weight on the back leg, one open palm raised high above the head like a guard, the other hand hooked behind, dynamic brush-stroke figure, motion trail in cobalt blue (#3E7BE0), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Bloqueo medio 格挡 ✅

**Destino:** `assets/art/cards/ge_dang.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist sweeping a forearm across the body at chest height to block an incoming strike, dynamic brush-stroke figure, motion trail in cobalt blue (#3E7BE0), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Bloqueo bajo 按掌 ✅

**Destino:** `assets/art/cards/an_zhang.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist pressing both palms downward in front of the hips to smother a low attack, dynamic brush-stroke figure, motion trail in cobalt blue (#3E7BE0), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Patada de talón 蹬腿 ✅

**Destino:** `assets/art/cards/deng_tui.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist thrusting a straight heel kick forward at stomach height, toes pulled back, dynamic brush-stroke figure, motion trail in gold (#E59A12), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Patada lateral 侧踹 ✅

**Destino:** `assets/art/cards/ce_chuai.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist delivering a powerful side kick with the body leaning away and the heel leading, dynamic brush-stroke figure, motion trail in gold (#E59A12), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Empujón a fondo 弓步推掌 ✅

**Destino:** `assets/art/cards/gongbu_tuizhang.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist in a deep bow stance pushing forward with an open palm, the whole body behind the push, dynamic brush-stroke figure, motion trail in violet (#9B5DE5), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Puño martillo 劈拳 ✅

**Destino:** `assets/art/cards/pi_quan.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist bringing a fist down in a chopping arc from above like an axe, dynamic brush-stroke figure, motion trail in vermilion (#E8453C), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Bloqueo alto 上架 ✅

**Destino:** `assets/art/cards/shang_jia.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist raising one forearm horizontally above the head to block a strike from above, dynamic brush-stroke figure, motion trail in cobalt blue (#3E7BE0), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Rodilla escudo 提膝 ✅

**Destino:** `assets/art/cards/ti_xi.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist balanced on one leg with the other knee lifted high to guard the body, dynamic brush-stroke figure, motion trail in cobalt blue (#3E7BE0), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Recuperar el aliento 调息 ✅

**Destino:** `assets/art/cards/tiao_xi.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist standing calmly with palms facing down in front of the belly, eyes closed, a soft swirl of breath rising, dynamic brush-stroke figure, motion trail in jade green (#1FA38A), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Saludo marcial 抱拳礼 ✅

**Destino:** `assets/art/cards/baoquan_li.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist bowing slightly with the kung fu salute, right fist pressed into the open left palm in front of the chest, dynamic brush-stroke figure, motion trail in jade green (#1FA38A), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Garra de tigre 虎爪 ✅

**Destino:** `assets/art/cards/hu_zhao.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist striking with a tiger claw hand, fingers curled like talons, faint tiger stripes in the motion trail, dynamic brush-stroke figure, motion trail in violet (#9B5DE5), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Salto del tigre 虎扑 ✅

**Destino:** `assets/art/cards/hu_pu.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist leaping forward with both tiger-claw hands extended, like a tiger pouncing, dynamic brush-stroke figure, motion trail in violet (#9B5DE5), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Guardia del tigre 虎抱头 ✅

**Destino:** `assets/art/cards/hu_bao_tou.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist crouching and wrapping both arms around the head like a tiger protecting itself, dynamic brush-stroke figure, motion trail in cobalt blue (#3E7BE0), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Rugido del tigre 虎啸 ✅

**Destino:** `assets/art/cards/hu_xiao.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist in a low stance releasing a powerful roar, a visible golden roar wave with a faint tiger head shape, dynamic brush-stroke figure, motion trail in jade green (#1FA38A), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Cola de tigre 虎尾 ✅

**Destino:** `assets/art/cards/hu_wei.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist spinning into a low sweeping back kick, the leg whipping like a tiger tail, faint tiger stripes in the motion trail, dynamic brush-stroke figure, motion trail in gold (#E59A12), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Tigre que baja de la montaña 下山虎 ✅

**Destino:** `assets/art/cards/xia_shan_hu.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist charging downhill in a deep stance, both palms thrust forward and down like a tiger descending a mountain, faint tiger stripes in the motion trail, dynamic brush-stroke figure, motion trail in violet (#9B5DE5), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Colmillo de tigre 虎牙 ✅

**Destino:** `assets/art/cards/hu_ya.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist driving a sharp uppercut with the knuckles bent like a fang, faint tiger stripes in the motion trail, dynamic brush-stroke figure, motion trail in vermilion (#E8453C), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Embestida del tigre 虎奔 ✅

**Destino:** `assets/art/cards/hu_ben.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist running forward and launching a flying front kick, like a tiger rushing at full speed, faint tiger stripes in the motion trail, dynamic brush-stroke figure, motion trail in gold (#E59A12), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Tigre hambriento 饿虎扑食 ✅

**Destino:** `assets/art/cards/e_hu_pu_shi.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist diving low and forward with both claw hands reaching out to seize, like a hungry tiger catching its prey, faint tiger stripes in the motion trail, dynamic brush-stroke figure, motion trail in violet (#9B5DE5), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Tigre agazapado 虎蹲 ✅

**Destino:** `assets/art/cards/hu_dun.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist crouching very low on the ground, arms coiled in front as a guard, like a tiger lying in wait, faint tiger stripes in the motion trail, dynamic brush-stroke figure, motion trail in cobalt blue (#3E7BE0), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Mano de serpiente 蛇形手 ✅

**Destino:** `assets/art/cards/she_xing_shou.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist striking with a flat snake-head hand, the arm undulating forward, the motion trail curling like a slender serpent, dynamic brush-stroke figure, motion trail in violet (#9B5DE5), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Lengua de serpiente 蛇吐信 ✅

**Destino:** `assets/art/cards/she_tu_xin.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background: a martial artist darting two fingers forward in a quick jab to the throat, like a snake flicking its tongue, the motion trail curling like a slender serpent, dynamic brush-stroke figure, motion trail in violet (#9B5DE5), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Serpiente enroscada 蛇缠身 ✅

**Destino:** `assets/art/cards/she_chan_shen.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure inside the frame, clear silhouette readable at small size.
The move: standing in a stable low horse stance, the front forearm raised upright in front of the chest with the open palm turned outward to deflect a blow, the rear hand held open beside the hip, calm and rooted.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every visible hand has five fingers with normal joints, drawn in a simple readable shape (flat open palms with the fingers together and the thumb visible); both hands are fully visible, apart from the body and from each other, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; the torso turns at most a quarter turn and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The snake is NOT in the body: the human pose stays natural, stable and anatomically correct. The coiling is shown only by a separate translucent ink serpent spirit in cobalt blue (#3E7BE0) that coils in a wide spiral around the whole figure like a protective shield; it never touches, wraps or hides the hands.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers.
```

#### Serpiente dorada 金蛇 ✅

**Destino:** `assets/art/cards/jin_she.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure inside the frame, clear silhouette readable at small size.
The move: stepping forward into a long bow stance and throwing a straight punch, the front arm fully extended at shoulder height, the rear fist pulled back at the hip.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every visible hand has five fingers with normal joints, drawn in a simple readable shape (two tight closed fists, knuckles clearly drawn, thumb folded over the fingers); both hands are fully visible, apart from the body and from each other, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; the torso turns at most a quarter turn and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The snake is NOT in the body: the human pose stays natural, stable and anatomically correct. The coiling is shown only by a separate translucent ink serpent spirit in vermilion (#E8453C) that spirals forward along the punching arm like a corkscrew, with a golden glint on its scales, ending in a small serpent head just past the fist; it never touches, wraps or hides the hands.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers.
```

#### Cola de serpiente 蛇尾 ✅

**Destino:** `assets/art/cards/she_wei.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure inside the frame, clear silhouette readable at small size.
The move: dropping into a low crouch on the bent support leg while the other leg stretches out straight and sweeps close to the ground, heel leading; the front hand rests open on the bent knee and the other arm reaches back for balance.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every visible hand has five fingers with normal joints, drawn in a simple readable shape (flat open palms with the fingers together and the thumb visible); both hands are fully visible, apart from the body and from each other, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; the torso turns at most a quarter turn and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The snake is NOT in the body: the human pose stays natural, stable and anatomically correct. The coiling is shown only by a separate translucent ink serpent spirit in gold (#E59A12) that trails behind the sweeping heel along the ground in a long S curve, like a snake's tail; it never touches, wraps or hides the hands.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers.
```

#### Serpiente que se escurre 蛇闪 ✅

**Destino:** `assets/art/cards/she_shan.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure inside the frame, clear silhouette readable at small size.
The move: taking a light, balanced sidestep out of the way of a strike, upper body leaning slightly to one side, both open hands raised in front of the chest ready to guard.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every visible hand has five fingers with normal joints, drawn in a simple readable shape (flat open palms with the fingers together and the thumb visible); both hands are fully visible, apart from the body and from each other, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; the torso turns at most a quarter turn and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The snake is NOT in the body: the human pose stays natural, stable and anatomically correct. The coiling is shown only by a separate translucent ink serpent spirit in jade green (#1FA38A) that draws an S curve along the path of the sidestep, showing where the body slipped away; it never touches, wraps or hides the hands.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers.
```

#### La serpiente vuelve la cabeza 蛇回头 ✅

**Destino:** `assets/art/cards/she_hui_tou.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure inside the frame, clear silhouette readable at small size.
The move: a turning strike: the figure has just pivoted on the balls of the feet, body and head now facing the same direction, one arm thrusting a palm strike forward at shoulder height, the other hand open in front of the chest; hair and robe still swinging from the turn.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every visible hand has five fingers with normal joints, drawn in a simple readable shape (flat open palms with the fingers together and the thumb visible, the striking wrist slightly bent back); both hands are fully visible, apart from the body and from each other, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; the torso turns at most a quarter turn and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The snake is NOT in the body: the human pose stays natural, stable and anatomically correct. The coiling is shown only by a separate translucent ink serpent spirit in violet (#9B5DE5) that follows the turn in a half circle behind the figure and rises with its head beside the striking palm; it never touches, wraps or hides the hands.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers.
```

#### Serpiente ágil 灵蛇 ✅

**Destino:** `assets/art/cards/ling_she.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure inside the frame, clear silhouette readable at small size.
The move: a light hopping front kick: the support leg slightly bent, up on the toes, the kicking leg snapping forward to waist height with the foot flexed, both arms open to the sides for balance.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every visible hand has five fingers with normal joints, drawn in a simple readable shape (flat open palms with the fingers together and the thumb visible); both hands are fully visible, apart from the body and from each other, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; the torso turns at most a quarter turn and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The snake is NOT in the body: the human pose stays natural, stable and anatomically correct. The coiling is shown only by a separate translucent ink serpent spirit in gold (#E59A12) that springs upward in a quick zigzag from the ground to the kicking foot; it never touches, wraps or hides the hands.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers.
```

#### Abrazo de la serpiente 蛇绞 ✅

**Destino:** `assets/art/cards/she_jiao.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure inside the frame, clear silhouette readable at small size.
The move: in a bow stance, the front hand presses down and forward at waist height, palm down, as if pinning an opponent's arm, while the rear hand pulls back to the hip as a closed fist; no opponent is drawn.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every visible hand has five fingers with normal joints, drawn in a simple readable shape (front hand a flat palm facing down with the fingers together; rear hand a closed fist with the thumb folded over); both hands are fully visible, apart from the body and from each other, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; the torso turns at most a quarter turn and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The snake is NOT in the body: the human pose stays natural, stable and anatomically correct. The coiling is shown only by a separate translucent ink serpent spirit in violet (#9B5DE5) that loops twice in a tight spiral in the empty space just in front of the front palm, like a snare closing on an invisible arm; it never touches, wraps or hides the hands.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers.
```

#### Serpiente al acecho 蛇盘 ✅

**Destino:** `assets/art/cards/she_pan.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure inside the frame, clear silhouette readable at small size.
The move: in a deep low stance with the weight sunk onto the back leg, knees bent, back straight, the front hand held open at chin height, the rear hand open below the front elbow guarding the body, eyes fixed forward, patient.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every visible hand has five fingers with normal joints, drawn in a simple readable shape (flat open palms with the fingers together and the thumb visible, palms facing forward); both hands are fully visible, apart from the body and from each other, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; the torso turns at most a quarter turn and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The snake is NOT in the body: the human pose stays natural, stable and anatomically correct. The coiling is shown only by a separate translucent ink serpent spirit in cobalt blue (#3E7BE0) that lies coiled in a flat spiral on the ground under the figure's feet, its head raised and watching, ready to strike; it never touches, wraps or hides the hands.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers.
```

#### Ala de grulla 鹤翅 ✅

**Destino:** `assets/art/cards/he_chi.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure inside the frame, clear silhouette readable at small size.
The move: standing in a balanced stance, the front forearm sweeping up and outward above the head with the open palm turned out to deflect a high blow, the rear hand open in front of the chest.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every visible hand has five fingers with normal joints, drawn in a simple readable shape (flat open palms with the fingers together and the thumb visible); both hands are fully visible, apart from the body and from each other, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; when standing on one leg, both legs are still drawn complete, the raised one clearly bent at the knee with its foot visible; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The crane is NOT in the body: the arms are human arms in sleeves, never wings, with no feathers growing from them. The crane is shown only by a separate translucent ink crane spirit in cobalt blue (#3E7BE0) that spreads one large wing behind the raised arm like a shield, plus a few loose white feathers drifting in the air; it never touches or hides the hands.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

#### Grulla en una pata 独立 ✅

**Destino:** `assets/art/cards/du_li.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure inside the frame, clear silhouette readable at small size.
The move: balanced calmly on one straight leg, the other knee raised to hip height with the foot hanging relaxed below it, both arms extended low and slightly out to the sides for balance.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every visible hand has five fingers with normal joints, drawn in a simple readable shape (flat open palms with the fingers together and the thumb visible, palms facing down); both hands are fully visible, apart from the body and from each other, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; when standing on one leg, both legs are still drawn complete, the raised one clearly bent at the knee with its foot visible; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The crane is NOT in the body: the arms are human arms in sleeves, never wings, with no feathers growing from them. The crane is shown only by a separate translucent ink crane spirit in cobalt blue (#3E7BE0) that stands on one leg beside the figure, mirroring the pose, plus a few loose white feathers drifting in the air; it never touches or hides the hands.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

#### Pico de grulla 鹤嘴 ✅

**Destino:** `assets/art/cards/he_zui.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure inside the frame, clear silhouette readable at small size.
The move: in a forward bow stance, the front arm extended at chest height striking with a crane-beak hand, the rear hand open at the hip.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every visible hand has five fingers with normal joints, drawn in a simple readable shape (front hand: all five fingertips pinched together into one clear point, wrist straight, like a bird's beak; rear hand a flat open palm); both hands are fully visible, apart from the body and from each other, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; when standing on one leg, both legs are still drawn complete, the raised one clearly bent at the knee with its foot visible; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The crane is NOT in the body: the arms are human arms in sleeves, never wings, with no feathers growing from them. The crane is shown only by a separate translucent ink crane spirit in vermilion (#E8453C) that stretches its long neck forward along the striking arm, its beak pointing the same way as the hand, plus a few loose white feathers drifting in the air; it never touches or hides the hands.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

#### Danza de la grulla 鹤舞 ✅

**Destino:** `assets/art/cards/he_wu.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure inside the frame, clear silhouette readable at small size.
The move: a high side kick at the moment of a turn: the support leg straight, the kicking leg extended out to the side at chest height with the foot flexed, the torso upright and leaning slightly away, both arms open wide to the sides for balance.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every visible hand has five fingers with normal joints, drawn in a simple readable shape (flat open palms with the fingers together and the thumb visible); both hands are fully visible, apart from the body and from each other, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; when standing on one leg, both legs are still drawn complete, the raised one clearly bent at the knee with its foot visible; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The crane is NOT in the body: the arms are human arms in sleeves, never wings, with no feathers growing from them. The crane is shown only by a separate translucent ink crane spirit in gold (#E59A12) that circles once around the figure with its wings open, tracing the turn, plus a few loose white feathers drifting in the air; it never touches or hides the hands.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

#### Rodilla de grulla 鹤膝 ✅

**Destino:** `assets/art/cards/he_xi.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure inside the frame, clear silhouette readable at small size.
The move: a rising knee strike: standing on one leg, the other knee driving up to chest height with the shin hanging below it, both arms raised to the sides at shoulder height, elbows soft.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every visible hand has five fingers with normal joints, drawn in a simple readable shape (flat open palms with the fingers together and the thumb visible); both hands are fully visible, apart from the body and from each other, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; when standing on one leg, both legs are still drawn complete, the raised one clearly bent at the knee with its foot visible; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The crane is NOT in the body: the arms are human arms in sleeves, never wings, with no feathers growing from them. The crane is shown only by a separate translucent ink crane spirit in gold (#E59A12) that lifts off from under the raised knee with wings spread upward, plus a few loose white feathers drifting in the air; it never touches or hides the hands.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

#### Canto de la grulla 鹤鸣 ✅

**Destino:** `assets/art/cards/he_ming.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure inside the frame, clear silhouette readable at small size.
The move: a tall poised guard, feet apart, chin slightly raised, both forearms held up in front of the body with open palms facing forward, one at face height and one at chest height.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every visible hand has five fingers with normal joints, drawn in a simple readable shape (flat open palms with the fingers together and the thumb visible); both hands are fully visible, apart from the body and from each other, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; when standing on one leg, both legs are still drawn complete, the raised one clearly bent at the knee with its foot visible; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The crane is NOT in the body: the arms are human arms in sleeves, never wings, with no feathers growing from them. The crane is shown only by a separate translucent ink crane spirit in cobalt blue (#3E7BE0) that throws its head back and calls out above the figure, with soft rings of sound spreading around the guard, plus a few loose white feathers drifting in the air; it never touches or hides the hands.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

#### Corona de la grulla 鹤顶 ✅

**Destino:** `assets/art/cards/he_ding.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure inside the frame, clear silhouette readable at small size.
The move: in a short forward stance, the front arm striking upward at chin height with the back of the bent wrist, the rear hand open in front of the chest.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every visible hand has five fingers with normal joints, drawn in a simple readable shape (front hand: wrist bent down, fingers relaxed and together pointing down, the top of the wrist leading the strike; rear hand a flat open palm); both hands are fully visible, apart from the body and from each other, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; when standing on one leg, both legs are still drawn complete, the raised one clearly bent at the knee with its foot visible; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The crane is NOT in the body: the arms are human arms in sleeves, never wings, with no feathers growing from them. The crane is shown only by a separate translucent ink crane spirit in violet (#9B5DE5) that rises beside the striking wrist with its small red crown at the point of impact, plus a few loose white feathers drifting in the air; it never touches or hides the hands.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

#### La grulla blanca abre las alas 白鹤亮翅 ✅

**Destino:** `assets/art/cards/bai_he_liang_chi.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure inside the frame, clear silhouette readable at small size.
The move: the classic White Crane Spreads Its Wings pose: weight on the bent back leg, the front foot resting lightly on its toes, one hand raised beside the temple with the palm turned out, the other hand pressing down beside the hip.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every visible hand has five fingers with normal joints, drawn in a simple readable shape (flat open palms with the fingers together and the thumb visible); both hands are fully visible, apart from the body and from each other, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; when standing on one leg, both legs are still drawn complete, the raised one clearly bent at the knee with its foot visible; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The crane is NOT in the body: the arms are human arms in sleeves, never wings, with no feathers growing from them. The crane is shown only by a separate translucent ink crane spirit in cobalt blue (#3E7BE0) that opens both wings wide behind the figure, one high and one low, echoing the hands, plus a few loose white feathers drifting in the air; it never touches or hides the hands.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

#### Picotazo de la grulla 鹤啄 ✅

**Destino:** `assets/art/cards/he_zhuo.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure inside the frame, clear silhouette readable at small size.
The move: a quick snapping toe kick: the support leg slightly bent, the kicking leg straight forward at knee height, toes pointed, both open hands raised in front of the chest in guard.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every visible hand has five fingers with normal joints, drawn in a simple readable shape (flat open palms with the fingers together and the thumb visible); both hands are fully visible, apart from the body and from each other, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; when standing on one leg, both legs are still drawn complete, the raised one clearly bent at the knee with its foot visible; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The crane is NOT in the body: the arms are human arms in sleeves, never wings, with no feathers growing from them. The crane is shown only by a separate translucent ink crane spirit in gold (#E59A12) that darts its beak down along the kicking leg toward the toes, plus a few loose white feathers drifting in the air; it never touches or hides the hands.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

#### La grulla duerme 鹤眠 ✅

**Destino:** `assets/art/cards/he_mian.png`, cuadrada (1024×1024), fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure inside the frame, clear silhouette readable at small size.
The move: resting serenely on one straight leg with eyes closed, the other knee raised with the foot tucked beside the standing knee, both open hands resting one on top of the other in front of the belly, shoulders relaxed.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every visible hand has five fingers with normal joints, drawn in a simple readable shape (flat open palms with the fingers together and the thumb visible, one palm laid on the other, all ten fingers visible); both hands are fully visible, apart from the body and from each other, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; when standing on one leg, both legs are still drawn complete, the raised one clearly bent at the knee with its foot visible; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The crane is NOT in the body: the arms are human arms in sleeves, never wings, with no feathers growing from them. The crane is shown only by a separate translucent ink crane spirit in jade green (#1FA38A) that sleeps standing on one leg beside the figure with its head tucked under a wing, plus a few loose white feathers drifting in the air; it never touches or hides the hands.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

## 5. Íconos y efectos

Todos transparentes, 256×256 px.

#### Aliento ✅

**Destino:** `assets/art/icons/breath.png`, cuadrado 256×256, fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The game shrinks it to 256×256 and shows it at about 32 pixels.

Game UI icon, transparent background, bold simple shape, readable at 32 pixels: a swirling cobalt blue (#3E7BE0) breath wisp shaped like the character 气.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Guardia ✅

**Destino:** `assets/art/icons/guard.png`, cuadrado 256×256, fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The game shrinks it to 256×256 and shows it at about 32 pixels.

Game UI icon, transparent background, bold simple shape, readable at 32 pixels: a rounded cobalt blue (#3E7BE0) shield with a cloud pattern.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Estructura ✅

**Destino:** `assets/art/icons/structure.png`, cuadrado 256×256, fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The game shrinks it to 256×256 and shows it at about 32 pixels.

Game UI icon, transparent background, bold simple shape, readable at 32 pixels: a violet (#9B5DE5) hexagonal crystal.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Desvío ✅

**Destino:** `assets/art/icons/deflect.png`, cuadrado 256×256, fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The game shrinks it to 256×256 and shows it at about 32 pixels.

Game UI icon, transparent background, bold simple shape, readable at 32 pixels: a jade green (#1FA38A) arc slash deflecting a strike, with sparkles.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Desequilibrado ✅

**Destino:** `assets/art/icons/stagger.png`, cuadrado 256×256, fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The game shrinks it to 256×256 and shows it at about 32 pixels.

Game UI icon, transparent background, bold simple shape, readable at 32 pixels: a gold (#E59A12) starburst with dizzy spirals.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Fuente ✅

**Destino:** `assets/art/icons/fountain.png`, cuadrado 256×256, fondo transparente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The game shrinks it to 256×256 and shows it at about 32 pixels.

Game UI icon, transparent background, bold simple shape, readable at 32 pixels: a small cobalt blue (#3E7BE0) spring with a pink lotus.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

---

## 6. Lo que viene (élites, economía y lore)

**Formato:** igual que los enemigos, vertical 2:3 (1024×1536) con fondo transparente, figura completa y pies cerca del borde inferior. Los retratos van en `assets/art/npc/`. Hasta que el código los use, no hace falta nada más que dejarlos en su carpeta.

**Estado:** los 5 de la primera tanda ya están en el juego (León, Abanico y Mono en combate; mercader y maestro en sus pantallas y en el prólogo). La tanda 2 también.

### León de Piedra (`lion`, élite) ✅

`assets/art/enemies/lion.png`. Guardián del arco del santuario: despierta de a poco; si no lo golpeás en un turno, gana Guardia.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: an
elite stone guardian lion (Chinese shishi) that has just woken up on its pedestal, pale carved
granite body with curly stone mane, one front paw resting on an embroidered ball, cracks of
glowing gold light along its back and mane, moss and fallen pine needles on its shoulders,
red silk ribbon tied around its neck, mouth open in a silent roar, heavy powerful crouch,
wide blocky silhouette that fills the frame.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Dama del Abanico (`fan`, élite) ✅

`assets/art/enemies/fan.png`. Élite humana: devuelve el primer golpe de cada turno con el abanico; hay que abrirla con fintas o palmas.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer in an elegant fighting stance, centered,
transparent background: an elite martial artist woman of the mountain, flowing layered violet
and coral robes with wide sleeves caught in the wind, a large open iron war fan painted with
clouds held in front of her face like a shield, the other hand in a crane-beak gesture, calm
confident eyes above the fan, petals swirling around her feet, tall graceful silhouette at
small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Mono Ladrón (`monkey`, común) ✅

`assets/art/enemies/monkey.png`. Común rápido: si sobrevive dos turnos, se escapa con parte de tu jade.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: a
cheeky golden mountain monkey thief, a small red cloth bundle full of jade coins slung over
its shoulder, a stolen peach in one hand and a coin between its teeth, crouched on its toes
ready to bolt, long curling tail, mischievous grin and wide eyes, a tiny jade coin falling
from the bundle, compact readable silhouette at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Mercader del Paso (`merchant`, retrato) ✅

`assets/art/npc/merchant.png`. Retrato para la tienda (nodo 商) cuando se haga la economía.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game character portrait, full body, facing the viewer, centered, transparent background: a
friendly old wandering merchant of the mountain pass, round straw hat, warm smile and long
white eyebrows, a huge wooden backpack frame stacked with scrolls, paper talismans, jars,
small jade charms and a hanging lantern, abacus at his belt, one hand raised in welcome,
patched gold and jade travel robes, cozy and trustworthy, clear silhouette at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### El Maestro de la escuela (`master`, retrato) ✅

`assets/art/npc/master.png`. Lore: aparece en el prólogo y al llegar a la cumbre. Que tenga algo ambiguo (la duda del pergamino de la cumbre).

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game character portrait, full body, facing the viewer, centered, transparent background: the
old master of the Sleeping Dragon school, tall and thin, long white beard flowing in the
wind, simple undyed linen robe with a jade sash, hands folded inside his sleeves, a wooden
staff leaning on his shoulder, serene half-smile with eyes that seem to hide a secret, a
faint gold dragon-scale pattern barely visible on the hem of his robe, wisps of cloud around
his feet, dignified and calm, clear silhouette at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Tanda 2

#### Bandido del Paso (`bandit`, común) ✅

`assets/art/enemies/bandit.png`. 1024×1536, transparente. Común con bastón: golpe fuerte cada dos turnos (se telegrafía).

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: a
burly but comical mountain pass bandit, bamboo hat tilted over one eye, red scarf over his
nose, sleeveless patched jade vest, a long wooden staff held across his shoulders with both
wrists hooked over it, wide boastful stance, a gourd of wine and a pouch of stolen coins at
his belt, bushy eyebrows and a cocky grin, clear wide silhouette at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Hongo Lingzhi (`lingzhi`, común) ✅

`assets/art/enemies/lingzhi.png`. 1024×1536, transparente. Común que se cura cada turno: hay que pegarle fuerte y rápido.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: a
living lingzhi mushroom spirit the size of a child, glossy layered caps in vermilion, gold and
coral like a fan, tiny root legs and little leafy arms, round sleepy eyes and a smug smile,
glowing jade spores floating around it like healing sparkles, a small drop of dew on its cap,
cute but stubborn, compact readable silhouette at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Fondo de la Fuente (`fountain_bg.png`) ✅

`assets/art/stages/qianyunshan/fountain_bg.png`. 1080×1920 vertical, sin transparencia. Pantalla de descanso del nodo 泉; centro despejado para la UI.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 9:16 aspect ratio (1080×1920), fully opaque (no transparency).

Vertical background, 1080x1920 pixels (aspect ratio 9:16), of a peaceful mountain spring: a small clear turquoise pond fed by a
thin waterfall over mossy rocks, lotus leaves and a few pink lotus flowers, a flat stone
ledge to sit and rest, bamboo and a leaning pine framing the sides, soft morning mist and
sunbeams, ripples and light reflections on the water, the middle of the image calm and open
for interface elements.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
background (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, calm and luminous mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no characters, no text, no watermark.
```

#### Fondo del Santuario (`shrine_bg.png`) ✅

`assets/art/stages/qianyunshan/shrine_bg.png`. 1080×1920 vertical, sin transparencia. Donde los espíritus eligen camino; las 3 estatuas van atrás y chicas, la UI va adelante.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 9:16 aspect ratio (1080×1920), fully opaque (no transparency).

Vertical background, 1080x1920 pixels (aspect ratio 9:16), of a small open-air mountain shrine at dawn: a stone courtyard with
three weathered statues on pedestals in the back, a tiger on the left, a crane in the middle
and a coiled snake on the right, each with a faint glow of its own color (vermilion, cobalt,
jade), incense smoke curling up, red paper lanterns and prayer ribbons tied to a pine branch,
clouds below the courtyard, the lower two thirds clean and open for interface elements.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
background (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, calm and luminous mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no characters, no text, no watermark.
```

#### Muro de la escuela (`school_wall.png`) ✅

`assets/art/school/school_wall.png`. 1080×1920 vertical, sin transparencia. Fondo del Registro y de la escena de derrota: donde la escuela recuerda a los que no volvieron.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 9:16 aspect ratio (1080×1920), fully opaque (no transparency).

Vertical background, 1080x1920 pixels (aspect ratio 9:16), of a quiet courtyard wall at the Sleeping Dragon school, warm
plastered wall with a small tiled roof on top, rows of small wooden name tablets hanging from
red cords (no readable writing), a few faded headbands and ribbons tied among them moving in
the breeze, a stone incense burner with a thin line of smoke, fallen plum blossoms on the
ground, soft afternoon light, nostalgic but bright and hopeful, the center calm and open for
interface elements.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
background (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, calm and luminous mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no characters, no text, no watermark.
```

## 7. Etapas 2 y 3

**Estado:** los fondos de las dos etapas (general y tramos) ya están. De los enemigos, todos tienen arte propio salvo los 4 comunes de la etapa 3 (`monkey_snow`, `golem_ice`, `disciple_wind`, `bat_frost`), que siguen siendo **variantes recoloreadas** de los de la etapa 1 (`tool/recolor_enemies.py`). Cuando llegue el arte propio de uno, se guarda con el mismo nombre en `assets/art/enemies/` y **se borra su entrada de `VARIANTS`** en el script (si no, volver a correrlo lo pisa).

### Fondos de combate

**Destino:** `assets/art/stages/xuankongsi/` y `assets/art/stages/wolongding/` (hay que agregar las carpetas en `pubspec.yaml`). Mismo formato que la etapa 1: cuadrados 1:1, suelo plano y despejado en el tercio inferior. Con `combat_bg.png` alcanza; las variantes por tramo usan los nombres de la etapa 1 (`combat_bg_ladera`, `_bifurcacion`, `_templo`, `_cumbre`), según `_sceneFiles`.

✅ Monasterio Colgado (`xuankongsi/combat_bg.png`):

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), fully opaque (no transparency).

Square game battle background, 1:1 aspect ratio: a wooden walkway of the Hanging Monastery (Xuankong Si) clinging to
a sheer cliff, red lacquered pillars and curved roofs, bronze bells, prayer flags, a deep misty
abyss with soft clouds below, warm saffron morning light, flat clear wooden floor in the lower third.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
background (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no characters, no text, no watermark.
```

✅ Cumbre del Dragón Dormido (`wolongding/combat_bg.png`):

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), fully opaque (no transparency).

Square game battle background, 1:1 aspect ratio, low camera close to the ground: a narrow wind-swept snow ridge
at the very top of the world, strong wind blowing fine snow diagonally across the frame, torn
blue prayer flags snapping on a leaning pole, sharp ice crystals catching the light, the sky
almost all a cold gradient from cobalt blue to soft violet with one thin golden line of sun at
the horizon, flat clear snowy ground in the lower third.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, COOL palette
dominated by cobalt blue (#3E7BE0), violet (#9B5DE5) and white, only tiny touches of gold
(#E59A12), almost no green and no red, crisp dry-brush strokes for the wind, energetic and
tense mood, high readability on a small phone screen. NOT dark, NOT gloomy, no black or brown
backgrounds, no photorealism, no characters, no text, no watermark.
```

#### Tramos de las etapas 2 y 3

Mismo formato que los tramos de la etapa 1: vertical 9:19.5, sin transparencia.

✅ Gran Campanario (`xuankongsi/combat_bg_templo.png`, élite y jefe de la etapa 2):

```
Create ONE single image. Start immediately, without asking questions.

Create a tall PORTRAIT image with a 9:19.5 aspect ratio, fully opaque (no transparency).

Mobile game combat background, vertical 9:19.5, no characters, symmetrical view looking slightly up: the inside of the Great Bell Pavilion of the Hanging Monastery, an enormous pale bronze bell with soft jade-green patina hanging from massive celadon-lacquered beams in the center top, open sides showing bright sky and floating clouds, thin golden rings of sound drifting through the air, a smooth polished stone floor reflecting light. Upper third open and uncluttered for a character, lower half soft and low-contrast so cards remain readable. No people, no animals, no text.
Style: vibrant modern Chinese ink-and-watercolor illustration, cool afternoon daylight, FRESH palette dominated by celadon, jade green (#1FA38A) and pale bronze, accents of cinnabar vermilion (#E8453C) on the beam joints, very little saffron, clean confident brush strokes, flat shading with watercolor bleeds, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

✅ Lecho del Dragón (`wolongding/combat_bg_cumbre.png`, jefe final):

```
Create ONE single image. Start immediately, without asking questions.

Create a tall PORTRAIT image with a 9:19.5 aspect ratio, fully opaque (no transparency).

Mobile game combat background, vertical 9:19.5, no characters, wide high view: the dragon's bed at the very top of the mountain, a huge round hollow of smooth turquoise ice shaped like a nest, giant curved ice ridges around it like the imprint of a coiled body, a few enormous shed scales of white jade lying on the ice, the sun rising behind in a sky of peach, coral and pale gold, soft pink light glowing through the ice. Upper third open and uncluttered for a character, lower half soft and low-contrast so cards remain readable. No people, no animals, no text.
Style: vibrant modern Chinese ink-and-watercolor illustration, sunrise light, DAWN palette of turquoise ice, peach, coral pink and white jade, small touches of gold (#E59A12), almost no cobalt or violet, soft gradients, clean brush strokes, watercolor bleeds, luminous final-battle feeling, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

✅ Escalera del Acantilado (`xuankongsi/combat_bg_ladera.png`, combates comunes de la etapa 2):

```
Create ONE single image. Start immediately, without asking questions.

Create a tall PORTRAIT image with a 9:19.5 aspect ratio, fully opaque (no transparency).

Mobile game combat background, vertical 9:19.5, no characters, view from the side of a steep climb: a narrow stone stairway carved into a pale apricot sandstone cliff, polished iron chains running along the steps as handrails, small jade-green pines growing sideways out of the rock, a few strips of red cloth tied to the chains fluttering in the wind, a wide clear blue midday sky with small white clouds, a flat stone landing in the lower part. Upper third open and uncluttered for a character, lower half soft and low-contrast so cards remain readable. No people, no animals, no text.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright midday light, palette of apricot and peach sandstone, sky blue (#3E7BE0), jade green (#1FA38A) pines and small vermilion (#E8453C) cloth accents, no saffron, no gold, sharp dry-brush rock texture, flat shading with watercolor bleeds, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

✅ Ventisquero (`wolongding/combat_bg_ladera.png`, combates comunes de la etapa 3):

```
Create ONE single image. Start immediately, without asking questions.

Create a tall PORTRAIT image with a 9:19.5 aspect ratio, fully opaque (no transparency).

Mobile game combat background, vertical 9:19.5, no characters, calm wide view: a sheltered snowy slope just after a snowfall, soft rounded snowdrifts like waves, three old stone lanterns half buried in snow with tiny warm lights inside, a few snow-laden pines on one side, the air perfectly still with big slow snowflakes, a pastel morning sky of pale pink and lilac, flat smooth snow in the lower part. Upper third open and uncluttered for a character, lower half soft and low-contrast so cards remain readable. No people, no animals, no text.
Style: vibrant modern Chinese ink-and-watercolor illustration, soft morning light, PASTEL palette of snow white, pale pink, lilac and mint, small warm gold (#E59A12) lantern lights, almost no cobalt, quiet and gentle mood, very soft wet watercolor bleeds, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

✅ Templo Helado (`wolongding/combat_bg_templo.png`, élite de la etapa 3):

```
Create ONE single image. Start immediately, without asking questions.

Create a tall PORTRAIT image with a 9:19.5 aspect ratio, fully opaque (no transparency).

Mobile game combat background, vertical 9:19.5, no characters, framed through a round moon gate in the foreground: a small mountain temple completely frozen, vermilion pillars and curved roofs coated in clear glassy ice, long icicles hanging from the eaves like crystal bells, a frozen pond in the courtyard reflecting the sky, bright sun making the ice sparkle with tiny rainbow glints, a smooth icy courtyard floor in the lower part. Upper third open and uncluttered for a character, lower half soft and low-contrast so cards remain readable. No people, no animals, no text.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright sunny winter light, palette of crystal white, icy aqua and silver with strong vermilion (#E8453C) pillars glowing under the ice and small rainbow glints, little violet, crisp clean brush strokes, flat shading with watercolor bleeds, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

✅ Puente Colgante (`xuankongsi/combat_bg_bifurcacion.png`, combates comunes de la etapa 2):

```
Create ONE single image. Start immediately, without asking questions.

Create a tall PORTRAIT image with a 9:19.5 aspect ratio, fully opaque (no transparency).

Mobile game combat background, vertical 9:19.5, no characters, looking along the length of a bridge: a long rope-and-plank suspension bridge stretched between two small cliffside pavilions with curved roofs, rows of round red paper lanterns hanging from the ropes, soft clouds drifting below and between the planks, the far pavilion small in the distance, warm late-afternoon sky in rose and lavender, the near end of the bridge as a flat wooden platform in the lower part. Upper third open and uncluttered for a character, lower half soft and low-contrast so cards remain readable. No people, no animals, no text.
Style: vibrant modern Chinese ink-and-watercolor illustration, late-afternoon glow, palette of rose pink, lavender (#9B5DE5) and cream clouds with bright red lanterns (#E8453C), very little gold, no saffron, strong one-point perspective, clean brush strokes, watercolor bleeds, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

✅ Glaciar (`wolongding/combat_bg_bifurcacion.png`, combates comunes de la etapa 3):

```
Create ONE single image. Start immediately, without asking questions.

Create a tall PORTRAIT image with a 9:19.5 aspect ratio, fully opaque (no transparency).

Mobile game combat background, vertical 9:19.5, no characters, wide view at eye level: a glacier field with huge natural ice arches of mint and emerald ice, a still glacial lake of bright green-turquoise water in the middle distance, smooth wind-carved ice shapes like frozen waves, a high white sun in a clear pale sky, flat frosted ice ground in the lower part. Upper third open and uncluttered for a character, lower half soft and low-contrast so cards remain readable. No people, no animals, no text.
Style: vibrant modern Chinese ink-and-watercolor illustration, high clear noon light, palette of mint, emerald and jade green (#1FA38A) ice with white and touches of pale gold (#E59A12) sunlight, almost no cobalt, no violet, no pink, glassy layered washes, clean brush strokes, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

### Enemigos

### Murciélago del Campanario (`bat_bronze`, común, etapa 2) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: a bat spirit that nests in a temple bell tower, bronze-and-copper wings engraved like an old bell, a tiny bronze bell hanging from its neck, sound rings rippling from its wings, wide round eyes.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Hombre de Bronce 铜人 (`golem_bronze`, común, etapa 2) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: a Shaolin bronze man training statue come alive, polished bronze body with acupuncture-point markings, short sharp bronze spikes on shoulders and forearms, solid wide stance, faint gold glow in its eyes.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Guardián del Pasadizo (`disciple_saffron`, común, etapa 2) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: a young monk guardian in deep maroon and saffron robes, wooden prayer beads, one palm raised forward like a closed gate, feet firmly planted.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Salamandra de Ceniza (`salamander_ash`, común, etapa 2) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: a lavender-grey salamander made of cooled ash with glowing pale embers along its back, small wisps of incense smoke curling from its tail, wounds closing with soft light.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Abad de Hierro 铁僧 (`monk_iron`, élite, etapa 2) ✅

Reemplaza el recoloreo (guardado después como `monk_slate`, que ya tiene arte propio). Pelea sobre el Gran Campanario (celadón), por eso va en acero y naranja.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, slightly high camera angle looking down, close framing, transparent background: a broad, stocky iron-shirt monk, bare-chested with skin that has the polished sheen of bright steel reflecting the blue sky, a big confident grin, thick arms crossed in front of the chest, heavy iron rings stacked on both forearms, a necklace of large iron prayer beads, wide orange-tangerine trousers and sash knotted at the waist, small sparks bouncing off his chest as if a strike just hit him, rooted wide stance, tough and a little playful, very wide square silhouette readable at small size, clearly different from a masked violet monk.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright noon daylight, fully transparent background, palette of polished steel blue, silver and cobalt (#3E7BE0) with bold tangerine orange and a touch of gold (#E59A12) on the sparks, no violet, clean confident brush strokes, metallic highlights painted as flat white strokes, watercolor bleeds, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown, no photorealism, no text, no watermark.
```

### León de Jade 玉狮 (`lion_jade`, élite, etapa 2) ✅

Reemplaza el recoloreo (que queda guardado como `lion_celadon.png`). Jade lavanda para que no se pierda sobre el fondo celadón del campanario.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, three-quarter side view in mid-pounce, front paws raised and mouth open in a roar, transparent background: a temple guardian lion carved from translucent lavender jade, its curly mane made of carved spirals with thin gold inlay, a bright vermilion silk ribbon and a small bronze bell tied around its neck, a few hairline cracks glowing with soft golden light, small jade chips flying from the leap, dynamic and powerful, long diagonal silhouette readable at small size, clearly different from a stone lion and from a green jade statue.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, fully transparent background, palette of lavender and lilac jade (#9B5DE5) with ivory highlights, gold (#E59A12) inlay and a strong vermilion (#E8453C) ribbon, no green, glassy translucent washes, clean confident brush strokes, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown, no photorealism, no text, no watermark.
```

### Abad de la Gran Campana 钟师 (`monk_gold`, jefe, etapa 2) ✅

Reemplaza el recoloreo (guardado después como `monk_amber`, que ya tiene arte propio). No tiene que parecerse al Guardián de la Campana (viejo barbudo en azafrán) ni al Monje sin Rostro, y tiene que leerse sobre el Gran Campanario (celadón).

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game boss character, full body, facing the viewer, perfectly symmetrical frontal composition at eye level, transparent background: the abbot of the Great Bell, a strong middle-aged monk with a shaved head marked by nine small ordination dots, clean-shaven stern face with sharp focused eyes, standing in a wide firm horse stance with both palms pressed forward, wearing white inner robes and a bright cinnabar-red kasaya with a gold patchwork pattern across one shoulder, two medium polished golden temple bells floating at his left and right sides like shields, concentric rings of golden sound rippling outward from both bells, a long string of white prayer beads swinging in the air, disciplined and imposing, fills most of the frame, wide symmetrical silhouette readable at small size, clearly different from an old bearded abbot in saffron and from a faceless masked monk.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, fully transparent background, palette of pure white and cinnabar vermilion (#E8453C) with bright gold (#E59A12) bells and trims, no saffron, no green, no violet, clean confident brush strokes, flat shading with watercolor bleeds, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown, no photorealism, no text, no watermark.
```

### Guardián de la Campana 守钟人 (`bell_keeper`, élite, etapa 2) ✅

Este prompt se escribió para `monk_gold`, pero la imagen salió distinta y se usó para un élite nuevo. El arte propio del Abad de la Gran Campana queda pendiente, con un prompt que no se parezca a este.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game boss character, full body, facing the viewer, centered, transparent background: the old abbot
of the Hanging Monastery, a kind wrinkled face with a long white beard and calm closed eyes (a
clearly visible human face, not hooded, not faceless), saffron and gold layered robes with a
vermilion sash, standing firm with a heavy wooden bell striker held across his body, a huge
bronze temple bell with a thin crack floating behind him like a halo, three golden rings of sound
spreading out from the bell, falling golden leaves, wise, sad and powerful, fills most of the
frame, wide triangular silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, fully transparent
background, WARM palette dominated by saffron, gold (#E59A12) and bronze, accents of vermilion
(#E8453C) and a little jade (#1FA38A) on the bell patina, almost no blue or violet, clean confident
brush strokes, flat shading with watercolor bleeds, high readability on a small phone screen.
NOT dark, NOT gloomy, NOT grim, no black or brown, no photorealism, no text, no watermark.
```

### Simio de las Nieves (`monkey_snow`, común, etapa 3) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: a white snow ape with frosty fur, icy blue scarf, breath visible in the cold, wild playful crouch ready to pounce.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Gólem de Escarcha (`golem_ice`, común, etapa 3) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: a golem of packed snow and pale blue ice blocks, frost crystals growing on its shoulders, cold mist pouring from its fists.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Discípulo del Viento (`disciple_wind`, común, etapa 3) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: a lost disciple in sky-blue tattered robes whipping in the wind, snow on his shoulders, faded headband, one leg raised for a sweeping kick trailing frost.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Murciélago de Escarcha (`bat_frost`, común, etapa 3) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: a pale ice-blue bat spirit with frosted translucent wings, snowflakes trailing behind it, icicle fangs.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Dama del Viento 风扇 (`fan_wind`, élite, etapa 3) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: an elegant warrior woman in teal and white layered robes, a large white iron fan releasing a gust of snow, hair and sleeves blown by the wind.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### León de las Nieves 雪狮 (`lion_snow`, élite, etapa 3) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: a guardian lion of snow-white marble covered in frost and icicles, small ice spikes along its mane, red ribbon, roaring.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Dragón Dormido 卧龙 (`dragon_azure`, jefe final, etapa 3) ✅

Hoy es un recoloreo del Eco del Dragón; esta imagen lo reemplaza (y hay que sacar `dragon_azure` de `VARIANTS` en `tool/recolor_enemies.py`). No tiene que parecerse al Eco (dorado de nubes) ni al Sueño del Dragón (azul enroscado), y tiene que leerse sobre el Lecho del Dragón (turquesa y durazno).

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game boss character, full body, centered, transparent background, low-angle view from below: the Sleeping Dragon fully awake, rearing straight up in a tall vertical pose, chest forward, head at the top looking down at the viewer, a solid body of porcelain-white scales, a flowing mane, whiskers and fin crests of bright vermilion red, golden antler horns, exactly four large armored chest scales like polished white-jade discs with fine gold edges, front claws open at shoulder height holding a glowing frost pearl, the tail spiraling around the bottom of the frame, a few snowflakes and red petals drifting, majestic and final, fills the whole frame, tall narrow silhouette readable at small size, clearly different from a golden cloud dragon and from a blue coiled dragon.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, fully transparent background, palette of porcelain white and strong vermilion (#E8453C) with gold (#E59A12) horns and scale edges, a little ice blue only in the pearl, no turquoise, no peach, no violet, bold clean brush strokes, flat shading with watercolor bleeds, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown, no photorealism, no text, no watermark.
```

### Sueño del Dragón 龙梦 (`dragon_dream`, élite, etapa 3) ✅

Este prompt se escribió para `dragon_azure`, pero se usó para un élite nuevo. El arte propio del Dragón Dormido queda pendiente, con un prompt que no se parezca a este (ni al Eco).

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game boss character, full body, facing the viewer, centered, transparent background: an immense
azure Chinese dragon with a solid body (not made of clouds), coiled in a near-perfect circle like an
ensō brush ring, snow resting on its back and mane, slowly waking: one huge golden eye half open,
the other still closed, horns like clear ice crystals, a row of large frosted scales of pale blue
and silver across its chest and forearms like a natural breastplate, a calm cold mist breathing
out of its nostrils, small snowflakes floating around it, ancient, serene and majestic, fills most
of the frame, iconic round silhouette readable at small size, clearly different from a golden
cloud dragon.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, fully transparent
background, COOL palette dominated by cobalt blue (#3E7BE0), ice white and soft violet (#9B5DE5),
gold (#E59A12) only in the eye and the pearl-like scale edges, a single vermilion (#E8453C) touch
on the tip of the tongue, crisp brush strokes, flat shading with watercolor bleeds, high
readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown, no
photorealism, no text, no watermark.
```

### Tanda 3: mapas, fuentes y paso entre etapas

**Estado:** todo en el juego: los dos mapas, las dos fuentes y el paso entre etapas. El mapa y la fuente buscan su archivo por `stageId` y, si falta, usan el de la etapa 1 (`stageArt` en `widgets/scene_backdrop.dart`). El manantial, el paso entre etapas, la semilla y el cofre llevan paleta, luz y encuadre propios (no el bloque de estilo común) para que no se vean iguales a los demás.

#### Mapa del Monasterio Colgado (`xuankongsi/map_bg.png`) ✅

1080×4000 vertical, sin sendero propio (lo dibuja el código) y con el centro despejado.

```
Create ONE single image. Start immediately, without asking questions.

Create a very tall PORTRAIT image (1080×4000), fully opaque (no transparency).

Tall vertical map background, 1080x4000 pixels (aspect ratio 27:100, very tall and narrow), of the Hanging Monastery: red lacquered halls and wooden walkways
pinned to a sheer cliff face, rising level after level, bronze bells and prayer flags, thin
waterfalls and soft clouds drifting between the buildings, the bottom in warm saffron stone tones
shifting to bright gold and pale sky near a great bell tower at the top, lots of empty space
along the middle for UI nodes.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
background (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, calm and luminous mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no characters, no text, no watermark.
```

#### Mapa de la Cumbre del Dragón Dormido (`wolongding/map_bg.png`) ✅

1080×4000 vertical, sin sendero propio y con el centro despejado.

```
Create ONE single image. Start immediately, without asking questions.

Create a very tall PORTRAIT image (1080×4000), fully opaque (no transparency).

Tall vertical map background, 1080x4000 pixels (aspect ratio 27:100, very tall and narrow), of a snowy summit above the clouds: wind-carved snow ridges, ice
crystals and a few frosted pines at the bottom, a sea of pastel clouds in the middle, pale blue
sky turning pink and gold near the peak, where the huge calm coil of a sleeping azure dragon rests
half hidden in the clouds, lots of empty space along the middle for UI nodes.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
background (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, calm and luminous mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no characters, no text, no watermark.
```

#### Fuente del Monasterio (`xuankongsi/fountain_bg.png`) ✅

1080×1920 vertical, sin transparencia; centro despejado para la UI.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 9:16 aspect ratio (1080×1920), fully opaque (no transparency).

Vertical background, 1080x1920 pixels (aspect ratio 9:16), of a quiet tea terrace inside a cliffside monastery: a bamboo pipe pouring
clear water into a round stone basin, a low wooden table with a clay teapot and steaming cups,
red lacquered railings, hanging lanterns, a view of soft clouds below the cliff, warm saffron
afternoon light, the middle of the image calm and open for interface elements.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
background (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, calm and luminous mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no characters, no text, no watermark.
```

#### Manantial de la Cumbre (`wolongding/fountain_bg.png`) ✅

1080×1920 vertical, sin transparencia; centro despejado para la UI.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 9:16 aspect ratio (1080×1920), fully opaque (no transparency).

Vertical background, 1080x1920 pixels (aspect ratio 9:16), seen from INSIDE a small rock alcove looking out: a hot spring in the
foreground with turquoise water and thick warm steam rising in soft spirals, smooth rounded
stones dusted with snow framing the left and right edges, a few red plum blossoms on a bare
branch, outside the alcove a bright snowy slope in late afternoon light, the middle of the image
filled only with soft steam, calm and open for interface elements.
Style: intimate modern Chinese ink-and-watercolor illustration, WARM-AND-COOL contrast: turquoise
(#1FA38A) water and pale peach-pink steam, accents of plum red (#E8453C), very wet watercolor
bleeds, soft edges, cozy and restful mood, high readability on a small phone screen. NOT dark,
NOT gloomy, no black or brown backgrounds, no photorealism, no characters, no text, no watermark.
```

#### Paso entre etapas (`stage_clear_bg.png`) ✅

`assets/art/ui/stage_clear_bg.png`. 1080×1920 vertical, sin transparencia. Fondo de la pantalla de etapa superada: el hanzi y la Vida van encima, así que el centro tiene que quedar muy limpio.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 9:16 aspect ratio (1080×1920), fully opaque (no transparency).

Vertical background, 1080x1920 pixels (aspect ratio 9:16), extremely minimal composition: almost the whole image is empty glowing
sky in a vertical gradient from pale gold at the top to warm cream in the middle, at the very
bottom a single small red lacquered gate (paifang) on the last steps of a stone stairway seen
from below, a thin line of distant peaks and two tiny cranes flying high, huge negative space
in the center for large text.
Style: sparse traditional Chinese ink painting with a single watercolor wash, lots of untouched
rice paper (#F6EEDC), only gold (#E59A12) and one vermilion (#E8453C) accent, few confident
brush strokes, serene and triumphant mood. NOT dark, NOT busy, no clouds sea, no black or brown
backgrounds, no photorealism, no characters, no text, no watermark.
```

#### Semilla de loto (`ui/lotus_seed.png`) ✅

`assets/art/ui/lotus_seed.png`. 512×512 cuadrado, fondo transparente. Ícono de la moneda permanente: se ve a 16–40 px en el contador y a ~120 px en el botín, así que la silueta tiene que leerse chiquita. Paleta propia rosa loto y verde semilla, para no confundirse con el jade.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The game shrinks it to 512×512 and shows it at 16–120 pixels.

Single game currency icon, square 1:1, centered, transparent background: one open lotus seed pod
seen at a gentle three-quarter angle from above, a round flat-topped pod in fresh celadon green
with five plump seeds peeking out of its holes, two soft pink lotus petals curling around the
base like a cradle, one tiny dewdrop catching light. Chunky simple shape, thick clean outline,
bold readable silhouette even at 24 pixels, soft top-left morning light with a small warm
highlight, gentle rim glow.
Style: polished mobile game icon painted in Chinese watercolor, pastel pink (#F4A6B8) and lotus
rose (#E26D8F) petals, celadon (#9CCFA8) and fresh green (#4FAE6B) pod, tiny gold (#E59A12)
sparkle, cream highlights (#F6EEDC). Bright, cute and precious. NOT dark, no black outline
heavy shadows, no background, no frame, no text, no watermark, no photorealism.
```

#### Cofre del botín (`ui/reward_chest.png`) ✅

`assets/art/ui/reward_chest.png`. 1024×1024 cuadrado, fondo transparente. Se muestra a ~200 px y el juego lo hace temblar y abrirse con un destello, así que va cerrado y de frente. El centro de la tapa queda liso: el juego estampa encima el sello 赏.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Single treasure chest object, square 1:1, centered, transparent background: a small closed
Chinese lacquered treasure box seen straight from the front and slightly above, rounded
domed lid, glossy vermilion lacquer body with soft gold corner caps and a gold lotus-shaped
clasp at the front, thin gold cloud-pattern trim along the edges, the flat center of the lid
left plain and empty, a red silk tassel hanging from the clasp, a faint warm golden glow
leaking from the seam under the lid as if something precious waits inside. Compact chunky
proportions, clean bold silhouette, soft bright daylight from the top-left.
Style: polished mobile game prop painted in Chinese watercolor and ink, vermilion (#E8453C),
gold (#E59A12) and warm cream highlights (#F6EEDC), one small jade green (#1FA38A) gem on the
clasp, soft gradients, gentle watercolor bleeds, cheerful and premium. NOT dark, NOT wooden
brown, no black shadows, no background, no characters, no text or characters on the lid, no
watermark, no photorealism.
```

## 8. Enemigos de concepto nuevo

Para que la montaña no sea solo "el mismo animal en otro material": cada uno trae una familia nueva (teatro, bestia mítica, papel encantado) y una forma distinta de jugarle, con reglas que el motor ya tiene. Son archivos nuevos, no recoloreos.

### Ópera de las Mil Caras 变脸 (`opera_mask`, común, etapa 2) ✅

Regla: cada turno cambia de máscara y con ella la guardia (puño → palma → patada); enseña a variar el tipo de carta.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: a Sichuan opera face-changing performer in a dramatic mid-spin pose, a vivid painted opera mask (vermilion, gold and cobalt patterns) half-turning into a second mask of jade and violet, a tall pheasant-feather headdress, long flowing water sleeves swirling like ribbons, an embroidered silk costume with cloud patterns, one hand sweeping across the face.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue (#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

### Pixiu 貔貅 (`pixiu`, común, etapas 2 y 3) ✅

Regla: devora jade al golpear (sin escaparse) y tiene una escama de oro; vencerlo devuelve lo robado.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: a pixiu, the chubby winged lion-dragon of Chinese myth that devours treasure, round jade-green body with gold scales on its back and small curled wings, a single short horn, a huge happy grin with a jade coin between its teeth, a few gold coins and jade beads bouncing around it, crouched ready to pounce.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue (#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

### Bandada de Grullas de Papel 纸鹤 (`paper_crane`, común, etapa 1) ✅

Regla: sale en grupos de 2 o 3, poca vida y golpes altos rápidos; enseña a repartir el daño entre varios rivales.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: an enchanted origami crane folded from a large paper talisman, crisp folded paper planes, vermilion talisman brushstroke marks and a small gold seal on its wings, wings spread wide in a swooping attack, tiny paper scraps and a faint gold glow trailing behind it, sharp folded beak.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue (#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

### Espada Voladora 飞剑 (`flying_sword`, común, etapa 3) ✅

Regla prevista: poca Vida, tres tajos altos seguidos y el último interrumpe la forma; enseña a cerrar formas antes de que llegue.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: an enchanted flying jian sword that moves on its own, a long bright silver blade with a jade-green hilt and a gold guard shaped like clouds, a long vermilion tassel and silk ribbons streaming behind it, three faint ghost-image copies of the blade fanning out to show its speed, a swirl of wind and snowflakes around it, diagonal dynamic pose pointing toward the viewer.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue (#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

### Buey de Madera 木牛 (`wooden_ox`, común, etapa 3) ✅

Regla prevista: autómata mohista; carga dos veces y después pisa bajo con cuenta regresiva; enseña a leer el golpe anunciado.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: a Mohist wooden ox automaton, a sturdy ox built from pale lacquered wooden planks, brass gears and pegs visible at the joints, a small spinning brass wheel in its chest, painted cobalt and vermilion cloud patterns on its sides, snow on its back, steam puffing from its nostrils, lowering its head and horns ready to charge, one front hoof raised.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue (#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

### Qilin 麒麟 (`qilin`, élite, etapa 3) ✅

Regla prevista: paso de nube; frena las patadas y desvía el primer golpe de cada turno, y desequilibrarlo le quita las dos defensas.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: a majestic qilin, the benevolent unicorn beast of Chinese myth, deer-like body covered in shimmering jade-green and gold scales, a flowing white and vermilion mane like flames, a single elegant antler-like horn, hooves walking on small swirling clouds instead of the ground, soft gold fire curling around its legs, proud rearing pose.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue (#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

### Zorro de Nueve Colas 九尾狐 (`nine_tail_fox`, élite, etapa 2) ✅

Regla prevista: ilusiones; cada dos turnos te hace descartar y su guardia cambia de lado; desequilibrarlo rompe la ilusión.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: an elegant nine-tailed fox spirit, sleek snow-white fur with soft violet and gold gradients at the tips, nine large flowing tails fanned out behind it like a peacock display, each tail ending in a small floating blue foxfire flame, a gold and vermilion ornament on its forehead, sly playful smile, one paw raised, faint mirror-image afterimages of the fox on both sides showing its illusions.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue (#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

### Títere de Sombras 皮影 (`shadow_puppet`, común, etapa 2) ✅

Regla prevista: teatro de linterna; copia la altura de tu último golpe y se cubre ahí.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: a Chinese shadow-puppet warrior come to life, a flat jointed figure made of translucent painted leather in vermilion, jade and gold, intricate cut-out lace patterns on its armor, thin bamboo rods attached to its hands and head, a warm lantern glow shining through its body, mid-swing pose with a painted sword, a few loose paper cut-out sparks around it.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue (#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

### Músico del Guqin 古琴 (`guqin_player`, común, etapa 3) ✅

Regla: tres notas altas seguidas, una disonancia que hace descartar y un acorde medio que congela. Aparece en los pisos 3, 5 y 7 de la etapa 3.

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: a serene mountain hermit musician seated on a floating cloud, playing a long guqin zither across his lap, long white beard and topknot, flowing cobalt and cream robes with snowflake embroidery, visible jade-green and gold musical sound ripples rising from the strings like waves, one hand plucking a string with a confident smile.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue (#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

## 9. Tanda de pulido: efectos y pantallas ✅

Ninguna es recoloreo. Los efectos (`vfx/`) son una sola imagen cada uno: la animación (escala, giro, fundido) la hace
el código (`ArtBurst` en `juice.dart`), así no se suman hojas de cuadros y el peso queda bajo (se achican a 640×640 en
`optimize_art.py`). Dónde se ven: tinta en cada golpe al rival, escudo cuando el rival se cubre, porcelana al
desequilibrarlo, remolino al recuperar aliento o vida, pétalos al vencer a un rival y en el triunfo final. El rollo se
recorta en varillas y papel (`lore_scroll.dart`); el epílogo se ve dentro de su rollo; los fondos, en el menú, los
eventos y el triunfo.

| Archivo | Tamaño | Para qué |
|---|---|---|
| `assets/art/vfx/hit_ink.png` | 1024×1024, transparente | salpicadura de tinta al golpear |
| `assets/art/vfx/guard_shield.png` | 1024×1024, transparente | escudo de jade al tener guardia |
| `assets/art/vfx/break_shatter.png` | 1024×1024, transparente | porcelana rota con oro al desequilibrar |
| `assets/art/vfx/qi_swirl.png` | 1024×1024, transparente | remolino de aliento (qi) |
| `assets/art/vfx/lotus_petals.png` | 1024×1024, transparente | pétalos al vencer a un rival y en el triunfo |
| `assets/art/ui/title_bg.png` | 1080×1920 | fondo del menú principal |
| `assets/art/ui/lore_scroll.png` | 1024×1536, transparente | rollo abierto para leer los pergaminos |
| `assets/art/ui/event_bg.png` | 1080×1920 | fondo de los eventos del camino |
| `assets/art/ui/victory_bg.png` | 1080×1920 | fondo del triunfo final |
| `assets/art/ui/epilogue_bg.png` | 1080×1920 | ilustración del epílogo (el maestro entrega el pincel) |

#### Golpe de tinta (`vfx/hit_ink.png`) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

A single explosive impact splash of vermilion and gold ink radiating outward from the center like a starburst, energetic brush flicks and small droplets, a bright cream-white core, symmetric enough to rotate, empty margins around it, no characters.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper cream tones (#F6EEDC) on the figure only, fully transparent background (real transparent PNG, no checkerboard, no paper behind the subject), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue (#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

#### Escudo de guardia (`vfx/guard_shield.png`) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

A round protective shield of translucent jade-green energy, like polished jade glass, with a delicate gold lotus-and-cloud pattern engraved on it and a soft glowing rim, seen straight from the front, centered, semi-transparent inside, no characters.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper cream tones (#F6EEDC) on the figure only, fully transparent background (real transparent PNG, no checkerboard, no paper behind the subject), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue (#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

#### Porcelana rota (`vfx/break_shatter.png`) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

A burst of shattering celadon porcelain shards flying outward from the center, the cracks filled with shining gold (kintsugi style), small gold sparks between the pieces, front view, centered, no characters.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper cream tones (#F6EEDC) on the figure only, fully transparent background (real transparent PNG, no checkerboard, no paper behind the subject), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue (#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

#### Remolino de aliento (`vfx/qi_swirl.png`) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

A spiral swirl of flowing qi energy made of soft cobalt-blue and jade-green brush ribbons and tiny glowing gold particles, like breath turning into wind, circular and centered so it can spin seamlessly, no characters.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper cream tones (#F6EEDC) on the figure only, fully transparent background (real transparent PNG, no checkerboard, no paper behind the subject), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue (#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

#### Pétalos de loto (`vfx/lotus_petals.png`) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

A gentle burst of pink-and-cream lotus petals and a few small gold sparkles scattering outward from the center, light and airy, each petal clearly separated, centered, no characters.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper cream tones (#F6EEDC) on the figure only, fully transparent background (real transparent PNG, no checkerboard, no paper behind the subject), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue (#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

#### Rollo de lectura (`ui/lore_scroll.png`) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole object is visible and centered, nothing cropped, with empty margins around it.

An unrolled ancient Chinese paper scroll seen straight from the front, vertical, with carved red-lacquered wooden rollers and gold end caps at top and bottom, the paper blank warm cream with faint watercolor texture and a thin vermilion border, completely empty inside (text is added later), no characters.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper cream tones (#F6EEDC) on the figure only, fully transparent background (real transparent PNG, no checkerboard, no paper behind the subject), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue (#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

#### Fondo del menú principal (`ui/title_bg.png`) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 9:16 aspect ratio (1080×1920), fully opaque (no transparency).

Epic main-menu background of misty Chinese mountains at sunrise, layered jade peaks fading into cream mist, a long cobalt-and-gold cloud dragon curling softly across the sky at the top, a tiny red temple on a far peak, warm golden light. Keep the center and lower half calm and empty (a hero character and buttons go there), no people.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper cream (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue (#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft gradients, clean confident brush strokes, flat shading with watercolor bleeds, joyful and premium mood, very readable on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

#### Fondo de eventos (`ui/event_bg.png`) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 9:16 aspect ratio (1080×1920), fully opaque (no transparency).

A peaceful roadside rest stop on a mountain path, a small wooden pavilion with a red roof and paper lanterns, a stone path, a pine tree, a teapot steaming on a stone table, soft afternoon light and floating petals. Keep the middle area soft and uncluttered (text panels go on top), no people.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper cream (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue (#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft gradients, clean confident brush strokes, flat shading with watercolor bleeds, joyful and premium mood, very readable on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

#### Fondo del triunfo final (`ui/victory_bg.png`) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 9:16 aspect ratio (1080×1920), fully opaque (no transparency).

Triumphant summit at golden sunrise above a sea of clouds, red prayer flags and golden ribbons fluttering, rays of light bursting from behind the peak, a small stone platform at the top, celebratory sparkles and drifting lotus petals. Keep the center open for a hero and a title, no people.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper cream (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue (#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft gradients, clean confident brush strokes, flat shading with watercolor bleeds, joyful and premium mood, very readable on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

#### Ilustración del epílogo (`ui/epilogue_bg.png`) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 9:16 aspect ratio (1080×1920), fully opaque (no transparency).

Story illustration of a wise old master with a long white beard and flowing cream-and-jade robes handing a large calligraphy brush to a young disciple seen from behind, both standing on a mountain summit at sunrise, the soft translucent shape of a friendly cobalt-and-gold dragon formed by clouds watching over them, warm hopeful mood, gold light.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper cream (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue (#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft gradients, clean confident brush strokes, flat shading with watercolor bleeds, joyful and premium mood, very readable on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

## 10. Armas — `assets/art/weapons/` ✅

Las 3 están integradas. Ninguna es recoloreo; si falta una, el juego la dibuja por código. Cada imagen va en la mano del héroe y en la elección del arma; vertical, con la punta arriba y **sin borla** (la borla, del color del nivel, la pone el juego). Al integrar se recortan los márgenes transparentes a una caja 1:3 y se ajusta el punto de agarre en `lib/delivery/widgets/weapon_art.dart` (`weaponShapes`).

### 1. `weapons/gun.png` — Bastón 棍 ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Game item sprite: a single weapon standing perfectly VERTICAL and centered, tip pointing straight UP, seen flat from the side, filling the full height of the image from top to bottom with only a thin empty margin. No hand, no person, no stand, no tassel, no ribbon, no shadow on the ground (the tassel is added by the game).

The weapon: a Chinese long staff (gùn), a straight round pole of polished ash wood lacquered warm vermilion-brown, slightly thicker at the bottom, with a gold metal cap ring at each end and two thin gold rings around the middle, simple and elegant. Layout: the grip area is the middle of the staff.

Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue (#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean confident brush strokes, flat shading with watercolor bleeds, high readability on a small phone screen. NOT dark, NOT gloomy, no black or brown backgrounds, no photorealism, no text, no watermark.
```

### 2. `weapons/jian.png` — Espada 剑 ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Game item sprite: a single weapon standing perfectly VERTICAL and centered, tip pointing straight UP, seen flat from the side, filling the full height of the image from top to bottom with only a thin empty margin. No hand, no person, no stand, no tassel, no ribbon, no shadow on the ground (the tassel is added by the game).

The weapon: a Chinese straight double-edged sword (jiàn), a slim bright steel blade with a fine central ridge and a pointed tip taking the top 60% of the height, a small gold cloud-shaped crossguard, a grip wrapped in dark cord with vermilion diamond wrapping, and a round gold pommel at the bottom. Layout: the guard sits at about 62% of the height from the top and the pommel near the bottom.

Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue (#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean confident brush strokes, flat shading with watercolor bleeds, high readability on a small phone screen. NOT dark, NOT gloomy, no black or brown backgrounds, no photorealism, no text, no watermark.
```

### 3. `weapons/pudao.png` — Pudao 朴刀 ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Game item sprite: a single weapon standing perfectly VERTICAL and centered, tip pointing straight UP, seen flat from the side, filling the full height of the image from top to bottom with only a thin empty margin. No hand, no person, no stand, no tassel, no ribbon, no shadow on the ground (the tassel is added by the game).

The weapon: a Chinese pudao, a long two-handed saber: a broad, single-edged curved steel blade on top (straight back on the left, curved cutting edge bulging to the right, rising to a point) taking the top 40% of the height, a gold collar where blade meets handle, then a long straight lacquered vermilion-brown wooden handle with a small gold end cap at the bottom. Layout: the blade takes the top 40% of the height and the long handle the rest.

Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue (#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean confident brush strokes, flat shading with watercolor bleeds, high readability on a small phone screen. NOT dark, NOT gloomy, no black or brown backgrounds, no photorealism, no text, no watermark.
```

---

## 11. Cadenas de postura y monjes propios ✅

Las 6 cartas de cadena (las de «desde una postura»): la figura en la postura nueva y un fantasma pálido de la anterior detrás.

Los 2 enemigos (7 y 8) reemplazaron los recoloreos del monje `monk_amber` y `monk_slate`; ya no están en `VARIANTS` de `tool/recolor_enemies.py`. Integrados el 06/11/2026.

### 1. `ma_zhuan_gong.png` — Del caballo al arco 马转弓 (Puño) · `assets/art/cards/` ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure inside the frame, clear silhouette readable at small size.
The move: a stance change into a strike: the hero pivots out of a wide low horse stance into a long forward bow stance (front knee bent, back leg straight) and drives a straight punch forward at chest height with a closed fist, the other fist pulled back at the hip. A faint pale afterimage of the previous horse stance (feet wide, knees bent, fists at the hips) stays behind the figure.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every visible hand has five fingers with normal joints, drawn in a simple readable shape (a closed fist or a flat open palm with the fingers together and the thumb visible); both hands are fully visible, apart from the body and from each other, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; both legs are drawn complete with both feet visible; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs. The faint afterimage is clearly a pale ghost of the same pose, behind the figure, never a second solid person.
A curved vermilion (#E8453C) ink brush trail sweeps from the afterimage into the punching fist, showing the turn of the hips, with a small burst of vermilion ink at the knuckles.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

### 2. `gong_zhuan_xu.png` — Del arco al paso vacío 弓转虚 (Patada) · `assets/art/cards/` ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure inside the frame, clear silhouette readable at small size.
The move: a stance change into a kick: the hero shifts back out of a long bow stance into a light empty stance and snaps a low front kick with the front foot at shin height, toes pointed, while both open palms guard in front of the chest. A faint pale afterimage of the previous bow stance (front knee bent, back leg straight) stays behind the figure.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every visible hand has five fingers with normal joints, drawn in a simple readable shape (a closed fist or a flat open palm with the fingers together and the thumb visible); both hands are fully visible, apart from the body and from each other, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; both legs are drawn complete with both feet visible; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs. The faint afterimage is clearly a pale ghost of the same pose, behind the figure, never a second solid person.
A curved gold (#E59A12) ink brush trail follows the kicking foot from the afterimage, with a small gold splash at the toes.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

### 3. `xu_zhuan_ma.png` — Del vacío al caballo 虚转马 (Palma) · `assets/art/cards/` ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure inside the frame, clear silhouette readable at small size.
The move: a stance change into a palm strike: the hero sinks out of a light empty stance into a wide low horse stance and pushes one open palm straight forward at chest height, fingers up, the other palm held in front of the belly. A faint pale afterimage of the previous empty stance (weight on the back leg, front toes lightly touching the ground) stays behind the figure.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every visible hand has five fingers with normal joints, drawn in a simple readable shape (a closed fist or a flat open palm with the fingers together and the thumb visible); both hands are fully visible, apart from the body and from each other, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; both legs are drawn complete with both feet visible; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs. The faint afterimage is clearly a pale ghost of the same pose, behind the figure, never a second solid person.
A violet (#9B5DE5) ink brush trail flows down from the afterimage into the rooted feet and out through the pushing palm, ending in a soft violet ripple in front of the palm.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

### 4. `hu_hui_shen.png` — El tigre se da vuelta 虎回身 (Palma) · `assets/art/cards/` ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure inside the frame, clear silhouette readable at small size.
The move: a powerful turning palm strike: the hero spins around out of a bow stance, landing in a wide low horse stance, and slams a heavy open palm sideways at chest height like a tiger's paw, fingers slightly curled and the thumb visible, the other hand guarding near the face. A faint pale afterimage of the previous bow stance stays behind the figure, showing the turn.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every visible hand has five fingers with normal joints, drawn in a simple readable shape (a closed fist or a flat open palm with the fingers together and the thumb visible); both hands are fully visible, apart from the body and from each other, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; both legs are drawn complete with both feet visible; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs. The faint afterimage is clearly a pale ghost of the same pose, behind the figure, never a second solid person.
A separate translucent violet (#9B5DE5) ink tiger spirit turns its head and swipes a paw beside the palm, never touching or hiding the hands, with a curved violet brush trail tracing the spin around the hero.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

### 5. `she_zhuan_shen.png` — La serpiente gira 蛇转身 (Palma) · `assets/art/cards/` ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure inside the frame, clear silhouette readable at small size.
The move: a quick light turning palm: the hero twists the waist out of an empty stance into a forward bow stance, the lead hand darting forward as an open palm with fingers together at throat height, the rear palm close to the chest. A faint pale afterimage of the previous empty stance stays behind the figure.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every visible hand has five fingers with normal joints, drawn in a simple readable shape (a closed fist or a flat open palm with the fingers together and the thumb visible); both hands are fully visible, apart from the body and from each other, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; both legs are drawn complete with both feet visible; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs. The faint afterimage is clearly a pale ghost of the same pose, behind the figure, never a second solid person.
The arms are human arms in sleeves, never a snake. A separate translucent violet (#9B5DE5) ink snake spirit coils once around the hero's path on the ground and rises beside the darting palm, never wrapping or hiding the hands, with a thin spiral violet brush trail showing the twist.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

### 6. `he_luo_di.png` — La grulla se posa 鹤落地 (Patada) · `assets/art/cards/` ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure inside the frame, clear silhouette readable at small size.
The move: landing from a crane stance into a low kick: the hero comes down from standing on one leg into a wide low horse stance and sweeps a low side kick with the landing foot at knee height, both arms open to the sides at shoulder height with open palms, elbows soft. A faint pale afterimage of the previous one-legged crane pose (one knee raised) stays behind the figure; both legs of the hero are drawn complete.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every visible hand has five fingers with normal joints, drawn in a simple readable shape (a closed fist or a flat open palm with the fingers together and the thumb visible); both hands are fully visible, apart from the body and from each other, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; both legs are drawn complete with both feet visible; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs. The faint afterimage is clearly a pale ghost of the same pose, behind the figure, never a second solid person.
The arms are human arms in sleeves, never wings, with no feathers growing from them. A separate translucent gold (#E59A12) ink crane spirit settles its wings above the hero, plus a few loose white feathers drifting down, never touching or hiding the hands.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

### 7. `monk_amber.png` — Monje del Incienso (`incense_monk`, común, etapa 2) — reemplaza un recoloreo del monje · `assets/art/enemies/` ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: a round cheerful temple monk with a shaved head and a calm half-smile, saffron and amber robes with a gold sash, holding a large bronze incense burner on a short chain in one hand, the other hand raised in a blessing with an open palm, thick ribbons of jade-green and gold incense smoke curling around him in spirals, a few glowing embers floating, sturdy stance with sandals visible. Clearly a different character from a plain fighting monk: the incense burner and the swirling smoke are the main shapes.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue (#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

### 8. `monk_slate.png` — Ermitaño de Pizarra (`slate_hermit`, común, etapa 3) — reemplaza un recoloreo del monje · `assets/art/enemies/` ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536, not square, not landscape), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background). The whole figure is visible and centered, nothing cropped, with empty margins around it.

Game enemy character, full body, facing the viewer, centered, transparent background: a tall lean mountain hermit whose skin is partly turned to smooth blue-grey slate stone, with cracked stone plates on the shoulders, forearms and shins and small tufts of jade moss and tiny white mountain flowers growing from the cracks, long white eyebrows and a stern but kind face, cobalt and cream patched robes, a walking staff of twisted pine in one hand, the other hand forward with an open palm, small sharp stone shards floating around him like a protective ring. Clearly a different character from a plain monk: the stone skin and floating shards are the main shapes.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue (#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood, high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown backgrounds, no photorealism, no text, no watermark.
```

## 12. Cartas de arma ✅

Las 12 ilustraciones de las cartas de Bastón, Espada y Pudao. Integradas el 06/11/2026.


> Cada arma suma 4 cartas a la baraja. El héroe sostiene la misma arma que ya está en `assets/art/weapons/` (que sirve de referencia: podés adjuntarla en ChatGPT). Las armas largas tientan a ChatGPT a fundir manos con el mango o duplicar el arma: cada prompt pide una sola arma, completa, y las manos cerradas alrededor del mango con los dedos visibles. Si sale mal, en la misma conversación pedí: *«Same image, fix only the hands and the weapon: one single weapon, five fingers on each hand wrapped around the handle»*.

### Bastón 棍

#### 6. `cards/gun_sao.png` — Barrido bajo 扫棍 (Palma) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu weapon move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure and the whole weapon inside the frame, clear silhouette readable at small size.
The weapon: a Chinese long staff (gùn) taller than the hero: a straight round pole of polished wood lacquered warm vermilion-brown, with a gold cap ring at each end and two thin gold rings around the middle. Exactly ONE weapon, drawn complete from end to end, straight and rigid, never bent, never duplicated.
The move: a low sweeping strike: crouched deep in a wide low stance, both hands on the staff, swinging it flat just above the ground at ankle height.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every hand holding the weapon has its fingers wrapped around the handle with the knuckles and thumb visible, and any free hand has five fingers in a simple readable shape; hands never merge with the handle, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The energy: a long flat ink arc skimming along the ground under the staff, with a few small dust puffs, painted in translucent violet ink (#9B5DE5); it never covers the hands or the face.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

#### 7. `cards/gun_ge.png` — Palo que cruza 格棍 (Defensa) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu weapon move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure and the whole weapon inside the frame, clear silhouette readable at small size.
The weapon: a Chinese long staff (gùn) taller than the hero: a straight round pole of polished wood lacquered warm vermilion-brown, with a gold cap ring at each end and two thin gold rings around the middle. Exactly ONE weapon, drawn complete from end to end, straight and rigid, never bent, never duplicated.
The move: a low block: knees bent, the staff held diagonally across the front of the shins with both hands spread wide on it, stopping a blow below.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every hand holding the weapon has its fingers wrapped around the handle with the knuckles and thumb visible, and any free hand has five fingers in a simple readable shape; hands never merge with the handle, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The energy: a round ink ripple bursting from the point where the staff blocks, like a gong being struck, painted in translucent cobalt blue ink (#3E7BE0); it never covers the hands or the face.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

#### 8. `cards/gun_tiao.png` — Palo que levanta 挑棍 (Palma) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu weapon move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure and the whole weapon inside the frame, clear silhouette readable at small size.
The weapon: a Chinese long staff (gùn) taller than the hero: a straight round pole of polished wood lacquered warm vermilion-brown, with a gold cap ring at each end and two thin gold rings around the middle. Exactly ONE weapon, drawn complete from end to end, straight and rigid, never bent, never duplicated.
The move: a rising flick: stepping forward, the back hand low near the hip drives the staff tip up from the ground to head height in one upward stroke.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every hand holding the weapon has its fingers wrapped around the handle with the knuckles and thumb visible, and any free hand has five fingers in a simple readable shape; hands never merge with the handle, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The energy: a curved ink stroke rising from the ground along the path of the staff tip, painted in translucent violet ink (#9B5DE5); it never covers the hands or the face.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

#### 9. `cards/gun_wuhua.png` — Molinete del palo 舞花棍 (Palma) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu weapon move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure and the whole weapon inside the frame, clear silhouette readable at small size.
The weapon: a Chinese long staff (gùn) taller than the hero: a straight round pole of polished wood lacquered warm vermilion-brown, with a gold cap ring at each end and two thin gold rings around the middle. Exactly ONE weapon, drawn complete from end to end, straight and rigid, never bent, never duplicated.
The move: a staff flourish: standing upright, the staff spinning in a figure-eight beside the body, held lightly in both hands at its middle.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every hand holding the weapon has its fingers wrapped around the handle with the knuckles and thumb visible, and any free hand has five fingers in a simple readable shape; hands never merge with the handle, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The energy: two overlapping ink circles blurred around the spinning staff, like the petals of a flower, painted in translucent violet ink (#9B5DE5); it never covers the hands or the face.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

### Espada 剑

#### 10. `cards/jian_ci.png` — Estocada 刺剑 (Puño) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu weapon move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure and the whole weapon inside the frame, clear silhouette readable at small size.
The weapon: a Chinese straight double-edged sword (jiàn): a slim bright steel blade with a fine central ridge and pointed tip, a small gold cloud-shaped crossguard, a grip wrapped in dark cord with vermilion diamond wrapping, and a round gold pommel, no tassel. Exactly ONE weapon, drawn complete from end to end, straight and rigid, never bent, never duplicated.
The move: a straight lunging thrust: front knee bent deep, back leg straight, the sword arm extended level at chest height, the free hand in sword-fingers (index and middle finger together, pointing up) raised behind the head.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every hand holding the weapon has its fingers wrapped around the handle with the knuckles and thumb visible, and any free hand has five fingers in a simple readable shape; hands never merge with the handle, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The energy: a sharp straight ink streak shooting forward from the sword tip, painted in translucent vermilion ink (#E8453C); it never covers the hands or the face.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

#### 11. `cards/jian_dian.png` — Punta que pica 点剑 (Puño) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu weapon move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure and the whole weapon inside the frame, clear silhouette readable at small size.
The weapon: a Chinese straight double-edged sword (jiàn): a slim bright steel blade with a fine central ridge and pointed tip, a small gold cloud-shaped crossguard, a grip wrapped in dark cord with vermilion diamond wrapping, and a round gold pommel, no tassel. Exactly ONE weapon, drawn complete from end to end, straight and rigid, never bent, never duplicated.
The move: a quick light tap: standing tall and relaxed, the wrist snapping the sword tip down in a small pecking motion, the free hand in sword-fingers at the side.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every hand holding the weapon has its fingers wrapped around the handle with the knuckles and thumb visible, and any free hand has five fingers in a simple readable shape; hands never merge with the handle, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The energy: three small ink sparks popping where the tip pecks, light and quick, painted in translucent vermilion ink (#E8453C); it never covers the hands or the face.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

#### 12. `cards/jian_jie.png` — Corte que intercepta 截剑 (Defensa) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu weapon move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure and the whole weapon inside the frame, clear silhouette readable at small size.
The weapon: a Chinese straight double-edged sword (jiàn): a slim bright steel blade with a fine central ridge and pointed tip, a small gold cloud-shaped crossguard, a grip wrapped in dark cord with vermilion diamond wrapping, and a round gold pommel, no tassel. Exactly ONE weapon, drawn complete from end to end, straight and rigid, never bent, never duplicated.
The move: an intercepting cut: turned sideways, the sword held vertical at chest level with the edge outward to cut off an incoming strike, the free hand open at the wrist of the sword hand.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every hand holding the weapon has its fingers wrapped around the handle with the knuckles and thumb visible, and any free hand has five fingers in a simple readable shape; hands never merge with the handle, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The energy: a crisp ink ring flashing at the edge of the blade where the strike is stopped, painted in translucent cobalt blue ink (#3E7BE0); it never covers the hands or the face.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

#### 13. `cards/jian_chuanxin.png` — Espada que atraviesa 穿心剑 (Puño) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu weapon move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure and the whole weapon inside the frame, clear silhouette readable at small size.
The weapon: a Chinese straight double-edged sword (jiàn): a slim bright steel blade with a fine central ridge and pointed tip, a small gold cloud-shaped crossguard, a grip wrapped in dark cord with vermilion diamond wrapping, and a round gold pommel, no tassel. Exactly ONE weapon, drawn complete from end to end, straight and rigid, never bent, never duplicated.
The move: a deep flying lunge: the whole body stretched in one straight line behind the sword, back foot just leaving the ground, the free hand reaching back in sword-fingers.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every hand holding the weapon has its fingers wrapped around the handle with the knuckles and thumb visible, and any free hand has five fingers in a simple readable shape; hands never merge with the handle, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The energy: a long piercing ink streak passing straight through a small ink ring ahead of the tip, painted in translucent vermilion ink (#E8453C); it never covers the hands or the face.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

### Pudao 朴刀

#### 14. `cards/pudao_pi.png` — Tajo que parte 劈刀 (Palma) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu weapon move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure and the whole weapon inside the frame, clear silhouette readable at small size.
The weapon: a Chinese pudao, a long two-handed saber: a broad single-edged curved steel blade, a gold collar where blade meets handle, and a long straight lacquered vermilion-brown wooden handle with a small gold end cap, no tassel. Exactly ONE weapon, drawn complete from end to end, straight and rigid, never bent, never duplicated.
The move: an overhead downward chop: both hands on the long handle, the blade coming down from above the head to the bottom of the arc in front, knees bent into the cut.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every hand holding the weapon has its fingers wrapped around the handle with the knuckles and thumb visible, and any free hand has five fingers in a simple readable shape; hands never merge with the handle, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The energy: a tall ink crescent tracing the downward path of the blade, painted in translucent violet ink (#9B5DE5); it never covers the hands or the face.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

#### 15. `cards/pudao_lan.png` — Hoja que ataja 拦刀 (Defensa) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu weapon move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure and the whole weapon inside the frame, clear silhouette readable at small size.
The weapon: a Chinese pudao, a long two-handed saber: a broad single-edged curved steel blade, a gold collar where blade meets handle, and a long straight lacquered vermilion-brown wooden handle with a small gold end cap, no tassel. Exactly ONE weapon, drawn complete from end to end, straight and rigid, never bent, never duplicated.
The move: a high block: the pudao held horizontally above the head with both hands far apart on the handle, the blade flat to stop a blow from above.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every hand holding the weapon has its fingers wrapped around the handle with the knuckles and thumb visible, and any free hand has five fingers in a simple readable shape; hands never merge with the handle, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The energy: a broad ink shimmer spreading along the raised blade like a shield, painted in translucent cobalt blue ink (#3E7BE0); it never covers the hands or the face.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

#### 16. `cards/pudao_kan.png` — Hachazo de pudao 砍刀 (Patada) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu weapon move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure and the whole weapon inside the frame, clear silhouette readable at small size.
The weapon: a Chinese pudao, a long two-handed saber: a broad single-edged curved steel blade, a gold collar where blade meets handle, and a long straight lacquered vermilion-brown wooden handle with a small gold end cap, no tassel. Exactly ONE weapon, drawn complete from end to end, straight and rigid, never bent, never duplicated.
The move: a huge diagonal hacking swing: the whole body turning from the hips, both hands on the handle, the blade cutting down diagonally across the front.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every hand holding the weapon has its fingers wrapped around the handle with the knuckles and thumb visible, and any free hand has five fingers in a simple readable shape; hands never merge with the handle, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The energy: a wide ink crescent along the swing, with a few broken pieces of an ink shield flying apart in front of the blade, painted in translucent gold ink (#E59A12); it never covers the hands or the face.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

#### 17. `cards/pudao_chantou.png` — Hoja que envuelve la cabeza 缠头刀 (Palma) ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024), PNG with a fully transparent background (real alpha channel, no white, paper or checkerboard background).

Small square illustration of a kung fu weapon move on a transparent background. The hero: one young martial artist with long wild brown hair tied with a red ribbon, cream robe with jade and vermilion sashes, deep blue trousers with gold cloud patterns, gold wrist guards. Full body, three-quarter side view, the whole figure and the whole weapon inside the frame, clear silhouette readable at small size.
The weapon: a Chinese pudao, a long two-handed saber: a broad single-edged curved steel blade, a gold collar where blade meets handle, and a long straight lacquered vermilion-brown wooden handle with a small gold end cap, no tassel. Exactly ONE weapon, drawn complete from end to end, straight and rigid, never bent, never duplicated.
The move: the head-wrapping cut: the blade circling around the head and behind the shoulders, held in both hands, about to come out the other side.
ANATOMY (most important, check it before finishing): exactly one person with two arms, two legs and two hands; every hand holding the weapon has its fingers wrapped around the handle with the knuckles and thumb visible, and any free hand has five fingers in a simple readable shape; hands never merge with the handle, never hidden behind the torso, never crossed or tangled; arms and legs keep normal human length and bend only at shoulders, elbows, wrists, hips and knees; the torso stays upright and the head turns with the shoulders, no twisted neck or spine; no extra, missing, merged or rubbery boneless limbs.
The energy: a full ink ring circling the head along the path of the blade, painted in translucent violet ink (#9B5DE5); it never covers the hands or the face.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark, no deformed hands, no extra fingers, no extra limbs.
```

---

## Pendiente

- Los nombres de cueva ya se cambiaron por nombres de montaña: Murciélago de Jade, Salamandra de Brasa y Gólem de Cuarzo.
