# NOTAS — estado del trabajo (para seguir desde un chat nuevo)

Última actualización: 06/11/2026 · rama `main`, pusheado.

## Qué es
Long Breath: roguelike de cartas de kung fu en Flutter (iOS), en español. Subís una montaña de 3 etapas (11 pisos cada una) peleando con cartas de postura.
- Manual de reglas: `docs/manual.md`
- Guía de feel: `docs/feel.md`
- Balance: `docs/balance.md`
- Ideas a futuro: `docs/futuro.md`
- Arte: `docs/arte/` (`prompts.md`, `relevamiento.md`)

## Reglas de trabajo (del usuario)
- **Comunicación:** responder en español, conciso y con el resultado primero. Para investigar código, usar subagentes (Explore/Plan).
- **Commits:** firmar con `git -c user.name=spcolonna -c user.email=spcolonna@gmail.com commit ...`. El mensaje termina con `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Después, push.
- **Estilo:** nada oscuro. Feel premium según `docs/feel.md`, con háptica en todo lo nuevo.
- **Ideas a futuro:** van en `docs/futuro.md`.
- **Formato:** nunca correr `dart format` sobre directorios enteros ni sobre `combat_screen.dart`.
- **Arte:**
  - correr `python3 tool/art_status.py` antes de pasar prompts;
  - no pedir imágenes repetidas y avisar si algo es recoloreo;
  - un prompt por imagen.
- **Disco y capturas:**
  - Hay poco disco: borrar capturas, temporales y `build/ios` al terminar.
  - No mirar capturas salvo para verificar algo visual. Si hace falta una, achicarla (`sips -Z 600` o scale 0.5) y hacer zoom a la zona que importa.
  - Para texto y estructura usar logs, tests, `read_page` o `get_page_text`.
  - Nada de capturas, videos ni datos de simulación en el repo: van al scratchpad y se borran al terminar.
  - Si se crean simuladores para una prueba, borrarlos al final.
- **Dónde va lo importante:** los números, conclusiones y decisiones se anotan en este archivo.
- **Al terminar cada tarea:** recomendar la siguiente sin que lo pida.

## Simulador (no perder la partida del usuario)
- **Dispositivo:** `D3BAFB7A-9E93-47CA-ADBC-349354810298`, bundle `com.oraki.longBreath`.
- **No tocar:** el simulador «Sandora Test» (430B221E) corre otra app, ZenGarden.
- **Probar** en partidas distintas de la Partida 1.
- **Antes de instalar, respaldar.** Al reinstalar cambia la ruta del contenedor, así que hay que recalcularla.

```bash
C=$(xcrun simctl get_app_container D3BAFB7A-9E93-47CA-ADBC-349354810298 com.oraki.longBreath data)
cp "$C/Library/Preferences/com.oraki.longBreath.plist" <scratchpad>/backupN.plist
cp -R "$C/Documents/run_logs" <scratchpad>/runlogsN
```

- **Instalar:**

```bash
flutter build ios --simulator --debug
xcrun simctl install D3BAFB7A-9E93-47CA-ADBC-349354810298 build/ios/iphonesimulator/Runner.app
xcrun simctl launch D3BAFB7A-9E93-47CA-ADBC-349354810298 com.oraki.longBreath
```

- **Después:**
  - comparar el plist con `cmp` usando la ruta nueva del contenedor;
  - si cambió, restaurar el respaldo;
  - borrar `build/ios`.
- **No sirve** `simctl spawn defaults` para el guardado.

## Registro de subidas
- **Dónde está:** cada subida queda en texto en `$C/Documents/run_logs/slot<N>/actual.log`. Las anteriores se archivan con fecha y se guardan las últimas 20 por partida.
- **Qué incluye:** camino y alternativas, jugadas, estado por turno, botín, compras y eventos.
- **Desde la app:** el botón «Copiar registro» lo copia.
- **Para revisarlo rápido:**

```bash
grep -E "CAMINO|gana el combate|pierde|compra|evento:|respira|COMBATE" actual.log
```

## Comandos útiles

```bash
flutter analyze
flutter test                          # 306 tests, todos pasan
python3 tool/make_audio.py            # regenera todo el sonido (o: make_audio.py <id>)
dart run tool/simulate.dart --runs 300 --profile promedio --difficulty normal   # ~45 s
dart run tool/simulate.dart --runs 300 --profile experto --difficulty normal
flutter gen-l10n                      # tras editar lib/l10n/app_es.arb
python3 tool/art_status.py
python3 tool/optimize_art.py          # tras agregar PNG de arte
```

macOS no tiene `timeout`.

## Rutas clave
- **Motor de combate:** `lib/domain/combat/combat_engine.dart` y los eventos en `combat_event.dart`.
- **Pantalla de combate:** `lib/delivery/screens/combat_screen.dart` (enorme; no formatear).
- **Efectos visuales:** `lib/delivery/widgets/juice.dart` (Shake, Bounce, ArtBurst…), `hero_sprite.dart` y `enemy_sprite.dart`.
- **Registro:** `lib/delivery/log/run_log.dart`.
- **Datos:** `assets/data/` (`enemies.json`, `cards.json`, `game_balance.json` con pools por piso, `events.json`, `forms.json`, `talismans.json`, `weapons.json`).
- **Textos de UI:** `lib/l10n/app_es.arb`. **Textos de contenido:** `assets/l10n/content/es.json`, que se edita como texto, nunca con `json.dumps`.

## Hecho en esta sesión
- **13/11 — 6 imágenes nuevas (169/169 en `art_status`, sin recoloreos de enemigos):**
  - Retratos `npc/shuang`, `npc/ming` y `npc/tie`: en los eventos (`eventPortrait` en `event_screen.dart`; `NpcPortrait` de 150 con el sello del evento en lugar del círculo con hanzi) y Shuang en sus pergaminos del registro.
  - Élites `dragon_reflection` y `lion_celadon` con arte propio; `VARIANTS` de `tool/recolor_enemies.py` quedó vacío.
  - Ícono `icons/page` (vía `GameIcon(Icons.history_edu)`): en la página que sale del cofre y en los pergaminos `page_*`.
  - Test `test/event_portrait_test.dart`. Prompts marcados ✅ en `docs/arte/prompts.md`.
- **`c0119ca` — cartel de «¡Forma completa!»:**
  - Antes se cortaba porque el slow motion (`timeDilation`) estiraba la animación mientras un timer de reloj lo quitaba.
  - Ahora se quita en `onEnd` de la animación.
  - Muestra un rótulo, el nombre, el hanzi y pinyin, y una píldora con el efecto.
  - Dura 2,6 s, o 3 s si es forma larga, y tiene háptica triple.
  - Los pasos de la forma quedan dorados un momento en el panel.
- **`67f200e` — Respirar:**
  - Con la mano vacía robaba 0 y gastaba Aliento igual.
  - Ahora roba `max(mano, breatheMinDraw)`, con `breatheMinDraw: 3` en `game_balance.json` → `player`.
  - Lleva test, y se actualizaron el tutorial y el manual.
- **`67f200e` — golpe que se veía doble:**
  - `Shake` (en `juice.dart`) devolvía el hijo solo cuando estaba quieto y `Transform` cuando animaba. Ese cambio de árbol rearmaba la arena al empezar y al terminar la sacudida, y se repetían las entradas del héroe y del rival.
  - Pasaba solo con golpes pesados: los que desequilibran, pegan 10 o más, o matan.
  - Ahora siempre devuelve `Transform.translate`.

- **Arte (06/11):** integradas las 6 cartas de cadena de postura (`ma_zhuan_gong`, `gong_zhuan_xu`, `xu_zhuan_ma`, `hu_hui_shen`, `she_zhuan_shen`, `he_luo_di`) y el arte propio de `monk_amber` (Monje del Incienso) y `monk_slate` (Ermitaño de Pizarra), que salieron de `VARIANTS` en `tool/recolor_enemies.py`. 
- **Arte completo (06/11):** integradas las 17 que faltaban (5 de la Grulla y 12 de arma). `art_status.py`: 160 ✅ · 2 🎨 · 0 ❌. `jian_chuanxin` llegó apaisado (1536×1024) y se recortó al contenido y se dejó cuadrado. Los 2 recoloreos (dragon_reflection, lion_celadon) son por diseño.

## Hecho (06/11, antes de la build +3)
- **Sonido:** no había ni un archivo, todo era silencio. `tool/make_audio.py` sintetiza:
  - 109 efectos, con una voz por cada uno de los 49 enemigos;
  - 5 loops de unos 70–80 s y 3 jingles en OGG, unos 11 MB en total.
  - `Sfx` nuevos: `tap`, que suena en cada botón vía `Haptics.tap`, más `scroll_open`, `realm_up`, `achievement`, `heal`, `talisman_trigger` y `weapon_trigger`.
  - `test/audio_assets_test.dart` comprueba que no falte ningún archivo.
- **Trampa de compilación:** después de `flutter build ipa`, el simulador puede quedarse con el `objective_c.framework` de iPhone. Entonces `path_provider` no carga, el audio cae en silencio y el log muestra `audio: Invalid argument… objective_c`. Se arregla con `flutter clean` antes de compilar para el simulador. Si funciona, el log dice `audio: 109 efectos y 8 pistas`.
- **Legibilidad:**
  - `PaperPanel` y `Palette.halo` en santuario, resultado, maestro, recompensa, registro y etapa superada.
  - El beneficio de cada animal se lee entero.
- **Rival en pergamino:** `ScrollFrame` (extraído de `LoreScroll`) y `widgets/enemy_scroll.dart`. Se abre al tocar la placa, el globo o las escamas.
- **Enemigos chicos:**
  - El globo de intención va al frente y es compacto: con un enemigo muestra chips cortos; con dos, «+N».
  - El sprite tiene un mínimo de 112 px con dos enemigos y 150 px con uno, y crece hacia arriba (`OverflowBox`).
  - En el caso de la Dama del Viento con el Murciélago de Escarcha pasó de 58 a 112 px. Lo cubre `test/enemy_size_test.dart`.
- **Mapa y balance:** ver `docs/balance.md` §3j.
  - Máximo 2 lugares seguidos sin combate y mínimo 6 combates por camino.
  - Entre etapas se cura el 40% de lo que falta.
  - Normal: promedio 24% → 16%, experto 56% → 51%.
- **Íconos:**
  - Los 3 de combate (`heart`, `charge`, `stolen`) ya están integrados (`87c25c2`).
  - Los talismanes y el arma siguen como sellos de hanzi, por diseño.

## Análisis de balance (06/11, Normal, Partida 1)

**Registros del usuario:**

| Subida | Final | Detalle |
|---|---|---|
| 1 | Piso 8 | Muere con el gólem: entra con 27 de Vida y lo deja en 18/81. Lo remata un golpe de 21 contra una guardia a la altura equivocada. |
| 2 | Piso 5 | El discípulo del piso 2 (85 de Vida) le baja de 50 a 9. Muere después con gólem y discípulo juntos. |
| 3 | Jefe del piso 11 | Llega con 40/52. Deja al dragón en 17/173 y muere con su golpe de fase 2 (30, recibe 25). |

**Sensación del usuario:** subir hasta el gólem o el jefe es demasiado fácil. Morir con el gólem no le molesta. Decidió **no tocar el gólem**.

**Simulación de referencia** (promedio, Normal, 300 runs): 32% de victorias. Llega a la etapa 2 el 58% y a la etapa 3 el 42%.
- **Comunes de la etapa 1:** unos 3 turnos y entre 3 y 8 de Vida perdida. El murciélago pierde 4,3, el mono 3,1, la salamandra 8,2 y el bandido 7,3.
- **Comunes de la etapa 2:** el murciélago de hielo, el simio de nieve, la espada voladora y el guqin caen en unos 2,2 turnos y quitan menos de 3 de Vida.
- **Los picos** son el discípulo (10,5), el gólem (13,4), el hombre de bronce (15,6), los élites (entre 15 y 17) y los jefes.

**Conclusión:** la dificultad está concentrada en unos pocos picos y los comunes son de trámite. El objetivo de balance es una escuela nueva con promedio cerca del 26% (ver `docs/balance.md`).

## Balance hecho (06/11)
- Más Vida para los comunes débiles y el discípulo fuera del piso 2. Promedio 32% → **26%**, experto 58% → 59% (Normal, 300 runs). Detalle en `docs/balance.md` §3f.
- **Hallazgo:** los comunes de la etapa 3 no se alargan subiendo la Vida (siguen en ~2,6 turnos y quitan ~3 de Vida).
- **Etapa 3 con más daño** (murciélago de hielo, simio de nieve, espada voladora, guqin, buey, discípulo del viento): Vida perdida por pelea ~3,5 → ~4,6; promedio 26% → **23%**, experto 59% (igual). Detalle en `docs/balance.md` §3h. Más números rinden poco: sus golpes son altos y se desvían; lo siguiente sería mecánico.
- **Etapa 3 con mecánica (06/11):** nuevo `"wear": true` en intents (cada golpe gasta la Guardia; ver `docs/balance.md` §3i). Murciélago y guqin desgastan, simio y buey pegan de entrada, la espada cambia de altura. Se devolvió parte del daño crudo. Promedio **24%**, experto **56%**; Vida perdida con esos comunes 4–5 → 6–7,6. Subir estructura no alarga peleas (descartado).

- **13/11 — Relevamiento de salto de calidad:** `docs/salto-de-calidad.md` (solo propuestas, nada implementado). Ejes: pelea viva (Flujo, Respirar recargable, contragolpe, enemigos que reaccionan), romper la estrategia «siempre Vida», etapa en 3 actos con dominio propio, mapa como sendero ilustrado, escuela que crece, historia, lavado de interfaz (tipografías, íconos pintados, shaders) y audio real. Se sugiere empezar por las fases A (lavado visual, 0 arte) y B (pelea viva, 5 imágenes).
  - **Dato del usuario:** la etapa 1 se termina en ≤15 min y eligiendo siempre Vida se llega muy alto sin esfuerzo. El bot promedio (4% sin árbol) **no representa** a una persona: hace falta un bot «prudente» (Vida primero) y comparar con los `run_logs`. El usuario prefiere etapas más largas con progresión dentro de la etapa, no más cortas.

## 13/11 — Aplicando docs/salto-de-calidad.md (fase A en curso)
- Hecho: tipografías (Alegreya cuerpo, Cormorant títulos ≥20 pt, Ma Shan Zheng respaldo de hanzi; `docs/arte/fuentes.md`) y grano de papel por shader (`shaders/paper.frag`, `PaperGrain` en `backdrop`).
- Hecho: rareza de cartas (`CardRarity`, clave `rarity` en `cards.json`): 21 raras y 1 legendaria por camino (hu_pu, jin_she, he_ming); iniciales y armas, comunes. Premios y tienda sortean con peso común 4 / rara 3 / legendaria 1 y recargo en tienda +5 / +15 (`rewards.rarityWeights` y `raritySurcharge` en `game_balance.json`). En la carta: forma del tipo bajo el costo (palma círculo, puño cuadrado, patada triángulo, defensa escudo, técnica rombo), gema de rareza en el adorno del pie y destello de oro que cruza el marco de las legendarias (quieto con movimiento reducido); todo con `Semantics`. Simulación Normal, 300 runs: promedio 4% y experto 23% igual que sin pesos (el bot promedio sigue sin representar al jugador; fase C).
- Sigue en A: bordes de pincel y oro con brillo en el resto de la interfaz, HUD de combate, glosario tocable; antes del HUD, partir `combat_screen.dart`.
- Ojo: no correr `dart format` en archivos viejos (reformatea miles de líneas); hacer cambios mínimos.

## Pendiente
1. Probar la build +2: que suene todo (música por pantalla, toques, golpes) y si la etapa 3 sigue fácil. Seguir juntando registros del usuario y comparar turnos y Vida perdida por piso con la simulación.
2. Probar en el juego la etapa 3 nueva (desgaste, embestida del buey, espada que cambia de altura) y ver si la línea «Cada golpe gasta tu Guardia» se entiende. Las peleas siguen cortas (~2,5 turnos).
3. **TestFlight:** pantalla de carga hecha (`71a2648`, logo sobre papel). Hecho también: solo iPhone y solo vertical, `ITSAppUsesNonExemptEncryption=false` y `ios/Runner/PrivacyInfo.xcprivacy` (UserDefaults, CA92.1; no recopila datos). Ficha, textos de TestFlight y paso a paso en `docs/testflight.md`; política de privacidad en `docs/privacidad.md` (URL de GitHub, repo público). Bundle `com.oraki.longBreath` (iOS y Android). IPA `0.1.0+1` (06/11) con ícono de Flutter e iOS 13. IPA `0.1.0+2` (06/11): ícono propio (fuente en `docs/arte/app_icon.webp`, integrado con `python3 tool/make_app_icon.py icon <png>`) y target mínimo iOS 15.0 (aviso 90068). **Solo se subió el `0.1.0+1`; el +2 y el +3 locales no se subieron. IPA `0.1.0+2` rehecho (06/11) con todo: sonido, legibilidad, pergamino del rival, balance de §3j y los 3 íconos nuevos (Vida, carga, jade robado). El próximo tiene que ser `+3`.** IPA `0.1.0+3` (interfaz nueva, `70bdc98`) **subido el 09/11**; `build/` borrado. IPA `0.1.0+4` (mapa con niebla, tregua, paso de montaña, emboscadas; `8f8a24b`) armado el 09/11 y no subido. IPA `0.1.0+5` (estancias, campamento con votos, sueños del dragón, guardados robustos; `c8f4083`) armado el 10/11: reemplaza a la +4, falta subirlo; borrar `build/` después. IPA `0.1.0+6` rehecho el 12/11 sobre `918238e` (sendero de salas, balance «Duro», enemigo visible, hilos de Shuang y Tío Bao, páginas sueltas y crónica): reemplaza a la +5, falta subirlo; borrar `build/` después. IPA `0.1.0+7` armado el 17/11 sobre `55a5cd9` (fases A, B y C hasta fuente pareja): reemplaza a la +6, falta subirlo; borrar `build/` después. La próxima es `+8`. El usuario crea la app en App Store Connect.
4. **Interfaz (07/11), va en la +3:** hecho:
   - botones con cuerpo de papel desde el tema;
   - `ScrollPanel` (marco y fundido) en registro, lecciones, meridianos, maestro, mercader y resultado; fundido solo en partidas, evento y etapa superada;
   - barra dorada y rebote global (`GameScrollBehavior`);
   - papel o halo bajo el texto suelto en evento, fuente, legado, talismanes, etapa superada, inicio y mercader.

   - mercader en pestañas (Cartas · Objetos · Servicios), sin «Hay más abajo»;
   - hitos del resultado en una fila de sellos (`HitoSealRow`); tocar uno muestra cómo se cumplió;
   - `ScrollPanel(hug: true)` + `shrinkWrap`: el marco abraza listas cortas (lecciones, meridianos, maestro).
5. **Mapa con niebla (09/11), va en la +4:**
   - Solo se ven las opciones de ahora, lo ya andado y la cumbre (jefe, atenuado): no se puede leer de antemano el camino fácil. Senderos solo entre lugares vistos.
   - Sellos más grandes (60/64/72 px, placa 12,5 px) y pisos más altos (`mapRowH` 126); `_bottom` 250 para que la tarjeta no tape el primer piso.
   - Elegir en dos pasos: tocar un lugar lo agranda y abre una tarjeta abajo (sello, nombre, qué ofrece, «Ir»); tocarlo de nuevo o «Ir» va. Sin elección, pista «Tocá un lugar…». Las opciones nuevas suben de la niebla una tras otra.
   - Falta probarlo en el teléfono (sobre todo si el paso extra molesta o suma).
6. **Cada nodo como un tramo (09/11), va en la +4:** tregua entre oleadas (se llamaba «respiro»; se renombró porque chocaba con el botón Respirar) (`175e101`), paso de montaña con 3 combates y seguir/volver (`a6f2156`) y emboscadas por etapa (ver `docs/futuro.md`). Simulación Normal, 300 runs: antes promedio ~22–24% y experto ~53–58%; con todo, promedio ~26–29% y experto ~61%. Queda un poco fácil: si se confirma en el teléfono, endurecer la emboscada (escabullirse 50%, −6) o la tregua (cura 8%). Falta probar en el teléfono la tarjeta de la tregua y la pantalla del paso.
7. **Estancias (10/11), después de la +4:** todo nodo de pelea (salvo élite fijo y jefe) es una estancia: 2 salas en los pisos 1–2 y 3 más arriba (`rooms` por piso en `game_balance.json`), sin volver al mapa (salir a mitad retoma en la pausa), tregua entre salas (`/stay`, reponerse ya o concentrarse/afilar para la sala siguiente) y cartas **solo en el cofre** del final (decisiones del usuario). El paso de montaña desapareció (los guardados viejos se leen como estancia). Palancas `run.stay`: Vida de comunes por sala 75/70/65%, jade de las salas intermedias 50%, cura entre salas 0. Simulación Normal, 300 runs: promedio **23%**, experto **62%**; subida ganada **~90 min** (meta vieja 45–75; el usuario acepta que sea más larga). Probadas: 4 salas arriba (promedio 14%), Vida 70/65/60 (21/67), cura 5% (35/80), jade 30% (16/51). Pendiente: medir repetición de enemigos y, si cansa, más comunes por etapa o una etapa más.
10. **Sendero de salas y «Duro» (11/11), va en la +6:** pedido del usuario tras jugar la +5: sentir la subida dentro de la etapa, sin curarse en cada sala, eventos y maestro como parte del camino (Hades/Absolum) y que el árbol pese. Hecho:
   - **Enemigo invisible** (`7f22ada`): en la oleada 2 el sprite heredaba la animación de caída (25% más grande, 26 px más arriba, cabeza bajo el globo). Test `enemy_wave_sprite_test`.
   - **Sendero** (`3ef45e8`): se va el mapa de nodos. Etapa = 13 salas que se abren de a una fila al entrar a cada sala (`path_gen.dart`, `RunEngine._openDepth`); 2–3 puertas con sello y **premio a la vista** (`MapNodeDef.reward`). Reglas `run.path`: mín. 8 peleas, máx. 2 salas seguidas sin pelear, maestro antes de la sala 8, mercader como puerta (cada ~4 peleas; en la 10 si no hubo), un desvío de élite por etapa. Sala 11 guardián, 12 fuente, 13 jefe. Barra de altitud (0–1.400 / 2.700 / 3.900 m), ladera que sube, discípulo que trepa; en combate «646 m · 7/13». Sin cura entre oleadas (`breather.healPct` 0). Los guardados viejos siguen con su mapa completo hasta terminar la etapa. Las estancias quedaron sin uso (código de salas y `/stay` por limpiar).
   - **Textos, lección y manual** (`8f060a3`).
   - **Balance «Duro»** (este commit): Normal enemigos 105/106 (Fácil 97/98, Difícil 108/110, Shifu 112/113); árbol con Vida +2/+8, cura al ganar +1/+1, Estructura +2, Aliento primer turno, +1 Respirar, 2 cartas templadas; loto 2 por pelea (élite 5, jefe 10, cumbre 20); reinos ×1,5 (135/375/690/1080/1575). Simulación Normal 300 runs (todo abierto): sin árbol promedio **4%** / experto **26%**; medio árbol **29%**; árbol completo **52% / 83%**. Escuelas (`--section meta`): el promedio gana su primera cumbre en la subida **9** (p25 6, p75 12) y completa el árbol hacia la **26**; el experto, en la 3 y la 18.
   - Ver la pantalla: `test/zz_shot_test.dart` (local, excluido de git) saca una captura de 440×956 con `flutter test test/zz_shot_test.dart --dart-define=OUT=<png> --dart-define=STEPS=6`.
   - Limpieza (12/11): fuera estancias (`RoomDef`, `rooms`, `roomStep`/`roomBoon`, fase `roomBreak`, `/stay`), `map_gen`, `map_layout`/`trail_painter`/`mountain_backdrop` y claves `stay*`. `mapRows` vive en `lib/domain/run/map_rows.dart`. Guardados viejos: la pausa entre salas o el paso siguen por las puertas.
   - Pendiente: probar en el teléfono; música por etapa y resto del plan pro.
9. **Plan «juego pro» (10/11):** `docs/plan-pro.md` (orden y decisiones) y `docs/historia.md` (biblia: nombres, sueños, votos).
   - **Hecho:** paso 1 (caída bien atribuida, guardados robustos, `errors.log` en Documents) y paso 3 parcial (campamento entre etapas con carta del maestro o sueño del dragón y voto opcional; un sueño nuevo en cada caída).
   - **Falta medir con simulación:** si conviene que los bots usen votos (hoy los bots no votan).
   - **Hilos (12/11):** Shuang (5 capítulos de evento, uno por subida, con lazo amable u orgulloso y dos finales) y Tío Bao (se presenta y cuenta un capítulo por subida si le compraste algo; en el 5, 10% de descuento). Marcas en `ProgressStorage.threads`, pergaminos `shuang_*` y `bao_*` en el registro. Detalle en `docs/historia.md`. Simulación sin cambios (promedio 4%, experto 28% sin árbol).
   - **Siguiente:** herido y herrero como hilos; páginas sueltas en el cofre y bestiario (plan pro 1.4).
8. Opcional: un lugar lacrado de la Grulla en el santuario, que muestre «se abre en 筑基 · 58/90».

## Notas técnicas
- Si un widget de animación devuelve `child!` cuando está quieto y lo envuelve cuando anima, el subárbol se remonta. Hay que devolver siempre el mismo tipo de widget.
- Los banners de combate se sacan con `onEnd` de la animación, nunca con timers de reloj, por `timeDilation`.
- El evento `FormCompleted` se emite en `combat_engine.dart` (`_advanceForms`).
- 12/11 Cofre y crónica (base, sin UI todavía): páginas sueltas `page_1..12` (15% por cofre, 1 por subida, marcas en `threads`, pergamino en el registro; motor `_page` con generador aparte) y crónica de enemigos (`chronicle.dart`, clave `bestiary` con victorias/caídas, `bestiaryProvider`, `enemies.<id>.lore` en es.json). **UI hecha (12/11):** la página se lee en reward_screen antes del botín (`_PageFound`) y el registro tiene la 5.ª pestaña «Crónica» (`widgets/chronicle_view.dart`, `/registry?tab=4`). Tests de motor, guardado, datos y pantalla; 311 en verde. Falta probarlo en el simulador/teléfono.

- Fase A (4/n): `combat_screen.dart` partido con `part` en `screens/combat/` (arena, enemy_stage, player, hand, action_bar, end_overlay); el estado (`_CombatScreenState`, ~1570 líneas) queda en el archivo principal. Sin cambios de código: contenido idéntico línea a línea, 314 tests.
- Fase A (5/n): HUD de combate. Placa del héroe (escudo de Guardia, Vida y Estructura en una pieza de papel con filo de oro) y sello de laca de la postura a la derecha: tocarlo es el Paso en T (el botón de la barra se fue; anclas de tutorial `stances`/`dingbu`/`guard` intactas). Abajo: medallón de Aliento con puntos en el arco, Respirar en píldora y Terminar turno grande. La fila de 3 posturas desapareció: la escena gana alto. Lugar previsto para el Flujo (fase B): a la izquierda de la placa. Captura de revisión: `test/zz_combat_shot_test.dart` (excluido de git, `--dart-define=OUT=...`).

### Fase A (6/n): glosario tocable (2026-11-16)
- `lib/delivery/widgets/glossary.dart`: 20 términos (`Term`, cada uno con hanzi y relacionados), explicaciones en `gloss*`/`term*` del ARB.
- `GlossaryText`: subraya en oro punteado los términos dentro de un texto (tabla de patrones en castellano; al traducir hace falta una por idioma). Se usa en el detalle de premio y del mercader.
- `showGlossary`: hoja de papel con sello, explicación y «Ver también»; tocar un relacionado cambia el contenido en el lugar.
- `showCardDetail`: pulsación larga sobre una carta (mano en combate y hoja del mazo) muestra la carta grande, su efecto y pastillas de términos. Antes el efecto solo se leía en premios y tienda.
- Tocables en combate: escudo de Guardia, fila de Estructura, medallón de Aliento y los chips del rival (Guardia, Espinas, Curación, Desequilibrado, Despierto, Abanico, Ladrón). Escamas sigue abriendo el pergamino del rival.
- Descubrimiento: pista en la hoja del mazo y una frase nueva en `tutHand`.
- Tests: `test/glossary_test.dart` (patrones, textos completos, ficha → glosario → relacionado). 319 pasan. No probado en el simulador.

### Fase B (1/n): Flujo (2026-11-16)
- Motor: `CombatState.flow` (0–3, `CombatEngine.flowMax`). Sube +1 al encadenar postura, desviar y cerrar forma; baja −1 con un golpe que entra sin Guardia (`!blocked && taken > 0`) y al terminar un turno sin jugar cartas. Evento `FlowChanged(level, delta, cause)`; también en el registro de subidas.
- Qué da: Flujo ≥1 → ataques +1 (`flowDamage`, va por `_styleDamage`, así la vista previa lo muestra); ≥2 → +1 carta al empezar el turno; 3 → también +1 Aliento. Todavía no hay Técnica del Camino (gasta el Flujo 3) ni capas de música/fondo.
- Vista: medidor 流 con tres tramos (jade, jade, oro) a la izquierda de la placa del héroe; con el máximo se dora. Vibra en cada cambio; cinta «Flujo 3» al llegar al tope. Tocarlo abre el término nuevo del glosario (`Term.flow`). Entra en 375 pt.
- Simulación Normal, 150 runs: promedio 2% → 3%, experto 23% → 27%. Sube algo; el ajuste fino va con la fase C (bot prudente).
- Tests: grupo `Flujo` en `combat_engine_test.dart` (desvío, golpe y turno quieto, tope, beneficios por nivel), medidor en `stance_chain_test.dart`. 323 pasan. No probado en el simulador.

### Fase B (2/n): Respirar recargable con modos (2026-11-16)
- Motor: `breathesLeft` ahora son cargas listas y `CombatState.breathCharge` los pasos hacia la próxima. Un paso al desviar, al cerrar una forma y al terminar el turno con Aliento sin gastar («aliento contenido»). `balance.player`: `breatheChargeAt` 3 pasos por carga, `breatheMax` 2 guardadas (con el tope no avanza). Se empieza con `breathesPerCombat` (1) + 百会 + picos; el Pico 9 ahora es «Empezás sin Respirar cargado» (se puede cargar).
- `Breathe(mode)`: `hand` (como antes: cambia la mano, cuesta `breatheCost`), `breath` (+`breatheBreath` 2 Aliento, gratis), `structure` (+`breatheStructure` 5 E hasta el máximo; `Invalid.structureFull` si está completa). Eventos `BreatheCharged`, `Breathed`, `StructureRecovered`.
- Vista: píldora de Respirar con aro de carga (un arco por paso, cargas al centro, rebota al cargarse); al tocarla, hoja con los tres modos (换 气 稳). En las lecciones solo se habilita cambiar la mano. Cinta «Respirar cargado» al completarse una carga. Textos de «una vez por combate» reescritos (tutorial, lección de formas, glosario, meridiano, pico).
- Bots: `breatheMode` (Estructura si está por romperse, mano si no hay ataque pagable, Aliento si le falta poco para atacar; con el tope gasta).
- Simulación Normal, 150 runs: promedio 3% → 7%, experto 27% → 35%. La ganancia viene casi toda de los modos sobre la carga inicial: con peleas de 2–3 turnos los bots casi no completan una recarga (con `breatheChargeAt` 3, 4 o 99 da igual). En jefes y élites sí pesa. Ajuste con la fase C.
- Tests: grupo `Respirar recargable` en `combat_engine_test.dart` (modos, sin carga, carga por Aliento contenido y desvío, tope); `lessons_flow_test` pasa por la hoja de modos.

### Fase B (3/n): Contragolpe (2026-11-16)
- Motor: cada desvío en el turno del rival deja `CombatState.counterReady` (uno por turno del rival, evento `CounterReady`). En el turno propio se usa con `Counter(mode)`: `free` (la próxima carta no cuesta Aliento: `counterFree`, `costOf` da 0 y se consume al jugarla), `draw` (roba `balance.player.counterDraw` 2), `flow` (+1 Flujo, `FlowCause.counter`; `Invalid.flowFull` al máximo). Sin desvío, `Invalid.noCounter`. Lo que no se usa se pierde al terminar el turno. Evento `Countered`.
- Sin timing ni pausa en el turno del rival: la elección queda para el turno siguiente, así el motor sigue siendo un reductor puro.
- Vista: sello dorado 反 que aparece en la barra (entre Respirar y Terminar turno) y late mientras está listo; al tocarlo, hoja con Golpe libre (免), Leer al rival (读) y Tomar el ritmo (流). Cinta «¡Contragolpe!» al desviar y «Próxima carta gratis» al elegirla. Glosario de Desvío lo menciona; la hoja del glosario ahora se desplaza si el texto no entra.
- Bots planificadores: `counterMode` (Flujo si le falta uno para 3, carta gratis si hay una de costo ≥ 2, si no robar); la búsqueda no explora `Counter`.
- Simulación Normal, 150 runs: promedio 7% → 11%, experto 35% → 41%. Se suma a lo de Respirar; el ajuste fino queda para la fase C.
- Tests: grupo `Contragolpe` en `combat_engine_test.dart` (desvío lo deja listo, sin desvío no hay, golpe libre, robar y Flujo, se pierde al terminar).

### Fase B (4/n): Técnica del Camino (2026-11-16)
- Motor: `CombatState.style` (camino de la subida; null en lecciones y muñecos). Con Flujo 3 se habilita `Technique()`: baja el Flujo a 0 (`FlowCause.technique`), evento `TechniqueUsed(style)` y el remate del camino. Sin Flujo lleno o sin camino, `Invalid.noTechnique`. Gratis (no cuesta Aliento).
- Remates (`balance.player.tech*`): Tigre «Zarpazo del Tigre» 12 de daño + 5 Estructura; Serpiente «Mordida en cadena» 3 golpes de 4 + 2 Estructura; Grulla «Vuelo de la Grulla» golpe de 6, +8 Guardia a la altura actual y roba 2.
- Vista: el sello del camino (虎 蛇 鹤, con su color) aparece y late en la barra mientras el Flujo está lleno; al tocarlo, hoja con qué hace y «Usar la técnica». Al usarla: cinta grande con el nombre, `FinisherSeal` con el hanzi y el color del camino, destello, sacudida y hápticos. La cinta de Flujo 3 ahora dice «Técnica del Camino lista»; el glosario de Flujo la menciona. `_CounterButton` pasó a `_SealButton` (sirve para los dos sellos).
- Bots planificadores: la Grulla la usa al empezar (roba); Tigre y Serpiente al final del turno, después de aprovechar el +1 del Flujo.
- Simulación Normal, 150 runs: promedio 11% → 9%, experto 41% → 42% (ruido). Falta medir % de peleas que llegan a Flujo 3 (meta 30–50%).
- Tests: grupo `Técnica del Camino` en `combat_engine_test.dart` (pide Flujo lleno, Tigre, Serpiente, Grulla).

### Fase B (5/n): presentación del golpe (2026-11-17)
- Squash & stretch: el héroe se estira al salir y se aplasta al contacto (`hero_sprite.dart`); el rival se encoge en el amague, se estira al lanzarse y se aplasta al chocar (`_attackPose` devuelve también `stretch`).
- Estela de tinta (`InkTrail` en `juice.dart`): trazo de pincel con dos hebras secas detrás del héroe (color del camino) y del rival (color del rango) mientras embisten.
- Cámara: `PunchZoom` envuelve la arena; se acerca al rival en el remate (último rival 5 %, élite/jefe 10 %, Técnica del Camino 8 %) y vuelve.
- Muerte: `InkDissolve` + `shaders/ink_dissolve.frag` (máscara de ruido con `ShaderMask`, se deshace de arriba hacia abajo); sin shader o con movimiento reducido, fundido con opacidad. El tinte blanco al morir bajó a 60 %.
- Flujo en la escena: `FlowWind` (pétalos 0/7/15/26 por nivel, ráfagas desde el 2, destellos dorados en el 3), con fundido entre niveles; el reloj se apaga en Flujo 0 y con movimiento reducido no corre.
- Sin arte nuevo. Pendiente: capas de música por Flujo (necesita stems reales, va con la fase G) y las 5 poses (golpe/guardia del héroe y ataque por jefe). No probado en el simulador; el shader compila con impellerc.
- Tests: `strike_presentation_test.dart` (zoom, estela, disolución sin shader, pétalos por nivel, reloj que se apaga, movimiento reducido).

### Fase C (1/n): bot prudente (2026-11-17)
- `PrudentBot` en `lib/domain/sim/bots.dart` (perfil `prudente` del simulador): pelea como el promedio, pero elige siempre lo que cura (puerta del té, fuente que cura, opción de evento con más Vida, té de Tío Bao, talismán de Vida) y esquiva élites salvo con más del 90% de Vida. En la ruta (`_route` de `tool/sim/lab.dart`) se cura 83 veces contra 55 del promedio en 30 subidas.
- **Normal, sin árbol, 200 subidas:** promedio 8%, prudente 12%, experto 39%. Llegan a la etapa 3: 16%, 23% y 53%.
- **Con la escuela creciendo** (`--section meta`, 30 escuelas × 30 subidas): prudente 21% → 35% → 46% → 59% → 65% → 71% por tramo de 5 subidas; promedio 20% → 68%; experto 55% → 91%.
- **Lectura:** curarse siempre ayuda (+4 a +10 puntos según el tramo), pero el simulador no lo muestra como estrategia dominante; lo que más pesa es el árbol de meridianos (de 21% a 71%). Los `run_logs` del simulador de iOS son de pruebas, no del teléfono: hace falta pasar los del teléfono para calibrar el prudente contra el usuario.
- Siguiente: sacar Vida de las puertas que compiten con poder y rehacer la fuente con tres opciones parejas, medido con el prudente.

### Fase C (2/n): fuente pareja y puertas sin té (2026-11-17)
- **Puertas:** el té sale de `combatRewards.weights` (peso 0 en las tres etapas); su peso pasa a temple (12/14/17) y talismán (6/8/9). Las puertas ofrecen poder contra poder; la Vida queda en la fuente, el té de Tío Bao, los eventos, el talismán de Vida y la cura entre etapas. `RewardKind.tea` sigue existiendo (pantalla y swap a jade intactos).
- **Fuente, tres opciones:** curar (igual, por dificultad: 20 en Normal), **templar 2 cartas distintas** (+3 cada una; `fountain.temper`), **purificar** = quitar 1 carta **y +4 de Vida máxima y Vida** (`fountain.removeMaxHp`). `fountainUpgrade(r, uids)` toma una lista; `fountainTemperOf` da el tope real; la pantalla elige las cartas de a una («carta 1 de 2»). Bots templan con `bestUpgrades`.
- **Normal, sin árbol, 200 subidas:** promedio 9% (antes 8), prudente 11% (antes 12), experto 41% (antes 39).
- **Escuela creciendo (30×30):** prudente 17/28/35/47/65/71% contra promedio 17/27/31/51/65/70%; experto 54 → 92%. Antes el prudente le sacaba hasta 9 puntos al promedio (subidas 11–15); ahora van parejos: «siempre Vida» dejó de ser ventaja.
- Siguiente: eventos con dos opciones buenas y distintas y un sumidero de jade (sobran ~170 de jade sin gastar en el simulador).

### Fase C (3/n): eventos con dos opciones buenas y la vitrina (2026-11-19)
- **Eventos sin cura gratis:** fuera de los hilos, ninguna opción cura sin pagar jade (test `ningún evento común cura gratis`). Las curas se cambiaron por poder distinto: forma (nido, sabio en el hielo, tambores), carta (peregrino, títeres), elegir qué mejorar (altar y ermitaño por 20 de jade, escama, cantero de la roca por 20), perder una carta inicial (monje de la campana, banderas, juncos) o un poco de Vida máxima (manantial +3, balcón +4). El té practica: elegís 1 de 3 cartas del camino. Rodear el puente y la otra tabla mejoran una carta.
- **Requisitos con costo:** las opciones que abre lo que llevás cobran 2–3 de Vida o 10–20 de jade (templar con el sabio, 20).
- **Sumidero de jade:** la vitrina del anticuario 珍 (monasterio y cumbre): 60 de jade → elegís 1 de 3 cartas raras o legendarias (`EventGain.rareCards`), 25 → elegís qué mejorar, o seguir. Dados fuertes: 40 de jade, 45% un talismán raro.
- **Normal, 200 subidas:** sin cambios (9/11/41%), porque **los bots nunca entran a un evento**: en `_route` (`tool/sim/lab.dart`) un evento puntúa 1 y una pelea 1 + premio. Con `SIM_AVOID=1` (prefieren eventos): antes 8/8/37%, ahora 8/8/36%; el jade sin gastar sigue en ~200, porque el bot valora el jade a 0,15 por punto y no compra la vitrina (60 × 0,15 = 9 > 8).
- Pendiente: que la ruta de los bots pise eventos como una persona y que el valor del jade baje cuando sobra; rehacer metas con eso. Siguiente: desgaste/enfurecimiento en las etapas 2 y 3, filo, votos y élites opcionales.


### Fase C (4/n): simulador que juega como una persona (2026-11-19)
- **Ruta (`_route` en `tool/sim/lab.dart`):** un evento puntúa 1,8 + 1,5 × Vida que falta (antes 1, nunca le ganaba a una pelea); el mercader puntúa 1,5 + (jade − precio de carta)/40, hasta 3,5 (antes 1,5 fijo: lo pisaban 0,7 veces por subida con ~190 de jade sin gastar).
- **Jade (`jadeWorth(r)` en `bots.dart`):** con más de 100 vale la mitad (0,075), para que los bots gasten en la vitrina y los dados. Pesa poco: el cambio grande es ir al mercader.
- `RunLog.healed` y `heals` (Vida curada fuera de pelea y veces). El test del prudente compara veces que se cura, porque las puertas de té ya no existen.
- **Normal, sin árbol, 200 subidas** (promedio/prudente/experto): antes **9/11/41%**; solo con eventos 21/19/52%; con eventos y mercader **46/47/79%**. Mercader 3,4 veces por subida, ~290 de jade gastado y ~85 sin gastar; talismanes 8,4 por subida (antes 2,9).
- **Lectura:** jugado como una persona (entra a eventos y gasta el jade), Normal es fácil, como dice el usuario. Las metas viejas (promedio ~24%, experto ~56%) eran de bots que nunca entraban a eventos ni gastaban jade. Siguiente: desgaste/enfurecimiento en las etapas 2 y 3, filo, votos y élites opcionales, medidos con este simulador, para volver a ~25% del promedio y ~60% del experto. Mirar si el mercader da demasiado (3 visitas con talismán, arma y vitrina).

### Fase C (5/n): furia de la montaña en las etapas 2 y 3 (2026-11-19)
- **Medición previa:** en las etapas 2 y 3 las peleas eran *más cortas* que en la 1 (comunes 2,1 turnos y jefe 3,6 en la etapa 3, contra 3,0 y 4,6 en la 1): el mazo crece más que los rivales y casi todas las muertes del promedio eran en la etapa 1. Un enfurecimiento por turno solo no pesaba (furia 1/2 con la Vida de antes: 43/43/77%).
- **Regla:** `fury` en `enemyMods` de la etapa (`PicoDef.fury`, suma con los Picos). Cada rival guarda `fury` y `furyStep`; después de cada acción `fury += furyStep` y se suma a sus golpes. No se calma al desequilibrarlo; si pierde la acción por Desequilibrio, ese turno no crece. Evento `EnemyFurious`, ficha «Furia de la montaña · +N» y término 狂 en el glosario.
- **Valores:** Monasterio `enemyHp` 14 → 40 y furia 3; Cumbre 22 → 62 y furia 4 (el daño no cambió: 9 y 16).
- **Normal, sin árbol** (promedio/prudente/experto): antes 46/47/79%; ahora **22/26/64%** (300 subidas). Sin furia y con la misma Vida daría 30/39/71%: la furia sola saca ~10 puntos, y más al prudente, que es lo que se buscaba (aguantar no alcanza). Fácil 47/58/83%, Difícil 12/17/44%.
- `FightLog.stage` (etapa de cada pelea) para medir por etapa. Siguiente: filo, votos y élites opcionales; revisar si el mercader da demasiado.

