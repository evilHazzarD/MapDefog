import 'package:flutter/material.dart' hide Badge;
import 'package:mapdefog/domain/progress.dart';
import 'package:mapdefog/l10n/app_localizations.dart';
import 'package:mapdefog/l10n/game_text.dart';
import 'package:mapdefog/ui/components/components.dart';
import 'package:mapdefog/ui/game_data.dart';
import 'package:mapdefog/ui/texts.dart';
import 'package:mapdefog/ui/theme/theme.dart';

class DeedsScreen extends StatefulWidget {
  const DeedsScreen({super.key, required this.data, required this.onBack});

  final GameData data;
  final VoidCallback onBack;

  @override
  State<DeedsScreen> createState() => _DeedsScreenState();
}

class _DeedsScreenState extends State<DeedsScreen> {
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = AppLocalizations.of(context);
    final done = {for (final b in widget.data.badges) b.id};

    return ColoredBox(
      color: p.bg,
      child: Column(
        children: [
          TopBar(c.deedsTitle(done.length, Badges.all.length), onBack: widget.onBack),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              children: [
                for (final g in Badges.groups) ...[
                  Builder(
                    builder: (context) {
                      final tiers = Badges.all.where((b) => b.group == g.id).toList();
                      final have = tiers.where((b) => done.contains(b.id)).length;
                      Badge? next;
                      for (final b in tiers) {
                        if (!done.contains(b.id)) {
                          next = b;
                          break;
                        }
                      }
                      final (color, soft) = groupColors(g.id, p);
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: UCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(color: soft, shape: BoxShape.circle),
                                    child: Icon(groupIcon(g.id), color: color, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(c.groupName(g.id), style: UType.strong(p)),
                                        Text(
                                          next == null ? c.allTiersComplete : c.badgeText(next),
                                          style: UType.muted(p),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '$have/${tiers.length}',
                                    style: UType.strong(p)
                                        .copyWith(color: next == null ? color : p.muted),
                                  ),
                                ],
                              ),
                              if (next != null) ...[
                                const SizedBox(height: 10),
                                ProgressBar(
                                  next.share(widget.data.facts),
                                  color: color,
                                  track: soft,
                                ),
                              ],
                              const SizedBox(height: 12),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    for (final b in tiers)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: GestureDetector(
                                          onTap: () => _openBadge(b),
                                          child: SizedBox(
                                            width: 66,
                                            child: Column(
                                              children: [
                                                Container(
                                                  width: 44,
                                                  height: 44,
                                                  decoration: BoxDecoration(
                                                    color: done.contains(b.id) ? soft : p.surface2,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: done.contains(b.id) ? p.gilt : p.line,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    groupIcon(g.id),
                                                    color: done.contains(b.id)
                                                        ? color
                                                        : p.faint.withValues(alpha: 0.5),
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  c.badgeTitle(b.id),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  style: UType.small(p).copyWith(
                                                    fontSize: 10.5,
                                                    color: done.contains(b.id) ? p.ink : p.faint,
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
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openBadge(Badge b) async {
    final p = context.palette;
    final c = AppLocalizations.of(context);
    final done = {for (final x in widget.data.badges) x.id};
    final on = done.contains(b.id);
    final (color, soft) = groupColors(b.group, p);
    await showCelebrateDialog(
      context,
      icon: groupIcon(b.group),
      color: on ? color : p.faint,
      soft: on ? soft : p.surface2,
      eyebrow: on ? c.unlocked : c.locked,
      title: c.badgeTitle(b.id),
      text:
          c.badgeText(b) +
          (on ? '' : '\n${c.percentProgress((b.share(widget.data.facts) * 100).round())}'),
    );
  }
}
