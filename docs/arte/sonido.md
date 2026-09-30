# Sonido y música

Lista de efectos y música para Long Breath, con el momento exacto del juego en que suena y un prompt para generarlo (ElevenLabs Sound Effects, Stable Audio, Suno/Udio para música). Los prompts están en inglés porque los generadores responden mejor así.

**Identidad sonora:** kung fu luminoso y con energía, como la paleta: percusión china seca (tambor dagu, bloque de madera, platillos bo, gong chico), cuerdas pulsadas (guzheng, pipa) y flauta dizi. Golpes cortos, con cuerpo y sin reverb larga. Nada de terror, drones graves ni ambiente oscuro.

## Formato y destino

| Tipo | Formato | Destino |
|---|---|---|
| Efecto | WAV 44,1 kHz, 16 bit, **mono**, sin silencio al inicio, pico a −1 dB | `assets/audio/sfx/<id>.wav` |
| Música | M4A (AAC 192 kbps), estéreo, **loop sin corte** | `assets/audio/music/<id>.m4a` |
| Jingle | M4A, estéreo, sin loop | `assets/audio/music/<id>.m4a` |

- OGG no sirve: iOS no lo reproduce.
- Los efectos que se repiten mucho llevan **variantes** (`hit_light_1`, `hit_light_2`, `hit_light_3`) para que no suenen a máquina; el juego elige una al azar y le cambia apenas el tono.
- Duración: efectos entre 0,1 y 1,2 s salvo que se indique otra cosa.

## Bloque de estilo (pegar al final de cada prompt de efecto)

```
Style: crisp, punchy game sound effect for a bright martial-arts card game, traditional Chinese
percussion and instruments, close and dry, no long reverb tail, no music, no voice unless stated,
clean start with no silence, mobile-friendly mix.
```

---

## 1. Prioridad MVP (lo que más cambia el feel)

Con estos 14 el combate ya se siente completo.

| id | Momento en el juego | Prompt |
|---|---|---|
| `card_deal` ×3 | Cada carta que entra a la mano (suenan en cascada) | `A single paper card flicked onto a wooden table, light quick swish and soft tap, 0.15 seconds.` |
| `card_select` | Tocar una carta para elegirla | `Soft wooden bead click with a tiny bright guzheng pluck, very short, 0.12 seconds.` |
| `card_deny` | Tocar una carta que no se puede jugar | `Dull muted wooden knock twice, short and negative but not harsh, 0.25 seconds.` |
| `card_play` | La carta sale volando hacia el objetivo | `Fast cloth-and-paper whoosh rising in pitch, energetic swipe, 0.3 seconds.` |
| `hit_light` ×3 | Golpe con daño menor a 10 | `Quick martial-arts punch impact on a padded body, tight thump with a snappy slap, 0.25 seconds.` |
| `hit_heavy` ×2 | Golpe con 10 o más de daño, o que rompe al enemigo | `Powerful kung fu strike impact, deep chinese dagu drum hit layered with a sharp slap and a short cymbal crash, 0.6 seconds.` |
| `block` | Daño absorbido por la Guardia enemiga ("Bloqueado") | `Solid block of a strike with forearm and wooden staff, hard knock with short ringing wood, 0.3 seconds.` |
| `player_hurt` ×2 | El enemigo te pega (acompaña al destello rojo) | `Heavy body hit received, low punchy thud with a short breathy grunt, not gory, 0.4 seconds.` |
| `deflect` | Desviás el golpe enemigo (化) | `Swift deflection, whoosh that bends away followed by a bright metallic shing and a small bell, 0.5 seconds.` |
| `guard_up` | Ganás Guardia con una carta de defensa | `Firm defensive stance, cloth snap and a low wooden block knock with a soft shimmer, 0.35 seconds.` |
| `enemy_windup` | El enemigo toma impulso antes de atacar | `Short tense inhale and cloth rustle building up, rising woodblock roll, 0.35 seconds.` |
| `turn_start` | Cartel "Tu turno" | `Single bright hand-drum hit followed by a quick rising dizi flute note, confident and inviting, 0.8 seconds.` |
| `victory_stamp` | Cae el sello 胜 al ganar | `Heavy ink seal stamped onto paper, deep satisfying thump followed by a bright gong swell and small bells, triumphant, 1.2 seconds.` |
| `defeat_stamp` | Cae el sello 败 al perder | `Slow heavy seal stamp on paper, soft low thud with a descending guzheng glissando, melancholic but gentle, not dark, 1.4 seconds.` |

---

## 2. Combate: el resto de los eventos

| id | Momento en el juego | Prompt |
|---|---|---|
| `fight_start` | Cartel de entrada del enemigo ("¡En guardia!") | `Martial arts duel opening, two sharp woodblock hits then a quick cymbal splash and a shout-like dizi accent, 1 second.` |
| `enemy_drop` | El enemigo cae a escena | `Light acrobatic landing on a wooden floor, soft thud with dust puff, 0.3 seconds.` |
| `break` | Enemigo Desequilibrado (inclinación y estrellas) | `Stagger and dizziness, wobbly boing-like pitch bend on a pipa string with small twinkling bells, playful, 0.7 seconds.` |
| `enemy_guard` | El enemigo gana Guardia ("+Guardia") | `Enemy raises guard, low wooden clack and armor-like cloth tighten, 0.3 seconds.` |
| `enemy_charge` | El enemigo carga ("+carga") | `Energy gathering, rising breathy whoosh with a building gong shimmer, 0.7 seconds.` |
| `enemy_skip` | El enemigo pierde su acción | `Comic fizzle, deflating whistle ending in a small wooden plonk, 0.5 seconds.` |
| `enemy_death` | El enemigo se disuelve en tinta | `Ink splash dissolving into the wind, wet brush swish turning into a soft airy shimmer, 1 second.` |
| `hero_victory` | El héroe festeja | `Quick victorious cloth flourish and a short bright guzheng run upward, 0.8 seconds.` |
| `hero_fall` | El héroe cae (derrota) | `Body slowly collapsing onto a wooden floor, soft thud and cloth, 0.6 seconds.` |
| `stance_change` | Cambiás de postura (Caballo, Arco, Vacía) | `Feet sliding firmly into a martial arts stance on wood, sharp scuff and cloth snap, 0.3 seconds.` |
| `form_step` | Avanza un paso de una forma | `Single clear guzheng pluck, rising pentatonic note, 0.4 seconds.` *(generar 5 notas ascendentes: `form_step_1` a `form_step_5`)* |
| `form_complete` | Forma completada (estallido de color) | `Martial form completed, fast ascending guzheng and pipa run ending on a bright gong and cymbal hit, triumphant, 1.2 seconds.` |
| `form_broken` | Formas interrumpidas | `Plucked string snapping with a dull detuned note, short and disappointed, 0.5 seconds.` |
| `breath_gain` | Recuperás Aliento | `Calm deep inhale with a soft airy wind chime, 0.6 seconds.` |
| `breath_spend` | Gastás Aliento al jugar | `Short sharp exhale, focused kiai breath without a word, 0.25 seconds.` |
| `phase_two` | El jefe entra en fase 2 ("El dragón despierta") | `Large gong struck hard with a rising roll of chinese drums and a sweeping wind, epic, 2 seconds.` |
| `end_rays` | Aparecen los rayos y pétalos de la victoria | `Airy celestial shimmer with gentle bells and falling petals feel, bright, 1.5 seconds.` |
| `ui_button` | Botones "Continuar", "Terminar turno" | `Soft wooden button tap with a light click, 0.1 seconds.` |

### Voces de los enemigos (una por enemigo, suena en `enemy_windup`)

| id | Enemigo | Prompt |
|---|---|---|
| `enemy_dummy` | Muñeco de madera | `Wooden training dummy creaking and knocking as it rocks, hollow wood, 0.4 seconds.` |
| `enemy_bat` | Murciélago | `Small bat screech with fast wing flutter, high pitched, cartoony not scary, 0.5 seconds.` |
| `enemy_salamander` | Salamandra | `Small salamander hiss with a crackle of fire, playful, 0.5 seconds.` |
| `enemy_golem` | Gólem | `Stone golem grinding and rumbling, rocks shifting, heavy but short, 0.6 seconds.` |
| `enemy_disciple` | Discípulo | `Young martial artist short kiai shout, energetic, 0.4 seconds.` |
| `enemy_monk` | Monje (élite) | `Deep monk kiai combined with a wooden prayer bead rattle, powerful, 0.6 seconds.` |
| `enemy_dragon` | Dragón (jefe) | `Majestic eastern dragon roar, resonant and bright with a metallic gong undertone, epic not horror, 1.5 seconds.` |

---

## 3. Fuera del combate

| id | Momento en el juego | Prompt |
|---|---|---|
| `screen_transition` | Cambio de pantalla (desvanecido) | `Very soft paper page turn with a light air swish, 0.3 seconds.` |
| `map_node` | Tocar un nodo del mapa | `Ink brush dab on paper with a soft wooden tap, 0.2 seconds.` |
| `reward_flip` ×3 | Cada carta de recompensa se da vuelta | `Card flipped over quickly with a bright small chime, 0.25 seconds.` |
| `reward_take` | La carta elegida sube al mazo | `Magical card collected, rising sparkle whoosh ending on a warm bell, 0.8 seconds.` |
| `fountain_heal` | La fuente cura (la Vida sube contando) | `Clear spring water pouring and bubbling with gentle rising wind chimes, healing and fresh, 1.5 seconds.` |
| `shrine_oath` | Jurás un camino en el santuario | `Solemn temple bell struck once with a soft incense whoosh, sacred and bright, 1.8 seconds.` |
| `run_result` | Cae el carácter del final de run | `Large calligraphy seal stamped with a deep gong and a bright cymbal shimmer, 1.5 seconds.` |

---

## 4. Música

Prompts para Suno/Udio. Todo instrumental, sin voz.

| id | Dónde suena | Prompt |
|---|---|---|
| `music_menu` | Menú y mapa, loop 1–2 min | `Instrumental loop, bright traditional Chinese folk, guzheng and dizi flute over light hand percussion, peaceful mountain morning, hopeful, 90 BPM, seamless loop, no vocals.` |
| `music_combat` | Combate común, loop 1–2 min | `Instrumental loop, energetic kung fu action, driving chinese drums, pipa riffs and dizi melody, bright and heroic not dark, 128 BPM, seamless loop, no vocals.` |
| `music_elite` | Combate contra el Monje | `Instrumental loop, intense kung fu duel, heavier dagu drums, erhu lead, gongs on accents, focused and dramatic but bright, 135 BPM, seamless loop, no vocals.` |
| `music_boss` | Combate contra el Dragón | `Instrumental loop, epic chinese orchestral battle, big taiko-style and dagu drums, soaring erhu and dizi, brass-like gong swells, majestic and heroic, 140 BPM, seamless loop, no vocals.` |
| `music_training` | Entrenamiento con el muñeco | `Instrumental loop, light playful training montage, woodblocks, plucked guzheng and cheerful dizi, 110 BPM, seamless loop, no vocals.` |
| `jingle_victory` | Pantalla de victoria (sin loop) | `Short triumphant chinese fanfare, gong hit, fast guzheng run and bright dizi melody ending on a major chord, 4 seconds, no vocals.` |
| `jingle_defeat` | Pantalla de derrota (sin loop) | `Short gentle defeat sting, slow descending guzheng and soft erhu, calm and hopeful not sad or dark, 4 seconds, no vocals.` |
| `jingle_run_won` | Run completada | `Celebratory chinese festival fanfare, drums, cymbals and dizi, joyful, 7 seconds, no vocals.` |

## Mezcla (referencia para integrarlo)

- **Volúmenes relativos:** golpes y sellos 100 %, cartas y UI 50 %, voces de enemigos 70 %, música 35 % (baja a 20 % durante el cartel de victoria o derrota, cuando entra el jingle).
- **Sincronía:** cada efecto suena en el mismo instante que su háptica y su animación (el impacto a los 330 ms del embiste del enemigo, el sello al caer).
- **Ajustes:** sonido y música con interruptores separados; se respeta el modo silencio del iPhone.
