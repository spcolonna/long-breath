// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Long Breath';

  @override
  String get newRun => 'New run';

  @override
  String get continueRun => 'Continue the climb';

  @override
  String get styleTitle => 'Choose your path';

  @override
  String get homeTagline =>
      'You climb as a novice. The path is chosen on the mountain.';

  @override
  String get shrineNode => 'Shrine';

  @override
  String get shrineTitle => 'Shrine of the Beasts';

  @override
  String get shrineHint =>
      'Two spirits await you. The path you take dyes your robe and changes how you fight, until the end of the climb.';

  @override
  String get shrineConfirm => 'Take this path';

  @override
  String styleSummary(int draw, int breath, int retain) {
    return 'Draw $draw · Breath $breath · Retain $retain';
  }

  @override
  String styleTileStats(int draw, int retain) {
    return 'Draw $draw · Retain $retain';
  }

  @override
  String get styleBenefitTiger =>
      'First Strike: the first attack each turn hits +3. You draw 5 cards per turn, one more than the others. You get the tiger cards and Tiger Fist.';

  @override
  String get styleBenefitSnake =>
      'Chain: each attack hits +1 for every attack you already played this turn. You retain up to 2 cards. You get the snake cards and Snake Fist.';

  @override
  String get styleBenefitCrane =>
      'Patience: you retain up to 3 cards, and retained cards cost 1 less next turn. You get the crane cards and Crane Fist.';

  @override
  String styleChipRetain(String hanzi, int count) {
    return '$hanzi Retain $count';
  }

  @override
  String styleChipDraw(String hanzi, int count) {
    return '$hanzi Draw $count';
  }

  @override
  String get styleBenefitPick => 'Tap a path to see what it gives you.';

  @override
  String stanceDeltaDamage(String value) {
    return '$value damage';
  }

  @override
  String stanceDeltaStructure(String value) {
    return '$value Structure';
  }

  @override
  String stanceDeltaGuard(String value) {
    return '$value guard';
  }

  @override
  String stanceDeltaCost(String value) {
    return '$value cost';
  }

  @override
  String stanceDeltaBy(String changes, String stance) {
    return '$changes from $stance';
  }

  @override
  String formsMissingCards(String forms) {
    return 'You\'re missing cards for: $forms';
  }

  @override
  String effHeal(int n) {
    return 'Heal $n';
  }

  @override
  String effGuard(int n) {
    return '+$n Guard';
  }

  @override
  String effFistBonus(int n) {
    return 'Your fists hit +$n for the rest of combat';
  }

  @override
  String get formScroll => 'Form · 套路';

  @override
  String get formScrollLong => 'Long form · 大套路';

  @override
  String get formLong => 'Long form';

  @override
  String get formScrollHint =>
      'Learning it replaces the card. Play its steps in order to trigger:';

  @override
  String formLearned(String name) {
    return 'You learned $name!';
  }

  @override
  String get formStepOwned => 'You have this card';

  @override
  String get formStepMissing => 'You lack this card';

  @override
  String get fistBonusTitle => 'Chained fists!';

  @override
  String fistBonusNow(int n) {
    return 'Your fists hit +$n all combat';
  }

  @override
  String get life => 'Life';

  @override
  String get structure => 'Structure';

  @override
  String get guard => 'Guard';

  @override
  String get breath => 'Breath';

  @override
  String get deck => 'Deck';

  @override
  String deckCount(int count) {
    return 'Deck: $count';
  }

  @override
  String get fountain => 'Meditation fountain';

  @override
  String get fountainDry => 'The fountain is dry: it heals nothing.';

  @override
  String fountainHeal(int amount) {
    return 'Heal $amount Life';
  }

  @override
  String fountainRemove(int maxHp) {
    return 'Purify: remove 1 card and +$maxHp max Life';
  }

  @override
  String get fountainNoUpgrade => 'You have no cards to temper.';

  @override
  String get fountainRemovePick => 'Choose the card the water carries away';

  @override
  String fountainUpgradePick(int n, int count) {
    return 'Temper: choose card $n of $count';
  }

  @override
  String fountainUpgrade(int count, int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return 'Temper: upgrade $_temp0 (+$amount)';
  }

  @override
  String get chooseCard => 'Choose a card';

  @override
  String get rewardTitle => 'Reward';

  @override
  String get rewardHint =>
      'Choose 1 card, learn the form, or skip. A small deck is more predictable.';

  @override
  String get skip => 'Skip';

  @override
  String get breathe => 'Breathe';

  @override
  String get endTurn => 'End turn';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String drawPile(int count) {
    return 'Draw pile: $count';
  }

  @override
  String discardPile(int count) {
    return 'Discard pile: $count';
  }

  @override
  String retainHint(int count) {
    return 'Tap up to $count card(s) to retain';
  }

  @override
  String get discardHint => 'Screech: choose 1 card to discard';

  @override
  String get tapAgain => 'Tap again to play';

  @override
  String get victory => 'Victory';

  @override
  String get defeat => 'Defeat';

  @override
  String get continueLabel => 'Continue';

  @override
  String discipleN(int n) {
    return 'Disciple No. $n';
  }

  @override
  String resultFellAt(String place) {
    return 'Your breath slips away at $place.';
  }

  @override
  String resultFellTo(String enemy) {
    return '$enemy stands alone in the mist.';
  }

  @override
  String resultFellNo(int n) {
    return 'Disciple No. $n did not return to the school.';
  }

  @override
  String resultSummitAt(String place) {
    return 'You climbed through the clouds to $place.';
  }

  @override
  String resultSummitTo(String enemy) {
    return '$enemy dissolves into golden breath.';
  }

  @override
  String resultSummitNo(int n) {
    return 'Disciple No. $n reached the summit.';
  }

  @override
  String get tabletNovice => 'Novice without a path';

  @override
  String tabletPath(String style) {
    return 'Path of the $style';
  }

  @override
  String tabletFloor(int floor, int floors) {
    return 'Room $floor of $floors';
  }

  @override
  String tabletStats(int hp, int deck) {
    return 'Max Life $hp · Deck $deck';
  }

  @override
  String get loreNew => 'New scroll';

  @override
  String get relayLine => 'The school sends another novice.';

  @override
  String get relaySummit => 'The school asks the next one to climb.';

  @override
  String relayButton(int n) {
    return 'Climb as Disciple No. $n';
  }

  @override
  String get backSchool => 'Return to the school';

  @override
  String get tapToSkip => 'Tap to continue';

  @override
  String get registryTitle => 'School registry';

  @override
  String get registryAscents => 'Ascents';

  @override
  String get registryScrolls => 'Scrolls';

  @override
  String get registryEmpty => 'No climb has ended yet.';

  @override
  String registryFell(String enemy) {
    return 'Fell to $enemy';
  }

  @override
  String get registryFellEarly => 'Fell on the mountain';

  @override
  String get registrySummit => 'Reached the summit';

  @override
  String registrySummary(int fallen, int summits) {
    return '$fallen fallen · $summits at the summit';
  }

  @override
  String get scrollSealed => 'Sealed';

  @override
  String get prologueClimb => 'Climb';

  @override
  String get runWon => 'You reached the summit';

  @override
  String get runLost => 'You fell on the mountain';

  @override
  String get tryAgain => 'Start over';

  @override
  String get backHome => 'Back to home';

  @override
  String get staggered => 'Staggered';

  @override
  String get losesAction => 'Loses its action';

  @override
  String get deflect => 'Deflect!';

  @override
  String get broken => 'Off balance!';

  @override
  String get playerBroken => 'Structure broken';

  @override
  String turn(int n) {
    return 'Turn $n';
  }

  @override
  String get abandon => 'Abandon run';

  @override
  String get typeFist => 'Fist';

  @override
  String get typePalm => 'Palm';

  @override
  String get typeKick => 'Kick';

  @override
  String get typeDefense => 'Defense';

  @override
  String get typeTechnique => 'Technique';

  @override
  String get heightHigh => 'high';

  @override
  String get heightMid => 'mid';

  @override
  String get heightLow => 'low';

  @override
  String get rankCommon => 'Common foe';

  @override
  String get rankElite => 'Elite';

  @override
  String get enemyInfoHp => 'Life';

  @override
  String get enemyInfoStructure => 'Structure';

  @override
  String get enemyInfoScales => 'Scales';

  @override
  String get enemyInfoRule => 'ITS STYLE';

  @override
  String get enemyInfoNow => 'NEXT MOVE';

  @override
  String get enemyInfoClose => 'Tap to roll up';

  @override
  String get intentTagInterrupt => 'Breaks forms';

  @override
  String get intentTagSameStance => 'Punishes repeats';

  @override
  String get intentTagWear => 'Wears Guard';

  @override
  String intentTagDrain(int n) {
    return '−$n Breath';
  }

  @override
  String intentTagFreeze(int n) {
    return '−$n draw';
  }

  @override
  String get rankBoss => 'Guardian';

  @override
  String waveOf(int index, int total) {
    return '$index of $total';
  }

  @override
  String waveGroupTitle(int n) {
    return 'Group of $n';
  }

  @override
  String get waveGroupSub =>
      'They come one after another: when one falls, the next steps in';

  @override
  String get waveNext => 'Next:';

  @override
  String get merchantMore => 'More below';

  @override
  String get resultCopyLog => 'Copy log';

  @override
  String get resultLogCopied => 'Climb log copied';

  @override
  String lootTotal(int before, int after) {
    return 'You carry $before → $after';
  }

  @override
  String get comboHits => 'hits';

  @override
  String get merchantWandering => 'A wandering merchant crosses your path';

  @override
  String get fountainNode => 'Fountain';

  @override
  String intentAttack(String height) {
    return '$height attack';
  }

  @override
  String intentNamedAttack(String name, String height) {
    return '$name ($height)';
  }

  @override
  String get intentCharge => 'Charge';

  @override
  String intentChargeDetail(int n) {
    return 'Next attack +$n';
  }

  @override
  String get intentDiscard => 'Discard';

  @override
  String intentDiscardDetail(int n) {
    return 'You discard $n';
  }

  @override
  String get intentInterrupt => 'Interrupts your forms unless you deflect it';

  @override
  String get intentSameStance => 'If you end in this stance: +4 damage, +2 S';

  @override
  String get countdown => 'turns';

  @override
  String get staggeredDouble => 'Staggered · damage ×2';

  @override
  String previewThen(String stance) {
    return 'then $stance';
  }

  @override
  String previewDamage(int n) {
    return '$n damage';
  }

  @override
  String previewStructure(int n) {
    return '$n S';
  }

  @override
  String previewCompletes(String name) {
    return 'completes $name!';
  }

  @override
  String previewAdvances(String name) {
    return 'advances $name';
  }

  @override
  String previewInterrupts(String name) {
    return '⚠ interrupts $name';
  }

  @override
  String get stanceHintMabu => 'Fists and palms +2 · S taken ½ · kicks +1 cost';

  @override
  String get stanceHintGongbu => 'Fists +3 damage and +1 S · you take +2 S';

  @override
  String get stanceHintXubu =>
      'Kicks −1 cost and +2 · deflection +1 Breath · defenses −2';

  @override
  String changeStance(String breath) {
    return 'Change stance · 1 $breath';
  }

  @override
  String get formsInterrupted => 'Forms interrupted';

  @override
  String get enemyPhase2 => 'Second phase!';

  @override
  String get enemyPhase3 => 'Final phase!';

  @override
  String get formCompleted => 'Form complete!';

  @override
  String effStance(String name) {
    return 'Shift to $name';
  }

  @override
  String effDraw(int n) {
    return 'Draw $n';
  }

  @override
  String effBreath(int n) {
    return '+$n Breath';
  }

  @override
  String effBonusStaggered(int n) {
    return '+$n if the enemy is Staggered';
  }

  @override
  String effDeflectDamage(int n) {
    return 'If you deflect, $n damage';
  }

  @override
  String effDeflectStructure(int n) {
    return 'If you deflect, the enemy loses $n extra S';
  }

  @override
  String effStanceStructure(String name, int n) {
    return 'In $name, +$n S';
  }

  @override
  String get effClearGuard => 'You lose all your Guard';

  @override
  String effTurnStructure(int n) {
    return 'This turn, all Structure damage +$n';
  }

  @override
  String get effFirstTurn => 'First turn only';

  @override
  String get effExhaust => 'Exhaust';

  @override
  String get invalidCombatOver => 'The combat is over';

  @override
  String get invalidMustDiscard => 'Choose a card to discard';

  @override
  String get invalidNotInHand => 'That card isn\'t in your hand';

  @override
  String get invalidFirstTurnOnly => 'First turn only';

  @override
  String get invalidNoBreath => 'Not enough Breath';

  @override
  String get invalidDingbuUsed => 'You already changed stance this turn';

  @override
  String get invalidSameStance => 'You\'re already in that stance';

  @override
  String get invalidBreatheUsed => 'Breathe isn\'t charged';

  @override
  String get invalidStructureFull => 'Your Structure is already full';

  @override
  String get breatheModeTitle => 'How do you breathe?';

  @override
  String get breatheModeHand => 'Change your hand';

  @override
  String breatheModeHandSub(int n) {
    return 'Discard everything and draw $n or more';
  }

  @override
  String get breatheModeBreath => 'Recover Breath';

  @override
  String breatheModeBreathSub(int n) {
    return '+$n Breath now';
  }

  @override
  String get breatheModeStructure => 'Recover Structure';

  @override
  String breatheModeStructureSub(int n) {
    return '+$n Structure';
  }

  @override
  String breatheCharges(int charges, int progress, int at) {
    return 'Breathe: $charges charges, $progress of $at toward the next';
  }

  @override
  String get breatheReady => 'Breathe charged';

  @override
  String get invalidNoCounter => 'You have no Counter ready';

  @override
  String get invalidFlowFull => 'Your Flow is already at max';

  @override
  String get counter => 'Counter';

  @override
  String get counterTitle => 'Counter';

  @override
  String get counterSub =>
      'You deflected: choose your answer. If you don\'t use it, it\'s lost at the end of the turn.';

  @override
  String get counterFree => 'Free strike';

  @override
  String get counterFreeSub => 'The next card you play costs no Breath';

  @override
  String get counterDraw => 'Read the foe';

  @override
  String counterDrawSub(int n) {
    return 'Draw $n cards';
  }

  @override
  String get counterFlow => 'Seize the rhythm';

  @override
  String get counterFlowSub => '+1 Flow';

  @override
  String get counterReady => 'Counter!';

  @override
  String get counterFreeActive => 'Next card free';

  @override
  String get invalidNoTechnique => 'You need full Flow';

  @override
  String get technique => 'Path Technique';

  @override
  String get techniqueSub => 'Spends all your Flow on your path\'s finisher.';

  @override
  String get techniqueUse => 'Use the technique';

  @override
  String get techTiger => 'Tiger\'s Claw';

  @override
  String techTigerSub(int d, int s) {
    return 'One strike of $d damage and $s Structure';
  }

  @override
  String get techSnake => 'Chain Bite';

  @override
  String techSnakeSub(int n, int d, int s) {
    return '$n strikes of $d damage and $s Structure each';
  }

  @override
  String get techCrane => 'Flight of the Crane';

  @override
  String techCraneSub(int d, int g, int n) {
    return 'Strike for $d, +$g Guard and draw $n cards';
  }

  @override
  String get invalidRetainTooMany => 'You\'re retaining too many cards';

  @override
  String get invalidNoDiscard => 'Nothing to discard';

  @override
  String get invalidBadTarget => 'That one can\'t be targeted';

  @override
  String get chestTitle => 'The room\'s chest';

  @override
  String get invalidMustBreathe => 'First choose what to do in the respite';

  @override
  String get invalidNoBreather => 'There\'s no respite now';

  @override
  String get breatherTitle => 'Respite';

  @override
  String breatherSub(String name) {
    return 'Before $name arrives';
  }

  @override
  String get breatherRest => 'Recover';

  @override
  String breatherRestHint(int count) {
    return 'Recover $count Life.';
  }

  @override
  String get breatherFocus => 'Focus';

  @override
  String breatherFocusHint(int draw, int breath) {
    return 'Draw $draw cards and gain $breath Breath.';
  }

  @override
  String get breatherFist => 'Sharpen your fists';

  @override
  String breatherFistHint(int count) {
    return '+$count to your fist damage this combat.';
  }

  @override
  String get partOfForm => 'Part of a form';

  @override
  String get tutStart => 'Start training';

  @override
  String get tutSkipToRun => 'I know how to play: new run';

  @override
  String get tutReplay => 'Repeat training';

  @override
  String get tutSkip => 'Skip';

  @override
  String get tutNext => 'Next';

  @override
  String get tutMaster => 'Master';

  @override
  String get tutGo => 'Let\'s go!';

  @override
  String get tutClimb => 'Begin the climb';

  @override
  String get tutHome => 'Back to home';

  @override
  String get tutWelcome =>
      'Welcome to the courtyard of the Sleeping Dragon school. Before climbing the mountain, you\'ll practice with the wooden dummy. I\'ll guide you.';

  @override
  String get tutIntent =>
      'This bubble shows what the dummy will do on its turn: a HIGH strike (up arrow) for 4 damage and 2 to your Structure (S). The enemy always warns you before acting.';

  @override
  String get tutEnemy =>
      'Its Life (red) and its Structure (violet). Bring its Life to 0 to win. Empty its Structure and it becomes Staggered: it loses its action and takes double damage.';

  @override
  String get tutPlayer =>
      'This is you: your Life, your Structure, your current stance (Horse) and your Guard, the shield on the right.';

  @override
  String get tutHand =>
      'Your hand. The number at the top left of each card is its Breath cost. You have 3 per turn, and whatever you don\'t spend is lost. Press and hold a card to read it; underlined words can be tapped.';

  @override
  String get tutPlayFist =>
      'Tap Full Punch once to see what it does, and again to play it.';

  @override
  String get tutDefend =>
      'Now defend yourself. The dummy will strike HIGH, and Step Back gives high Guard. If the height matches and your Guard is enough, you deflect the strike. Play it with two taps.';

  @override
  String get tutKick =>
      'You\'re now in Empty stance, where kicks cost 1 less: Whip Kick is free now. Play it.';

  @override
  String get tutForms =>
      'Full Punch and Whip Kick are the first two steps of Little Red Fist. Complete a form in order and a big strike is unleashed. Defenses don\'t interrupt it.';

  @override
  String get tutEndTurn =>
      'Your Guard is ready. End the turn and see what happens.';

  @override
  String get tutDeflect =>
      'Deflect! You took no damage, the dummy lost Structure and is Staggered: it loses its action and takes double. The deflection also gives you extra Breath this turn.';

  @override
  String get tutActions =>
      'Two aids: T-Step changes your stance for 1 Breath, once per turn. Breathe charges when you deflect, complete a form, or end the turn with unspent Breath; when you use it, you choose: change your hand, recover Breath, or recover Structure.';

  @override
  String get tutFree =>
      'Now finish it yourself. While it\'s Staggered, every strike counts double.';

  @override
  String get tutDone =>
      'Well done! On the mountain, after each combat you add a card to your deck. Life doesn\'t recover on its own, only at the fountain. Halfway up, the Shrine offers you two paths. And always check the bubble before you play.';

  @override
  String get blocked => 'Blocked';

  @override
  String get yourTurn => 'Your turn';

  @override
  String endSummaryWon(int turns, int hp, int maxHp) {
    String _temp0 = intl.Intl.pluralLogic(
      turns,
      locale: localeName,
      other: 'In $turns turns',
      one: 'In 1 turn',
    );
    return '$_temp0 · Life $hp/$maxHp';
  }

  @override
  String endSummaryLost(String name, int hp) {
    return '$name held on with $hp Life';
  }

  @override
  String get fightStart => 'En garde!';

  @override
  String get soundEffects => 'Sound effects';

  @override
  String get music => 'Music';

  @override
  String get options => 'Options';

  @override
  String get vibration => 'Vibration';

  @override
  String get motionTitle => 'Motion';

  @override
  String get motionSystem => 'Match system';

  @override
  String get motionFull => 'Full';

  @override
  String get motionReduced => 'Reduced';

  @override
  String get motionHint =>
      'Reduced removes shakes, particles, special transitions and looping animations.';

  @override
  String get menuLearn => 'Learn to play';

  @override
  String menuLearnProgress(int done, int total) {
    return '$done of $total lessons';
  }

  @override
  String get menuStartHere => 'Start here';

  @override
  String get difficultyTitle => 'How do you want to climb?';

  @override
  String get difficultySubtitle =>
      'Fixed for this save slot. To play another, use another save slot.';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyNormal => 'Normal';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get difficultyShifu => 'Shifu';

  @override
  String get difficultyEasyDesc =>
      'To learn the mountain at your own pace. More Life and softer foes.';

  @override
  String get difficultyNormalDesc => 'The climb as it was meant to be.';

  @override
  String get difficultyHardDesc =>
      'Tougher foes and a fountain that heals less.';

  @override
  String get difficultyShifuDesc =>
      'For masters: less Life, and every mistake costs you.';

  @override
  String get difficultyLocked => 'Locked';

  @override
  String get difficultyShifuLocked => 'Unlocks after winning a climb on Hard.';

  @override
  String difficultyStats(int hp, int heal, int enemy) {
    return 'Life $hp · Fountain +$heal · Foes $enemy%';
  }

  @override
  String scales(int count) {
    return 'Scales $count · −$count per hit';
  }

  @override
  String get scaleShed => 'Scale torn off!';

  @override
  String get scalesRegrown => 'Its scales grow back!';

  @override
  String scalesNow(int count) {
    return 'Now has $count';
  }

  @override
  String scalesLeft(int count) {
    return '$count left';
  }

  @override
  String get menuClimb => 'The Climb';

  @override
  String get menuClimbSubtitle => 'Mountain of a Thousand Clouds';

  @override
  String get menuReplaceRunTitle => 'Start a new climb?';

  @override
  String get menuReplaceRunBody =>
      'You have a saved climb. If you start another, it will be lost.';

  @override
  String get menuReplaceRunOk => 'Start over';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get lessonsTitle => 'Learn to play';

  @override
  String get lessonsIntro =>
      'Short lessons with the master. Each one unlocks when you finish the previous one, and you can replay them whenever you like.';

  @override
  String get lessonLocked => 'Complete the previous lesson';

  @override
  String lessonMinutes(int n) {
    return '$n min';
  }

  @override
  String lessonNumber(int n) {
    return 'Lesson $n';
  }

  @override
  String get lessonDoneTitle => 'Lesson complete';

  @override
  String get lessonNext => 'Next lesson';

  @override
  String get lessonBackToList => 'Back to lessons';

  @override
  String get lessonRetry => 'Retry';

  @override
  String get lessonLostHint => 'No harm done: it\'s practice. Try again.';

  @override
  String get lessonAllDone =>
      'You finished your training! Now you can climb the mountain.';

  @override
  String get lesStrikeTitle => 'Your first strike';

  @override
  String get lesStrikeBlurb =>
      'The screen, the cards, Breath and how to attack.';

  @override
  String get lesStrikeDone =>
      'You learned to read a card, use your Breath and attack.';

  @override
  String get lesDefendTitle => 'The foe warns you';

  @override
  String get lesDefendBlurb =>
      'Reading the foe\'s bubble, Guard, heights and deflection.';

  @override
  String get lesDefendDone =>
      'You learned to read your foe and defend at the right height.';

  @override
  String get lesStancesTitle => 'Stances';

  @override
  String get lesStancesBlurb =>
      'Horse, Bow and Empty: set your stance before you strike.';

  @override
  String get lesStancesDone =>
      'You learned to set your stance before you strike.';

  @override
  String get lesStructureTitle => 'Structure';

  @override
  String get lesStructureBlurb =>
      'Throw your foe off balance and keep your own.';

  @override
  String get lesStructureDone =>
      'You learned to stagger your foe to hit for double.';

  @override
  String get lesFormsTitle => 'Forms';

  @override
  String get lesFormsBlurb => 'Chain steps for an extra strike, and Breathe.';

  @override
  String get lesFormsDone => 'You learned to complete a form and to Breathe.';

  @override
  String get lesClimbTitle => 'The Climb';

  @override
  String get lesClimbBlurb =>
      'The trail, the doors, the rewards, the fountain and the Paths.';

  @override
  String get pauseTitle => 'Pause';

  @override
  String get pauseResume => 'Keep fighting';

  @override
  String get pauseHowTo => 'How to play';

  @override
  String get pauseToMenu => 'Back to menu';

  @override
  String get pauseToMenuHint =>
      'Your climb is saved: \"Continue\" takes you back to the doors, before this fight.';

  @override
  String get pauseRestartLesson => 'Restart lesson';

  @override
  String get pauseExitLesson => 'Exit to lessons';

  @override
  String get mapHome => 'Main menu';

  @override
  String get mapMore => 'More options';

  @override
  String get abandonConfirmTitle => 'Abandon the climb?';

  @override
  String get abandonConfirmBody => 'All progress on this climb will be lost.';

  @override
  String get illCardTitle => 'How to read a card';

  @override
  String get illCost => 'Breath cost';

  @override
  String get illType => 'Type';

  @override
  String get illName => 'Name';

  @override
  String get illStatsDamage => 'Life damage';

  @override
  String get illStatsStructure => 'Structure damage';

  @override
  String get nodeCombat => 'Combat';

  @override
  String get illStance => 'Stance it leaves you in, after acting';

  @override
  String get illGuard => 'Guard and its height';

  @override
  String get illIntentTitle => 'The foe\'s bubble';

  @override
  String get illIntentAttack =>
      'Attack: the arrow is the height, the number is the damage and S is the damage to your Structure.';

  @override
  String get illIntentGuard => 'Covers up: gains Guard against your next hits.';

  @override
  String get illIntentCharge =>
      'Charge: gathers strength; its next hit lands harder.';

  @override
  String get illIntentDiscard => 'Screech: makes you discard cards.';

  @override
  String get illHeightsTitle => 'Heights';

  @override
  String get illHeightsSame =>
      'Same height: Guard absorbs it all. If it\'s enough, you deflect the hit (化).';

  @override
  String get illHeightsOther => 'Different height: Guard absorbs only half.';

  @override
  String get illHigh => 'High';

  @override
  String get illMid => 'Mid';

  @override
  String get illLow => 'Low';

  @override
  String get illStancesTitle => 'Stances';

  @override
  String get illStanceMabuPro =>
      'Fists and palms +2. You take half Structure damage.';

  @override
  String get illStanceMabuCon => 'Kicks cost 1 more.';

  @override
  String get illStanceGongbuPro => 'Fists +3 damage and +1 Structure.';

  @override
  String get illStanceGongbuCon => 'You take 2 more Structure damage.';

  @override
  String get illStanceXubuPro =>
      'Kicks: cost 1 less and hit +2. Deflecting gives +1 extra Breath.';

  @override
  String get illStanceXubuCon => 'Defenses give 2 less Guard.';

  @override
  String get illTurnTitle => 'Order of a turn';

  @override
  String get illTurn1 =>
      'Your Guard resets to 0, you draw cards and recover your Breath.';

  @override
  String get illTurn2 =>
      'You play cards: tap one to see what it does, and again to play it.';

  @override
  String get illTurn3 =>
      'You end your turn: the cards left over are discarded.';

  @override
  String get illTurn4 =>
      'The foe does what its bubble announced and announces the next move.';

  @override
  String get illBrokenTitle => 'Staggered';

  @override
  String get illBroken =>
      'If the foe\'s Structure hits 0, it loses its next action and takes double damage until the end of your next turn. If it happens to you, you start your next turn with 2 less Breath.';

  @override
  String get illFormsTitle => 'Forms';

  @override
  String get illForms =>
      'Fixed sequences of cards. Play them in order and the last step triggers the form\'s effect (a strike, Breath, healing…). An attack out of order interrupts it; defenses and techniques don\'t. On the climb, you learn them as rewards.';

  @override
  String get lesStrike1 =>
      'Welcome. This is turn-based combat: you\'re on the left, and the wooden dummy is your foe. On your turn you play cards; then the foe takes its turn. I\'ll explain everything, step by step.';

  @override
  String get lesStrike2 =>
      'This is you. The green bar is your Life: if it reaches 0, you lose. The violet one is your Structure, your balance: you\'ll see what it\'s for later on.';

  @override
  String get lesStrike3 =>
      'This is your foe: its name, its Life (red) and its Structure (violet). To win, bring its Life to 0.';

  @override
  String get lesStrike4 =>
      'These are your cards: your hand. Each turn you draw 5 new cards from your deck.';

  @override
  String get lesStrike5 =>
      'Here\'s how to read a card. Top left, its cost; top right, its type. In the center, the name in English with a drawing of the move (or its Chinese name). At the bottom, what it does: the red bolt is Life damage and the violet hexagon is Structure damage. If it shows → and a stance, it leaves you in that stance after acting.';

  @override
  String get lesStrike6 =>
      'These dots are your Breath, your energy for the turn. You have 3, and each card costs what its circle says. Whatever you don\'t spend is lost when the turn ends.';

  @override
  String get lesStrike7 => 'Tap Firm Punch just ONCE.';

  @override
  String get lesStrike8 =>
      'This is the preview: it shows exactly what will happen, with every bonus already added. To play the card, tap it again.';

  @override
  String get lesStrike9 =>
      'Hit! You took 7 Life (5 from the card + 2 for being in Horse stance) and 2 Structure. Watch its bars drop. Your Breath went from 3 to 2.';

  @override
  String get lesStrike10 =>
      'Now Palm Push: it does little damage but takes a lot of Structure. Tap it twice.';

  @override
  String get lesStrike11 =>
      'You have 1 Breath left: play the other Firm Punch.';

  @override
  String get lesStrike12 =>
      'You\'re out of Breath. Cards you can\'t pay for are dimmed: Whip Kick costs 2 in Horse stance. The cards you didn\'t play are discarded when the turn ends.';

  @override
  String get lesStrike13 =>
      'Before you end, look at this bubble: it\'s what the foe will do on its turn. The arrow → is the height (MID), 5 is the damage to your Life and S 2 the damage to your Structure. The foe always warns you before acting.';

  @override
  String get lesStrike14 =>
      'You don\'t have any defenses yet, so it\'s going to hit you. Tap End turn and watch.';

  @override
  String get lesStrike15 =>
      'It hit you: the red number was the damage to your Life, 5. Your Structure dropped only 1 because in Horse you take half. In the next lesson you\'ll learn to defend yourself.';

  @override
  String get lesStrike16 =>
      'Your turn 2 has begun: you drew 5 new cards and your Breath is back to 3. That\'s how every turn starts.';

  @override
  String get lesStrike17 =>
      'The dummy has 10 Life left. Finish it off yourself: pick whichever cards you like.';

  @override
  String get lesDefend1 =>
      'The most important thing in the game: reading the foe\'s bubble. The arrow is the HEIGHT of the hit: ↑ high, → mid, ↓ low. The number is the damage and S the damage to your Structure.';

  @override
  String get lesDefend2 =>
      'Defense cards give you Guard: a shield that absorbs the foe\'s hit. Each defense protects one HEIGHT. The dummy will strike HIGH, and High Block protects up top with 9 Guard.';

  @override
  String get lesDefend3 => 'Play it: two taps.';

  @override
  String get lesDefend4 =>
      'This is your Guard: 9, high. If the hit comes at the same height and your Guard is enough to cover it, you DEFLECT it (化): you take nothing, the foe loses 3 Structure and you gain 1 Breath for your next turn.';

  @override
  String get lesDefend5 => 'With the Breath you have left, hit it: Firm Punch.';

  @override
  String get lesDefend6 => 'End the turn and watch.';

  @override
  String get lesDefend7 =>
      'Deflection! You took no damage and its Structure dropped 3. This is fighting well: read the bubble and answer at the right height.';

  @override
  String get lesDefend8 =>
      'Your Guard is back to 0: it only lasts through the foe\'s turn, so you have to defend every turn. And notice you have 4 Breath: +1 for the deflection.';

  @override
  String get lesDefend9 =>
      'Now a MID (→) hit is coming for 6 damage, and the only defense you have is LOW.';

  @override
  String get lesDefend10 =>
      'Play Low Block anyway, to see what happens at the wrong height.';

  @override
  String get lesDefend11 => 'End the turn.';

  @override
  String get lesDefend12 =>
      'Wrong height: Guard absorbed only half and you took 3 damage. Height matters as much as the number.';

  @override
  String get lesDefend13 =>
      'Every foe has a rule of its own. Tap the foe\'s name whenever you want to read it.';

  @override
  String get lesDefend14 =>
      'Now a LOW (↓) hit is coming and you have Low Block. Defend well and finish it off.';

  @override
  String get lesStances1 =>
      'You\'re always in one of three stances: Horse 马步, Bow 弓步 or Empty 虚步. Right now you\'re in Horse. The stance you\'re IN changes how hard your cards hit and how much they cost.';

  @override
  String get lesStances2 =>
      'Here\'s what each stance gives. You can see it again anytime from the pause menu, under \"How to play\".';

  @override
  String get lesStances3 => 'Tap Lunge Punch once and look at the preview.';

  @override
  String get lesStances4 =>
      'Look at the damage: 8 with a green ▲. The base card does 6, but you strike from Horse, which adds +2 to fists: the ▲ marks what the stance adds, and above it says \"+2 damage from Mǎbù\". If a stance takes something away, you\'ll see a red ▼. Below, → Bow is the stance it leaves you in AFTER striking. Play it.';

  @override
  String get lesStances5 =>
      'Now you\'re in Bow: fists hit +3 and take +1 Structure. The card that brought you here didn\'t use that edge: the NEXT one does.';

  @override
  String get lesStances6 =>
      'Look at Firm Punch: before it showed 7 damage and 2 Structure; now, 8 and 3. Your card numbers always show what they hit from the stance you\'re in. It strikes from Bow and then leaves you in Horse. Play it.';

  @override
  String get lesStances7 =>
      'That\'s the trick: a card with → sets up the next one. Before playing, think about the order: first the one that leaves you in the stance the other one uses.';

  @override
  String get lesStances8 =>
      'If no card leaves you in the stance you need, T-Step changes it NOW, for 1 Breath, once per turn. Kicks shine in Empty: tap it and choose Empty.';

  @override
  String get lesStances9 =>
      'In Empty, kicks cost 1 less and hit +2: Whip Kick now costs 0 (the cost turns green) and does 7 ▲. Play it.';

  @override
  String get lesStances10 =>
      'Finish the fight however you like. Before each card, check which stance you\'re in and which one it leaves you in.';

  @override
  String get lesStructure1 =>
      'This dummy has little Structure: 8. Every attack has two numbers: the red bolt is Life damage and the violet hexagon is Structure damage. If the foe\'s Structure reaches 0, it becomes STAGGERED.';

  @override
  String get lesStructure2 =>
      'Palm Push barely does damage, but it takes 4 Structure. Play it.';

  @override
  String get lesStructure3 => 'Again: it has 4 left.';

  @override
  String get lesStructure4 =>
      'Staggered! See the stars. It loses the action it announced and takes DOUBLE damage until the end of your next turn.';

  @override
  String get lesStructure5 =>
      'Take advantage: Firm Punch. The preview already shows double damage.';

  @override
  String get lesStructure6 =>
      'Its bubble said it was going to cover up (the foe\'s Guard absorbs the Life damage of your hits, but not Structure). Now it\'s dimmed: it loses that action.';

  @override
  String get lesStructure7 =>
      'You have Structure too. If the foe empties it, you start your next turn with 2 less Breath. Defending well protects it.';

  @override
  String get lesStructure8 => 'End the turn.';

  @override
  String get lesStructure9 =>
      'It lost its action. Now it announces Charge (the lightning icon): on its turn it won\'t attack you; it gathers strength and its next hit will do 4 more. When you see a charge, get ready.';

  @override
  String get lesStructure10 =>
      'It stays staggered for this whole turn: your hits count double. Finish it.';

  @override
  String get lesForms1 =>
      'A form (套路) is a fixed sequence of cards. Play them in order and, when you complete the last step, an extra strike is added. This one is Little Red Fist: Lunge Punch → Whip Kick → Block and Counter → Step Back.';

  @override
  String get lesForms2 => 'First step: Lunge Punch.';

  @override
  String get lesForms3 => 'Second step: Whip Kick.';

  @override
  String get lesForms4 =>
      'Two steps marked. Progress isn\'t lost when the turn ends: the form waits for you.';

  @override
  String get lesForms5 => 'Tap Palm Push ONCE, without playing it.';

  @override
  String get lesForms6 =>
      'See the warning triangle: an attack (fist, palm or kick) that isn\'t the next step INTERRUPTS the form, and you have to start over. Defenses and techniques never interrupt it.';

  @override
  String get lesForms7 =>
      'The third step costs 2 and you have 1 Breath left. End the turn: the form waits for you.';

  @override
  String get lesForms8 =>
      'Third step: Block and Counter, a defense that also strikes.';

  @override
  String get lesForms8b =>
      'You have 1 Breath left: not enough to Breathe and play Step Back. End the turn; the form waits for you.';

  @override
  String get lesForms9 =>
      'Step Back is missing and it\'s not in your hand. Tap Breathe and choose «Change hand»: it discards your hand and draws the same number of cards (at least 3) for 1 Breath. It uses one charge; it recharges when you deflect, close forms or save Breath. Use it.';

  @override
  String get lesForms10 => 'There it is! Last step: Step Back.';

  @override
  String get lesForms11 =>
      'Form complete! On top of the card\'s effect: 14 damage, 6 Structure, and you draw 2 cards. On the climb, you learn forms as rewards for winning fights.';

  @override
  String get lesForms12 => 'Finish the fight.';

  @override
  String get lesClimbSlide1Title => 'The mountain';

  @override
  String get lesClimbSlide1 =>
      'Each stage is a trail of 13 rooms up the mountain. After each room you choose between two or three doors, and each fight shows what reward lies on the other side. The altitude bar shows how far you\'ve climbed and where the guardian, the fountain and the boss await.';

  @override
  String get lesClimbSlide2Title => 'The doors';

  @override
  String get lesClimbSlide2 =>
      'Each seal is a place: a common fight (武), the guardian or a detour with a strong foe who drops a talisman (精), the boss (龙), the fountain (泉), the shrine (庙), an event (缘), the wandering master (师) and the merchant (商). You can\'t dodge every fight: the trail always puts foes in your way.';

  @override
  String get lesClimbSlide3Title => 'The chest';

  @override
  String get lesClimbSlide3 =>
      'When you win a room, its chest opens with the reward the door showed. If it\'s scrolls, you choose ONE thing: 1 of 3 cards for your deck, learn the form on offer, or nothing. You start with no forms: each one you learn stays for the whole climb and has its own effect (a strike, Breath, healing…). A bigger deck isn\'t always better: your best cards come up less often.';

  @override
  String get lesClimbSlide4Title => 'Life and Structure';

  @override
  String get lesClimbSlide4 =>
      'Your Life does NOT recover between rooms: guard it. You heal at the fountain, with tea (a reward from some doors or the merchant), with some talismans and by breathing deep after clearing a stage. Structure does come back in full every fight.';

  @override
  String get lesClimbSlide5Title => 'The shrine';

  @override
  String get lesClimbSlide5 =>
      'Halfway up you choose a Path: Tiger, Snake or Crane. The Tiger draws more cards and has its own cards and Tiger Fist, which only show up as rewards if you follow its Path. The Snake and the Crane can RETAIN cards at the end of the turn: those cards are kept and you still draw a full hand. The Snake is also offered Snake Fist.';

  @override
  String get lesClimbSlide6Title => 'Up you go!';

  @override
  String get lesClimbSlide6 =>
      'If you lose all your Life, that disciple doesn\'t return: the school sends another novice, who starts from scratch. Always check the foe\'s bubble before playing. Good luck!';

  @override
  String get eventNode => 'Event';

  @override
  String get combatNode => 'Path';

  @override
  String get optionalEliteTag => 'Detour';

  @override
  String get mapPickHint => 'Choose where to keep climbing';

  @override
  String pathTitle(int n, int total) {
    return 'Room $n of $total';
  }

  @override
  String pathReward(String kind) {
    return 'On the other side: $kind.';
  }

  @override
  String combatAltitude(String meters, int n, int total) {
    return '$meters · $n/$total';
  }

  @override
  String get mapGo => 'Go';

  @override
  String get nodeHintCommon => 'A foe on the trail.';

  @override
  String get nodeHintElite => 'The stage guardian: more risk, and a talisman.';

  @override
  String get nodeHintDetour =>
      'A detour with a strong foe. You can skip it, but it pays like no other: a rare talisman, rare cards and jade.';

  @override
  String get nodeHintBoss => 'The guardian of the summit.';

  @override
  String nodeHintPack(int count) {
    return '$count foes are coming.';
  }

  @override
  String get nodeHintFountain =>
      'Clear water: heal Life, temper two cards or purify your deck.';

  @override
  String get nodeHintShrine => 'A sacred animal offers you its blessing.';

  @override
  String get nodeHintEvent =>
      'An encounter on the trail. It may help you or cost you something.';

  @override
  String get nodeHintMerchant =>
      'Cards, items and services in exchange for jade.';

  @override
  String get nodeHintMaster => 'A master teaches you a new form.';

  @override
  String get formMissingShort => 'Cards missing';

  @override
  String eventCost(int n) {
    return '−$n Life';
  }

  @override
  String eventHeal(int n) {
    return '+$n Life';
  }

  @override
  String eventMaxHp(int n) {
    return '+$n max Life';
  }

  @override
  String get eventGainForm => 'you learn a form';

  @override
  String get eventGainTalisman => 'a talisman';

  @override
  String get eventGainRareTalisman => 'a rare talisman';

  @override
  String get eventGainCard => 'a random new card';

  @override
  String get eventGainUpgrade => 'upgrade a random card';

  @override
  String get eventGainLoseStarter => 'lose a random starting card';

  @override
  String get eventGainPathCards => 'choose 1 of 3 cards from your Path';

  @override
  String get eventGainRareCards => 'choose 1 of 3 rare or legendary cards';

  @override
  String get eventGainPickUpgrade => 'choose which card to upgrade';

  @override
  String get eventGainPathTalisman => 'your Path\'s talisman';

  @override
  String eventDuel(String enemy) {
    return 'Duel with $enemy · if you win: a talisman of your choice and jade';
  }

  @override
  String get eventDuelGo => 'Fight!';

  @override
  String get eventChoose => 'Choose';

  @override
  String get eventPathTiger => 'Trial of the Tiger';

  @override
  String get eventPathSnake => 'Trial of the Snake';

  @override
  String get eventPathCrane => 'Trial of the Crane';

  @override
  String get eventNothing => 'no change';

  @override
  String get eventGainFight => 'you must fight';

  @override
  String get eventGainTemper => 'temper your weapon';

  @override
  String get eventGainMark => 'continues higher up';

  @override
  String eventNeedWith(String name) {
    return 'With $name';
  }

  @override
  String get eventBack => 'An old acquaintance';

  @override
  String eventResultTemper(String name, int n) {
    return 'Tempered: $name (level $n)';
  }

  @override
  String get eventResultMark => 'This continues higher up';

  @override
  String eventChance(int pct, String ok, String fail) {
    return '$pct%: $ok · otherwise: $fail';
  }

  @override
  String get eventCantPay => 'Not enough Life';

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
    return 'You pay $n jade';
  }

  @override
  String get eventContinue => 'Keep climbing';

  @override
  String eventResultTalisman(String name) {
    return 'Talisman: $name';
  }

  @override
  String eventResultCard(String name) {
    return 'New card: $name';
  }

  @override
  String eventResultForm(String name) {
    return 'Form learned: $name';
  }

  @override
  String eventResultUpgrade(String name) {
    return 'Upgraded: $name';
  }

  @override
  String eventResultLost(String name) {
    return 'Removed from deck: $name';
  }

  @override
  String get eventLucky => 'It went well!';

  @override
  String get eventUnlucky => 'It went badly…';

  @override
  String get talismanPickTitle => 'Choose a talisman';

  @override
  String get talismanPickHint =>
      'Lasts the whole climb and works on its own. Rare ones gleam gold, and boss ones, lacquer.';

  @override
  String get talismanRare => 'Rare';

  @override
  String get cardRare => 'Rare card';

  @override
  String get cardLegendary => 'Legendary card';

  @override
  String cardTypeName(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'fist': 'Fist',
      'palm': 'Palm',
      'kick': 'Kick',
      'defense': 'Defense',
      'technique': 'Technique',
      'other': 'Card',
    });
    return '$_temp0';
  }

  @override
  String get talismanVow => 'Vow · one stage';

  @override
  String get campTitle => 'The camp';

  @override
  String get campLetter => 'Among your things lies a card you had never seen.';

  @override
  String get campDream => 'The campfire fades slowly. That night, you dreamed.';

  @override
  String get campQuiet =>
      'The campfire crackles and the dragon sleeps without dreams. Tomorrow, onward.';

  @override
  String get campVowTitle => 'Will you make a vow for the next stage?';

  @override
  String campVowHint(int lotus) {
    return 'An advantage with a cost, until the next campfire. Beat the stage boss under the vow and you fulfill it: +$lotus lotus. You may choose not to vow.';
  }

  @override
  String get campClimbVow => 'Climb with the vow';

  @override
  String get campClimbFree => 'Go on without a vow';

  @override
  String get talismanBoss => 'From a boss';

  @override
  String talismanGained(String name) {
    return '$name!';
  }

  @override
  String get talismansTitle => 'Talismans';

  @override
  String get talismansHint =>
      'Objects that stay with you the whole climb and act on their own.';

  @override
  String get talismansNone =>
      'You have no talismans yet. You find them in events and by beating the elite.';

  @override
  String talEffStance(String stance) {
    return 'You start each combat in $stance.';
  }

  @override
  String talEffFirstBreath(int n) {
    return '+$n Breath on the first turn of each combat.';
  }

  @override
  String talEffStructure(int n) {
    return '+$n Structure in each combat.';
  }

  @override
  String talEffEnemyHp(int n) {
    return 'The foe starts each combat with $n less Life.';
  }

  @override
  String talEffEnemyStructure(int n) {
    return 'The foe starts each combat with $n less Structure.';
  }

  @override
  String talEffMaxHp(int n) {
    return '+$n max Life.';
  }

  @override
  String talEffFountain(int n) {
    return 'The fountain heals $n more.';
  }

  @override
  String talEffWinHeal(int n) {
    return 'Winning a combat heals $n.';
  }

  @override
  String talEffDeflect(int n) {
    return 'Each deflection gives +$n Breath.';
  }

  @override
  String talEffFormHeal(int n) {
    return 'Each completed form heals $n.';
  }

  @override
  String talEffStanceGuard(int n) {
    return 'Each time you change stance, +$n Guard.';
  }

  @override
  String talEffDingbu(String move) {
    return '$move costs no Breath.';
  }

  @override
  String talEffWinJade(int n) {
    return 'Winning a combat gives +$n jade.';
  }

  @override
  String talEffFirstCard(int n) {
    return 'The first card each turn costs $n less.';
  }

  @override
  String talEffBreakDraw(int n) {
    return 'Staggering a foe draws $n cards.';
  }

  @override
  String talEffDeflectDamage(int n) {
    return 'Each deflection deals $n damage back.';
  }

  @override
  String talEffTurnBreath(int n) {
    return '+$n Breath each turn,';
  }

  @override
  String talEffHandLess(int n) {
    return 'but you draw $n card fewer.';
  }

  @override
  String talEffMaxHpLess(int n) {
    return 'but you lose $n max Life.';
  }

  @override
  String talEffFountainLess(int n) {
    return 'but the fountain heals $n less.';
  }

  @override
  String talEffShopMarkup(int n) {
    return 'but the merchant charges you $n% more.';
  }

  @override
  String talEffStructureLess(int n) {
    return 'but you have $n less Structure.';
  }

  @override
  String talEffGuardKeep(int n) {
    return 'At the start of your turn you keep $n% of your Guard.';
  }

  @override
  String talEffHandMore(int n) {
    return '+$n card in each hand.';
  }

  @override
  String talEffAttackStructure(int n) {
    return 'Your attacks remove $n more Structure.';
  }

  @override
  String talEffGuardPierce(int n) {
    return 'Your attacks pierce $n of the foe\'s Guard without spending it.';
  }

  @override
  String talEffHeavyDamage(int n) {
    return 'Attacks that cost 2 or more Breath hit +$n.';
  }

  @override
  String talEffEdgeDamage(int n) {
    return 'On the edge (at 70% Life or less), your attacks hit +$n.';
  }

  @override
  String talEffEdgeBreath(int n) {
    return 'On the edge (at 70% Life or less), you start each turn with +$n Breath.';
  }

  @override
  String get weaponPickTitle => 'Choose a weapon';

  @override
  String get weaponPickHint =>
      'Only one per climb: it adds its techniques to the loot and can be tempered up to level III.';

  @override
  String get weaponForgeTitle => 'Temper the weapon';

  @override
  String get weaponForgeHint =>
      'Your weapon goes up a level: stronger, with a new technique in the loot.';

  @override
  String weaponLevel(int n) {
    return 'Level $n';
  }

  @override
  String weaponLevelUp(int from, int to) {
    return 'Level $from → $to';
  }

  @override
  String weaponAffinity(String bonus) {
    return 'Attuned to your Path: $bonus';
  }

  @override
  String weaponCards(String names) {
    return 'Techniques: $names';
  }

  @override
  String weaponGained(String name) {
    return '$name!';
  }

  @override
  String weaponForged(String name, int n) {
    return '$name, level $n!';
  }

  @override
  String get weaponNone => 'No weapon. The first elite lets you choose one.';

  @override
  String get weaponTitle => 'Weapon';

  @override
  String get lootKindWeapon => 'Weapon';

  @override
  String get merchantWeapon => 'Armory';

  @override
  String merchantForge(String name, int n) {
    return 'Temper $name (level $n)';
  }

  @override
  String masterForge(String name, int from, int to) {
    return 'Temper $name (level $from → $to)';
  }

  @override
  String get masterForgeMax =>
      'The master tempers up to level II; level III comes from loot or the merchant.';

  @override
  String talEffBreakDamage(int n) {
    return 'Staggering a foe strikes it for $n, dealt double.';
  }

  @override
  String talEffThirdAttackDraw(int n) {
    return 'The third attack each turn draws $n card.';
  }

  @override
  String talEffRetainedGuard(int n) {
    return 'At the start of your turn, +$n Guard for each retained card.';
  }

  @override
  String talEffShopDiscount(int n) {
    return 'The merchant charges you $n% less.';
  }

  @override
  String awEffFirstStrike(int n) {
    return 'The first attack each turn hits +$n.';
  }

  @override
  String awEffChain(int n) {
    return 'Each attack hits +$n for each earlier attack this turn.';
  }

  @override
  String awEffRetain(int n) {
    return 'You can retain $n more card.';
  }

  @override
  String awEffDraw(int n) {
    return 'You draw $n more card per turn.';
  }

  @override
  String awEffRetainedDiscount(int n) {
    return 'Retained cards cost $n less.';
  }

  @override
  String awEffFirstStrikeStructure(int n) {
    return 'The first attack each turn removes +$n Structure.';
  }

  @override
  String awEffFirstStrikeDiscount(int n) {
    return 'The first attack each turn costs $n less.';
  }

  @override
  String awEffBreakDraw(int n) {
    return 'When you stagger the foe, draw $n.';
  }

  @override
  String awEffChainStructure(int n) {
    return 'Each attack removes +$n Structure for each earlier attack this turn.';
  }

  @override
  String awEffThirdAttackDraw(int n) {
    return 'When you play the third attack of the turn, draw $n.';
  }

  @override
  String awEffRetainedDamage(int n) {
    return 'Retained attacks hit +$n.';
  }

  @override
  String awEffDeflectBreath(int n) {
    return 'Each deflection gives +$n Breath.';
  }

  @override
  String awEffCircle(int breath, int draw) {
    return 'When you close the Circle of stances, gain +$breath Breath and draw $draw more.';
  }

  @override
  String awEffGuardBonus(int n) {
    return 'Your defenses give +$n Guard.';
  }

  @override
  String get awakeningTitle => 'AWAKENING';

  @override
  String get awakeningHint =>
      'The spirit of your Path teaches you something more. Choose one: it stays with you for the rest of the climb.';

  @override
  String get awakeningPick => 'Choose an awakening';

  @override
  String get awakeningConfirm => 'Awaken and keep climbing';

  @override
  String get awakeningsLabel => 'Awakenings';

  @override
  String get lesClimbSlideEventsTitle => 'Events and talismans';

  @override
  String get lesClimbSlideEvents =>
      'The pink icon is an event: a scene with a choice (pay Life for something, take a risk or play it safe). There, and by beating the elite, you earn talismans: objects that act on their own the whole climb, like starting in Bow or healing when you win. You see them at the top of the map and in combat; tap them to read them.';

  @override
  String get talismanTapHint =>
      'Tap your talismans at the top to see again what they do.';

  @override
  String get merchantNode => 'Merchant';

  @override
  String get masterNode => 'Wandering master';

  @override
  String jadeGained(int n) {
    return '+$n jade';
  }

  @override
  String get merchantTitle => 'Scroll merchant';

  @override
  String get merchantBao => 'Uncle Bao and his bundle';

  @override
  String get merchantTale =>
      'Uncle Bao sets his bundle on the ground and sits for a moment.';

  @override
  String get merchantTaleGo => 'See the wares';

  @override
  String get merchantHint =>
      'Trade jade for cards, a talisman or a service. Whatever you don\'t spend stays with you for later.';

  @override
  String get merchantCards => 'Cards';

  @override
  String get merchantTalisman => 'Talisman';

  @override
  String get merchantServices => 'Services';

  @override
  String get merchantTabItems => 'Items';

  @override
  String get merchantShowcase => 'Showcase';

  @override
  String get merchantRareTag => 'Select';

  @override
  String get merchantRemove => 'Remove 1 card from the deck';

  @override
  String merchantUpgrade(int amount) {
    return 'Upgrade 1 card (+$amount)';
  }

  @override
  String get merchantUsed => 'Already used';

  @override
  String merchantSale(int pct) {
    return 'Sale −$pct%';
  }

  @override
  String merchantTea(int n) {
    return 'Ginger tea (+$n Life)';
  }

  @override
  String merchantTeaDetail(int n) {
    return 'A hot bowl that restores $n Life. Once per visit.';
  }

  @override
  String get merchantNoJade => 'Not enough jade';

  @override
  String get merchantBought => 'Bought!';

  @override
  String get merchantPickRemove => 'Choose the card you want to remove';

  @override
  String get merchantPickUpgrade => 'Choose the card you want to upgrade';

  @override
  String get merchantEmpty => 'Nothing left for sale.';

  @override
  String get masterTitle => 'Wandering master';

  @override
  String get masterText =>
      'An old man practices on the trail. He sees you coming, smiles and offers you a single lesson.';

  @override
  String get masterTeach => 'Learn a form';

  @override
  String get masterTeachHint => 'Tap the one you want to learn.';

  @override
  String masterUpgrade(int amount) {
    return 'Upgrade 1 card (+$amount)';
  }

  @override
  String get masterUpgradeHint => 'Choose the card the master will polish.';

  @override
  String get masterNoForms => 'You already know every form he can teach you.';

  @override
  String get masterOr => 'or';

  @override
  String masterUpgraded(String name, int n) {
    return '$name +$n!';
  }

  @override
  String get lesClimbSlideShopTitle => 'Jade, merchant and master';

  @override
  String get lesClimbSlideShop =>
      'Each combat you win gives you jade (玉); the elite gives more. Every few combats a traveling merchant crosses your path: there you trade it for cards, a talisman, removing a card or upgrading one. The wandering master charges nothing: he teaches you a form or upgrades a card, but only one of the two.';

  @override
  String effChain(int n) {
    return '+$n damage for each attack you already played this turn';
  }

  @override
  String effRetained(int n) {
    return 'If you retained it, +$n damage';
  }

  @override
  String effChainStructure(int n) {
    return '+$n Structure for each attack you already played this turn';
  }

  @override
  String effRetainedStructure(int n) {
    return 'If you retained it, +$n Structure';
  }

  @override
  String effComboDraw(int at, int n) {
    return 'If you already played $at attacks this turn, draw $n';
  }

  @override
  String effComboBreath(int at, int n) {
    return 'If you already played $at attacks this turn, +$n Breath';
  }

  @override
  String effRetainedDraw(int n) {
    return 'If you retained it, draw $n';
  }

  @override
  String effRetainedBreath(int n) {
    return 'If you retained it, +$n Breath';
  }

  @override
  String effBreakDraw(int n) {
    return 'If it staggers the foe, draw $n';
  }

  @override
  String effBreakBreath(int n) {
    return 'If it staggers the foe, +$n Breath';
  }

  @override
  String styleChipFirstStrike(String hanzi, int n) {
    return '$hanzi First strike +$n';
  }

  @override
  String styleChipChain(String hanzi, int n) {
    return '$hanzi Chain +$n';
  }

  @override
  String styleChipRetained(String hanzi, int n) {
    return '$hanzi Retained −$n';
  }

  @override
  String get retainedTag => 'Retained';

  @override
  String styleDeltaDamage(int n) {
    return '+$n damage from your Path';
  }

  @override
  String retainedCheaper(int n) {
    return '−$n cost for retaining';
  }

  @override
  String get picosTitle => 'Peaks';

  @override
  String get picosDesc =>
      'Normal with extra rules. Each Peak adds one more to the previous ones.';

  @override
  String get picosLocked => 'Win a climb on Normal to open Peak 1.';

  @override
  String picoName(int n) {
    return 'Peak $n';
  }

  @override
  String picoNew(String rule) {
    return 'New: $rule';
  }

  @override
  String get picoStackedOne => 'Plus the rule of Peak 1.';

  @override
  String picoStacked(int n) {
    return 'Plus the rules of Peaks 1 to $n.';
  }

  @override
  String get picoLower => 'Lower Peak';

  @override
  String get picoHigher => 'Higher Peak';

  @override
  String picoOpened(int n) {
    return 'Peak $n is open!';
  }

  @override
  String get picoTop => 'You crowned the last Peak.';

  @override
  String get picoRule1 => 'Elites +15% Life';

  @override
  String get picoRule2 =>
      'The merchant charges 20% more and mist covers the first turn of each fight';

  @override
  String get picoRule3 => 'Foes start with 3 Guard';

  @override
  String get picoRule4 =>
      'Foes +5% damage, and elites and bosses fight with a bell';

  @override
  String get picoRule5 =>
      'You start with 5 less Life and the fountain heals 5 less';

  @override
  String get picoRule6 =>
      'Elites bring a second question: thorns, healing or fury';

  @override
  String get picoRule7 => 'Foes +5% damage and +5% Structure';

  @override
  String get picoRule8 =>
      'Elites and boss +10% Life, and thin air: 1 less Breath per turn until you breathe';

  @override
  String get picoRule9 => 'You start without Breathe charged';

  @override
  String get picoRule10 =>
      'Foes +5% damage, +8% Life and +5% Structure, and the boss rises one more time';

  @override
  String wrathChip(int n) {
    return 'Awake · +$n per hit';
  }

  @override
  String furyChip(int n) {
    return 'Mountain\'s Fury · +$n';
  }

  @override
  String stageFuryTitle(int n) {
    return '狂 Mountain\'s Fury · +$n per action';
  }

  @override
  String stageFuryNew(int n) {
    return 'From here on the mountain enrages the foes: after each action their hits deal $n more, and it never calms. Enduring isn\'t enough: defeat them quickly.';
  }

  @override
  String stageFuryMore(int n, int prev) {
    return 'Higher up it rages more: each action adds $n to their hits, instead of $prev. Defeat them quickly.';
  }

  @override
  String get wrathCalmed => 'Falls back asleep';

  @override
  String get parryChip => 'Fan ready';

  @override
  String get parried => 'Fan!';

  @override
  String previewParried(int n) {
    return 'Fan: 0 damage, deals $n back to you';
  }

  @override
  String parriedDetail(int n) {
    return 'Deflects your strike and deals $n back to you';
  }

  @override
  String stolenChip(int n) {
    return 'Stole $n jade from you';
  }

  @override
  String get intentFlee => 'Flees';

  @override
  String intentFleeDetail(int n) {
    return 'with $n jade';
  }

  @override
  String get fledTitle => 'It fled';

  @override
  String endSummaryFled(String name, int n) {
    return '$name fled with $n jade';
  }

  @override
  String jadeLost(int n) {
    return '−$n jade · taken';
  }

  @override
  String get stageCleared => 'STAGE CLEARED';

  @override
  String get stageBreath => 'You breathe deeply before going on';

  @override
  String get stageClimb => 'Keep climbing';

  @override
  String mapStage(int n, int total) {
    return 'Stage $n of $total';
  }

  @override
  String thornsChip(int n) {
    return 'Thorns · −$n per card';
  }

  @override
  String get thornsHurt => 'Thorns';

  @override
  String regenChip(int n) {
    return 'Heals $n when acting';
  }

  @override
  String guardOnly(String type, int n) {
    return 'Guard $n · only stops $type';
  }

  @override
  String guardOnlyChip(int n, String type) {
    return 'Guard $n · only $type';
  }

  @override
  String get guardBypassed => 'You slipped past its guard!';

  @override
  String get guardBypassedDetail => 'A different kind of strike';

  @override
  String intentDrain(int n) {
    return 'If you don\'t deflect it: −$n Breath';
  }

  @override
  String intentFreeze(int n) {
    return 'If you don\'t deflect it: draw $n fewer';
  }

  @override
  String get intentWear => 'Each hit wears down your Guard';

  @override
  String previewWear(int n, int hits) {
    return '⚠ each hit wears down your Guard: covers $n of $hits';
  }

  @override
  String get breathDrained => 'Toll';

  @override
  String breathDrainedDetail(int n) {
    return '−$n Breath next turn';
  }

  @override
  String get handFrozen => 'Frost';

  @override
  String handFrozenDetail(int n) {
    return 'Draw $n card fewer';
  }

  @override
  String previewThorns(int n) {
    return 'Thorns: costs you $n';
  }

  @override
  String get previewGuardMiss => 'Slips past its guard';

  @override
  String get previewGuardHit => 'Its guard stops it';

  @override
  String get previewCovers => '✓ covers its strike';

  @override
  String previewHalfCover(String height) {
    return '⚠ its strike is $height: covers half';
  }

  @override
  String get realmLabel => 'Realm';

  @override
  String breathTotal(int n) {
    return '$n breath';
  }

  @override
  String breathToNext(int n) {
    return '$n to the next realm';
  }

  @override
  String get breathMax => 'Highest realm';

  @override
  String breathEarned(int n) {
    return '+$n breath for the school';
  }

  @override
  String get breathEarnedHint =>
      'Win or fall, every disciple leaves their breath.';

  @override
  String get realmUp => 'The school rises a realm';

  @override
  String get realmOpened => 'Opened';

  @override
  String get realmLocked => 'Locked';

  @override
  String realmNeeds(int n) {
    return 'At $n breath';
  }

  @override
  String get registryTabCultivation => 'Cultivation';

  @override
  String get registryHitos => 'Milestones';

  @override
  String get hitosSummary =>
      'Each milestone is reached once per save slot and leaves breath to the school.';

  @override
  String get hitoNew => 'NEW';

  @override
  String hitoBreath(int n) {
    return '+$n 气';
  }

  @override
  String get lootTitle => 'Loot';

  @override
  String get lootOpenHint => 'Tap the chest to open it';

  @override
  String get lootKindCards => 'Scrolls';

  @override
  String get lootKindJade => 'Jade pouch';

  @override
  String get lootKindLotus => 'Lotus seeds';

  @override
  String get lootKindUpgrade => 'Temper';

  @override
  String get lootKindTea => 'Mountain tea';

  @override
  String get lootKindTalisman => 'Talisman';

  @override
  String get lootHintCards =>
      'Add a technique to your deck or learn the form. A small deck is more predictable.';

  @override
  String lootHintJade(int n) {
    return '$n jade for the merchant on the path.';
  }

  @override
  String lootHintLotus(int n) {
    return '$n seeds that return with you to the school, even if you fall. They open points on the meridian tree.';
  }

  @override
  String lootHintUpgrade(int n) {
    return 'Choose a card: it gains +$n for the whole climb.';
  }

  @override
  String lootHintTea(int n) {
    return 'You recover $n Life.';
  }

  @override
  String get lootHintTalisman => 'Choose one: it lasts the whole climb.';

  @override
  String get lootTake => 'Take';

  @override
  String get lootDrink => 'Drink';

  @override
  String get lootTemper => 'Temper';

  @override
  String lootReroll(int n) {
    return 'Reroll ($n)';
  }

  @override
  String lotusGained(int n) {
    return '+$n lotus';
  }

  @override
  String get legacyTitle => 'Legacy';

  @override
  String legacyHint(int n) {
    return 'Disciple no. $n left you something for the path. Choose a legacy.';
  }

  @override
  String get legacyCard => 'Their card';

  @override
  String legacyCardUp(String card, int n) {
    return '$card +$n';
  }

  @override
  String get legacyStat => 'What they reached';

  @override
  String legacyHp(int n) {
    return '+$n max Life';
  }

  @override
  String legacyJade(int n) {
    return '+$n jade';
  }

  @override
  String legacyGained(String what) {
    return 'Inherited: $what';
  }

  @override
  String get talismanStartTitle => 'Gift of the school';

  @override
  String get talismanStartHint =>
      'The meridians are with you: choose a talisman for this climb.';

  @override
  String get stageLootTitle => 'Stage loot';

  @override
  String get stageLootWins => 'Combats won';

  @override
  String get stageLootJade => 'Jade earned';

  @override
  String get stageLootLotus => 'Lotus seeds';

  @override
  String get meridiansTitle => 'Meridian tree';

  @override
  String get meridiansButton => 'Meridians';

  @override
  String get meridiansHint =>
      'Every climb brings lotus seeds, win or fall. With them the school opens points that help every disciple to come.';

  @override
  String meridiansBalance(int n) {
    return '$n seeds';
  }

  @override
  String get meridiansRealmGifts => 'Realm gifts';

  @override
  String get meridiansRealmGiftsHint =>
      'Each cultivation realm grants a gift, without spending lotus.';

  @override
  String get meridianBranchBody => 'Body';

  @override
  String get meridianBranchSpirit => 'Spirit';

  @override
  String get meridianBranchTechnique => 'Technique';

  @override
  String meridianOpen(int n) {
    return 'Open point · $n';
  }

  @override
  String get meridianOpened => 'Open';

  @override
  String meridianNeedsRealm(String realm) {
    return 'Requires $realm';
  }

  @override
  String get meridianNeedsPrev => 'Open the previous point first';

  @override
  String meridianNeedsLotus(int n) {
    return '$n seeds short';
  }

  @override
  String get meridianNextRun => 'Takes effect from your next climb.';

  @override
  String bonusMaxHp(int n) {
    return '+$n max Life';
  }

  @override
  String bonusFountainHeal(int n) {
    return 'The fountain heals $n more';
  }

  @override
  String bonusWinHeal(int n) {
    return 'Heal $n after winning each fight';
  }

  @override
  String bonusStructure(int n) {
    return '+$n Structure in every fight';
  }

  @override
  String bonusStartJade(int n) {
    return 'Start with $n jade';
  }

  @override
  String bonusUpgradedStarters(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n starting cards begin tempered',
      one: 'One starting card begins tempered',
    );
    return '$_temp0';
  }

  @override
  String get bonusStartTalisman => 'Choose a talisman at the start';

  @override
  String bonusMerchantDiscount(int n) {
    return 'The merchant charges $n% less';
  }

  @override
  String bonusRewardChoices(int n) {
    return '+$n card to choose from in scrolls';
  }

  @override
  String bonusTalismanChoices(int n) {
    return '+$n talisman to choose from at elites';
  }

  @override
  String bonusRerolls(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'You can reroll the scrolls $n times per climb',
      one: 'You can reroll the scrolls once per climb',
    );
    return '$_temp0';
  }

  @override
  String bonusLotusPct(int n) {
    return '+$n% lotus seeds';
  }

  @override
  String bonusFirstTurnBreath(int n) {
    return '+$n Breath on the first turn';
  }

  @override
  String bonusBreathes(int n) {
    return '+$n Breathe charge at the start';
  }

  @override
  String bonusWeaponLevel(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Weapons arrive with $n extra temper levels',
      one: 'Weapons arrive with one extra temper level',
    );
    return '$_temp0';
  }

  @override
  String bonusTeaHeal(int n) {
    return 'Tea heals $n more';
  }

  @override
  String bonusStageHealPct(int n) {
    return 'On clearing a stage, heal $n% more of your missing Life';
  }

  @override
  String bonusHandSize(int n) {
    return 'Draw $n more card each turn';
  }

  @override
  String bonusTurnBreath(int n) {
    return '+$n Breath every turn';
  }

  @override
  String bonusRetain(int n) {
    return 'Keep $n more card at the end of your turn';
  }

  @override
  String bonusFirstStrike(int n) {
    return 'Your first attack each turn deals +$n damage';
  }

  @override
  String bonusChain(int n) {
    return 'Each attack deals +$n damage for every earlier attack this turn';
  }

  @override
  String bonusEnemyHp(int n) {
    return 'Foes start with $n less Life';
  }

  @override
  String bonusEnemyStructure(int n) {
    return 'Foes start with $n less Structure';
  }

  @override
  String get meridianChoice =>
      'Choose one of the two: the other closes forever';

  @override
  String get meridianChosenOther => 'You chose the other point';

  @override
  String get meridianOr => 'or';

  @override
  String resultLotus(int n, int total) {
    return '+$n lotus seeds · the school has $total';
  }

  @override
  String resultOffering(int jade, int n) {
    return '$jade leftover jade, offered to the school: +$n';
  }

  @override
  String get resultToMeridians => 'Open meridians';

  @override
  String get schoolButton => 'Restore the school';

  @override
  String get schoolTitle => 'The School';

  @override
  String get schoolHint =>
      'The jade left over from each climb, win or fall, stays at the school. It restores the buildings, and each level helps every disciple who comes after.';

  @override
  String schoolLevel(int n, int max) {
    return 'Level $n of $max';
  }

  @override
  String get schoolRuined => 'In ruins';

  @override
  String schoolRestore(int n) {
    return 'Restore · $n';
  }

  @override
  String schoolNeedsJade(int n) {
    return '$n jade short';
  }

  @override
  String get schoolDone => 'Fully restored';

  @override
  String get schoolNext => 'Next level';

  @override
  String get schoolGives => 'Grants';

  @override
  String schoolProgress(int n, int max) {
    return '$n of $max levels restored';
  }

  @override
  String resultSchoolJade(int jade) {
    return '$jade leftover jade stays at the school to restore it';
  }

  @override
  String get cinematicSkip => 'Tap to skip';

  @override
  String get introBoss => 'Guardian of the stage';

  @override
  String get introElite => 'Elite of the path';

  @override
  String introEscort(String name) {
    return 'Elite with escort: $name';
  }

  @override
  String get menuPlay => 'Play';

  @override
  String menuPlaySubtitle(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n save slots in use',
      one: '1 save slot in use',
      zero: 'Three save slots, each with its own difficulty',
    );
    return '$_temp0';
  }

  @override
  String get slotsTitle => 'Save Slots';

  @override
  String get slotsSubtitle =>
      'Each save slot has its own school, record and fixed difficulty.';

  @override
  String get slotsChange => 'Change save slot';

  @override
  String slotName(int n) {
    return 'Slot $n';
  }

  @override
  String get slotNew => 'New save slot';

  @override
  String get slotNewHint =>
      'You choose the difficulty once and it stays for the whole save.';

  @override
  String slotAscents(int n, int wins) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n climbs',
      one: '1 climb',
      zero: 'no climbs',
    );
    String _temp1 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: ' · $wins summits',
      one: ' · 1 summit',
      zero: '',
    );
    return '$_temp0$_temp1';
  }

  @override
  String slotClimbing(String stage, int floor) {
    return 'Climbing: $stage, room $floor';
  }

  @override
  String get slotResting => 'At the school, no climb underway';

  @override
  String get slotOptions => 'Save slot options';

  @override
  String get slotRestart => 'Start over';

  @override
  String get slotDelete => 'Delete save slot';

  @override
  String slotDeleteTitle(int n) {
    return 'Delete Slot $n?';
  }

  @override
  String get slotDeleteBody =>
      'Everything in this save is lost: disciples, record, lotus, meridians and the current climb. Lessons and sound settings are kept.';

  @override
  String get slotDeleteOk => 'Delete';

  @override
  String get slotDeleteSureTitle => 'Are you sure?';

  @override
  String slotDeleteSureBody(int n) {
    return 'Slot $n disappears forever. This cannot be undone.';
  }

  @override
  String get slotDeleteSureOk => 'Yes, delete forever';

  @override
  String get picoNone => 'No Peak';

  @override
  String ghostName(int n) {
    return 'Lost Disciple No. $n';
  }

  @override
  String ghostIntro(int n, int floor) {
    return 'I was No. $n. I fell in room $floor, and the mist won\'t let me go down.';
  }

  @override
  String ghostIntroPath(int n, String path, int floor) {
    return 'I was No. $n; my path was $path. I fell in room $floor, and the mist won\'t let me go down.';
  }

  @override
  String get ghostRank => 'Fallen of the school';

  @override
  String get foeKnown => 'You know their story: they start out hesitant';

  @override
  String get ghostReply => 'I\'ve come to take you back to the school.';

  @override
  String ghostDrop(int n) {
    return 'No. $n leaves you their card';
  }

  @override
  String schoolLastFallen(int n) {
    return 'Last fallen: No. $n';
  }

  @override
  String schoolFellTo(String enemy, int floor) {
    return '$enemy · room $floor';
  }

  @override
  String schoolFellAt(int floor) {
    return 'Fell in room $floor';
  }

  @override
  String get schoolGhostWaits => 'Their ribbon awaits you';

  @override
  String get schoolNoFallen => 'No one has fallen yet';

  @override
  String get schoolNoFallenSub => 'The whole school watches you climb';

  @override
  String schoolNextHito(int breath) {
    return 'Milestone · +$breath breath';
  }

  @override
  String get schoolAllHitos => 'All milestones reached';

  @override
  String schoolHitoBest(String name, int have, int need) {
    return '$name · best $have/$need';
  }

  @override
  String effFrom(String name, String bonus) {
    return 'From $name: $bonus';
  }

  @override
  String get chainedTag => 'Chains';

  @override
  String get chainedFloat => 'Chain!';

  @override
  String talEffChainBreath(int n) {
    return 'Each card that chains from its stance gives +$n Breath.';
  }

  @override
  String get circleTag => 'Closes the circle';

  @override
  String get circleFloat => 'Circle closed!';

  @override
  String circleSub(int breath, int draw) {
    return '+$breath Breath · draw $draw';
  }

  @override
  String get chestPage => 'Among the loot, a loose page.';

  @override
  String get chestPageGo => 'Keep it and see the loot';

  @override
  String get registryChronicle => 'Chronicle';

  @override
  String get chronicleSummary =>
      'The mountain\'s chronicle: every foe you meet leaves their entry.';

  @override
  String get chronicleSealed => 'You haven\'t met them yet.';

  @override
  String get chronicleLost => 'No stage';

  @override
  String chronicleCount(int wins, int falls) {
    return 'Defeated $wins · Defeated you $falls';
  }

  @override
  String get glossTitle => 'Glossary';

  @override
  String get glossRelated => 'See also';

  @override
  String get glossCardHint => 'Press and hold a card to read it';

  @override
  String get glossGuard =>
      'A shield that absorbs the foe\'s strike. Each defense covers one height: at the same height it absorbs everything, at another only half. It lasts until the end of the foe\'s turn.';

  @override
  String get glossHeight =>
      'Every strike and every Guard has a height: ↑ high, → mid, ↓ low. Check the arrow in the foe\'s bubble and defend at the same height.';

  @override
  String get glossDeflect =>
      'If your Guard matches the strike\'s height and is enough to cover it, you deflect it (化): you take nothing, the foe loses Structure and you gain Breath for your next turn. It also grants a Counter: on your turn, choose a free card, a draw or +1 Flow.';

  @override
  String get glossStructure =>
      'Every fighter\'s balance. Strikes with the violet hexagon lower it. At 0, the fighter is Staggered.';

  @override
  String get glossStaggered =>
      'With Structure at 0, the foe loses their next action and takes double damage until the end of your next turn. If it happens to you, you start your next turn with 2 less Breath.';

  @override
  String get glossBreath =>
      'You pay for cards with Breath: the number at the top left is the cost. It refills at the start of each turn, and whatever you don\'t spend is lost.';

  @override
  String get glossBreathe =>
      'Spend a charge to change your hand, recover Breath or recover Structure. It charges when you deflect, complete a form and end your turn with unspent Breath (three steps per charge, up to two stored).';

  @override
  String get glossStance =>
      'Horse, Bow or Empty. Each stance changes what your cards do, and some cards move you from one to another.';

  @override
  String get glossDingbu =>
      'Change stance by paying Breath, once per turn. Tap your stance seal to use it.';

  @override
  String get glossChain =>
      'The card does more if you play it from the stance it names («From…»).';

  @override
  String get glossCircle =>
      'If you chain from all three stances in a single turn, you close the circle: you gain Breath and draw cards.';

  @override
  String get glossRetain =>
      'At the end of your turn you can keep some cards in hand instead of discarding them. Some do more if you retained them.';

  @override
  String get glossExhaust =>
      'When played, it leaves the fight and doesn\'t return until the next one.';

  @override
  String get glossForm =>
      'A sequence of cards played in order. Complete it to unleash a great strike. Defenses don\'t interrupt it.';

  @override
  String get glossThorns =>
      'Each of your cards that damages it costs you that much Life (forms don\'t). It doesn\'t work while Staggered.';

  @override
  String get glossRegen =>
      'Before each action it recovers that much Life. If Staggered and it loses the action, it doesn\'t heal either.';

  @override
  String get glossFury =>
      'Higher up, the mountain enrages foes: after each action their strikes add a little more, and it never calms. Holding out isn\'t enough: beat them fast. When Staggered, the foe loses the action and doesn\'t grow angrier that turn.';

  @override
  String get glossWrath =>
      'After each action its strikes add that much damage, and it stacks. Staggering it puts it back to sleep.';

  @override
  String get glossParry =>
      'The first damaging strike each turn deals it no damage and sends a little back to you. It doesn\'t work while Staggered.';

  @override
  String get glossSteal =>
      'Each strike that damages you steals jade. If it escapes, it takes it; if you beat it, you get it back.';

  @override
  String get glossScales =>
      'Each strike loses that much damage, unless the foe is Staggered. Each time you stagger it, it loses a scale.';

  @override
  String get termHeight => 'Height';

  @override
  String get termDeflect => 'Deflection';

  @override
  String get termStaggered => 'Staggered';

  @override
  String get termStance => 'Stance';

  @override
  String get termChain => 'Chain';

  @override
  String get termCircle => 'Circle';

  @override
  String get termFlow => 'Flow';

  @override
  String get glossFlow =>
      'Your rhythm in the fight, from 0 to 3. It rises when you chain, deflect and complete forms; it drops if a strike lands without Guard or you end a turn without playing. At 1, your attacks hit +1; at 2, you draw one more card; at 3, you also get one more Breath and can spend it all on the Path Technique.';

  @override
  String flowLevel(int level, int max) {
    return 'Flow $level of $max';
  }

  @override
  String flowUp(int level) {
    return 'Flow $level';
  }

  @override
  String get flowMaxSub => 'Path Technique ready';

  @override
  String get termRetain => 'Retain';

  @override
  String get termExhaust => 'Exhaust';

  @override
  String get termForm => 'Form';

  @override
  String get termThorns => 'Thorns';

  @override
  String get termRegen => 'Regen';

  @override
  String get termFury => 'Mountain\'s Fury';

  @override
  String get termWrath => 'Awake';

  @override
  String get termParry => 'Fan';

  @override
  String get termSteal => 'Thief';

  @override
  String get termScales => 'Scales';

  @override
  String get masteryButton => 'Path Mastery';

  @override
  String get masteryTitle => 'Path Mastery';

  @override
  String get masteryHint =>
      'Each path levels up with the fights you win using it: elites, bosses and the summit give more. Each level unlocks something from that path for future climbs.';

  @override
  String masteryLevel(int n, int max) {
    return 'Level $n of $max';
  }

  @override
  String masteryXp(int xp, int next) {
    return '$xp of $next experience';
  }

  @override
  String get masteryFull => 'Mastery complete';

  @override
  String masteryAwakening(String name) {
    return 'Awakening $name';
  }

  @override
  String masteryWeapon(String name) {
    return '$name level 3';
  }

  @override
  String masteryShrine(int n, int max) {
    return 'Mastery $n/$max';
  }

  @override
  String masteryGained(String path, int xp, int n) {
    return '$path: +$xp mastery · level $n';
  }

  @override
  String masteryUp(String list) {
    return 'Unlocked: $list';
  }

  @override
  String get introOk => 'Got it';

  @override
  String get introNew => 'New';

  @override
  String get introHelp => 'How it works';

  @override
  String get introWhoMaster => 'MASTER SONG';

  @override
  String get introWhoTie => 'MASTER TIE';

  @override
  String get introWhoShuang => 'SHUANG OF THE BLUE BIRD';

  @override
  String get introMeridiansQuote =>
      '«Breath is ordered little by little, point by point. What you open here, every disciple who climbs after you inherits.»';

  @override
  String get introMeridians1 => 'Every climb brings lotus seeds, win or fall.';

  @override
  String get introMeridians2 =>
      'With them you open points on three branches: Body, Spirit and Technique. Each point requires the one before.';

  @override
  String get introMeridians3 =>
      'On some rows you must choose one of two points: the other closes forever.';

  @override
  String get introMeridians4 =>
      'The highest points require a cultivation realm: you reach it by climbing higher.';

  @override
  String get introSchoolQuote =>
      '«Bring me jade and the school will stand again. The hammer remembers on its own.»';

  @override
  String get introSchool1 =>
      'The jade you have left at the end of a climb stays at the school, win or fall.';

  @override
  String get introSchool2 =>
      'It restores five buildings of three levels each: infirmary, teahouse, forge, library and courtyard.';

  @override
  String get introSchool3 =>
      'Each level grants a gift to every disciple who climbs after.';

  @override
  String get introMasteryQuote =>
      '«I watched you fight. A path isn\'t learned by watching: it\'s learned by winning with it.»';

  @override
  String get introMastery1 =>
      'Tiger, Snake and Crane level up separately, through the fights you win with each.';

  @override
  String get introMastery2 =>
      'Elites, bosses and the summit give more experience. Escaping gives nothing.';

  @override
  String get introMastery3 =>
      'Each level unlocks something from that path for future climbs: rare cards, the fourth awakening, the weapon at level 3 and the legendary card.';

  @override
  String get introProgressQuote =>
      '«Look how much the school has grown since you arrived, and how far there is still to go.»';

  @override
  String get introProgress1 =>
      'Here you see everything at a glance: cultivation, meridians, the school, mastery, summits and the story.';

  @override
  String get introProgress2 => 'Tap each part to go see it.';

  @override
  String get introProgress3 => 'Winning with each path tells its own ending.';

  @override
  String get progressTitle => 'The Path So Far';

  @override
  String progressTotal(int pct) {
    return '$pct% of the path';
  }

  @override
  String get progressRealm => 'Cultivation';

  @override
  String progressRealmSub(String name, int n, int max) {
    return '$name · realm $n of $max';
  }

  @override
  String progressMeridiansSub(int n, int max) {
    return '$n of $max points open';
  }

  @override
  String progressMasterySub(int n, int max) {
    return '$n of $max levels across the three paths';
  }

  @override
  String get progressSummits => 'Summits';

  @override
  String progressSummitsSub(int n, int max) {
    return '$n of $max paths reached the summit';
  }

  @override
  String get progressPicos => 'Peaks';

  @override
  String progressPicosSub(int n, int max) {
    return 'Peak $n of $max unlocked';
  }

  @override
  String get progressPicosNone => 'Unlocked by winning on Normal';

  @override
  String get progressStory => 'Story';

  @override
  String progressStorySub(int n, int max) {
    return '$n of $max scrolls';
  }

  @override
  String get storyNew => 'Story';

  @override
  String storyTitle(String who) {
    return '$who\'s Story';
  }

  @override
  String storyCount(int n, int max) {
    return '$n of $max';
  }

  @override
  String storyListen(String who) {
    return 'Listen to $who';
  }

  @override
  String get storyDone => 'You\'ve heard it all.';

  @override
  String get storyWaitAscent => 'More after your next climb.';

  @override
  String storyWaitLevel(int level) {
    return 'More once the building reaches level $level.';
  }

  @override
  String get storyWaitSummit =>
      'The last chapter comes after you reach the summit.';

  @override
  String get recapWho => 'Master Song';

  @override
  String get dreamTitle => 'The dream lifts';

  @override
  String get dreamCalm =>
      'The Sleeping Dragon closes its eyes. Over the snow, its breath takes the shape of a boy with a ribbon like yours.';

  @override
  String get dreamBroth =>
      'You drink Ming\'s broth: your Life is fully restored.';

  @override
  String get dreamBreath => 'You breathe deeply: your Life is fully restored.';

  @override
  String get dreamBlade => 'Tie\'s scale blade hums in your hand.';

  @override
  String get dreamGo => 'Face the First Disciple';

  @override
  String get progressTrue => 'True ending';

  @override
  String progressTrueSub(int pico) {
    return 'All three endings, Peak $pico won and the whole school restored.';
  }

  @override
  String get progressTrueReady =>
      'All set: on your next climb, something more awaits at the summit.';

  @override
  String get progressTrueDone =>
      'You saw it: the dragon sleeps without dreaming.';

  @override
  String trialChallenge(String text, int jade) {
    return 'Challenge: $text (+$jade jade)';
  }

  @override
  String get trialMet => 'Challenge met!';

  @override
  String get trialFailed => 'Challenge lost';

  @override
  String trialSpoils(int jade) {
    return 'Challenge met: +$jade jade';
  }

  @override
  String get intentHidden => 'Hidden in the mist';

  @override
  String get reactionTag => 'Reacts!';

  @override
  String bellIn(int n) {
    return 'Bell in $n';
  }

  @override
  String get bellNow => 'Tolls at turn\'s end';

  @override
  String get bellTolled => 'Bell!';

  @override
  String bellTolledDetail(int taken, int damage) {
    return '−$taken to you, −$damage to each foe';
  }

  @override
  String get allyShielded => 'Shields its ally';

  @override
  String get allyHealed => 'Heals its ally';

  @override
  String markRevenge(String enemy, int n, int jade) {
    return 'Revenge: $enemy defeated disciple $n here. Beat it: +$jade jade';
  }

  @override
  String markShuang(int pct) {
    return 'Shuang\'s shortcut: she\'s been through here, and foes start with $pct% less Life';
  }

  @override
  String memorialHere(int n) {
    return 'Here fell disciple $n';
  }

  @override
  String memorialFoe(String enemy) {
    return 'to $enemy';
  }

  @override
  String revengeSpoils(int jade) {
    return 'Revenge: +$jade jade';
  }

  @override
  String get dayMorning => 'Morning';

  @override
  String get dayNoon => 'Noon';

  @override
  String get dayDusk => 'Dusk';

  @override
  String get thinAirName => 'Thin air';

  @override
  String thinAirLine(int n) {
    return 'Thin air: $n less Breath per turn until you Breathe.';
  }

  @override
  String picoMark(String path, int n) {
    return 'Mark on Peak $n: $path';
  }

  @override
  String get dailyTitle => 'Today\'s Challenge';

  @override
  String dailySub(String path) {
    return '$path · the same mountain for everyone';
  }

  @override
  String get dailyGo => 'Climb';

  @override
  String dailyDone(int floor, int floors) {
    return 'Done: floor $floor of $floors';
  }

  @override
  String get dailyWon => 'Done: you reached the summit';

  @override
  String get dailyStarted => 'Started: one attempt per day';

  @override
  String get dailyTomorrow => 'Tomorrow, another mountain';

  @override
  String get dailyStartTitle => 'Today\'s Challenge';

  @override
  String dailyStartBody(String path) {
    return 'You climb with the $path from the start, on Normal, with nothing from the school: no meridians, no buildings, no threads. There\'s one attempt per day, and it leaves nothing in your save.';
  }

  @override
  String get dailyStartOk => 'Climb';

  @override
  String get dailyTablet => 'Daily Challenge';

  @override
  String get dailyRelay => 'Tomorrow the mountain will be different.';

  @override
  String get dailyBack => 'Back to the school';

  @override
  String dailyStreak(int n) {
    return '$n-day streak';
  }

  @override
  String get progressDaily => 'Daily Challenge';

  @override
  String get progressDailyNone => 'You haven\'t played one yet';

  @override
  String progressDailySub(int played, int won, int streak) {
    return '$played played · $won summits · $streak streak';
  }

  @override
  String get tollFree => 'Level trail';

  @override
  String get tollFreeCost => 'Free';

  @override
  String get tollJade => 'Toll bridge';

  @override
  String get tollBreath => 'Steep slope';

  @override
  String tollBreathCost(int n) {
    return '−$n Breath';
  }

  @override
  String get tollKey => 'Hidden path';

  @override
  String tollKeyCost(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n keys',
      one: '1 key',
    );
    return '$_temp0';
  }

  @override
  String tollJadeLine(int n) {
    return 'You pay $n jade. On the other side, the fight pays a talisman.';
  }

  @override
  String tollBreathLine(int n) {
    return 'You arrive winded: you start with $n less Breath. A strong rival who gives a talisman and a key.';
  }

  @override
  String get tollKeyLine =>
      'You use a key. On the other side, a sealed chest, no fight.';

  @override
  String get tollNoJade => 'You don\'t have enough jade for the toll.';

  @override
  String get tollNoKey => 'You need a key.';

  @override
  String keysCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n keys',
      one: '1 key',
    );
    return '$_temp0';
  }

  @override
  String keyGained(int n) {
    return '+$n key';
  }

  @override
  String get signTracks => 'Fresh tracks';

  @override
  String get signVoices => 'Voices';

  @override
  String get signSmoke => 'Smoke';

  @override
  String get signBells => 'Little bell';

  @override
  String get signBanner => 'Torn banner';

  @override
  String get signSeal => 'Sealed door';

  @override
  String get signTracksHint => 'Footprints in the mud, recent ones.';

  @override
  String get signVoicesHint =>
      'Voices up ahead. You can\'t make out what they say.';

  @override
  String get signSmokeHint =>
      'Smoke rises between the trees: someone lit a fire.';

  @override
  String get signBellsHint => 'A little bell rings, like loaded mules.';

  @override
  String get signBannerHint =>
      'A torn banner marks the passage of someone strong.';

  @override
  String get signSealHint => 'Among the rocks, a stone door with a lock.';
}
