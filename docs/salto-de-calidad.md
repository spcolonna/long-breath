# Salto de calidad — relevamiento y propuestas

_Relevamiento del 13/11 (versión 0.1.0+6). Qué mejoraría y cómo, en mecánicas, dinamismo de las peleas, progresión, historia, mapa e interfaz._
_Son propuestas, no decisiones: nada de esto está implementado. Lo que se decida hacer pasa a `docs/futuro.md` y `NOTAS.md`._

Reglas que todo lo de acá respeta: nada oscuro, feel de juego pago (`docs/feel.md`), arte costoso (pocas imágenes, bien elegidas, un prompt por imagen).

Cada propuesta lleva: **Problema** (con dato), **Propuesta**, **Cómo** (archivos), **Arte** y **Cómo medir**.

---

## 0. Diagnóstico

**Ya está a buen nivel:** arte 169/169, kit de feel propio (hit-stop, tinta, cinemáticas), 135 hápticos, 313 tests, hilos narrativos, movimiento reducido.

**Las brechas**, según el relevamiento del código y la experiencia de juego real:

| # | Brecha | Evidencia |
|---|---|---|
| 1 | Hay una estrategia dominante: «siempre Vida» | jugando así se llega muy alto casi sin esfuerzo; la fuente es casi siempre «curar 20» |
| 2 | La etapa no tiene arco propio | 13 salas parejas; la única decisión de camino es el santuario de la sala 3 de la etapa 1 |
| 3 | Peleas comunes de trámite | 2,2–3 turnos; ciclo de intenciones fijo; Respirar 1 vez por combate |
| 4 | El mapa no es un lugar | puertas sobre una ladera, sin recorrido ni memoria entre subidas |
| 5 | La progresión entre subidas es un árbol de números | 15 nodos de meridianos; la escuela no cambia |
| 6 | La interfaz no está a la altura del arte | 0 fuentes propias; 83 `Icon(` de Material contra 19 `GameIcon(`; personajes de una sola pose |
| 7 | Audio sintetizado | 109 wav + 8 ogg generados por `tool/make_audio.py`; sin música por etapa |
| 8 | El simulador no juega como una persona | el bot promedio gana 4% sin árbol; una persona que prioriza Vida llega mucho más lejos |

**Sobre el ritmo:** la subida es ágil (la etapa 1 se termina en ≤15 min). No hay que acortarla; al revés, la etapa puede ser más larga si se siente como un viaje con progresión propia (§3).

---

## 1. Dinamismo de las peleas

### 1.1 Flujo: un medidor que hace crecer la pelea
- **Problema:** el turno no tiene una meta visible más allá de bajar Vida. El «círculo de posturas» existe pero sale poco. La pelea se ve igual en el turno 1 que en el 5.
- **Propuesta:** un medidor de **Flujo** con 3 niveles.
  - Sube al encadenar posturas distintas, desviar a la altura correcta y cerrar formas.
  - Baja al recibir un golpe sin Guardia o al terminar el turno sin jugar.
  - Cada nivel da algo jugable (+daño, +1 carta, +1 Aliento) y algo sensorial: entra una capa de música, el fondo se anima (pétalos, viento), el héroe cambia de aura.
  - Con Flujo 3 se habilita la **Técnica del Camino**: un remate propio de Tigre, Grulla o Serpiente con cinemática corta, que consume el Flujo.
- **Cómo:** estado nuevo en `lib/domain/combat/combat_engine.dart`; la vista reutiliza `ComboCounter` y `FinisherSeal` de `lib/delivery/widgets/juice.dart`; las capas de música en `infrastructure/soloud_audio.dart`. Absorbe la regla del círculo de posturas.
- **Arte:** 0 (3 remates por código con los VFX que ya hay). Opcional: 3 ilustraciones de técnica final.
- **Cómo medir:** turnos por pelea común (meta 3–5), % de peleas en que se llega a Flujo 3 (meta 30–50%), y que el simulador no encuentre un build que lo mantenga siempre al máximo.

### 1.2 Respirar como centro del juego
- **Problema:** el juego se llama Long Breath y Respirar se usa una vez por combate. En el Pico 9 queda en 0 si no tenés el nodo 百会.
- **Propuesta:** Respirar pasa a ser un recurso que se carga y se elige cómo gastar.
  - Se carga al desviar, al cerrar una forma o al terminar el turno con Aliento sin usar («aliento contenido»).
  - Al usarlo se elige un modo: recuperar Aliento, recuperar Estructura, o leer el turno siguiente del rival.
  - Los picos y el árbol modifican la carga, no la existencia.
- **Cómo:** `combat_action.dart` y `combat_engine.dart`; botón de Respirar con anillo de carga en `combat_screen.dart`; lección nueva en `tutorial/lessons.dart`.
- **Arte:** 0.
- **Cómo medir:** usos de Respirar por pelea (meta 1–3) y que ningún modo se elija más del 60% de las veces.

### 1.3 Contragolpe
- **Problema:** defender es pasivo: se pone la Guardia y se espera.
- **Propuesta:** al desviar a la altura exacta se abre una elección inmediata (sin timing): jugar gratis una carta de la mano, robar una carta, o ganar Flujo. Límite: una vez por turno del rival.
- **Cómo:** un paso de resolución nuevo en el motor y un overlay chico en combate, con el estilo de la tregua entre oleadas.
- **Arte:** 0.
- **Cómo medir:** % de turnos con desvío exacto (debería subir) y que la carta gratis no rompa el daño por turno en el simulador.

### 1.4 Enemigos que reaccionan
- **Problema:** las 164 intenciones van en ciclo fijo y visible; una vez aprendido el ciclo, la pelea se resuelve sola.
- **Propuesta:**
  - Ciclos con ramas: el rival cambia de intención si repetís altura o postura, si le rompiste la Estructura, si está por debajo de cierta Vida o si cayó su compañero. La rama se anuncia en su pergamino.
  - Roles de grupo: uno protege, otro carga, otro cura o alienta. El orden en que caen importa.
  - Élites con una «pregunta» única y jefes con un momento firma por fase.
- **Cómo:** campo opcional de condiciones en `enemies.json`; el motor ya soporta fases de jefe y reglas propias, se generaliza.
- **Arte:** 0.
- **Cómo medir:** en la Crónica, que la relación victorias/caídas no sea plana entre comunes; en el simulador, que el bot experto gane claramente más que el prudente (hoy la diferencia viene de las decisiones de mazo, no de la pelea).

### 1.5 Salas con condiciones y retos opcionales
- **Problema:** ~24 peleas por subida con 8–10 comunes por etapa: se repiten.
- **Propuesta:**
  - 8–10 **condiciones de sala** que cambian las reglas de esa pelea: niebla (intención oculta un turno), viento (cartas altas cuestan −1), puente angosto (de a un rival), campana (cada tercer turno golpea a todos), lluvia (la Guardia dura dos turnos pero vale menos).
  - Un **reto opcional** por pelea con premio extra: «sin perder Vida», «rematá con quiebre», «en 3 turnos», «sin repetir postura».
  - La condición y el reto se ven en la puerta, así que también son decisión de ruta.
- **Cómo:** `lib/domain/run/path_gen.dart` (asignación), `MapNodeDef`, y un cartel al entrar a la pelea.
- **Arte:** 0 (ícono pintado y tinte del fondo). Los íconos entran en la tanda de §7.2.
- **Cómo medir:** % de retos intentados y cumplidos (meta 40–60% cumplidos).

### 1.6 Presentación del golpe
- **Problema:** héroe y enemigos son una imagen con transformaciones; no hay poses.
- **Propuesta (por código):** squash & stretch en la embestida, estela de tinta, sombra de contacto, cámara que se acerca en el remate, disolución en tinta al morir (shader de fragmento), un remate distinto por arma.
- **Arte:** 5 imágenes — 2 poses del héroe (golpe y guardia) y 1 pose de ataque por jefe.
- **Cómo:** `juice.dart` y la zona de personajes de `combat_screen.dart` (después de partirlo, §7.8).
- **Cómo medir:** visual; una captura achicada por efecto y 60 fps en el teléfono.

---

## 2. Mecánicas y decisiones

### 2.1 Romper «siempre Vida»
- **Problema:** elegir Vida en cada puerta alcanza para llegar muy alto. No hay tensión entre sobrevivir y crecer.
- **Propuesta:**
  - La Vida deja de competir en la misma puerta que el poder. Las puertas ofrecen poder contra poder; la cura vive en reglas propias (fuente, té, ganar una pelea sin daño, campamento).
  - La montaña exige build: desde la etapa 2 los rivales tienen desgaste o enfurecimiento (el `wear` de la etapa 3 ya existe), así que aguantar no alcanza; hay que matar a tiempo.
  - Premiar el riesgo: efectos de «filo» (más daño o Aliento con Vida baja), votos más tentadores, élites opcionales con el mejor botín.
- **Cómo:** `game_balance.json` (`combatRewards`, premios de puerta), `path_gen.dart`, y talismanes/cartas nuevos de filo.
- **Arte:** 0.
- **Cómo medir:** con el bot prudente de §2.4. Si gana más que el objetivo de Normal eligiendo siempre Vida, sigue dominante.

### 2.2 Profundidad de build
- **Problema:** 64 cartas sin rareza, solo 11 generales; 3 arquetipos (uno por camino); la especialización termina en la sala 3.
- **Propuesta:**
  - **Rareza** (común, rara, legendaria) con marco propio. Ya hay 5 marcos.
  - **12–15 cartas generales «bisagra»** entre caminos: retener + cadena, quiebre + postura, Guardia que pega.
  - **Maestría de carta:** usarla N veces en subidas desbloquea su variante.
  - **Santuario en las tres etapas:** segunda y tercera especialización (despertar a elegir, sub-camino).
  - **Talismanes con conjuntos:** dos del mismo sello activan un efecto.
  - Más adelante: cuarto camino (Leopardo).
- **Cómo:** campo `rarity` en las cartas, pesos en cofre y tienda, `CardWidget` (487 líneas) para el marco.
- **Arte:** 12–15 ilustraciones de carta; Leopardo pide 11 cartas más y un recoloreo del héroe.
- **Cómo medir:** cantidad de arquetipos con tasa de victoria parecida en el simulador (meta ≥6) y que ninguna carta aparezca en más del 70% de los mazos ganadores.

### 2.3 Nodos con decisiones de verdad
- **Problema:** la fuente es casi siempre «curar 20»; muchos eventos son «−X Vida por Y, o nada»; las opciones con requisito son siempre mejores y sin riesgo; sobran ~52 de jade al final.
- **Propuesta:**
  - Fuente con tres opciones parejas (ajustar valores hasta que ninguna pase del 50%).
  - Reescribir los eventos pobres con dos opciones buenas y distintas; las opciones con requisito pasan a tener costo.
  - Sumidero de jade en la etapa 3: vitrina legendaria, templar el arma, apuesta con Shuang.
- **Cómo:** `events.json`, `game_balance.json`, `merchant_screen.dart`.
- **Arte:** 0.
- **Cómo medir:** reparto de elecciones por nodo en los `run_logs`.

### 2.4 Simulador creíble
- **Problema:** las metas de balance salen de bots que no juegan como una persona (4% sin árbol contra la experiencia real).
- **Propuesta:** perfiles de bot con prioridades — **prudente** (Vida primero, después cartas), **codicioso**, **experto** — y compararlos con los `run_logs/slot<N>/actual.log` reales del teléfono. Rehacer las metas con esos números.
- **Cómo:** el simulador de `tool/` y `docs/balance.md`.
- **Cómo medir:** que el bot prudente llegue a la misma altura que el jugador real en sus registros.

---

## 3. La etapa como viaje

### 3.1 Tres actos por etapa
- **Problema:** las 13 salas de una etapa son parejas; no hay sensación de avanzar dentro de ella.
- **Propuesta:** etapas de ~18–20 salas en tres actos (falda, ladera, umbral). Cada acto tiene su fondo, sus rivales y un cierre: guardián de acto → campamento → acto siguiente. El jefe cierra el tercero.
- **Cómo:** `run.stages` y `run.path` en `game_balance.json`, `path_gen.dart`, `stage_clear_screen.dart` (versión corta para el cierre de acto).
- **Arte:** 0. Los fondos alcanzan (10 / 6 / 7 por etapa).
- **Cómo medir:** minutos por etapa (meta 20–25) y repetición de rivales por subida.

### 3.2 Dominio de la etapa
- **Problema:** se crece entre subidas, pero poco dentro de una etapa.
- **Propuesta:** una barra por etapa que se llena peleando, cumpliendo retos y explorando. En cada umbral se elige una **bendición del lugar** (del bosque, del monasterio, de la cumbre) que dura esa etapa. Al pasar de etapa se conserva una sola.
- **Cómo:** estado en `run_engine.dart`; la barra vive junto a la de altitud en `map_screen.dart`.
- **Arte:** 0 (sellos de hanzi).
- **Cómo medir:** que en el acto 3 de cada etapa el jugador tenga 2–3 bendiciones y que se elijan variadas.

### 3.3 Una regla propia por etapa
- **Propuesta:** cada etapa enseña algo y obliga a adaptar el build.
  - **Bosque:** bambú — cobertura que frena el primer golpe y emboscadas.
  - **Monasterio:** campanas — turnos marcados que premian o castigan.
  - **Cumbre:** aire fino — el Aliento rinde menos salvo que respires (se apoya en §1.2).
- **Cómo:** reglas de etapa en el motor, presentadas por `StageIntro`.
- **Arte:** 0.

### 3.4 Historia dentro de la etapa
- **Propuesta:** cada etapa con apertura, encuentro central y cierre, y un personaje que acompaña ese tramo: Ming en el bosque, Tie en el monasterio, Shuang en la cumbre. Los retratos ya existen.

---

## 4. El mapa como lugar

- **Problema:** el mapa son 2–3 puertas sobre una ladera; solo se ve la fila siguiente; no recuerda nada.
- **Propuesta:**
  - **Sendero ilustrado continuo** por etapa: el héroe camina de sala en sala, se ven 2–3 filas por delante para planear la ruta, y la cumbre se acerca.
  - **Hora y clima** que avanzan con la altitud: mañana → mediodía → atardecer dorado. Nunca noche.
  - **Memoria entre subidas:** la tablilla donde cayó el discípulo anterior, las marcas de Shuang, el puesto de Bao, atajos que quedan abiertos.
  - **Salas visibles de lejos:** élite dorada, cofre sellado que pide llave, condición de sala (§1.5).
- **Cómo:** `map_screen.dart` (844 líneas) se rehace sobre un `CustomPainter` con scroll; `path_gen.dart` expone más filas; `CloudDrift` y `KenBurns` se reutilizan.
- **Arte:** 3 ilustraciones largas (una por etapa) y ~6 hitos chicos.
- **Cómo medir:** visual, y que la elección de ruta cambie según lo que se ve dos filas adelante.

---

## 5. Progresión del usuario

### 5.1 La escuela crece
- **Problema:** la progresión es un árbol de 15 nodos; la escuela es una pantalla que no cambia.
- **Propuesta:** el monasterio empieza en ruinas y se restaura con lo que traés de cada subida. Cada edificio abre una función y un hilo:
  - **Forja** (Tie): templar y elegir arma inicial.
  - **Casa de té** (Bao): comprar una ventaja para la próxima subida.
  - **Enfermería** (Ming): Vida inicial y curas.
  - **Patio** (Shuang): práctica contra rivales de la Crónica y desafíos.
- **Cómo:** `/school` pasa a ser una escena; los costos salen de las semillas de loto y el Aliento de cultivo que ya existen.
- **Arte:** 1 ilustración del monasterio y 4 edificios (o estados) = ~5.
- **Cómo medir:** que cada subida, ganada o perdida, permita mejorar algo visible.

### 5.2 Maestría por camino
- Niveles propios de Tigre, Grulla y Serpiente con cartas, la Técnica del Camino (§1.1) y cosméticos (recoloreos, dorsos, sellos). Casi sin arte nuevo.

### 5.3 Meridianos
- Rehacer la pantalla como un cuerpo o constelación que se ilumina, con nodos que cambian cómo se juega y no solo números. Posibilidad de reiniciar el árbol.

### 5.4 Retención
- Desafío diario con semilla (la semilla interna ya existe), semilla compartible, pantalla de estadísticas, ascensiones sobre Difícil y Shifu (los 10 Picos hoy son solo sobre Normal), Game Center con los 29 hitos.

---

## 6. Historia

- **Problema:** hay buen material (56 pergaminos, 2 hilos, 3 finales), pero se lee en el registro más de lo que se vive.
- **Propuesta:**
  - **Un misterio central** que se arma entre subidas (por qué duerme el dragón, quién fue el primer discípulo), con revelaciones que cambian la montaña.
  - **Decisiones que dejan marca:** lo que hiciste con Shuang, Ming, Tie y Bao cambia diálogos de jefes, eventos y el final.
  - **Final verdadero** tras varias cumbres, además de los 3 por camino.
  - **Voces:** una línea del rival al empezar y al caer; el maestro comenta tu subida anterior.
  - **Hilos de Ming y Tie** y arreglo del Monje sin Rostro (`plan-pro.md` §1.6).
- **Cómo:** `lib/domain/run/threads.dart`, `events.json`, `assets/l10n/content/es.json`, `FoeIntro`.
- **Arte:** 0–2 (epílogo del final verdadero).
- **Cómo medir:** cuántos capítulos ve un jugador en sus primeras 5 subidas (meta: al menos uno por subida).

---

## 7. Lavado de interfaz

### 7.1 Tipografía
- **Problema:** no hay ninguna fuente propia; títulos y hanzi salen con la del sistema. Es la mayor distancia con la estética de tinta.
- **Propuesta:** una display de pincel para títulos, una serif legible para el cuerpo y una caligráfica para los hanzi. Licencia libre y subset de los caracteres usados para cuidar el peso.
- **Cómo:** `pubspec.yaml`, `TextTheme` en `lib/delivery/theme.dart`, `InkSeal` en `widgets/lotus.dart`. Revisar desbordes con los tests de widget.
- **Arte:** 0. Es el cambio más barato y más visible.

### 7.2 Iconografía
- **Problema:** 83 íconos de Material conviven con íconos pintados.
- **Propuesta:** ~14 conceptos del juego pasan a `GameIcon`: altura alta, media y baja; las tres posturas; aliento; fuego; mejora; tienda; escuela; candado; quitar; condición de sala. Flechas y chevrons quedan en Material.
- **Arte:** ~14 prompts sueltos de 1:1.

### 7.3 Materia
- Grano de papel y tinta por shader, bordes de pincel en paneles, oro con brillo, sombras cálidas. Pasar `ink_reveal` a shader.

### 7.4 Cartas
- Rediseño con rareza, tipo por forma además de color, costo y postura más legibles a tamaño de mano.

### 7.5 HUD de combate
- Menos cajas y más jerarquía; Flujo y Respirar como protagonistas; registro plegable de «por qué pasó» con las últimas resoluciones.

### 7.6 Pantallas
- **Inicio vivo:** la montaña con hora del día y tu progreso a la vista.
- **Nodos** (fuente, santuario, talismán, legado) con composición propia en vez del mismo kit.
- **Cofre** con apertura distinta por rareza.
- **Resultado** como pergamino de la subida, compartible como imagen.

### 7.7 Claridad y accesibilidad
- Glosario tocable en palabras clave (hoy hay 3 tooltips).
- Forma además de color para tipo de carta, rango y camino; escala de texto del sistema con tope; `Semantics` (hoy 0).

### 7.8 Antes de tocar el combate
- Partir `combat_screen.dart` (5371 líneas, ~50 clases privadas) por zonas: mano, rivales, HUD, overlays. Sin `dart format`.

---

## 8. Audio
- **Problema:** todo es sintetizado; no acompaña al arte pintado.
- **Propuesta:**
  - Música con instrumentos reales (guzheng, dizi, erhu, tambores): un tema por etapa, más élite, jefe, menú y escuela, con capas que entran con el Flujo.
  - Reemplazar los ~20 efectos más frecuentes (golpe, desvío, quiebre, carta, botón, cofre) por muestras reales.
  - Ambiente por etapa (viento, agua, campanas) y deslizadores de volumen.
- **Cómo:** `soloud_audio.dart` ya funde pistas; falta la mezcla por capas. Anotar las licencias en `docs/`.

---

## 9. Producto
- Inglés (el ARB y `content/es.json` ya lo permiten), iPad (hoy solo iPhone vertical), iCloud, Game Center, tráiler y capturas de tienda.
- Docs al día: `reglas-implementadas.md` describe el mapa viejo y `docs/arte/relevamiento.md` dice que no hay sonido.

---

## 10. Hoja de ruta sugerida

| Fase | Qué | Arte nuevo |
|---|---|---|
| A. Lavado visual | Tipografías, shaders de papel y tinta, cartas con rareza, forma + color | 0 |
| B. Pelea viva | Flujo, Respirar recargable, contragolpe, presentación del golpe | 5 |
| C. Decisiones | Romper «siempre Vida», nodos parejos, bot prudente y `run_logs` | 0 |
| D. Etapa como viaje | 3 actos, dominio, regla por etapa, enemigos que reaccionan | 0 |
| E. Mapa | Sendero ilustrado, memoria entre subidas, clima | ~9 |
| F. Escuela e historia | Monasterio que crece, hilos de Ming y Tie, misterio y final verdadero | ~6 |
| G. Identidad y audio | ~14 íconos, música real por capas, efectos clave | ~14 |
| H. Contenido y retención | Cartas bisagra, maestrías, diario, ascensiones, Leopardo | ~15+ |

**Por dónde empezar:** A y B. A cambia cómo se ve todo sin tocar reglas ni pedir arte; B cambia cómo se siente cada turno. C conviene hacerla junto con B, porque Flujo y Respirar mueven el balance y hace falta el bot prudente para medirlo.
