# Reglas implementadas: interpretaciones

El documento de diseño deja algunos puntos abiertos. Estas son las decisiones que toma el motor (`lib/domain/combat/combat_engine.dart`). Cada una se puede cambiar.

## Mapa de la run
Murciélago → [Discípulo | Evento] → Santuario → bifurcación [Gólem | Salamandra] → Evento → Fuente → Monje sin Rostro → Eco del Dragón (10 nodos y 8 pasos). Está definido en `assets/data/game_balance.json`.

## Eventos
- Datos en `assets/data/events.json`; textos (nombre, escena, opciones y resultados) en `assets/l10n/content/es.json` → `events`.
- Al entrar a un nodo `event` se sortea uno con el RNG de la run entre los que no salieron (`seenEvents`); si salieron todos, entre todos.
- Cada opción tiene un resultado (`hp` = Vida que se pierde, `heal`, `maxHp`, `gain`) o, si tiene `chance`, un `success` y un `failure`.
- La Vida perdida en un evento nunca baja de 1. Una opción con costo de Vida solo se puede elegir si `hp > costo`. El riesgo no cuenta como costo.
- `maxHp` sube la Vida máxima y cura lo mismo.
- Ganancias: `form` (una forma aprendible; si no queda ninguna, una carta), `talisman` / `rareTalisman` (uno que no se tenga de esa rareza; si no queda, cualquiera), `card` (del pool de recompensas del camino), `upgrade` (+3 a una carta mejorable al azar), `loseStarter` (se va una carta inicial al azar).
- Al resolver se vuelve al mapa y queda `lastEvent` con lo que pasó, para mostrarlo.

## Talismanes
- Datos en `assets/data/talismans.json` (efecto y rareza); nombres en `es.json` → `talismans`. El texto del efecto se arma con l10n desde los números.
- El élite (Monje) abre la fase `talisman`: 3 al azar de los que no se tienen. Se elige uno (no se saltea) y después viene la recompensa, que ya estaba sorteada.
- Al empezar el combate: postura inicial, Estructura máxima extra, Aliento del turno 1 (vía `nextTurnBreathMod`) y Vida/Estructura del rival (nunca menos de 1; el máximo del rival no cambia, así se ve la diferencia). Cada uno emite `TalismanTriggered`.
- En combate: Aliento extra por desvío (al turno siguiente) y curación al completar una forma.
- En la run: Vida máxima (al conseguirlo), curación de la fuente (`healOf`) y curación al ganar un combate (no en el jefe final, que termina la run).

## Santuario y caminos
- La run empieza sin camino (`style: null`) con las estadísticas de `novice`.
- Al entrar al santuario se barajan los 3 caminos con el RNG de la run y se ofrecen los primeros `paths.choices` (2). Es reproducible con la misma semilla.
- Hay que tomar uno (no se saltea) y queda fijo hasta el final de la run.
- Las runs guardadas antes de este cambio conservan el camino que tenían.

## Daño del jugador
1. Base de la carta + mejora de la fuente (a la Guardia si la carta tiene Guardia; si no, al daño).
2. Bonus (y costo, y Guardia) de la postura en la que estás al jugarla. Una carta con postura te mueve **después** de aplicar su efecto.
3. Bonus condicionales: Pī Quán (+6 si el enemigo está Desequilibrado), Hǔ Zhǎo (+2 E en mǎbù).
4. Hǔ Xiào: +2 a todo daño a Estructura en ese turno, incluido el de las formas.
5. Enemigo Desequilibrado: daño ×2. Gólem (inamovible) sin desequilibrar: daño ½.
6. La Guardia enemiga absorbe daño, pero no daño a Estructura.

## Desequilibrio del enemigo
- Al llegar a 0 de Estructura en el turno N, ya sea por tu ataque o por un desvío durante su acción, queda Desequilibrado hasta el final de tu turno N+1.
- Pierde su próxima acción y el ciclo sigue desde la acción siguiente.
- Mientras está Desequilibrado no recibe daño a Estructura. Al terminar, recupera la Estructura máxima.

## Guardia y desvío
- La Guardia no se consume entre golpes y vuelve a 0 al empezar tu turno. Su altura es la de la última defensa jugada.
- En un ataque doble, la Guardia se aplica a cada golpe. Como no se consume, si desvía un golpe desvía todos, y el desvío se premia **una vez por acción**: +1 Aliento, +1 extra en xūbù, −3 E al enemigo y los bonus de Tí Xī o Hǔ Bào Tóu.
- Bloqueo con altura incorrecta: absorbe la mitad (redondeo hacia abajo) y el daño a Estructura también se reduce a la mitad.
- Estructura recibida: primero se aplica la mitad por bloqueo, después la mitad de mǎbù, y después el +2 de gōngbù (solo si queda algo).

## Estructura del jugador
Si llega a 0, el próximo turno empieza con −2 de Aliento (mínimo 0) y la Estructura se restablece a 10 en ese momento.

## Formas
- La subida arranca sin formas (`RunState.knownForms` vacío). Al ganar un combate que no es el último, se sortea una forma no aprendida y permitida por el camino (`pool`) como `rewardForm`. Elegir carta (o saltear) la descarta; `chooseForm` la aprende sin sumar carta.
- El combate solo sigue las formas conocidas (`CombatEngine.start(forms:)`). Las lecciones pasan las suyas en `LessonSetup.forms`.
- Efectos posibles: daño, Estructura, Guardia (+altura), robar, Aliento (`breath`), curar (`heal`, hasta la Vida máxima) y `fistBonus` (+daño a los Puños con daño, acumulable, todo el combate).
- Solo los Puños, Palmas y Patadas pueden interrumpir. Las defensas y técnicas nunca interrumpen, aunque estén en otro paso de la secuencia.
- El efecto de la forma no recibe el bonus de postura; sí le aplican el ×2 por desequilibrio, el ½ del Gólem y Hǔ Xiào.
- Interrumpir del Monje: si no lo desviás, todas las formas vuelven a 0.

## Enemigos
- **Chillido:** al empezar tu próximo turno, después de robar, tenés que descartar 1 carta antes de hacer cualquier otra cosa.
- **Discípulo:** si tu postura al terminar el turno es la misma que al terminar el anterior, el ataque que ejecuta en ese momento suma +5 de daño y +2 a Estructura. El primer turno no cuenta.
- **Gólem:** Carga se acumula para su próximo ataque.
- **Salamandra:** su Guardia dura hasta su siguiente acción.
- **Escamas (Eco del Dragón, 4):** restan su valor a cada golpe (cartas, formas y desvíos), después de la mitad del Inamovible y antes de la Guardia. No cuentan mientras está Desequilibrado. Al desequilibrarse pierde una escama (evento `ScaleShed`), para todo el combate.
- **Eco del Dragón:** al cruzar el 50% de Vida cambia de fase en el acto y el ciclo empieza desde el paso 0. La intención muestra cuántas acciones faltan para el Aliento del Dragón.
- **Fase 3 del Dragón (30%):** las escamas vuelven a 2 si tenía menos (evento `ScalesRegrown`); el ciclo pasa a barrido bajo doble y Aliento. Si un golpe cruza los dos umbrales a la vez, entra directo en la fase 3.

## Mano
- Al empezar el turno robás el tamaño de mano completo de tu camino; las cartas retenidas son extra y se suman. Las cartas robadas por efectos también pueden superar ese tamaño.
- Retener se elige al terminar el turno (acción `EndTurn(retain: [...])`).
- Bàoquán Lǐ (Saludo marcial) roba 2 y se agota; se puede jugar en cualquier turno (antes era solo el turno 1 y quedaba muerta si la robabas tarde).

## Dificultad
- Se elige al crear la run y se guarda en ella (`RunState.difficulty`; las runs viejas se leen como Normal).
- Vida inicial y curación de la fuente salen de la dificultad.
- Al ganar una subida se guarda la dificultad (`ProgressStorage`, fuera de la run). Shifu está bloqueada hasta tener una victoria en Difícil (o en Shifu).
- Al empezar cada combate de la subida se escalan la Vida y la Estructura del enemigo (redondeo al entero más cercano). El daño de cada ataque (con Carga y castigo incluidos) se escala al anunciarlo y al ejecutarlo, así que la intención muestra el número real.

## Recompensas
- Se ofrecen 3 cartas al azar de los pools de `rewards.pools`.
- Un pool con el nombre de un camino (`tiger`) solo aparece si seguís ese camino. Antes del santuario no sale ninguno.

## Mapa generado
- `run.floors` en `game_balance.json`: cada piso tiene un ancho (`width`, fijo o `[min, max]`), tipos con peso (`types`) y enemigos posibles (`enemies`).
- Se genera en `RunEngine.newRun` con la semilla de la run (`lib/domain/run/map_gen.dart`) y se guarda en la run (`RunState.map`). Las subidas guardadas sin mapa se descartan.
- Reglas: al menos un combate en cada piso que los permite; santuario, fuente, mercader y maestro como mucho uno por piso; mercader y maestro aparecen al menos una vez en el mapa; enemigos sin repetir dentro de un piso.
- Conexiones: cada nodo se une con los que le quedan enfrente; entre pisos del mismo ancho se suman diagonales al azar sin cruces.
- Se empieza eligiendo entre los nodos del primer piso (los que no tienen ninguno antes).

## Jade y mercader
- Cada combate ganado da `jade.common` + 0..`jade.spread` (élite: `jade.elite` + 0..`spread`). El jefe no da (termina la subida).
- El mercader (`merchant` en el balance) ofrece `cards` cartas del pool de recompensas, 1 talismán común que no tengas y dos servicios por visita: quitar una carta y mejorar una carta (+`fountain.upgrade`).
- No se puede comprar sin jade suficiente.

## Maestro errante
- Ofrece hasta `master.forms` formas que todavía no sabés y que tu camino permite.
- Se elige una sola cosa: aprender una de ellas o mejorar una carta (+`fountain.upgrade`).

