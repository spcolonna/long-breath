# Relevamiento de arte y sonido

Qué hay, qué es prestado y qué falta, en orden de prioridad. **Antes de pedir o pasar un prompt, se mira acá**: si el archivo ya existe con arte propio, no se vuelve a generar. Cuando llega un archivo nuevo se actualiza esta tabla.

Actualizado: 2026-10-08.

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

Tramos (`_sceneFiles` en `combat_screen.dart`):

| Tramo | Etapa 1 | Etapa 2 | Etapa 3 |
|---|---|---|---|
| `ladera` | bambu | escalera | ventisquero |
| `bifurcacion` | cristales | pasarela | glaciar |
| `templo` | campanas (élite) | campanario (élite) y gran_campana (jefe) | templo_helado (élite) |
| `cumbre` | cumbre (jefe) | — | lecho_dragon (jefe) |

## Hecho, con arte propio

- **Etapa 1:** `combat_bg` más sus 4 tramos, `map_bg`, `fountain_bg`, `shrine_bg` y `school_wall`.
- **Etapa 2:** `combat_bg`, `map_bg` y `fountain_bg`.
- **Etapa 3:** `combat_bg` y `map_bg`.
- **UI:** `stage_clear_bg`.
- **NPC:** `master` y `merchant`.
- **Héroe:** `hero.png`. Los 4 caminos salen de él por recoloreo, que es así por diseño (`tool/recolor_hero.py`).
- **Enemigos:**
  - etapa 1: dummy, bat, salamander, golem, disciple, bandit, lingzhi, monkey, monk, lion, fan y dragon;
  - élites nuevos: `bell_keeper` (Guardián de la Campana, etapa 2) y `dragon_dream` (Sueño del Dragón, etapa 3).

## Pendiente, por prioridad

### 1. Enemigos de las etapas 2 y 3: hoy son recoloreos

Ya **existen**, pero son el enemigo de la etapa 1 con otro color (`VARIANTS` en `tool/recolor_enemies.py`). El arte propio **reemplaza el archivo con el mismo nombre**, y después hay que borrar su entrada de `VARIANTS` para que el script no lo pise. Los prompts están en `prompts.md` §7. **Ojo:** el Dragón Dormido y el Abad necesitan un prompt nuevo, porque los anteriores dieron `dragon_dream` y `bell_keeper`.

| Orden | Archivo | Enemigo | Rol | Sale de |
|---|---|---|---|---|
| 1 | `dragon_azure.png` | Dragón Dormido | jefe final | dragon |
| 2 | `monk_gold.png` | Abad de la Gran Campana | jefe etapa 2 | monk |
| 3 | `monk_iron.png` | Abad de Hierro | élite etapa 2 | monk |
| 4 | `lion_jade.png` | León de Jade | élite etapa 2 | lion |
| 5 | `fan_wind.png` | Dama del Viento | élite etapa 3 | fan |
| 6 | `lion_snow.png` | León de las Nieves | élite etapa 3 | lion |
| 7 | `disciple_saffron.png` | Guardián del Pasadizo | común etapa 2 | disciple |
| 8 | `golem_bronze.png` | Hombre de Bronce | común etapa 2 | golem |
| 9 | `bat_bronze.png` | Murciélago del Campanario | común etapa 2 | bat |
| 10 | `salamander_ash.png` | Salamandra de Ceniza | común etapa 2 | salamander |
| 11 | `disciple_wind.png` | Discípulo del Viento | común etapa 3 | disciple |
| 12 | `golem_ice.png` | Gólem de Escarcha | común etapa 3 | golem |
| 13 | `monkey_snow.png` | Simio de las Nieves | común etapa 3 | monkey |
| 14 | `bat_frost.png` | Murciélago de Escarcha | común etapa 3 | bat |

### 2. Fondos que el juego ya busca y no existen

| Archivo | Se ve en | Hoy muestra |
|---|---|---|
| `stages/wolongding/fountain_bg.png` | fuente de la etapa 3 | la fuente de la etapa 1 (prompt listo en §7 Tanda 3) |
| `stages/wolongding/combat_bg_cumbre.png` | pelea contra el jefe final | el `combat_bg` de la etapa 3 |
| `stages/xuankongsi/combat_bg_templo.png` | élite y jefe de la etapa 2 | el `combat_bg` de la etapa 2 |
| `stages/wolongding/combat_bg_templo.png` | élite de la etapa 3 | el `combat_bg` de la etapa 3 |
| `stages/xuankongsi/combat_bg_ladera.png`, `_bifurcacion.png` | combates comunes de la etapa 2 | el `combat_bg` de la etapa 2 |
| `stages/wolongding/combat_bg_ladera.png`, `_bifurcacion.png` | combates comunes de la etapa 3 | el `combat_bg` de la etapa 3 |

Hay prompt en `prompts.md` §7 para todos menos las dos bifurcaciones (`pasarela` y `glaciar`). El santuario solo aparece en la etapa 1, así que las etapas 2 y 3 no necesitan `shrine_bg`.

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
