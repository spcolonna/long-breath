# Futuros cambios y plan de crecimiento

Lo que queda para después del MVP: pendientes concretos, ideas de mecánica y el plan para que el juego completo tenga la profundidad y la duración de un juego pago. Cuando algo se implementa, se saca de acá y se documenta en `manual.md` / `reglas-implementadas.md`.

---

## 1. Pendientes inmediatos

- **Balance:** hecho el 01/10/2026 (ver `balance.md`).
  - Combates de 2,4 a 4,8 turnos.
  - El jugador promedio gana el 60% de las runs y el experto el 79%.
  - Los tres caminos quedan parejos.

  Segunda vuelta (mismo día): dificultades Fácil/Normal/Difícil/Shifu en la interfaz, retener como cartas extra (Tigre roba 5) y escamas del Dragón.

  Lo que queda:
  - **Formas más alcanzables:** formas propias de cada camino.
  - **Calibrar el modelo de tiempo** con partidas reales, y confirmar las dificultades con personas.
  - **Tercera fase del Dragón** si con personas el jefe se siente corto.
  - **Shifu desbloqueable** (ganar en Difícil), si se quiere que sea una meta y no una opción más.
- **Duración acorde al precio (requisito de la versión final).** Hoy una subida se resuelve en unos 12 minutos y el juego completo (3 etapas, prototipo) en alrededor de una hora. Para la versión que se venda, eso no alcanza: la duración total tiene que estar a la altura de lo que cuesta. Antes de lanzar hay que fijar el precio y, con él, la meta de horas (ver sección 3), y verificarla con el simulador y con personas: horas hasta la primera victoria, horas hasta ganar con los tres caminos y horas de rejugabilidad (dificultades, Picos, cultivo).
- **Arte de enemigos faltante:** `disciple.png`, `monk.png` y `dragon.png` en `assets/art/enemies/`.
- **Nombres de cueva:** "Salamandra de la Grieta", "Gólem de Estalactita" y "Eco de Murciélago" vienen de la vieja idea de la cueva. Hay que pasarlos a nombres de montaña, épicos o memorables (`assets/l10n/content/es.json`).
- **Zoom de la carta seleccionada:** hoy es ×1,5 y tapa parte de la vista previa. Evaluar 1,35.

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

### Formas
- **Más formas** en lugar de 2: formas de cada camino y formas largas de 5 o 6 pasos con gran recompensa.
- **Formas con cadena de postura:** cada paso tiene que jugarse en una postura determinada.
- **Aprender formas en la subida:** las da un maestro errante, en un nodo del mapa.

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

### 3.2 Mapa generado
- El mapa deja de ser fijo: se arma con la semilla de la run, con reglas por piso. Por ejemplo:
  - Élite no antes del piso 4.
  - Fuente antes del jefe.
  - Al menos un santuario.
- Ninguna subida es igual a otra.
- **Arte:** ninguno.

### 3.3 Nuevos tipos de nodo
- **Evento:** una escena de texto con una decisión. Por ejemplo, un ermitaño ofrece una carta a cambio de Vida, o un puente roto se cruza con riesgo o se rodea. Es barato de producir y le da mucha variedad e historia a la subida.
- **Mercader de pergaminos:** compra de cartas, mejoras y talismanes con una moneda de la run (por ejemplo, monedas de jade que se ganan en los combates).
- **Maestro errante:** enseña una forma o mejora una carta.
- **Arte:** 1 ícono por tipo de nodo. Los eventos se resuelven con texto y alguna ilustración reutilizada.

### 3.4 Talismanes (objetos pasivos)
- Objetos que duran toda la subida y cambian las reglas. Por ejemplo:
  - "Empezás cada combate en Arco."
  - "El primer desvío de cada combate da +2 de Aliento."
  - "Las formas completas curan 3."
- Son la fuente principal de combinaciones y de rejugabilidad en los roguelikes de cartas.
- **Prototipo:** hay 10 talismanes medidos en `balance.md` (sección 5). Cada uno suma entre +1 y +14 puntos de victoria, y todos juntos unos +20.
- Se obtienen en las élites, los jefes, los eventos y el mercader.
- **Arte:** ícono chico por talismán. Se pueden armar con un set de íconos simples o con caracteres caligrafiados.

### 3.5 Más enemigos
- **Por etapa:** entre 6 y 8 comunes, 2 o 3 élites y 1 jefe, cada uno con una regla que enseñe algo.
- **Variantes con poco arte:** el mismo sprite recoloreado por código, como el héroe, con otro patrón y otra regla. Por ejemplo, "Gólem de Jade" frente a "Gólem de Piedra".
- **Arte:** entre 4 y 6 sprites nuevos por etapa. El resto son variantes.

### 3.6 Dificultad creciente: los Picos
- Después de ganar se habilita el **Pico 1**, y así hasta el 10. Cada pico suma un modificador acumulativo. Por ejemplo:
  - Enemigos con +10% de Vida.
  - La fuente cura menos.
  - Las élites tienen una regla extra.
- Es lo que da cientos de horas de rejugabilidad.
- **Prototipo:** hay una escala de 10 Picos simulada en `balance.md` (sección 6). La caída es gradual, de 55% a 12% para el experto.
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
- **Escenas:**
  - Prólogo en el templo del Dragón Dormido 卧龙门.
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
