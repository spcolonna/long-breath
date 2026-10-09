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
  String styleTileStats(int draw, int retain) {
    return 'Robás $draw · Retenés $retain';
  }

  @override
  String get styleBenefitTiger =>
      'Golpe primero: el primer ataque de cada turno pega +3. Robás 5 cartas por turno, una más que los otros. Te salen las cartas del tigre y el Puño del Tigre.';

  @override
  String get styleBenefitSnake =>
      'Cadena: cada ataque pega +1 por cada ataque que ya jugaste en el turno. Retenés hasta 2 cartas. Te salen las cartas de la serpiente y el Puño de la Serpiente.';

  @override
  String get styleBenefitCrane =>
      'Paciencia: retenés hasta 3 cartas y las retenidas cuestan 1 menos el turno siguiente. Te salen las cartas de la grulla y el Puño de la Grulla.';

  @override
  String styleChipRetain(String hanzi, int count) {
    return '$hanzi Retenés $count';
  }

  @override
  String styleChipDraw(String hanzi, int count) {
    return '$hanzi Robás $count';
  }

  @override
  String get styleBenefitPick => 'Tocá un camino para ver qué te da.';

  @override
  String stanceDeltaDamage(String value) {
    return '$value daño';
  }

  @override
  String stanceDeltaStructure(String value) {
    return '$value Estructura';
  }

  @override
  String stanceDeltaGuard(String value) {
    return '$value guardia';
  }

  @override
  String stanceDeltaCost(String value) {
    return '$value costo';
  }

  @override
  String stanceDeltaBy(String changes, String stance) {
    return '$changes por $stance';
  }

  @override
  String formsMissingCards(String forms) {
    return 'Te faltan cartas para: $forms';
  }

  @override
  String effHeal(int n) {
    return 'Curás $n';
  }

  @override
  String effGuard(int n) {
    return '+$n Guardia';
  }

  @override
  String effFistBonus(int n) {
    return 'Tus puños pegan +$n el resto del combate';
  }

  @override
  String get formScroll => 'Forma · 套路';

  @override
  String get formScrollHint =>
      'Aprenderla reemplaza a la carta. Al jugar sus pasos en orden se dispara:';

  @override
  String formLearned(String name) {
    return '¡Aprendiste $name!';
  }

  @override
  String get formStepOwned => 'Ya tenés esta carta';

  @override
  String get formStepMissing => 'Te falta esta carta';

  @override
  String get fistBonusTitle => '¡Puños encadenados!';

  @override
  String fistBonusNow(int n) {
    return 'Tus puños pegan +$n todo el combate';
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
      'Elegí 1 carta o aprendé la forma, o salteá. Un mazo chico es más predecible.';

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
  String discipleN(int n) {
    return 'Discípulo nº $n';
  }

  @override
  String resultFellAt(String place) {
    return 'El aliento se te escapa en $place.';
  }

  @override
  String resultFellTo(String enemy) {
    return '$enemy queda de pie entre la niebla.';
  }

  @override
  String resultFellNo(int n) {
    return 'El Discípulo nº $n no volvió a la escuela.';
  }

  @override
  String resultSummitAt(String place) {
    return 'Subiste entre las nubes hasta $place.';
  }

  @override
  String resultSummitTo(String enemy) {
    return '$enemy se deshace en aliento dorado.';
  }

  @override
  String resultSummitNo(int n) {
    return 'El Discípulo nº $n llegó a la cumbre.';
  }

  @override
  String get tabletNovice => 'Novicio sin camino';

  @override
  String tabletPath(String style) {
    return 'Camino de $style';
  }

  @override
  String tabletFloor(int floor, int floors) {
    return 'Piso $floor de $floors';
  }

  @override
  String tabletStats(int hp, int deck) {
    return 'Vida máx. $hp · Mazo $deck';
  }

  @override
  String get loreNew => 'Pergamino nuevo';

  @override
  String get relayLine => 'La escuela envía a otro novicio.';

  @override
  String get relaySummit => 'La escuela pide que suba el siguiente.';

  @override
  String relayButton(int n) {
    return 'Subir como Discípulo nº $n';
  }

  @override
  String get backSchool => 'Volver a la escuela';

  @override
  String get tapToSkip => 'Tocá para seguir';

  @override
  String get registryTitle => 'Registro de la escuela';

  @override
  String get registryAscents => 'Subidas';

  @override
  String get registryScrolls => 'Pergaminos';

  @override
  String get registryEmpty => 'Todavía no terminó ninguna subida.';

  @override
  String registryFell(String enemy) {
    return 'Cayó ante $enemy';
  }

  @override
  String get registryFellEarly => 'Cayó en la montaña';

  @override
  String get registrySummit => 'Llegó a la cumbre';

  @override
  String registrySummary(int fallen, int summits) {
    return '$fallen caídos · $summits en la cumbre';
  }

  @override
  String get scrollSealed => 'Lacrado';

  @override
  String get prologueClimb => 'Subir';

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
  String waveOf(int index, int total) {
    return '$index de $total';
  }

  @override
  String get merchantWandering => 'Un mercader ambulante se cruza en el camino';

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
  String get enemyPhase3 => '¡Última fase!';

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
      'Dos ayudas: Paso en T te cambia de postura por 1 de Aliento, una vez por turno. Respirar cambia toda tu mano por 1 de Aliento, una vez por combate.';

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
  String get scalesRegrown => '¡Le crecen escamas!';

  @override
  String scalesNow(int count) {
    return 'Ahora tiene $count';
  }

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
  String mapFloor(int floor, int floors) {
    return 'Piso $floor de $floors';
  }

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
      'Secuencias fijas de cartas. Si las jugás en orden, el último paso dispara el efecto de la forma (un golpe, Aliento, curación…). Un ataque fuera de orden la interrumpe; las defensas y técnicas no. En la subida se aprenden como recompensa.';

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
      'Fijate el daño: 8 con un ▲ verde. La carta base hace 6, pero pegás desde Caballo, que suma +2 a los puños: el ▲ marca lo que te suma la postura y arriba dice \"+2 daño por Mǎbù\". Si una postura te resta, vas a ver un ▼ rojo. Lo de abajo, → Arco, es la postura en la que te deja DESPUÉS de pegar. Jugala.';

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
      'En Vacía las patadas cuestan 1 menos y pegan +2: Patada látigo ahora cuesta 0 (el costo se pone verde) y hace 7 ▲. Jugala.';

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
  String get lesForms8b =>
      'Te queda 1 de Aliento: no alcanza para Respirar y jugar Paso atrás. Terminá el turno; la forma te espera.';

  @override
  String get lesForms9 =>
      'Falta Paso atrás y no está en tu mano. Respirar descarta tu mano y roba la misma cantidad de cartas. Cuesta 1 de Aliento y se usa una vez por combate. Usalo.';

  @override
  String get lesForms10 => '¡Ahí está! Último paso: Paso atrás.';

  @override
  String get lesForms11 =>
      '¡Forma completa! Además del efecto de la carta: 14 de daño, 6 de Estructura y robás 2 cartas. En la subida, las formas se aprenden como recompensa al ganar combates.';

  @override
  String get lesForms12 => 'Terminá el combate.';

  @override
  String get lesClimbSlide1Title => 'La montaña';

  @override
  String get lesClimbSlide1 =>
      'La subida es un camino de combates por la montaña. En el mapa elegís a qué lugar ir; cuando el camino se abre, decidís vos. Cada subida arma un mapa distinto: deslizá para verlo entero.';

  @override
  String get lesClimbSlide2Title => 'Los lugares del mapa';

  @override
  String get lesClimbSlide2 =>
      'Cada ícono es un lugar distinto: combates comunes, élites (más fuertes, mejor premio), el jefe al final, la fuente, el santuario, los eventos y el maestro errante. Algunos combates traen un grupo: cuando cae uno, entra el siguiente.';

  @override
  String get lesClimbSlide3Title => 'Después de cada combate';

  @override
  String get lesClimbSlide3 =>
      'Elegís UNA cosa: 1 de 3 cartas para sumar a tu mazo, o aprender la forma que te ofrecen, o nada. Arrancás sin formas: cada una que aprendas queda para toda la subida y tiene su efecto propio (golpe, Aliento, curación…). Un mazo más grande no siempre es mejor: tus mejores cartas salen menos seguido.';

  @override
  String get lesClimbSlide4Title => 'Vida y Estructura';

  @override
  String get lesClimbSlide4 =>
      'Tu Vida NO se recupera sola entre combates: cuidala. En la fuente podés curarte, mejorar una carta o sacar una del mazo. La Estructura sí vuelve completa en cada combate.';

  @override
  String get lesClimbSlide5Title => 'El santuario';

  @override
  String get lesClimbSlide5 =>
      'A mitad de camino elegís un camino: Tigre, Serpiente o Grulla. El Tigre roba más cartas y tiene cartas propias y el Puño del Tigre, que solo te salen de recompensa si seguís su camino. La Serpiente y la Grulla pueden RETENER cartas al terminar el turno: esas cartas se guardan y además robás la mano completa. A la Serpiente se le ofrece además el Puño de la Serpiente.';

  @override
  String get lesClimbSlide6Title => '¡A subir!';

  @override
  String get lesClimbSlide6 =>
      'Si perdés toda la Vida, ese discípulo no vuelve: la escuela manda a otro novicio, que empieza de cero. Mirá siempre el globo del rival antes de jugar. ¡Suerte!';

  @override
  String get eventNode => 'Evento';

  @override
  String get combatNode => 'Camino';

  @override
  String get formMissingShort => 'Faltan cartas';

  @override
  String eventCost(int n) {
    return '−$n Vida';
  }

  @override
  String eventHeal(int n) {
    return '+$n Vida';
  }

  @override
  String eventMaxHp(int n) {
    return '+$n Vida máxima';
  }

  @override
  String get eventGainForm => 'aprendés una forma';

  @override
  String get eventGainTalisman => 'un talismán';

  @override
  String get eventGainRareTalisman => 'un talismán raro';

  @override
  String get eventGainCard => 'una carta nueva al azar';

  @override
  String get eventGainUpgrade => 'mejorás una carta al azar';

  @override
  String get eventGainLoseStarter => 'perdés una carta inicial al azar';

  @override
  String get eventNothing => 'sin cambios';

  @override
  String eventChance(int pct, String ok, String fail) {
    return '$pct%: $ok · si no: $fail';
  }

  @override
  String get eventCantPay => 'No te alcanza la Vida';

  @override
  String eventJade(int n) {
    return '+$n jade';
  }

  @override
  String eventJadeSpent(int n) {
    return '−$n jade';
  }

  @override
  String eventPrice(int n) {
    return 'Pagás $n jade';
  }

  @override
  String get eventContinue => 'Seguir subiendo';

  @override
  String eventResultTalisman(String name) {
    return 'Talismán: $name';
  }

  @override
  String eventResultCard(String name) {
    return 'Carta nueva: $name';
  }

  @override
  String eventResultForm(String name) {
    return 'Forma aprendida: $name';
  }

  @override
  String eventResultUpgrade(String name) {
    return 'Mejorada: $name';
  }

  @override
  String eventResultLost(String name) {
    return 'Se fue del mazo: $name';
  }

  @override
  String get eventLucky => '¡Salió bien!';

  @override
  String get eventUnlucky => 'Salió mal…';

  @override
  String get talismanPickTitle => 'Elegí un talismán';

  @override
  String get talismanPickHint =>
      'Vale para toda la subida y actúa solo. Los raros brillan en oro.';

  @override
  String get talismanRare => 'Raro';

  @override
  String talismanGained(String name) {
    return '¡$name!';
  }

  @override
  String get talismansTitle => 'Talismanes';

  @override
  String get talismansHint =>
      'Objetos que te acompañan toda la subida y actúan solos.';

  @override
  String get talismansNone =>
      'Todavía no tenés talismanes. Se consiguen en los eventos y al vencer al élite.';

  @override
  String talEffStance(String stance) {
    return 'Empezás cada combate en $stance.';
  }

  @override
  String talEffFirstBreath(int n) {
    return '+$n de Aliento en el primer turno de cada combate.';
  }

  @override
  String talEffStructure(int n) {
    return '+$n de Estructura en cada combate.';
  }

  @override
  String talEffEnemyHp(int n) {
    return 'El rival empieza cada combate con $n de Vida menos.';
  }

  @override
  String talEffEnemyStructure(int n) {
    return 'El rival empieza cada combate con $n de Estructura menos.';
  }

  @override
  String talEffMaxHp(int n) {
    return '+$n de Vida máxima.';
  }

  @override
  String talEffFountain(int n) {
    return 'La fuente cura $n más.';
  }

  @override
  String talEffWinHeal(int n) {
    return 'Ganar un combate cura $n.';
  }

  @override
  String talEffDeflect(int n) {
    return 'Cada desvío da +$n de Aliento.';
  }

  @override
  String talEffFormHeal(int n) {
    return 'Cada forma completa cura $n.';
  }

  @override
  String awEffFirstStrike(int n) {
    return 'El primer ataque del turno pega +$n.';
  }

  @override
  String awEffChain(int n) {
    return 'Cada ataque pega +$n por cada ataque anterior del turno.';
  }

  @override
  String awEffRetain(int n) {
    return 'Podés retener $n carta más.';
  }

  @override
  String awEffDraw(int n) {
    return 'Robás $n carta más por turno.';
  }

  @override
  String awEffRetainedDiscount(int n) {
    return 'Las cartas retenidas cuestan $n menos.';
  }

  @override
  String awEffFirstStrikeStructure(int n) {
    return 'El primer ataque del turno quita +$n de Estructura.';
  }

  @override
  String awEffFirstStrikeDiscount(int n) {
    return 'El primer ataque del turno cuesta $n menos.';
  }

  @override
  String awEffBreakDraw(int n) {
    return 'Al desequilibrar al rival, robás $n.';
  }

  @override
  String awEffChainStructure(int n) {
    return 'Cada ataque quita +$n de Estructura por cada ataque anterior del turno.';
  }

  @override
  String awEffThirdAttackDraw(int n) {
    return 'Al jugar el tercer ataque del turno, robás $n.';
  }

  @override
  String awEffRetainedDamage(int n) {
    return 'Los ataques retenidos pegan +$n.';
  }

  @override
  String awEffDeflectBreath(int n) {
    return 'Cada desvío da +$n de Aliento.';
  }

  @override
  String awEffGuardBonus(int n) {
    return 'Tus defensas dan +$n de Guardia.';
  }

  @override
  String get awakeningTitle => 'DESPERTAR';

  @override
  String get awakeningHint =>
      'El espíritu de tu camino te enseña algo más. Elegí uno: te acompaña el resto de la subida.';

  @override
  String get awakeningPick => 'Elegí un despertar';

  @override
  String get awakeningConfirm => 'Despertar y seguir subiendo';

  @override
  String get awakeningsLabel => 'Despertares';

  @override
  String get lesClimbSlideEventsTitle => 'Eventos y talismanes';

  @override
  String get lesClimbSlideEvents =>
      'El ícono rosa es un evento: una escena con una decisión (pagar Vida por algo, arriesgarse o ir a lo seguro). Ahí y al vencer al élite conseguís talismanes: objetos que actúan solos toda la subida, como empezar en Arco o curarte al ganar. Los ves arriba en el mapa y en el combate; tocalos para leerlos.';

  @override
  String get talismanTapHint =>
      'Tocá tus talismanes arriba para volver a ver qué hacen.';

  @override
  String get merchantNode => 'Mercader';

  @override
  String get masterNode => 'Maestro errante';

  @override
  String jadeGained(int n) {
    return '+$n de jade';
  }

  @override
  String get merchantTitle => 'Mercader de pergaminos';

  @override
  String get merchantHint =>
      'Cambiá jade por cartas, un talismán o un servicio. Lo que no gastes te queda para después.';

  @override
  String get merchantCards => 'Cartas';

  @override
  String get merchantTalisman => 'Talismán';

  @override
  String get merchantServices => 'Servicios';

  @override
  String get merchantRemove => 'Quitar 1 carta del mazo';

  @override
  String merchantUpgrade(int amount) {
    return 'Mejorar 1 carta (+$amount)';
  }

  @override
  String get merchantUsed => 'Ya usado';

  @override
  String merchantSale(int pct) {
    return 'Oferta −$pct%';
  }

  @override
  String merchantTea(int n) {
    return 'Té de jengibre (+$n Vida)';
  }

  @override
  String merchantTeaDetail(int n) {
    return 'Un tazón caliente que te devuelve $n de Vida. Una vez por visita.';
  }

  @override
  String get merchantNoJade => 'Te falta jade';

  @override
  String get merchantBought => '¡Comprado!';

  @override
  String get merchantPickRemove => 'Elegí la carta que querés quitar';

  @override
  String get merchantPickUpgrade => 'Elegí la carta que querés mejorar';

  @override
  String get merchantEmpty => 'No queda nada en venta.';

  @override
  String get masterTitle => 'Maestro errante';

  @override
  String get masterText =>
      'Un anciano practica en el sendero. Te ve llegar, sonríe y te ofrece una sola lección.';

  @override
  String get masterTeach => 'Aprender una forma';

  @override
  String get masterTeachHint => 'Tocá la que quieras aprender.';

  @override
  String masterUpgrade(int amount) {
    return 'Mejorar 1 carta (+$amount)';
  }

  @override
  String get masterUpgradeHint => 'Elegí la carta que el maestro va a pulir.';

  @override
  String get masterNoForms => 'Ya sabés todas las formas que te puede enseñar.';

  @override
  String get masterOr => 'o';

  @override
  String masterUpgraded(String name, int n) {
    return '¡$name +$n!';
  }

  @override
  String get lesClimbSlideShopTitle => 'Jade, mercader y maestro';

  @override
  String get lesClimbSlideShop =>
      'Cada combate ganado te da jade (玉); el élite, más. Cada tantos combates se cruza un mercader ambulante: ahí lo cambiás por cartas, un talismán, quitar una carta o mejorar una. El maestro errante no cobra: te enseña una forma o te mejora una carta, pero solo una de las dos.';

  @override
  String effChain(int n) {
    return '+$n de daño por cada ataque que ya jugaste en el turno';
  }

  @override
  String effRetained(int n) {
    return 'Si la retuviste, +$n de daño';
  }

  @override
  String effChainStructure(int n) {
    return '+$n de Estructura por cada ataque que ya jugaste en el turno';
  }

  @override
  String effRetainedStructure(int n) {
    return 'Si la retuviste, +$n de Estructura';
  }

  @override
  String styleChipFirstStrike(String hanzi, int n) {
    return '$hanzi Primer golpe +$n';
  }

  @override
  String styleChipChain(String hanzi, int n) {
    return '$hanzi Cadena +$n';
  }

  @override
  String styleChipRetained(String hanzi, int n) {
    return '$hanzi Retenidas −$n';
  }

  @override
  String get retainedTag => 'Retenida';

  @override
  String styleDeltaDamage(int n) {
    return '+$n daño por tu camino';
  }

  @override
  String retainedCheaper(int n) {
    return '−$n costo por retenida';
  }

  @override
  String get picosTitle => 'Picos';

  @override
  String get picosDesc =>
      'Normal con reglas extra. Cada Pico suma una más a las anteriores.';

  @override
  String get picosLocked => 'Ganá una subida en Normal para abrir el Pico 1.';

  @override
  String picoName(int n) {
    return 'Pico $n';
  }

  @override
  String picoNew(String rule) {
    return 'Nueva: $rule';
  }

  @override
  String get picoStackedOne => 'Más la regla del Pico 1.';

  @override
  String picoStacked(int n) {
    return 'Más las reglas de los Picos 1 a $n.';
  }

  @override
  String get picoLower => 'Bajar de Pico';

  @override
  String get picoHigher => 'Subir de Pico';

  @override
  String picoOpened(int n) {
    return '¡Se abrió el Pico $n!';
  }

  @override
  String get picoTop => 'Coronaste el último Pico.';

  @override
  String get picoRule1 => 'Élites +15% de Vida';

  @override
  String get picoRule2 => 'La fuente cura 5 menos';

  @override
  String get picoRule3 => 'El jefe +10% de Vida';

  @override
  String get picoRule4 => 'Rivales +5% de daño';

  @override
  String get picoRule5 => 'Empezás con 5 de Vida menos';

  @override
  String get picoRule6 => 'Rivales +10% de Estructura';

  @override
  String get picoRule7 => 'Rivales +5% de daño otra vez';

  @override
  String get picoRule8 => 'Élites y jefe +10% de Vida otra vez';

  @override
  String get picoRule9 => 'Rivales +5% de daño otra vez';

  @override
  String get picoRule10 => 'Todos los rivales +8% de Vida y +5% de Estructura';

  @override
  String wrathChip(int n) {
    return 'Despierto · +$n por golpe';
  }

  @override
  String get wrathCalmed => 'Se vuelve a dormir';

  @override
  String get parryChip => 'Abanico listo';

  @override
  String get parried => '¡Abanico!';

  @override
  String previewParried(int n) {
    return 'Abanico: 0 daño, te devuelve $n';
  }

  @override
  String parriedDetail(int n) {
    return 'Desvía tu golpe y te devuelve $n';
  }

  @override
  String stolenChip(int n) {
    return 'Te robó $n de jade';
  }

  @override
  String get intentFlee => 'Se escapa';

  @override
  String intentFleeDetail(int n) {
    return 'con $n de jade';
  }

  @override
  String get fledTitle => 'Se escapó';

  @override
  String endSummaryFled(String name, int n) {
    return '$name se escapó con $n de jade';
  }

  @override
  String jadeLost(int n) {
    return '−$n de jade · se lo llevó';
  }

  @override
  String get stageCleared => 'ETAPA SUPERADA';

  @override
  String get stageBreath => 'Respirás hondo antes de seguir';

  @override
  String get stageClimb => 'Seguir subiendo';

  @override
  String mapStage(int n, int total) {
    return 'Etapa $n de $total';
  }

  @override
  String thornsChip(int n) {
    return 'Espinas · −$n por carta';
  }

  @override
  String get thornsHurt => 'Espinas';

  @override
  String regenChip(int n) {
    return 'Se cura $n al actuar';
  }

  @override
  String guardOnly(String type, int n) {
    return 'Guardia $n · solo frena $type';
  }

  @override
  String guardOnlyChip(int n, String type) {
    return 'Guardia $n · solo $type';
  }

  @override
  String get guardBypassed => '¡Esquivaste su guardia!';

  @override
  String get guardBypassedDetail => 'Era otro tipo de golpe';

  @override
  String intentDrain(int n) {
    return 'Si no lo desviás: −$n Aliento';
  }

  @override
  String intentFreeze(int n) {
    return 'Si no lo desviás: robás $n menos';
  }

  @override
  String get breathDrained => 'Repique';

  @override
  String breathDrainedDetail(int n) {
    return '−$n Aliento el próximo turno';
  }

  @override
  String get handFrozen => 'Escarcha';

  @override
  String handFrozenDetail(int n) {
    return 'Robás $n carta menos';
  }

  @override
  String previewThorns(int n) {
    return 'Espinas: te quita $n';
  }

  @override
  String get previewGuardMiss => 'Esquiva su guardia';

  @override
  String get previewGuardHit => 'Su guardia lo frena';

  @override
  String get realmLabel => 'Reino';

  @override
  String breathTotal(int n) {
    return '$n de aliento';
  }

  @override
  String breathToNext(int n) {
    return '$n para el próximo reino';
  }

  @override
  String get breathMax => 'Reino más alto';

  @override
  String breathEarned(int n) {
    return '+$n de aliento para la escuela';
  }

  @override
  String get breathEarnedHint =>
      'Gane o caiga, cada discípulo deja su aliento.';

  @override
  String get realmUp => 'La escuela sube de reino';

  @override
  String get realmOpened => 'Se abrió';

  @override
  String get realmLocked => 'Cerrado';

  @override
  String realmNeeds(int n) {
    return 'Con $n de aliento';
  }

  @override
  String get registryTabCultivation => 'Cultivo';

  @override
  String get lootTitle => 'Botín';

  @override
  String get lootOpenHint => 'Tocá el cofre para abrirlo';

  @override
  String get lootKindCards => 'Pergaminos';

  @override
  String get lootKindJade => 'Bolsa de jade';

  @override
  String get lootKindLotus => 'Semillas de loto';

  @override
  String get lootKindUpgrade => 'Temple';

  @override
  String get lootKindTea => 'Té de montaña';

  @override
  String get lootKindTalisman => 'Talismán';

  @override
  String get lootHintCards =>
      'Sumá una técnica a tu mazo o aprendé la forma. Un mazo chico es más predecible.';

  @override
  String lootHintJade(int n) {
    return '$n de jade para el mercader del camino.';
  }

  @override
  String lootHintLotus(int n) {
    return '$n semillas que vuelven con vos a la escuela, aunque caigas. Abren puntos del árbol de meridianos.';
  }

  @override
  String lootHintUpgrade(int n) {
    return 'Elegí una carta: gana +$n para toda la subida.';
  }

  @override
  String lootHintTea(int n) {
    return 'Recuperás $n de Vida.';
  }

  @override
  String get lootHintTalisman => 'Elegí uno: vale para toda la subida.';

  @override
  String get lootTake => 'Tomar';

  @override
  String get lootDrink => 'Beber';

  @override
  String get lootTemper => 'Templar';

  @override
  String lootReroll(int n) {
    return 'Volver a tirar ($n)';
  }

  @override
  String lotusGained(int n) {
    return '+$n de loto';
  }

  @override
  String get talismanStartTitle => 'Don de la escuela';

  @override
  String get talismanStartHint =>
      'Los meridianos te acompañan: elegí un talismán para esta subida.';

  @override
  String get stageLootTitle => 'Botín de la etapa';

  @override
  String get stageLootWins => 'Combates ganados';

  @override
  String get stageLootJade => 'Jade ganado';

  @override
  String get stageLootLotus => 'Semillas de loto';

  @override
  String get meridiansTitle => 'Árbol de meridianos';

  @override
  String get meridiansButton => 'Meridianos';

  @override
  String get meridiansHint =>
      'Cada subida trae semillas de loto, ganes o caigas. Con ellas la escuela abre puntos que ayudan a todos los discípulos que vienen.';

  @override
  String meridiansBalance(int n) {
    return '$n semillas';
  }

  @override
  String get meridiansRealmGifts => 'Dones del reino';

  @override
  String get meridiansRealmGiftsHint =>
      'Cada reino del cultivo regala un don, sin gastar loto.';

  @override
  String get meridianBranchBody => 'Cuerpo';

  @override
  String get meridianBranchSpirit => 'Espíritu';

  @override
  String get meridianBranchTechnique => 'Técnica';

  @override
  String meridianOpen(int n) {
    return 'Abrir punto · $n';
  }

  @override
  String get meridianOpened => 'Abierto';

  @override
  String meridianNeedsRealm(String realm) {
    return 'Requiere $realm';
  }

  @override
  String get meridianNeedsPrev => 'Primero abrí el punto anterior';

  @override
  String meridianNeedsLotus(int n) {
    return 'Faltan $n semillas';
  }

  @override
  String get meridianNextRun => 'Vale desde la próxima subida.';

  @override
  String bonusMaxHp(int n) {
    return '+$n de Vida máxima';
  }

  @override
  String bonusFountainHeal(int n) {
    return 'La fuente cura $n más';
  }

  @override
  String bonusWinHeal(int n) {
    return 'Curás $n al ganar cada combate';
  }

  @override
  String bonusStructure(int n) {
    return '+$n de Estructura en cada combate';
  }

  @override
  String bonusStartJade(int n) {
    return 'Empezás con $n de jade';
  }

  @override
  String bonusUpgradedStarters(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n cartas iniciales empiezan templadas',
      one: 'Una carta inicial empieza templada',
    );
    return '$_temp0';
  }

  @override
  String get bonusStartTalisman => 'Elegís un talismán al empezar';

  @override
  String bonusMerchantDiscount(int n) {
    return 'El mercader cobra $n% menos';
  }

  @override
  String bonusRewardChoices(int n) {
    return '+$n carta para elegir en los pergaminos';
  }

  @override
  String bonusTalismanChoices(int n) {
    return '+$n talismán para elegir en el élite';
  }

  @override
  String bonusRerolls(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Podés volver a tirar los pergaminos $n veces por subida',
      one: 'Podés volver a tirar los pergaminos una vez por subida',
    );
    return '$_temp0';
  }

  @override
  String bonusLotusPct(int n) {
    return '+$n% de semillas de loto';
  }

  @override
  String bonusFirstTurnBreath(int n) {
    return '+$n de Aliento en el primer turno';
  }

  @override
  String bonusBreathes(int n) {
    return '+$n Respirar por combate';
  }

  @override
  String resultLotus(int n, int total) {
    return '+$n semillas de loto · la escuela tiene $total';
  }

  @override
  String get resultToMeridians => 'Abrir meridianos';

  @override
  String get cinematicSkip => 'Tocá para saltar';

  @override
  String get introBoss => 'Guardián de la etapa';

  @override
  String get introElite => 'Élite del camino';
}
