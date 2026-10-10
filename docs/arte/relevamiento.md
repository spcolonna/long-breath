# Relevamiento de arte y sonido

Qué hay, qué es prestado y qué falta, en orden de prioridad. **Antes de pedir o pasar un prompt, se mira acá**: si el archivo ya existe con arte propio, no se vuelve a generar. Cuando llega un archivo nuevo se actualiza esta tabla.

Actualizado: 2026-10-10.

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
  - etapas 2 y 3, reemplazando el recoloreo: `monk_gold` (Abad de la Gran Campana), `monk_iron` (Abad de Hierro), `lion_jade` (León de Jade), `dragon_azure` (Dragón Dormido), `fan_wind` (Dama del Viento), `lion_snow` (León de las Nieves) y `golem_bronze` (Hombre de Bronce).

## Reserva de recoloreos

Cuando un recoloreo recibe arte propio, su versión teñida no se pierde: queda en `VARIANTS` con otro nombre para usarla en un enemigo secundario. Hoy: `dragon_reflection` (en uso, Reflejo del Dragón), `monk_amber`, `monk_slate` y `lion_celadon` (sin usar todavía).

## Pendiente, por prioridad

### 1. Enemigos de las etapas 2 y 3: hoy son recoloreos

Ya **existen**, pero son el enemigo de la etapa 1 con otro color (`VARIANTS` en `tool/recolor_enemies.py`). El arte propio **reemplaza el archivo con el mismo nombre**, y después hay que borrar su entrada de `VARIANTS` para que el script no lo pise. Los prompts están en `prompts.md` §7.

| Orden | Archivo | Enemigo | Rol | Sale de |
|---|---|---|---|---|
| 1 | `disciple_saffron.png` | Guardián del Pasadizo | común etapa 2 | disciple |
| 2 | `bat_bronze.png` | Murciélago del Campanario | común etapa 2 | bat |
| 3 | `salamander_ash.png` | Salamandra de Ceniza | común etapa 2 | salamander |
| 4 | `disciple_wind.png` | Discípulo del Viento | común etapa 3 | disciple |
| 5 | `golem_ice.png` | Gólem de Escarcha | común etapa 3 | golem |
| 6 | `monkey_snow.png` | Simio de las Nieves | común etapa 3 | monkey |
| 7 | `bat_frost.png` | Murciélago de Escarcha | común etapa 3 | bat |

### 2. Fondos

Ya existen todos los que busca el juego: los 4 tramos de combate y la fuente de las tres etapas. El santuario solo aparece en la etapa 1, así que las etapas 2 y 3 no necesitan `shrine_bg`.

### 3. Opcional

- `stages/qianyunshan/map_node_stone.png`: textura de los sellos del mapa (512×512, transparente). Sin ella queda el disco con degradado.

### 4. Sonido: no hay ningún archivo

`assets/audio/` está vacío, así que hoy el juego no suena. Los prompts están en `docs/arte/sonido.md`.

- Faltan 39 efectos (53 archivos contando variantes) y 8 músicas.
- La voz de cada enemigo se busca por su **id** (`sfx/enemy_<id>`), no por su arte. Hay prompt solo para 7 de los 33.

### 5. Ideas (el código todavía no las usa)

- Fondo de inicio y logo (§1).
- Marcos y 20 ilustraciones de cartas (§4).
- 6 íconos (§5).

Antes de generarlas hay que preparar el código y `pubspec.yaml`.
