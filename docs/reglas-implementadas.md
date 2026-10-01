# Reglas implementadas: interpretaciones

El documento de diseño deja algunos puntos abiertos. Estas son las decisiones que toma el motor (`lib/domain/combat/combat_engine.dart`). Cada una se puede cambiar.

## Mapa de la run
Murciélago → Discípulo → Santuario → bifurcación [Gólem | Salamandra] → Fuente → Monje sin Rostro → Eco del Dragón (8 nodos y 7 pasos). Está definido en `assets/data/game_balance.json`.

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
- Solo los Puños, Palmas y Patadas pueden interrumpir. Las defensas y técnicas nunca interrumpen, aunque estén en otro paso de la secuencia.
- El efecto de la forma no recibe el bonus de postura; sí le aplican el ×2 por desequilibrio, el ½ del Gólem y Hǔ Xiào.
- Interrumpir del Monje: si no lo desviás, todas las formas vuelven a 0.

## Enemigos
- **Chillido:** al empezar tu próximo turno, después de robar, tenés que descartar 1 carta antes de hacer cualquier otra cosa.
- **Discípulo:** si tu postura al terminar el turno es la misma que al terminar el anterior, el ataque que ejecuta en ese momento suma +5 de daño y +2 a Estructura. El primer turno no cuenta.
- **Gólem:** Carga se acumula para su próximo ataque.
- **Salamandra:** su Guardia dura hasta su siguiente acción.
- **Eco del Dragón:** al cruzar el 50% de Vida cambia de fase en el acto y el ciclo empieza desde el paso 0. La intención muestra cuántas acciones faltan para el Aliento del Dragón.

## Mano
- Robás hasta completar el tamaño de mano de tu camino. Las cartas robadas por efectos pueden superar ese tamaño.
- Retener se elige al terminar el turno (acción `EndTurn(retain: [...])`).
- Bàoquán Lǐ (Saludo marcial) roba 2 y se agota; se puede jugar en cualquier turno (antes era solo el turno 1 y quedaba muerta si la robabas tarde).

## Recompensas
- Se ofrecen 3 cartas al azar de los pools de `rewards.pools`.
- Un pool con el nombre de un camino (`tiger`) solo aparece si seguís ese camino. Antes del santuario no sale ninguno.
