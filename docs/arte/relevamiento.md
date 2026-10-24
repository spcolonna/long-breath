# Relevamiento de arte y sonido

Qué hay, qué es prestado y qué falta, en orden de prioridad. **Antes de pedir o pasar un prompt, se mira acá**: si el archivo ya existe con arte propio, no se vuelve a generar. Cuando llega un archivo nuevo se actualiza esta tabla.

Actualizado: 2026-10-11.

**El juego usa WebP.** El arte se genera y se guarda en PNG con el nombre del prompt; al integrarlo se commitea el PNG (queda en el historial de git como original) y se corre `python3 tool/optimize_art.py`, que lo pasa a `.webp` del tamaño en que se muestra y borra el PNG. Así las imágenes pasaron de 152 MB a 19 MB (11/10/2026).

**La lista exacta, archivo por archivo, está en [`checklist.md`](checklist.md)**, que genera `python3 tool/art_status.py` comparando lo que el código busca con lo que hay en `assets/art`. Ante cualquier duda, manda la checklist: se corre antes de pasar prompts y cada vez que llega arte.

## Cómo busca cada imagen el juego

| Pantalla | Primero | Si falta |
|---|---|---|
| Arena de combate | `stages/<etapa>/combat_bg_<tramo>.png` | `stages/<etapa>/combat_bg.png` → cielo dibujado |
| Mapa | `stages/<etapa>/map_bg.png` | montaña dibujada por código |
| Evento | `map_bg.png` de la etapa | el de la etapa 1 → papel |
| Fuente / Santuario | `fountain_bg.png` / `shrine_bg.png` de la etapa | el de la etapa 1 → papel |
| Etapa superada | `ui/stage_clear_bg.png` | papel |
| Registro y derrota | `qianyunshan/school_wall.png` | papel |
| Victoria | `wolongding/map_bg.png` | el de la etapa 1 |
| Enemigo | `enemies/<art>.png` | `placeholder.png` |
| Héroe | `player/hero_<camino>.png` | vacío |

Tramos (`_sceneFiles` en `widgets/stage_scene.dart`):

| Tramo | Etapa 1 | Etapa 2 | Etapa 3 |
|---|---|---|---|
| `ladera` | bambu | escalera | ventisquero |
| `bifurcacion` | cristales | pasarela | glaciar |
| `templo` | campanas (élite) | campanario (élite) y gran_campana (jefe) | templo_helado (élite) |
| `cumbre` | cumbre (jefe) | — | lecho_dragon (jefe) |

## Hecho, con arte propio

- **Etapa 1:** `combat_bg` más sus 4 tramos, `map_bg`, `fountain_bg`, `shrine_bg` y `school_wall`.
- **Etapa 2:** `combat_bg` más sus 3 tramos (`ladera`, `bifurcacion` y `templo`, el Gran Campanario), `map_bg` y `fountain_bg`.
- **Etapa 3:** `combat_bg` más sus 4 tramos (con `cumbre`, el Lecho del Dragón), `map_bg` y `fountain_bg`.
- **UI:** `stage_clear_bg`, `lotus_seed` (semilla de loto) y `reward_chest` (cofre del botín).
- **NPC:** `master` y `merchant`.
- **Héroe:** `hero.png`. Los 4 caminos salen de él por recoloreo, que es así por diseño (`tool/recolor_hero.py`).
- **Enemigos:**
  - etapa 1: dummy, bat, salamander, golem, disciple, bandit, lingzhi, monkey, monk, lion, fan y dragon;
  - élites nuevos: `bell_keeper` (Guardián de la Campana, etapa 2) y `dragon_dream` (Sueño del Dragón, etapa 3);
  - etapas 2 y 3, reemplazando el recoloreo: `monk_gold` (Abad de la Gran Campana), `monk_iron` (Abad de Hierro), `lion_jade` (León de Jade), `dragon_azure` (Dragón Dormido), `fan_wind` (Dama del Viento), `lion_snow` (León de las Nieves) `golem_bronze` (Hombre de Bronce), `disciple_saffron` (Guardián del Pasadizo), `bat_bronze` (Murciélago del Campanario) y `salamander_ash` (Salamandra de Ceniza), `disciple_wind` (Discípulo del Viento), `golem_ice` (Gólem de Escarcha), `monkey_snow` (Simio de las Nieves) y `bat_frost` (Murciélago de Escarcha);
  - de concepto nuevo: `paper_crane` (Grulla de Papel), `opera_mask` (Ópera de las Mil Caras), `pixiu` (Pixiu), `flying_sword` (Espada Voladora), `wooden_ox` (Buey de Madera), `qilin` (Qilin) y `guqin_player` (Músico del Guqin).
- **Mapa:** `map_node_stone` (textura de los sellos).
- **Listas para cuando haya código:** `ui/logo`, los 6 íconos de `icons/`, los 5 marcos de `cards/` y la ilustración de `gongbu_chongquan`.

## Reserva de recoloreos

Cuando un recoloreo recibe arte propio, su versión teñida no se pierde: queda en `VARIANTS` con otro nombre para usarla en un enemigo secundario. Hoy: `dragon_reflection` (en uso, Reflejo del Dragón), `monk_amber` (Monje del Incienso), `monk_slate` (Ermitaño de Pizarra) y `lion_celadon` (León de Celadón), en uso.

## Pendiente, por prioridad

### 1. Enemigos y fondos

Ya no falta ninguno: todos los enemigos tienen arte propio o un recoloreo de la reserva, y existen todos los fondos que busca el juego.

### 2. Sonido: no hay ningún archivo

`assets/audio/` está vacío, así que hoy el juego no suena. Los prompts están en `docs/arte/sonido.md`.

- Faltan 39 efectos (53 archivos contando variantes) y 8 músicas.
- La voz de cada enemigo se busca por su **id** (`sfx/enemy_<id>`), no por su arte. Hay prompt solo para 7 de los 33.

### 3. Ideas (el código todavía no las usa)

- Faltan 19 ilustraciones de cartas (bloques F y G de `prompts.md`).
- El logo, los íconos, los marcos y `gongbu_chongquan` ya están en webp, pero no van en `pubspec.yaml` hasta que el código los use.
