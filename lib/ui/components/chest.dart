import 'package:flutter/material.dart';
import 'package:mapdefog/data/models.dart';
import 'package:mapdefog/domain/rarity.dart';
import 'package:mapdefog/domain/relics.dart';
import 'package:mapdefog/l10n/app_localizations.dart';
import 'package:mapdefog/l10n/game_text.dart';
import 'package:mapdefog/ui/components/components.dart';
import 'package:mapdefog/ui/texts.dart';
import 'package:mapdefog/ui/theme/theme.dart';

/// Cache-open celebration — shake, open, claim loot (Android ChestDialog).
Future<void> showChestDialog(
  BuildContext context, {
  required FindRow find,
  required Set<String> owned,
  required VoidCallback onDismiss,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _ChestDialog(find: find, owned: owned, onDismiss: onDismiss),
  );
}

class _ChestDialog extends StatefulWidget {
  const _ChestDialog({required this.find, required this.owned, required this.onDismiss});

  final FindRow find;
  final Set<String> owned;
  final VoidCallback onDismiss;

  @override
  State<_ChestDialog> createState() => _ChestDialogState();
}

class _ChestDialogState extends State<_ChestDialog> with SingleTickerProviderStateMixin {
  var _open = false;
  late final AnimationController _shake;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _runOpen();
  }

  Future<void> _runOpen() async {
    await _shake.forward();
    await _shake.reverse();
    if (!mounted) return;
    setState(() => _open = true);
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = AppLocalizations.of(context);
    final rarity = Rarity.values[widget.find.rarity.clamp(0, Rarity.values.length - 1)];
    final (_, color, soft) = rarityColors(rarity, p);
    final relic = widget.find.relic.isEmpty ? null : Relics.byId(widget.find.relic);

    return Dialog(
      backgroundColor: p.bg,
      shape: const RoundedRectangleBorder(borderRadius: U.rLg),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(c.cacheOpened.toUpperCase(), style: UType.eyebrow(p).copyWith(color: color)),
            const SizedBox(height: 4),
            Text(
              c.cacheOf(c.rarity(rarity)),
              style: UType.title(p).copyWith(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _shake,
              builder: (context, child) {
                final t = (_shake.value - 0.5) * 2;
                return Transform.rotate(angle: t * 0.12, child: child);
              },
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: soft,
                  borderRadius: U.rMd,
                  border: Border.all(color: color, width: 3),
                ),
                child: Icon(
                  _open ? Icons.inventory_2_rounded : Icons.lock_rounded,
                  color: color,
                  size: 48,
                ),
              ),
            ),
            if (_open) ...[
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RewardChip(text: c.plusGold(widget.find.coins), color: p.gold, soft: p.goldSoft),
                  const SizedBox(width: 8),
                  _RewardChip(text: c.plusXp(widget.find.xp), color: p.accent, soft: p.accentSoft),
                ],
              ),
              if (relic != null) ...[
                const SizedBox(height: 18),
                Builder(
                  builder: (context) {
                    final (_, rc, rs) = rarityColors(relic.rarity, p);
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: p.surface, borderRadius: U.rMd),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: rs,
                            child: Icon(relicIcon(relic.id), color: rc),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (widget.find.duplicate ? c.relicDuplicate : c.relicNew)
                                      .toUpperCase(),
                                  style: UType.eyebrow(p)
                                      .copyWith(color: widget.find.duplicate ? p.faint : rc),
                                ),
                                Text(c.relicName(relic.id), style: UType.strong(p)),
                                Text(c.relicLore(relic.id), style: UType.muted(p)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 6),
                Text(
                  c.relicSetProgress(
                    c.setName(relic.set),
                    Relics.inSet(relic.set).where((r) => widget.owned.contains(r.id)).length,
                    6,
                  ),
                  style: UType.small(p),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 20),
              PrimaryButton(
                c.takeLoot,
                color: color,
                onPressed: () {
                  Navigator.pop(context);
                  widget.onDismiss();
                },
              ),
            ] else
              const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  const _RewardChip({required this.text, required this.color, required this.soft});

  final String text;
  final Color color;
  final Color soft;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: soft, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: UType.strong(context.palette).copyWith(color: color)),
    );
  }
}
