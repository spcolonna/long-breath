# Prompts de arte

Prompts para generar la identidad visual de Long Breath. Sirven para cualquier generador (Midjourney, DALL·E, Imagen, SD). Están en inglés porque los generadores responden mejor así.

**Regla general:** nada de fondos negros, marrones ni "versión dark". Es una pintura china vista a plena luz: papel claro, color saturado y mucho aire.

## Bloque de estilo (pegar al final de cada prompt)

```
Style: vibrant modern Chinese ink-and-watercolor illustration, bright daylight, warm rice-paper
background (#F6EEDC), saturated accents of vermilion (#E8453C), jade green (#1FA38A), cobalt blue
(#3E7BE0), gold (#E59A12) and violet (#9B5DE5), soft color gradients and tonal shifts, clean
confident brush strokes, flat shading with watercolor bleeds, playful and energetic mood,
high readability on a small phone screen. NOT dark, NOT gloomy, NOT grim, no black or brown
backgrounds, no photorealism, no text, no watermark.
```

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

**Destino:** `assets/art/enemies/placeholder.png`, PNG cuadrado (1024×1024) con fondo transparente.

Se usa para todos los enemigos hasta que cada uno tenga su imagen (`assets/art/enemies/<id>.png`). El juego le agrega un aura del color del rango (jade común, violeta élite, bermellón jefe), por eso la figura usa colores neutros.

```
Game enemy character, full body, facing the viewer in a fighting stance, centered, transparent
background: a rival kung fu martial artist in a simple layered robe of soft jade and off-white
with a sash, hair tied up, calm but threatening expression, hands raised in guard, slight
low-angle heroic perspective, clean readable silhouette at small size, neutral colors that work
under a colored aura. [ESTILO]
```

### Fondo de arena de combate

**Destino:** `assets/art/stages/qianyunshan/combat_bg.png`, vertical (1206×1400 aprox.). Ocupa la mitad superior de la pantalla, detrás del enemigo.

```
Mobile game battle arena background, vertical: a flat stone terrace on a green mountain ledge,
bamboo and pine at the sides, layers of soft pastel clouds and distant peaks behind, bright
morning sky in light blue fading to warm cream at the bottom, open empty center for a
character standing on the terrace, low detail in the middle. [ESTILO]
```

## 1. Pantalla de inicio

**Destino:** `assets/art/ui/home_bg.png`, vertical 9:19.5, con espacio libre en el centro para el logo.

```
Vertical mobile splash illustration: a young kung fu student in a flowing jade-and-white robe
standing on a floating rock at the foot of a colossal mountain wrapped in a thousand swirling
pastel clouds, dawn light in peach and gold, a faint golden dragon silhouette drawn by the clouds
themselves, wide empty sky area in the upper-middle for a logo. [ESTILO]
```

**Logo:** `assets/art/ui/logo.png`, cuadrado y transparente.

```
Logo emblem: the Chinese character 龙 painted in a single energetic vermilion brush stroke, with a
thin gold breath-like swirl wrapping around it, on transparent background, bold and readable at
small size. [ESTILO]
```

## 2. Etapa 1: Montaña de las Mil Nubes (千云山)

**Destino:** `assets/art/stages/qianyunshan/`

Fondo del mapa (`map_bg.png`, vertical y alto, se puede desplazar):

```
Tall vertical map background of an ascending mountain path: stone stairs zig-zagging up a green
mountain through layers of fluffy pastel clouds, small pagodas, pine trees and waterfalls, the
bottom in fresh morning jade tones gradually shifting to warm gold and pink near the summit,
lots of empty space along the path for UI nodes. [ESTILO]
```

Fondos de combate (`combat_bg_<tramo>.png`, 9:19.5). La zona superior queda despejada para el enemigo y la inferior es más suave para las cartas:

| Tramo | Nodos | Prompt (parte variable) |
|---|---|---|
| Ladera | n1–n2 | `mountain slope with bamboo grove and morning mist, jade and mint tones` |
| Bifurcación | n3a / n3b | `rocky ledge with crystal formations and a glowing crack, turquoise and cobalt tones` |
| Fuente | n4 | `serene spring pool under a blossoming tree, cobalt water, pink petals` |
| Templo | n5 | `open-air cliff temple with red pillars and hanging bells, vermilion and gold` |
| Cumbre | n6 | `summit above a sea of clouds at sunset, gold, coral and violet sky` |

```
Mobile game combat background, vertical: [PARTE VARIABLE]. Upper third open and uncluttered for a
character, lower half soft and low-contrast so cards remain readable. [ESTILO]
```

## 3. Enemigos

**Destino:** `assets/art/enemies/<id>.png`, cuadrado y transparente, figura completa. Cada enemigo tiene un color dominante que coincide con su nodo en el mapa.

| id | Nombre | Prompt (parte variable) |
|---|---|---|
| `bat` | Eco de Murciélago | `a mischievous spirit bat made of echoing sound rings, jade and mint wings, big expressive eyes, mid-screech pose` |
| `disciple` | Discípulo Perdido | `a young rival martial artist in a torn jade training robe, determined but lost expression, fighting stance` |
| `golem` | Gólem de Estalactita | `a sturdy golem of pale crystal stone with turquoise veins, immovable wide stance, moss on shoulders` |
| `salamander` | Salamandra de la Grieta | `a nimble fire salamander with coral and gold scales, flickering tail flame, crouched to leap` |
| `monk` | Monje sin Rostro | `an elite monk with a smooth blank porcelain mask, violet and gold robes, prayer beads, serene menace` |
| `dragon` | Eco del Dragón | `a colossal translucent dragon spirit formed of golden breath and clouds, vermilion eyes, coiling, awe-inspiring but colorful` |

```
Game enemy character portrait, full body, centered, transparent background: [PARTE VARIABLE].
Readable silhouette at small size. [ESTILO]
```

## 4. Cartas

**Marcos por tipo** (`assets/art/cards/frame_<tipo>.png`, proporción 2:3, centro transparente):

```
Playing card frame, 2:3 ratio, empty transparent center, ornamental Chinese cloud-pattern border
painted in [COLOR] with gold accents, rounded corners, top-left circle slot for cost. [ESTILO]
```

`fist` = vermilion · `palm` = violet · `kick` = gold · `defense` = cobalt · `technique` = jade

**Ilustración por carta** (`assets/art/cards/<card_id>.png`, cuadrado): una por carta, mostrando el movimiento.

```
Small square illustration of a kung fu move: [DESCRIPCIÓN DEL MOVIMIENTO], dynamic brush-stroke
figure, motion trail in [COLOR DEL TIPO]. [ESTILO]
```

## 5. Íconos y efectos

**Destino:** `assets/art/icons/`, transparentes, 256 px.

| Archivo | Prompt (parte variable) |
|---|---|
| `breath.png` | `a swirling cobalt breath wisp (气)` |
| `guard.png` | `a rounded cobalt shield with cloud pattern` |
| `structure.png` | `a violet hexagonal crystal` |
| `deflect.png` | `a jade arc slash deflecting a strike, sparkles` |
| `stagger.png` | `a gold starburst with dizzy spirals` |
| `fountain.png` | `a small cobalt spring with a lotus` |

```
Game UI icon, transparent background, bold simple shape: [PARTE VARIABLE]. [ESTILO]
```

---

## Pendiente

- Algunos nombres de enemigos todavía vienen del ambiente de cueva: "Estalactita", "Grieta" y el eco del murciélago. En los prompts ya los ubiqué en la montaña; queda decidir si también se renombran en `assets/data/enemies.json`.
