# Balance de Long Breath

Este documento reúne los objetivos de balance, el método de medición, los valores actuales y el modelo para el juego completo. Los números salen del simulador (`tool/simulate.dart`). Última pasada: 01/10/2026 (segunda vuelta: retener, Dragón y dificultades).

> **Ojo con lo que mide el simulador.** Son bots, no personas. Sirve para comparar versiones del juego entre sí, no para predecir con exactitud cómo le va a una persona. Antes de dar un número por bueno hay que jugarlo.

---

## 1. Cómo se mide

### Tres perfiles de jugador (`lib/domain/sim/bots.dart`)

| Perfil | A quién representa | Cómo juega |
|---|---|---|
| **Novato** | Alguien que hizo el tutorial y es su primera subida | Pega con lo que más daño hace. Se defiende de golpes de 6 o más y acierta la altura 3 de cada 4 veces. No planifica posturas ni formas, no usa Paso en T ni Respirar. Elige las recompensas al azar |
| **Promedio** | Alguien que ya entendió el juego | Piensa el turno con poca profundidad. Uno de cada cuatro turnos juega "en piloto automático", pegando lo que más daño hace. Elige recompensas con criterio y algo de azar. Va a la fuente si le falta Vida y esquiva la élite si está golpeado |
| **Experto** | Un buen jugador | Busca la mejor secuencia del turno, con desvíos, Desequilibrio y formas. Usa Respirar y elige con criterio. Es un piso: una persona experta puede jugar mejor que el bot (por ejemplo, retener cartas con intención) |

Como referencia quedan los bots `aleatorio` y `codicioso`.

### Tiempo estimado
Se calcula con un modelo simple:
- 5 s por carta jugada.
- 6 s por turno, incluida la animación del rival.
- 10 s por combate (entrada y cierre).
- 15 s por pantalla de mapa, recompensa o fuente, y 30 s el santuario.

Hay que calibrarlo cronometrando partidas reales. Una persona que recién empieza probablemente tarda bastante más que esto.

### Comandos
```bash
dart run tool/simulate.dart                           # runs de la etapa 1, 3 perfiles
```
```bash
dart run tool/simulate.dart --section cards           # poder de cada carta
```
```bash
dart run tool/simulate.dart --section difficulty      # victoria por dificultad y perfil
```
```bash
dart run tool/simulate.dart --difficulty hard         # informe completo en una dificultad
```
```bash
dart run tool/simulate.dart --stages 3 --talismans    # prototipo de 3 etapas
```
```bash
dart run tool/simulate.dart --stages 3 --section picos
```
```bash
dart run tool/simulate.dart --stages 3 --section talismans
```

**Palancas para explorar sin tocar los JSON:**
- `--hp common=1.2,boss=1.1` y `--dmg 1.1`: multiplicadores por rango.
- `--str ...`: Estructura enemiga.
- `--set "archivo.json:id.campo=valor;..."`: cambiar cualquier valor puntual.
- `--data carpeta`: correr con otro set de datos.
- `--sloppy 0.4`: hacer más torpe al perfil promedio.
- `--curve`, `--fountains` y `--boss-heal`: parámetros del prototipo.

**Uso:** antes de cambiar un número, se corre con palancas. Cuando cumple los objetivos, se pasa al JSON.

---

## 2. Objetivos

| Qué | Objetivo | Por qué |
|---|---|---|
| Combate común (promedio) | 3–5 turnos, 4–12 de Vida perdida | Que haya tiempo para leer al rival, cambiar de postura y buscar el Desequilibrio |
| Élite (promedio) | 5–7 turnos | Una pelea que se recuerde |
| Jefe (promedio) | 6–8 turnos | El clímax de la etapa |
| Victoria de la run, etapa 1 | Promedio 45–60%; experto 75–90% | Difícil pero justo; la habilidad tiene que notarse |
| Caminos | No más de 8 puntos entre el mejor y el peor (promedio) | Ningún camino obligatorio ni descartable |
| Cartas de recompensa | Tomar cualquiera suma entre −3 y +10 puntos de victoria | Que elegir importe y que ninguna sea trampa |
| Talismanes | Cada uno suma entre +3 y +10 puntos | Igual que las cartas, a otra escala |
| Duración de la subida | Etapa 1: 10–15 min. Juego completo (3 etapas): 45–70 min | Ver `futuro.md` |

---

## 3. Etapa 1: antes y después

**Antes:** valores del documento de diseño. **Después:** esta pasada. Son 1000 runs por perfil, con los caminos repartidos en partes iguales.

### Runs completas

| Perfil | Victoria antes | Victoria después | Minutos antes | Minutos después | Formas por run (antes → después) |
|---|---|---|---|---|---|
| Novato | 50% | **1%** | 8,6 | 9,3 | 0 → 0 |
| Promedio | 91% | **60%** | 8,1 | 11,1 | 0,1 → 0,3 |
| Experto | 95% | **79%** | 7,9 | 10,8 | 0,1 → 0,5 |

### Victoria por camino

| Perfil | Tigre (antes → después) | Serpiente | Grulla |
|---|---|---|---|
| Novato | 96% → 2% | 41% → 1% | 10% → 0% |
| Promedio | 100% → **61%** | 89% → **59%** | 82% → **60%** |
| Experto | 100% → **78%** | 96% → **79%** | 87% → **79%** |

Antes el Tigre era obligatorio: sacaba 18 puntos de ventaja y con el novato, 86. Ahora los tres caminos quedan a 2 puntos o menos.

### Combates del perfil promedio (dentro de las runs, con su mazo y su Vida)

| Enemigo | Turnos antes | Turnos después | Vida perdida antes | Vida perdida después | Victoria después |
|---|---|---|---|---|---|
| Murciélago de Jade | 1,3 | 2,4 | 0,2 | 3,0 | 100% |
| Salamandra | 1,6 | 3,2 | 1,7 | 4,5 | 100% |
| Discípulo Perdido | 2,0 | 3,5 | 3,7 | 10,8 | 100% |
| Gólem | 3,0 | 4,1 | 6,1 | 11,7 | 98% |
| Monje sin Rostro (élite) | 3,0 | 4,8 | 7,7 | 12,9 | 100% |
| Eco del Dragón (jefe) | 4,3 | 5,8 | 16,9 | 22,5 | 61% |

- Cada pelea tiene ahora alrededor de un Desequilibrio (antes 0,2). Esa ventana de daño doble existe en todos los combates.
- El murciélago sigue siendo corto, a propósito: es el primer combate.
- El jefe queda en 5,8 turnos, por debajo del objetivo de 6 a 8. Con más Vida se vuelve una carrera de daño que castiga a la Serpiente y a la Grulla (con 170 de Vida, el promedio cae al 33%). Para alargarlo hace falta una mecánica, no más Vida (ver la sección 7).

### Uso de posturas (cartas jugadas desde cada postura)

| Perfil | Caballo | Arco | Vacía |
|---|---|---|---|
| Promedio | 30% | 39% | 31% |
| Experto | 29% | 38% | 33% |

Las tres posturas se usan. Arco es la más jugada, por los puñetazos.

### Poder de cada carta de recompensa
Cada valor es la victoria de una run que **empieza** con esa carta en el mazo, comparada con la del mazo inicial. Así se aísla la carta de cómo la elige el bot.

| Carta | Costo | Antes (promedio / experto) | Después (promedio / experto) |
|---|---|---|---|
| Patada de talón | 2 | −4 / −3 | +7 / +6 |
| Patada lateral | 2 | +9 / +3 | +5 / +1 |
| Empujón a fondo | 1 | 0 / −4 | +1 / −1 |
| Puño martillo | 1 | −1 / −8 | +4 / +3 |
| Bloqueo alto | 1 | 0 / −3 | −1 / −1 |
| Rodilla escudo | 1 | −1 / −2 | +2 / +1 |
| Recuperar el aliento | 0 | +10 / +6 | +9 / +4 |
| Saludo marcial | 0 | −4 / −10 | +5 / +7 |
| Garra de tigre | 1 | 0 / −7 | 0 / 0 |
| Salto del tigre | 2 | −8 / −10 | +4 / +2 |
| Guardia del tigre | 1 | −3 / −6 | 0 / −1 |
| Rugido del tigre | 0 | 0 / +2 | +1 / −2 |

Antes, **la mayoría de las recompensas empeoraban el mazo**: eran más flojas que las cartas iniciales, así que lo mejor era saltearlas. Ahora todas quedan entre −2 y +9. Las de costo 2 y las de robo son las más fuertes; las defensas, neutras. El margen es chico (±2 puntos de ruido con 1000 runs).

**Pendiente:** Bloqueo alto quedó en −1 porque lo usa la lección 2, con su Guardia de 9 en el guion. Si se la quiere mejorar, hay que cambiar también la lección.

### Qué se cambió

**Enemigos** (`enemies.json`; los muñecos de práctica no se tocaron):

| Enemigo | Vida | Estructura | Daño |
|---|---|---|---|
| Comunes | ×2,2 a ×2,7 (por ejemplo, Murciélago 18 → 48, Discípulo 32 → 70) | ×1,3 a ×1,8 | ×1,15 |
| Monje | 55 → 116 | 15 → 21 | ×1,15 |
| Dragón | 90 → 154 | 20 → 26 | ×1,15 (el Aliento del Dragón pasa a 29) |

La Estructura sube para que el Desequilibrio llegue a mitad de pelea y no en el primer turno.

**Caminos** (`game_balance.json`):

| Camino | Robás | Aliento | Retenés |
|---|---|---|---|
| Tigre | 6 → 4 | 4 | 0 |
| Serpiente | 5 → 4 | 3 → 4 | 1 → 2 |
| Grulla | 4 | 3 → 4 | 3 |

Al tomar un camino, el discípulo pasa de 3 a 4 de Aliento: se siente como un salto de poder.

**Cartas del Tigre exclusivas:**
- Garra, Salto, Guardia y Rugido del tigre solo salen de recompensa si seguís el Tigre (`GameData.rewardPoolFor`).
- Es la identidad del camino, y el primer paso del árbol por camino de `futuro.md`.
- Lo que más pesa es el Aliento: con 4 de Aliento el Tigre ganaba 98% contra 46% de la Serpiente.
- El retener casi no suma, porque al empezar el turno se roba hasta completar la mano. Ver la sección 7.

**Fuente:** cura 15 → 20.

**Mazo inicial:**
- Un Bloqueo medio pasa a ser un segundo Paso atrás, que es el paso final del Pequeño Puño Rojo.
- El Pequeño Puño Rojo hace 14 de daño y 6 a Estructura (antes 10 y 5).
- Las formas pasan de 0,1 a 0,3–0,5 por run.

**Cartas de recompensa:**

| Carta | Antes | Después |
|---|---|---|
| Patada de talón | 8 de daño / 3 E | 11 / 4 |
| Patada lateral | 5 / 6 | 6 / 8 |
| Empujón a fondo | 3 de daño | 4 |
| Puño martillo | 6 de daño | 8, +1 E |
| Rodilla escudo | Guardia 6, desvío 4 | Guardia 8, desvío 5 |
| Saludo marcial | Solo en el primer turno (si salía después era una carta muerta) | Se juega en cualquier turno |
| Garra de tigre | 3 / 4 | 4 / 5 |
| Salto del tigre | 10 / 3 | 14 / 5 |
| Guardia del tigre | Guardia 7 | 9 |
| Rugido del tigre | Costo 1 | Costo 0 |

---

## 3b. Segunda vuelta (01/10/2026): retener, Dragón y dificultades

Tres cambios de regla, medidos con 1000 runs por perfil en Normal:

1. **Retener ya no ocupa lugar en la mano.** Al empezar el turno robás la mano completa y las cartas retenidas se suman. Con eso la Serpiente y la Grulla subieron a 84% y 83% (promedio) y el Tigre quedó atrás (62%). Se compensó con **Tigre: 5 cartas por turno** (antes 4).
2. **Escamas del Dragón.** Cada golpe le hace 1 de daño menos por escama, salvo que esté Desequilibrado; cada Desequilibrio le arranca una escama para siempre. Empieza con **4 escamas**, **150 de Vida** y **18 de Estructura** (antes 154 y 26) para que romperlo sea alcanzable y sea *la* respuesta. El Aliento del Dragón sigue cancelándose si lo desequilibrás antes.
3. **Dificultades** en la interfaz (sección 4).

| Perfil | Victoria (1.ª vuelta) | Victoria ahora | Minutos |
|---|---|---|---|
| Novato | 1% | 4% | 12,5 |
| Promedio | 60% | **63%** | 11,5 |
| Experto | 79% | **86%** | 10,9 |

| Perfil | Tigre | Serpiente | Grulla |
|---|---|---|---|
| Promedio | 64% | 61% | 64% |
| Experto | 85% | 87% | 86% |

| Eco del Dragón | Turnos | Vida perdida | Desequilibrios | Victoria |
|---|---|---|---|---|
| Promedio | 6,1 (antes 5,8) | 23,1 | 1,3 (antes 0,9) | 63% |
| Experto | 5,5 | 18,9 | 1,4 | 86% |

Probado y descartado: Serpiente retener 1 y Grulla 2 (el Tigre seguía 20 puntos abajo), Grulla con 5 de Aliento (desbalancea al revés), 2 o 3 escamas sin bajar la Estructura (el Dragón se rompe una sola vez y las escamas son solo una resta).

## 3c. Tercera fase del Dragón (01/10/2026)

El jefe seguía corto (6,1 turnos contra la meta de 7 a 10). Se le sumó una **fase 3 al 30% de Vida**:

- **Le vuelven a crecer escamas** hasta tener 2: hay que desequilibrarlo de nuevo para que los golpes entren completos.
- **El Aliento llega cada dos acciones** (medio 24, E8), con un barrido bajo doble (2 × 6, E2) entre medio. Se responde igual que en la fase 2: desviándolo o rompiéndolo antes.

Para que la pelea más larga no se coma la victoria, se compensó: **Vida 150 → 175** y el golpe medio de la fase 1 **12 → 10**.

| Eco del Dragón | Turnos | Vida perdida | Desequilibrios | Victoria |
|---|---|---|---|---|
| Promedio | **7,2** (antes 6,1) | 24,5 | 1,6 (antes 1,3) | 61% |
| Experto | 6,4 | 20,5 | 1,6 | 83% |

Run completa en Normal: novato 4%, promedio 59–61%, experto 83%. Caminos del promedio (3000 runs): Tigre 58%, Serpiente 61%, Grulla 64%. Probado y descartado: fase 3 sin compensar (63% pero solo 6,3 turnos) y solo subir la Vida (165 → 55%, 180 → 49%).

## 3d. Formas como recompensa (02/10/2026)

La subida arranca sin formas y cada recompensa ofrece 3 cartas **o** 1 forma. Se sumaron 5 formas con efectos distintos (Aliento, curación, +daño a puños, Estructura, remate del Tigre). Los bots valoran una forma por su efecto, cuántos pasos ya tienen y que se repite cada combate.

| Normal | antes (formas gratis) | ahora |
|---|---|---|
| Novato | 4–6% | 6% |
| Promedio | 59–60% | 58–60% |
| Experto | 83% | 82–83% |

Los bots aprenden ~0,5 formas por subida y completan 0,2–0,4 por subida (antes 0,3–0,7). Sus heurísticas casi no juegan alrededor de las formas, así que el balance no se mueve. La ventaja la saca el jugador que planifica, y eso es lo que hay que mirar en las pruebas reales.

## 3e. Eventos y talismanes (02/10/2026)

El mapa suma dos eventos (uno compite con el Discípulo, otro va después de la bifurcación) y el Monje deja elegir 1 de 3 talismanes. Los bots eligen talismanes por el valor medido en la sección 5 y opciones de evento por valor esperado (la Vida pesa más cuanto menos queda).

| Normal | antes | con eventos y talismanes | + Dragón con 8% más de daño |
|---|---|---|---|
| Novato | 6% | 8% | **5%** |
| Promedio | 58–60% | 66% | **59%** |
| Experto | 82–83% | 87% | **82%** |

Subir la Vida del Dragón casi no movía nada (×1,1 → 62%); el daño sí. Quedó en 10/11/10, 13/13/31 y 6×2/26 por fase. En Fácil el promedio gana el 95% y en Difícil el 27% (experto 56%). Los bots consiguen ~1 talismán por subida y la subida dura unos 12 minutos (los eventos se cuentan como 30 s).

## 3f. Mapa generado, jade, mercader y maestro (02/10/2026)

El mapa pasa a generarse por subida (9 pisos, ver `manual.md`), con mercader y maestro errante en los pisos 4 a 6. Los combates dan jade (14–20; élite 30–36). Precios: carta 20, talismán común 50, quitar carta 30, mejorar 25. Los bots van al mercader si les alcanza para una carta; ahí compran talismán si pueden, la mejor carta si vale la pena y quitan la carta inicial más floja. Con el maestro aprenden la forma que más rinde con su mazo o mejoran.

| Normal (1000 runs) | antes | mapa generado |
|---|---|---|
| Novato | 5% | **5%** |
| Promedio | 59% | **59%** |
| Experto | 82% | **84%** |

La subida sigue en ~13 minutos (mercader 40 s, maestro 25 s en el modelo de tiempo). Los bots pasan por 0,8 mercaderes y 0,8 maestros por subida y gastan ~17 de jade: un jugador real seguramente gaste más, así que conviene mirar el balance con partidas reales.

## 3g. Pasivas y cartas propias de cada camino (02/10/2026)

Cada camino gana una pasiva, 4 cartas propias y una forma propia (ver `manual.md`): Tigre +3 al primer ataque del turno, Serpiente +1 por cada ataque anterior del turno, Grulla −1 de costo a lo retenido. Respirar pasa a costar 1 de Aliento.

Las pasivas subieron el promedio de Normal de 59% a 68%. Para volver a ~60% se subió **+10% la Vida base de los seis rivales de la subida** (Murciélago 53, Salamandra 63, Discípulo 77, Gólem 70, Monje 128, Dragón 193). Así también endurecen Difícil y Shifu, que multiplican sobre esa base.

| Normal (1500 runs) | Tigre | Serpiente | Grulla | Total |
|---|---|---|---|---|
| Novato | 3% | 5% | 7% | 5% |
| Promedio | 61% | 61% | 63% | **62%** |
| Experto | 79% | 81% | 85% | **82%** |

Los bots valoran la cadena (~1,5 ataques previos) y lo retenido (la mitad de las veces) en `cardValue`, y retienen primero las cartas con bonus de retenida.

### Cartas nuevas de camino (6 por camino)
Tigre: Cola de tigre (patada 2 · 9/5, +7 con Desequilibrio) y Tigre que baja de la montaña (palma 1 · 5/6, → Caballo). Serpiente: Cola de serpiente (patada 1 · 3/2, +2 E por ataque previo) y Serpiente que se escurre (técnica 0, roba 2, se agota). Grulla: Rodilla de grulla (patada 1 · 3/3, +5 E retenida) y Canto de la grulla (defensa 2, Guardia 11 media, desvío 4/3).
Poder medido (pp de victoria al sumarla, promedio): entre −0 y +6; ninguna se dispara. Normal, 600 runs: novato 0%, promedio 58%, experto 82%; por camino el promedio queda entre 58% y 64%.

## 3h. Etapas 2 y 3 en el juego (06/10/2026)

La subida pasa a tener 3 etapas reales de 9 pisos (27 en total): Montaña de las Mil Nubes, Monasterio Colgado y Cumbre del Dragón Dormido. El simulador corre las etapas reales por defecto (`--stages 1` para la etapa 1 sola; el prototipo viejo quedó en `--proto`).

**Cambios para llegar al objetivo:**
- **Fuente antes del jefe:** en cada etapa el orden de arriba es élite → fuente → jefe (antes era fuente → élite → jefe). Fue lo que más movió: el promedio llega al jefe con ~52 de Vida en vez de ~31.
- **Entre etapas:** el jefe intermedio da talismán, recompensa y 25 de jade, y después se recupera toda la Vida.
- **Eco del Dragón** (ahora jefe de la etapa 1): Vida 193 → 150, Aliento 31 → 28.
- **Espinas en 1** (Hombre de Bronce, Abad de Hierro, León de las Nieves): con 2 se perdían 25 a 28 de Vida por pelea.
- **Dragón Dormido:** Vida 205, golpes 10/11/10 y Aliento 28/26.

**Resultado (1500 runs, Normal):**

| Perfil | Llega a la etapa 2 | Llega a la etapa 3 | Gana | Minutos (victorias) |
|---|---|---|---|---|
| Novato | 18% | 4% | 0% | — |
| Promedio | 83% | 76% | 59% | 39 |
| Experto | 96% | 92% | 83% | 37 |

La etapa 1 sola queda más fácil que antes (promedio 84%, experto 95%) porque ya no es el final.

**Por dificultad, con los valores de la etapa 1 (600 runs):** Fácil 13% / 99% / 100%, Difícil 0% / 15% / 45%, Shifu 0% / 1% / 6% (novato / promedio / experto). Con tres etapas el castigo se acumula, así que se recalibraron (sección 4).

### 3i. Dificultades para 3 etapas (06/10/2026)

Se buscaron las mismas referencias que en la etapa 1: novato ~40% en Fácil, promedio ~60% en Normal, experto ~55–60% en Difícil y ~18% en Shifu. Fácil se abrió más (el novato llegaba a la etapa 2 pero no pasaba de ahí) y Difícil y Shifu se suavizaron.

| Dificultad | Novato | Promedio | Experto |
|---|---|---|---|
| Fácil | **45%** · 42 min | 100% · 37 min | 100% · 35 min |
| Normal | 0% | **59%** · 39 min | 82% · 37 min |
| Difícil | 0% | 27% · 40 min | **60%** · 38 min |
| Shifu | 0% | 4% · 41 min | **17%** · 39 min |

**Hongo Lingzhi (mismo día):** común nuevo de los pisos 5 y 6 de la etapa 1 (52 de Vida, regeneración 3). Es una pelea liviana (novato 3,9 de Vida perdida, 3,4 turnos) que presenta la regeneración antes de la etapa 2. Normal queda en novato 0%, promedio 57%, experto 86% (1000 runs).

(1000 runs por perfil.) Los Picos no se tocaron: encima de Normal bajan parejo, del 80% al 3% para el experto y del 50% al 1% para el promedio (400 runs):

| Pico | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|
| Promedio | 50% | 40% | 35% | 26% | 13% | 6% | 4% | 3% | 1% | 1% |
| Experto | 80% | 74% | 64% | 59% | 42% | 30% | 22% | 12% | 7% | 3% |

## 4. Dificultades (implementadas)

**Implementado:** al empezar cada subida se elige **Fácil, Normal, Difícil o Shifu** (`game_balance.json` → `difficulties`). Afecta la Vida inicial, la curación de la fuente y la Vida, Estructura y daño de los enemigos de la subida (los muñecos de las lecciones no cambian).

| Dificultad | Vida | Fuente | Vida enemiga | Daño enemigo | Estructura enemiga |
|---|---|---|---|---|---|
| Fácil 易 | 65 | +30 | 88% | 80% | 100% |
| Normal 常 | 50 | +20 | 100% | 100% | 100% |
| Difícil 难 | 50 | +15 | 106% | 107% | 100% |
| Shifu 师 | 45 | +15 | 114% | 114% | 106% |

Valores para 3 etapas (sección 3i). La tabla de abajo es la medición original, con la etapa 1 sola y Fácil 60/+25/95%/85%, Difícil 110%/110% y Shifu 120%/120%/110%.

Victoria y minutos de las runs ganadas (1000 runs por perfil, etapa 1):

| Dificultad | Novato | Promedio | Experto |
|---|---|---|---|
| Fácil | **40%** · 13 min | 97% · 12 min | 99% · 11 min |
| Normal | 4% · 13 min | **59%** · 12 min | 83% · 11 min |
| Difícil | 0% | 27% · 13 min | **56%** · 12 min |
| Shifu | 0% | 4% · 14 min | **18%** · 13 min |

(Medido con el Dragón de tres fases, sección 3c.)

Cada escalón le quita al perfil de referencia entre 30 y 40 puntos: Fácil es para aprender, Normal la experiencia diseñada, Difícil el reto del experto y Shifu una meta de maestría: aparece bloqueada (tono blanco y candado) hasta ganar una subida en Difícil. Los Picos (sección 6) siguen como idea para el juego completo, encima de estas cuatro.

Lo que sigue es el análisis de la primera vuelta, que llevó a esta decisión.

**Primera vuelta: un modo Sereno** para la primera subida. Con los números nuevos, el novato gana el 1% de las runs: llega al Dragón la mitad de las veces y ahí cae. El Gólem es su gran muro: 39% de victoria y 27 de Vida perdida, porque el novato no busca el Desequilibrio.

**Prototipo de Sereno:** Vida 65 en vez de 50 y enemigos con −20% de daño.

| Perfil | Normal | Sereno |
|---|---|---|
| Novato | 1% | **12%** (Tigre 23%) |
| Promedio | 60% | 99% |
| Experto | 79% | 100% |

**Recomendación:**
1. **Sereno** como opción al empezar la subida, recomendada si todavía no ganaste nunca. Es "aprender la montaña". Más adelante se puede reforzar con avisos de altura en la mano.
2. **Normal** es la experiencia diseñada.
3. **Picos** (sección 6): la dificultad que se gana ganando, para quien ya domina el juego.

Sereno no está implementado en la interfaz: queda en `futuro.md`.

---

## 5. Modelo del juego completo: 3 etapas (solo en el simulador)

Es un prototipo en `tool/sim/lab.dart`. El juego no lo carga.
- **Mapa:** 3 etapas de 13 pisos, con dos caminos por piso y generado con la semilla de la run.
  - El santuario está en el piso 4 de la etapa 1.
  - Hay élite desde el piso 5 (18%).
  - Hay fuente desde el piso 3 (30%), y una fuente siempre antes del jefe.
- **Enemigos:** las etapas 2 y 3 reutilizan los enemigos con una curva aplicada:
  - Vida ×1,1 y ×1,2.
  - Daño y Estructura ×1,05 y ×1,1.
- **Jefe:** al vencer al jefe de una etapa se recupera toda la Vida.
- **Talismanes:** uno al vencer cada élite y cada jefe.

| Perfil | Victoria | Llega al jefe final | Minutos (media) | Minutos (victorias) | Mazo final |
|---|---|---|---|---|---|
| Novato | 0% | 0% | 10,7 | – | 16 |
| Promedio | 45% | 56% | 41,8 | **55** | 33 |
| Experto | 57% | 68% | 44,8 | **53** | 35 |

**Lo que enseña el prototipo:**
- **La duración ya da.** Una subida ganada dura 53 a 55 minutos, dentro del objetivo de 45 a 70, con unos 28 combates.
- **En una run larga lo que mata es el desgaste, no un combate.**
  - Con la curva que se pensaba al principio (Vida ×1,6 y ×2,3), nadie pasaba de la etapa 2.
  - Con una fuente cada tanto y la curación del jefe, los combates de las etapas 2 y 3 se vuelven *más cortos* que los de la etapa 1, porque el mazo crece más rápido que la curva.
  - Conclusión: las etapas 2 y 3 necesitan **enemigos nuevos con reglas nuevas** que exijan otras respuestas, no números más grandes. Ahí está la profundidad, y de paso el arte.
- **El mazo engorda.** Los bots terminan con 33 a 35 cartas, porque casi nunca saltean.
  - El Pico 7 (recompensas de 2 cartas) le *sube* la victoria al experto.
  - Hacen falta más formas de achicar el mazo (la fuente ya permite eliminar una carta) y que la interfaz deje claro que saltear es válido.
- **Las formas siguen siendo raras** (0,4 a 0,7 por run). Con un mazo de 30 cartas, juntar la secuencia es difícil. Hace falta retener mejor o tener formas propias de cada camino (sección 7).

### Talismanes (perfil promedio, empezando la run de 3 etapas con uno solo)

| Talismán | Efecto | Diferencia de victoria |
|---|---|---|
| Arco | Empezás cada combate en Arco | +1 a +5 |
| Aliento | +1 de Aliento en el turno 1 | +9 a +11 |
| Vida | +4 de Vida máxima | +6 a +10 |
| Formas | Cada forma completa cura 8 | 0 a +1 |
| Desvío | Cada desvío da +1 de Aliento extra | +1 a +3 |
| Roca | +4 de Estructura al empezar cada combate | +4 a +6 |
| Primer golpe | El rival empieza con 6 de Vida menos | +6 a +8 |
| Grieta | El rival empieza con 3 de Estructura menos | +7 a +17 |
| Fuente | La fuente cura 8 más | +6 a +8 |
| Victoria | Ganar un combate cura 2 | +9 a +14 |

Los rangos vienen de dos corridas de 400 runs; el ruido es de unos ±4 puntos.
- **Para los talismanes comunes:** Primer golpe, Roca, Fuente y Vida.
- **Para los raros o de jefe:** Grieta, Victoria y Aliento.
- **Flojos:** Formas y Desvío. Hay que reforzarlos o atarlos a una mecánica que el jugador busque. Por ejemplo, Desvío podría dar +2 de Aliento.

Todos los talismanes juntos valen unos +20 puntos: de 27% sin ninguno a 45% con los que se ganan en la subida.

---

## 6. Picos: dificultad desbloqueable (etapa 1, en el juego)

Están en `game_balance.json` → `picos` y se acumulan: el Pico N incluye las reglas del 1 al N. Van encima de Normal; ganar en Normal o más difícil abre el siguiente. `dart run tool/simulate.dart --section picos` usa las mismas reglas que la app.

| Pico | Regla nueva | Promedio | Experto |
|---|---|---|---|
| 0 | Normal | 62% | 82% |
| 1 | Élites +15% de Vida | 61% | 80% |
| 2 | La fuente cura 5 menos | 56% | 78% |
| 3 | El jefe +10% de Vida | 51% | 74% |
| 4 | Rivales +5% de daño | 39% | 65% |
| 5 | Empezás con 5 de Vida menos | 30% | 56% |
| 6 | Rivales +10% de Estructura | 20% | 44% |
| 7 | Rivales +5% de daño otra vez | 16% | 38% |
| 8 | Élites y jefe +10% de Vida otra vez | 11% | 32% |
| 9 | Rivales +5% de daño otra vez | 7% | 24% |
| 10 | Todos los rivales +8% de Vida y +5% de Estructura | 3% | 17% |

- **Curva:** cada Pico le quita al experto entre 2 y 12 puntos, sin saltos grandes. Con un humano experto, que juega mejor que el bot, el Pico 10 debería quedar en 20–30%.
- **Qué pesa:** el daño enemigo y la Vida inicial son las palancas más fuertes; la Vida de los comunes casi no cambia nada (se descartó). La Vida de élites y jefe muerde poco al principio, por eso abre la escala.
- **Prototipo anterior (3 etapas):** las reglas "la fuente cura menos" y "empezás con menos Vida" no tenían efecto en el simulador (tocaban valores que la run no usa), así que sus números estaban inflados. Las "recompensas de 2 cartas" no endurecían y se sacaron.

---|---|---|---|
| 0 | Normal | 45% | 55% |
| 1 | Élites +10% de Vida | 44% | 52% |
| 2 | La fuente cura 3 menos | 39% | 47% |
| 3 | Jefes +5% de Vida | 31% | 36% |
| 4 | Comunes +4% de Vida | 28% | 37% |
| 5 | Empezás con 3 de Vida menos | 23% | 34% |
| 6 | Enemigos +5% de daño | 16% | 29% |
| 7 | Recompensas de 2 cartas en vez de 3 | 16% | 32% |
| 8 | Élites +10% de Vida (acumula) | 13% | 30% |
| 9 | Jefes +5% de Vida (acumula) | 10% | 22% |
| 10 | Todos los enemigos +3% de Vida y de daño | 5% | 12% |

- **Curva:** la caída es gradual y el Pico 10 queda en 12% para el experto. Con un humano experto, que juega mejor que el bot, debería quedar en 15–30%.
- **Pico 7:** no endurece. Con menos cartas para elegir, el mazo engorda menos. Hay que reemplazarlo, por ejemplo por "élites con una regla extra".
- **Pico 3:** es el escalón más grande, porque el jefe es la pelea que más decide. Si se busca suavidad, conviene ponerlo más tarde.

---

## 7. Lo que queda (palancas y decisiones)

1. ~~Retener vale poco~~ → resuelto: lo retenido es extra (sección 3b).
2. ~~El jefe es una carrera de daño~~ → resuelto en parte con las escamas (6,1 turnos, 1,3 Desequilibrios). Con la tercera fase (sección 3c) llega a 7,2 turnos.
3. ~~Modo Sereno~~ → resuelto con las cuatro dificultades. Falta confirmarlas con personas reales.
4. **Recompensas:** probar rareza (comunes y raras) cuando haya más cartas, y dar alguna señal de que saltear es una buena jugada.
5. **Calibrar el tiempo** cronometrando a alguien que juegue por primera vez.
6. **Repetir esta pasada** después de cada cambio de reglas, contenido o enemigos, con `dart run tool/simulate.dart`.

### 3j. Once pisos por etapa (07/10/2026)
Para acercar la duración a la meta (45 a 75 minutos) cada etapa suma dos pisos antes del élite: uno con 3 combates, 2 eventos, mercader y maestro, y otro con 2 combates. Los enemigos son los del piso de abajo. El élite queda en el piso 9, la fuente en el 10 y el jefe en el 11 (33 pisos en total).

| Normal, 600 runs | 9 pisos | +1 piso | +2 pisos (elegido) |
|---|---|---|---|
| promedio | 58% · 38 min | 55% · 41,5 min | 58% · 44 min |
| experto | 82% · 36 min | 79% · 40 min | 82% · 42,5 min |

Los pisos extra dan más recompensas y jade, y eso compensa el desgaste. Con dificultades (400 runs, novato / promedio / experto): Fácil 46% / 100% / 100% (Vida 65 → 70 para devolver al novato al ~45%), Normal 0 / 60 / 82, Difícil 0 / 31 / 60 y Shifu 0 / 5 / 16. Picos: el experto va de 84% a 5% y el promedio de 59% a 0%. Al final sobran ~56 de jade: el mercader por etapa (precios y surtido) queda pendiente.

### 3k. Eventos por etapa y mercader por etapa (07/10/2026)
- **Eventos:** 8 nuevos con `stages` (2 de la etapa 1, 3 de la 2 y 3 de la 3). En cada etapa salen primero los propios sin ver, después los generales sin ver y, al final, cualquiera de la etapa. Usan los mismos efectos de siempre. Normal (600 runs): promedio 61%, experto 80%.
- **Mercader** (`merchant` dentro de cada etapa pisa el base): Monasterio 4 cartas a 25, talismán 60, quitar 35, mejorar 30, té 20 (+20); Cumbre 4 cartas a 30, talismán **raro** a 85, quitar 40, mejorar 35, té 25 (+25). Normal: promedio 59%, experto 79%, ~44 min. Dificultades (400 runs): Fácil 45 / 100 / 100, Normal 0 / 61 / 79, Difícil 0 / 33 / 60, Shifu 0 / 6 / 19.
- Sobran ~52 de jade al final: casi todo se gana después del último mercader (élite, fuente y jefe), así que no es un problema de precios.

### 3l. Despertares del camino (07/10/2026)
- Al superar la etapa 1 y la 2 se elige 1 de 3 despertares del camino (4 por camino, en `styles.*.awakenings`; `run.awakeningChoices`). Efectos en `AwakeningEffect`: los numéricos se suman a la pasiva (golpe primero, cadena, retener, robar, descuento retenido) y los nuevos son Estructura y descuento del primer golpe, robar al desequilibrar, Estructura en cadena, robar en el tercer ataque, daño retenido, Guardia extra y Aliento por desvío.
- Sin compensar suben al promedio de 59% a 77%. Se compensa con `enemyMods` por etapa (mismas reglas que un Pico): Monasterio +14% Vida / +9% daño, Cumbre +22% / +16%.
- Normal (1000 runs): novato 0%, promedio 62%, experto 81%, ~45 min. Por camino (promedio): Tigre 67%, Serpiente 59%, Grulla 59%.
- Dificultades (600 runs): Fácil 43 / 100 / 100, Normal 0 / 62 / 80, Difícil 0 / 34 / 61, Shifu 0 / 6 / 26.
- Victoria del promedio por despertar (runs que llegaron a la etapa 2, base 73%): los más fuertes son Garra que quiebra (93%), Alas abiertas (87%), Salto (86%) y Abrazo (85%); los más flojos, Quietud (58%) y Veneno lento (69%). Robar 1 más por turno es lo más fuerte; si hace falta, es lo primero que se toca. Quietud depende de retener ataques, que los bots hacen poco.

### 3m. Cultivo del aliento (07/10/2026)
- `cultivation` en `game_balance.json`. Aliento por subida: 2 por piso + 10 por etapa + 25 por ganar, × dificultad (50/100/130/160%) × (1 + 10% por Pico). `RunState.locked` congela lo cerrado al crear la run. El simulador acepta `--locked id,id` y tiene `--section cultivation`.
- **Primer intento: cerrar raros y cartas generales.** En el reino 1 el promedio bajaba a 44% (con todo abierto, 59%). Por grupos (800 runs): los 3 raros cerrados, 52%; las cartas, 54%; la Grulla, 63%; las formas, 62%. Por separado cada raro casi no mueve nada; juntos sí.
- **Quedó: solo variedad.** Cerrados al inicio: la Grulla, 6 cartas de camino y 4 formas. Victoria del promedio por reino (800 runs): 58 / 58 / 56 / 61 / 61 / 60%; experto 80–86%. Aliento medio por subida en Normal: novato ~22, promedio ~85, experto ~101.
- **Ritmo** (umbrales 90 / 250 / 460 / 720 / 1050). Subidas para llegar a cada reino:

  | Perfil | Reino 2 | Reino 3 | Reino 4 | Reino 5 | Reino 6 |
  |---|---|---|---|---|---|
  | Promedio | 1,1 | 2,9 | 5,4 | 8,5 | 12,3 |
  | Experto | 0,9 | 2,5 | 4,6 | 7,1 | 10,3 |

  A unos 40 minutos por subida, el último reino llega en unas 8 horas de juego para el promedio.

### 3n. Grupos, mercader ambulante y Normal para el experto (09/10/2026)
- **Por qué:** en la primera subida real el usuario pasó la etapa 1 sin conocer combos. Un nodo era un solo enemigo, de 11 pisos solo 3 obligaban a pelear y se podían encadenar mercaderes. El bot promedio juega peor que una persona que lee las intenciones.
- **Cambios:**
  - Pisos 2 a 8: combate 4–5 / evento 2 / maestro 1, sin mercader.
  - Grupos (`floors[].packs`): E1 `{1:3, 2:2}`, E2 `{1:2, 2:2, 3:1}`, E3 `{1:1, 2:2, 3:1}`. Solo comunes que no huyen. `run.packs.hpPct` [100, 70, 58] y `jadePerExtra` 5.
  - Mercader ambulante (`run.wanderingMerchant`): cada 3 ± 1 combates ganados, o tras el élite si la etapa no tuvo ninguno. Sale ~4 veces por run para el promedio y ~5 para el experto.
- **Calibración nueva:** Normal se mide con el **experto ~60%**, no con el promedio. Las lecciones (y los tests) corren sin dificultad: `difficulty: null`.
- **Resultados (1000 runs):**

  | Dificultad | Vida | Fuente | Enemigos (Vida/daño) | novato | promedio | experto |
  |---|---|---|---|---|---|---|
  | Fácil | 60 | 25 | 104 / 104 | 0% | 64% | 86% |
  | Normal | 50 | 20 | 106 / 105 | 0% | 33% | 62% |
  | Difícil | 50 | 15 | 111 / 111 | 0% | 16% | 43% |
  | Shifu | 45 | 15 | 112 / 111 (+6% Estructura) | 0% | 7% | 24% |

  Una subida completa dura ~55 min (antes ~45).
