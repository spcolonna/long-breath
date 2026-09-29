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

  /// No description provided for @ageTitle.
  ///
  /// In es, this message translates to:
  /// **'Edad (prueba)'**
  String get ageTitle;

  /// No description provided for @ageSummary.
  ///
  /// In es, this message translates to:
  /// **'Robás {draw} · Aliento {breath} · Retenés {retain}'**
  String ageSummary(int draw, int breath, int retain);

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

  /// No description provided for @mapTitle.
  ///
  /// In es, this message translates to:
  /// **'La cueva del dragón'**
  String get mapTitle;

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

  /// No description provided for @dingbu.
  ///
  /// In es, this message translates to:
  /// **'Dīngbù'**
  String get dingbu;

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
  /// **'Ascendiste la cueva'**
  String get runWon;

  /// No description provided for @runLost.
  ///
  /// In es, this message translates to:
  /// **'Caíste en la cueva'**
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
