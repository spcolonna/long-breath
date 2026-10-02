import '../domain/combat/combat_engine.dart';
import '../domain/model/card_def.dart';
import '../domain/model/enums.dart';
import '../domain/model/form_def.dart';
import '../l10n/app_localizations.dart';
import 'content_text.dart';

/// Traducciones de enums del dominio a texto de interfaz.
extension Labels on AppLocalizations {
  String typeLabel(CardType type) => switch (type) {
    CardType.fist => typeFist,
    CardType.palm => typePalm,
    CardType.kick => typeKick,
    CardType.defense => typeDefense,
    CardType.technique => typeTechnique,
  };

  String heightLabel(Height? h) => switch (h) {
    Height.high => heightHigh,
    Height.mid => heightMid,
    Height.low => heightLow,
    null => '—',
  };

  String difficultyName(Difficulty d) => switch (d) {
    Difficulty.easy => difficultyEasy,
    Difficulty.normal => difficultyNormal,
    Difficulty.hard => difficultyHard,
    Difficulty.shifu => difficultyShifu,
  };

  String difficultyDesc(Difficulty d) => switch (d) {
    Difficulty.easy => difficultyEasyDesc,
    Difficulty.normal => difficultyNormalDesc,
    Difficulty.hard => difficultyHardDesc,
    Difficulty.shifu => difficultyShifuDesc,
  };

  String styleBenefit(Style s) => switch (s) {
    Style.tiger => styleBenefitTiger,
    Style.snake => styleBenefitSnake,
    Style.crane => styleBenefitCrane,
  };

  String stanceHint(Stance s) => switch (s) {
    Stance.mabu => stanceHintMabu,
    Stance.gongbu => stanceHintGongbu,
    Stance.xubu => stanceHintXubu,
  };

  String invalidLabel(Invalid i) => switch (i) {
    Invalid.combatOver => invalidCombatOver,
    Invalid.mustDiscard => invalidMustDiscard,
    Invalid.notInHand => invalidNotInHand,
    Invalid.firstTurnOnly => invalidFirstTurnOnly,
    Invalid.noBreath => invalidNoBreath,
    Invalid.dingbuUsed => invalidDingbuUsed,
    Invalid.sameStance => invalidSameStance,
    Invalid.breatheUsed => invalidBreatheUsed,
    Invalid.retainTooMany => invalidRetainTooMany,
    Invalid.noDiscard => invalidNoDiscard,
  };

  /// Texto corto con el efecto especial de la carta (lo que no se ve en íconos).
  String cardEffect(CardDef d, ContentText text) => [
    if (d.stance != null) effStance(text.stance(d.stance!)),
    if (d.draw > 0) effDraw(d.draw),
    if (d.gainBreath > 0) effBreath(d.gainBreath),
    if (d.bonusDamageIfStaggered > 0)
      effBonusStaggered(d.bonusDamageIfStaggered),
    if (d.onDeflectDamage > 0) effDeflectDamage(d.onDeflectDamage),
    if (d.onDeflectStructure > 0) effDeflectStructure(d.onDeflectStructure),
    if (d.stanceStructureBonus != null)
      effStanceStructure(
        text.stance(d.stanceStructureBonus!.$1),
        d.stanceStructureBonus!.$2,
      ),
    if (d.clearGuard) effClearGuard,
    if (d.turnStructureBonus > 0) effTurnStructure(d.turnStructureBonus),
    if (d.firstTurnOnly) effFirstTurn,
    if (d.exhaust) effExhaust,
  ].join('. ');

  /// Lo que hace una forma al completarse.
  String formEffect(FormEffect e) => [
    if (e.damage > 0) previewDamage(e.damage),
    if (e.structure > 0) previewStructure(e.structure),
    if (e.guard > 0) effGuard(e.guard),
    if (e.heal > 0) effHeal(e.heal),
    if (e.breath > 0) effBreath(e.breath),
    if (e.draw > 0) effDraw(e.draw),
    if (e.fistBonus > 0) effFistBonus(e.fistBonus),
  ].join(' · ');
}
