import 'package:flutter/material.dart';
import 'package:mapdefog/l10n/app_localizations.dart';
import 'package:mapdefog/ui/theme/theme.dart';

Widget uCard(
  BuildContext context, {
  EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  VoidCallback? onTap,
  required Widget child,
}) {
  final p = context.palette;
  return Material(
    color: p.surface,
    shape: RoundedRectangleBorder(
      borderRadius: U.rMd,
      side: BorderSide(color: p.gilt.withValues(alpha: 0.55)),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(padding: padding, child: child),
    ),
  );
}

class UCard extends StatelessWidget {
  const UCard({
    super.key,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    required this.child,
  });

  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      uCard(context, onTap: onTap, padding: padding, child: child);
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 22, 4, 10),
      child: Text(text.toUpperCase(), style: UType.eyebrow(context.palette)),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.icon,
    this.color,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? color;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = color ?? p.accent;
    return FilledButton(
      onPressed: enabled ? onPressed : null,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        backgroundColor: c,
        foregroundColor: p.onAccent,
        disabledBackgroundColor: p.line,
        disabledForegroundColor: p.faint,
        shape: const RoundedRectangleBorder(borderRadius: U.rMd),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
          Text(label, style: UType.button(p)),
        ],
      ),
    );
  }
}

class FogChip extends StatelessWidget {
  const FogChip(this.label, {super.key, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = p.accent;
    // FilterChip requires a Material ancestor; Settings (and similar screens)
    // use ColoredBox instead of Scaffold, so provide one locally.
    return Material(
      color: Colors.transparent,
      child: FilterChip(
        selected: selected,
        onSelected: (_) => onTap(),
        label: Text(label, style: UType.muted(p).copyWith(fontWeight: FontWeight.w500)),
        shape: const RoundedRectangleBorder(borderRadius: U.rSm),
        selectedColor: c.withValues(alpha: 0.16),
        checkmarkColor: c,
        side: BorderSide(color: selected ? c.withValues(alpha: 0.5) : p.line),
        labelStyle: TextStyle(color: selected ? c : p.muted),
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar(this.title, {super.key, this.onBack, this.actions});

  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final topInset = MediaQuery.paddingOf(context).top;
    return Padding(
      padding: EdgeInsets.only(top: topInset),
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            if (onBack != null)
              IconButton(
                onPressed: onBack,
                icon: Icon(Icons.arrow_back_rounded, color: p.ink),
              )
            else
              const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: UType.strong(p).copyWith(fontSize: 19),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ...?actions,
          ],
        ),
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  const ProgressBar(this.fraction, {super.key, this.color, this.track, this.height = 8});

  final double fraction;
  final Color? color;
  final Color? track;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: fraction.clamp(0, 1),
        minHeight: height,
        color: color ?? p.accent,
        backgroundColor: track ?? p.accentSoft,
      ),
    );
  }
}

class CoinIcon extends StatelessWidget {
  const CoinIcon({super.key, this.size = 16, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.palette.gold;
    return Icon(Icons.paid_rounded, size: size, color: c);
  }
}

Future<void> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String text,
  required String confirm,
  required VoidCallback onConfirm,
  bool danger = false,
}) {
  final p = context.palette;
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: p.bg,
      title: Text(title, style: UType.strong(p).copyWith(fontSize: 19)),
      content: Text(text, style: UType.sub(p)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(
            AppLocalizations.of(context).cancel,
            style: UType.button(p).copyWith(color: p.muted),
          ),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(ctx);
          },
          child: Text(
            confirm,
            style: UType.button(p).copyWith(color: danger ? p.danger : p.accent),
          ),
        ),
      ],
    ),
  );
}

Future<void> showCelebrateDialog(
  BuildContext context, {
  required IconData icon,
  required Color color,
  required Color soft,
  required String eyebrow,
  required String title,
  required String text,
  VoidCallback? onDismiss,
}) {
  final p = context.palette;
  return showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: p.bg,
      shape: const RoundedRectangleBorder(borderRadius: U.rLg),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(color: soft, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 42),
            ),
            const SizedBox(height: 18),
            Text(eyebrow.toUpperCase(), style: UType.eyebrow(p).copyWith(color: color)),
            const SizedBox(height: 6),
            Text(title, textAlign: TextAlign.center, style: UType.title(p).copyWith(fontSize: 22)),
            const SizedBox(height: 8),
            Text(text, textAlign: TextAlign.center, style: UType.sub(p)),
            const SizedBox(height: 20),
            PrimaryButton(
              AppLocalizations.of(context).nice,
              color: color,
              onPressed: () {
                Navigator.pop(ctx);
                onDismiss?.call();
              },
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> showTimePickerDialog(
  BuildContext context, {
  required int minutesAfterMidnight,
  required void Function(int minutes) onPicked,
}) async {
  final initial = TimeOfDay(hour: minutesAfterMidnight ~/ 60, minute: minutesAfterMidnight % 60);
  final picked = await showTimePicker(context: context, initialTime: initial);
  if (picked != null) {
    onPicked(picked.hour * 60 + picked.minute);
  }
}
