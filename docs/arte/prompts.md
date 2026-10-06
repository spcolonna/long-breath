# Prompts de arte

Prompts para generar la identidad visual de Long Breath. **Cada bloque es un prompt completo** (con el estilo y la paleta ya incluidos): se copia entero con el botón del bloque y se pega en el generador. Sirven para cualquier generador (Midjourney, DALL·E, Imagen, SD). Están en inglés porque los generadores responden mejor así.

**Regla general:** nada de fondos negros, marrones ni "versión dark". Es una pintura china vista a plena luz: papel claro, color saturado y mucho aire.

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

## 0. Prioridad MVP (lo que el juego ya sabe usar)

Son las dos imágenes que el código ya busca. Si no existen, se usa una silueta dibujada y un degradado.

### Enemigo genérico

**Destino:** `assets/art/enemies/placeholder.png`, vertical 2:3 (1024×1536) con fondo transparente.

Se usa para todos los enemigos hasta que cada uno tenga su imagen (`assets/art/enemies/<id>.png`). El juego le agrega un aura del color del rango (jade común, violeta élite, bermellón jefe), por eso la figura usa colores neutros.

```
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

### Fondo de arena de combate

**Destino:** `assets/art/stages/qianyunshan/combat_bg.png`, vertical 6:7 (1200×1400). Ocupa la mitad superior de la pantalla y se recorta para cubrirla, así que lo importante va en el centro. El enemigo se para en el centro-derecha, a unos 3/4 de la altura; el héroe tapa la esquina inferior izquierda.

```
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

### Muñeco de madera (tutorial)

**Destino:** `assets/art/enemies/dummy.png`, 2:3 y transparente. Ya integrado.

```
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

### Héroe

**Fuente:** `assets/art/player/hero.png`, 2:3 y transparente, de espaldas mirando hacia el enemigo. Ropa bermellón para que el recoloreo funcione. Después de cambiarla hay que correr `python3 tool/recolor_hero.py`, que genera `hero_novice.png` (lino crudo, antes del santuario), `hero_tiger.png`, `hero_snake.png` y `hero_crane.png`.

```
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

**Destino:** `assets/art/ui/home_bg.png`, vertical 9:19.5, con espacio libre en el centro para el logo.

```
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

**Logo:** `assets/art/ui/logo.png`, cuadrado y transparente.

```
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

Fondo del mapa (`map_bg.png`, opcional, **1080×4000**, vertical, se dibuja al 85% sobre las capas pintadas). Que no tenga sendero ni escalones propios (los pone el código) y que el centro quede despejado:

```
Tall vertical map background, 1080x4000 pixels (aspect ratio 27:100, very tall and narrow), of an ascending mountain path: stone stairs zig-zagging up a green
mountain through layers of fluffy pastel clouds, small pagodas, pine trees and waterfalls, the
bottom in fresh morning jade tones gradually shifting to warm gold and pink near the summit,
lots of empty space along the path for UI nodes.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
background (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

Textura de los sellos del mapa (`map_node_stone.png`, opcional, 512×512, PNG con transparencia; se recorta en círculo y se dibuja al 90% debajo del carácter tallado):

```
Top-down view of a single round flat stone disc for a game map node, pale warm granite with
subtle mineral speckles and soft worn edges, light coming from the top left, centered, empty
center (no carving, no symbol), transparent background.
Style: modern Chinese ink-and-watercolor illustration, bright and light, warm rice-paper tones
(#F6EEDC, #E2D3B6). NOT dark, no black, no text, no watermark.
```

Fondos de combate por tramo. Son opcionales y se toman solos, sin tocar código: si falta el del tramo, se usa `combat_bg.png`. La ladera es n1–n2, la bifurcación n3a/n3b, el templo n5 y la cumbre la pelea del jefe. La fuente no tiene combate: su fondo queda para cuando tenga pantalla propia.

**Formato:** la arena es casi cuadrada (la mitad de arriba de la pantalla; las cartas van abajo, sobre papel). Los fondos nuevos van **cuadrados 1:1** (1024×1024 o más), sin transparencia, con un suelo plano y despejado en el tercio inferior para que se paren los luchadores y el centro libre para el enemigo. Si llega uno vertical, se ve solo la franja del medio; `_variantFocus` en `combat_screen.dart` permite bajarla o subirla (el templo usa 0,45).

**Estado:** los 4 fondos de tramo (ladera, bifurcación, templo y cumbre) ya están en el juego.

#### Ladera (n1–n2)

**Destino:** `assets/art/stages/qianyunshan/combat_bg_ladera.png`, cuadrado 1:1, sin transparencia.

```
Mobile game combat background, square 1:1, no characters: a flat grassy clearing on a mountain slope, framed by a bamboo grove on the sides, soft morning mist and distant jade peaks behind, a few stone steps and a small vermilion lantern post at one edge, fresh jade and mint tones with touches of gold sunlight. Flat open ground across the lower third where two fighters stand, center open and uncluttered for a character. No people, no animals, no text.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
background (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Bifurcación (n3a / n3b)

**Destino:** `assets/art/stages/qianyunshan/combat_bg_bifurcacion.png`, cuadrado 1:1, sin transparencia.

```
Mobile game combat background, square 1:1, no characters: a wide flat rocky ledge where the mountain path splits in two, a weathered stone signpost at the fork, bright turquoise and cobalt quartz crystals growing from the cliffs on the sides, a softly glowing crack in the rock, pine trees and drifting clouds behind, turquoise, cobalt and jade tones in bright daylight. Flat open ground across the lower third where two fighters stand, center open and uncluttered for a character. No people, no animals, no text.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
background (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Fuente (n4)

**Destino:** `assets/art/stages/qianyunshan/combat_bg_fuente.png`, vertical 9:19.5, sin transparencia.

```
Mobile game combat background, vertical 9:19.5, no characters: serene spring pool under a blossoming tree, cobalt water, pink petals drifting. Upper third open and uncluttered for a character, lower half soft and low-contrast so cards remain readable. No people, no animals, no text.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
background (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Templo (n5)

**Destino:** `assets/art/stages/qianyunshan/combat_bg_templo.png`, vertical 9:19.5, sin transparencia.

```
Mobile game combat background, vertical 9:19.5, no characters: open-air cliff temple with red pillars and hanging bronze bells, vermilion and gold tones. Upper third open and uncluttered for a character, lower half soft and low-contrast so cards remain readable. No people, no animals, no text.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
background (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Cumbre (n6)

**Destino:** `assets/art/stages/qianyunshan/combat_bg_cumbre.png`, vertical 9:19.5, sin transparencia.

```
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

### Murciélago de Jade (`bat`, común)

Ataca dos veces y chilla para hacerte descartar.

```
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

### Salamandra de Brasa (`salamander`, común)

Guardia que absorbe daño; se rompe con palmas y empujes.

```
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

### Gólem de Cuarzo (`golem`, común)

Inamovible: hay que desequilibrarlo.

```
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

### Discípulo Perdido (`disciple`, común)

Castiga repetir la misma postura.

```
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

### Monje sin Rostro (`monk`, élite)

Interrumpe tus formas si no lo desviás.

```
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

### Eco del Dragón (`dragon`, jefe)

Jefe final, con 3 fases: tiene **escamas** que restan daño a cada golpe (se caen al desequilibrarlo y le vuelven a crecer en la fase 3) y desde la fase 2 lanza el **Aliento del Dragón**. Por eso el prompt pide escamas de jade bien visibles en pecho y brazos y la boca abierta juntando aliento dorado.

```
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

#### Marco de Puño

**Destino:** `assets/art/cards/frame_fist.png`, 2:3 (1024×1536), centro transparente.

```
Playing card frame, 2:3 ratio, empty transparent center, ornamental Chinese cloud-pattern border painted in vermilion (#E8453C) with gold accents, rounded corners, a round slot in the top-left corner for the cost number.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Marco de Palma

**Destino:** `assets/art/cards/frame_palm.png`, 2:3 (1024×1536), centro transparente.

```
Playing card frame, 2:3 ratio, empty transparent center, ornamental Chinese cloud-pattern border painted in violet (#9B5DE5) with gold accents, rounded corners, a round slot in the top-left corner for the cost number.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Marco de Patada

**Destino:** `assets/art/cards/frame_kick.png`, 2:3 (1024×1536), centro transparente.

```
Playing card frame, 2:3 ratio, empty transparent center, ornamental Chinese cloud-pattern border painted in gold (#E59A12) with gold accents, rounded corners, a round slot in the top-left corner for the cost number.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Marco de Defensa

**Destino:** `assets/art/cards/frame_defense.png`, 2:3 (1024×1536), centro transparente.

```
Playing card frame, 2:3 ratio, empty transparent center, ornamental Chinese cloud-pattern border painted in cobalt blue (#3E7BE0) with gold accents, rounded corners, a round slot in the top-left corner for the cost number.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Marco de Técnica

**Destino:** `assets/art/cards/frame_technique.png`, 2:3 (1024×1536), centro transparente.

```
Playing card frame, 2:3 ratio, empty transparent center, ornamental Chinese cloud-pattern border painted in jade green (#1FA38A) with gold accents, rounded corners, a round slot in the top-left corner for the cost number.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

**Ilustración por carta.** Una por carta, cuadrada, mostrando el movimiento. El color de la estela es el del tipo de la carta.

#### Puñetazo a fondo 弓步冲拳

**Destino:** `assets/art/cards/gongbu_chongquan.png`, cuadrada (1024×1024), fondo transparente.

```
Small square illustration of a kung fu move on a transparent background: a martial artist in a deep bow stance, front knee bent and back leg straight, driving a straight punch forward at chest height, dynamic brush-stroke figure, motion trail in vermilion (#E8453C), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Puñetazo firme 马步冲拳

**Destino:** `assets/art/cards/mabu_chongquan.png`, cuadrada (1024×1024), fondo transparente.

```
Small square illustration of a kung fu move on a transparent background: a martial artist in a wide low horse stance, thighs parallel to the ground, firing a straight punch to the side, dynamic brush-stroke figure, motion trail in vermilion (#E8453C), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Patada látigo 弹腿

**Destino:** `assets/art/cards/tan_tui.png`, cuadrada (1024×1024), fondo transparente.

```
Small square illustration of a kung fu move on a transparent background: a martial artist snapping a fast whip-like front kick at waist height, the kicking foot pointed, arms balanced, dynamic brush-stroke figure, motion trail in gold (#E59A12), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Empujón de palma 推掌

**Destino:** `assets/art/cards/tui_zhang.png`, cuadrada (1024×1024), fondo transparente.

```
Small square illustration of a kung fu move on a transparent background: a martial artist pushing forward with an open palm, fingers up, a soft shockwave in front of the hand, dynamic brush-stroke figure, motion trail in violet (#9B5DE5), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Bloqueo y contragolpe 马步架打

**Destino:** `assets/art/cards/mabu_jiada.png`, cuadrada (1024×1024), fondo transparente.

```
Small square illustration of a kung fu move on a transparent background: a martial artist in horse stance raising one forearm to block overhead while punching with the other hand, dynamic brush-stroke figure, motion trail in cobalt blue (#3E7BE0), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Paso atrás 虚步亮掌

**Destino:** `assets/art/cards/xubu_liangzhang.png`, cuadrada (1024×1024), fondo transparente.

```
Small square illustration of a kung fu move on a transparent background: a martial artist in an empty stance, weight on the back leg, one open palm raised high above the head like a guard, the other hand hooked behind, dynamic brush-stroke figure, motion trail in cobalt blue (#3E7BE0), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Bloqueo medio 格挡

**Destino:** `assets/art/cards/ge_dang.png`, cuadrada (1024×1024), fondo transparente.

```
Small square illustration of a kung fu move on a transparent background: a martial artist sweeping a forearm across the body at chest height to block an incoming strike, dynamic brush-stroke figure, motion trail in cobalt blue (#3E7BE0), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Bloqueo bajo 按掌

**Destino:** `assets/art/cards/an_zhang.png`, cuadrada (1024×1024), fondo transparente.

```
Small square illustration of a kung fu move on a transparent background: a martial artist pressing both palms downward in front of the hips to smother a low attack, dynamic brush-stroke figure, motion trail in cobalt blue (#3E7BE0), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Patada de talón 蹬腿

**Destino:** `assets/art/cards/deng_tui.png`, cuadrada (1024×1024), fondo transparente.

```
Small square illustration of a kung fu move on a transparent background: a martial artist thrusting a straight heel kick forward at stomach height, toes pulled back, dynamic brush-stroke figure, motion trail in gold (#E59A12), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Patada lateral 侧踹

**Destino:** `assets/art/cards/ce_chuai.png`, cuadrada (1024×1024), fondo transparente.

```
Small square illustration of a kung fu move on a transparent background: a martial artist delivering a powerful side kick with the body leaning away and the heel leading, dynamic brush-stroke figure, motion trail in gold (#E59A12), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Empujón a fondo 弓步推掌

**Destino:** `assets/art/cards/gongbu_tuizhang.png`, cuadrada (1024×1024), fondo transparente.

```
Small square illustration of a kung fu move on a transparent background: a martial artist in a deep bow stance pushing forward with an open palm, the whole body behind the push, dynamic brush-stroke figure, motion trail in violet (#9B5DE5), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Puño martillo 劈拳

**Destino:** `assets/art/cards/pi_quan.png`, cuadrada (1024×1024), fondo transparente.

```
Small square illustration of a kung fu move on a transparent background: a martial artist bringing a fist down in a chopping arc from above like an axe, dynamic brush-stroke figure, motion trail in vermilion (#E8453C), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Bloqueo alto 上架

**Destino:** `assets/art/cards/shang_jia.png`, cuadrada (1024×1024), fondo transparente.

```
Small square illustration of a kung fu move on a transparent background: a martial artist raising one forearm horizontally above the head to block a strike from above, dynamic brush-stroke figure, motion trail in cobalt blue (#3E7BE0), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Rodilla escudo 提膝

**Destino:** `assets/art/cards/ti_xi.png`, cuadrada (1024×1024), fondo transparente.

```
Small square illustration of a kung fu move on a transparent background: a martial artist balanced on one leg with the other knee lifted high to guard the body, dynamic brush-stroke figure, motion trail in cobalt blue (#3E7BE0), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Recuperar el aliento 调息

**Destino:** `assets/art/cards/tiao_xi.png`, cuadrada (1024×1024), fondo transparente.

```
Small square illustration of a kung fu move on a transparent background: a martial artist standing calmly with palms facing down in front of the belly, eyes closed, a soft swirl of breath rising, dynamic brush-stroke figure, motion trail in jade green (#1FA38A), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Saludo marcial 抱拳礼

**Destino:** `assets/art/cards/baoquan_li.png`, cuadrada (1024×1024), fondo transparente.

```
Small square illustration of a kung fu move on a transparent background: a martial artist bowing slightly with the kung fu salute, right fist pressed into the open left palm in front of the chest, dynamic brush-stroke figure, motion trail in jade green (#1FA38A), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Garra de tigre 虎爪

**Destino:** `assets/art/cards/hu_zhao.png`, cuadrada (1024×1024), fondo transparente.

```
Small square illustration of a kung fu move on a transparent background: a martial artist striking with a tiger claw hand, fingers curled like talons, faint tiger stripes in the motion trail, dynamic brush-stroke figure, motion trail in violet (#9B5DE5), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Salto del tigre 虎扑

**Destino:** `assets/art/cards/hu_pu.png`, cuadrada (1024×1024), fondo transparente.

```
Small square illustration of a kung fu move on a transparent background: a martial artist leaping forward with both tiger-claw hands extended, like a tiger pouncing, dynamic brush-stroke figure, motion trail in violet (#9B5DE5), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Guardia del tigre 虎抱头

**Destino:** `assets/art/cards/hu_bao_tou.png`, cuadrada (1024×1024), fondo transparente.

```
Small square illustration of a kung fu move on a transparent background: a martial artist crouching and wrapping both arms around the head like a tiger protecting itself, dynamic brush-stroke figure, motion trail in cobalt blue (#3E7BE0), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Rugido del tigre 虎啸

**Destino:** `assets/art/cards/hu_xiao.png`, cuadrada (1024×1024), fondo transparente.

```
Small square illustration of a kung fu move on a transparent background: a martial artist in a low stance releasing a powerful roar, a visible golden roar wave with a faint tiger head shape, dynamic brush-stroke figure, motion trail in jade green (#1FA38A), clear silhouette readable at small size.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

## 5. Íconos y efectos

Todos transparentes, 256×256 px.

#### Aliento

**Destino:** `assets/art/icons/breath.png`, cuadrado 256×256, fondo transparente.

```
Game UI icon, transparent background, bold simple shape, readable at 32 pixels: a swirling cobalt blue (#3E7BE0) breath wisp shaped like the character 气.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Guardia

**Destino:** `assets/art/icons/guard.png`, cuadrado 256×256, fondo transparente.

```
Game UI icon, transparent background, bold simple shape, readable at 32 pixels: a rounded cobalt blue (#3E7BE0) shield with a cloud pattern.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Estructura

**Destino:** `assets/art/icons/structure.png`, cuadrado 256×256, fondo transparente.

```
Game UI icon, transparent background, bold simple shape, readable at 32 pixels: a violet (#9B5DE5) hexagonal crystal.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Desvío

**Destino:** `assets/art/icons/deflect.png`, cuadrado 256×256, fondo transparente.

```
Game UI icon, transparent background, bold simple shape, readable at 32 pixels: a jade green (#1FA38A) arc slash deflecting a strike, with sparkles.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Desequilibrado

**Destino:** `assets/art/icons/stagger.png`, cuadrado 256×256, fondo transparente.

```
Game UI icon, transparent background, bold simple shape, readable at 32 pixels: a gold (#E59A12) starburst with dizzy spirals.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Fuente

**Destino:** `assets/art/icons/fountain.png`, cuadrado 256×256, fondo transparente.

```
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

**Estado:** los 5 de la primera tanda ya están en el juego (León, Abanico y Mono en combate; mercader y maestro en sus pantallas y en el prólogo). De la tanda 2 faltan todos.

### León de Piedra (`lion`, élite)

`assets/art/enemies/lion.png`. Guardián del arco del santuario: despierta de a poco; si no lo golpeás en un turno, gana Guardia.

```
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

### Dama del Abanico (`fan`, élite)

`assets/art/enemies/fan.png`. Élite humana: devuelve el primer golpe de cada turno con el abanico; hay que abrirla con fintas o palmas.

```
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

### Mono Ladrón (`monkey`, común)

`assets/art/enemies/monkey.png`. Común rápido: si sobrevive dos turnos, se escapa con parte de tu jade.

```
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

### Mercader del Paso (`merchant`, retrato)

`assets/art/npc/merchant.png`. Retrato para la tienda (nodo 商) cuando se haga la economía.

```
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

### El Maestro de la escuela (`master`, retrato)

`assets/art/npc/master.png`. Lore: aparece en el prólogo y al llegar a la cumbre. Que tenga algo ambiguo (la duda del pergamino de la cumbre).

```
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

#### Bandido del Paso (`bandit`, común)

`assets/art/enemies/bandit.png`. 1024×1536, transparente. Común con bastón: golpe fuerte cada dos turnos (se telegrafía).

```
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

#### Hongo Lingzhi (`lingzhi`, común)

`assets/art/enemies/lingzhi.png`. 1024×1536, transparente. Común que se cura cada turno: hay que pegarle fuerte y rápido.

```
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

#### Fondo de la Fuente (`fountain_bg.png`)

`assets/art/stages/qianyunshan/fountain_bg.png`. 1080×1920 vertical, sin transparencia. Pantalla de descanso del nodo 泉; centro despejado para la UI.

```
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

#### Fondo del Santuario (`shrine_bg.png`)

`assets/art/stages/qianyunshan/shrine_bg.png`. 1080×1920 vertical, sin transparencia. Donde los espíritus eligen camino; las 3 estatuas van atrás y chicas, la UI va adelante.

```
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

#### Muro de la escuela (`school_wall.png`)

`assets/art/school/school_wall.png`. 1080×1920 vertical, sin transparencia. Fondo del Registro y de la escena de derrota: donde la escuela recuerda a los que no volvieron.

```
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

**Estado:** los 14 enemigos ya están en el juego como **variantes recoloreadas** de los de la etapa 1 (`tool/recolor_enemies.py`). Cuando llegue el arte propio de uno, se guarda con el mismo nombre en `assets/art/enemies/` y **se borra su entrada de `VARIANTS`** en el script (si no, volver a correrlo lo pisa). Los fondos de combate de estas etapas hoy son los de la etapa 1 teñidos (`_stageTint` en `combat_screen.dart`).

### Fondos de combate

**Destino:** `assets/art/stages/xuankongsi/` y `assets/art/stages/wolongding/` (hay que agregar las carpetas en `pubspec.yaml`). Mismo formato que la etapa 1: cuadrados 1:1, suelo plano y despejado en el tercio inferior. Con `combat_bg.png` alcanza; las variantes por tramo usan los nombres de la etapa 1 (`combat_bg_ladera`, `_bifurcacion`, `_templo`, `_cumbre`), según `_sceneFiles`.

Monasterio Colgado (`xuankongsi/combat_bg.png`):

```
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

Cumbre del Dragón Dormido (`wolongding/combat_bg.png`):

```
Square game battle background, 1:1 aspect ratio: a snowy mountain summit above a sea of clouds, wind-carved snow
ridges, a small frozen shrine, pale blue sky with pink dawn light, gentle falling snow, the vague
coil of a sleeping dragon's body hidden in the clouds far behind, flat clear snowy ground in the lower third.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
background (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no characters, no text, no watermark.
```

### Enemigos

### Murciélago del Campanario (`bat_bronze`, común, etapa 2)

```
Game enemy character, full body, facing the viewer, centered, transparent background: a bat spirit that nests in a temple bell tower, bronze-and-copper wings engraved like an old bell, a tiny bronze bell hanging from its neck, sound rings rippling from its wings, wide round eyes.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Hombre de Bronce 铜人 (`golem_bronze`, común, etapa 2)

```
Game enemy character, full body, facing the viewer, centered, transparent background: a Shaolin bronze man training statue come alive, polished bronze body with acupuncture-point markings, short sharp bronze spikes on shoulders and forearms, solid wide stance, faint gold glow in its eyes.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Guardián del Pasadizo (`disciple_saffron`, común, etapa 2)

```
Game enemy character, full body, facing the viewer, centered, transparent background: a young monk guardian in deep maroon and saffron robes, wooden prayer beads, one palm raised forward like a closed gate, standing on a narrow wooden walkway.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Salamandra de Ceniza (`salamander_ash`, común, etapa 2)

```
Game enemy character, full body, facing the viewer, centered, transparent background: a lavender-grey salamander made of cooled ash with glowing pale embers along its back, small wisps of incense smoke curling from its tail, wounds closing with soft light.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Abad de Hierro 铁僧 (`monk_iron`, élite, etapa 2)

```
Game enemy character, full body, facing the viewer, centered, transparent background: a towering faceless abbot in steel-blue robes with an iron-scaled undershirt visible at the chest, iron prayer beads, short spikes on its bracers, calm menacing posture.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### León de Jade 玉狮 (`lion_jade`, élite, etapa 2)

```
Game enemy character, full body, facing the viewer, centered, transparent background: a guardian lion carved from translucent green jade, gold cracks of light along the mane, red silk ribbon, cracks slowly healing with green glow.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Abad de la Gran Campana 钟师 (`monk_gold`, jefe, etapa 2)

```
Game enemy character, full body, facing the viewer, centered, transparent background: the old abbot of the hanging monastery, golden robes, a huge cracked bronze temple bell floating behind him, a heavy wooden striker in his hands, rings of sound around him, sad wise expression.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Simio de las Nieves (`monkey_snow`, común, etapa 3)

```
Game enemy character, full body, facing the viewer, centered, transparent background: a white snow ape with frosty fur, icy blue scarf, breath visible in the cold, wild playful crouch ready to pounce.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Gólem de Escarcha (`golem_ice`, común, etapa 3)

```
Game enemy character, full body, facing the viewer, centered, transparent background: a golem of packed snow and pale blue ice blocks, frost crystals growing on its shoulders, cold mist pouring from its fists.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Discípulo del Viento (`disciple_wind`, común, etapa 3)

```
Game enemy character, full body, facing the viewer, centered, transparent background: a lost disciple in sky-blue tattered robes whipping in the wind, snow on his shoulders, faded headband, one leg raised for a sweeping kick trailing frost.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Murciélago de Escarcha (`bat_frost`, común, etapa 3)

```
Game enemy character, full body, facing the viewer, centered, transparent background: a pale ice-blue bat spirit with frosted translucent wings, snowflakes trailing behind it, icicle fangs.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Dama del Viento 风扇 (`fan_wind`, élite, etapa 3)

```
Game enemy character, full body, facing the viewer, centered, transparent background: an elegant warrior woman in teal and white layered robes, a large white iron fan releasing a gust of snow, hair and sleeves blown by the wind.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### León de las Nieves 雪狮 (`lion_snow`, élite, etapa 3)

```
Game enemy character, full body, facing the viewer, centered, transparent background: a guardian lion of snow-white marble covered in frost and icicles, small ice spikes along its mane, red ribbon, roaring.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Dragón Dormido 卧龙 (`dragon_azure`, jefe final, etapa 3)

```
Game enemy character, full body, facing the viewer, centered, transparent background: an immense azure-and-gold Chinese dragon coiled around the snowy summit, only partly awake, one huge eye half open, clouds being born from its slow breath, ancient and majestic, fills the frame.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
cream tones (#F6EEDC) on the figure only, fully transparent background, saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

### Tanda 3: mapas, fuentes y paso entre etapas

**Estado:** ya están en el juego los dos mapas y la fuente del Monasterio. El mapa y la fuente buscan su archivo por `stageId` y, si falta, usan el de la etapa 1 (`stageArt` en `widgets/scene_backdrop.dart`). Faltan el manantial de la cumbre y el paso entre etapas; los dos ya se cargan apenas se guarden.

#### Mapa del Monasterio Colgado (`xuankongsi/map_bg.png`)

1080×4000 vertical, sin sendero propio (lo dibuja el código) y con el centro despejado.

```
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

#### Mapa de la Cumbre del Dragón Dormido (`wolongding/map_bg.png`)

1080×4000 vertical, sin sendero propio y con el centro despejado.

```
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

#### Fuente del Monasterio (`xuankongsi/fountain_bg.png`)

1080×1920 vertical, sin transparencia; centro despejado para la UI.

```
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

#### Manantial de la Cumbre (`wolongding/fountain_bg.png`)

1080×1920 vertical, sin transparencia; centro despejado para la UI.

```
Vertical background, 1080x1920 pixels (aspect ratio 9:16), of a hot spring high on a snowy mountain: a turquoise steaming pool among
smooth snow-covered rocks, warm vapor curling up, small icicles shining, a red-ribboned prayer
rope on a stone, pale blue sky and pink dawn light over a sea of clouds, the middle of the image
calm and open for interface elements.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
background (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, calm and luminous mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no characters, no text, no watermark.
```

#### Paso entre etapas (`stage_clear_bg.png`)

`assets/art/ui/stage_clear_bg.png`. 1080×1920 vertical, sin transparencia. Fondo de la pantalla de etapa superada: el hanzi y la Vida van encima, así que el centro tiene que quedar muy limpio.

```
Vertical background, 1080x1920 pixels (aspect ratio 9:16), of a mountain gate (paifang) of red lacquered wood standing on a stone
stairway that climbs from green misty slopes at the bottom, through a sea of clouds, toward a
far snowy peak glowing in gold and pink light at the top, a few cranes flying, very soft and
airy composition with a wide clean empty area in the center for large text.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
background (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, calm and luminous mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no characters, no text, no watermark.
```

---

## Pendiente

- Los nombres de cueva ya se cambiaron por nombres de montaña: Murciélago de Jade, Salamandra de Brasa y Gólem de Cuarzo.
