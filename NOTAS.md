# NOTAS — estado del trabajo (para seguir desde un chat nuevo)

Última actualización: 06/11/2026 · último commit: `67f200e` (rama `main`, pusheado).

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
flutter test                          # 285 tests, todos pasan
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
1. Seguir juntando registros del usuario y comparar turnos y Vida perdida por piso con la simulación.
2. Probar en el juego la etapa 3 nueva (desgaste, embestida del buey, espada que cambia de altura) y ver si la línea «Cada golpe gasta tu Guardia» se entiende. Las peleas siguen cortas (~2,5 turnos).
3. **TestFlight:** pantalla de carga hecha (`71a2648`, logo sobre papel). Hecho también: solo iPhone y solo vertical, `ITSAppUsesNonExemptEncryption=false` y `ios/Runner/PrivacyInfo.xcprivacy` (UserDefaults, CA92.1; no recopila datos). Ficha, textos de TestFlight y paso a paso en `docs/testflight.md`; política de privacidad en `docs/privacidad.md` (URL de GitHub, repo público). Bundle `com.oraki.longBreath` (iOS y Android). IPA `0.1.0+1` (06/11) con ícono de Flutter e iOS 13. **IPA `0.1.0+2` (06/11): ícono propio (fuente en `docs/arte/app_icon.webp`, integrado con `python3 tool/make_app_icon.py icon <png>`) y target mínimo iOS 15.0** (aviso 90068). El próximo tiene que ser `+3`. El usuario crea la app en App Store Connect.
4. Opcional: un lugar lacrado de la Grulla en el santuario, que muestre «se abre en 筑基 · 58/90».

## Notas técnicas
- Si un widget de animación devuelve `child!` cuando está quieto y lo envuelve cuando anima, el subárbol se remonta. Hay que devolver siempre el mismo tipo de widget.
- Los banners de combate se sacan con `onEnd` de la animación, nunca con timers de reloj, por `timeDilation`.
- El evento `FormCompleted` se emite en `combat_engine.dart` (`_advanceForms`).
