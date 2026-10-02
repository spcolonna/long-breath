import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'Long Breath'**
  String get appTitle;

  /// No description provided for @newRun.
  ///
  /// In es, this message translates to:
  /// **'Nueva run'**
  String get newRun;

  /// No description provided for @continueRun.
  ///
  /// In es, this message translates to:
  /// **'Continuar run'**
  String get continueRun;

  /// No description provided for @styleTitle.
  ///
  /// In es, this message translates to:
  /// **'Elegí tu camino'**
  String get styleTitle;

  /// No description provided for @homeTagline.
  ///
  /// In es, this message translates to:
  /// **'Subís como novicio. El camino se elige en la montaña.'**
  String get homeTagline;

  /// No description provided for @shrineNode.
  ///
  /// In es, this message translates to:
  /// **'Santuario'**
  String get shrineNode;

  /// No description provided for @shrineTitle.
  ///
  /// In es, this message translates to:
  /// **'Santuario de los animales'**
  String get shrineTitle;

  /// No description provided for @shrineHint.
  ///
  /// In es, this message translates to:
  /// **'Dos espíritus te esperan. El camino que tomes tiñe tu túnica y cambia cómo peleás, hasta el final de la subida.'**
  String get shrineHint;

  /// No description provided for @shrineConfirm.
  ///
  /// In es, this message translates to:
  /// **'Tomar este camino'**
  String get shrineConfirm;

  /// No description provided for @styleSummary.
  ///
  /// In es, this message translates to:
  /// **'Robás {draw} · Aliento {breath} · Retenés {retain}'**
  String styleSummary(int draw, int breath, int retain);

  /// No description provided for @styleTileStats.
  ///
  /// In es, this message translates to:
  /// **'Robás {draw} · Retenés {retain}'**
  String styleTileStats(int draw, int retain);

  /// No description provided for @styleBenefitTiger.
  ///
  /// In es, this message translates to:
  /// **'Robás 5 cartas por turno, una más que los otros caminos. Te salen las cartas del tigre y el Puño del Tigre.'**
  String get styleBenefitTiger;

  /// No description provided for @styleBenefitSnake.
  ///
  /// In es, this message translates to:
  /// **'Al terminar el turno retenés hasta 2 cartas y igual robás la mano completa. Te sale el Puño de la Serpiente.'**
  String get styleBenefitSnake;

  /// No description provided for @styleBenefitCrane.
  ///
  /// In es, this message translates to:
  /// **'Al terminar el turno retenés hasta 3 cartas y igual robás la mano completa: guardás todo para el momento justo.'**
  String get styleBenefitCrane;

  /// No description provided for @styleChipRetain.
  ///
  /// In es, this message translates to:
  /// **'{hanzi} Retenés {count}'**
  String styleChipRetain(String hanzi, int count);

  /// No description provided for @styleChipDraw.
  ///
  /// In es, this message translates to:
  /// **'{hanzi} Robás {count}'**
  String styleChipDraw(String hanzi, int count);

  /// No description provided for @styleBenefitPick.
  ///
  /// In es, this message translates to:
  /// **'Tocá un camino para ver qué te da.'**
  String get styleBenefitPick;

  /// No description provided for @stanceDeltaDamage.
  ///
  /// In es, this message translates to:
  /// **'{value} daño'**
  String stanceDeltaDamage(String value);

  /// No description provided for @stanceDeltaStructure.
  ///
  /// In es, this message translates to:
  /// **'{value} Estructura'**
  String stanceDeltaStructure(String value);

  /// No description provided for @stanceDeltaGuard.
  ///
  /// In es, this message translates to:
  /// **'{value} guardia'**
  String stanceDeltaGuard(String value);

  /// No description provided for @stanceDeltaCost.
  ///
  /// In es, this message translates to:
  /// **'{value} costo'**
  String stanceDeltaCost(String value);

  /// No description provided for @stanceDeltaBy.
  ///
  /// In es, this message translates to:
  /// **'{changes} por {stance}'**
  String stanceDeltaBy(String changes, String stance);

  /// No description provided for @life.
  ///
  /// In es, this message translates to:
  /// **'Vida'**
  String get life;

  /// No description provided for @structure.
  ///
  /// In es, this message translates to:
  /// **'Estructura'**
  String get structure;

  /// No description provided for @guard.
  ///
  /// In es, this message translates to:
  /// **'Guardia'**
  String get guard;

  /// No description provided for @breath.
  ///
  /// In es, this message translates to:
  /// **'Aliento'**
  String get breath;

  /// No description provided for @deck.
  ///
  /// In es, this message translates to:
  /// **'Mazo'**
  String get deck;

  /// No description provided for @deckCount.
  ///
  /// In es, this message translates to:
  /// **'Mazo: {count}'**
  String deckCount(int count);

  /// No description provided for @fountain.
  ///
  /// In es, this message translates to:
  /// **'Fuente de meditación'**
  String get fountain;

  /// No description provided for @fountainHeal.
  ///
  /// In es, this message translates to:
  /// **'Curar {amount} de Vida'**
  String fountainHeal(int amount);

  /// No description provided for @fountainRemove.
  ///
  /// In es, this message translates to:
  /// **'Eliminar 1 carta del mazo'**
  String get fountainRemove;

  /// No description provided for @fountainUpgrade.
  ///
  /// In es, this message translates to:
  /// **'Mejorar 1 carta (+{amount})'**
  String fountainUpgrade(int amount);

  /// No description provided for @chooseCard.
  ///
  /// In es, this message translates to:
  /// **'Elegí una carta'**
  String get chooseCard;

  /// No description provided for @rewardTitle.
  ///
  /// In es, this message translates to:
  /// **'Recompensa'**
  String get rewardTitle;

  /// No description provided for @rewardHint.
  ///
  /// In es, this message translates to:
  /// **'Elegí 1 carta o salteá. Un mazo chico es más predecible.'**
  String get rewardHint;

  /// No description provided for @skip.
  ///
  /// In es, this message translates to:
  /// **'Saltear'**
  String get skip;

  /// No description provided for @breathe.
  ///
  /// In es, this message translates to:
  /// **'Respirar'**
  String get breathe;

  /// No description provided for @endTurn.
  ///
  /// In es, this message translates to:
  /// **'Terminar turno'**
  String get endTurn;

  /// No description provided for @confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @retainHint.
  ///
  /// In es, this message translates to:
  /// **'Tocá hasta {count} carta(s) para retener'**
  String retainHint(int count);

  /// No description provided for @discardHint.
  ///
  /// In es, this message translates to:
  /// **'Chillido: elegí 1 carta para descartar'**
  String get discardHint;

  /// No description provided for @tapAgain.
  ///
  /// In es, this message translates to:
  /// **'Tocá de nuevo para jugar'**
  String get tapAgain;

  /// No description provided for @victory.
  ///
  /// In es, this message translates to:
  /// **'Victoria'**
  String get victory;

  /// No description provided for @defeat.
  ///
  /// In es, this message translates to:
  /// **'Derrota'**
  String get defeat;

  /// No description provided for @continueLabel.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continueLabel;

  /// No description provided for @runWon.
  ///
  /// In es, this message translates to:
  /// **'Llegaste a la cumbre'**
  String get runWon;

  /// No description provided for @runLost.
  ///
  /// In es, this message translates to:
  /// **'Caíste en la montaña'**
  String get runLost;

  /// No description provided for @tryAgain.
  ///
  /// In es, this message translates to:
  /// **'Empezar de nuevo'**
  String get tryAgain;

  /// No description provided for @backHome.
  ///
  /// In es, this message translates to:
  /// **'Volver al inicio'**
  String get backHome;

  /// No description provided for @staggered.
  ///
  /// In es, this message translates to:
  /// **'Desequilibrado'**
  String get staggered;

  /// No description provided for @losesAction.
  ///
  /// In es, this message translates to:
  /// **'Pierde su acción'**
  String get losesAction;

  /// No description provided for @deflect.
  ///
  /// In es, this message translates to:
  /// **'¡Desvío!'**
  String get deflect;

  /// No description provided for @broken.
  ///
  /// In es, this message translates to:
  /// **'¡Desequilibrio!'**
  String get broken;

  /// No description provided for @playerBroken.
  ///
  /// In es, this message translates to:
  /// **'Estructura rota'**
  String get playerBroken;

  /// No description provided for @turn.
  ///
  /// In es, this message translates to:
  /// **'Turno {n}'**
  String turn(int n);

  /// No description provided for @abandon.
  ///
  /// In es, this message translates to:
  /// **'Abandonar run'**
  String get abandon;

  /// No description provided for @typeFist.
  ///
  /// In es, this message translates to:
  /// **'Puño'**
  String get typeFist;

  /// No description provided for @typePalm.
  ///
  /// In es, this message translates to:
  /// **'Palma'**
  String get typePalm;

  /// No description provided for @typeKick.
  ///
  /// In es, this message translates to:
  /// **'Patada'**
  String get typeKick;

  /// No description provided for @typeDefense.
  ///
  /// In es, this message translates to:
  /// **'Defensa'**
  String get typeDefense;

  /// No description provided for @typeTechnique.
  ///
  /// In es, this message translates to:
  /// **'Técnica'**
  String get typeTechnique;

  /// No description provided for @heightHigh.
  ///
  /// In es, this message translates to:
  /// **'alto'**
  String get heightHigh;

  /// No description provided for @heightMid.
  ///
  /// In es, this message translates to:
  /// **'medio'**
  String get heightMid;

  /// No description provided for @heightLow.
  ///
  /// In es, this message translates to:
  /// **'bajo'**
  String get heightLow;

  /// No description provided for @rankElite.
  ///
  /// In es, this message translates to:
  /// **'Élite'**
  String get rankElite;

  /// No description provided for @rankBoss.
  ///
  /// In es, this message translates to:
  /// **'Guardián'**
  String get rankBoss;

  /// No description provided for @fountainNode.
  ///
  /// In es, this message translates to:
  /// **'Fuente'**
  String get fountainNode;

  /// No description provided for @intentAttack.
  ///
  /// In es, this message translates to:
  /// **'Ataque {height}'**
  String intentAttack(String height);

  /// No description provided for @intentNamedAttack.
  ///
  /// In es, this message translates to:
  /// **'{name} ({height})'**
  String intentNamedAttack(String name, String height);

  /// No description provided for @intentCharge.
  ///
  /// In es, this message translates to:
  /// **'Carga'**
  String get intentCharge;

  /// No description provided for @intentChargeDetail.
  ///
  /// In es, this message translates to:
  /// **'Próximo ataque +{n}'**
  String intentChargeDetail(int n);

  /// No description provided for @intentDiscard.
  ///
  /// In es, this message translates to:
  /// **'Descarte'**
  String get intentDiscard;

  /// No description provided for @intentDiscardDetail.
  ///
  /// In es, this message translates to:
  /// **'Descartás {n}'**
  String intentDiscardDetail(int n);

  /// No description provided for @intentInterrupt.
  ///
  /// In es, this message translates to:
  /// **'Interrumpe tus formas si no lo desviás'**
  String get intentInterrupt;

  /// No description provided for @intentSameStance.
  ///
  /// In es, this message translates to:
  /// **'Si terminás en esta postura: +4 daño, +2 E'**
  String get intentSameStance;

  /// No description provided for @countdown.
  ///
  /// In es, this message translates to:
  /// **'turnos'**
  String get countdown;

  /// No description provided for @staggeredDouble.
  ///
  /// In es, this message translates to:
  /// **'Desequilibrado · daño ×2'**
  String get staggeredDouble;

  /// No description provided for @previewThen.
  ///
  /// In es, this message translates to:
  /// **'después {stance}'**
  String previewThen(String stance);

  /// No description provided for @previewDamage.
  ///
  /// In es, this message translates to:
  /// **'{n} daño'**
  String previewDamage(int n);

  /// No description provided for @previewStructure.
  ///
  /// In es, this message translates to:
  /// **'{n} E'**
  String previewStructure(int n);

  /// No description provided for @previewCompletes.
  ///
  /// In es, this message translates to:
  /// **'¡completa {name}!'**
  String previewCompletes(String name);

  /// No description provided for @previewAdvances.
  ///
  /// In es, this message translates to:
  /// **'avanza {name}'**
  String previewAdvances(String name);

  /// No description provided for @previewInterrupts.
  ///
  /// In es, this message translates to:
  /// **'⚠ interrumpe {name}'**
  String previewInterrupts(String name);

  /// No description provided for @stanceHintMabu.
  ///
  /// In es, this message translates to:
  /// **'Puños y palmas +2 · E recibida ½ · patadas +1 costo'**
  String get stanceHintMabu;

  /// No description provided for @stanceHintGongbu.
  ///
  /// In es, this message translates to:
  /// **'Puños +3 daño y +1 E · recibís +2 E'**
  String get stanceHintGongbu;

  /// No description provided for @stanceHintXubu.
  ///
  /// In es, this message translates to:
  /// **'Patadas −1 costo y +2 · desvío +1 Aliento · defensas −2'**
  String get stanceHintXubu;

  /// No description provided for @changeStance.
  ///
  /// In es, this message translates to:
  /// **'Cambiar postura · 1 {breath}'**
  String changeStance(String breath);

  /// No description provided for @formsInterrupted.
  ///
  /// In es, this message translates to:
  /// **'Formas interrumpidas'**
  String get formsInterrupted;

  /// No description provided for @enemyPhase2.
  ///
  /// In es, this message translates to:
  /// **'¡Segunda fase!'**
  String get enemyPhase2;

  /// No description provided for @enemyPhase3.
  ///
  /// In es, this message translates to:
  /// **'¡Última fase!'**
  String get enemyPhase3;

  /// No description provided for @formCompleted.
  ///
  /// In es, this message translates to:
  /// **'¡Forma completa!'**
  String get formCompleted;

  /// No description provided for @effStance.
  ///
  /// In es, this message translates to:
  /// **'Pasás a {name}'**
  String effStance(String name);

  /// No description provided for @effDraw.
  ///
  /// In es, this message translates to:
  /// **'Robás {n}'**
  String effDraw(int n);

  /// No description provided for @effBreath.
  ///
  /// In es, this message translates to:
  /// **'+{n} Aliento'**
  String effBreath(int n);

  /// No description provided for @effBonusStaggered.
  ///
  /// In es, this message translates to:
  /// **'+{n} si el enemigo está Desequilibrado'**
  String effBonusStaggered(int n);

  /// No description provided for @effDeflectDamage.
  ///
  /// In es, this message translates to:
  /// **'Si desviás, {n} de daño'**
  String effDeflectDamage(int n);

  /// No description provided for @effDeflectStructure.
  ///
  /// In es, this message translates to:
  /// **'Si desviás, el enemigo pierde {n} E extra'**
  String effDeflectStructure(int n);

  /// No description provided for @effStanceStructure.
  ///
  /// In es, this message translates to:
  /// **'En {name}, +{n} E'**
  String effStanceStructure(String name, int n);

  /// No description provided for @effClearGuard.
  ///
  /// In es, this message translates to:
  /// **'Perdés toda tu Guardia'**
  String get effClearGuard;

  /// No description provided for @effTurnStructure.
  ///
  /// In es, this message translates to:
  /// **'Este turno, todo daño a Estructura +{n}'**
  String effTurnStructure(int n);

  /// No description provided for @effFirstTurn.
  ///
  /// In es, this message translates to:
  /// **'Solo en el primer turno'**
  String get effFirstTurn;

  /// No description provided for @effExhaust.
  ///
  /// In es, this message translates to:
  /// **'Agotar'**
  String get effExhaust;

  /// No description provided for @invalidCombatOver.
  ///
  /// In es, this message translates to:
  /// **'El combate terminó'**
  String get invalidCombatOver;

  /// No description provided for @invalidMustDiscard.
  ///
  /// In es, this message translates to:
  /// **'Elegí una carta para descartar'**
  String get invalidMustDiscard;

  /// No description provided for @invalidNotInHand.
  ///
  /// In es, this message translates to:
  /// **'La carta no está en la mano'**
  String get invalidNotInHand;

  /// No description provided for @invalidFirstTurnOnly.
  ///
  /// In es, this message translates to:
  /// **'Solo en el primer turno'**
  String get invalidFirstTurnOnly;

  /// No description provided for @invalidNoBreath.
  ///
  /// In es, this message translates to:
  /// **'Aliento insuficiente'**
  String get invalidNoBreath;

  /// No description provided for @invalidDingbuUsed.
  ///
  /// In es, this message translates to:
  /// **'Ya cambiaste de postura este turno'**
  String get invalidDingbuUsed;

  /// No description provided for @invalidSameStance.
  ///
  /// In es, this message translates to:
  /// **'Ya estás en esa postura'**
  String get invalidSameStance;

  /// No description provided for @invalidBreatheUsed.
  ///
  /// In es, this message translates to:
  /// **'Ya respiraste en este combate'**
  String get invalidBreatheUsed;

  /// No description provided for @invalidRetainTooMany.
  ///
  /// In es, this message translates to:
  /// **'Retenés demasiadas cartas'**
  String get invalidRetainTooMany;

  /// No description provided for @invalidNoDiscard.
  ///
  /// In es, this message translates to:
  /// **'No hay que descartar'**
  String get invalidNoDiscard;

  /// No description provided for @partOfForm.
  ///
  /// In es, this message translates to:
  /// **'Parte de una forma'**
  String get partOfForm;

  /// No description provided for @tutStart.
  ///
  /// In es, this message translates to:
  /// **'Empezar entrenamiento'**
  String get tutStart;

  /// No description provided for @tutSkipToRun.
  ///
  /// In es, this message translates to:
  /// **'Ya sé jugar: nueva run'**
  String get tutSkipToRun;

  /// No description provided for @tutReplay.
  ///
  /// In es, this message translates to:
  /// **'Repetir entrenamiento'**
  String get tutReplay;

  /// No description provided for @tutSkip.
  ///
  /// In es, this message translates to:
  /// **'Saltear'**
  String get tutSkip;

  /// No description provided for @tutNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get tutNext;

  /// No description provided for @tutMaster.
  ///
  /// In es, this message translates to:
  /// **'Maestro'**
  String get tutMaster;

  /// No description provided for @tutGo.
  ///
  /// In es, this message translates to:
  /// **'¡Vamos!'**
  String get tutGo;

  /// No description provided for @tutClimb.
  ///
  /// In es, this message translates to:
  /// **'Empezar la subida'**
  String get tutClimb;

  /// No description provided for @tutHome.
  ///
  /// In es, this message translates to:
  /// **'Volver al inicio'**
  String get tutHome;

  /// No description provided for @tutWelcome.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido al patio de la escuela del Dragón Dormido. Antes de subir la montaña vas a practicar con el muñeco de madera. Yo te guío.'**
  String get tutWelcome;

  /// No description provided for @tutIntent.
  ///
  /// In es, this message translates to:
  /// **'Este globo es lo que el muñeco va a hacer en su turno: un golpe ALTO (flecha arriba) de 4 de daño y 2 a tu Estructura (E). El enemigo siempre avisa antes de actuar.'**
  String get tutIntent;

  /// No description provided for @tutEnemy.
  ///
  /// In es, this message translates to:
  /// **'Su Vida (roja) y su Estructura (violeta). Llevá la Vida a 0 para ganar. Si le vaciás la Estructura, queda Desequilibrado: pierde su acción y recibe el doble de daño.'**
  String get tutEnemy;

  /// No description provided for @tutPlayer.
  ///
  /// In es, this message translates to:
  /// **'Este sos vos: tu Vida, tu Estructura, tu postura actual (Caballo) y tu Guardia, el escudo de la derecha.'**
  String get tutPlayer;

  /// No description provided for @tutHand.
  ///
  /// In es, this message translates to:
  /// **'Tu mano. El número de arriba a la izquierda de cada carta es su costo en Aliento. Tenés 3 por turno y lo que no gastes se pierde.'**
  String get tutHand;

  /// No description provided for @tutPlayFist.
  ///
  /// In es, this message translates to:
  /// **'Tocá Puñetazo a fondo una vez para ver qué hace y otra vez para jugarla.'**
  String get tutPlayFist;

  /// No description provided for @tutDefend.
  ///
  /// In es, this message translates to:
  /// **'Ahora defendete. El muñeco va a pegar ALTO y Paso atrás da Guardia alta. Si la altura coincide y la Guardia alcanza, desviás el golpe. Jugala con dos toques.'**
  String get tutDefend;

  /// No description provided for @tutKick.
  ///
  /// In es, this message translates to:
  /// **'Quedaste en postura Vacía, donde las patadas cuestan 1 menos: Patada látigo ahora es gratis. Jugala.'**
  String get tutKick;

  /// No description provided for @tutForms.
  ///
  /// In es, this message translates to:
  /// **'Puñetazo a fondo y Patada látigo son los dos primeros pasos del Pequeño Puño Rojo. Si completás una forma en orden, se desata un golpe grande. Las defensas no la interrumpen.'**
  String get tutForms;

  /// No description provided for @tutEndTurn.
  ///
  /// In es, this message translates to:
  /// **'Tu Guardia está lista. Terminá el turno y mirá qué pasa.'**
  String get tutEndTurn;

  /// No description provided for @tutDeflect.
  ///
  /// In es, this message translates to:
  /// **'¡Desvío! No recibiste daño, el muñeco perdió Estructura y quedó Desequilibrado: pierde su acción y recibe el doble. Además, el desvío te da Aliento extra para este turno.'**
  String get tutDeflect;

  /// No description provided for @tutActions.
  ///
  /// In es, this message translates to:
  /// **'Dos ayudas: Paso en T te cambia de postura por 1 de Aliento, una vez por turno. Respirar cambia toda tu mano, una vez por combate.'**
  String get tutActions;

  /// No description provided for @tutFree.
  ///
  /// In es, this message translates to:
  /// **'Ahora rematalo vos. Mientras esté Desequilibrado, cada golpe cuenta doble.'**
  String get tutFree;

  /// No description provided for @tutDone.
  ///
  /// In es, this message translates to:
  /// **'¡Bien hecho! En la montaña, después de cada combate sumás una carta a tu mazo. La Vida no se recupera sola, solo en la fuente. A mitad de camino, el Santuario te ofrece dos caminos. Y mirá siempre el globo antes de jugar.'**
  String get tutDone;

  /// No description provided for @blocked.
  ///
  /// In es, this message translates to:
  /// **'Bloqueado'**
  String get blocked;

  /// No description provided for @yourTurn.
  ///
  /// In es, this message translates to:
  /// **'Tu turno'**
  String get yourTurn;

  /// No description provided for @endSummaryWon.
  ///
  /// In es, this message translates to:
  /// **'{turns, plural, =1{En 1 turno} other{En {turns} turnos}} · Vida {hp}/{maxHp}'**
  String endSummaryWon(int turns, int hp, int maxHp);

  /// No description provided for @endSummaryLost.
  ///
  /// In es, this message translates to:
  /// **'{name} resistió con {hp} de Vida'**
  String endSummaryLost(String name, int hp);

  /// No description provided for @fightStart.
  ///
  /// In es, this message translates to:
  /// **'¡En guardia!'**
  String get fightStart;

  /// No description provided for @soundEffects.
  ///
  /// In es, this message translates to:
  /// **'Efectos de sonido'**
  String get soundEffects;

  /// No description provided for @music.
  ///
  /// In es, this message translates to:
  /// **'Música'**
  String get music;

  /// No description provided for @menuLearn.
  ///
  /// In es, this message translates to:
  /// **'Aprender a jugar'**
  String get menuLearn;

  /// No description provided for @menuLearnProgress.
  ///
  /// In es, this message translates to:
  /// **'{done} de {total} lecciones'**
  String menuLearnProgress(int done, int total);

  /// No description provided for @menuStartHere.
  ///
  /// In es, this message translates to:
  /// **'Empezá acá'**
  String get menuStartHere;

  /// No description provided for @difficultyTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo querés subir?'**
  String get difficultyTitle;

  /// No description provided for @difficultySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Podés cambiarla en cada subida nueva.'**
  String get difficultySubtitle;

  /// No description provided for @difficultyEasy.
  ///
  /// In es, this message translates to:
  /// **'Fácil'**
  String get difficultyEasy;

  /// No description provided for @difficultyNormal.
  ///
  /// In es, this message translates to:
  /// **'Normal'**
  String get difficultyNormal;

  /// No description provided for @difficultyHard.
  ///
  /// In es, this message translates to:
  /// **'Difícil'**
  String get difficultyHard;

  /// No description provided for @difficultyShifu.
  ///
  /// In es, this message translates to:
  /// **'Shifu'**
  String get difficultyShifu;

  /// No description provided for @difficultyEasyDesc.
  ///
  /// In es, this message translates to:
  /// **'Para conocer la montaña sin apuro. Más Vida y rivales más blandos.'**
  String get difficultyEasyDesc;

  /// No description provided for @difficultyNormalDesc.
  ///
  /// In es, this message translates to:
  /// **'La subida tal como fue pensada.'**
  String get difficultyNormalDesc;

  /// No description provided for @difficultyHardDesc.
  ///
  /// In es, this message translates to:
  /// **'Rivales más duros y una fuente que cura menos.'**
  String get difficultyHardDesc;

  /// No description provided for @difficultyShifuDesc.
  ///
  /// In es, this message translates to:
  /// **'Para maestros: menos Vida y cada error se paga.'**
  String get difficultyShifuDesc;

  /// No description provided for @difficultyLocked.
  ///
  /// In es, this message translates to:
  /// **'Bloqueada'**
  String get difficultyLocked;

  /// No description provided for @difficultyShifuLocked.
  ///
  /// In es, this message translates to:
  /// **'Se desbloquea al ganar una subida en Difícil.'**
  String get difficultyShifuLocked;

  /// No description provided for @difficultyStats.
  ///
  /// In es, this message translates to:
  /// **'Vida {hp} · Fuente +{heal} · Rivales {enemy}%'**
  String difficultyStats(int hp, int heal, int enemy);

  /// No description provided for @scales.
  ///
  /// In es, this message translates to:
  /// **'Escamas {count} · −{count} por golpe'**
  String scales(int count);

  /// No description provided for @scaleShed.
  ///
  /// In es, this message translates to:
  /// **'¡Escama arrancada!'**
  String get scaleShed;

  /// No description provided for @scalesRegrown.
  ///
  /// In es, this message translates to:
  /// **'¡Le crecen escamas!'**
  String get scalesRegrown;

  /// No description provided for @scalesNow.
  ///
  /// In es, this message translates to:
  /// **'Ahora tiene {count}'**
  String scalesNow(int count);

  /// No description provided for @scalesLeft.
  ///
  /// In es, this message translates to:
  /// **'Le quedan {count}'**
  String scalesLeft(int count);

  /// No description provided for @menuClimb.
  ///
  /// In es, this message translates to:
  /// **'La subida'**
  String get menuClimb;

  /// No description provided for @menuClimbSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Montaña de las Mil Nubes'**
  String get menuClimbSubtitle;

  /// No description provided for @menuReplaceRunTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Empezar una subida nueva?'**
  String get menuReplaceRunTitle;

  /// No description provided for @menuReplaceRunBody.
  ///
  /// In es, this message translates to:
  /// **'Tenés una subida guardada. Si empezás otra, se pierde.'**
  String get menuReplaceRunBody;

  /// No description provided for @menuReplaceRunOk.
  ///
  /// In es, this message translates to:
  /// **'Empezar de nuevo'**
  String get menuReplaceRunOk;

  /// No description provided for @cancelAction.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancelAction;

  /// No description provided for @lessonsTitle.
  ///
  /// In es, this message translates to:
  /// **'Aprender a jugar'**
  String get lessonsTitle;

  /// No description provided for @lessonsIntro.
  ///
  /// In es, this message translates to:
  /// **'Lecciones cortas con el maestro. Cada una se habilita al terminar la anterior y podés repetirlas cuando quieras.'**
  String get lessonsIntro;

  /// No description provided for @lessonLocked.
  ///
  /// In es, this message translates to:
  /// **'Completá la lección anterior'**
  String get lessonLocked;

  /// No description provided for @lessonMinutes.
  ///
  /// In es, this message translates to:
  /// **'{n} min'**
  String lessonMinutes(int n);

  /// No description provided for @lessonNumber.
  ///
  /// In es, this message translates to:
  /// **'Lección {n}'**
  String lessonNumber(int n);

  /// No description provided for @lessonDoneTitle.
  ///
  /// In es, this message translates to:
  /// **'Lección completa'**
  String get lessonDoneTitle;

  /// No description provided for @lessonNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente lección'**
  String get lessonNext;

  /// No description provided for @lessonBackToList.
  ///
  /// In es, this message translates to:
  /// **'Volver a las lecciones'**
  String get lessonBackToList;

  /// No description provided for @lessonRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get lessonRetry;

  /// No description provided for @lessonLostHint.
  ///
  /// In es, this message translates to:
  /// **'No pasa nada: es práctica. Probá de nuevo.'**
  String get lessonLostHint;

  /// No description provided for @lessonAllDone.
  ///
  /// In es, this message translates to:
  /// **'¡Terminaste el entrenamiento! Ya podés subir la montaña.'**
  String get lessonAllDone;

  /// No description provided for @lesStrikeTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu primer golpe'**
  String get lesStrikeTitle;

  /// No description provided for @lesStrikeBlurb.
  ///
  /// In es, this message translates to:
  /// **'La pantalla, las cartas, el Aliento y cómo atacar.'**
  String get lesStrikeBlurb;

  /// No description provided for @lesStrikeDone.
  ///
  /// In es, this message translates to:
  /// **'Aprendiste a leer una carta, a usar tu Aliento y a atacar.'**
  String get lesStrikeDone;

  /// No description provided for @lesDefendTitle.
  ///
  /// In es, this message translates to:
  /// **'El rival avisa'**
  String get lesDefendTitle;

  /// No description provided for @lesDefendBlurb.
  ///
  /// In es, this message translates to:
  /// **'Leer el globo del rival, la Guardia, las alturas y el desvío.'**
  String get lesDefendBlurb;

  /// No description provided for @lesDefendDone.
  ///
  /// In es, this message translates to:
  /// **'Aprendiste a leer al rival y a defenderte a la altura justa.'**
  String get lesDefendDone;

  /// No description provided for @lesStancesTitle.
  ///
  /// In es, this message translates to:
  /// **'Posturas'**
  String get lesStancesTitle;

  /// No description provided for @lesStancesBlurb.
  ///
  /// In es, this message translates to:
  /// **'Caballo, Arco y Vacía: preparar la postura antes de pegar.'**
  String get lesStancesBlurb;

  /// No description provided for @lesStancesDone.
  ///
  /// In es, this message translates to:
  /// **'Aprendiste a preparar tu postura antes de pegar.'**
  String get lesStancesDone;

  /// No description provided for @lesStructureTitle.
  ///
  /// In es, this message translates to:
  /// **'Estructura'**
  String get lesStructureTitle;

  /// No description provided for @lesStructureBlurb.
  ///
  /// In es, this message translates to:
  /// **'Desequilibrar al rival y cuidar tu propio equilibrio.'**
  String get lesStructureBlurb;

  /// No description provided for @lesStructureDone.
  ///
  /// In es, this message translates to:
  /// **'Aprendiste a desequilibrar al rival para pegarle el doble.'**
  String get lesStructureDone;

  /// No description provided for @lesFormsTitle.
  ///
  /// In es, this message translates to:
  /// **'Formas'**
  String get lesFormsTitle;

  /// No description provided for @lesFormsBlurb.
  ///
  /// In es, this message translates to:
  /// **'Encadenar pasos para un golpe extra, y Respirar.'**
  String get lesFormsBlurb;

  /// No description provided for @lesFormsDone.
  ///
  /// In es, this message translates to:
  /// **'Aprendiste a completar una forma y a usar Respirar.'**
  String get lesFormsDone;

  /// No description provided for @lesClimbTitle.
  ///
  /// In es, this message translates to:
  /// **'La subida'**
  String get lesClimbTitle;

  /// No description provided for @lesClimbBlurb.
  ///
  /// In es, this message translates to:
  /// **'El mapa, las recompensas, la fuente y los caminos.'**
  String get lesClimbBlurb;

  /// No description provided for @pauseTitle.
  ///
  /// In es, this message translates to:
  /// **'Pausa'**
  String get pauseTitle;

  /// No description provided for @pauseResume.
  ///
  /// In es, this message translates to:
  /// **'Seguir peleando'**
  String get pauseResume;

  /// No description provided for @pauseHowTo.
  ///
  /// In es, this message translates to:
  /// **'Cómo se juega'**
  String get pauseHowTo;

  /// No description provided for @pauseToMenu.
  ///
  /// In es, this message translates to:
  /// **'Volver al menú'**
  String get pauseToMenu;

  /// No description provided for @pauseToMenuHint.
  ///
  /// In es, this message translates to:
  /// **'La subida queda guardada: con \"Continuar\" volvés al mapa, antes de este combate.'**
  String get pauseToMenuHint;

  /// No description provided for @pauseRestartLesson.
  ///
  /// In es, this message translates to:
  /// **'Reiniciar lección'**
  String get pauseRestartLesson;

  /// No description provided for @pauseExitLesson.
  ///
  /// In es, this message translates to:
  /// **'Salir a las lecciones'**
  String get pauseExitLesson;

  /// No description provided for @mapHome.
  ///
  /// In es, this message translates to:
  /// **'Menú principal'**
  String get mapHome;

  /// No description provided for @mapMore.
  ///
  /// In es, this message translates to:
  /// **'Más opciones'**
  String get mapMore;

  /// No description provided for @abandonConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Abandonar la subida?'**
  String get abandonConfirmTitle;

  /// No description provided for @abandonConfirmBody.
  ///
  /// In es, this message translates to:
  /// **'Se pierde todo el progreso de esta subida.'**
  String get abandonConfirmBody;

  /// No description provided for @illCardTitle.
  ///
  /// In es, this message translates to:
  /// **'Cómo se lee una carta'**
  String get illCardTitle;

  /// No description provided for @illCost.
  ///
  /// In es, this message translates to:
  /// **'Costo en Aliento'**
  String get illCost;

  /// No description provided for @illType.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get illType;

  /// No description provided for @illName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get illName;

  /// No description provided for @illStatsDamage.
  ///
  /// In es, this message translates to:
  /// **'daño a la Vida'**
  String get illStatsDamage;

  /// No description provided for @illStatsStructure.
  ///
  /// In es, this message translates to:
  /// **'daño a la Estructura'**
  String get illStatsStructure;

  /// No description provided for @nodeCombat.
  ///
  /// In es, this message translates to:
  /// **'Combate'**
  String get nodeCombat;

  /// No description provided for @illStance.
  ///
  /// In es, this message translates to:
  /// **'Postura en la que te deja, después de actuar'**
  String get illStance;

  /// No description provided for @illGuard.
  ///
  /// In es, this message translates to:
  /// **'Guardia y su altura'**
  String get illGuard;

  /// No description provided for @illIntentTitle.
  ///
  /// In es, this message translates to:
  /// **'El globo del rival'**
  String get illIntentTitle;

  /// No description provided for @illIntentAttack.
  ///
  /// In es, this message translates to:
  /// **'Ataque: la flecha es la altura, el número el daño y E el daño a tu Estructura.'**
  String get illIntentAttack;

  /// No description provided for @illIntentGuard.
  ///
  /// In es, this message translates to:
  /// **'Se cubre: gana Guardia contra tus próximos golpes.'**
  String get illIntentGuard;

  /// No description provided for @illIntentCharge.
  ///
  /// In es, this message translates to:
  /// **'Carga: junta fuerza, su próximo golpe pega más.'**
  String get illIntentCharge;

  /// No description provided for @illIntentDiscard.
  ///
  /// In es, this message translates to:
  /// **'Chillido: te hace descartar cartas.'**
  String get illIntentDiscard;

  /// No description provided for @illHeightsTitle.
  ///
  /// In es, this message translates to:
  /// **'Alturas'**
  String get illHeightsTitle;

  /// No description provided for @illHeightsSame.
  ///
  /// In es, this message translates to:
  /// **'Misma altura: la Guardia absorbe todo. Si alcanza, desviás el golpe (化).'**
  String get illHeightsSame;

  /// No description provided for @illHeightsOther.
  ///
  /// In es, this message translates to:
  /// **'Otra altura: la Guardia absorbe solo la mitad.'**
  String get illHeightsOther;

  /// No description provided for @illHigh.
  ///
  /// In es, this message translates to:
  /// **'Alto'**
  String get illHigh;

  /// No description provided for @illMid.
  ///
  /// In es, this message translates to:
  /// **'Medio'**
  String get illMid;

  /// No description provided for @illLow.
  ///
  /// In es, this message translates to:
  /// **'Bajo'**
  String get illLow;

  /// No description provided for @illStancesTitle.
  ///
  /// In es, this message translates to:
  /// **'Posturas'**
  String get illStancesTitle;

  /// No description provided for @illStanceMabuPro.
  ///
  /// In es, this message translates to:
  /// **'Puños y palmas +2. Recibís la mitad de daño a la Estructura.'**
  String get illStanceMabuPro;

  /// No description provided for @illStanceMabuCon.
  ///
  /// In es, this message translates to:
  /// **'Las patadas cuestan 1 más.'**
  String get illStanceMabuCon;

  /// No description provided for @illStanceGongbuPro.
  ///
  /// In es, this message translates to:
  /// **'Puños +3 de daño y +1 de Estructura.'**
  String get illStanceGongbuPro;

  /// No description provided for @illStanceGongbuCon.
  ///
  /// In es, this message translates to:
  /// **'Recibís 2 más de daño a la Estructura.'**
  String get illStanceGongbuCon;

  /// No description provided for @illStanceXubuPro.
  ///
  /// In es, this message translates to:
  /// **'Patadas: cuestan 1 menos y pegan +2. Desviar da +1 Aliento extra.'**
  String get illStanceXubuPro;

  /// No description provided for @illStanceXubuCon.
  ///
  /// In es, this message translates to:
  /// **'Las defensas dan 2 menos de Guardia.'**
  String get illStanceXubuCon;

  /// No description provided for @illTurnTitle.
  ///
  /// In es, this message translates to:
  /// **'Orden de un turno'**
  String get illTurnTitle;

  /// No description provided for @illTurn1.
  ///
  /// In es, this message translates to:
  /// **'Tu Guardia vuelve a 0, robás cartas y recuperás el Aliento.'**
  String get illTurn1;

  /// No description provided for @illTurn2.
  ///
  /// In es, this message translates to:
  /// **'Jugás cartas: tocá una para ver qué hace y otra vez para jugarla.'**
  String get illTurn2;

  /// No description provided for @illTurn3.
  ///
  /// In es, this message translates to:
  /// **'Terminás el turno: las cartas que quedan se descartan.'**
  String get illTurn3;

  /// No description provided for @illTurn4.
  ///
  /// In es, this message translates to:
  /// **'El rival hace lo que anunció en su globo y anuncia lo próximo.'**
  String get illTurn4;

  /// No description provided for @illBrokenTitle.
  ///
  /// In es, this message translates to:
  /// **'Desequilibrado'**
  String get illBrokenTitle;

  /// No description provided for @illBroken.
  ///
  /// In es, this message translates to:
  /// **'Si la Estructura del rival llega a 0, pierde su próxima acción y recibe el doble de daño hasta el final de tu próximo turno. Si te pasa a vos, empezás el turno siguiente con 2 de Aliento menos.'**
  String get illBroken;

  /// No description provided for @illFormsTitle.
  ///
  /// In es, this message translates to:
  /// **'Formas'**
  String get illFormsTitle;

  /// No description provided for @illForms.
  ///
  /// In es, this message translates to:
  /// **'Secuencias fijas de cartas. Si las jugás en orden, el último paso suma un golpe extra. Un ataque fuera de orden la interrumpe; las defensas y técnicas no.'**
  String get illForms;

  /// No description provided for @lesStrike1.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido. Esto es un combate por turnos: vos sos el de la izquierda y el muñeco de madera es tu rival. En tu turno jugás cartas; después el rival hace lo suyo. Te voy a explicar todo, paso a paso.'**
  String get lesStrike1;

  /// No description provided for @lesStrike2.
  ///
  /// In es, this message translates to:
  /// **'Esto sos vos. La barra verde es tu Vida: si llega a 0, perdés. La violeta es tu Estructura, tu equilibrio: más adelante vas a ver para qué sirve.'**
  String get lesStrike2;

  /// No description provided for @lesStrike3.
  ///
  /// In es, this message translates to:
  /// **'Este es el rival: su nombre, su Vida (roja) y su Estructura (violeta). Para ganar, llevá su Vida a 0.'**
  String get lesStrike3;

  /// No description provided for @lesStrike4.
  ///
  /// In es, this message translates to:
  /// **'Estas son tus cartas: tu mano. Cada turno robás 5 cartas nuevas de tu mazo.'**
  String get lesStrike4;

  /// No description provided for @lesStrike5.
  ///
  /// In es, this message translates to:
  /// **'Así se lee una carta. Arriba a la izquierda, lo que cuesta; a la derecha, su tipo. En el centro, el nombre en español y su nombre chino. Abajo, lo que hace: el rayo rojo es el daño a la Vida y el hexágono violeta, el daño a la Estructura. Si dice → y una postura, te deja en esa postura después de actuar.'**
  String get lesStrike5;

  /// No description provided for @lesStrike6.
  ///
  /// In es, this message translates to:
  /// **'Estos puntos son tu Aliento, la energía del turno. Tenés 3 y cada carta cuesta lo que dice su círculo. Lo que no gastes se pierde al terminar el turno.'**
  String get lesStrike6;

  /// No description provided for @lesStrike7.
  ///
  /// In es, this message translates to:
  /// **'Tocá Puñetazo firme UNA sola vez.'**
  String get lesStrike7;

  /// No description provided for @lesStrike8.
  ///
  /// In es, this message translates to:
  /// **'Esta es la vista previa: muestra exactamente lo que va a pasar, con todos los bonus ya sumados. Para jugar la carta, tocala otra vez.'**
  String get lesStrike8;

  /// No description provided for @lesStrike9.
  ///
  /// In es, this message translates to:
  /// **'¡Golpe! Le sacaste 7 de Vida (5 de la carta + 2 por estar en postura Caballo) y 2 de Estructura. Mirá cómo bajaron sus barras. Tu Aliento bajó de 3 a 2.'**
  String get lesStrike9;

  /// No description provided for @lesStrike10.
  ///
  /// In es, this message translates to:
  /// **'Ahora Empujón de palma: hace poco daño pero le saca mucha Estructura. Tocala dos veces.'**
  String get lesStrike10;

  /// No description provided for @lesStrike11.
  ///
  /// In es, this message translates to:
  /// **'Te queda 1 de Aliento: jugá el otro Puñetazo firme.'**
  String get lesStrike11;

  /// No description provided for @lesStrike12.
  ///
  /// In es, this message translates to:
  /// **'Te quedaste sin Aliento. Las cartas que no podés pagar se ven apagadas: Patada látigo cuesta 2 en postura Caballo. Las que no jugaste se descartan al terminar el turno.'**
  String get lesStrike12;

  /// No description provided for @lesStrike13.
  ///
  /// In es, this message translates to:
  /// **'Antes de terminar, mirá este globo: es lo que el rival va a hacer en su turno. La flecha → es la altura (MEDIA), 5 es el daño a tu Vida y E 2 el daño a tu Estructura. El rival siempre avisa antes de actuar.'**
  String get lesStrike13;

  /// No description provided for @lesStrike14.
  ///
  /// In es, this message translates to:
  /// **'Todavía no tenés defensas, así que te va a pegar. Tocá Terminar turno y mirá.'**
  String get lesStrike14;

  /// No description provided for @lesStrike15.
  ///
  /// In es, this message translates to:
  /// **'Te pegó: el número rojo fue el daño a tu Vida, 5. Tu Estructura bajó solo 1 porque en Caballo recibís la mitad. En la próxima lección aprendés a defenderte.'**
  String get lesStrike15;

  /// No description provided for @lesStrike16.
  ///
  /// In es, this message translates to:
  /// **'Empezó tu turno 2: robaste 5 cartas nuevas y tu Aliento volvió a 3. Así empieza cada turno.'**
  String get lesStrike16;

  /// No description provided for @lesStrike17.
  ///
  /// In es, this message translates to:
  /// **'Al muñeco le quedan 10 de Vida. Rematalo vos: elegí las cartas que quieras.'**
  String get lesStrike17;

  /// No description provided for @lesDefend1.
  ///
  /// In es, this message translates to:
  /// **'Lo más importante del juego: leer el globo del rival. La flecha es la ALTURA del golpe: ↑ alto, → medio, ↓ bajo. El número es el daño y E el daño a tu Estructura.'**
  String get lesDefend1;

  /// No description provided for @lesDefend2.
  ///
  /// In es, this message translates to:
  /// **'Las cartas de Defensa te dan Guardia: un escudo que absorbe el golpe del rival. Cada defensa protege una ALTURA. El muñeco va a pegar ALTO, y Bloqueo alto protege arriba con 9 de Guardia.'**
  String get lesDefend2;

  /// No description provided for @lesDefend3.
  ///
  /// In es, this message translates to:
  /// **'Jugala: dos toques.'**
  String get lesDefend3;

  /// No description provided for @lesDefend4.
  ///
  /// In es, this message translates to:
  /// **'Esta es tu Guardia: 9, alta. Si el golpe llega a la misma altura y tu Guardia alcanza para cubrirlo, lo DESVIÁS (化): no recibís nada, el rival pierde 3 de Estructura y ganás 1 de Aliento para tu próximo turno.'**
  String get lesDefend4;

  /// No description provided for @lesDefend5.
  ///
  /// In es, this message translates to:
  /// **'Con el Aliento que te queda, pegale: Puñetazo firme.'**
  String get lesDefend5;

  /// No description provided for @lesDefend6.
  ///
  /// In es, this message translates to:
  /// **'Terminá el turno y mirá.'**
  String get lesDefend6;

  /// No description provided for @lesDefend7.
  ///
  /// In es, this message translates to:
  /// **'¡Desvío! No recibiste daño y su Estructura bajó 3. Esto es pelear bien: mirar el globo y responder a la altura justa.'**
  String get lesDefend7;

  /// No description provided for @lesDefend8.
  ///
  /// In es, this message translates to:
  /// **'Tu Guardia volvió a 0: dura solo el turno del rival, así que hay que defenderse cada turno. Y fijate que tenés 4 de Aliento: +1 por el desvío.'**
  String get lesDefend8;

  /// No description provided for @lesDefend9.
  ///
  /// In es, this message translates to:
  /// **'Ahora viene MEDIO (→) con 6 de daño, y la única defensa que tenés es BAJA.'**
  String get lesDefend9;

  /// No description provided for @lesDefend10.
  ///
  /// In es, this message translates to:
  /// **'Jugá Bloqueo bajo igual, para ver qué pasa con la altura equivocada.'**
  String get lesDefend10;

  /// No description provided for @lesDefend11.
  ///
  /// In es, this message translates to:
  /// **'Terminá el turno.'**
  String get lesDefend11;

  /// No description provided for @lesDefend12.
  ///
  /// In es, this message translates to:
  /// **'Altura equivocada: la Guardia absorbió solo la mitad y recibiste 3 de daño. La altura importa tanto como el número.'**
  String get lesDefend12;

  /// No description provided for @lesDefend13.
  ///
  /// In es, this message translates to:
  /// **'Cada rival tiene una regla propia. Tocá el nombre del rival cuando quieras leerla.'**
  String get lesDefend13;

  /// No description provided for @lesDefend14.
  ///
  /// In es, this message translates to:
  /// **'Ahora viene BAJO (↓) y tenés Bloqueo bajo. Defendete bien y rematalo.'**
  String get lesDefend14;

  /// No description provided for @lesStances1.
  ///
  /// In es, this message translates to:
  /// **'Siempre estás en una de tres posturas: Caballo 马步, Arco 弓步 o Vacía 虚步. Ahora estás en Caballo. La postura en la que ESTÁS cambia cuánto pegan y cuánto cuestan tus cartas.'**
  String get lesStances1;

  /// No description provided for @lesStances2.
  ///
  /// In es, this message translates to:
  /// **'Esto da cada postura. Lo podés volver a ver cuando quieras desde la pausa, en \"Cómo se juega\".'**
  String get lesStances2;

  /// No description provided for @lesStances3.
  ///
  /// In es, this message translates to:
  /// **'Tocá Puñetazo a fondo una vez y mirá la vista previa.'**
  String get lesStances3;

  /// No description provided for @lesStances4.
  ///
  /// In es, this message translates to:
  /// **'Fijate el daño: 8 con un ▲ verde. La carta base hace 6, pero pegás desde Caballo, que suma +2 a los puños: el ▲ marca lo que te suma la postura y arriba dice \"+2 daño por Mǎbù\". Si una postura te resta, vas a ver un ▼ rojo. Lo de abajo, → Arco, es la postura en la que te deja DESPUÉS de pegar. Jugala.'**
  String get lesStances4;

  /// No description provided for @lesStances5.
  ///
  /// In es, this message translates to:
  /// **'Ahora estás en Arco: los puños pegan +3 y sacan +1 de Estructura. Esa ventaja no la usó la carta que te trajo: la aprovecha la PRÓXIMA.'**
  String get lesStances5;

  /// No description provided for @lesStances6.
  ///
  /// In es, this message translates to:
  /// **'Mirá Puñetazo firme: antes marcaba 7 de daño y 2 de Estructura; ahora, 8 y 3. Los números de tus cartas siempre muestran lo que pegan desde la postura en la que estás. Pega desde Arco y después te deja en Caballo. Jugalo.'**
  String get lesStances6;

  /// No description provided for @lesStances7.
  ///
  /// In es, this message translates to:
  /// **'Ese es el truco: una carta con → te prepara la siguiente. Antes de jugar, pensá el orden: primero la que te deja en la postura que la otra aprovecha.'**
  String get lesStances7;

  /// No description provided for @lesStances8.
  ///
  /// In es, this message translates to:
  /// **'Si ninguna carta te deja en la postura que necesitás, Paso en T te cambia YA, por 1 de Aliento, una vez por turno. Las patadas rinden en Vacía: tocalo y elegí Vacía.'**
  String get lesStances8;

  /// No description provided for @lesStances9.
  ///
  /// In es, this message translates to:
  /// **'En Vacía las patadas cuestan 1 menos y pegan +2: Patada látigo ahora cuesta 0 (el costo se pone verde) y hace 7 ▲. Jugala.'**
  String get lesStances9;

  /// No description provided for @lesStances10.
  ///
  /// In es, this message translates to:
  /// **'Terminá el combate como quieras. Antes de cada carta, mirá en qué postura estás y en cuál te deja.'**
  String get lesStances10;

  /// No description provided for @lesStructure1.
  ///
  /// In es, this message translates to:
  /// **'Este muñeco tiene poca Estructura: 8. Cada ataque tiene dos números: el rayo rojo es el daño a la Vida y el hexágono violeta, el daño a la Estructura. Si la Estructura del rival llega a 0, queda DESEQUILIBRADO.'**
  String get lesStructure1;

  /// No description provided for @lesStructure2.
  ///
  /// In es, this message translates to:
  /// **'Empujón de palma casi no hace daño, pero saca 4 de Estructura. Jugalo.'**
  String get lesStructure2;

  /// No description provided for @lesStructure3.
  ///
  /// In es, this message translates to:
  /// **'Otra vez: le quedan 4.'**
  String get lesStructure3;

  /// No description provided for @lesStructure4.
  ///
  /// In es, this message translates to:
  /// **'¡Desequilibrado! Mirá las estrellas. Pierde la acción que había anunciado y recibe el DOBLE de daño hasta el final de tu próximo turno.'**
  String get lesStructure4;

  /// No description provided for @lesStructure5.
  ///
  /// In es, this message translates to:
  /// **'Aprovechá: Puñetazo firme. En la vista previa el daño ya sale doble.'**
  String get lesStructure5;

  /// No description provided for @lesStructure6.
  ///
  /// In es, this message translates to:
  /// **'Su globo decía que se iba a cubrir (la Guardia del rival absorbe el daño a la Vida de tus golpes, pero no la Estructura). Ahora está apagado: esa acción la pierde.'**
  String get lesStructure6;

  /// No description provided for @lesStructure7.
  ///
  /// In es, this message translates to:
  /// **'Vos también tenés Estructura. Si el rival te la vacía, empezás tu próximo turno con 2 de Aliento menos. Defenderte bien la protege.'**
  String get lesStructure7;

  /// No description provided for @lesStructure8.
  ///
  /// In es, this message translates to:
  /// **'Terminá el turno.'**
  String get lesStructure8;

  /// No description provided for @lesStructure9.
  ///
  /// In es, this message translates to:
  /// **'Perdió su acción. Ahora anuncia Carga (el ícono del rayo): en su turno no te ataca, junta fuerza y su próximo golpe hará 4 más. Cuando veas una carga, preparate.'**
  String get lesStructure9;

  /// No description provided for @lesStructure10.
  ///
  /// In es, this message translates to:
  /// **'Sigue desequilibrado todo este turno: tus golpes cuentan doble. Terminalo.'**
  String get lesStructure10;

  /// No description provided for @lesForms1.
  ///
  /// In es, this message translates to:
  /// **'Una forma (套路) es una secuencia fija de cartas. Si las jugás en orden, al completar el último paso se suma un golpe extra. Esta es el Pequeño Puño Rojo: Puñetazo a fondo → Patada látigo → Bloqueo y contragolpe → Paso atrás.'**
  String get lesForms1;

  /// No description provided for @lesForms2.
  ///
  /// In es, this message translates to:
  /// **'Primer paso: Puñetazo a fondo.'**
  String get lesForms2;

  /// No description provided for @lesForms3.
  ///
  /// In es, this message translates to:
  /// **'Segundo paso: Patada látigo.'**
  String get lesForms3;

  /// No description provided for @lesForms4.
  ///
  /// In es, this message translates to:
  /// **'Dos pasos marcados. El progreso no se pierde al terminar el turno: la forma te espera.'**
  String get lesForms4;

  /// No description provided for @lesForms5.
  ///
  /// In es, this message translates to:
  /// **'Tocá Empujón de palma UNA vez, sin jugarla.'**
  String get lesForms5;

  /// No description provided for @lesForms6.
  ///
  /// In es, this message translates to:
  /// **'Mirá el triángulo de aviso: un ataque (puño, palma o patada) que no es el próximo paso INTERRUMPE la forma y hay que empezar de nuevo. Las defensas y las técnicas nunca la interrumpen.'**
  String get lesForms6;

  /// No description provided for @lesForms7.
  ///
  /// In es, this message translates to:
  /// **'El tercer paso cuesta 2 y te queda 1 de Aliento. Terminá el turno: la forma te espera.'**
  String get lesForms7;

  /// No description provided for @lesForms8.
  ///
  /// In es, this message translates to:
  /// **'Tercer paso: Bloqueo y contragolpe, una defensa que además pega.'**
  String get lesForms8;

  /// No description provided for @lesForms9.
  ///
  /// In es, this message translates to:
  /// **'Falta Paso atrás y no está en tu mano. Respirar descarta tu mano y roba la misma cantidad de cartas, gratis, una vez por combate. Usalo.'**
  String get lesForms9;

  /// No description provided for @lesForms10.
  ///
  /// In es, this message translates to:
  /// **'¡Ahí está! Último paso: Paso atrás.'**
  String get lesForms10;

  /// No description provided for @lesForms11.
  ///
  /// In es, this message translates to:
  /// **'¡Forma completa! Además del efecto de la carta: 10 de daño, 5 de Estructura y robás 2 cartas.'**
  String get lesForms11;

  /// No description provided for @lesForms12.
  ///
  /// In es, this message translates to:
  /// **'Terminá el combate.'**
  String get lesForms12;

  /// No description provided for @lesClimbSlide1Title.
  ///
  /// In es, this message translates to:
  /// **'La montaña'**
  String get lesClimbSlide1Title;

  /// No description provided for @lesClimbSlide1.
  ///
  /// In es, this message translates to:
  /// **'La subida es un camino de combates por la montaña. En el mapa elegís a qué lugar ir; cuando el camino se abre en dos, decidís vos.'**
  String get lesClimbSlide1;

  /// No description provided for @lesClimbSlide2Title.
  ///
  /// In es, this message translates to:
  /// **'Los lugares del mapa'**
  String get lesClimbSlide2Title;

  /// No description provided for @lesClimbSlide2.
  ///
  /// In es, this message translates to:
  /// **'Cada ícono es un lugar distinto: combates comunes, élites (más fuertes, mejor premio), el jefe al final, la fuente y el santuario.'**
  String get lesClimbSlide2;

  /// No description provided for @lesClimbSlide3Title.
  ///
  /// In es, this message translates to:
  /// **'Después de cada combate'**
  String get lesClimbSlide3Title;

  /// No description provided for @lesClimbSlide3.
  ///
  /// In es, this message translates to:
  /// **'Elegís 1 de 3 cartas para sumar a tu mazo, o ninguna. Un mazo más grande no siempre es mejor: tus mejores cartas salen menos seguido.'**
  String get lesClimbSlide3;

  /// No description provided for @lesClimbSlide4Title.
  ///
  /// In es, this message translates to:
  /// **'Vida y Estructura'**
  String get lesClimbSlide4Title;

  /// No description provided for @lesClimbSlide4.
  ///
  /// In es, this message translates to:
  /// **'Tu Vida NO se recupera sola entre combates: cuidala. En la fuente podés curarte, mejorar una carta o sacar una del mazo. La Estructura sí vuelve completa en cada combate.'**
  String get lesClimbSlide4;

  /// No description provided for @lesClimbSlide5Title.
  ///
  /// In es, this message translates to:
  /// **'El santuario'**
  String get lesClimbSlide5Title;

  /// No description provided for @lesClimbSlide5.
  ///
  /// In es, this message translates to:
  /// **'A mitad de camino elegís un camino: Tigre, Serpiente o Grulla. El Tigre roba más cartas y tiene cartas propias, que solo te salen de recompensa si seguís su camino. La Serpiente y la Grulla pueden RETENER cartas al terminar el turno: esas cartas se guardan y además robás la mano completa.'**
  String get lesClimbSlide5;

  /// No description provided for @lesClimbSlide6Title.
  ///
  /// In es, this message translates to:
  /// **'¡A subir!'**
  String get lesClimbSlide6Title;

  /// No description provided for @lesClimbSlide6.
  ///
  /// In es, this message translates to:
  /// **'Si perdés toda la Vida, la subida termina y se empieza de nuevo. Mirá siempre el globo del rival antes de jugar. ¡Suerte!'**
  String get lesClimbSlide6;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
