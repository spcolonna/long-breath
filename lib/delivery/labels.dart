import '../domain/combat/combat_engine.dart';
import '../domain/model/awakening_def.dart';
import '../domain/model/card_def.dart';
import '../domain/model/enums.dart';
import '../domain/model/event_def.dart';
import '../domain/model/form_def.dart';
import '../domain/model/game_balance.dart';
import '../domain/model/meta_bonus.dart';
import '../domain/model/talisman_def.dart';
import '../l10n/app_localizations.dart';
import 'content_text.dart';

/// Traducciones de enums del dominio a texto de interfaz.
extension Labels on AppLocalizations {
  /// Una línea por cada cosa que hace un don de la escuela.
  List<String> bonusLines(MetaBonus b) => [
    if (b.maxHp != 0) bonusMaxHp(b.maxHp),
    if (b.fountainHeal != 0) bonusFountainHeal(b.fountainHeal),
    if (b.winHeal != 0) bonusWinHeal(b.winHeal),
    if (b.structure != 0) bonusStructure(b.structure),
    if (b.startJade != 0) bonusStartJade(b.startJade),
    if (b.upgradedStarters != 0) bonusUpgradedStarters(b.upgradedStarters),
    if (b.startTalisman != 0) bonusStartTalisman,
    if (b.merchantDiscountPct != 0)
      bonusMerchantDiscount(b.merchantDiscountPct),
    if (b.rewardChoices != 0) bonusRewardChoices(b.rewardChoices),
    if (b.talismanChoices != 0) bonusTalismanChoices(b.talismanChoices),
    if (b.rerolls != 0) bonusRerolls(b.rerolls),
    if (b.lotusPct != 0) bonusLotusPct(b.lotusPct),
    if (b.firstTurnBreath != 0) bonusFirstTurnBreath(b.firstTurnBreath),
    if (b.breathes != 0) bonusBreathes(b.breathes),
  ];

  String branchName(MeridianBranch b) => switch (b) {
    MeridianBranch.body => meridianBranchBody,
    MeridianBranch.spirit => meridianBranchSpirit,
    MeridianBranch.technique => meridianBranchTechnique,
  };

  String lootKind(RewardKind k) => switch (k) {
    RewardKind.cards => lootKindCards,
    RewardKind.jade => lootKindJade,
    RewardKind.lotus => lootKindLotus,
    RewardKind.upgrade => lootKindUpgrade,
    RewardKind.tea => lootKindTea,
    RewardKind.talisman => lootKindTalisman,
  };

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

  String picoRule(int n) => switch (n) {
    1 => picoRule1,
    2 => picoRule2,
    3 => picoRule3,
    4 => picoRule4,
    5 => picoRule5,
    6 => picoRule6,
    7 => picoRule7,
    8 => picoRule8,
    9 => picoRule9,
    _ => picoRule10,
  };

  /// Las reglas que el Pico [n] arrastra de los anteriores.
  String? picoStack(int n) => switch (n) {
    <= 1 => null,
    2 => picoStackedOne,
    _ => picoStacked(n - 1),
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
    if (d.chainDamage > 0) effChain(d.chainDamage),
    if (d.retainedDamage > 0) effRetained(d.retainedDamage),
    if (d.chainStructure > 0) effChainStructure(d.chainStructure),
    if (d.retainedStructure > 0) effRetainedStructure(d.retainedStructure),
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

  /// Lo que enseña un despertar, una frase por efecto.
  String awakeningEffect(AwakeningEffect e) => [
    if (e.firstStrike > 0) awEffFirstStrike(e.firstStrike),
    if (e.firstStrikeStructure > 0)
      awEffFirstStrikeStructure(e.firstStrikeStructure),
    if (e.firstStrikeDiscount > 0)
      awEffFirstStrikeDiscount(e.firstStrikeDiscount),
    if (e.breakDraw > 0) awEffBreakDraw(e.breakDraw),
    if (e.chain > 0) awEffChain(e.chain),
    if (e.chainStructure > 0) awEffChainStructure(e.chainStructure),
    if (e.thirdAttackDraw > 0) awEffThirdAttackDraw(e.thirdAttackDraw),
    if (e.retainedDamage > 0) awEffRetainedDamage(e.retainedDamage),
    if (e.retainedDiscount > 0) awEffRetainedDiscount(e.retainedDiscount),
    if (e.guardBonus > 0) awEffGuardBonus(e.guardBonus),
    if (e.deflectBreath > 0) awEffDeflectBreath(e.deflectBreath),
    if (e.draw > 0) awEffDraw(e.draw),
    if (e.retain > 0) awEffRetain(e.retain),
  ].join(' ');

  /// Lo que hace un talismán, una frase por efecto.
  String talismanEffect(TalismanEffect e, ContentText text) => [
    if (e.startStance != null) talEffStance(text.stance(e.startStance!)),
    if (e.firstTurnBreath > 0) talEffFirstBreath(e.firstTurnBreath),
    if (e.structure > 0) talEffStructure(e.structure),
    if (e.enemyHp > 0) talEffEnemyHp(e.enemyHp),
    if (e.enemyStructure > 0) talEffEnemyStructure(e.enemyStructure),
    if (e.maxHp > 0) talEffMaxHp(e.maxHp),
    if (e.fountainHeal > 0) talEffFountain(e.fountainHeal),
    if (e.winHeal > 0) talEffWinHeal(e.winHeal),
    if (e.deflectBreath > 0) talEffDeflect(e.deflectBreath),
    if (e.formHeal > 0) talEffFormHeal(e.formHeal),
  ].join(' ');

  /// Consecuencias de un resultado de evento, en corto ("−8 Vida · …").
  String eventOutcome(EventOutcome o) {
    final parts = [
      if (o.hp > 0) eventCost(o.hp),
      if (o.heal > 0) eventHeal(o.heal),
      if (o.maxHp > 0) eventMaxHp(o.maxHp),
      if (o.jade > 0) eventJade(o.jade),
      if (o.gain != null)
        switch (o.gain!) {
          EventGain.form => eventGainForm,
          EventGain.talisman => eventGainTalisman,
          EventGain.rareTalisman => eventGainRareTalisman,
          EventGain.card => eventGainCard,
          EventGain.upgrade => eventGainUpgrade,
          EventGain.loseStarter => eventGainLoseStarter,
        },
    ];
    return parts.isEmpty ? eventNothing : parts.join(' · ');
  }

  /// Lo que promete una opción (con riesgo: las dos salidas posibles).
  String eventOptionSummary(EventOptionDef o) {
    final s = o.chance == null
        ? eventOutcome(o.outcome)
        : eventChance(o.chance!, eventOutcome(o.outcome), eventOutcome(o.failure!));
    if (o.price == 0) return s;
    return o.chance == null && s == eventNothing
        ? eventPrice(o.price)
        : '${eventPrice(o.price)} · $s';
  }
}
