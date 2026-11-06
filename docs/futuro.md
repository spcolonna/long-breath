# Futuros cambios y plan de crecimiento

Lo que queda para después del MVP: pendientes concretos, ideas de mecánica y el plan para que el juego completo tenga la profundidad y la duración de un juego pago. Cuando algo se implementa, se saca de acá y se documenta en `manual.md` / `reglas-implementadas.md`.

---

## 1. Pendientes inmediatos

- **Pulido general (29/10/2026):** botones que se hunden al tocar, Vida que cuenta, entradas escalonadas, carta que se quema o se mejora en fuente/mercader/maestro, avisos de papel con sello, mazos de robo y descarte con rebarajado, pausa de impacto en golpes fuertes y respeto de «reducir movimiento» del sistema. Transiciones propias: el combate entra con dos pinceladas de laca y oro en X; la etapa superada se abre como un rollo colgante.
- **Pulido y técnico (29/10/2026):** Opciones (sonido, música, vibración y movimiento: como el sistema, completo o reducido), kit de nodo (fondo de etapa en mercader y maestro, opciones de papel, elegir carta con encabezado propio), cofre, cartas y talismanes que se hunden, nubes en dos capas en el combate (por código), niebla sin blur y sprites sin filtros cuando no hacen falta. La base para todo lo nuevo está en `docs/feel.md`.
  - **Falta:** los archivos de sonido y música (`assets/audio/` está vacío, así que el juego es mudo); medir el rendimiento en un teléfono real.
- **Cartas de Serpiente y Grulla (29/10/2026):** 4 cartas más por camino (10 cada uno). Mecánicas nuevas: **combo** de la Serpiente (si ya jugaste 2 ataques en el turno, roba o da Aliento) y **retenida** de la Grulla que roba o da Aliento. Hecho después: el Tigre también tiene 10, con el **Quiebre** (la carta que desequilibra al enemigo roba o da Aliento).

- **Balance:** hecho el 01/10/2026 (ver `balance.md`).
  - Combates de 2,4 a 4,8 turnos.
  - El jugador promedio gana el 60% de las runs y el experto el 79%.
  - Los tres caminos quedan parejos.

  Segunda vuelta (mismo día): dificultades Fácil/Normal/Difícil/Shifu en la interfaz, retener como cartas extra (Tigre roba 5) y escamas del Dragón. Shifu se desbloquea ganando en Difícil. El Dragón tiene una tercera fase (escamas que vuelven y Aliento cada dos acciones).

  Lo que queda:
  - ~~**Formas más alcanzables:** formas propias de cada camino.~~ Hecho (03/11/2026): 2 cortas y 1 larga por camino, y prioridad del camino al ofrecerlas.
  - **Calibrar el modelo de tiempo** con partidas reales, y confirmar las dificultades con personas.
- **Duración acorde al precio (requisito de la versión final).** Hoy una subida se resuelve en unos 12 minutos y el juego completo (3 etapas, prototipo) en alrededor de una hora. Para la versión que se venda, eso no alcanza: la duración total tiene que estar a la altura de lo que cuesta. Antes de lanzar hay que fijar el precio y, con él, la meta de horas (ver sección 3), y verificarla con el simulador y con personas: horas hasta la primera victoria, horas hasta ganar con los tres caminos y horas de rejugabilidad (dificultades, Picos, cultivo).
- **Arte de la etapa 1:** completo el 02/10/2026 (6 enemigos y 4 fondos de tramo).

## 2. Ideas de mecánica

### Posturas
- **Cartas que piden una postura y te dejan en otra.** Por ejemplo, "desde Caballo, te deja en Arco". Eso arma cadenas (Caballo → Arco → Vacía) y le da todavía más profundidad a las formas. Para el MVP alcanza con la versión actual, donde la carta pega con la postura en la que estás y te deja en la suya. **Hecho (05/11/2026), primera parte:** 6 cartas con cadena (`from` en `cards.json`): 3 generales que cierran el círculo Caballo → Arco → Vacía → Caballo y una por camino. Jugadas desde su postura de salida suman daño, Estructura, Aliento o robo; en la mano se marcan en dorado («Encadena») y al jugarlas sale «¡Cadena!» con vibración doble. Simulación en Normal (600 subidas): experto 57% igual; promedio 24% contra 26%; Grulla sola 50%/25% contra 52%/24%. **Hecho (05/11/2026):** talismán raro Rueda de las Posturas 轮 (+1 Aliento por cadena); simulación en Normal: experto 56%, promedio 28%, neutro. **Hecho (06/11/2026):** círculo cerrado: encadenar desde las tres posturas en un turno da +1 Aliento y roba 2 (una vez por turno); la carta que lo cierra lo anuncia en la mano. Simulación en Normal (600 subidas): experto 56%, promedio 28%, igual (el bot no lo busca a propósito). Siguiente: un despertar que premie encadenar, enseñar al bot a buscar el círculo y arte de las 6 cartas y del talismán.
- **Bonus de "postura preparada":** un extra para las cartas que se juegan estando ya en la postura que indican. Recompensa todavía más el orden de la mano. Antes de sumarlo hay que medirlo en el simulador.
- **Nuevas posturas:** Pūbù 仆步 (barrido bajo), Xiēbù 歇步 (cruzada, giro) y Dúlìbù 独立步 (grulla, sobre una pierna). Cada una con su ventaja y su costo, y con cartas que lleven a ella.

### Combates
- **Dos enemigos a la vez (1 contra 2).** **Hecho (29/10/2026):** los grupos de dos pueden pelear juntos (`floors[].together`, % por piso). Se apunta tocando, se ven las dos intenciones y actúan uno tras otro. Siguientes pasos posibles:
  - élite con escolta (un élite y un común a la vez). **Hecho (29/10/2026):** `escort` y `escorts` en el piso del élite (etapa 2: 40%, etapa 3: 60%); el élite pelea con 80% de Vida, la escolta con 45% y los dos pegan 85%;
  - formas o cartas de área que peguen a los dos;
  - enemigos que se potencian entre sí (uno cubre al otro, uno cura al otro).
- **Golpes con peso.** **Hecho (02/11/2026):** cámara lenta breve al desequilibrar, al completar una forma y en el golpe final. Tres tamaños de número de daño (el fuerte con borde dorado) y «×2» si estaba desequilibrado. Las élites y los jefes se rematan con un trazo de pincel y un sello 破. Siguientes pasos posibles:
  - sonido propio de remate (hoy reusa `break` + `victory_stamp`);
  - zoom de cámara al rival en el remate de un jefe;
  - ~~combo visible~~ **Hecho (02/11/2026):** `ComboCounter` desde el segundo ataque del turno, con nota que sube; falta que las cartas de combo (Serpiente) brillen cuando ya cumplen.

### Caminos y cartas
- **Árbol por camino:** cada animal es una rama con cartas, formas y una mecánica propia:
  - Tigre: romper Estructura.
  - Serpiente: veneno, golpes encadenados y retener.
  - Grulla: desvíos y contraataques.
  - **Hecho (07/10/2026), primera parte: despertares.** Al superar la etapa 1 y la 2 se elige 1 de 3 despertares del camino (4 por camino) que cambian su regla. Siguiente paso posible: un tercer despertar más fuerte en la cumbre, o despertares que pidan un estilo de juego ("si no retuviste nada, …").
- **Leopardo** como cuarto camino (velocidad: cartas de costo 0 y robar). El Dragón queda sellado por la historia.

### Armas (bīngqì 兵器)
- **Hecho (02/11/2026):** bastón 棍, espada 剑 y pudao 朴刀, con 3 niveles, 4 técnicas cada una, efecto propio (Estructura, atravesar Guardia, golpes pesados) y extra de camino. El primer élite la garantiza; se templa en el botín, el mercader (armería) y el maestro (hasta el II). Capa del arma en la mano del héroe, dibujada por código hasta que llegue el arte (`assets/art/weapons/<id>.png`). Balance (`balance.md` §3p): promedio 32% (antes 31%), experto 66% (igual). **Falta:** el arte de las tres; cambiar de arma; más armas (lanza 枪, sable 刀, san jie gun 三节棍); formas de arma; sonidos `weaponSwing`/`weaponForge`.
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
- ~~**Más formas** en lugar de 2: formas de cada camino y formas largas de 5 o 6 pasos con gran recompensa.~~ Hecho (03/11/2026): 14 formas, una larga de 5 pasos por camino.
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
  - Eventos propios de cada etapa: **hecho (07/10/2026)**, 8 nuevos (ver `manual.md`).
  - Dificultades recalibradas para 3 etapas (06/10/2026, `balance.md` §3i). Falta confirmarlas con personas.
  - Precios del mercader por etapa: **hecho (07/10/2026)**, más caro arriba, 4 cartas desde la etapa 2 y talismán raro en la Cumbre. Vitrina (05/11/2026): un raro aparte por 140 / 160 en las etapas 2 y 3, en vez del raro de la Cumbre. Sobran ~52 de jade al final, pero es estructural: se gana después del último mercader (pisos 9 a 11).
  - Duración: **hecho (07/10/2026)**, 11 pisos por etapa; una subida ganada dura unos 44 minutos en el modelo del simulador (un jugador real tarda más). Eventos propios por etapa: **hecho (07/10/2026)**, 2 en la etapa 1 y 3 en las etapas 2 y 3 (16 en total).

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
- **Mercader de pergaminos:** **en el juego** (02/10/2026), con jade de los combates. **Economía (05/10/2026):** carta en oferta (−40%), té de jengibre (+15 Vida por 15), mercader posible desde el piso 2, la élite ya no da jade (llegaba cuando no quedaban tiendas) y eventos que pagan o cobran jade (ermitaño, dados, peregrino). Simulación: el jade sin gastar al final bajó de ~61 a ~27; promedio 58%. ~~Que el jade sobrante sirva entre subidas~~ **hecho (03/11/2026):** se ofrenda a la escuela, 1 semilla de loto cada 5 de jade. ~~Falta: talismanes raros caros en la tienda y precios que suban por etapa.~~ **Hecho:** precios por etapa (07/10/2026) y vitrina con un raro caro (05/11/2026); simulación sin cambios (experto 56% contra 57%, 1000 subidas). Idea original: compra de cartas, mejoras y talismanes con una moneda de la run (por ejemplo, monedas de jade que se ganan en los combates).
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
- **Hecho (30/10/2026):** 8 talismanes que cambian reglas (Paso en T gratis, Guardia al cambiar de postura, primera carta más barata, robar al desequilibrar, desvío que devuelve daño, jade al ganar) y una rareza nueva **de jefe** (laca) que solo da el jefe de etapa: Luna Llena (+1 Aliento por turno, −5 Vida máxima) y Raíz de la Montaña (conservás 30% de la Guardia). Medidos con `--section talismans`: comunes +5 a +12 pp, raros +16/+17, de jefe +12 a +25; el balance general quedó igual (experto 66% contra 65%, promedio 30% contra 31%). ~~Falta: más de jefe con costo~~ **hecho (03/11/2026):** Tambor de Bronce, Perla del Dragón, Hoja Partida y Horno de Cinabrio (+10 a +25 pp, como los anteriores).
- **Hecho (02/11/2026):** un talismán raro por camino (Garra del Tigre: desequilibrar pega 5 doble; Escama de la Serpiente: el tercer ataque roba; Pluma de la Grulla: +3 de Guardia por carta retenida) que solo le sale a ese camino, y 2 que solo vende el mercader, la mitad de las veces (Ábaco: −20% en la tienda; Manga Ancha: +1 carta por mano, −10 Vida máxima). Simulación en Normal sin cambios: experto 67% contra 65%, promedio 28% contra 29%.
- **Hecho (02/11/2026):** eventos de camino. Son 9 pruebas, una por camino y etapa, que salen primero después del santuario. Tienen opciones nuevas: elegir 1 de 3 cartas del camino, elegir qué carta mejorar, el talismán del camino y un duelo contra un rival que deja elegir talismán. Al elegir, la escena se pliega; el duelo hace temblar la pantalla y muestra al rival. Simulación en Normal (600 subidas): experto 67% igual que antes; promedio 33% contra 30%.
- ~~**Siguiente para eventos:** opciones que pidan un talismán o una forma, y eventos en dos partes que vuelvan más arriba.~~ **Hecho (05/11/2026):** 13 opciones con requisito (talismán, arma o forma) que solo aparecen si se cumple, la ganancia «templar el arma» y 3 historias en dos partes (herido, rival, herrero). Siguiente: más cadenas (una por camino), segundas partes que cambien según lo elegido y eventos que pidan Vida baja o mucho jade.
- **Arte:** ícono chico por talismán. Se pueden armar con un set de íconos simples o con caracteres caligrafiados.

### 3.5 Más enemigos
- **Por etapa:** entre 6 y 8 comunes, 2 o 3 élites y 1 jefe, cada uno con una regla que enseñe algo.
- **Variantes con poco arte:** el mismo sprite recoloreado por código, como el héroe, con otro patrón y otra regla. Por ejemplo, "Gólem de Jade" frente a "Gólem de Piedra".
- **Arte:** entre 4 y 6 sprites nuevos por etapa. El resto son variantes.
- **Hecho (05/10/2026):** élites con regla propia en la etapa 1: el piso 8 sale al azar entre Monje sin Rostro, León de Piedra (despierta, se calma al desequilibrarlo) y Dama del Abanico (desvía el primer golpe de cada turno). Común nuevo: Mono Ladrón (roba jade y se escapa en su tercera acción). Promedio en Normal: 59%. El mercader y el maestro tienen retrato. Después: el Bandido del Paso y el Hongo Lingzhi, con arte propio. Hecho (03/11/2026): élites opcionales en los pisos 5 y 7 (40%), como desvío con talismán. Marca en el mapa (05/11/2026): anillo punteado que gira, placa «Desvío» y doble vibración al elegirlo.

- **Familias nuevas (propuesta, 11/10/2026):** ya hay varias variantes de bat, golem, salamander, disciple, monk, lion y dragon. El arte nuevo va a conceptos distintos, no a reemplazar recoloreos que ya funcionan:
  - teatro y arte: Ópera de las Mil Caras 变脸 (cambia de guardia cada turno), títeres de linterna 皮影, músico de guqin que marca el ritmo;
  - bestias míticas: Pixiu 貔貅 (devora jade), qilin, zorro de nueve colas (ilusiones: descartes);
  - objetos encantados: grullas de papel 纸鹤 (en bandada), espada voladora, buey de madera de los mohistas (autómata);
  - **hecho (11/10/2026):** Grulla de Papel (etapa 1, pisos 2, 5 y 7), Ópera de las Mil Caras (etapa 2) y Pixiu (etapas 2 y 3). El balance de Normal no se movió (experto 58%, promedio 27%).
  - **hecho (12/10/2026):** Espada Voladora y Buey de Madera (comunes de la etapa 3) y Qilin (élite de la etapa 3, datos listos; falta `qilin.png`). Desequilibrar ahora tira las guardias que frenan un solo tipo de golpe.
- **Pedidos (12/10/2026), hechos:** Zorro de Nueve Colas (élite, etapa 2, ilusiones), Títere de Sombras (común, etapa 2) y Músico del Guqin (común, etapa 3), todos con arte propio, igual que el Qilin. No queda ningún enemigo pedido.
- **Reserva en uso (12/10/2026):** `monk_amber` → Monje del Incienso (común, etapa 2), `monk_slate` → Ermitaño de Pizarra (común, etapa 3), `lion_celadon` → León de Celadón (élite, etapa 2). Balance de Normal sin cambios (1000 runs: promedio 30%, experto 55%).
- **Recoloreos que quedan** (`golem_ice`, `monkey_snow`, `disciple_wind`, `bat_frost`): no hace falta reemplazarlos.

### 3.6 Dificultad creciente: los Picos
- Después de ganar se habilita el **Pico 1**, y así hasta el 10. Cada pico suma un modificador acumulativo. Por ejemplo:
  - Enemigos con +10% de Vida.
  - La fuente cura menos.
  - Las élites tienen una regla extra.
- Es lo que da cientos de horas de rejugabilidad.
- **Hecho (etapa 1):** 10 Picos encima de Normal, en `game_balance.json`. El bot experto baja de 80% a 17% (`balance.md`, sección 6). Medidos con 3 etapas (`balance.md` §3i): del 80% al 3% para el experto. **Hecho (reglas):** además de los números, cuatro Picos cambian cómo se juega: mercader más caro (2), rivales que arrancan con Guardia (3), élites con Espinas (6) y un Respiro menos (9).
- **Arte:** ninguno.

### 3.7 Progresión entre partidas: el cultivo del aliento
- **Hecho (07/10/2026):** 6 reinos 境界 con aliento por subida (gane o pierda, caer no resta). Abren la Grulla, 6 cartas de camino y 4 formas; el aura del héroe crece en el inicio, la pantalla final muestra el aliento y el reino nuevo, y el registro tiene la pestaña Cultivo. Solo variedad: cerrar raros y cartas generales bajaba el promedio a 44% (ver `balance.md` §3m). El último reino llega en ~12 subidas.
- **Hecho (09/10/2026):** semillas de loto 莲 (se ganan en cada subida y no se pierden) y árbol de meridianos 经络 de 15 puntos en 3 canales; cada reino regala un don. Botín sorpresa al ganar (pergaminos, jade, loto, temple, té o talismán) con cofre que se abre. Ver `balance.md` §3o.
- **Siguiente:**
  - Reiniciar el árbol (devolver el loto) para probar otras ramas.
  - En Difícil o más, mostrar en el mapa qué botín trae cada combate (como las puertas de Hades) para elegir el camino.
  - Más puntos: una cuarta rama por camino animal (Tigre, Serpiente, Grulla) que se abre al ganar con ese camino.
  - Desbloqueos que no sean de combate (fondos del inicio, títulos del discípulo, ropa del héroe) pagados con loto.
  - Arte opcional: ícono pintado de la semilla de loto y del cofre del botín (hoy son sellos con carácter).

### 3.8 Historia y legado
- **Hecho (base):** cada subida la hace un discípulo con número; al caer se narra qué pasó y "la escuela envía a otro novicio"; registro de la escuela 名册 con tablillas y 9 pergaminos de lore que se abren por hitos (prólogo, santuario, caer ante cada rival, cumbre, 5 y 10 caídos). Sin efecto mecánico.
- **Pendiente:**
  - ~~Que el Discípulo Perdido lleve algo de un discípulo caído del registro~~ **hecho (30/10/2026):** lleva el número del último caído, se presenta diciendo quién fue, su camino y dónde cayó, y al vencerlo suelta la carta que ese discípulo dejó en el registro (la de su camino más mejorada). Si te vence, el registro dice «Cayó ante el Discípulo Perdido nº N». ~~Siguiente: que pelee con cartas de su camino~~ **hecho (03/11/2026):** si el caído tenía camino, el Discípulo Perdido pelea con los golpes de ese camino (Tigre: Despierta; Serpiente: Regeneración e Interrumpir; Grulla: Abanico y guardias) y cierra su ciclo con la forma larga del camino, con cuenta regresiva.
  - ~~Pergaminos de las etapas 2 y 3, y del giro del maestro~~ **hecho (12/10/2026):** 18 pergaminos (vigas, huellas, Guardián de la Campana, Dama del Viento, epílogo con el giro), diálogos de jefes y élites, maestro errante con líneas por etapa y 4 eventos con historia.
  - Ilustración del epílogo (hoy es un pergamino).
- **Escenas:**
  - Prólogo en el templo del Dragón Dormido 卧龙门 (hoy es un pergamino; falta la ilustración).
  - ~~Giro del maestro~~ y ~~finales distintos según el camino~~ **hecho (02/11/2026)** como pergaminos (con sello del camino y retrato del maestro). Falta: escenas ilustradas.
- ~~**Legado:** lo que un discípulo deja para el siguiente~~ **hecho (03/11/2026):** al empezar cada subida (desde la segunda) el nuevo elige una herencia del discípulo anterior, gane o pierda: su carta guardada con la mitad de las mejoras, o +3 de Vida máxima si pasó de la primera etapa (si no, +15 de jade). Va antes del talismán de los meridianos.
- **Arte:** pocas ilustraciones fijas, con texto encima.

### 3.8b Presentaciones y escenarios (hecho)
- Escenarios a pantalla completa en combate, con movimiento lento; menos velo en el mapa y las pantallas tranquilas.
- Presentación de etapa (paneo por la montaña) y de jefe/élite (silueta → color, sello y héroe). Completa la primera vez, corta después, se saltan con un toque.
- Los jefes de las etapas 2 y 3 tienen fondo propio (Gran Campanario y Lecho del Dragón, 10/10/2026).
- **Siguiente:**
  - ~~un ajuste "Reducir movimiento" en Opciones~~ (hecho, 29/10/2026);
  - ~~un epílogo corto al vencer al Dragón Dormido~~ (hecho como pergamino; falta escena ilustrada);
  - ~~capas de nubes para parallax en el combate~~ (hecho por código, 29/10/2026).

### 3.8c Partidas (hecho, 12/10/2026)
- Tres partidas con dificultad fija; borrar o empezar de cero con confirmación. La partida 1 usa las claves de antes.
- **Siguiente:** nombre propio para cada partida; exportar/importar una partida; mostrar en la tarjeta el reino del cultivo.

### 3.9 Modos extra
- **Desafío diario:** la misma semilla para todos y una tabla de resultados.
- **Combate libre contra cualquier enemigo ya vencido**, para practicar.

---

## 4. Orden sugerido

**Prioridad acordada (02/11/2026):** 1) contenido de juego (armas, formas por camino, Discípulo Perdido con cartas, enemigos pedidos (hecho), élites opcionales (hecho)); 2) economía y progresión (jade entre subidas (hecho), talismanes de jefe con costo (hecho), legado (hecho)); 3) pulido chico; 4) escenas ilustradas, desafío diario y combate libre. La duración total y el precio se deciden después de que lo prueben amigos.

**Hoja de ruta (07/10/2026), por prioridad:**
1. Cultivo del aliento: **hecho**.
2. Hitos 功 (logros): **hecho (29/10/2026)**, 18 hitos por partida con aliento extra (ver `manual.md`). Hitos por enemigo (élites de cada reino, jefe sin perder Vida), por despertares y por talismanes: **hecho (02/11/2026)**, 27 en total, con barra de avance en el Registro.
3. ~~Menú principal vivo~~ **hecho (30/10/2026):** en la escuela de cada partida, nubes que pasan, motas de aliento y aura que crecen con el cultivo, tablilla del último caído y el próximo hito con su avance.
4. Narrativa:
   - pergaminos de las etapas 2 y 3;
   - ~~el Discípulo Perdido con el nombre de un caído~~ (hecho);
   - ~~el giro del maestro~~ (hecho);
   - ~~finales por camino~~ (hecho, 02/11/2026).
5. ~~Armas 兵器~~ (hecho, 02/11/2026; falta el arte).
6. ~~Pasada de feel en mercader, evento, recompensa y maestro~~ (hecho, 29/10/2026; ver `feel.md`).
7. Optimización: peso de los PNG y rendimiento medido.


| Fase | Contenido | Resultado |
| --- | --- | --- |
| A · Núcleo sólido | Balance, arte faltante, nombres de montaña | Una subida corta que se siente bien |
| B · Una subida larga | 3 etapas, mapa generado, eventos, talismanes, mercader | Una subida de 45 a 75 minutos |
| C · Rejugabilidad | Picos, cultivo del aliento, desbloqueos | Muchas horas de juego |
| D · Mundo | Árboles de camino, cartas de Serpiente y Grulla, formas nuevas, historia y legado | La experiencia completa |

**Modelo pago:** la versión gratis o demo incluye el tutorial y la etapa 1. La compra desbloquea las otras etapas, los Picos y el cultivo. La fase B es lo mínimo para que la compra valga la pena.
