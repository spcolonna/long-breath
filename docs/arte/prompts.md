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

Fondo del mapa (`map_bg.png`, vertical y alto, se puede desplazar):

```
Tall vertical map background of an ascending mountain path: stone stairs zig-zagging up a green
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

Fondos de combate por tramo. Son opcionales: hoy todos los combates usan `combat_bg.png`. La zona superior queda despejada para el enemigo y la inferior es más suave para las cartas.

#### Ladera (n1–n2)

**Destino:** `assets/art/stages/qianyunshan/combat_bg_ladera.png`, vertical 9:19.5, sin transparencia.

```
Mobile game combat background, vertical 9:19.5, no characters: mountain slope with a bamboo grove and soft morning mist, jade and mint tones. Upper third open and uncluttered for a character, lower half soft and low-contrast so cards remain readable. No people, no animals, no text.
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
background (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

#### Bifurcación (n3a / n3b)

**Destino:** `assets/art/stages/qianyunshan/combat_bg_bifurcacion.png`, vertical 9:19.5, sin transparencia.

```
Mobile game combat background, vertical 9:19.5, no characters: rocky mountain ledge with crystal formations and a softly glowing crack, turquoise and cobalt tones. Upper third open and uncluttered for a character, lower half soft and low-contrast so cards remain readable. No people, no animals, no text.
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
Mobile game combat background, vertical 9:19.5, no characters: summit above a sea of clouds at sunset, gold, coral and violet sky. Upper third open and uncluttered for a character, lower half soft and low-contrast so cards remain readable. No people, no animals, no text.
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

Jefe final; en fase 2 lanza el Aliento del Dragón.

```
Game boss character, facing the viewer, centered, transparent background: a colossal
translucent dragon spirit formed of swirling golden breath and white clouds, head and
front claws coming toward the viewer, the long body coiling up and behind in an S shape,
vermilion glowing eyes, flowing jade whiskers and mane, small pearls of light around it,
awe-inspiring and majestic but colorful and bright, fills the frame, iconic silhouette.
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

## Pendiente

- Los nombres de cueva ya se cambiaron por nombres de montaña: Murciélago de Jade, Salamandra de Brasa y Gólem de Cuarzo.
