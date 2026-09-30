# Long Breath · Manual

Manual del juego tal como está hoy (MVP). La primera parte cuenta el mundo; la segunda explica cómo se juega. Los números salen de `assets/data/` y pueden cambiar con el balance.

---

# Parte 1 · Lore e historia

## El nombre

*Lóng* (龙) es dragón en chino; *long breath* es respiración larga en inglés. El juego une las dos cosas: el dragón que espera en la cumbre y el aliento (气 qì) que sostiene cada golpe. En la escuela se dice que quien controla la respiración controla el combate.

## La escuela del Dragón Dormido

Sos discípulo de la **escuela del Dragón Dormido** (卧龙门 Wòlóng Mén), que entrena al pie de la **Montaña de las Mil Nubes** (千云山 Qiān Yún Shān). La escuela toma su nombre de la leyenda de la montaña: en la cumbre duerme un dragón, y su respiración es la que forma las nubes. La prueba final de todo alumno es subirla solo, combatiendo, hasta la cumbre.

El emblema de la escuela, un dragón rojo, va bordado en la espalda de cada discípulo.

## Los tres caminos

Nadie elige su camino en la escuela. Los novicios suben con la túnica de lino crudo, sin teñir, y a mitad de la ladera, pasado el Discípulo Perdido, llegan al **Santuario de los animales**. Ahí los espíritus del Wǔ Xíng Quán (五形拳, los cinco animales de Shaolín) se muestran al novicio, pero nunca todos: **solo dos se presentan**, y el novicio sigue a uno de ellos. Los maestros dicen que no elegís el camino; el camino te elige a vos y vos solo aceptás.

El camino no cambia quién sos; cambia cómo peleás. Desde ese momento la túnica toma el color del animal:

| Camino | Color de la túnica | Lema | Cómo pelea |
|---|---|---|---|
| **Tigre** 虎 | Bermellón | *Golpea primero, golpea fuerte.* | Ataca sin pausa; mucha energía, nada de reserva |
| **Serpiente** 蛇 | Violeta | *Fluye y muerde en el hueco.* | Se adapta; equilibrio entre ataque y paciencia |
| **Grulla** 鹤 | Cobalto | *Espera. El momento llega.* | Guarda sus mejores movimientos para el instante justo |

Existen otros dos animales, el Leopardo y el Dragón. El Dragón está sellado: nadie en la escuela lo enseña.

## La montaña

La subida se hace por tramos: la ladera de bambú, el santuario de los animales, una bifurcación entre rocas, una fuente de meditación, un templo en el acantilado y, arriba de todo, la cumbre sobre un mar de nubes.

Antes de subir, los novicios practican en el patio con el **muñeco de madera** (木人桩), el mismo que se usa en las escuelas de Wing Chun y de Hung Gar. En el camino aparecen:

- **Eco de Murciélago:** un espíritu hecho de ecos. Su chillido aturde y te hace soltar lo que tenés en la mano.
- **Discípulo Perdido:** un alumno que no llegó arriba y quedó atrapado en la montaña. Castiga a quien se queda quieto en la misma postura.
- **Gólem de Estalactita:** roca con vetas de cristal, casi inamovible hasta que se le rompe el equilibrio.
- **Salamandra de la Grieta:** ágil y escurridiza, se entierra para protegerse.
- **Monje sin Rostro** (élite): un maestro con máscara de porcelana que interrumpe las formas a medio ejecutar.
- **Eco del Dragón** 龙音 (guardián): en la cumbre no espera un dragón, sino su eco, un espíritu de aliento dorado y nubes. Al quedar herido despierta y prepara el **Aliento del Dragón**.

El Discípulo Perdido y el Monje sin Rostro son espíritus de estudiantes que cayeron antes que vos. Esa pista prepara la historia completa: qué le pasó a los que no volvieron y qué quiere el maestro de la escuela.

> **Pendiente:** Estalactita, Grieta y Murciélago vienen de la vieja idea de la cueva. Los nombres se pueden cambiar en `assets/l10n/content/es.json`.

## Lo que viene (fuera del MVP)

- **Cultivo del aliento:** con cada partida el discípulo avanza por reinos de cultivo (境界). No envejece ni cambia de cuerpo; su aura crece.
- **Árbol del camino:** cada animal tendrá su rama y sus propias cartas.
- **Legado e historia:** el prólogo en el templo, el giro del maestro y lo que heredan los que vienen detrás.

---

# Parte 2 · Mecánicas de juego

## Entrenamiento (tutorial)

La primera vez que abrís el juego, el botón principal es **Empezar entrenamiento**: un combate guiado en el patio de la escuela contra el **muñeco de madera** (木人桩 Mù Rén Zhuāng). El maestro resalta cada parte de la pantalla y, cuando pide una jugada, solo deja tocar lo que corresponde:

1. Qué es el globo de intención del enemigo, su Vida y su Estructura, tus barras, tu mano y el Aliento.
2. Jugar **Puñetazo a fondo**: un toque para ver la vista previa y otro para jugarla. La carta te mueve a postura Arco.
3. Defenderte con **Paso atrás** (Guardia alta contra un ataque alto) y jugar **Patada látigo** gratis en postura Vacía, que además avanza el Pequeño Puño Rojo.
4. Terminar el turno: desviás el golpe y el muñeco queda **Desequilibrado**.
5. Rematarlo libremente con el daño doble. Al ganar, el maestro resume cómo sigue la montaña y ofrece **Empezar la subida**.

Se puede **saltear** en cualquier momento. Después aparece **Repetir entrenamiento** en el inicio; si ya sabés jugar, **Ya sé jugar: nueva run** lo omite.

## Una partida (run)

1. **Inicio:** tocás **Nueva run** y empezás como novicio, sin camino. **Continuar run** retoma la partida guardada; si la dejaste en medio de un combate, vuelve al mapa antes de ese combate.
2. **Mapa:** 8 nodos de abajo hacia arriba. Tocás el siguiente nodo para avanzar.

   Murciélago → Discípulo → **Santuario** → **bifurcación** (Gólem o Salamandra) → Fuente → Monje sin Rostro → Eco del Dragón

3. **Santuario de los animales:** se ofrecen **2 de los 3 caminos, al azar**. Tocar uno muestra cómo te queda la túnica y sus números; **Tomar este camino** lo confirma para el resto de la run. No se puede saltear ni cambiar.

4. **Después de cada combate** elegís 1 de 3 cartas para sumar al mazo, o salteás. Saltear está bien: un mazo chico es más predecible.
5. **Fuente de meditación:** elegís una opción entre curar 15 de Vida, eliminar 1 carta del mazo o mejorar 1 carta (+3 a su daño o a su Guardia).
6. **Fin:** ganás al vencer al Eco del Dragón. Si tu Vida llega a 0, la run termina y la próxima empieza de cero con el mazo inicial.

La Vida **no** se recupera entre combates (solo en la fuente). La Estructura sí, completa.

## Tu camino

| Camino | Robás por turno | Aliento por turno | Retenés |
|---|---|---|---|
| Novicio (hasta el santuario) | 5 | 3 | 0 |
| Tigre | 6 | 4 | 0 |
| Serpiente | 5 | 3 | 1 |
| Grulla | 4 | 3 | 3 |

- **Tigre:** más cartas y más Aliento, pero todo lo que no uses se pierde. Ideal para aprender.
- **Serpiente:** el punto medio.
- **Grulla:** pocas cartas por turno, pero puede guardar hasta 3 para armar formas y respuestas exactas. Es el más difícil.

Como el santuario ofrece solo dos, no siempre vas a poder jugar tu camino favorito: parte de la gracia es adaptarse al que te toca.

## Valores del jugador

| Valor | Base | Nota |
|---|---|---|
| Vida | 50 | Si llega a 0 perdés la run |
| Estructura | 10 | Tu equilibrio. Se recupera al terminar cada combate |
| Aliento | según camino | Se paga para jugar cartas. Lo que sobra se pierde |
| Respirar | 1 vez por combate | Descartás la mano y robás la misma cantidad, gratis |
| Postura inicial | Caballo (马步) | |

## Cómo leer la pantalla de combate

De arriba hacia abajo:

1. **Arena.** El enemigo al frente y tu héroe de espaldas, abajo a la izquierda.
   - **Globo sobre el enemigo:** lo que va a hacer en su próxima acción. La flecha indica la altura (↑ alto, → medio, ↓ bajo), el número es el daño y **E** es el daño a tu Estructura.
   - **Placa con el nombre:** su color indica el rango (jade común, violeta élite, bermellón jefe). Tocala para leer su regla especial.
   - **Barras:** Vida (rojo) y Estructura (violeta). Debajo aparecen su Guardia y si está Desequilibrado.
2. **Tus barras:** Vida y Estructura.
3. **Posturas:** Caballo, Arco y Vacía; la actual está resaltada. A la derecha, tu Guardia.
4. **Formas:** los pasos de cada forma; el próximo paso se resalta.
5. **Mano:** tus cartas. Arriba a la izquierda de cada una está el costo en Aliento.
6. **Acciones:** Aliento disponible, **Paso en T**, **Respirar** y **Terminar turno**.

Un toque en una carta la selecciona y muestra la vista previa con los números finales (bonus incluidos). Un segundo toque la juega. Nunca hace falta hacer cuentas.

## El turno

1. Tu Guardia vuelve a 0 y robás hasta completar la mano. Si el mazo se vacía, se mezcla el descarte.
2. Jugás cartas pagando su Aliento, en el orden que quieras.
3. Terminás el turno. Si tu camino permite retener, elegís qué cartas guardar; el resto va al descarte.
4. El enemigo hace la acción anunciada.
5. El enemigo anuncia la siguiente.

## Cartas

Hay cinco tipos: **Puño**, **Palma**, **Patada**, **Defensa** y **Técnica**. Cada carta muestra el nombre traducido, el nombre chino como marca de agua y el pinyin.

- Una carta que lleva a una postura (por ejemplo *Puñetazo a fondo*, que dice → Arco) **primero te mueve** a esa postura y después aplica su efecto, ya con el bonus de la postura nueva.
- **Agotar:** la carta desaparece por el resto del combate al jugarla.
- **Saludo marcial** (Bàoquán Lǐ) solo se puede jugar en el primer turno.

## Posturas

Siempre estás en una postura:

| Postura | Ventaja | Costo |
|---|---|---|
| **Caballo** 马步 | Puños y palmas +2 de daño. El daño a Estructura que recibís se reduce a la mitad | Las patadas cuestan +1 Aliento |
| **Arco** 弓步 | Puños +3 de daño y +1 a Estructura | Recibís +2 de daño a Estructura |
| **Vacía** 虚步 | Patadas cuestan 1 menos y hacen +2 de daño. Un desvío da +1 Aliento extra | Cada defensa da 2 de Guardia menos |

**Paso en T** (丁步): cuesta 1 Aliento, te lleva a cualquier postura y se usa una vez por turno. Sirve para no quedar atrapado cuando la mano no trae cartas de cambio.

## Guardia, altura y desvío

Las defensas dan **Guardia** con una altura (alta, media o baja). Vale la altura de la última defensa que jugaste. Cuando el enemigo ataca:

- **Altura correcta:** la Guardia absorbe todo su valor.
- **Altura incorrecta:** absorbe la mitad.
- **Desvío** (化): altura correcta y Guardia mayor o igual al daño. No recibís daño ni daño a Estructura, el enemigo pierde 3 de Estructura y empezás el próximo turno con +1 Aliento.
- Si bloqueás sin desviar, recibís la mitad del daño a Estructura.
- En un ataque doble (por ejemplo 3×2) la Guardia se aplica a cada golpe, y el desvío se premia una sola vez.

## Estructura y Desequilibrio

La Estructura es el equilibrio del luchador.

- **Enemigo en 0:** queda **Desequilibrado** hasta el final de tu próximo turno. Pierde la acción anunciada y recibe **el doble de daño**. Después recupera toda su Estructura. Es el momento de rematar.
- **Vos en 0:** tu próximo turno empieza con 2 de Aliento menos, y la Estructura vuelve a 10.

## Formas (套路)

Una forma es una secuencia fija de cartas. Si la completás en orden, se desata un efecto grande y su nombre aparece en pantalla.

- Avanza cuando jugás el paso siguiente. El progreso se mantiene entre turnos dentro del mismo combate.
- Un Puño, Palma o Patada que no sea el paso siguiente la **interrumpe** y vuelve a 0.
- Defensas y técnicas fuera de la secuencia **no** interrumpen: podés defenderte en medio de una forma.
- Varias formas pueden avanzar a la vez, y una forma completada se puede repetir.

| Forma | Pasos | Al completarla |
|---|---|---|
| **Pequeño Puño Rojo** 小洪拳 | Puñetazo a fondo → Patada látigo → Bloqueo y contragolpe → Paso atrás | 10 de daño, 5 a Estructura, robás 2 |
| **Gran Puño Rojo** 大洪拳 | Puñetazo firme → Empujón a fondo → Patada de talón → Paso atrás → Puñetazo a fondo | 18 de daño, 8 a Estructura, Guardia 8 media |

El Gran Puño Rojo necesita dos cartas de recompensa: *Empujón a fondo* y *Patada de talón*.

## Enemigos

Los patrones se repiten en ciclo y siempre se ven un turno antes.

| Enemigo | Rango | Vida | Estructura | Patrón | Regla especial |
|---|---|---|---|---|---|
| Eco de Murciélago | Común | 18 | 6 | Alto 3×2 → Alto 6 → Chillido | Chillido: al empezar tu turno descartás 1 carta a elección |
| Discípulo Perdido | Común | 32 | 10 | Alto 6 → Medio 8 → Barrido bajo 6 | Si terminás el turno en la misma postura que el anterior, su ataque hace +4 de daño y +2 a Estructura |
| Gólem de Estalactita | Común | 30 | 12 | Medio 10 → Carga → Medio 10 | Recibe la mitad del daño salvo que esté Desequilibrado. La Carga suma +5 a su próximo ataque |
| Salamandra de la Grieta | Común | 24 | 8 | Bajo 7 → Se entierra → Bajo 9 | Su Guardia frena el daño, pero no el daño a Estructura: usá palmas y empujes |
| Monje sin Rostro | Élite | 55 | 15 | Medio 9 → Interrumpir (alto 5) → Bajo 12 | Si no desviás Interrumpir, tus formas en progreso vuelven a 0 |
| Eco del Dragón | Guardián | 90 | 20 | Dos fases | Al 50% de Vida cambia de fase y prepara el Aliento del Dragón (medio 25, E8), con cuenta regresiva. Se evita desviándolo o dejándolo Desequilibrado antes |

En la bifurcación conviene elegir según el mazo: el **Gólem** premia romper Estructura; la **Salamandra**, palmas y empujes.

## Consejos

- Mirá siempre el globo del enemigo antes de jugar: la altura te dice qué defensa sirve.
- Un desvío vale más que un bloqueo: te ahorra daño, le rompe Estructura y te da Aliento.
- Romper la Estructura y rematar con el enemigo Desequilibrado (daño ×2) es la forma más rápida de ganar.
- Contra el Discípulo, cambiá de postura cada turno.
- Guardá **Respirar** para una mano realmente mala.
