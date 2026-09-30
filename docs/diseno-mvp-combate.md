# Long Breath — Diseño del MVP de combate

Sep 29, 2026 · @Sebastian Pérez

## Resumen y objetivo del MVP

El MVP valida una sola pregunta: **¿el combate con cartas, posturas y formas es satisfactorio, desafiante y depende más de las decisiones que del azar?** Todo lo demás (árbol, cultivo del aliento, Legado, historia) queda fuera hasta que el combate funcione.

El juego es un roguelike de cartas para móvil (iOS y Android, en Flutter). El protagonista, un estudiante de kung fu, debe ascender la Montaña de las Mil Nubes (千云山) combatiendo. El vocabulario marcial es tradicional: posturas (步型 bùxíng), técnicas y formas (套路 tàolù) con su nombre en pinyin y caracteres.

**Nombre:** Long Breath. *Lóng* (龙) significa dragón en chino y *long breath* es respiración larga en inglés: une el dragón, la meditación y el Aliento del combate. La marca es global; cada región puede sumar un subtítulo localizado.

**Entra en el MVP:**

- Motor de combate completo: Aliento, mano, Vida, Estructura, intenciones del enemigo, desvío, desequilibrio, retener y respirar.
- 3 posturas (mǎbù, gōngbù, xūbù) más la acción de transición dīngbù.
- 24 cartas: 12 del mazo inicial y 12 de recompensa.
- 2 formas: Xiǎo Hóng Quán y Dà Hóng Quán.
- 1 estilo animal: Tigre (Hǔ Quán), como cartas de recompensa.
- 6 enemigos: 4 comunes, 1 élite y 1 guardián.
- Una run corta de 8 nodos con un santuario, una bifurcación y una fuente de meditación.
- Se empieza como novicio; en el santuario se elige entre 2 de los 3 caminos (Tigre, Serpiente o Grulla), sorteados.

**Queda fuera:** árbol de habilidades, cultivo del aliento, Legado, prólogo en el templo, narrativa, Firebase y monetización.

## Reglas de combate

El combate es por turnos, uno contra uno, y el enemigo siempre anuncia su próxima acción. El azar decide qué cartas tenés; la resolución de cada jugada es siempre determinista.

### Valores base del jugador (novicio)

| Valor | Base | Nota |
| --- | --- | --- |
| Vida | 50 | No se recupera entre combates, salvo en la fuente |
| Estructura | 10 | Se recupera completa al terminar cada combate |
| Aliento por turno | 3 | Lo que no se usa se pierde |
| Cartas robadas por turno | 5 |  |
| Retener | 1 carta | Se guarda para el turno siguiente |
| Respirar | 1 vez por combate | Descartás la mano y robás la misma cantidad, cuesta 0 |
| Postura inicial | Mǎbù |  |

### Orden del turno

1. Tu Guardia vuelve a 0. Robás hasta completar la mano. Si el mazo se vacía, se baraja el descarte.
2. Jugás cartas pagando su costo en Aliento, en el orden que quieras. Podés usar dīngbù (1 Aliento) para cambiar de postura.
3. Terminás el turno: elegís qué retener y el resto va al descarte.
4. El enemigo ejecuta la acción anunciada.
5. El enemigo anuncia su próxima acción.

### Guardia y altura

Las cartas de defensa dan Guardia y tienen una altura: alto, medio o bajo. La altura de tu Guardia es la de la última defensa jugada. Cada ataque enemigo anuncia daño, altura y daño a Estructura.

- **Altura correcta:** la Guardia absorbe su valor completo.
- **Altura incorrecta:** la Guardia absorbe la mitad (redondeo hacia abajo).
- **Desvío:** altura correcta y Guardia mayor o igual al daño. No recibís daño ni daño a Estructura, el enemigo pierde 3 de Estructura y empezás el próximo turno con +1 Aliento.
- Si bloqueás sin desviar, recibís la mitad del daño a Estructura. Sin Guardia, lo recibís completo.

### Estructura y desequilibrio

- **Enemigo:** si su Estructura llega a 0, queda Desequilibrado hasta el final de tu próximo turno. Pierde la acción anunciada y todo el daño que recibe se duplica. Después su Estructura vuelve al máximo.
- **Jugador:** si tu Estructura llega a 0, tu próximo turno empieza con 2 de Aliento menos. Después vuelve a 10.

### Victoria y derrota

Ganás cuando la Vida del enemigo llega a 0. Perdés cuando llega a 0 la tuya. Un combate normal debería durar entre 3 y 6 turnos.

## Posturas del MVP

Siempre estás en una postura, y cada una tiene en el juego las propiedades que tiene en el entrenamiento real. Cambiás de postura de dos formas: jugando una carta que la incluye en su nombre (por ejemplo, Gōngbù Chōngquán te lleva a gōngbù) o con la acción dīngbù.

| Postura | Propiedad real | Ventaja | Costo |
| --- | --- | --- | --- |
| Mǎbù 马步 (caballo) | Raíz, estabilidad | Puños y palmas +2 de daño. El daño a Estructura que recibís se reduce a la mitad | Las patadas cuestan +1 Aliento |
| Gōngbù 弓步 (arco) | Proyección hacia adelante | Puños +3 de daño y +1 de daño a Estructura | Recibís +2 de daño a Estructura |
| Xūbù 虚步 (vacía) | Peso atrás, pierna delantera libre | Patadas cuestan 1 menos (mínimo 0) y hacen +2 de daño. Un desvío da +1 Aliento extra | Cada defensa da 2 de Guardia menos |

**Dīngbù 丁步 (transición):** no es una postura donde te quedás, es una acción siempre disponible. Cuesta 1 Aliento, te lleva a cualquier postura y se puede usar una vez por turno. Existe para que una mano sin cartas de cambio de postura no te deje atrapado.

**Regla de aplicación:** una carta que cambia de postura primero te mueve y después aplica su efecto. Por eso Gōngbù Chōngquán ya recibe el bonus de gōngbù. Las técnicas sin postura en el nombre usan la postura en la que estás.

**Próximas posturas (fuera del MVP):** pūbù 仆步, xiēbù 歇步 y dúlìbù 独立步.

## Cartas

El MVP tiene 24 cartas: 12 en el mazo inicial y 12 que se obtienen como recompensa (8 generales y 4 del estilo Tigre, en su propia sección). Los nombres siguen la convención de las formas: postura + técnica. Los valores de la tabla son base, antes de bonus de postura.

### Anatomía de una carta

Cada carta tiene: id, nombre en pinyin, caracteres, traducción al español, tipo (Puño, Palma, Patada, Defensa o Técnica), costo en Aliento, postura destino (opcional), daño, daño a Estructura, Guardia y altura (si es defensa), efecto especial y las formas a las que pertenece. Una carta con **Agotar** se elimina por el resto del combate al jugarla.

### Mazo inicial (12 cartas)

| Carta | Tipo | Costo | Efecto base | Copias |
| --- | --- | --- | --- | --- |
| Gōngbù Chōngquán 弓步冲拳 (puño en arco) | Puño | 1 | Pasás a gōngbù. 6 de daño, 1 a Estructura | 3 |
| Mǎbù Chōngquán 马步冲拳 (puño en caballo) | Puño | 1 | Pasás a mǎbù. 5 de daño, 2 a Estructura | 1 |
| Tán Tuǐ 弹腿 (patada de latigazo) | Patada | 1 | 5 de daño, 1 a Estructura | 2 |
| Tuī Zhǎng 推掌 (empuje de palma) | Palma | 1 | 2 de daño, 4 a Estructura | 1 |
| Mǎbù Jiàdǎ 马步架打 (bloquear y golpear) | Defensa | 2 | Pasás a mǎbù. Guardia 6 alta y 4 de daño | 1 |
| Xūbù Liàngzhǎng 虚步亮掌 (mostrar la palma) | Defensa | 1 | Pasás a xūbù. Guardia 7 alta (5 efectiva en xūbù) y robás 1 | 1 |
| Gé Dǎng 格挡 (bloqueo) | Defensa | 1 | Guardia 7 media | 2 |
| Àn Zhǎng 按掌 (palma que presiona) | Defensa | 1 | Guardia 6 baja | 1 |

### Cartas de recompensa generales (8)

| Carta | Tipo | Costo | Efecto base |
| --- | --- | --- | --- |
| Dēng Tuǐ 蹬腿 (patada de talón) | Patada | 2 | 8 de daño, 3 a Estructura |
| Cè Chuài 侧踹 (patada lateral) | Patada | 2 | 5 de daño, 6 a Estructura |
| Gōngbù Tuīzhǎng 弓步推掌 (empuje en arco) | Palma | 1 | Pasás a gōngbù. 3 de daño, 5 a Estructura |
| Pī Quán 劈拳 (puño que corta) | Puño | 1 | 6 de daño. +6 si el enemigo está Desequilibrado |
| Shàng Jià 上架 (bloqueo alto) | Defensa | 1 | Guardia 9 alta |
| Tí Xī 提膝 (rodilla arriba) | Defensa | 1 | Guardia 6 baja. Si desviás, 4 de daño |
| Tiáo Xī 调息 (regular la respiración) | Técnica | 0 | +1 Aliento y robás 1. Agotar |
| Bàoquán Lǐ 抱拳礼 (saludo) | Técnica | 0 | Solo en el primer turno. Robás 2. Agotar |

**Recompensas:** tras cada combate elegís 1 de 3 cartas al azar del grupo de recompensa, o salteás. Saltear es válido: un mazo chico es más predecible.

## Formas (套路 tàolù)

Una forma es una secuencia fija de cartas; si la completás en orden, se desata un efecto grande. Es practicar el tàolù: la forma solo funciona ejecutada completa y en orden.

### Reglas de progreso

- La forma avanza cuando jugás la siguiente carta de su secuencia. El progreso se mantiene entre turnos, dentro del mismo combate.
- Un Puño, Palma o Patada que no es el paso siguiente **interrumpe** la forma y el progreso vuelve a 0. Si esa carta es el primer paso, la forma reinicia en el paso 1.
- Las Defensas y Técnicas que no son parte de la secuencia no interrumpen. Podés defenderte en medio de una forma.
- Algunos enemigos tienen una acción de interrumpir que reinicia tu progreso si no la desviás.
- Podés tener varias formas en progreso a la vez, y una carta puede avanzar más de una.
- El efecto se aplica al resolverse la última carta. Después el progreso vuelve a 0 y la forma se puede repetir.

### Xiǎo Hóng Quán 小洪拳 (Pequeño Puño Rojo)

Disponible desde el inicio, con cartas del mazo inicial. Cuesta 5 de Aliento en total, así que normalmente se completa en dos turnos.

1. Gōngbù Chōngquán
2. Tán Tuǐ
3. Mǎbù Jiàdǎ
4. Xūbù Liàngzhǎng

**Al completarla:** 10 de daño, 5 a Estructura y robás 2 cartas.

### Dà Hóng Quán 大洪拳 (Gran Puño Rojo)

Requiere dos cartas de recompensa: Gōngbù Tuīzhǎng y Dēng Tuǐ. Cuesta 6 de Aliento en total.

1. Mǎbù Chōngquán
2. Gōngbù Tuīzhǎng
3. Dēng Tuǐ
4. Xūbù Liàngzhǎng
5. Gōngbù Chōngquán

**Al completarla:** 18 de daño, 8 a Estructura y Guardia 8 media.

**Pendiente de validar:** estas secuencias son provisorias y están armadas con las cartas del MVP. La idea es reemplazarlas por 4 o 5 movimientos representativos del inicio de cada forma tal como se practica en la escuela, y agregar las cartas que falten.

## Estilo animal: Tigre (虎拳 Hǔ Quán)

El Tigre es el estilo de la fuerza y su identidad mecánica es romper Estructura. Es uno de los cinco animales del Wǔ Xíng Quán 五形拳 de Shaolín. En el MVP son 4 cartas de recompensa; en el juego completo será una rama del árbol.

| Carta | Tipo | Costo | Efecto base |
| --- | --- | --- | --- |
| Hǔ Zhǎo 虎爪 (garra de tigre) | Palma | 1 | 3 de daño, 4 a Estructura. En mǎbù, +2 a Estructura |
| Hǔ Pū 虎扑 (salto del tigre) | Palma | 2 | Pasás a gōngbù. 10 de daño, 3 a Estructura. Perdés toda tu Guardia |
| Hǔ Bào Tóu 虎抱头 (el tigre se cubre) | Defensa | 1 | Guardia 7 alta. Si desviás, el enemigo pierde 3 de Estructura extra |
| Hǔ Xiào 虎啸 (rugido del tigre) | Técnica | 1 | Este turno, todo daño a Estructura +2. Agotar |

El Tigre combina con mǎbù y con el desequilibrio: romper la Estructura con garras y rematar con Pī Quán o una forma.

**Fuera del MVP:** las cartas propias de la Serpiente y la Grulla, y el Leopardo. En el MVP las cartas del Tigre aparecen como recompensa en cualquier camino. El Dragón queda sellado por la historia.

## Enemigos

Cada enemigo enseña o pone a prueba una mecánica, y su regla especial obliga a cambiar la forma de jugar. Los patrones son cíclicos y siempre visibles un turno antes. Los ataques se escriben como altura, daño y daño a Estructura (E).

| Enemigo | Rango | Vida | Estructura | Patrón cíclico | Regla especial |
| --- | --- | --- | --- | --- | --- |
| Eco de Murciélago | Común | 18 | 6 | Alto 3×2 (E1) → Alto 6 (E2) → Chillido | Chillido: descartás 1 carta a tu elección. En un ataque doble, la Guardia se aplica a cada golpe |
| Salamandra de la Grieta | Común | 24 | 8 | Bajo 7 (E2) → Se entierra (Guardia 8) → Bajo 9 (E3) | Su Guardia absorbe daño, pero no daño a Estructura. Premia palmas y empujes |
| Gólem de Estalactita | Común | 30 | 12 | Medio 10 (E4) → Carga (su próximo ataque +5) → Medio 10 (E4) | Inamovible: recibe la mitad del daño salvo que esté Desequilibrado |
| Discípulo Perdido | Común | 32 | 10 | Alto 6 (E2) → Medio 8 (E2) → Barrido bajo 6 (E4) | Si terminás el turno en la misma postura que el anterior, su próximo ataque hace +4 de daño y +2 a Estructura |
| Monje sin Rostro | Élite | 55 | 15 | Medio 9 (E3) → Interrumpir: alto 5 → Bajo 12 (E4) | Interrumpir: si no lo desviás, tus formas en progreso vuelven a 0 |
| Eco del Dragón 龙音 Lóng Yīn | Guardián | 90 | 20 | Fase 1: Alto 8 (E2) → Medio 10 (E3) → Bajo 8 (E4). Fase 2: Alto 10 (E3) → Bajo 10 (E3) → Aliento del Dragón | Fase 2 empieza al 50% de Vida. Aliento del Dragón: medio 25 (E8), con cuenta regresiva visible. Se evita desviándolo o dejándolo Desequilibrado antes |

**Lore breve:** el Discípulo Perdido y el Monje sin Rostro son espíritus de estudiantes que cayeron antes que vos. Ese detalle ya prepara el giro del maestro y el sistema de Legado.

## Estructura de la run del MVP

La run se juega de abajo hacia arriba, como el ascenso por la montaña: 8 nodos: dos combates como novicio, el santuario de los animales, una bifurcación y una fuente antes de la élite.

&#91;embedded content: mapa de la run del MVP · 7 nodos, 1 bifurcación\]

En la bifurcación, el jugador elige entre un enemigo que premia romper Estructura (Gólem) y uno que premia palmas y empujes (Salamandra), según las cartas que haya juntado.

### Fuente de meditación

Elegís una sola opción: curar 15 de Vida, eliminar 1 carta del mazo, o mejorar 1 carta (+3 a su daño o a su Guardia). Si perdés, la run termina y empieza de nuevo desde el primer nodo con el mazo inicial.

### Caminos (estilos animales)

Reemplazan al sistema de edad: cambian cómo se juega la mano sin necesitar un personaje distinto por etapa. No se eligen al empezar: el jugador sube como **novicio** (5 cartas, 3 de Aliento, sin retener, túnica sin teñir) y, después del Discípulo, el **santuario** sortea 2 de los 3 caminos y el jugador toma uno para el resto de la run. Cuántos se ofrecen está en `paths.choices` de `game_balance.json`.

| Camino | Color | Cartas robadas | Aliento | Retener | Lectura |
| --- | --- | --- | --- | --- | --- |
| Tigre 虎 Hǔ | Bermellón | 6 | 4 | 0 | Agresivo, todo o nada |
| Serpiente 蛇 Shé | Violeta | 5 | 3 | 1 | Fluido, equilibrado |
| Grulla 鹤 Hè | Cobalto | 4 | 3 | 3 | Paciente, planifica |

- **Visual:** un solo arte del héroe (`assets/art/player/hero.png`). `tool/recolor_hero.py` genera la variante del novicio (lino crudo) y una por camino tiñendo solo la tela bermellón; el aura y el carácter del animal se dibujan por código.
- **Juego completo:** cada camino será una rama del árbol con sus propias cartas.
- **Cultivo del aliento (fuera del MVP):** progresión entre partidas por reinos (境界). Cada reino abre espacios del árbol y alguna mejora chica; morir hace perder parte del aliento acumulado, pero nunca se baja de reino. Visualmente solo crece el aura.

## Pantalla de combate

La pantalla es vertical y jugable con una mano; el jugador nunca debería tener que calcular, solo decidir. Por eso la interfaz siempre muestra los valores finales con los bonus ya aplicados.

### Zonas, de arriba hacia abajo

1. **Enemigo:** figura, Vida, barra de Estructura, Guardia y regla especial (tocando el ícono).
2. **Intención:** ícono grande con altura (alto, medio o bajo), daño y daño a Estructura. En el guardián, cuenta regresiva del Aliento del Dragón.
3. **Jugador:** Vida, barra de Estructura, Guardia con su altura, y la postura actual resaltada entre las tres.
4. **Formas:** una fila por forma con sus pasos. Los completados se marcan y el próximo paso se resalta.
5. **Mano:** cartas en abanico, Aliento disponible y botones de Dīngbù, Respirar y Terminar turno.

### Interacción y feedback

- Un toque selecciona la carta y muestra la vista previa: daño final, Guardia final y postura resultante. Un segundo toque la juega.
- Las cartas que avanzan una forma tienen un borde brillante. Las que la interrumpirían muestran una advertencia.
- Un desvío, un desequilibrio y una forma completada tienen cada uno su animación y sonido. Al completar una forma aparece su nombre en caracteres grandes.
- Al retener, se elige con un toque qué carta queda para el turno siguiente.

## Implementación técnica en Flutter

El MVP se hace en Flutter para iOS y Android, con widgets y animaciones nativas, sin motor de juego. Un juego de cartas por turnos no necesita game loop; Flame se puede sumar más adelante si hacen falta efectos visuales complejos.

### Arquitectura

- **Domain:** Dart puro, sin imports de Flutter. `CombatState` inmutable y un motor que funciona como reductor: recibe un estado y una acción y devuelve el nuevo estado más una lista de eventos (daño, desvío, forma completada) que la interfaz usa para animar. El azar usa un generador con semilla inyectada, así cada combate es reproducible.
- **Infrastructure:** carga de datos desde JSON y guardado local de la run. Sin Firebase en el MVP.
- **Delivery:** Riverpod para el estado, go\_router para las pantallas (mapa, combate, recompensa, fuente, resultado) y localización ARB, empezando en español.

### Datos externalizados

Todo el balance vive en archivos, no en código: `game_balance.json` (valores base, caminos, recompensas), `cards.json`, `stances.json`, `forms.json` y `enemies.json`. Cambiar un número no requiere recompilar la lógica.

```
lib/
  domain/          # motor de combate, modelos, reglas
  infrastructure/  # carga de JSON, guardado local
  delivery/        # pantallas, widgets, providers
assets/data/       # cards, stances, forms, enemies, game_balance
tool/simulate.dart # simulador sin interfaz
test/              # tests del motor
```

### Simulador de balance

Como el motor no depende de Flutter, se puede correr sin interfaz. `tool/simulate.dart` juega miles de combates con tres bots: uno aleatorio, uno codicioso (máximo daño inmediato) y uno planificador (busca formas y desequilibrios). Reporta porcentaje de victorias, turnos promedio y formas completadas por enemigo. Es la herramienta principal para ajustar números.

## Criterios de éxito y preguntas abiertas

El MVP funciona si las victorias dependen de las decisiones y no de la mano que tocó. Estos son los objetivos iniciales; los números se ajustan con el simulador.

| Criterio | Objetivo |
| --- | --- |
| Duración de un combate común | 3 a 6 turnos |
| Diferencia de victorias entre el bot planificador y el aleatorio | 30 puntos porcentuales o más |
| Xiǎo Hóng Quán completada por un jugador humano | En al menos la mitad de los combates |
| Victoria contra el guardián de alguien que ya entiende el sistema | Entre 40% y 60% de las runs |
| Percepción de testers | Atribuyen sus derrotas a decisiones propias, no a la suerte |

### Preguntas abiertas

- [ ] Secuencias reales de Xiǎo Hóng Quán y Dà Hóng Quán según la escuela.
- [ ] Nombres de las técnicas tal como se usan en la escuela (pinyin estándar o nombres propios del linaje).
- [ ] Dirección de arte: figura esquelética paramétrica o ilustración.
- [ ] Si el prólogo en el templo entra en la segunda versión del MVP.
