# Kit de feel

Todo lo que se agrega al juego tiene que salir pulido desde el primer commit. Esta es la caja de herramientas y la lista de control. Si una pieza no existe, se crea acá (en `lib/delivery/widgets/` o `lib/delivery/feel.dart`) y se suma a esta lista; no se hace una versión privada dentro de una pantalla.

## Lista de control para cada pantalla o mecánica nueva

1. **Todo lo que se toca se hunde.** Usá `Press` alrededor del `GestureDetector`, o un botón de Material, que ya se hunde por el tema. Nada de `InkWell` dentro de `Press`: el ripple se duplica.
2. **Cada toque suena y vibra.** Vibrá con `Haptics.*` (respeta Opciones), nunca con `HapticFeedback` directo. El sonido va por `ref.read(audioProvider).play(Sfx.…)`. Si no existe el id, se agrega al `enum Sfx` aunque todavía no haya archivo.
3. **Nada aparece de golpe.** Las listas y las opciones entran con `StaggerIn`. Los números que cambian, con `CountUp` (o `HpCount` y `JadeCount`). Los premios y gastos, con `PopText` y, si son importantes, con `Bounce` + `InkBurst`.
4. **Los momentos grandes tienen pausa.** Un golpe fuerte lleva `Shake` + `ScreenFlash`. Una carta que se quema o mejora va con `DeckPickScreen` o `DeckGrid(pickFx:)`. Para una entrada especial, un `fx` en `_route` de `app.dart` (ver `route_fx.dart`).
5. **Los lugares del camino usan el kit de nodo** (`node_kit.dart`):
   - `NodeBackdrop` para el fondo pintado de la etapa;
   - `ChoiceTile` para las opciones;
   - `DeckPickScreen` para elegir una carta.

   Nada de `AppBar` pelado.
6. **Movimiento reducido.** Preguntá con `calm(context)`:
   - con movimiento reducido no hay sacudidas, partículas, giros ni transiciones especiales;
   - los loops decorativos (respirar, flotar, niebla) arrancan con `loopUnlessCalm` en `didChangeDependencies`, nunca con `..repeat()`;
   - un fundido corto sí está bien.
7. **Rendimiento.**
   - Ningún `ColorFiltered`, `Opacity` o blur que quede puesto cuando no hace nada: solo mientras hace efecto.
   - Nada de `MaskFilter.blur` por cuadro: el borde suave sale de un `RadialGradient`.
   - Lo que se anima siempre va dentro de un `RepaintBoundary`.
   - El arte en `.webp`, al tamaño en que se muestra (`cacheWidth`).
8. **Sin arte nuevo, si se puede.** Nubes, niebla, partículas y sellos se pintan por código (`cloud_drift.dart`, `juice.dart`, `InkSeal`).
9. **Probar en el simulador** con el movimiento completo y reducido, antes del commit.

## Piezas

| Pieza | Archivo | Para qué |
|---|---|---|
| `Press`, `pressedContent` | `widgets/press.dart` | Hundir lo que se toca; el tema lo aplica a los botones |
| `StaggerIn` | `widgets/press.dart` | Entrar de a uno |
| `CountUp`, `HpCount`, `JadeCount` | `press.dart`, `hp_count.dart`, `jade.dart` | Cifras que cuentan |
| `Shake`, `Bounce`, `PopText`, `InkBurst`, `ArtBurst`, `ScreenFlash`, `TrailBar` | `widgets/juice.dart` | Golpes, premios, estallidos, barras con estela |
| `DeckGrid(pickFx:)` | `widgets/deck_sheet.dart` | La carta se quema o se ilumina |
| `NodeBackdrop`, `ChoiceTile`, `DeckPickScreen` | `widgets/node_kit.dart` | Pantallas de lugares del camino |
| `SceneBackdrop`, `KenBurns`, `StageScene` | `widgets/` | Fondos pintados que respiran |
| `CloudDrift` | `widgets/cloud_drift.dart` | Nubes en dos capas (parallax), sin arte |
| `brushSlash`, `scrollUnroll`, `inkReveal` | `route_fx.dart`, `ink_reveal.dart` | Entradas de pantalla especiales |
| `Cinematic`, `StageIntro`, `FoeIntro` | `widgets/cinematic.dart` | Presentaciones |
| `InkSeal`, `NpcPortrait`, `FormScroll` | `widgets/` | Sello, retrato que respira, pergamino de forma |
| `Haptics`, `calm`, `loopUnlessCalm`, `feelProvider` | `delivery/feel.dart` | Vibración y movimiento según Opciones |
| `OptionsButton` | `widgets/options_sheet.dart` | Sonido, música, vibración y movimiento |
