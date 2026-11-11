import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapdefog/app/app_scope.dart';
import 'package:mapdefog/data/backup.dart';
import 'package:mapdefog/data/settings_store.dart';
import 'package:mapdefog/l10n/app_localizations.dart';
import 'package:mapdefog/ui/components/components.dart';
import 'package:mapdefog/ui/theme/theme.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.settings, required this.onBack});

  final Settings settings;
  final VoidCallback onBack;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _density;
  String _version = '…';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = info.version);
    });
    _density = widget.settings.fogDensity;
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.fogDensity != widget.settings.fogDensity) {
      _density = widget.settings.fogDensity;
    }
  }

  SettingsStore get _store => AppScope.of(context).settings;

  Future<void> _update(Settings Function(Settings) change) async {
    await _store.update(change);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = AppLocalizations.of(context);
    final s = _store.now();

    return ColoredBox(
      color: p.bg,
      child: Column(
        children: [
          TopBar(c.settingsTitle, onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(c.sectionNotifications),
                  UCard(
                    child: Column(
                      children: [
                        _SwitchRow(
                          title: c.dailyReminderTitle,
                          subtitle: c.dailyReminderSubtitle,
                          value: s.remind,
                          onChanged: (v) => _update((x) => x.copyWith(remind: v)),
                        ),
                        if (s.remind) ...[
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => showTimePickerDialog(
                              context,
                              minutesAfterMidnight: s.remindAt,
                              onPicked: (m) => _update((x) => x.copyWith(remindAt: m)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Text(
                                c.remindAtLabel(_formatRemind(context, s.remindAt)),
                                style: UType.button(p).copyWith(color: p.accent),
                              ),
                            ),
                          ),
                        ],
                        Divider(height: 24, color: p.line),
                        _SwitchRow(
                          title: c.nearbyCachesTitle,
                          subtitle: c.nearbyCachesSubtitle,
                          value: s.nearbyAlerts,
                          onChanged: (v) => _update((x) => x.copyWith(nearbyAlerts: v)),
                        ),
                      ],
                    ),
                  ),
                  SectionTitle(c.sectionFog),
                  UCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.fogDensityTitle, style: UType.strong(p)),
                        Text(c.fogDensitySubtitle, style: UType.muted(p)),
                        Slider(
                          value: _density,
                          min: 0.6,
                          max: 1,
                          activeColor: p.accent,
                          inactiveColor: p.accentSoft,
                          onChanged: (v) => setState(() => _density = v),
                          onChangeEnd: (v) => _update((x) => x.copyWith(fogDensity: v)),
                        ),
                      ],
                    ),
                  ),
                  SectionTitle(c.sectionUnits),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FogChip(
                        c.unitsMetric,
                        selected: s.units == UnitsPref.metric,
                        onTap: () => _update((x) => x.copyWith(units: UnitsPref.metric)),
                      ),
                      FogChip(
                        c.unitsImperial,
                        selected: s.units == UnitsPref.imperial,
                        onTap: () => _update((x) => x.copyWith(units: UnitsPref.imperial)),
                      ),
                    ],
                  ),
                  SectionTitle(c.sectionFeel),
                  UCard(
                    child: _SwitchRow(
                      title: c.hapticsTitle,
                      subtitle: c.hapticsSubtitle,
                      value: s.haptics,
                      onChanged: (v) => _update((x) => x.copyWith(haptics: v)),
                    ),
                  ),
                  SectionTitle(c.sectionAppearance),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FogChip(
                        c.themeSystem,
                        selected: s.theme == ThemeModePref.system,
                        onTap: () => _update((x) => x.copyWith(theme: ThemeModePref.system)),
                      ),
                      FogChip(
                        c.themeLight,
                        selected: s.theme == ThemeModePref.light,
                        onTap: () => _update((x) => x.copyWith(theme: ThemeModePref.light)),
                      ),
                      FogChip(
                        c.themeDark,
                        selected: s.theme == ThemeModePref.dark,
                        onTap: () => _update((x) => x.copyWith(theme: ThemeModePref.dark)),
                      ),
                    ],
                  ),
                  SectionTitle(c.sectionLanguage),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FogChip(
                        c.languageSystem,
                        selected: s.language == LanguagePref.system,
                        onTap: () => _update((x) => x.copyWith(language: LanguagePref.system)),
                      ),
                      FogChip(
                        c.languageEnglish,
                        selected: s.language == LanguagePref.en,
                        onTap: () => _update((x) => x.copyWith(language: LanguagePref.en)),
                      ),
                      FogChip(
                        c.languageRussian,
                        selected: s.language == LanguagePref.ru,
                        onTap: () => _update((x) => x.copyWith(language: LanguagePref.ru)),
                      ),
                      FogChip(
                        c.languageUkrainian,
                        selected: s.language == LanguagePref.uk,
                        onTap: () => _update((x) => x.copyWith(language: LanguagePref.uk)),
                      ),
                    ],
                  ),
                  SectionTitle(c.sectionBackup),
                  UCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.backupBlurb, style: UType.muted(p)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () async {
                                try {
                                  final json = await Backup.exportJson(AppScope.of(context).db);
                                  final dir = await getTemporaryDirectory();
                                  final file = File('${dir.path}/mapdefog-backup.json');
                                  await file.writeAsString(json);
                                  await SharePlus.instance.share(
                                    ShareParams(files: [XFile(file.path)]),
                                  );
                                } on Exception catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(content: Text(c.exportFailed(e))));
                                }
                              },
                              child: Text(
                                c.exportLabel,
                                style: UType.button(p).copyWith(color: p.accent),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                  final picked = await FilePicker.pickFile(
                                    type: FileType.custom,
                                    allowedExtensions: ['json'],
                                  );
                                  if (picked == null) return;
                                  final text = String.fromCharCodes(await picked.readAsBytes());
                                  if (!context.mounted) return;
                                  final scope = AppScope.of(context);
                                  var confirmed = false;
                                  await showConfirmDialog(
                                    context,
                                    title: c.importConfirmTitle,
                                    text: c.importConfirmBody,
                                    confirm: c.importConfirmAction,
                                    onConfirm: () => confirmed = true,
                                  );
                                  if (!confirmed || !context.mounted) return;
                                  await Backup.importJson(scope.db, text);
                                  await scope.reloadAll();
                                  scope.notifySettings();
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(content: Text(c.atlasImported)));
                                } on Exception catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(content: Text(c.importFailed(e))));
                                }
                              },
                              child: Text(
                                c.importLabel,
                                style: UType.button(p).copyWith(color: p.accent),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SectionTitle(c.sectionAbout),
                  UCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.aboutBody, style: UType.sub(p)),
                        const SizedBox(height: 8),
                        Text(c.versionLabel(_version), style: UType.small(p)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRemind(BuildContext context, int minutes) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.jm(locale).format(DateTime(2000, 1, 1, minutes ~/ 60, minutes % 60));
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: UType.strong(p)),
              const SizedBox(height: 2),
              Text(subtitle, style: UType.muted(p)),
            ],
          ),
        ),
        Switch(value: value, activeTrackColor: p.accent, onChanged: onChanged),
      ],
    );
  }
}
