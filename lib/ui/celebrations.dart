import 'package:flutter/material.dart';
import 'package:mapdefog/app/app_scope.dart';
import 'package:mapdefog/data/models.dart';
import 'package:mapdefog/domain/progress.dart' as prog;
import 'package:mapdefog/domain/relics.dart';
import 'package:mapdefog/l10n/app_localizations.dart';
import 'package:mapdefog/l10n/game_text.dart';
import 'package:mapdefog/ui/components/chest.dart';
import 'package:mapdefog/ui/components/components.dart';
import 'package:mapdefog/ui/game_data.dart';
import 'package:mapdefog/ui/texts.dart';
import 'package:mapdefog/ui/theme/theme.dart';

/// Chests, new badges, finished relic sets, and level-ups — each shown once.
class CelebrationsHost extends StatefulWidget {
  const CelebrationsHost({super.key, required this.data});

  final GameData data;

  @override
  State<CelebrationsHost> createState() => _CelebrationsHostState();
}

class _CelebrationsHostState extends State<CelebrationsHost> {
  var _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShow());
  }

  @override
  void didUpdateWidget(covariant CelebrationsHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShow());
  }

  Future<void> _maybeShow() async {
    if (!mounted || _busy) return;
    if (!widget.data.settings.onboarded) return;

    final data = widget.data;
    final s = data.settings;
    final c = AppLocalizations.of(context);
    final scope = AppScope.of(context);
    final p = context.palette;

    final chestFind = data.finds.where((f) => !f.seen).firstOrNull;
    final fresh = data.badges.where((b) => !s.seenBadges.contains(b.id)).toList();
    final newSet = Relics.completeSets(data.relics)
        .where((set) => !s.seenBadges.contains('set:$set'))
        .firstOrNull;

    _busy = true;
    try {
      if (chestFind != null) {
        await showChestDialog(
          context,
          find: chestFind,
          owned: data.relics,
          onDismiss: () {
            scope.db.markSeen(chestFind.key);
          },
        );
        return;
      }

      if (newSet != null) {
        final reward = Relics.setReward(newSet);
        await showCelebrateDialog(
          context,
          icon: setIcon(newSet),
          color: p.violet,
          soft: p.violetSoft,
          eyebrow: c.setComplete,
          title: c.setName(newSet),
          text: c.setCompleteText(c.setTitle(newSet), reward.$1),
          onDismiss: () {
            scope.settings.update(
              (it) => it.copyWith(seenBadges: {...it.seenBadges, 'set:$newSet'}),
            );
          },
        );
        return;
      }

      if (fresh.isNotEmpty) {
        final b = fresh.last;
        final (color, soft) = badgeColors(b, p);
        await showCelebrateDialog(
          context,
          icon: groupIcon(b.group),
          color: color,
          soft: soft,
          eyebrow: c.badgeUnlocked,
          title: c.badgeTitle(b.id),
          text: c.badgeText(b) + (fresh.length > 1 ? '\n${c.badgeMore(fresh.length - 1)}' : ''),
          onDismiss: () {
            scope.settings.update(
              (it) => it.copyWith(seenBadges: {...it.seenBadges, ...fresh.map((f) => f.id)}),
            );
          },
        );
        return;
      }

      if (data.level > s.levelSeen) {
        final gold = [for (var l = s.levelSeen + 1; l <= data.level; l++) prog.Levels.reward(l)]
            .fold<int>(0, (a, b) => a + b);
        await showCelebrateDialog(
          context,
          icon: Icons.map_rounded,
          color: p.accent,
          soft: p.accentSoft,
          eyebrow: c.levelUp,
          title: '${c.levelN(data.level)} · ${c.rank(prog.Levels.rank(data.level))}',
          text: c.levelUpText(gold),
          onDismiss: () async {
            final level = data.level;
            final now = DateTime.now().millisecondsSinceEpoch;
            for (var l = s.levelSeen + 1; l <= level; l++) {
              await scope.db.grant(EntryRow(ref: 'lvl:$l', at: now, coins: prog.Levels.reward(l)));
            }
            await scope.settings.update((it) => it.copyWith(levelSeen: level));
          },
        );
      }
    } finally {
      if (mounted) _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
