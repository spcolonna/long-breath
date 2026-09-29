# Long Breath 龙

Roguelike de cartas de kung fu para móvil (Flutter, iOS y Android). El protagonista cae en la cueva del dragón y asciende combatiendo con posturas (步型), técnicas y formas (套路).

Este repositorio contiene el **MVP de combate**. El diseño completo está en [docs/diseno-mvp-combate.md](docs/diseno-mvp-combate.md).

## Estructura

```
lib/domain/          motor de combate y run (Dart puro, sin Flutter)
lib/infrastructure/  carga de JSON y guardado local
lib/delivery/        pantallas, widgets y providers (Riverpod + go_router)
assets/data/         balance del juego en JSON
tool/simulate.dart   simulador de balance sin interfaz
test/                tests del motor
```

## Comandos

```bash
flutter test                                   # tests
dart run tool/simulate.dart --n 2000           # simulador de balance
flutter run                                    # app
```

## Estado del MVP

- Motor de combate completo con tests (`test/domain`).
- Run de 7 nodos con recompensas, fuente de meditación y guardado local.
- Interfaz vertical: intención, posturas, formas, mano en abanico con vista previa de valores finales, retener, Dīngbù y Respirar.
- Simulador con tres bots. Los resultados y las palancas de balance están en [docs/balance.md](docs/balance.md).
- Interpretaciones de reglas ambiguas: [docs/reglas-implementadas.md](docs/reglas-implementadas.md).
