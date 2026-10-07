# Futuros cambios y plan de crecimiento

Lo que queda para después del MVP: pendientes concretos, ideas de mecánica y el plan para que el juego completo tenga la profundidad y la duración de un juego pago. Cuando algo se implementa, se saca de acá y se documenta en `manual.md` / `reglas-implementadas.md`.

---

## 1. Pendientes inmediatos

- **Balance:** hecho el 01/10/2026 (ver `balance.md`).
  - Combates de 2,4 a 4,8 turnos.
  - El jugador promedio gana el 60% de las runs y el experto el 79%.
  - Los tres caminos quedan parejos.

  Segunda vuelta (mismo día): dificultades Fácil/Normal/Difícil/Shifu en la interfaz, retener como cartas extra (Tigre roba 5) y escamas del Dragón. Shifu se desbloquea ganando en Difícil. El Dragón tiene una tercera fase (escamas que vuelven y Aliento cada dos acciones).

  Lo que queda:
  - **Formas más alcanzables:** formas propias de cada camino.
  - **Calibrar el modelo de tiempo** con partidas reales, y confirmar las dificultades con personas.
- **Duración acorde al precio (requisito de la versión final).** Hoy una subida se resuelve en unos 12 minutos y el juego completo (3 etapas, prototipo) en alrededor de una hora. Para la versión que se venda, eso no alcanza: la duración total tiene que estar a la altura de lo que cuesta. Antes de lanzar hay que fijar el precio y, con él, la meta de horas (ver sección 3), y verificarla con el simulador y con personas: horas hasta la primera victoria, horas hasta ganar con los tres caminos y horas de rejugabilidad (dificultades, Picos, cultivo).
- **Arte de la etapa 1:** completo el 02/10/2026 (6 enemigos y 4 fondos de tramo).

## 2. Ideas de mecánica

### Posturas
- **Cartas que piden una postura y te dejan en otra.** Por ejemplo, "desde Caballo, te deja en Arco". Eso arma cadenas (Caballo → Arco → Vacía) y le da todavía más profundidad a las formas. Para el MVP alcanza con la versión actual, donde la carta pega con la postura en la que estás y te deja en la suya.
- **Bonus de "postura preparada":** un extra para las cartas que se juegan estando ya en la postura que indican. Recompensa todavía más el orden de la mano. Antes de sumarlo hay que medirlo en el simulador.
- **Nuevas posturas:** Pūbù 仆步 (barrido bajo), Xiēbù 歇步 (cruzada, giro) y Dúlìbù 独立步 (grulla, sobre una pierna). Cada una con su ventaja y su costo, y con cartas que lleven a ella.

### Caminos y cartas
- **Cartas propias de la Serpiente y la Grulla.** Hoy solo el Tigre tiene cartas.
- **Árbol por camino:** cada animal es una rama con cartas, formas y una mecánica propia:
  - Tigre: romper Estructura.
  - Serpiente: veneno, golpes encadenados y retener.
  - Grulla: desvíos y contraataques.
- **Leopardo** como cuarto camino (velocidad: cartas de costo 0 y robar). El Dragón queda sellado por la historia.

### Armas (bīngqì 兵器)
- **Mejoras que son armas:** palo/bastón (gùn 棍), espada (jiàn 剑), pudao (朴刀) y otras, cada una con **nivel 1, 2 y 3**. Se consiguen y suben en la subida (recompensa, mercader o maestro errante).
- **Qué cambian:** cada arma le da identidad al mazo. Por ejemplo:
  - Bastón: alcance y Estructura (barridos bajos, golpes que desequilibran).
  - Espada: precisión (más daño contra Guardia, desvíos que cortan).
  - Pudao: golpes pesados y lentos (mucho daño, cuestan más Aliento).

  Pueden ser un talismán especial (uno solo equipado), o sumar cartas propias del arma al pool de recompensas. El nivel sube los números o desbloquea una carta más.
- **Combina con los caminos:** por ejemplo, la Serpiente con espada o el Tigre con pudao, con bonus si el arma y el camino se llevan bien.
- **Arte (sí pide assets nuevos):** el héroe tiene que verse con el arma.
  - Para no multiplicar sprites (camino × arma × nivel), el arma va en una **capa aparte**, anclada a la mano del héroe, que se mueve con las mismas animaciones de código del sprite.
  - Eso es 1 imagen por arma, más un anclaje por camino.
  - El nivel se muestra por código (brillo, borla o cinta de color, aura), sin arte extra. Si alguna pose no encaja con la capa, recién ahí se dibuja el sprite completo.

### Formas
- **Más formas** en lugar de 2: formas de cada camino y formas largas de 5 o 6 pasos con gran recompensa.
- **Formas con cadena de postura:** cada paso tiene que jugarse en una postura determinada.
- **Aprender formas en la subida:** las da un maestro errante, en un nodo del mapa.

### Formas de la escuela (programa de examen)
Fuente: programa de examen 2025 de la escuela (Shifu Matías Correa). Son las formas que se quieren llevar al juego.

Las formas del juego son secuencias cortas de 3 a 5 cartas. Cada forma real se adapta como una secuencia inspirada en ella, con su nombre real, el hanzi y la traducción primero.

Nombre en español primero, después chino y pinyin, y entre paréntesis cómo figura en el programa. "Por confirmar" marca la escritura china que se dedujo porque el programa no la trae.

**Mano vacía**

| Faja | Español | 中文 · pinyin | Programa | Estado |
| --- | --- | --- | --- | --- |
| Amarillo 1º | Combinación 1 | 组合一 · Zǔhé yī | Shu ho yi | |
| Amarillo 1º | Combinación 2 | 组合二 · Zǔhé èr | Shu ho er | |
| Amarillo 1º | Puño de los cinco pasos | 五步拳 · Wǔbù quán | Wu bu chuen | En el juego |
| Amarillo 2º | Puño de las seis armonías | 六合拳 · Liùhé quán | Liu hou chuen | Por confirmar |
| Amarillo 2º | Puño encadenado | 连环拳 · Liánhuán quán | Lian huan quan | En el juego |
| Amarillo 2º | Puño que atraviesa la espalda | 通背拳 · Tōngbèi quán | Tong bei quan | |
| Verde 1º | Las 18 manos del Luohan | 罗汉十八手 · Luóhàn shíbā shǒu | Luohan shiba shou | |
| Verde 1º | Pequeño Puño Hong | 小洪拳 · Xiǎo hóng quán | Xiao hong chuen | En el juego |
| Verde 2º | Gran Puño Hong, segunda ruta | 大洪拳二路 · Dà hóng quán èr lù | Er lu da hong chuen | |
| Verde 2º | Puño del Tigre | 虎拳 · Hǔ quán | Tigre | En el juego |
| Azul 1º | Puño de las siete estrellas | 七星拳 · Qīxīng quán | Puño de 7 estrellas | |
| Azul 1º y Rojo 1º | Las 12 rutas de patadas de la puerta | 十二路门户腿 · Shí'èr lù ménhù tuǐ | Ma ho tuei (12 ejercicios; completo en Rojo 1º) | En el juego |
| Azul 2º | (pendiente) | — | Er tang jia | Prevista. Se identifica con un video |
| Azul 2º | Puño de la Serpiente | 蛇拳 · Shé quán | Serpiente | En el juego |
| Rojo 2º | Gran Puño Hong | 大洪拳 · Dà hóng quán | Da hong chuen | En el juego |
| Rojo 2º | Puño de suelo | 地趟拳 · Dìtáng quán | Di tang chuen | |
| Rojo 2º | Puño del Mono | 猴拳 · Hóu quán | Mono | |
| Negro | Puño del Borracho | 醉拳 · Zuì quán | Borracho | |

Descartada por ahora: Candado de piedra (Verde 1º).

洪 (Hong) significa "vasto"; "rojo" se escribe 红. La forma del juego que hoy se llama "Pequeño Puño Rojo" es esta. Queda por decidir si se mantiene la traducción popular o se pasa a "Pequeño Puño Hong".

**Armas**

| Faja | Español | 中文 · pinyin | Programa | Estado |
| --- | --- | --- | --- | --- |
| Amarillo 1º y 2º | Palo de Damo | 达摩棍 · Dámó gùn | Rutina de Damo palo | |
| Amarillo 2º y Verde 1º | Sable hoja de sauce | 柳叶刀 · Liǔyè dāo | Sable hoja de sauce | |
| Amarillo 2º y Verde 1º | Espada que somete al tigre | 伏虎剑 · Fúhǔ jiàn | Espada jian fa | |
| Amarillo 2º | Palo, primera ruta | 一路棍 · Yī lù gùn | Yi lu gun | |
| Verde 1º | Palo, segunda ruta | 二路棍 · Èr lù gùn | Er lu gun | |
| Verde 1º | Lanza de Damo | 达摩枪 · Dámó qiāng | Lanza Da Mo | |
| Verde 1º | Palo de tres secciones | 三节棍 · Sānjié gùn | San chen gun | |
| Verde 2º | Palo de fuego (también "palo loco") | 烧火棍 · Shāohuǒ gùn | Palo loco | Por confirmar. "Palo de fuego" apunta al 烧火棍 de Shaolin; "palo loco" apunta a 疯魔棍 Fēngmó gùn, que podría ser otro nombre de la misma forma |
| Azul 1º | Espada de Damo (1.ª y 2.ª, la 2.ª en Negro) | 达摩剑 · Dámó jiàn | Espada de Damo (一) / (二) | |
| Azul 1º | Sable de mango largo de Damo | 朴刀 · Pǔdāo | Bu dao Da Mo | |
| Azul 2º | Palo de la mano yin | 阴手棍 · Yīnshǒu gùn | Palo de Da Mo | |
| Azul 2º | Sable de Damo | 达摩刀 · Dámó dāo | Sable Da Mo | |
| Azul 2º | Cadena de Damo (látigo de nueve secciones) | 九节鞭 · Jiǔjié biān | Cadena de Da Mo / jiu yi pien | |
| Rojo 1º | Palo de la flor de ciruelo | 梅花棍 · Méihuā gùn | Palo de Mei Hua | |
| Rojo 1º | Látigo de Damo | 达摩鞭 · Dámó biān | Látigo de Da Mo | Por confirmar si es la misma arma que la cadena |
| Rojo 2º | Gran sable de Primavera y Otoño | 春秋大刀 · Chūnqiū dàdāo | Da dao de Da Mo | |
| Negro | Bastón de Damo | 达摩杖 · Dámó zhàng | Bastón de Da Mo Chang | Por confirmar ("Chang" podría ser 杖 o 长) |

**Lista de espera.** Estas formas no se usan en el juego hasta confirmar su nombre con la escuela:
- **Liu hou chuen:** ¿es 六合拳 Liùhé quán (seis armonías)?
- **Látigo y cadena de Da Mo:** ¿son la misma arma (九节鞭)?
- **Bastón de Da Mo Chang:** ¿qué carácter es "Chang" (杖 o 长)?
- **Er tang jia:** sin identificar; se ubica con un video.
- **Palo loco / palo de fuego:** ¿es 烧火棍 o 疯魔棍?

- **Caminos:** Tigre y Serpiente ya son caminos. **Mono** y **Borracho** son candidatos a caminos nuevos.
- **Armas:** el programa da casi uno a uno la lista de la idea de armas por nivel (palo, espada, sable, lanza, san chen gun, bu dao, da dao, cadena, látigo, bastón).
- **Posturas del programa que el juego no tiene:**
  - Chu bu.
  - Ha tan bu.
  - Ten jan bu.
  - Tim bu.
  - Palma bu.

  Se suman a Pu bu y Duli bu (ver "Nuevas posturas").
- **Fajas como progresión:** blanco (metal), amarillo (tierra), verde (madera), azul (agua), rojo (fuego) y negro. Pueden ser los reinos del cultivo (3.7): cada faja desbloquea sus formas y armas.
- **Chi kung por faja:** respiración del gran círculo, del letrado y del guerrero, abrazo del árbol, 8 brocados, 5 animales y Luohan 13. Pueden dar técnicas o talismanes de Aliento.

---

## 3. Plan de crecimiento: profundidad y duración

**Objetivo:** que la experiencia completa justifique pagar. **La duración tiene que ser acorde al costo:** que el juego no se resuelva en una hora. Esta meta se revisa cuando se fije el precio.
- **Hoy:** una subida son 7 nodos y unos 15 minutos.
- **Meta:**
  - Una subida completa de **45 a 75 minutos**.
  - **15 a 25 horas** hasta ver todo y ganar con los tres caminos.
  - Rejugabilidad abierta después, con dificultades crecientes.

Restricción que guía todo: **pocos assets**. Cada punto indica cuánto arte nuevo pide.

### 3.1 La montaña en tres etapas
- **Etapas:** la subida pasa de una etapa a tres, cada una con su jefe.
  1. **Montaña de las Mil Nubes** 千云山, la de hoy.
  2. Una segunda etapa a media altura, por ejemplo un monasterio colgado o un bosque de pinos sobre las nubes.
  3. La cumbre, con el guardián final.

  Los nombres finales tienen que ser épicos y no tener nada de cueva.
- **Nodos:** cada etapa tiene entre 12 y 15 nodos, con bifurcaciones reales (2 o 3 caminos por piso, no uno solo).
- **Prototipo simulado** (`balance.md`, sección 5): con 3 etapas de 13 pisos, una subida ganada dura unos 55 minutos. Lo que mata es el desgaste: hacen falta fuentes frecuentes y curar al vencer al jefe. Las etapas 2 y 3 necesitan **enemigos con reglas nuevas**, no números más grandes.
- **Arte:** 1 fondo por etapa, o sea 2 fondos nuevos.
- **Hecho (06/10/2026):** 3 etapas de 9 pisos: Montaña de las Mil Nubes 千云山, **Monasterio Colgado** 悬空寺 y **Cumbre del Dragón Dormido** 卧龙顶. Arriba de cada etapa: élite → fuente → jefe. El jefe intermedio da talismán, recompensa y 25 de jade, y una pantalla de "etapa superada" cura toda la Vida antes de subir. 14 enemigos nuevos (variantes recoloreadas con `tool/recolor_enemies.py`) con 5 reglas nuevas: espinas, regeneración, repique (−Aliento), escarcha (−cartas) y guardia de un solo tipo de golpe. Fondos de combate: los de la etapa 1 teñidos; el mapa cambia de colores y el jefe del monasterio tiene su campana. Promedio en Normal: 59%, unos 39 minutos por subida ganada (`balance.md` §3h).
- **Falta:**
  - Arte propio: 2 fondos de combate por etapa, los sprites definitivos de los 14 enemigos (prompts en `docs/arte/prompts.md`) y los jefes con silueta propia (hoy el abad es el monje dorado y el Dragón Dormido, el eco recoloreado).
  - Eventos propios de cada etapa (hoy se comparten los 8).
  - Dificultades recalibradas para 3 etapas (06/10/2026, `balance.md` §3i). Falta confirmarlas con personas.
  - Precios del mercader por etapa (sobran ~43 de jade al final).
  - Duración: **hecho (07/10/2026)**, 11 pisos por etapa; una subida ganada dura unos 44 minutos en el modelo del simulador (un jugador real tarda más). Próximo paso para llegar al centro de la meta: más eventos propios de cada etapa.

### 3.2 Mapa generado
- **En el juego** (02/10/2026) para la etapa 1: 9 pisos con pesos por tipo, mercader y maestro garantizados. Falta: más pisos por etapa cuando haya 3 etapas, élites opcionales en pisos intermedios.
- El mapa deja de ser fijo: se arma con la semilla de la run, con reglas por piso. Por ejemplo:
  - Élite no antes del piso 4.
  - Fuente antes del jefe.
  - Al menos un santuario.
- Ninguna subida es igual a otra.
- **Arte:** ninguno.

### 3.3 Nuevos tipos de nodo
- **Evento:** **en el juego** (02/10/2026): 6 eventos y 2 nodos en la etapa 1. Para crecer: más eventos por etapa, eventos que dependan del camino o de un talismán, y eventos con más de dos opciones.
- **Mercader de pergaminos:** **en el juego** (02/10/2026), con jade de los combates. **Economía (05/10/2026):** carta en oferta (−40%), té de jengibre (+15 Vida por 15), mercader posible desde el piso 2, la élite ya no da jade (llegaba cuando no quedaban tiendas) y eventos que pagan o cobran jade (ermitaño, dados, peregrino). Simulación: el jade sin gastar al final bajó de ~61 a ~27; promedio 58%. Falta: que el jade sobrante sirva entre subidas (cultivo §3.7), talismanes raros caros en la tienda y precios que suban por etapa. Idea original: compra de cartas, mejoras y talismanes con una moneda de la run (por ejemplo, monedas de jade que se ganan en los combates).
- **Maestro errante:** **en el juego** (02/10/2026): enseña una forma o mejora una carta.
- **Arte:** 1 ícono por tipo de nodo. Los eventos se resuelven con texto y alguna ilustración reutilizada.

### 3.4 Talismanes (objetos pasivos)
- Objetos que duran toda la subida y cambian las reglas. Por ejemplo:
  - "Empezás cada combate en Arco."
  - "El primer desvío de cada combate da +2 de Aliento."
  - "Las formas completas curan 3."
- Son la fuente principal de combinaciones y de rejugabilidad en los roguelikes de cartas.
- **Prototipo:** hay 10 talismanes medidos en `balance.md` (sección 5). Cada uno suma entre +1 y +14 puntos de victoria, y todos juntos unos +20.
- Se obtienen en las élites, los jefes, los eventos y el mercader.
- **En el juego** (02/10/2026): los 10 del prototipo, del élite (1 de 3) y de los eventos. Falta: talismanes de jefe, del mercader y talismanes que cambien reglas (no solo números).
- **Arte:** ícono chico por talismán. Se pueden armar con un set de íconos simples o con caracteres caligrafiados.

### 3.5 Más enemigos
- **Por etapa:** entre 6 y 8 comunes, 2 o 3 élites y 1 jefe, cada uno con una regla que enseñe algo.
- **Variantes con poco arte:** el mismo sprite recoloreado por código, como el héroe, con otro patrón y otra regla. Por ejemplo, "Gólem de Jade" frente a "Gólem de Piedra".
- **Arte:** entre 4 y 6 sprites nuevos por etapa. El resto son variantes.
- **Hecho (05/10/2026):** élites con regla propia en la etapa 1: el piso 8 sale al azar entre Monje sin Rostro, León de Piedra (despierta, se calma al desequilibrarlo) y Dama del Abanico (desvía el primer golpe de cada turno). Común nuevo: Mono Ladrón (roba jade y se escapa en su tercera acción). Promedio en Normal: 59%. El mercader y el maestro tienen retrato. Falta: el Bandido del Paso y el Hongo Lingzhi (arte pendiente), y élites opcionales en pisos intermedios.

### 3.6 Dificultad creciente: los Picos
- Después de ganar se habilita el **Pico 1**, y así hasta el 10. Cada pico suma un modificador acumulativo. Por ejemplo:
  - Enemigos con +10% de Vida.
  - La fuente cura menos.
  - Las élites tienen una regla extra.
- Es lo que da cientos de horas de rejugabilidad.
- **Hecho (etapa 1):** 10 Picos encima de Normal, en `game_balance.json`. El bot experto baja de 80% a 17% (`balance.md`, sección 6). Medidos con 3 etapas (`balance.md` §3i): del 80% al 3% para el experto. Falta: élites con una regla extra como Pico.
- **Arte:** ninguno.

### 3.7 Progresión entre partidas: el cultivo del aliento
- **Reinos de cultivo** 境界: cada subida, gane o pierda, suma aliento.
- **Cada reino desbloquea:**
  - Cartas nuevas en el mazo de recompensas.
  - Talismanes.
  - El tercer camino.
  - Formas.
- Morir hace perder parte del aliento acumulado, pero nunca se baja de reino.
- **Visual:** solo crece el aura del héroe, dibujada por código.
- **Arte:** ninguno.

### 3.8 Historia y legado
- **Hecho (base):** cada subida la hace un discípulo con número; al caer se narra qué pasó y "la escuela envía a otro novicio"; registro de la escuela 名册 con tablillas y 9 pergaminos de lore que se abren por hitos (prólogo, santuario, caer ante cada rival, cumbre, 5 y 10 caídos). Sin efecto mecánico.
- **Pendiente:**
  - Que el Discípulo Perdido lleve algo de un discípulo caído del registro (nombre/número, su camino).
  - Pergaminos de las etapas 2 y 3, y del giro del maestro (la cumbre ya siembra la duda: tu nombre ya estaba tallado).
- **Escenas:**
  - Prólogo en el templo del Dragón Dormido 卧龙门 (hoy es un pergamino; falta la ilustración).
  - Giro del maestro.
  - Finales distintos según el camino.
- **Legado:** lo que un discípulo deja para el siguiente, por ejemplo una carta heredada.
- **Arte:** pocas ilustraciones fijas, con texto encima.

### 3.9 Modos extra
- **Desafío diario:** la misma semilla para todos y una tabla de resultados.
- **Combate libre contra cualquier enemigo ya vencido**, para practicar.

---

## 4. Orden sugerido

| Fase | Contenido | Resultado |
| --- | --- | --- |
| A · Núcleo sólido | Balance, arte faltante, nombres de montaña | Una subida corta que se siente bien |
| B · Una subida larga | 3 etapas, mapa generado, eventos, talismanes, mercader | Una subida de 45 a 75 minutos |
| C · Rejugabilidad | Picos, cultivo del aliento, desbloqueos | Muchas horas de juego |
| D · Mundo | Árboles de camino, cartas de Serpiente y Grulla, formas nuevas, historia y legado | La experiencia completa |

**Modelo pago:** la versión gratis o demo incluye el tutorial y la etapa 1. La compra desbloquea las otras etapas, los Picos y el cultivo. La fase B es lo mínimo para que la compra valga la pena.
