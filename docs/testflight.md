# Long Breath · Ficha y subida a TestFlight

## 1. Ficha en inglés (idioma principal)

**Idioma principal:** English (U.S.).

> ⚠️ El juego hoy está solo en español. La descripción lo aclara al final para que nadie lo baje esperando inglés; la App Store además muestra «Idiomas: español».

| Campo | Límite | Texto |
|---|---|---|
| Name | 30 | `Long Breath` (si está ocupado: `Long Breath: Kung Fu`) |
| Subtitle | 30 | `Kung fu roguelike card game` |
| Keywords | 100 | `roguelike,deckbuilder,cards,martial arts,shaolin,strategy,deck,dragon,mountain,wuxia,tiger,crane` |
| Promotional Text | 170 | `Climb the Mountain of a Thousand Clouds with stance cards, breathe at the right moment and wake the dragon at the summit. Every climb is different.` |
| Category | — | Games → Card; secundaria: Games → Strategy |
| Age Rating | — | Cartoon or Fantasy Violence: *Infrequent/Mild*. El resto: None. Debería quedar en 9+. |
| Privacy Policy URL | — | https://github.com/spcolonna/long-breath/blob/main/docs/privacidad.md |
| App Privacy | — | «Data Not Collected» |
| Copyright | — | `2026 <tu nombre o el de tu estudio>` |

### Description

```
At the summit of the Mountain of a Thousand Clouds sleeps a dragon. Its breath becomes the clouds. As a disciple of the Sleeping Dragon school, your final trial is to climb it alone, fighting all the way, until you wake it.

Long Breath is a kung fu roguelike card game. Every card is a stance: Horse roots you, Bow drives forward, Empty lets the kick fly. Chain stances to complete forms, read each opponent's intent and set the height of your guard before the blow lands.

• Three stages of eleven floors each, and a different path on every climb.
• Breathing is a choice: you recover breath and draw cards, but your opponent won't wait.
• At the Shrine of the Animals, two spirits of Wǔ Xíng Quán appear and choose you: Tiger, Snake or Crane changes the way you fight.
• Weapons, talismans, meridians and disciples who inherit what you learned.
• Short lessons that teach everything from scratch.
• Three save slots, each with its own difficulty.
• No ads, no in-app purchases, no internet needed.

Whoever controls the breath controls the fight.

Currently available in Spanish only.
```

### Localización opcional en español (México)

Si querés que en Latinoamérica la ficha se vea en español, agregá la localización «Spanish (Mexico)» en App Store Connect y usá esto:

| Campo | Texto |
|---|---|
| Subtítulo | `Roguelike de cartas de kung fu` |
| Palabras clave | `roguelike,cartas,deckbuilder,artes marciales,shaolin,estrategia,mazo,dragón,montaña,wuxia,tigre` |
| Texto promocional | `Subí la Montaña de las Mil Nubes con cartas de postura, respirá a tiempo y despertá al dragón de la cumbre. Cada subida es distinta.` |

```
En la cumbre de la Montaña de las Mil Nubes duerme un dragón. Su respiración forma las nubes. Como discípulo de la escuela del Dragón Dormido, tu prueba final es subirla solo, combatiendo, hasta despertarlo.

Long Breath es un roguelike de cartas de kung fu. Cada carta es una postura: el Caballo te planta, el Arco empuja, la Vacía suelta la patada. Encadená posturas para completar formas, leé la intención de cada rival y elegí la altura de tu guardia antes de que llegue el golpe.

• Tres etapas, once pisos cada una, y un camino distinto en cada subida.
• Respirar es una decisión: recuperás aliento y robás cartas, pero el rival no espera.
• En el Santuario de los animales, dos espíritus del Wǔ Xíng Quán se presentan y te eligen: Tigre, Serpiente o Grulla cambian cómo peleás.
• Armas, talismanes, meridianos y discípulos que heredan lo que aprendiste.
• Lecciones cortas que enseñan todo desde cero.
• Tres partidas en paralelo, cada una con su dificultad.
• Sin anuncios, sin compras dentro de la app, sin conexión.

Quien controla la respiración controla el combate.
```

## 2. TestFlight: Test Information (en inglés)

**What to Test** (va en cada build):

```
First test build. What helps us most:
• Is it clear how to play after the lessons?
• Which floor was hardest, and where did you die?
• Does any card, text or animation look wrong or confusing?
To share a climb, tap "Copiar registro" on the result screen and paste it into your TestFlight feedback (take a screenshot → Share Beta Feedback).
Note: the game is in Spanish for now.
```

**Beta App Description** (solo para testers externos):

```
A kung fu roguelike card game (in Spanish). Climb a three-stage mountain fighting with stance cards. No account or internet needed.
```

**Feedback Email:** spcolonna@gmail.com. **Sign-in:** no hace falta (destildar «Sign-in required»).

## 3. Paso a paso (ya tenés cuenta y certificados)

### Una sola vez

1. **Registrar el bundle ID.** Abrí `ios/Runner.xcworkspace` en Xcode → Runner → *Signing & Capabilities*. Con el equipo `RZGQPAGH53` y *Automatically manage signing*, Xcode registra `com.oraki.longBreath`. Si no aparece, crealo a mano en developer.apple.com → Identifiers.
2. **Crear la app.** App Store Connect → Apps → **+** → Nueva app. Plataforma iOS; nombre, idioma y bundle ID como en la ficha; SKU `longbreath-ios`; acceso completo.
3. **Ícono:** pasame el PNG y corro `python3 tool/make_app_icon.py icon <png>`. Sin ícono propio la build sube igual, con el ícono de Flutter.

### Cada build

4. **Subir el número de build.** En `pubspec.yaml`, `version: 0.1.0+1`: el número después del `+` tiene que crecer en cada subida (`+2`, `+3`…).
5. **Compilar:**

   ```bash
   flutter build ipa --release
   ```

   Deja `build/ios/ipa/long_breath.ipa`. Si falla la firma, abrí `build/ios/archive/Runner.xcarchive` (Xcode → Organizer) y usá **Distribute App → App Store Connect → Upload**, que arregla la firma con tu sesión.
6. **Subir** el `.ipa` con la app **Transporter** (arrastrar y *Entregar*), o desde el Organizer como en el paso anterior.
7. **Esperar el procesado** (10–30 min; llega un correo). No pregunta por cifrado porque ya está declarado en el `Info.plist`.
8. **Borrar `build/`** después de subir (hay poco disco).

### Probar

9. **Testers internos** (vos y hasta 100 personas con acceso a tu App Store Connect): TestFlight → Pruebas internas → **+** → agregar personas → elegir la build. Sin revisión: instalan con la app TestFlight al rato.
10. **Testers externos** (hasta 10.000, por correo o enlace público): TestFlight → Pruebas externas → nuevo grupo → agregar la build. La primera vez pide la información de la sección 2 y pasa por la **revisión beta de Apple** (normalmente menos de un día). Las builds siguientes de la misma versión suelen pasar sin revisión.
11. La build vence a los **90 días**.
