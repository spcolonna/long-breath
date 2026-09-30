# Sonido y música

Lista de efectos y música para Long Breath, con el momento exacto del juego en que suena y un prompt para generarlo (ElevenLabs Sound Effects, Stable Audio, Suno/Udio para música). Los prompts están en inglés porque los generadores responden mejor así. **Cada bloque es un prompt completo** (con el estilo incluido): se copia entero y se pega.

**Identidad sonora:** kung fu luminoso y con energía, como la paleta: percusión china seca (tambor dagu, bloque de madera, platillos bo, gong chico), cuerdas pulsadas (guzheng, pipa) y flauta dizi. Golpes cortos, con cuerpo y sin reverb larga. Nada de terror, drones graves ni ambiente oscuro.

## Formato y destino

| Tipo | Formato | Destino |
|---|---|---|
| Efecto | WAV 44,1 kHz, 16 bit, **mono**, sin silencio al inicio, pico a −1 dB | `assets/audio/sfx/<id>.wav` |
| Música | OGG Vorbis (calidad ~6), estéreo, **loop sin corte** | `assets/audio/music/<id>.ogg` |
| Jingle | OGG Vorbis, estéreo, sin loop | `assets/audio/music/<id>.ogg` |

- El juego acepta `.wav`, `.ogg`, `.mp3` y `.flac`; M4A/AAC no. Para música conviene OGG: el MP3 agrega un silencio mínimo que se nota en el loop.
- No hace falta tocar código: se agrega el archivo con el nombre exacto y suena. Lo que falta, no suena.
- Los efectos que se repiten mucho llevan **variantes** (`hit_light_1`, `hit_light_2`, `hit_light_3`) para que no suenen a máquina; el juego elige una al azar y le cambia apenas el tono.
- Duración: efectos entre 0,1 y 1,2 s salvo que se indique otra cosa.

---

## 1. Prioridad MVP (lo que más cambia el feel)

Con estos 14 el combate ya se siente completo.

#### `card_deal` — Cada carta que entra a la mano (suenan en cascada)

**Destino:** `assets/audio/sfx/card_deal_1.wav … card_deal_3.wav` (3 variantes: generá el mismo prompt 3 veces)

```
A single paper card flicked onto a wooden table, light quick swish and soft tap, 0.15 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `card_select` — Tocar una carta para elegirla

**Destino:** `assets/audio/sfx/card_select.wav`

```
Soft wooden bead click with a tiny bright guzheng pluck, very short, 0.12 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `card_deny` — Tocar una carta que no se puede jugar

**Destino:** `assets/audio/sfx/card_deny.wav`

```
Dull muted wooden knock twice, short and negative but not harsh, 0.25 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `card_play` — La carta sale volando hacia el objetivo

**Destino:** `assets/audio/sfx/card_play.wav`

```
Fast cloth-and-paper whoosh rising in pitch, energetic swipe, 0.3 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `hit_light` — Golpe con daño menor a 10

**Destino:** `assets/audio/sfx/hit_light_1.wav … hit_light_3.wav` (3 variantes: generá el mismo prompt 3 veces)

```
Quick martial-arts punch impact on a padded body, tight thump with a snappy slap, 0.25 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `hit_heavy` — Golpe con 10 o más de daño, o que rompe al enemigo

**Destino:** `assets/audio/sfx/hit_heavy_1.wav … hit_heavy_2.wav` (2 variantes: generá el mismo prompt 2 veces)

```
Powerful kung fu strike impact, deep chinese dagu drum hit layered with a sharp slap and a short cymbal crash, 0.6 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `block` — Daño absorbido por la Guardia enemiga ("Bloqueado")

**Destino:** `assets/audio/sfx/block.wav`

```
Solid block of a strike with forearm and wooden staff, hard knock with short ringing wood, 0.3 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `player_hurt` — El enemigo te pega (acompaña al destello rojo)

**Destino:** `assets/audio/sfx/player_hurt_1.wav … player_hurt_2.wav` (2 variantes: generá el mismo prompt 2 veces)

```
Heavy body hit received, low punchy thud with a short breathy grunt, not gory, 0.4 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `deflect` — Desviás el golpe enemigo (化)

**Destino:** `assets/audio/sfx/deflect.wav`

```
Swift deflection, whoosh that bends away followed by a bright metallic shing and a small bell, 0.5 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `guard_up` — Ganás Guardia con una carta de defensa

**Destino:** `assets/audio/sfx/guard_up.wav`

```
Firm defensive stance, cloth snap and a low wooden block knock with a soft shimmer, 0.35 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `enemy_windup` — El enemigo toma impulso antes de atacar

**Destino:** `assets/audio/sfx/enemy_windup.wav`

```
Short tense inhale and cloth rustle building up, rising woodblock roll, 0.35 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `turn_start` — Cartel "Tu turno"

**Destino:** `assets/audio/sfx/turn_start.wav`

```
Single bright hand-drum hit followed by a quick rising dizi flute note, confident and inviting, 0.8 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `victory_stamp` — Cae el sello 胜 al ganar

**Destino:** `assets/audio/sfx/victory_stamp.wav`

```
Heavy ink seal stamped onto paper, deep satisfying thump followed by a bright gong swell and small bells, triumphant, 1.2 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `defeat_stamp` — Cae el sello 败 al perder

**Destino:** `assets/audio/sfx/defeat_stamp.wav`

```
Slow heavy seal stamp on paper, soft low thud with a descending guzheng glissando, melancholic but gentle, not dark, 1.4 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```



---

## 2. Combate: el resto de los eventos

#### `fight_start` — Cartel de entrada del enemigo ("¡En guardia!")

**Destino:** `assets/audio/sfx/fight_start.wav`

```
Martial arts duel opening, two sharp woodblock hits then a quick cymbal splash and a shout-like dizi accent, 1 second.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `enemy_drop` — El enemigo cae a escena

**Destino:** `assets/audio/sfx/enemy_drop.wav`

```
Light acrobatic landing on a wooden floor, soft thud with dust puff, 0.3 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `break` — Enemigo Desequilibrado (inclinación y estrellas)

**Destino:** `assets/audio/sfx/break.wav`

```
Stagger and dizziness, wobbly boing-like pitch bend on a pipa string with small twinkling bells, playful, 0.7 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `enemy_guard` — El enemigo gana Guardia ("+Guardia")

**Destino:** `assets/audio/sfx/enemy_guard.wav`

```
Enemy raises guard, low wooden clack and armor-like cloth tighten, 0.3 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `enemy_charge` — El enemigo carga ("+carga")

**Destino:** `assets/audio/sfx/enemy_charge.wav`

```
Energy gathering, rising breathy whoosh with a building gong shimmer, 0.7 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `enemy_skip` — El enemigo pierde su acción

**Destino:** `assets/audio/sfx/enemy_skip.wav`

```
Comic fizzle, deflating whistle ending in a small wooden plonk, 0.5 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `enemy_death` — El enemigo se disuelve en tinta

**Destino:** `assets/audio/sfx/enemy_death.wav`

```
Ink splash dissolving into the wind, wet brush swish turning into a soft airy shimmer, 1 second.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `hero_victory` — El héroe festeja

**Destino:** `assets/audio/sfx/hero_victory.wav`

```
Quick victorious cloth flourish and a short bright guzheng run upward, 0.8 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `hero_fall` — El héroe cae (derrota)

**Destino:** `assets/audio/sfx/hero_fall.wav`

```
Body slowly collapsing onto a wooden floor, soft thud and cloth, 0.6 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `stance_change` — Cambiás de postura (Caballo, Arco, Vacía)

**Destino:** `assets/audio/sfx/stance_change.wav`

```
Feet sliding firmly into a martial arts stance on wood, sharp scuff and cloth snap, 0.3 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `form_step` — Avanza un paso de una forma

**Destino:** `assets/audio/sfx/form_step_1.wav … form_step_5.wav` (5 notas, cada una más aguda)

```
Single clear guzheng pluck, rising pentatonic note, 0.4 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `form_complete` — Forma completada (estallido de color)

**Destino:** `assets/audio/sfx/form_complete.wav`

```
Martial form completed, fast ascending guzheng and pipa run ending on a bright gong and cymbal hit, triumphant, 1.2 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `form_broken` — Formas interrumpidas

**Destino:** `assets/audio/sfx/form_broken.wav`

```
Plucked string snapping with a dull detuned note, short and disappointed, 0.5 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `breath_gain` — Recuperás Aliento

**Destino:** `assets/audio/sfx/breath_gain.wav`

```
Calm deep inhale with a soft airy wind chime, 0.6 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `breath_spend` — Gastás Aliento al jugar

**Destino:** `assets/audio/sfx/breath_spend.wav`

```
Short sharp exhale, focused kiai breath without a word, 0.25 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `phase_two` — El jefe entra en fase 2 ("El dragón despierta")

**Destino:** `assets/audio/sfx/phase_two.wav`

```
Large gong struck hard with a rising roll of chinese drums and a sweeping wind, epic, 2 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `end_rays` — Aparecen los rayos y pétalos de la victoria

**Destino:** `assets/audio/sfx/end_rays.wav`

```
Airy celestial shimmer with gentle bells and falling petals feel, bright, 1.5 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `ui_button` — Botones "Continuar", "Terminar turno"

**Destino:** `assets/audio/sfx/ui_button.wav`

```
Soft wooden button tap with a light click, 0.1 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```



### Voces de los enemigos (una por enemigo, suena en `enemy_windup`)

#### `enemy_dummy` — Muñeco de madera

**Destino:** `assets/audio/sfx/enemy_dummy.wav`

```
Wooden training dummy creaking and knocking as it rocks, hollow wood, 0.4 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `enemy_bat` — Murciélago

**Destino:** `assets/audio/sfx/enemy_bat.wav`

```
Small bat screech with fast wing flutter, high pitched, cartoony not scary, 0.5 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `enemy_salamander` — Salamandra

**Destino:** `assets/audio/sfx/enemy_salamander.wav`

```
Small salamander hiss with a crackle of fire, playful, 0.5 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `enemy_golem` — Gólem

**Destino:** `assets/audio/sfx/enemy_golem.wav`

```
Stone golem grinding and rumbling, rocks shifting, heavy but short, 0.6 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `enemy_disciple` — Discípulo

**Destino:** `assets/audio/sfx/enemy_disciple.wav`

```
Young martial artist short kiai shout, energetic, 0.4 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `enemy_monk` — Monje (élite)

**Destino:** `assets/audio/sfx/enemy_monk.wav`

```
Deep monk kiai combined with a wooden prayer bead rattle, powerful, 0.6 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `enemy_dragon` — Dragón (jefe)

**Destino:** `assets/audio/sfx/enemy_dragon.wav`

```
Majestic eastern dragon roar, resonant and bright with a metallic gong undertone, epic not horror, 1.5 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```



---

## 3. Fuera del combate

#### `screen_transition` — Cambio de pantalla (desvanecido)

**Destino:** `assets/audio/sfx/screen_transition.wav`

```
Very soft paper page turn with a light air swish, 0.3 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `map_node` — Tocar un nodo del mapa

**Destino:** `assets/audio/sfx/map_node.wav`

```
Ink brush dab on paper with a soft wooden tap, 0.2 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `reward_flip` — Cada carta de recompensa se da vuelta

**Destino:** `assets/audio/sfx/reward_flip_1.wav … reward_flip_3.wav` (3 variantes: generá el mismo prompt 3 veces)

```
Card flipped over quickly with a bright small chime, 0.25 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `reward_take` — La carta elegida sube al mazo

**Destino:** `assets/audio/sfx/reward_take.wav`

```
Magical card collected, rising sparkle whoosh ending on a warm bell, 0.8 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `fountain_heal` — La fuente cura (la Vida sube contando)

**Destino:** `assets/audio/sfx/fountain_heal.wav`

```
Clear spring water pouring and bubbling with gentle rising wind chimes, healing and fresh, 1.5 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `shrine_oath` — Jurás un camino en el santuario

**Destino:** `assets/audio/sfx/shrine_oath.wav`

```
Solemn temple bell struck once with a soft incense whoosh, sacred and bright, 1.8 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

#### `run_result` — Cae el carácter del final de run

**Destino:** `assets/audio/sfx/run_result.wav`

```
Large calligraphy seal stamped with a deep gong and a bright cymbal shimmer, 1.5 seconds.
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```



---

## 4. Música

Prompts para Suno/Udio. Todo instrumental, sin voz.

#### `music_menu` — Menú y mapa, loop 1–2 min

**Destino:** `assets/audio/music/music_menu.ogg`

```
Instrumental loop, bright traditional Chinese folk, guzheng and dizi flute over light hand percussion, peaceful mountain morning, hopeful, 90 BPM, seamless loop, no vocals.
```

#### `music_combat` — Combate común, loop 1–2 min

**Destino:** `assets/audio/music/music_combat.ogg`

```
Instrumental loop, energetic kung fu action, driving chinese drums, pipa riffs and dizi melody, bright and heroic not dark, 128 BPM, seamless loop, no vocals.
```

#### `music_elite` — Combate contra el Monje

**Destino:** `assets/audio/music/music_elite.ogg`

```
Instrumental loop, intense kung fu duel, heavier dagu drums, erhu lead, gongs on accents, focused and dramatic but bright, 135 BPM, seamless loop, no vocals.
```

#### `music_boss` — Combate contra el Dragón

**Destino:** `assets/audio/music/music_boss.ogg`

```
Instrumental loop, epic chinese orchestral battle, big taiko-style and dagu drums, soaring erhu and dizi, brass-like gong swells, majestic and heroic, 140 BPM, seamless loop, no vocals.
```

#### `music_training` — Entrenamiento con el muñeco

**Destino:** `assets/audio/music/music_training.ogg`

```
Instrumental loop, light playful training montage, woodblocks, plucked guzheng and cheerful dizi, 110 BPM, seamless loop, no vocals.
```

#### `jingle_victory` — Pantalla de victoria (sin loop)

**Destino:** `assets/audio/music/jingle_victory.ogg`

```
Short triumphant chinese fanfare, gong hit, fast guzheng run and bright dizi melody ending on a major chord, 4 seconds, no vocals.
```

#### `jingle_defeat` — Pantalla de derrota (sin loop)

**Destino:** `assets/audio/music/jingle_defeat.ogg`

```
Short gentle defeat sting, slow descending guzheng and soft erhu, calm and hopeful not sad or dark, 4 seconds, no vocals.
```

#### `jingle_run_won` — Run completada

**Destino:** `assets/audio/music/jingle_run_won.ogg`

```
Celebratory chinese festival fanfare, drums, cymbals and dizi, joyful, 7 seconds, no vocals.
```



## Mezcla (referencia para integrarlo)

- **Volúmenes relativos:** golpes y sellos 100 %, cartas y UI 50 %, voces de enemigos 70 %, música 35 % (baja a 20 % durante el cartel de victoria o derrota, cuando entra el jingle).
- **Sincronía:** cada efecto suena en el mismo instante que su háptica y su animación (el impacto a los 330 ms del embiste del enemigo, el sello al caer).
- **Ajustes:** sonido y música con interruptores separados (arriba a la derecha en el inicio); se respeta el modo silencio del iPhone.

## Dónde conseguirlos

- **Generarlos con IA** (lo más rápido para que suenen propios):
  - Efectos: [ElevenLabs Sound Effects](https://elevenlabs.io/sound-effects) (texto a efecto, pegar los prompts de arriba) o [Stable Audio](https://stableaudio.com).
  - Música: [Suno](https://suno.com) o [Udio](https://www.udio.com), en modo instrumental. En planes pagos permiten uso comercial; revisar la licencia del plan antes de publicar.
- **Bibliotecas gratis:**
  - [Kenney](https://kenney.nl/assets?q=audio) (CC0, sin atribución): UI, impactos, cartas. Ideal para `card_*`, `ui_button`, `map_node`.
  - [Freesound](https://freesound.org) (filtrar por licencia CC0): gongs, tambores chinos, bloque de madera, guzheng sueltos.
  - [Sonniss GDC Bundle](https://sonniss.com/gameaudiogdc) (gratis, uso comercial sin atribución): cientos de GB de golpes y whooshes profesionales.
- **Packs pagos baratos:** [itch.io](https://itch.io/game-assets/tag-sound-effects) y el Unity Asset Store (sirven fuera de Unity) tienen packs de "martial arts" / "asian percussion" / "card game UI" por 5–30 USD.
- **Para convertir y recortar:** [Audacity](https://www.audacityteam.org) (gratis): recortar el silencio inicial, normalizar a −1 dB, exportar WAV mono u OGG.

## Integración (ya hecha)

- Motor: `flutter_soloud` (baja latencia, varias voces, loops sin corte). Para compilar en iOS/Android hace falta **CMake** (`brew install cmake`).
- Catálogo: `lib/delivery/audio/game_audio.dart` (enums `Sfx` y `Music` con id, variantes y volumen). Implementación en `lib/infrastructure/soloud_audio.dart`.
- Al arrancar se imprime en la consola cuántos efectos y pistas encontró (`audio: N efectos y M pistas encontradas`).
