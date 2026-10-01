// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Long Breath';

  @override
  String get newRun => 'Nueva run';

  @override
  String get continueRun => 'Continuar run';

  @override
  String get styleTitle => 'Elegí tu camino';

  @override
  String get homeTagline =>
      'Subís como novicio. El camino se elige en la montaña.';

  @override
  String get shrineNode => 'Santuario';

  @override
  String get shrineTitle => 'Santuario de los animales';

  @override
  String get shrineHint =>
      'Dos espíritus te esperan. El camino que tomes tiñe tu túnica y cambia cómo peleás, hasta el final de la subida.';

  @override
  String get shrineConfirm => 'Tomar este camino';

  @override
  String styleSummary(int draw, int breath, int retain) {
    return 'Robás $draw · Aliento $breath · Retenés $retain';
  }

  @override
  String get life => 'Vida';

  @override
  String get structure => 'Estructura';

  @override
  String get guard => 'Guardia';

  @override
  String get breath => 'Aliento';

  @override
  String get deck => 'Mazo';

  @override
  String deckCount(int count) {
    return 'Mazo: $count';
  }

  @override
  String get fountain => 'Fuente de meditación';

  @override
  String fountainHeal(int amount) {
    return 'Curar $amount de Vida';
  }

  @override
  String get fountainRemove => 'Eliminar 1 carta del mazo';

  @override
  String fountainUpgrade(int amount) {
    return 'Mejorar 1 carta (+$amount)';
  }

  @override
  String get chooseCard => 'Elegí una carta';

  @override
  String get rewardTitle => 'Recompensa';

  @override
  String get rewardHint =>
      'Elegí 1 carta o salteá. Un mazo chico es más predecible.';

  @override
  String get skip => 'Saltear';

  @override
  String get breathe => 'Respirar';

  @override
  String get endTurn => 'Terminar turno';

  @override
  String get confirm => 'Confirmar';

  @override
  String get cancel => 'Cancelar';

  @override
  String retainHint(int count) {
    return 'Tocá hasta $count carta(s) para retener';
  }

  @override
  String get discardHint => 'Chillido: elegí 1 carta para descartar';

  @override
  String get tapAgain => 'Tocá de nuevo para jugar';

  @override
  String get victory => 'Victoria';

  @override
  String get defeat => 'Derrota';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get runWon => 'Llegaste a la cumbre';

  @override
  String get runLost => 'Caíste en la montaña';

  @override
  String get tryAgain => 'Empezar de nuevo';

  @override
  String get backHome => 'Volver al inicio';

  @override
  String get staggered => 'Desequilibrado';

  @override
  String get losesAction => 'Pierde su acción';

  @override
  String get deflect => '¡Desvío!';

  @override
  String get broken => '¡Desequilibrio!';

  @override
  String get playerBroken => 'Estructura rota';

  @override
  String turn(int n) {
    return 'Turno $n';
  }

  @override
  String get abandon => 'Abandonar run';

  @override
  String get typeFist => 'Puño';

  @override
  String get typePalm => 'Palma';

  @override
  String get typeKick => 'Patada';

  @override
  String get typeDefense => 'Defensa';

  @override
  String get typeTechnique => 'Técnica';

  @override
  String get heightHigh => 'alto';

  @override
  String get heightMid => 'medio';

  @override
  String get heightLow => 'bajo';

  @override
  String get rankElite => 'Élite';

  @override
  String get rankBoss => 'Guardián';

  @override
  String get fountainNode => 'Fuente';

  @override
  String intentAttack(String height) {
    return 'Ataque $height';
  }

  @override
  String intentNamedAttack(String name, String height) {
    return '$name ($height)';
  }

  @override
  String get intentCharge => 'Carga';

  @override
  String intentChargeDetail(int n) {
    return 'Próximo ataque +$n';
  }

  @override
  String get intentDiscard => 'Descarte';

  @override
  String intentDiscardDetail(int n) {
    return 'Descartás $n';
  }

  @override
  String get intentInterrupt => 'Interrumpe tus formas si no lo desviás';

  @override
  String get intentSameStance => 'Si terminás en esta postura: +4 daño, +2 E';

  @override
  String get countdown => 'turnos';

  @override
  String get staggeredDouble => 'Desequilibrado · daño ×2';

  @override
  String previewThen(String stance) {
    return 'después $stance';
  }

  @override
  String previewDamage(int n) {
    return '$n daño';
  }

  @override
  String previewStructure(int n) {
    return '$n E';
  }

  @override
  String previewCompletes(String name) {
    return '¡completa $name!';
  }

  @override
  String previewAdvances(String name) {
    return 'avanza $name';
  }

  @override
  String previewInterrupts(String name) {
    return '⚠ interrumpe $name';
  }

  @override
  String get stanceHintMabu =>
      'Puños y palmas +2 · E recibida ½ · patadas +1 costo';

  @override
  String get stanceHintGongbu => 'Puños +3 daño y +1 E · recibís +2 E';

  @override
  String get stanceHintXubu =>
      'Patadas −1 costo y +2 · desvío +1 Aliento · defensas −2';

  @override
  String changeStance(String breath) {
    return 'Cambiar postura · 1 $breath';
  }

  @override
  String get formsInterrupted => 'Formas interrumpidas';

  @override
  String get enemyPhase2 => '¡Segunda fase!';

  @override
  String get formCompleted => '¡Forma completa!';

  @override
  String effStance(String name) {
    return 'Pasás a $name';
  }

  @override
  String effDraw(int n) {
    return 'Robás $n';
  }

  @override
  String effBreath(int n) {
    return '+$n Aliento';
  }

  @override
  String effBonusStaggered(int n) {
    return '+$n si el enemigo está Desequilibrado';
  }

  @override
  String effDeflectDamage(int n) {
    return 'Si desviás, $n de daño';
  }

  @override
  String effDeflectStructure(int n) {
    return 'Si desviás, el enemigo pierde $n E extra';
  }

  @override
  String effStanceStructure(String name, int n) {
    return 'En $name, +$n E';
  }

  @override
  String get effClearGuard => 'Perdés toda tu Guardia';

  @override
  String effTurnStructure(int n) {
    return 'Este turno, todo daño a Estructura +$n';
  }

  @override
  String get effFirstTurn => 'Solo en el primer turno';

  @override
  String get effExhaust => 'Agotar';

  @override
  String get invalidCombatOver => 'El combate terminó';

  @override
  String get invalidMustDiscard => 'Elegí una carta para descartar';

  @override
  String get invalidNotInHand => 'La carta no está en la mano';

  @override
  String get invalidFirstTurnOnly => 'Solo en el primer turno';

  @override
  String get invalidNoBreath => 'Aliento insuficiente';

  @override
  String get invalidDingbuUsed => 'Ya cambiaste de postura este turno';

  @override
  String get invalidSameStance => 'Ya estás en esa postura';

  @override
  String get invalidBreatheUsed => 'Ya respiraste en este combate';

  @override
  String get invalidRetainTooMany => 'Retenés demasiadas cartas';

  @override
  String get invalidNoDiscard => 'No hay que descartar';

  @override
  String get partOfForm => 'Parte de una forma';

  @override
  String get tutStart => 'Empezar entrenamiento';

  @override
  String get tutSkipToRun => 'Ya sé jugar: nueva run';

  @override
  String get tutReplay => 'Repetir entrenamiento';

  @override
  String get tutSkip => 'Saltear';

  @override
  String get tutNext => 'Siguiente';

  @override
  String get tutMaster => 'Maestro';

  @override
  String get tutGo => '¡Vamos!';

  @override
  String get tutClimb => 'Empezar la subida';

  @override
  String get tutHome => 'Volver al inicio';

  @override
  String get tutWelcome =>
      'Bienvenido al patio de la escuela del Dragón Dormido. Antes de subir la montaña vas a practicar con el muñeco de madera. Yo te guío.';

  @override
  String get tutIntent =>
      'Este globo es lo que el muñeco va a hacer en su turno: un golpe ALTO (flecha arriba) de 4 de daño y 2 a tu Estructura (E). El enemigo siempre avisa antes de actuar.';

  @override
  String get tutEnemy =>
      'Su Vida (roja) y su Estructura (violeta). Llevá la Vida a 0 para ganar. Si le vaciás la Estructura, queda Desequilibrado: pierde su acción y recibe el doble de daño.';

  @override
  String get tutPlayer =>
      'Este sos vos: tu Vida, tu Estructura, tu postura actual (Caballo) y tu Guardia, el escudo de la derecha.';

  @override
  String get tutHand =>
      'Tu mano. El número de arriba a la izquierda de cada carta es su costo en Aliento. Tenés 3 por turno y lo que no gastes se pierde.';

  @override
  String get tutPlayFist =>
      'Tocá Puñetazo a fondo una vez para ver qué hace y otra vez para jugarla.';

  @override
  String get tutDefend =>
      'Ahora defendete. El muñeco va a pegar ALTO y Paso atrás da Guardia alta. Si la altura coincide y la Guardia alcanza, desviás el golpe. Jugala con dos toques.';

  @override
  String get tutKick =>
      'Quedaste en postura Vacía, donde las patadas cuestan 1 menos: Patada látigo ahora es gratis. Jugala.';

  @override
  String get tutForms =>
      'Puñetazo a fondo y Patada látigo son los dos primeros pasos del Pequeño Puño Rojo. Si completás una forma en orden, se desata un golpe grande. Las defensas no la interrumpen.';

  @override
  String get tutEndTurn =>
      'Tu Guardia está lista. Terminá el turno y mirá qué pasa.';

  @override
  String get tutDeflect =>
      '¡Desvío! No recibiste daño, el muñeco perdió Estructura y quedó Desequilibrado: pierde su acción y recibe el doble. Además, el desvío te da Aliento extra para este turno.';

  @override
  String get tutActions =>
      'Dos ayudas: Paso en T te cambia de postura por 1 de Aliento, una vez por turno. Respirar cambia toda tu mano, una vez por combate.';

  @override
  String get tutFree =>
      'Ahora rematalo vos. Mientras esté Desequilibrado, cada golpe cuenta doble.';

  @override
  String get tutDone =>
      '¡Bien hecho! En la montaña, después de cada combate sumás una carta a tu mazo. La Vida no se recupera sola, solo en la fuente. A mitad de camino, el Santuario te ofrece dos caminos. Y mirá siempre el globo antes de jugar.';

  @override
  String get blocked => 'Bloqueado';

  @override
  String get yourTurn => 'Tu turno';

  @override
  String endSummaryWon(int turns, int hp, int maxHp) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: 'En $turns turnos',
      one: 'En 1 turno',
    );
    return '$_temp0 · Vida $hp/$maxHp';
  }

  @override
  String endSummaryLost(String name, int hp) {
    return '$name resistió con $hp de Vida';
  }

  @override
  String get fightStart => '¡En guardia!';

  @override
  String get soundEffects => 'Efectos de sonido';

  @override
  String get music => 'Música';

  @override
  String get menuLearn => 'Aprender a jugar';

  @override
  String menuLearnProgress(int done, int total) {
    return '$done de $total lecciones';
  }

  @override
  String get menuStartHere => 'Empezá acá';

  @override
  String get difficultyTitle => '¿Cómo querés subir?';

  @override
  String get difficultySubtitle => 'Podés cambiarla en cada subida nueva.';

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyNormal => 'Normal';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String get difficultyShifu => 'Shifu';

  @override
  String get difficultyEasyDesc =>
      'Para conocer la montaña sin apuro. Más Vida y rivales más blandos.';

  @override
  String get difficultyNormalDesc => 'La subida tal como fue pensada.';

  @override
  String get difficultyHardDesc =>
      'Rivales más duros y una fuente que cura menos.';

  @override
  String get difficultyShifuDesc =>
      'Para maestros: menos Vida y cada error se paga.';

  @override
  String get difficultyLocked => 'Bloqueada';

  @override
  String get difficultyShifuLocked =>
      'Se desbloquea al ganar una subida en Difícil.';

  @override
  String difficultyStats(int hp, int heal, int enemy) {
    return 'Vida $hp · Fuente +$heal · Rivales $enemy%';
  }

  @override
  String scales(int count) {
    return 'Escamas $count · −$count por golpe';
  }

  @override
  String get scaleShed => '¡Escama arrancada!';

  @override
  String scalesLeft(int count) {
    return 'Le quedan $count';
  }

  @override
  String get menuClimb => 'La subida';

  @override
  String get menuClimbSubtitle => 'Montaña de las Mil Nubes';

  @override
  String get menuReplaceRunTitle => '¿Empezar una subida nueva?';

  @override
  String get menuReplaceRunBody =>
      'Tenés una subida guardada. Si empezás otra, se pierde.';

  @override
  String get menuReplaceRunOk => 'Empezar de nuevo';

  @override
  String get cancelAction => 'Cancelar';

  @override
  String get lessonsTitle => 'Aprender a jugar';

  @override
  String get lessonsIntro =>
      'Lecciones cortas con el maestro. Cada una se habilita al terminar la anterior y podés repetirlas cuando quieras.';

  @override
  String get lessonLocked => 'Completá la lección anterior';

  @override
  String lessonMinutes(int n) {
    return '$n min';
  }

  @override
  String lessonNumber(int n) {
    return 'Lección $n';
  }

  @override
  String get lessonDoneTitle => 'Lección completa';

  @override
  String get lessonNext => 'Siguiente lección';

  @override
  String get lessonBackToList => 'Volver a las lecciones';

  @override
  String get lessonRetry => 'Reintentar';

  @override
  String get lessonLostHint => 'No pasa nada: es práctica. Probá de nuevo.';

  @override
  String get lessonAllDone =>
      '¡Terminaste el entrenamiento! Ya podés subir la montaña.';

  @override
  String get lesStrikeTitle => 'Tu primer golpe';

  @override
  String get lesStrikeBlurb =>
      'La pantalla, las cartas, el Aliento y cómo atacar.';

  @override
  String get lesStrikeDone =>
      'Aprendiste a leer una carta, a usar tu Aliento y a atacar.';

  @override
  String get lesDefendTitle => 'El rival avisa';

  @override
  String get lesDefendBlurb =>
      'Leer el globo del rival, la Guardia, las alturas y el desvío.';

  @override
  String get lesDefendDone =>
      'Aprendiste a leer al rival y a defenderte a la altura justa.';

  @override
  String get lesStancesTitle => 'Posturas';

  @override
  String get lesStancesBlurb =>
      'Caballo, Arco y Vacía: preparar la postura antes de pegar.';

  @override
  String get lesStancesDone =>
      'Aprendiste a preparar tu postura antes de pegar.';

  @override
  String get lesStructureTitle => 'Estructura';

  @override
  String get lesStructureBlurb =>
      'Desequilibrar al rival y cuidar tu propio equilibrio.';

  @override
  String get lesStructureDone =>
      'Aprendiste a desequilibrar al rival para pegarle el doble.';

  @override
  String get lesFormsTitle => 'Formas';

  @override
  String get lesFormsBlurb =>
      'Encadenar pasos para un golpe extra, y Respirar.';

  @override
  String get lesFormsDone =>
      'Aprendiste a completar una forma y a usar Respirar.';

  @override
  String get lesClimbTitle => 'La subida';

  @override
  String get lesClimbBlurb =>
      'El mapa, las recompensas, la fuente y los caminos.';

  @override
  String get pauseTitle => 'Pausa';

  @override
  String get pauseResume => 'Seguir peleando';

  @override
  String get pauseHowTo => 'Cómo se juega';

  @override
  String get pauseToMenu => 'Volver al menú';

  @override
  String get pauseToMenuHint =>
      'La subida queda guardada: con \"Continuar\" volvés al mapa, antes de este combate.';

  @override
  String get pauseRestartLesson => 'Reiniciar lección';

  @override
  String get pauseExitLesson => 'Salir a las lecciones';

  @override
  String get mapHome => 'Menú principal';

  @override
  String get mapMore => 'Más opciones';

  @override
  String get abandonConfirmTitle => '¿Abandonar la subida?';

  @override
  String get abandonConfirmBody => 'Se pierde todo el progreso de esta subida.';

  @override
  String get illCardTitle => 'Cómo se lee una carta';

  @override
  String get illCost => 'Costo en Aliento';

  @override
  String get illType => 'Tipo';

  @override
  String get illName => 'Nombre';

  @override
  String get illStatsDamage => 'daño a la Vida';

  @override
  String get illStatsStructure => 'daño a la Estructura';

  @override
  String get nodeCombat => 'Combate';

  @override
  String get illStance => 'Postura en la que te deja, después de actuar';

  @override
  String get illGuard => 'Guardia y su altura';

  @override
  String get illIntentTitle => 'El globo del rival';

  @override
  String get illIntentAttack =>
      'Ataque: la flecha es la altura, el número el daño y E el daño a tu Estructura.';

  @override
  String get illIntentGuard =>
      'Se cubre: gana Guardia contra tus próximos golpes.';

  @override
  String get illIntentCharge =>
      'Carga: junta fuerza, su próximo golpe pega más.';

  @override
  String get illIntentDiscard => 'Chillido: te hace descartar cartas.';

  @override
  String get illHeightsTitle => 'Alturas';

  @override
  String get illHeightsSame =>
      'Misma altura: la Guardia absorbe todo. Si alcanza, desviás el golpe (化).';

  @override
  String get illHeightsOther =>
      'Otra altura: la Guardia absorbe solo la mitad.';

  @override
  String get illHigh => 'Alto';

  @override
  String get illMid => 'Medio';

  @override
  String get illLow => 'Bajo';

  @override
  String get illStancesTitle => 'Posturas';

  @override
  String get illStanceMabuPro =>
      'Puños y palmas +2. Recibís la mitad de daño a la Estructura.';

  @override
  String get illStanceMabuCon => 'Las patadas cuestan 1 más.';

  @override
  String get illStanceGongbuPro => 'Puños +3 de daño y +1 de Estructura.';

  @override
  String get illStanceGongbuCon => 'Recibís 2 más de daño a la Estructura.';

  @override
  String get illStanceXubuPro =>
      'Patadas: cuestan 1 menos y pegan +2. Desviar da +1 Aliento extra.';

  @override
  String get illStanceXubuCon => 'Las defensas dan 2 menos de Guardia.';

  @override
  String get illTurnTitle => 'Orden de un turno';

  @override
  String get illTurn1 =>
      'Tu Guardia vuelve a 0, robás cartas y recuperás el Aliento.';

  @override
  String get illTurn2 =>
      'Jugás cartas: tocá una para ver qué hace y otra vez para jugarla.';

  @override
  String get illTurn3 =>
      'Terminás el turno: las cartas que quedan se descartan.';

  @override
  String get illTurn4 =>
      'El rival hace lo que anunció en su globo y anuncia lo próximo.';

  @override
  String get illBrokenTitle => 'Desequilibrado';

  @override
  String get illBroken =>
      'Si la Estructura del rival llega a 0, pierde su próxima acción y recibe el doble de daño hasta el final de tu próximo turno. Si te pasa a vos, empezás el turno siguiente con 2 de Aliento menos.';

  @override
  String get illFormsTitle => 'Formas';

  @override
  String get illForms =>
      'Secuencias fijas de cartas. Si las jugás en orden, el último paso suma un golpe extra. Un ataque fuera de orden la interrumpe; las defensas y técnicas no.';

  @override
  String get lesStrike1 =>
      'Bienvenido. Esto es un combate por turnos: vos sos el de la izquierda y el muñeco de madera es tu rival. En tu turno jugás cartas; después el rival hace lo suyo. Te voy a explicar todo, paso a paso.';

  @override
  String get lesStrike2 =>
      'Esto sos vos. La barra verde es tu Vida: si llega a 0, perdés. La violeta es tu Estructura, tu equilibrio: más adelante vas a ver para qué sirve.';

  @override
  String get lesStrike3 =>
      'Este es el rival: su nombre, su Vida (roja) y su Estructura (violeta). Para ganar, llevá su Vida a 0.';

  @override
  String get lesStrike4 =>
      'Estas son tus cartas: tu mano. Cada turno robás 5 cartas nuevas de tu mazo.';

  @override
  String get lesStrike5 =>
      'Así se lee una carta. Arriba a la izquierda, lo que cuesta; a la derecha, su tipo. En el centro, el nombre en español y su nombre chino. Abajo, lo que hace: el rayo rojo es el daño a la Vida y el hexágono violeta, el daño a la Estructura. Si dice → y una postura, te deja en esa postura después de actuar.';

  @override
  String get lesStrike6 =>
      'Estos puntos son tu Aliento, la energía del turno. Tenés 3 y cada carta cuesta lo que dice su círculo. Lo que no gastes se pierde al terminar el turno.';

  @override
  String get lesStrike7 => 'Tocá Puñetazo firme UNA sola vez.';

  @override
  String get lesStrike8 =>
      'Esta es la vista previa: muestra exactamente lo que va a pasar, con todos los bonus ya sumados. Para jugar la carta, tocala otra vez.';

  @override
  String get lesStrike9 =>
      '¡Golpe! Le sacaste 7 de Vida (5 de la carta + 2 por estar en postura Caballo) y 2 de Estructura. Mirá cómo bajaron sus barras. Tu Aliento bajó de 3 a 2.';

  @override
  String get lesStrike10 =>
      'Ahora Empujón de palma: hace poco daño pero le saca mucha Estructura. Tocala dos veces.';

  @override
  String get lesStrike11 =>
      'Te queda 1 de Aliento: jugá el otro Puñetazo firme.';

  @override
  String get lesStrike12 =>
      'Te quedaste sin Aliento. Las cartas que no podés pagar se ven apagadas: Patada látigo cuesta 2 en postura Caballo. Las que no jugaste se descartan al terminar el turno.';

  @override
  String get lesStrike13 =>
      'Antes de terminar, mirá este globo: es lo que el rival va a hacer en su turno. La flecha → es la altura (MEDIA), 5 es el daño a tu Vida y E 2 el daño a tu Estructura. El rival siempre avisa antes de actuar.';

  @override
  String get lesStrike14 =>
      'Todavía no tenés defensas, así que te va a pegar. Tocá Terminar turno y mirá.';

  @override
  String get lesStrike15 =>
      'Te pegó: el número rojo fue el daño a tu Vida, 5. Tu Estructura bajó solo 1 porque en Caballo recibís la mitad. En la próxima lección aprendés a defenderte.';

  @override
  String get lesStrike16 =>
      'Empezó tu turno 2: robaste 5 cartas nuevas y tu Aliento volvió a 3. Así empieza cada turno.';

  @override
  String get lesStrike17 =>
      'Al muñeco le quedan 10 de Vida. Rematalo vos: elegí las cartas que quieras.';

  @override
  String get lesDefend1 =>
      'Lo más importante del juego: leer el globo del rival. La flecha es la ALTURA del golpe: ↑ alto, → medio, ↓ bajo. El número es el daño y E el daño a tu Estructura.';

  @override
  String get lesDefend2 =>
      'Las cartas de Defensa te dan Guardia: un escudo que absorbe el golpe del rival. Cada defensa protege una ALTURA. El muñeco va a pegar ALTO, y Bloqueo alto protege arriba con 9 de Guardia.';

  @override
  String get lesDefend3 => 'Jugala: dos toques.';

  @override
  String get lesDefend4 =>
      'Esta es tu Guardia: 9, alta. Si el golpe llega a la misma altura y tu Guardia alcanza para cubrirlo, lo DESVIÁS (化): no recibís nada, el rival pierde 3 de Estructura y ganás 1 de Aliento para tu próximo turno.';

  @override
  String get lesDefend5 =>
      'Con el Aliento que te queda, pegale: Puñetazo firme.';

  @override
  String get lesDefend6 => 'Terminá el turno y mirá.';

  @override
  String get lesDefend7 =>
      '¡Desvío! No recibiste daño y su Estructura bajó 3. Esto es pelear bien: mirar el globo y responder a la altura justa.';

  @override
  String get lesDefend8 =>
      'Tu Guardia volvió a 0: dura solo el turno del rival, así que hay que defenderse cada turno. Y fijate que tenés 4 de Aliento: +1 por el desvío.';

  @override
  String get lesDefend9 =>
      'Ahora viene MEDIO (→) con 6 de daño, y la única defensa que tenés es BAJA.';

  @override
  String get lesDefend10 =>
      'Jugá Bloqueo bajo igual, para ver qué pasa con la altura equivocada.';

  @override
  String get lesDefend11 => 'Terminá el turno.';

  @override
  String get lesDefend12 =>
      'Altura equivocada: la Guardia absorbió solo la mitad y recibiste 3 de daño. La altura importa tanto como el número.';

  @override
  String get lesDefend13 =>
      'Cada rival tiene una regla propia. Tocá el nombre del rival cuando quieras leerla.';

  @override
  String get lesDefend14 =>
      'Ahora viene BAJO (↓) y tenés Bloqueo bajo. Defendete bien y rematalo.';

  @override
  String get lesStances1 =>
      'Siempre estás en una de tres posturas: Caballo 马步, Arco 弓步 o Vacía 虚步. Ahora estás en Caballo. La postura en la que ESTÁS cambia cuánto pegan y cuánto cuestan tus cartas.';

  @override
  String get lesStances2 =>
      'Esto da cada postura. Lo podés volver a ver cuando quieras desde la pausa, en \"Cómo se juega\".';

  @override
  String get lesStances3 =>
      'Tocá Puñetazo a fondo una vez y mirá la vista previa.';

  @override
  String get lesStances4 =>
      'Fijate el daño: 8. La carta base hace 6, pero pegás desde Caballo, que suma +2 a los puños. Lo de abajo, → Arco, es la postura en la que te deja DESPUÉS de pegar. Jugala.';

  @override
  String get lesStances5 =>
      'Ahora estás en Arco: los puños pegan +3 y sacan +1 de Estructura. Esa ventaja no la usó la carta que te trajo: la aprovecha la PRÓXIMA.';

  @override
  String get lesStances6 =>
      'Mirá Puñetazo firme: antes marcaba 7 de daño y 2 de Estructura; ahora, 8 y 3. Los números de tus cartas siempre muestran lo que pegan desde la postura en la que estás. Pega desde Arco y después te deja en Caballo. Jugalo.';

  @override
  String get lesStances7 =>
      'Ese es el truco: una carta con → te prepara la siguiente. Antes de jugar, pensá el orden: primero la que te deja en la postura que la otra aprovecha.';

  @override
  String get lesStances8 =>
      'Si ninguna carta te deja en la postura que necesitás, Paso en T te cambia YA, por 1 de Aliento, una vez por turno. Las patadas rinden en Vacía: tocalo y elegí Vacía.';

  @override
  String get lesStances9 =>
      'En Vacía las patadas cuestan 1 menos y pegan +2: Patada látigo ahora cuesta 0 y hace 7. Jugala.';

  @override
  String get lesStances10 =>
      'Terminá el combate como quieras. Antes de cada carta, mirá en qué postura estás y en cuál te deja.';

  @override
  String get lesStructure1 =>
      'Este muñeco tiene poca Estructura: 8. Cada ataque tiene dos números: el rayo rojo es el daño a la Vida y el hexágono violeta, el daño a la Estructura. Si la Estructura del rival llega a 0, queda DESEQUILIBRADO.';

  @override
  String get lesStructure2 =>
      'Empujón de palma casi no hace daño, pero saca 4 de Estructura. Jugalo.';

  @override
  String get lesStructure3 => 'Otra vez: le quedan 4.';

  @override
  String get lesStructure4 =>
      '¡Desequilibrado! Mirá las estrellas. Pierde la acción que había anunciado y recibe el DOBLE de daño hasta el final de tu próximo turno.';

  @override
  String get lesStructure5 =>
      'Aprovechá: Puñetazo firme. En la vista previa el daño ya sale doble.';

  @override
  String get lesStructure6 =>
      'Su globo decía que se iba a cubrir (la Guardia del rival absorbe el daño a la Vida de tus golpes, pero no la Estructura). Ahora está apagado: esa acción la pierde.';

  @override
  String get lesStructure7 =>
      'Vos también tenés Estructura. Si el rival te la vacía, empezás tu próximo turno con 2 de Aliento menos. Defenderte bien la protege.';

  @override
  String get lesStructure8 => 'Terminá el turno.';

  @override
  String get lesStructure9 =>
      'Perdió su acción. Ahora anuncia Carga (el ícono del rayo): en su turno no te ataca, junta fuerza y su próximo golpe hará 4 más. Cuando veas una carga, preparate.';

  @override
  String get lesStructure10 =>
      'Sigue desequilibrado todo este turno: tus golpes cuentan doble. Terminalo.';

  @override
  String get lesForms1 =>
      'Una forma (套路) es una secuencia fija de cartas. Si las jugás en orden, al completar el último paso se suma un golpe extra. Esta es el Pequeño Puño Rojo: Puñetazo a fondo → Patada látigo → Bloqueo y contragolpe → Paso atrás.';

  @override
  String get lesForms2 => 'Primer paso: Puñetazo a fondo.';

  @override
  String get lesForms3 => 'Segundo paso: Patada látigo.';

  @override
  String get lesForms4 =>
      'Dos pasos marcados. El progreso no se pierde al terminar el turno: la forma te espera.';

  @override
  String get lesForms5 => 'Tocá Empujón de palma UNA vez, sin jugarla.';

  @override
  String get lesForms6 =>
      'Mirá el triángulo de aviso: un ataque (puño, palma o patada) que no es el próximo paso INTERRUMPE la forma y hay que empezar de nuevo. Las defensas y las técnicas nunca la interrumpen.';

  @override
  String get lesForms7 =>
      'El tercer paso cuesta 2 y te queda 1 de Aliento. Terminá el turno: la forma te espera.';

  @override
  String get lesForms8 =>
      'Tercer paso: Bloqueo y contragolpe, una defensa que además pega.';

  @override
  String get lesForms9 =>
      'Falta Paso atrás y no está en tu mano. Respirar descarta tu mano y roba la misma cantidad de cartas, gratis, una vez por combate. Usalo.';

  @override
  String get lesForms10 => '¡Ahí está! Último paso: Paso atrás.';

  @override
  String get lesForms11 =>
      '¡Forma completa! Además del efecto de la carta: 10 de daño, 5 de Estructura y robás 2 cartas.';

  @override
  String get lesForms12 => 'Terminá el combate.';

  @override
  String get lesClimbSlide1Title => 'La montaña';

  @override
  String get lesClimbSlide1 =>
      'La subida es un camino de combates por la montaña. En el mapa elegís a qué lugar ir; cuando el camino se abre en dos, decidís vos.';

  @override
  String get lesClimbSlide2Title => 'Los lugares del mapa';

  @override
  String get lesClimbSlide2 =>
      'Cada ícono es un lugar distinto: combates comunes, élites (más fuertes, mejor premio), el jefe al final, la fuente y el santuario.';

  @override
  String get lesClimbSlide3Title => 'Después de cada combate';

  @override
  String get lesClimbSlide3 =>
      'Elegís 1 de 3 cartas para sumar a tu mazo, o ninguna. Un mazo más grande no siempre es mejor: tus mejores cartas salen menos seguido.';

  @override
  String get lesClimbSlide4Title => 'Vida y Estructura';

  @override
  String get lesClimbSlide4 =>
      'Tu Vida NO se recupera sola entre combates: cuidala. En la fuente podés curarte, mejorar una carta o sacar una del mazo. La Estructura sí vuelve completa en cada combate.';

  @override
  String get lesClimbSlide5Title => 'El santuario';

  @override
  String get lesClimbSlide5 =>
      'A mitad de camino elegís un camino: Tigre, Serpiente o Grulla. El Tigre roba más cartas y tiene cartas propias, que solo te salen de recompensa si seguís su camino. La Serpiente y la Grulla pueden RETENER cartas al terminar el turno: esas cartas se guardan y además robás la mano completa.';

  @override
  String get lesClimbSlide6Title => '¡A subir!';

  @override
  String get lesClimbSlide6 =>
      'Si perdés toda la Vida, la subida termina y se empieza de nuevo. Mirá siempre el globo del rival antes de jugar. ¡Suerte!';
}
