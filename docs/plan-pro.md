# Plan «juego pro»: historia viva, pulido y base técnica

Armado el 10/11 con dos relevamientos del código (historia y técnica). Cada bloque se puede hacer y verificar con tests y simulación, sin probar en el teléfono; lo que sí pide teléfono queda marcado 📱.

## Diagnóstico corto

**Historia.** Ya hay mucho escrito: el prólogo, el giro (el dragón es el primer maestro; el maestro cayó ante la Dama del Viento), finales, 22 pergaminos, 16 rivales con diálogo, 38 eventos y el Discípulo Perdido. El problema es *cuándo* y *cómo* llega:
- casi todo se abre **al terminar la subida**, como texto suelto en el registro: durante la subida pasa poco;
- **nada de lo que decidís sobrevive a la subida**: el herido, el rival y el herrero mueren con ella;
- **nadie tiene nombre**: ni el maestro, ni el mercader, ni el rival de la otra escuela. El mercader no habla;
- entre etapas solo hay curación, botín y presentación; no hay **escena** ni **decisión**;
- después de «El nombre que falta» no hay más historia (Picos, Leopardo y Dragón sellado sin relato);
- hay incoherencias: el nombre tallado en la viga *y* en la piedra de la cumbre, y el Monje sin Rostro «cuida las campanas» pero es élite de la etapa 1.

**Técnica.**
- `combat_screen.dart` tiene 5.363 líneas y `run_engine` es una clase con 92 métodos.
- Guardados:
  - no tienen versión;
  - un guardado ilegible **borra la subida en silencio** (`run_storage.dart:19`);
  - una tablilla corrupta rompe todo el registro.
- No hay reporte de errores ni accesibilidad: 0 `Semantics` y fuentes de 7,5–9 pt en combate.
- Imágenes de 1024 px sin `cacheWidth` ni precarga; SFX en WAV (5,7 MB).
- Feel incompleto:
  - 6 pantallas con `AppBar` pelado;
  - `InkWell` en vez de `Press`;
  - loops que no respetan el movimiento reducido;
  - sin música por etapa ni jingle de derrota o de etapa.
- **Fallo nuevo por las estancias:** al caer, el registro anota `node.enemy`, que ahora es el guardián de la última sala, aunque hayas caído en la primera (`run_controller.dart:176`). Eso también abre mal los pergaminos `fell_*`.

---

## Bloque 1: historia que pasa *durante* y *entre* subidas

La idea central es que **la montaña recuerda**. Cada subida deja huella y la siguiente la nota.

### 1.1 Hilos: historias largas que cruzan subidas
- **Qué son:** tres o cuatro personajes con nombre, cada uno con 4–6 capítulos que se abren de a uno, **en subidas distintas**, según lo que hiciste.
- **Cómo funcionan:**
  - cada capítulo es un evento especial en el mapa o una escena en la pausa entre etapas;
  - lo que elegís queda guardado en `ProgressStorage` (clave `threads`) y cambia el capítulo siguiente;
  - un capítulo aparece como máximo una vez por subida, así no tapa los eventos comunes.

| Hilo | Personaje | Arco |
|---|---|---|
| **El rival** | Discípulo de la escuela rival (hoy sin nombre; la cadena `rival` → `rival_summit`) | Lo cruzás subida tras subida, cada vez más arriba. Si lo ayudás o lo humillás, cambia su último capítulo: aliado en la cumbre o rival en el jefe. |
| **El mercader** | Le damos nombre y voz | Cuenta de a poco por qué sube y baja la montaña sin pelear. Con cada compra grande suma confianza, y al final revela que fue discípulo y abandonó, lo que abre una mercancía única. |
| **El herido / el herrero** | Las cadenas que hoy existen | Si salvaste al herido, en la subida siguiente aparece como peregrino que te devuelve el favor. El arma del herrero queda como reliquia de la escuela. |
| **El maestro** | Sin nombre hoy; le damos uno | Cartas que te deja en la mochila: una al empezar, una por etapa. Son el hilo que lleva al giro «El nombre que falta». |

### 1.2 Escena entre etapas: «El campamento»
- **Dónde:** se agrega a `stage_clear_screen` antes del botín. Es una escena breve con fogata, el fondo de la etapa y 3–4 líneas.
- **Qué la dispara**, por prioridad:
  1. un capítulo de hilo pendiente;
  2. una carta del maestro;
  3. un sueño del dragón, que es lore nuevo.
- **Termina con una decisión que pesa:** un **voto** para la etapa siguiente.
  - Ejemplos: «Voto de silencio: +1 Aliento, sin curarte en la fuente» o «Voto del tigre: +2 de daño, −5 de Vida máxima».
  - Son 6–8 votos simples, usan reglas que ya existen y se balancean con simulación.

### 1.3 Morir cuenta algo: sueños del dragón
- **Al caer:** antes de la tablilla, una escena corta de «sueño» (2–3 líneas, nada oscuro: niebla clara y oro). Revela un fragmento según dónde y ante quién caíste.
- **Cantidad:** un fragmento nuevo por caída hasta completar ~15. Así perder también **avanza la historia**, al estilo Hades.
- **Requisito:** antes hay que arreglar el fallo de `node.enemy` para que la caída se atribuya bien.

### 1.4 Lore durante la subida
- **Cofre de estancia:** a veces trae una **página suelta** (diario del maestro, de discípulos caídos, notas del monasterio). Se lee en el momento con `LoreScroll` y queda en el registro. Esto le da al cofre un premio extra que no es carta.
- **Bestiario («Crónica de la montaña»):** nueva pestaña del registro. Cada enemigo vencido abre su ficha: lore de 1–2 líneas (hoy solo está en el manual), cuántas veces lo venciste y ante cuál caíste. Los comunes ganan identidad.
- **Escuela viva:** la pantalla de la escuela muestra cambios según el progreso: tablillas que se acumulan, el arma del herrero colgada, el rival que pasa de visita. Es texto y detalles que reusan arte, sin assets nuevos.

### 1.5 Después del final
- Tras «El nombre que falta», el Pico 2+ abre un **epílogo en capítulos**: qué pasa con la escuela cuando *vos* sos el que anota.
- El Leopardo y el Dragón sellado se presentan como hilo: «la puerta lacrada del santuario».
- Va en una segunda tanda. Primero 1.1–1.4.

### 1.6 Coherencia
- Unificar dónde está tallado el nombre: la viga es el comienzo y la piedra es el nombre completo. Lo explicamos así en vez de borrar.
- Mover al Monje sin Rostro a otra cosa que no sean las campanas.
- Actualizar `manual.md` («Lo que viene» y la línea 51) y `futuro.md:159`.

**Lo que hace falta:**
- **Textos:** muchos, en `content/es.json`. Los escribo yo y los revisás de corrido.
- **Arte:** mínimo. Fogata y retrato del rival si querés; mientras tanto se usan los retratos que ya existen. Antes de pedir nada corro `art_status.py`.

---

## Bloque 2: base técnica (sin cambiar lo que se ve)
1. **Arreglar el registro de caída** con la sala real de la estancia (`node.stay[roomStep].enemy` o el enemigo vivo del combate), con test.
2. **Guardados robustos:**
   - campo `v` (versión) y migraciones explícitas;
   - una fase o un enum desconocido cae a un valor por defecto en vez de reventar;
   - un guardado ilegible se **respalda** (`run_corrupt`) en vez de borrarse, con log;
   - tablillas corruptas se saltean de a una.
3. **Errores visibles:** `FlutterError.onError` + `runZonedGuarded` que escriban al registro de la subida. Nada de servicios externos.
4. **Partir `combat_screen.dart`** en arena, mano, barra de acciones, final y despacho de efectos.
   - Movimiento de clases sin tocar la lógica.
   - **Sin `dart format`** sobre el archivo; los archivos nuevos sí se formatean.
5. **Partir `run_engine`** por fase: mapa, estancias, recompensas y mercader, cierre de etapa. Los tests existentes siguen en verde.
6. **Lints más estrictos** (unos pocos útiles: `prefer_const`, `unawaited_futures`, `avoid_catches_without_on_clauses`) y corregir lo que salga.
7. **Tests de pantallas que no se verifican:** escuela, registro, resultado, etapa superada, mercader, legado. Al menos un test de contenido por pantalla, no solo `find.byType(Scaffold)`.
8. **`bots.dart` fuera de `lib/`**, a `tool/sim/`.

## Bloque 3: pulido «pro» (feel, sonido, rendimiento, accesibilidad)
1. **Feel según `docs/feel.md`:**
   - las 6 pantallas con `AppBar` pelado pasan a la cabecera propia;
   - `InkWell` → `Press`;
   - `StaggerIn` en premio, resultado, etapa superada, registro, ranuras y lecciones;
   - loops con `loopUnlessCalm`.
2. **Sonido:**
   - **música por etapa** en el mapa: una pista por etapa, generada con `tool/make_audio.py` como el resto;
   - jingle de etapa superada y jingle de caída;
   - sonidos de apertura de cofre, sala superada, gasto de jade y selección de tregua.
3. **Peso y rendimiento:**
   - `cacheWidth` en sprites, fondos y cinemáticas;
   - precarga del arte de la estancia y del enemigo siguiente durante la pausa entre salas;
   - SFX a OGG (−4 MB aprox.);
   - revisar los fondos más pesados.
4. **Accesibilidad:**
   - `Semantics` en cartas, intención enemiga, Vida y botones;
   - mínimo 11 pt en combate;
   - respetar `textScaler` hasta 1,3.

---

## Orden propuesto

| Paso | Qué | Por qué primero |
|---|---|---|
| 1 | B2.1 fallo de caída + B2.2 guardados + B2.3 errores | Arreglos baratos que protegen las partidas de los testers. Los sueños (1.3) dependen de la caída bien atribuida. |
| 2 | B1.6 coherencia + nombres (maestro, mercader, rival, escuela rival) | Todo el bloque 1 se apoya en esto. |
| 3 | B1.2 campamento con votos + B1.3 sueños | Es lo que más se va a notar: algo pasa entre etapas y al morir. |
| 4 | B1.1 hilos (rival y mercader primero) | El enganche entre subidas. |
| 5 | B1.4 páginas en el cofre + bestiario + escuela viva | Redondea las estancias y le da identidad a los comunes. |
| 6 | B2.4–2.8 refactor + tests + lints | Mejor con la historia ya adentro, para no partir dos veces. |
| 7 | B3 pulido | Antes de la build que se juega en serio. |
| 8 | B1.5 después del final | Segunda tanda. |

Cada paso termina con `flutter analyze`, `flutter test`, la simulación cuando toca balance, una nota en `NOTAS.md`, commit y push.
Al final, build +5 📱 con todo junto, para probar de corrido.

## Decisiones abiertas
- Nombres: ¿los propongo yo (en pinyin con traducción, estilo actual) o tenés alguno?
- Votos del campamento: ¿obligatorios (siempre elegís uno) u opcionales (podés no votar)?
- Arte nuevo para hilos (retrato del rival, fogata): ¿se pide o se reusa lo que hay?
