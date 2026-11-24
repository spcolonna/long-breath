# Rediseño: desafío, árboles y razones para volver

**Origen (23/11/2026).** Partida real con la build +8: ganó en Normal, en la primera subida con la Serpiente, sin esforzarse.
- Duró unos 40 minutos activos: 14 minutos la etapa 2 y 10 la etapa 3.
- Las 25 peleas duraron entre 1 y 4 turnos. Nunca bajó de 14/60 de Vida.
- Mató al Dragón dormido (349 de Vida) en 2 turnos, con 316 de daño en el primero.
- Terminó con 278 de jade y 166 de loto sin gastar.

**Decisión del usuario:** sigue siendo un juego **de pago único**. Ganar tiene que **obligar a desarrollar varios árboles de progreso**. Se rehace a fondo.

## Metas

| Meta | Hoy | Objetivo |
|---|---|---|
| Primera victoria en Normal | subida 1 | subida 8–15, con 1 o 2 ramas del árbol completas |
| Árboles completos | ~8 subidas (1260 de loto) | 25–35 subidas |
| Todo el contenido (3 finales, final verdadero, Picos) | ~4 h | 30–50 h |
| Peleas comunes | 1–4 turnos | 3–6 turnos |
| Jefe | 2 turnos | 6–10 turnos, sin saltear fases |
| Recursos al final de una subida | sobran | se gastan; en la escuela si sobran |

**Calibración:** el simulador subestima a una persona (dice promedio 24% y experto 53%, pero el usuario ganó sin esfuerzo). Desde ahora:
- El **bot experto, sin árbol, tiene que ganar ≤10% en Normal**.
- Con un árbol completo, ~35%. Con todos, ~70%.
- Cada build se valida con registros reales (`run_logs`), no solo con bots.

## Fase 1 — Techo de combate y base más dura
El daño crece sin límite y los jefes no frenan nada.

1. **Fases de jefe como barreras.** Al cruzar un umbral el daño sobrante se pierde.
   - El jefe se recompone: sale del Desequilibrado, recupera Estructura y escamas, y gana Guardia.
   - Hace un rugido o una acción inmediata.
   - Nunca puede saltear dos fases en un turno.
   - Todos los jefes de etapa pasan a tener 3 fases.
2. **Desequilibrado ×2 → ×1,5.** Se mantiene que ignore escamas.
3. **Filo y sus variantes** (abismo, voto_filo) pasan a sumar **solo al primer ataque de cada turno**, con un valor más alto (+6/+8), en vez de a cada golpe.
4. **Base de Normal más dura:**
   - Más Vida y daño de los enemigos en las etapas 2 y 3.
   - La cura entre etapas baja de 40% a 25% de lo que falta.
   - La fuente cura menos o deja de estar siempre antes del jefe.
5. **Comunes con intención que castiga.** Calibrar para que la etapa 3 haga perder Vida de verdad.
6. **Bot experto como «persona».** Medir contra el registro del 23/11: con el mazo y las decisiones de ese registro, el bot tiene que terminar con poca Vida o caer.

## Fase 2 — Árboles que hay que desarrollar (el centro del rediseño)
Los recursos se ganan en cada subida y se gastan entre subidas. Son tres árboles con monedas distintas:

1. **Meridianos ampliados (loto). ✅ Hechos el 24/11** (ver `balance.md` §4c): 36 puntos, 3 ramas de 10 filas con 2 elecciones cada una, ~6950 de loto. Lo de abajo era el plan.
   - Pasan de 15 a ~36 nodos: 3 ramas × 12, con costos crecientes y ~6000 de loto en total.
   - Nodos con decisiones: elegir 1 de 2 en ciertos puntos.
   - Nodos que cambian cómo se juega: segundo Respirar, contragolpe mejorado, técnica más barata.
   - La rama Cuerpo es la que hace «posible» ganar en Normal.
2. **Maestría por camino (experiencia del camino). ✅ Hecha el 24/11** (ver `balance.md` §4d). Cada camino (Tigre, Serpiente, Grulla) sube de nivel con lo que se pelea con él.
   - Desbloquea cartas raras de ese camino, su técnica mejorada, un tercer despertar y su arma nivel 3.
   - Obliga a jugar con los tres caminos.
3. **La escuela (jade). ✅ Hecha el 23/11** (ver `balance.md` §4b). El jade que sobra deja de convertirse en loto y pasa a restaurar el monasterio.
   - Forja (Tie): armas mejores desde el inicio y templar en el mapa.
   - Casa de té (Bao): té y curación a la venta.
   - Enfermería (Ming): fuente mejor y curar entre etapas.
   - Biblioteca: más opciones de carta y de evento.
   - Patio (Shuang): práctica y desafíos.
   - Cada edificio tiene 3 niveles y abre un capítulo de historia. Así gastar jade en la subida o guardarlo para la escuela es una decisión real.
4. **Economía:** una subida perdida rinde ~60–120 de loto y una ganada ~200–300. Calibrarlo para las metas de arriba.

## Fase 3 — Historia que se arma en muchas subidas
1. **Un misterio central:** por qué duerme el dragón y quién fue el primer discípulo.
   - Se revela con los sueños (10), las páginas (12) y los capítulos de la escuela.
   - Cada revelación cambia algo de la montaña: un enemigo, un evento, el diálogo del jefe.
2. **Hilos de Ming y Tie** (ya tienen retrato): 5 capítulos cada uno, ligados a su edificio.
3. **Finales escalonados:**
   - Final de camino al ganar con cada uno.
   - **Final verdadero**: los 3 finales + Pico 5 + la escuela restaurada, con un jefe extra.
4. **Voces:** el maestro comenta la subida anterior y cada jefe tiene una línea al empezar y otra al caer.

## Fase 4 — Picos con reglas y retención
1. **Picos (1–10) con reglas, no solo números:** niebla, aire fino, campanas, élites con dos preguntas, jefe con una fase extra.
   - Ganar en cada Pico da una marca por camino.
2. **Desafío diario** con semilla y estadísticas por camino.
3. **Pantalla de progreso:** árboles, escuela, finales y Picos de un vistazo, para que se vea cuánto falta.

## Arte necesario (poco)
- Escuela: 1 ilustración base + 5 edificios restaurados (6 imágenes).
- Jefe extra del final verdadero: 1 imagen.
- Ming y Tie ya tienen retrato. Lo demás se resuelve por código.

## Orden de trabajo
1. Fase 1, en la build +9: el usuario la prueba y confirma que Normal ya no se gana en la primera subida.
2. Fase 2: árboles y escuela, con la economía calibrada.
3. Fase 3: historia.
4. Fase 4: Picos y retención.
