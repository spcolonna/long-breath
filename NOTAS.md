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
flutter test                          # 300 tests, todos pasan
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

## Pendiente
1. Probar la build +2: que suene todo (música por pantalla, toques, golpes) y si la etapa 3 sigue fácil. Seguir juntando registros del usuario y comparar turnos y Vida perdida por piso con la simulación.
2. Probar en el juego la etapa 3 nueva (desgaste, embestida del buey, espada que cambia de altura) y ver si la línea «Cada golpe gasta tu Guardia» se entiende. Las peleas siguen cortas (~2,5 turnos).
3. **TestFlight:** pantalla de carga hecha (`71a2648`, logo sobre papel). Hecho también: solo iPhone y solo vertical, `ITSAppUsesNonExemptEncryption=false` y `ios/Runner/PrivacyInfo.xcprivacy` (UserDefaults, CA92.1; no recopila datos). Ficha, textos de TestFlight y paso a paso en `docs/testflight.md`; política de privacidad en `docs/privacidad.md` (URL de GitHub, repo público). Bundle `com.oraki.longBreath` (iOS y Android). IPA `0.1.0+1` (06/11) con ícono de Flutter e iOS 13. IPA `0.1.0+2` (06/11): ícono propio (fuente en `docs/arte/app_icon.webp`, integrado con `python3 tool/make_app_icon.py icon <png>`) y target mínimo iOS 15.0 (aviso 90068). **Solo se subió el `0.1.0+1`; el +2 y el +3 locales no se subieron. IPA `0.1.0+2` rehecho (06/11) con todo: sonido, legibilidad, pergamino del rival, balance de §3j y los 3 íconos nuevos (Vida, carga, jade robado). El próximo tiene que ser `+3`.** IPA `0.1.0+3` (interfaz nueva, `70bdc98`) **subido el 09/11**; `build/` borrado. IPA `0.1.0+4` (mapa con niebla, tregua, paso de montaña, emboscadas; `8f8a24b`) armado el 09/11 y no subido. IPA `0.1.0+5` (estancias, campamento con votos, sueños del dragón, guardados robustos; `c8f4083`) armado el 10/11: reemplaza a la +4, falta subirlo; borrar `build/` después. IPA `0.1.0+6` (sendero de salas, balance «Duro», enemigo visible; `cb0979b`) armado el 11/11: reemplaza a la +5 si no se subió. La próxima es `+7`. El usuario crea la app en App Store Connect.
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
   - **Siguiente:** hilos entre subidas (rival Shuang, Tío Bao).
8. Opcional: un lugar lacrado de la Grulla en el santuario, que muestre «se abre en 筑基 · 58/90».

## Notas técnicas
- Si un widget de animación devuelve `child!` cuando está quieto y lo envuelve cuando anima, el subárbol se remonta. Hay que devolver siempre el mismo tipo de widget.
- Los banners de combate se sacan con `onEnd` de la animación, nunca con timers de reloj, por `timeDilation`.
- El evento `FormCompleted` se emite en `combat_engine.dart` (`_advanceForms`).
