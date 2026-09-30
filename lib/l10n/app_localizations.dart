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
  /// **'Tocá Puño en arco una vez para ver qué hace y otra vez para jugarla.'**
  String get tutPlayFist;

  /// No description provided for @tutStance.
  ///
  /// In es, this message translates to:
  /// **'La carta te llevó a la postura Arco antes de pegar, y en Arco los puños hacen +3. Cada postura tiene ventajas y costos.'**
  String get tutStance;

  /// No description provided for @tutDefend.
  ///
  /// In es, this message translates to:
  /// **'Ahora defendete. El muñeco va a pegar ALTO y Mostrar la palma da Guardia alta. Si la altura coincide y la Guardia alcanza, desviás el golpe. Jugala con dos toques.'**
  String get tutDefend;

  /// No description provided for @tutKick.
  ///
  /// In es, this message translates to:
  /// **'Quedaste en postura Vacía, donde las patadas cuestan 1 menos: Patada de latigazo ahora es gratis. Jugala.'**
  String get tutKick;

  /// No description provided for @tutForms.
  ///
  /// In es, this message translates to:
  /// **'Puño en arco y Patada de latigazo son los dos primeros pasos del Pequeño Puño Rojo. Si completás una forma en orden, se desata un golpe grande. Las defensas no la interrumpen.'**
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
