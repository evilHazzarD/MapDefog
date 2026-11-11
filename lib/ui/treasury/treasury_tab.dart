import 'package:animated_options_bar/animated_options_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapdefog/app/app_scope.dart';
import 'package:mapdefog/data/settings_store.dart';
import 'package:mapdefog/domain/quests.dart';
import 'package:mapdefog/domain/relics.dart' show Relic, Relics;
import 'package:mapdefog/l10n/app_localizations.dart';
import 'package:mapdefog/l10n/game_text.dart';
import 'package:mapdefog/ui/components/components.dart';
import 'package:mapdefog/ui/game_data.dart';
import 'package:mapdefog/ui/navigation.dart';
import 'package:mapdefog/ui/texts.dart';
import 'package:mapdefog/ui/theme/theme.dart';
import 'package:mapdefog/ui/treasury/shop_art.dart';

enum _TreasuryPart { relics, shop }

class TreasuryTab extends StatefulWidget {
  const TreasuryTab({super.key, required this.data, required this.go, required this.mapFocus});

  final GameData data;
  final FogGo go;
  final ValueNotifier<MapFocus?> mapFocus;

  @override
  State<TreasuryTab> createState() => _TreasuryTabState();
}

class _TreasuryTabState extends State<TreasuryTab> {
  _TreasuryPart _part = _TreasuryPart.relics;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = AppLocalizations.of(context);
    final data = widget.data;
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(c.treasuryTitle, style: UType.title(p))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: p.goldSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      const CoinIcon(size: 16),
                      const SizedBox(width: 6),
                      Text(
                        NumberFormat('#,###').format(data.coins),
                        style: UType.strong(p).copyWith(color: p.gold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(c.relicsCount(data.relics.length, Relics.all.length), style: UType.sub(p)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: p.line),
              ),
              child: AnimatedOptionsBar<_TreasuryPart>(
                items: _TreasuryPart.values,
                selectedId: _part.name,
                onItemSelected: (id) => setState(() => _part = _TreasuryPart.values.byName(id)),
                getId: (v) => v.name,
                getLabel: (v) => v == _TreasuryPart.relics ? c.relicsTab : c.shopTab,
                config: OptionsBarConfig(
                  textPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
                  borderRadius: 50,
                  itemSpacing: 8,
                  scrollEdgePadding: 0,
                  activeTextColor: p.onAccent,
                  inactiveTextColor: p.muted,
                  selectionColor: p.accent,
                  animationDuration: const Duration(milliseconds: 260),
                  textStyle: const TextStyle(
                    fontFamily: 'AlegreyaSans',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  centerOptions: true,
                ),
              ),
            ),
            if (_part == _TreasuryPart.relics) _RelicsPart(data: data) else _ShopPart(data: data),
          ],
        ),
      ),
    );
  }
}

class _RelicsPart extends StatefulWidget {
  const _RelicsPart({required this.data});
  final GameData data;

  @override
  State<_RelicsPart> createState() => _RelicsPartState();
}

class _RelicsPartState extends State<_RelicsPart> {
  Future<void> _showRelic(BuildContext context, Relic r) async {
    final p = context.palette;
    final c = AppLocalizations.of(context);
    final count = widget.data.finds.where((f) => f.relic == r.id).length;
    final (_, color, soft) = rarityColors(r.rarity, p);
    await showCelebrateDialog(
      context,
      icon: relicIcon(r.id),
      color: color,
      soft: soft,
      eyebrow: '${c.rarity(r.rarity)} · ${c.setName(r.set)}',
      title: c.relicName(r.id),
      text: '${c.relicLore(r.id)}\n\n${c.foundTimes(count)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = AppLocalizations.of(context);
    final data = widget.data;

    return Column(
      children: [
        for (final set in Relics.sets) ...[
          const SizedBox(height: 14),
          Builder(
            builder: (context) {
              final relics = Relics.inSet(set);
              final have = relics.where((r) => data.relics.contains(r.id)).length;
              final (_, color, soft) = rarityColors(Relics.setRarity(set), p);
              return UCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: soft, shape: BoxShape.circle),
                          child: Icon(setIcon(set), color: color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.setName(set), style: UType.strong(p)),
                              Text(
                                have == relics.length
                                    ? c.setTitle(set)
                                    : c.completeFor(Relics.setReward(set).$1),
                                style: UType.muted(p),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '$have/${relics.length}',
                          style: UType.strong(p)
                              .copyWith(color: have == relics.length ? color : p.muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (final row in _chunks(relics, 3))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            for (final r in row)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: _RelicTile(
                                    relic: r,
                                    owned: data.relics.contains(r.id),
                                    color: color,
                                    soft: soft,
                                    onTap: data.relics.contains(r.id)
                                        ? () => _showRelic(context, r)
                                        : null,
                                  ),
                                ),
                              ),
                            for (var i = row.length; i < 3; i++) const Expanded(child: SizedBox()),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _RelicTile extends StatelessWidget {
  const _RelicTile({
    required this.relic,
    required this.owned,
    required this.color,
    required this.soft,
    this.onTap,
  });

  final Relic relic;
  final bool owned;
  final Color color;
  final Color soft;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = AppLocalizations.of(context);
    return Material(
      color: owned ? soft : p.surface2,
      borderRadius: U.rSm,
      child: InkWell(
        onTap: onTap,
        borderRadius: U.rSm,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Column(
            children: [
              if (owned)
                Icon(relicIcon(relic.id), color: color, size: 26)
              else
                Text('?', style: UType.strong(p).copyWith(fontSize: 20, color: p.faint)),
              const SizedBox(height: 6),
              Text(
                owned ? c.relicName(relic.id) : '???',
                textAlign: TextAlign.center,
                maxLines: 2,
                style: UType.small(p).copyWith(color: owned ? p.ink : p.faint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShopPart extends StatefulWidget {
  const _ShopPart({required this.data});
  final GameData data;

  @override
  State<_ShopPart> createState() => _ShopPartState();
}

class _ShopPartState extends State<_ShopPart> {
  Future<void> _confirmBuy(
    BuildContext context,
    AppLocalizations c,
    String name,
    int price,
    int coins,
    Future<void> Function() action,
  ) async {
    await showConfirmDialog(
      context,
      title: c.buyConfirm(name),
      text: c.buyCost(price, coins),
      confirm: c.buy,
      onConfirm: action,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = AppLocalizations.of(context);
    final scope = AppScope.of(context);
    final s = widget.data.settings;
    final data = widget.data;
    final now = DateTime.now().millisecondsSinceEpoch;

    Future<void> buy(String item, int price, Future<void> Function() apply) async {
      final ok = await scope.explorer.buy(item, price);
      if (!context.mounted) return;
      if (ok) {
        await apply();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(c.notEnoughCoins)));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(c.fogStyles),
        for (final row in _chunks(Shop.styles, 2)) ...[
          Row(
            children: [
              for (final st in row)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10, bottom: 10),
                    child: _StyleCard(
                      id: st.id,
                      price: st.price,
                      owned: s.owned.contains(st.id),
                      active: s.fog == st.id,
                      coins: data.coins,
                      onTap: () {
                        if (s.owned.contains(st.id)) {
                          scope.settings.update((x) => x.copyWith(fog: st.id));
                        } else {
                          _confirmBuy(
                            context,
                            c,
                            c.styleName(st.id),
                            st.price,
                            data.coins,
                            () => buy('style:${st.id}', st.price, () async {
                              await scope.settings.update(
                                (x) => x.copyWith(owned: {...x.owned, st.id}, fog: st.id),
                              );
                            }),
                          );
                        }
                      },
                    ),
                  ),
                ),
              if (row.length == 1) const Expanded(child: SizedBox()),
            ],
          ),
        ],
        SectionTitle(c.boosts),
        _BoostRow(
          art: BoostArt.lantern,
          color: p.gold,
          soft: p.goldSoft,
          title: c.lanternTitle,
          text: c.lanternBody,
          price: Shop.lantern,
          coins: data.coins,
          onTap: () => _confirmBuy(
            context,
            c,
            c.lanternTitle,
            Shop.lantern,
            data.coins,
            () => buy('lantern', Shop.lantern, () async {
              await scope.settings.update(
                (x) => x.copyWith(lanternUntil: mathMax(x.lanternUntil, now) + Shop.boostMs),
              );
            }),
          ),
        ),
        const SizedBox(height: 10),
        _BoostRow(
          art: BoostArt.radar,
          color: p.violet,
          soft: p.violetSoft,
          title: c.radarTitle,
          text: c.radarBody,
          price: Shop.radar,
          coins: data.coins,
          onTap: () => _confirmBuy(
            context,
            c,
            c.radarTitle,
            Shop.radar,
            data.coins,
            () => buy('radar', Shop.radar, () async {
              await scope.settings.update(
                (x) => x.copyWith(radarUntil: mathMax(x.radarUntil, now) + Shop.boostMs),
              );
            }),
          ),
        ),
        const SizedBox(height: 10),
        _BoostRow(
          art: BoostArt.shield,
          color: p.sky,
          soft: p.skySoft,
          title: c.streakShieldTitle,
          text: '${c.streakShieldBody} (${c.shieldCount(s.shields, Shop.maxShields)})',
          price: Shop.shield,
          coins: data.coins,
          enabled: s.shields < Shop.maxShields,
          onTap: () => _confirmBuy(
            context,
            c,
            c.streakShieldTitle,
            Shop.shield,
            data.coins,
            () => buy('shield', Shop.shield, () async {
              await scope.settings.update(
                (x) => x.copyWith(shields: (x.shields + 1).clamp(0, Shop.maxShields)),
              );
            }),
          ),
        ),
        const SizedBox(height: 10),
        Builder(
          builder: (context) {
            final canReroll =
                s.beacon.day == data.today && !data.todayRow.beacon && s.rerollDay != data.today;
            return _BoostRow(
              art: BoostArt.reroll,
              color: p.flame,
              soft: p.flameSoft,
              title: c.rerollTitle,
              text: canReroll ? c.rerollBody : c.rerollDone,
              price: Shop.reroll,
              coins: data.coins,
              enabled: canReroll,
              onTap: () {
                final fix = scope.explorer.liveValue.fix;
                if (fix == null) return;
                _confirmBuy(
                  context,
                  c,
                  c.rerollTitle,
                  Shop.reroll,
                  data.coins,
                  () => buy('reroll', Shop.reroll, () async {
                    final placed = Beacons.place(
                      data.today,
                      1,
                      fix.lat,
                      fix.lon,
                      data.level,
                      (la, lo) => scope.fog.exploredAround(la, lo, 120),
                    );
                    await scope.settings.update(
                      (x) => x.copyWith(
                        beacon: BeaconSpot(data.today, placed.$1, placed.$2),
                        rerollDay: data.today,
                      ),
                    );
                  }),
                );
              },
            );
          },
        ),
      ],
    );
  }

  int mathMax(int a, int b) => a > b ? a : b;
}

class _StyleCard extends StatelessWidget {
  const _StyleCard({
    required this.id,
    required this.price,
    required this.owned,
    required this.active,
    required this.coins,
    required this.onTap,
  });

  final String id;
  final int price;
  final bool owned;
  final bool active;
  final int coins;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = AppLocalizations.of(context);
    return Material(
      color: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: U.rMd,
        side: BorderSide(color: active ? p.accent : p.line, width: active ? 2 : 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: U.rMd,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FogSwatch(id),
              const SizedBox(height: 8),
              Text(c.styleName(id), style: UType.strong(p).copyWith(fontSize: 14)),
              Text(c.styleText(id), maxLines: 2, style: UType.small(p)),
              const SizedBox(height: 6),
              if (active)
                Text(c.active, style: UType.small(p).copyWith(color: p.accent))
              else if (owned)
                Text(c.tapToUse, style: UType.small(p))
              else
                _Price(price: price, affordable: coins >= price),
            ],
          ),
        ),
      ),
    );
  }
}

class _Price extends StatelessWidget {
  const _Price({required this.price, required this.affordable});
  final int price;
  final bool affordable;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        CoinIcon(size: 13, color: affordable ? p.gold : p.faint),
        const SizedBox(width: 4),
        Text(
          '$price',
          style: UType.strong(p).copyWith(fontSize: 14, color: affordable ? p.gold : p.faint),
        ),
      ],
    );
  }
}

class _BoostRow extends StatelessWidget {
  const _BoostRow({
    required this.art,
    required this.color,
    required this.soft,
    required this.title,
    required this.text,
    required this.price,
    required this.coins,
    required this.onTap,
    this.enabled = true,
  });

  final BoostArt art;
  final Color color;
  final Color soft;
  final String title;
  final String text;
  final int price;
  final int coins;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return UCard(
      onTap: enabled ? onTap : null,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: soft, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: BoostIcon(art, color: enabled ? color : p.faint, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: UType.strong(p).copyWith(color: enabled ? p.ink : p.faint, fontSize: 15),
                ),
                Text(text, style: UType.muted(p)),
              ],
            ),
          ),
          if (enabled)
            _Price(price: price, affordable: coins >= price)
          else
            Icon(Icons.check_rounded, color: p.faint, size: 18),
        ],
      ),
    );
  }
}

List<List<T>> _chunks<T>(List<T> list, int size) {
  final out = <List<T>>[];
  for (var i = 0; i < list.length; i += size) {
    out.add(list.sublist(i, i + size > list.length ? list.length : i + size));
  }
  return out;
}
