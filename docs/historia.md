# Biblia de historia de Long Breath

Esta es la fuente de verdad para escribir textos nuevos (eventos, hilos, cartas, sueños). Los textos del juego están en `assets/l10n/content/es.json` (`lore`, `events`, `masterLines`, `enemies.*.intro/reply/...`).

## El mundo en una frase
Al pie de la Montaña de las Mil Nubes, la escuela del Dragón Dormido (卧龙门) manda a sus discípulos a subir de a uno. Arriba duerme un dragón que fue el primer discípulo. Su aliento hace las nubes y sueña con todos los que suben.

## Tono
- Nada oscuro ni macabro: caer es «quedarse en la montaña», no morir con sangre.
- Ternura, humor seco y asombro.
- Voseo rioplatense.
- Frases cortas.
- Cada texto deja una pregunta o una imagen, no una explicación.

## Personajes con nombre

| Personaje | Nombre | Qué sabemos | Dónde aparece |
|---|---|---|---|
| Protagonista | «Discípulo nº N» (sin nombre: cambia en cada subida) | — | Todo |
| Maestro | 松 **Song**, «el pino». **El nombre se revela recién en «El nombre que falta».** Firma sus cartas con «—S.». | Cayó frente a la Dama del Viento sin pedir paso. El dragón soñó que bajaba. Anota pisos, no nombres. | Tutorial, maestro errante, cartas del campamento, epílogo |
| Dragón Dormido | — | El primer muchacho que subió. Prometió respirar por el valle. Escribe en la piedra de la cumbre los nombres que sueña. | Sueños, jefe final |
| Dama del Viento | — | La primera que llegó al templo helado. Tiene miedo de elegir mal y por eso no deja pasar a nadie. | Élite de la etapa 3, sueño 7 |
| Monje sin Rostro | — | Fue maestro antes que el maestro. Cuida el **sendero de piedra** (etapa 1, no las campanas). | Élite de la etapa 1 |
| Mercader | 包叔 **Tío Bao**, «el del fardo» *(planeado, hilo 1.1)* | Fue discípulo, se quedó sin aliento en el monasterio y eligió bajar y subir vendiendo, sin pelear. | Mercader |
| Rival | 霜 **Shuang**, «Escarcha», de la escuela del Ave Azul (青鸾派) *(planeado)* | Apuesta carreras a la cumbre. La cadena `rival` → `rival_summit`. | Eventos |
| Monje herido | 明 **Hermano Ming** *(planeado)* | Cadena `wounded` → `wounded_return`. | Eventos |
| Herrero | 铁 **Maestro Tie** *(planeado)* | Cadena `smith` → `smith_delivery`. | Eventos |

## Los nombres tallados (coherencia)
- **Vigas del monasterio:** los monjes tallan los nombres de los que siguen subiendo. Los nombres quedan **a medio tallar**: al tuyo le falta la última letra.
- **Piedra de la cumbre:** los nombres están **completos**, escritos por el dragón al soñarlos, antes de que cada uno nazca.
- **Maestro Song:** talla la última letra de su nombre en la viga más alta cuando alguien llega por los tres caminos.

## Cómo llega la historia
| Momento | Qué se cuenta | Estado |
|---|---|---|
| Inicio | Prólogo | Hecho |
| Durante la subida | Presentación de etapa, diálogos de élites y jefes, maestro errante, eventos con historia | Hecho |
| **Campamento entre etapas** | Carta del maestro la primera vez (`letter_1`, `letter_2`). Después, el próximo sueño del dragón. Voto opcional para la etapa siguiente. | **Hecho (10/11)** |
| **Al caer** | El próximo sueño del dragón (`dream_1`…`dream_10`, en orden) | **Hecho (10/11)** |
| Final de la subida | Cumbre, epílogo, final por camino, «El nombre que falta» | Hecho |
| Entre subidas | Hilos con personajes (rival, mercader, herido, herrero) que recuerdan lo que hiciste | Planeado (`docs/plan-pro.md` 1.1) |

## Los sueños del dragón (orden fijo)
1. Un sueño de nubes: te respiran desde arriba.
2. El primero que subió: un muchacho sin escuela ni sendero.
3. La promesa: respirar por los de abajo.
4. Escamas: la nieve se vuelve escamas y el valle reverdece.
5. La primera puerta: una mujer funda la escuela y manda a uno por vez.
6. Los que se quedan: los caídos empujan el aliento hacia el valle.
7. La niña del viento: la Dama del Viento y su miedo a elegir.
8. Unas sandalias en la nieve: el maestro y la Dama.
9. Las cartas sin enviar: tu nombre escrito antes de que nacieras.
10. Descansar un rato: el dragón sueña a alguien que respire por él.

## Votos del campamento
Son talismanes de rareza `vow` en `talismans.json`: duran una etapa, no salen como premio y no cuentan para los hitos.

| Voto | Hanzi | Ventaja | Costo |
|---|---|---|---|
| Silencio | 静 | +1 Aliento en el primer turno | −4 Estructura |
| Ayuno | 斋 | Mercader 25% más barato | −8 Vida máxima |
| Penitencia | 苦 | +10 de jade por victoria | La fuente cura 10 menos |
| Firmeza | 坚 | Conservás el 25% de la Guardia | −6 Vida máxima |
| Fiereza | 猛 | +2 de daño en los golpes pesados | −4 Estructura |
| Loto | 莲 | Las formas curan 8 | Mercader 20% más caro |
