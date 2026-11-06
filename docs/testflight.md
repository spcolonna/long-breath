# Long Breath · Ficha y subida a TestFlight

## 1. Ficha (texto para copiar)

**Idioma principal:** Español (México), que es el que App Store muestra en Latinoamérica.

| Campo | Límite | Texto |
|---|---|---|
| Nombre | 30 | `Long Breath` (si está ocupado: `Long Breath: Kung Fu`) |
| Subtítulo | 30 | `Roguelike de cartas de kung fu` |
| Palabras clave | 100 | `roguelike,cartas,deckbuilder,artes marciales,shaolin,estrategia,mazo,dragón,montaña,wuxia,tigre` |
| Texto promocional | 170 | `Subí la Montaña de las Mil Nubes con cartas de postura, respirá a tiempo y despertá al dragón de la cumbre. Cada subida es distinta.` |
| Categoría | — | Juegos → Cartas; secundaria: Juegos → Estrategia |
| Clasificación por edad | — | Violencia de dibujos animados o fantasía: *poco frecuente / leve*. El resto: no. Debería quedar en 9+. |
| URL de privacidad | — | https://github.com/spcolonna/long-breath/blob/main/docs/privacidad.md |
| Privacidad de la app | — | «No se recopilan datos» |
| Copyright | — | `2026 <tu nombre o el de tu estudio>` |

### Descripción

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

## 2. TestFlight: datos de prueba

**Qué probar** (va en cada build):

```
Primera build de prueba. Lo que más nos sirve:
• ¿Se entiende cómo jugar después de las lecciones?
• ¿Qué piso te costó más y dónde moriste?
• ¿Alguna carta, texto o animación se ve mal o confunde?
Para contarnos una subida, en la pantalla de resultado tocá «Copiar registro» y pegalo en el comentario de TestFlight (captura de pantalla → Compartir comentarios beta).
```

**Descripción beta** (solo para testers externos):

```
Roguelike de cartas de kung fu en español. Subís una montaña de tres etapas peleando con cartas de postura. No necesita cuenta ni conexión.
```

**Correo de comentarios:** spcolonna@gmail.com. **Inicio de sesión:** no hace falta (destildar «Se requiere inicio de sesión»).

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
