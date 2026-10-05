import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/run_controller.dart';
import '../labels.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/card_widget.dart';
import '../widgets/deck_sheet.dart';
import '../widgets/jade.dart';
import '../widgets/juice.dart';
import '../widgets/npc_portrait.dart';
import '../widgets/talisman_widgets.dart';

/// Lo que se tiene elegido en la tienda.
sealed class _Item {
  const _Item();
}

class _CardItem extends _Item {
  const _CardItem(this.id);
  final String id;

  @override
  bool operator ==(Object o) => o is _CardItem && o.id == id;

  @override
  int get hashCode => id.hashCode;
}

class _TalismanItem extends _Item {
  const _TalismanItem();
}

class _RemoveItem extends _Item {
  const _RemoveItem();
}

class _UpgradeItem extends _Item {
  const _UpgradeItem();
}

class _TeaItem extends _Item {
  const _TeaItem();
}

/// Mercader de pergaminos: se compra con el jade de los combates.
class MerchantScreen extends ConsumerStatefulWidget {
  const MerchantScreen({super.key});

  @override
  ConsumerState<MerchantScreen> createState() => _MerchantScreenState();
}

class _MerchantScreenState extends ConsumerState<MerchantScreen> {
  /// Lo que había en venta al entrar: lo comprado queda con su sello.
  List<String>? _cards;
  String? _talisman;
  _Item? _selected;

  /// Elegir carta del mazo para un servicio.
  _Item? _picking;
  final _bought = <_Item>{};
  int _burst = 0;
  int? _spent;

  /// La carta en oferta al entrar (queda marcada aunque se compre).
  String? _sale;

  int _price(_Item i) {
    final m = ref.read(dataProvider).balance.merchant;
    return switch (i) {
      _CardItem(:final id) => id == _sale ? m.salePrice : m.card,
      _TeaItem() => m.tea,
      _TalismanItem() => m.talisman,
      _RemoveItem() => m.remove,
      _UpgradeItem() => m.upgrade,
    };
  }

  void _select(_Item i) {
    if (_bought.contains(i)) return;
    HapticFeedback.selectionClick();
    ref.read(audioProvider).play(Sfx.cardSelect);
    setState(() => _selected = _selected == i ? null : i);
  }

  void _buy() {
    final i = _selected;
    if (i == null) return;
    if (i is _RemoveItem || i is _UpgradeItem) {
      setState(() => _picking = i);
      return;
    }
    final ctl = ref.read(runControllerProvider.notifier);
    switch (i) {
      case _CardItem(:final id):
        ctl.buyCard(id);
      case _TalismanItem():
        ctl.buyTalisman();
      case _TeaItem():
        ctl.buyTea();
        ref.read(audioProvider).play(Sfx.fountainHeal);
      case _RemoveItem() || _UpgradeItem():
        break;
    }
    _celebrate(i);
  }

  void _celebrate(_Item i) {
    HapticFeedback.heavyImpact();
    ref.read(audioProvider).play(Sfx.rewardTake);
    setState(() {
      _bought.add(i);
      _spent = _price(i);
      _selected = null;
      _picking = null;
      _burst++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final run = ref.watch(runControllerProvider);
    if (run == null) return const SizedBox();
    final data = ref.watch(dataProvider);
    final engine = ref.watch(runEngineProvider);
    final text = ref.watch(textProvider);
    final m = data.balance.merchant;
    _cards ??= run.shopCards;
    _talisman ??= run.shopTalisman;
    _sale ??= run.shopSale;
    final ctl = ref.read(runControllerProvider.notifier);

    if (_picking != null) {
      final upgrade = _picking is _UpgradeItem;
      return Scaffold(
        appBar: AppBar(
          title: Text(upgrade ? t.merchantPickUpgrade : t.merchantPickRemove),
          leading: BackButton(onPressed: () => setState(() => _picking = null)),
        ),
        body: DeckGrid(
          cards: run.deck,
          enabled: upgrade ? engine.canUpgrade : null,
          onPick: (c) {
            final item = _picking!;
            upgrade ? ctl.buyUpgrade(c.uid) : ctl.buyRemove(c.uid);
            _celebrate(item);
          },
        ),
      );
    }

    bool affordable(_Item i) => run.jade >= _price(i);
    bool used(_Item i) => switch (i) {
      _RemoveItem() => run.shopRemoved,
      _UpgradeItem() => run.shopUpgraded,
      _TeaItem() => run.shopTea,
      _ => _bought.contains(i),
    };

    final sel = _selected;
    final detail = switch (sel) {
      null => t.merchantHint,
      _CardItem(:final id) =>
        '${text.card(id)} · ${data.card(id).pinyin} ${data.card(id).hanzi}\n'
            '${t.cardEffect(data.card(id), text)}',
      _TalismanItem() =>
        '${text.talisman(_talisman!)}\n'
            '${t.talismanEffect(data.talisman(_talisman!).effect, text)}',
      _RemoveItem() => t.merchantRemove,
      _UpgradeItem() => t.merchantUpgrade(data.balance.fountainUpgrade),
      _TeaItem() => t.merchantTeaDetail(m.teaHeal),
    };

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: Palette.jade, size: 18),
                  const SizedBox(width: 4),
                  Bounce(
                    trigger: run.hp,
                    scale: 1.3,
                    child: Text(
                      '${run.hp}/${run.maxHp}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      JadeCount(jade: run.jade, size: 22),
                      if (_spent != null)
                        Positioned(
                          left: 20,
                          top: -6,
                          child: PopText(
                            key: ValueKey(_burst),
                            text: '−$_spent',
                            color: Palette.lacquer,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                  Expanded(child: TalismanRow(ids: run.talismans, wrap: false)),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 12, bottom: 16),
                  children: [
                    NpcPortrait(
                      asset: 'assets/art/npc/merchant.png',
                      color: Palette.jade,
                      height: 150,
                      badge: _Medallion(hanzi: '商', burst: _burst),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.merchantTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    _Section(t.merchantCards),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (final id in _cards!)
                          _Ware(
                            price: _price(_CardItem(id)),
                            oldPrice: id == _sale ? m.card : null,
                            tag: id == _sale ? t.merchantSale(m.sale) : null,
                            affordable: affordable(_CardItem(id)),
                            selected: _selected == _CardItem(id),
                            sold: _bought.contains(_CardItem(id)),
                            onTap: () => _select(_CardItem(id)),
                            child: CardWidget(
                              def: data.card(id),
                              width: 92,
                              selected: _selected == _CardItem(id),
                            ),
                          ),
                      ],
                    ),
                    if (_talisman != null) ...[
                      _Section(t.merchantTalisman),
                      _Ware(
                        price: m.talisman,
                        affordable: affordable(const _TalismanItem()),
                        selected: _selected is _TalismanItem,
                        sold: _bought.contains(const _TalismanItem()),
                        onTap: () => _select(const _TalismanItem()),
                        child: _Panel(
                          selected: _selected is _TalismanItem,
                          child: TalismanTile(id: _talisman!, badgeSize: 40),
                        ),
                      ),
                    ],
                    _Section(t.merchantServices),
                    for (final (item, icon, label) in [
                      (
                        const _RemoveItem() as _Item,
                        Icons.delete_outline,
                        t.merchantRemove,
                      ),
                      (
                        const _UpgradeItem() as _Item,
                        Icons.upgrade,
                        t.merchantUpgrade(data.balance.fountainUpgrade),
                      ),
                      (
                        const _TeaItem() as _Item,
                        Icons.emoji_food_beverage_outlined,
                        t.merchantTea(m.teaHeal),
                      ),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _Ware(
                          price: _price(item),
                          affordable: affordable(item),
                          selected: _selected == item,
                          sold: used(item),
                          soldLabel: t.merchantUsed,
                          onTap: () => _select(item),
                          child: _Panel(
                            selected: _selected == item,
                            child: Row(
                              children: [
                                Icon(icon, color: Palette.jade),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    label,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                height: 56,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    detail,
                    key: ValueKey(detail),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: sel == null ? Palette.textDim : Palette.text,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ctl.leaveShop();
                        context.go('/map');
                      },
                      child: Text(t.eventContinue),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: sel != null && affordable(sel) && !used(sel)
                          ? _buy
                          : null,
                      child: Text(
                        sel != null && !affordable(sel)
                            ? t.merchantNoJade
                            : t.confirm,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Medallion extends StatelessWidget {
  const _Medallion({required this.hanzi, required this.burst});

  final String hanzi;
  final int burst;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 120,
    height: 92,
    child: Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Bounce(
          trigger: burst,
          scale: 1.15,
          child: Container(
            width: 84,
            height: 84,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Palette.surface,
              border: Border.all(color: Palette.jade, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Palette.jade.withValues(alpha: 0.35),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Text(
              hanzi,
              style: const TextStyle(
                fontSize: 42,
                height: 1,
                color: Palette.jade,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: InkBurst(
            trigger: burst,
            colors: const [Palette.jade, Palette.gold, Colors.white],
            count: 28,
            radius: 140,
          ),
        ),
      ],
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
    child: Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w800,
        color: Palette.textDim,
      ),
    ),
  );
}

/// Caja clara para lo que no es carta (talismán y servicios).
class _Panel extends StatelessWidget {
  const _Panel({required this.selected, required this.child});

  final bool selected;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Palette.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: selected ? Palette.jade : Palette.line,
        width: selected ? 2.5 : 1.5,
      ),
      boxShadow: selected
          ? [
              BoxShadow(
                color: Palette.jade.withValues(alpha: 0.3),
                blurRadius: 10,
              ),
            ]
          : null,
    ),
    child: child,
  );
}

/// Un artículo con su precio; lo comprado queda atenuado con un sello.
class _Ware extends StatelessWidget {
  const _Ware({
    required this.price,
    required this.affordable,
    required this.selected,
    required this.sold,
    required this.onTap,
    required this.child,
    this.soldLabel,
    this.oldPrice,
    this.tag,
  });

  final int price;

  /// Precio tachado y cinta de oferta.
  final int? oldPrice;
  final String? tag;
  final bool affordable;
  final bool selected;
  final bool sold;
  final String? soldLabel;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GestureDetector(
      onTap: sold ? null : onTap,
      child: AnimatedScale(
        scale: selected ? 1.05 : 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            AnimatedOpacity(
              opacity: sold ? 0.35 : (affordable ? 1 : 0.6),
              duration: const Duration(milliseconds: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  child,
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const JadeCoin(size: 16),
                      const SizedBox(width: 4),
                      if (oldPrice != null) ...[
                        Text(
                          '$oldPrice',
                          style: const TextStyle(
                            color: Palette.textDim,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        '$price',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: affordable ? Palette.jade : Palette.lacquer,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (tag != null && !sold)
              Positioned(top: -4, right: -6, child: _SaleTag(tag!)),
            if (sold)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 1.8, end: 1),
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOutBack,
                builder: (_, v, child) => Transform.scale(
                  scale: v,
                  child: Transform.rotate(angle: -0.2, child: child),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Palette.lacquer, width: 2),
                    borderRadius: BorderRadius.circular(6),
                    color: Palette.surface.withValues(alpha: 0.85),
                  ),
                  child: Text(
                    soldLabel ?? t.merchantBought,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Palette.lacquer,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Cinta de oferta que se balancea apenas, para que se note sin gritar.
class _SaleTag extends StatefulWidget {
  const _SaleTag(this.label);

  final String label;

  @override
  State<_SaleTag> createState() => _SaleTagState();
}

class _SaleTagState extends State<_SaleTag>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, child) => Transform.rotate(
      angle: 0.12 + 0.05 * Curves.easeInOut.transform(_c.value),
      child: child,
    ),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Palette.lacquer,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Palette.lacquer.withValues(alpha: 0.35),
            blurRadius: 6,
          ),
        ],
      ),
      child: Text(
        widget.label,
        style: const TextStyle(
          color: Palette.onColor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}
