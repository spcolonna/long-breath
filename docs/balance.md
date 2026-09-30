# Balance: resultados del simulador

`dart run tool/simulate.dart --n 500 --runs 300 --age adult` (29/09/2026, números del documento de diseño sin tocar).

Los combates aislados se juegan con el mazo inicial y la Vida completa.

| Enemigo | Aleatorio: victoria / turnos | Planificador: victoria / turnos | Diferencia |
| --- | --- | --- | --- |
| Eco de Murciélago | 100% / 2.0 | 100% / 1.2 | 0 pp |
| Salamandra | 100% / 2.7 | 100% / 1.6 | 0 pp |
| Gólem | 100% / 4.6 | 100% / 2.8 | 0 pp |
| Discípulo Perdido | 100% / 3.1 | 100% / 1.9 | 0 pp |
| Monje sin Rostro | 100% / 4.6 | 100% / 3.0 | 0 pp |
| Eco del Dragón | 81% / 6.9 | 100% / 4.3 | 19 pp |

Runs completas: aleatorio 47%, codicioso ~34%, planificador 99%. Tigre (antes Joven): 97–100% para todos los bots. Grulla (antes Anciano): aleatorio 37%, planificador 95%.

## Lectura frente a los criterios de éxito

- **Duración de 3 a 6 turnos:** no se cumple. Con 3 de Aliento y cartas de ~9 de daño (gōngbù), el jugador hace entre 20 y 27 de daño por turno. Los comunes (18 a 32 de Vida) caen en 1 o 2 turnos con buen juego.
- **Diferencia de 30 pp o más:** en combates aislados no se cumple, porque todos se ganan. En runs completas sí: 99% contra 47%. La habilidad pesa, pero la run es fácil.
- **Formas:** los bots casi nunca completan Xiǎo Hóng Quán (0,1 por combate). No les da tiempo: el combate termina antes.

## Palancas sugeridas (a decidir)

1. Multiplicar la Vida de los enemigos por 2 a 2,5. Es lo más directo para llegar a 3 a 6 turnos.
2. Bajar el bonus de puños en gōngbù de +3 a +2, porque Gōngbù Chōngquán ×3 domina.
3. Subir el daño de los enemigos entre un 30% y un 50%, para que defenderse y desviar importe más.

Todo vive en `assets/data/*.json`: ajustar y volver a correr el simulador.
