import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('ru'), Locale('uk')];

  /// No description provided for @tabMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get tabMap;

  /// No description provided for @tabQuests.
  ///
  /// In en, this message translates to:
  /// **'Quests'**
  String get tabQuests;

  /// No description provided for @tabHoard.
  ///
  /// In en, this message translates to:
  /// **'Hoard'**
  String get tabHoard;

  /// No description provided for @tabChronicle.
  ///
  /// In en, this message translates to:
  /// **'Chronicle'**
  String get tabChronicle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @sectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get sectionNotifications;

  /// No description provided for @dailyReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get dailyReminderTitle;

  /// No description provided for @dailyReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Nudge you if the streak is at risk.'**
  String get dailyReminderSubtitle;

  /// No description provided for @nearbyCachesTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby caches'**
  String get nearbyCachesTitle;

  /// No description provided for @nearbyCachesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Alert when a chest is close while walking.'**
  String get nearbyCachesSubtitle;

  /// No description provided for @sectionFog.
  ///
  /// In en, this message translates to:
  /// **'Fog'**
  String get sectionFog;

  /// No description provided for @fogDensityTitle.
  ///
  /// In en, this message translates to:
  /// **'Fog density'**
  String get fogDensityTitle;

  /// No description provided for @fogDensitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'How thick the mist feels on the map.'**
  String get fogDensitySubtitle;

  /// No description provided for @sectionUnits.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get sectionUnits;

  /// No description provided for @unitsMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get unitsMetric;

  /// No description provided for @unitsImperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get unitsImperial;

  /// No description provided for @sectionFeel.
  ///
  /// In en, this message translates to:
  /// **'Feel'**
  String get sectionFeel;

  /// No description provided for @hapticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Haptics'**
  String get hapticsTitle;

  /// No description provided for @hapticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Light taps when you open a cache.'**
  String get hapticsSubtitle;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @sectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get sectionLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @languageUkrainian.
  ///
  /// In en, this message translates to:
  /// **'Українська'**
  String get languageUkrainian;

  /// No description provided for @sectionBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get sectionBackup;

  /// No description provided for @backupBlurb.
  ///
  /// In en, this message translates to:
  /// **'Export or import your fog, journal, and treasury as JSON.'**
  String get backupBlurb;

  /// No description provided for @exportLabel.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportLabel;

  /// No description provided for @importLabel.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importLabel;

  /// No description provided for @atlasImported.
  ///
  /// In en, this message translates to:
  /// **'Atlas imported'**
  String get atlasImported;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @allowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow location'**
  String get allowLocation;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Walk through the mist'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'MapDefog turns your walks into a living map. Every street you tread clears the fog and fills your journal.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'What you will find'**
  String get onboardingTitle2;

  /// No description provided for @featureCachesTitle.
  ///
  /// In en, this message translates to:
  /// **'Caches'**
  String get featureCachesTitle;

  /// No description provided for @featureCachesBody.
  ///
  /// In en, this message translates to:
  /// **'Treasure chests hidden in the fog.'**
  String get featureCachesBody;

  /// No description provided for @featureBeaconsTitle.
  ///
  /// In en, this message translates to:
  /// **'Beacons'**
  String get featureBeaconsTitle;

  /// No description provided for @featureBeaconsBody.
  ///
  /// In en, this message translates to:
  /// **'Daily goals that lead you somewhere new.'**
  String get featureBeaconsBody;

  /// No description provided for @featureRelicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Relics'**
  String get featureRelicsTitle;

  /// No description provided for @featureRelicsBody.
  ///
  /// In en, this message translates to:
  /// **'Collect sets and earn titles.'**
  String get featureRelicsBody;

  /// No description provided for @featureStreaksTitle.
  ///
  /// In en, this message translates to:
  /// **'Streaks'**
  String get featureStreaksTitle;

  /// No description provided for @featureStreaksBody.
  ///
  /// In en, this message translates to:
  /// **'Walk most days to keep the flame alive.'**
  String get featureStreaksBody;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Ready to explore?'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'MapDefog needs your location while you walk so it can reveal the map around you. You can change this anytime in settings.'**
  String get onboardingBody3;

  /// No description provided for @setOut.
  ///
  /// In en, this message translates to:
  /// **'Set out'**
  String get setOut;

  /// No description provided for @endJourney.
  ///
  /// In en, this message translates to:
  /// **'End journey'**
  String get endJourney;

  /// No description provided for @tooFast.
  ///
  /// In en, this message translates to:
  /// **'Too fast'**
  String get tooFast;

  /// No description provided for @questsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quests'**
  String get questsTitle;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @claim.
  ///
  /// In en, this message translates to:
  /// **'Claim'**
  String get claim;

  /// No description provided for @showOnMap.
  ///
  /// In en, this message translates to:
  /// **'Show on map'**
  String get showOnMap;

  /// No description provided for @treasuryTitle.
  ///
  /// In en, this message translates to:
  /// **'Treasury'**
  String get treasuryTitle;

  /// No description provided for @relicsTab.
  ///
  /// In en, this message translates to:
  /// **'Relics'**
  String get relicsTab;

  /// No description provided for @shopTab.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shopTab;

  /// No description provided for @fogStyles.
  ///
  /// In en, this message translates to:
  /// **'Fog styles'**
  String get fogStyles;

  /// No description provided for @boosts.
  ///
  /// In en, this message translates to:
  /// **'Boosts'**
  String get boosts;

  /// No description provided for @lanternTitle.
  ///
  /// In en, this message translates to:
  /// **'Lantern'**
  String get lanternTitle;

  /// No description provided for @lanternBody.
  ///
  /// In en, this message translates to:
  /// **'Wider reveal for one hour.'**
  String get lanternBody;

  /// No description provided for @radarTitle.
  ///
  /// In en, this message translates to:
  /// **'Radar'**
  String get radarTitle;

  /// No description provided for @radarBody.
  ///
  /// In en, this message translates to:
  /// **'See nearby caches for one hour.'**
  String get radarBody;

  /// No description provided for @streakShieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak shield'**
  String get streakShieldTitle;

  /// No description provided for @streakShieldBody.
  ///
  /// In en, this message translates to:
  /// **'Protect your streak.'**
  String get streakShieldBody;

  /// No description provided for @notEnoughCoins.
  ///
  /// In en, this message translates to:
  /// **'Not enough coins'**
  String get notEnoughCoins;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @tapToUse.
  ///
  /// In en, this message translates to:
  /// **'Tap to use'**
  String get tapToUse;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @weeklyRefill.
  ///
  /// In en, this message translates to:
  /// **'Weekly caches refill every Monday.'**
  String get weeklyRefill;

  /// No description provided for @streakSafe.
  ///
  /// In en, this message translates to:
  /// **'Streak safe for today'**
  String get streakSafe;

  /// No description provided for @journalTitle.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journalTitle;

  /// No description provided for @explored.
  ///
  /// In en, this message translates to:
  /// **'EXPLORED'**
  String get explored;

  /// No description provided for @walked.
  ///
  /// In en, this message translates to:
  /// **'Walked'**
  String get walked;

  /// No description provided for @sectors.
  ///
  /// In en, this message translates to:
  /// **'Sectors'**
  String get sectors;

  /// No description provided for @caches.
  ///
  /// In en, this message translates to:
  /// **'Caches'**
  String get caches;

  /// No description provided for @beacons.
  ///
  /// In en, this message translates to:
  /// **'Beacons'**
  String get beacons;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get bestStreak;

  /// No description provided for @cells.
  ///
  /// In en, this message translates to:
  /// **'Cells'**
  String get cells;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @exploreFirstSector.
  ///
  /// In en, this message translates to:
  /// **'Explore to chart your first sector.'**
  String get exploreFirstSector;

  /// No description provided for @recentWalks.
  ///
  /// In en, this message translates to:
  /// **'Recent walks'**
  String get recentWalks;

  /// No description provided for @nextDeeds.
  ///
  /// In en, this message translates to:
  /// **'NEXT DEEDS'**
  String get nextDeeds;

  /// No description provided for @openDeedBook.
  ///
  /// In en, this message translates to:
  /// **'Open deed book'**
  String get openDeedBook;

  /// No description provided for @allTiersComplete.
  ///
  /// In en, this message translates to:
  /// **'All tiers complete'**
  String get allTiersComplete;

  /// No description provided for @unlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlocked;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @allWalksTitle.
  ///
  /// In en, this message translates to:
  /// **'All walks'**
  String get allWalksTitle;

  /// No description provided for @walks.
  ///
  /// In en, this message translates to:
  /// **'Walks'**
  String get walks;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @noWalksYet.
  ///
  /// In en, this message translates to:
  /// **'No walks yet — head out and explore.'**
  String get noWalksYet;

  /// No description provided for @walkTitle.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get walkTitle;

  /// No description provided for @walkNotFound.
  ///
  /// In en, this message translates to:
  /// **'Walk not found'**
  String get walkNotFound;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @pace.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get pace;

  /// No description provided for @chests.
  ///
  /// In en, this message translates to:
  /// **'Chests'**
  String get chests;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @nice.
  ///
  /// In en, this message translates to:
  /// **'Nice'**
  String get nice;

  /// No description provided for @cacheOpened.
  ///
  /// In en, this message translates to:
  /// **'Chest opened'**
  String get cacheOpened;

  /// No description provided for @relicNew.
  ///
  /// In en, this message translates to:
  /// **'New relic'**
  String get relicNew;

  /// No description provided for @relicDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get relicDuplicate;

  /// No description provided for @takeLoot.
  ///
  /// In en, this message translates to:
  /// **'Claim the loot'**
  String get takeLoot;

  /// No description provided for @badgeUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Deed accomplished'**
  String get badgeUnlocked;

  /// No description provided for @levelUp.
  ///
  /// In en, this message translates to:
  /// **'Level up'**
  String get levelUp;

  /// No description provided for @setComplete.
  ///
  /// In en, this message translates to:
  /// **'Set complete'**
  String get setComplete;

  /// No description provided for @unitFeet.
  ///
  /// In en, this message translates to:
  /// **'ft'**
  String get unitFeet;

  /// No description provided for @unitMiles.
  ///
  /// In en, this message translates to:
  /// **'mi'**
  String get unitMiles;

  /// No description provided for @unitMeters.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get unitMeters;

  /// No description provided for @unitKilometers.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get unitKilometers;

  /// No description provided for @unitMilesSquared.
  ///
  /// In en, this message translates to:
  /// **'mi²'**
  String get unitMilesSquared;

  /// No description provided for @unitMetersSquared.
  ///
  /// In en, this message translates to:
  /// **'m²'**
  String get unitMetersSquared;

  /// No description provided for @unitKmSquared.
  ///
  /// In en, this message translates to:
  /// **'km²'**
  String get unitKmSquared;

  /// No description provided for @unitMinutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get unitMinutes;

  /// No description provided for @unitHours.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get unitHours;

  /// No description provided for @notifyChannelNearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby finds'**
  String get notifyChannelNearby;

  /// No description provided for @notifyChannelRemind.
  ///
  /// In en, this message translates to:
  /// **'Evening nudge'**
  String get notifyChannelRemind;

  /// No description provided for @notifyChannelJourney.
  ///
  /// In en, this message translates to:
  /// **'Journey'**
  String get notifyChannelJourney;

  /// No description provided for @notifyJourneyDescription.
  ///
  /// In en, this message translates to:
  /// **'MapDefog is charting your walk'**
  String get notifyJourneyDescription;

  /// No description provided for @notifyChestNearby.
  ///
  /// In en, this message translates to:
  /// **'A chest nearby'**
  String get notifyChestNearby;

  /// No description provided for @notifyChestOpened.
  ///
  /// In en, this message translates to:
  /// **'Chest opened'**
  String get notifyChestOpened;

  /// No description provided for @notifyChestOpenedBody.
  ///
  /// In en, this message translates to:
  /// **'Something gleams in the mist'**
  String get notifyChestOpenedBody;

  /// No description provided for @notifyRemindBeaconTitle.
  ///
  /// In en, this message translates to:
  /// **'The mist waits'**
  String get notifyRemindBeaconTitle;

  /// No description provided for @notifyShrineReached.
  ///
  /// In en, this message translates to:
  /// **'Shrine reached'**
  String get notifyShrineReached;

  /// No description provided for @notifyShrineBody.
  ///
  /// In en, this message translates to:
  /// **'The beacon of the day is yours'**
  String get notifyShrineBody;

  /// No description provided for @notifyRemindBody.
  ///
  /// In en, this message translates to:
  /// **'The streak waits in the mist…'**
  String get notifyRemindBody;

  /// No description provided for @notifyCharting.
  ///
  /// In en, this message translates to:
  /// **'Charting the mist…'**
  String get notifyCharting;

  /// No description provided for @notifyStillCharting.
  ///
  /// In en, this message translates to:
  /// **'Still charting…'**
  String get notifyStillCharting;

  /// No description provided for @stopWalk.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopWalk;

  /// No description provided for @needLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'The atlas needs to know where you stand'**
  String get needLocationTitle;

  /// No description provided for @needLocationText.
  ///
  /// In en, this message translates to:
  /// **'The mist parts wherever you walk. Your path never leaves this phone.'**
  String get needLocationText;

  /// No description provided for @osmCredit.
  ///
  /// In en, this message translates to:
  /// **'© OpenStreetMap contributors'**
  String get osmCredit;

  /// No description provided for @followMe.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get followMe;

  /// No description provided for @walkingHint.
  ///
  /// In en, this message translates to:
  /// **'The journey goes on with the screen off'**
  String get walkingHint;

  /// No description provided for @rerollTitle.
  ///
  /// In en, this message translates to:
  /// **'Reroll the shrine'**
  String get rerollTitle;

  /// No description provided for @rerollBody.
  ///
  /// In en, this message translates to:
  /// **'Place today\'s shrine somewhere new. Once per day, if you have not reached it.'**
  String get rerollBody;

  /// No description provided for @rerollDone.
  ///
  /// In en, this message translates to:
  /// **'Already rerolled today'**
  String get rerollDone;

  /// No description provided for @importConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Import atlas?'**
  String get importConfirmTitle;

  /// No description provided for @importConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This merges the backup into your current atlas. Continue?'**
  String get importConfirmBody;

  /// No description provided for @importConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importConfirmAction;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'MapDefog reveals your city as you walk. Map data © OpenStreetMap contributors.'**
  String get aboutBody;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(Object error);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailed(Object error);

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @remindAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Remind at {time}'**
  String remindAtLabel(String time);

  /// No description provided for @shrineLabel.
  ///
  /// In en, this message translates to:
  /// **'Shrine {arrow}'**
  String shrineLabel(String arrow);

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{days} day streak'**
  String dayStreak(int days);

  /// No description provided for @xpLabel.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String xpLabel(int xp);

  /// No description provided for @buyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Buy {name}?'**
  String buyConfirm(String name);

  /// No description provided for @foundTimes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Found {count} time} other{Found {count} times}}'**
  String foundTimes(int count);

  /// No description provided for @buyCost.
  ///
  /// In en, this message translates to:
  /// **'{price, plural, one{Cost {price} coin. You have {coins}.} other{Cost {price} coins. You have {coins}.}}'**
  String buyCost(int price, int coins);

  /// No description provided for @completeFor.
  ///
  /// In en, this message translates to:
  /// **'{coins, plural, one{Complete for {coins} coin} other{Complete for {coins} coins}}'**
  String completeFor(int coins);

  /// No description provided for @relicsCount.
  ///
  /// In en, this message translates to:
  /// **'{have} of {total} relics'**
  String relicsCount(int have, int total);

  /// No description provided for @shieldCount.
  ///
  /// In en, this message translates to:
  /// **'{have}/{max}'**
  String shieldCount(int have, int max);

  /// No description provided for @resetsIn.
  ///
  /// In en, this message translates to:
  /// **'Resets in {hours} h {minutes} min'**
  String resetsIn(int hours, int minutes);

  /// No description provided for @exploreToSave.
  ///
  /// In en, this message translates to:
  /// **'{cells, plural, one{Explore {cells} cell to save today} other{Explore {cells} cells to save today}}'**
  String exploreToSave(int cells);

  /// No description provided for @shieldsBest.
  ///
  /// In en, this message translates to:
  /// **'{shields, plural, one{{shields} shield · Best {best}} other{{shields} shields · Best {best}}}'**
  String shieldsBest(int shields, int best);

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, one{{days} day left} other{{days} days left}}'**
  String daysLeft(int days);

  /// No description provided for @percentOfEarth.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of Earth'**
  String percentOfEarth(String percent);

  /// No description provided for @activeDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} active day} other{{count} active days}}'**
  String activeDays(int count);

  /// No description provided for @badgesCount.
  ///
  /// In en, this message translates to:
  /// **'Badges {done}/{total}'**
  String badgesCount(int done, int total);

  /// No description provided for @allWalksCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{All walks ({count})} other{All {count} walks}}'**
  String allWalksCount(int count);

  /// No description provided for @deedsTitle.
  ///
  /// In en, this message translates to:
  /// **'Deeds {done}/{total}'**
  String deedsTitle(int done, int total);

  /// No description provided for @percentProgress.
  ///
  /// In en, this message translates to:
  /// **'{percent}% progress'**
  String percentProgress(int percent);

  /// No description provided for @cachesFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} cache} other{{count} caches}}'**
  String cachesFound(int count);

  /// No description provided for @cacheOf.
  ///
  /// In en, this message translates to:
  /// **'Cache of {rarity}'**
  String cacheOf(String rarity);

  /// No description provided for @plusGold.
  ///
  /// In en, this message translates to:
  /// **'+{coins} gold'**
  String plusGold(int coins);

  /// No description provided for @plusXp.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String plusXp(int xp);

  /// No description provided for @relicSetProgress.
  ///
  /// In en, this message translates to:
  /// **'{setName} · {have} / {total}'**
  String relicSetProgress(String setName, int have, int total);

  /// No description provided for @badgeMore.
  ///
  /// In en, this message translates to:
  /// **'And {more} more'**
  String badgeMore(int more);

  /// No description provided for @levelN.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelN(int level);

  /// No description provided for @levelUpText.
  ///
  /// In en, this message translates to:
  /// **'The atlas remembers every step. Take {gold} gold for the road.'**
  String levelUpText(int gold);

  /// No description provided for @setCompleteText.
  ///
  /// In en, this message translates to:
  /// **'You earn the title «{title}» and {coins} gold.'**
  String setCompleteText(String title, int coins);

  /// No description provided for @notifyAboutMeters.
  ///
  /// In en, this message translates to:
  /// **'About {meters} m away'**
  String notifyAboutMeters(int meters);

  /// No description provided for @notifyNearTitle.
  ///
  /// In en, this message translates to:
  /// **'{rarity} chest nearby'**
  String notifyNearTitle(String rarity);

  /// No description provided for @notifyOpenedTitle.
  ///
  /// In en, this message translates to:
  /// **'{rarity} chest opened'**
  String notifyOpenedTitle(String rarity);

  /// No description provided for @notifyOpenedCoins.
  ///
  /// In en, this message translates to:
  /// **'+{coins} gold for your atlas'**
  String notifyOpenedCoins(int coins);

  /// No description provided for @notifyStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'{days}-day streak at risk'**
  String notifyStreakTitle(int days);

  /// No description provided for @notifyWalkStats.
  ///
  /// In en, this message translates to:
  /// **'{cells, plural, one{{cells} cell · {distance}} other{{cells} cells · {distance}}}'**
  String notifyWalkStats(int cells, String distance);

  /// No description provided for @toastNewLand.
  ///
  /// In en, this message translates to:
  /// **'New land: {name}'**
  String toastNewLand(String name);

  /// No description provided for @toastMilestone.
  ///
  /// In en, this message translates to:
  /// **'{name} is {percent}% charted · +{coins} gold'**
  String toastMilestone(String name, int percent, int coins);

  /// No description provided for @lanternLeft.
  ///
  /// In en, this message translates to:
  /// **'Lantern {time}'**
  String lanternLeft(String time);

  /// No description provided for @radarLeft.
  ///
  /// In en, this message translates to:
  /// **'Radar {time}'**
  String radarLeft(String time);

  /// No description provided for @todayLine.
  ///
  /// In en, this message translates to:
  /// **'{cells, plural, one{Today · {cells} cell · {distance}} other{Today · {cells} cells · {distance}}}'**
  String todayLine(int cells, String distance);

  /// Chest and relic rarity, by Rarity.name.
  ///
  /// In en, this message translates to:
  /// **'{rarity, select, common{Common} rare{Rare} epic{Epic} legendary{Legendary} other{}}'**
  String rarityLabel(String rarity);

  /// Relic name by relic id. Empty for unknown ids.
  ///
  /// In en, this message translates to:
  /// **'{id, select, compass{Brass Compass} boots{Worn Boots} lantern{Tin Lantern} staff{Walking Staff} flask{Water Flask} rope{Coil of Rope} torn_map{Torn Map} sea_chart{Sea Chart} star_chart{Star Chart} city_plan{City Plan} treasure_map{Treasure Map} nowhere_map{Map of Nowhere} watch{Pocket Watch} spyglass{Spyglass} music_box{Music Box} hourglass{Hourglass} quill{Cartographer\'s Quill} snow_globe{Snow Globe} moonstone{Moonstone} amber{Amber Drop} pearl{River Pearl} fossil{Fossil Shell} geode{Geode} meteorite{Meteorite Shard} dragon_scale{Dragon Scale} phoenix_feather{Phoenix Feather} mermaid_comb{Mermaid\'s Comb} griffin_claw{Griffin Claw} unicorn_hair{Unicorn Hair} kraken_ink{Kraken Ink} comet_tail{Comet Tail} star_seed{Star Seed} sun_coin{Sun Coin} moon_key{Moon Key} aurora_ribbon{Aurora Ribbon} void_pearl{Void Pearl} other{}}'**
  String relicNameById(String id);

  /// One line of relic lore by relic id.
  ///
  /// In en, this message translates to:
  /// **'{id, select, compass{Its needle wavers toward places you have never been.} boots{Someone walked a thousand streets in these. Now it\'s your turn.} lantern{Lit once, it never quite goes out.} staff{Carved with the initials of every owner. There\'s room for yours.} flask{Always cool, however long the road.} rope{Forty feet of good hemp and a knot no one can untie.} torn_map{Half a city. The other half is out there somewhere.} sea_chart{Coastlines drawn by a sailor who never saw them.} star_chart{Constellations that only appear above unexplored streets.} city_plan{Every alley marked, every name misspelled.} treasure_map{The X keeps moving. Probably on purpose.} nowhere_map{Blank paper that slowly fills as you walk.} watch{Runs fast when you rest and slow when you wander.} spyglass{Look through it and the fog thins a little.} music_box{Plays a tune from the street where it was found.} hourglass{The sand falls upward on long walks.} quill{It draws the roads before you reach them.} snow_globe{A tiny town inside. The lights are on.} moonstone{Glows faintly when the moon is up and you are out.} amber{A tiny map is trapped inside, older than any city.} pearl{Found where a river once ran under the street.} fossil{This was the seabed. Now it\'s your neighbourhood.} geode{Plain outside, a whole cave of crystals within.} meteorite{Fell from the sky to be found by a walker.} dragon_scale{Warm to the touch. Don\'t ask where the dragon is.} phoenix_feather{Burns without heat and never turns to ash.} mermaid_comb{Smells of salt, though the sea is far away.} griffin_claw{Points north, as all good griffins do.} unicorn_hair{A single silver strand that hums in the wind.} kraken_ink{Write a street\'s name in it and you\'ll never forget the way.} comet_tail{A wisp of light caught on the way past Earth.} star_seed{Plant it in the dark and something will grow.} sun_coin{Minted at noon on the longest day of the year.} moon_key{Opens a door that only exists after midnight.} aurora_ribbon{Green and violet, it moves on its own.} void_pearl{Holds the dark between the stars. The rarest thing a walker finds.} other{}}'**
  String relicLoreById(String id);

  /// Relic set name by set id.
  ///
  /// In en, this message translates to:
  /// **'{set, select, wayfarer{Wayfarer\'s Pack} maps{Maps of Old} curios{Wizard\'s Curios} stones{Gems of the Deep} myths{Beasts of Legend} stars{Gifts of the Heavens} other{Gifts of the Heavens}}'**
  String relicSetName(String set);

  /// Title earned by completing a relic set.
  ///
  /// In en, this message translates to:
  /// **'{set, select, wayfarer{Seasoned Wayfarer} maps{Keeper of Maps} curios{Apprentice of Wonders} stones{Delver of the Deep} myths{Dragonfriend} stars{Child of the Stars} other{Child of the Stars}}'**
  String relicSetTitle(String set);

  /// Walker rank; index is "i" + rank number (i0..i7).
  ///
  /// In en, this message translates to:
  /// **'{index, select, i0{Wanderer} i1{Squire} i2{Ranger} i3{Pathfinder} i4{Cartographer} i5{Knight-Errant} i6{Lorekeeper} i7{Legend of the Realm} other{Legend of the Realm}}'**
  String rankName(String index);

  /// Deed title by badge id (group_tier). Empty for unknown ids.
  ///
  /// In en, this message translates to:
  /// **'{id, select, km_1{First Steps} km_2{Stretching the Legs} km_3{Morning Stroll} km_4{Ten-League Boots} km_5{Long Road} km_6{Half a Hundred} km_7{Centurion of the Road} km_8{Two Hundred Miles of Song} km_9{Pilgrim} km_10{Five Hundred Leagues} km_11{Tireless} km_12{The Thousand} km_13{Wanderer of Ages} km_14{Two Thousand Roads} km_15{Crosser of Kingdoms} km_16{Walker Between Worlds} area_1{A Clearing} area_2{Patch of Light} area_3{The Village Green} area_4{Quarter Charted} area_5{Half a League} area_6{The Square League} area_7{Two Leagues of Land} area_8{Barony} area_9{County} area_10{Duchy} area_11{March} area_12{Principality} area_13{Kingdom} area_14{Empire} cells_1{Hundred Steps} cells_2{Five Hundred Stones} cells_3{Thousand Tiles} cells_4{Mapmaker\'s Apprentice} cells_5{Mapmaker\'s Journeyman} cells_6{Ten Thousand Squares} cells_7{Master of the Grid} cells_8{Half a Myriad More} cells_9{One Hundred Thousand} cells_10{Weaver of the World} cache_1{Lucky Find} cache_2{Treasure Hunter} cache_3{Pocketful of Loot} cache_4{Chest Cracker} cache_5{Hoarder} cache_6{Hundred Locks} cache_7{Vault Breaker} cache_8{Dragon\'s Envy} cache_9{Lord of Plunder} cache_10{Hoard of Legend} rare_1{Glimmer of Blue} rare_2{Collector of Rarities} rare_3{Rare Breed} rare_4{Hundred Wonders} epic_1{Touched by Magic} epic_2{Spellbound} epic_3{Arcane Hoard} legend_1{Legendary Luck} legend_2{Fortune\'s Favourite} legend_3{Chosen by Fate} relic_1{Curiosity Shelf} relic_2{Cabinet of Wonders} relic_3{Museum Wing} relic_4{Hall of Relics} relic_5{Royal Collection} relic_6{Keeper of Treasures} relic_7{Every Last Relic} set_1{Complete Set} set_2{Pair of Sets} set_3{Three Sets Whole} set_4{Four Sets Whole} set_5{Five Sets Whole} set_6{All Six Sets} sector_1{Beyond the Gate} sector_2{Three Lands} sector_3{Five Lands} sector_4{Ten Lands} sector_5{Twenty Lands} sector_6{Thirty Lands} sector_7{Fifty Lands} sector_8{Seventy-Five Lands} sector_9{Hundred Lands} sector_10{Two Hundred Lands} charted_1{Charted Land} charted_2{Three Charted} charted_3{Five Charted} charted_4{Ten Charted} charted_5{Twenty-Five Charted} half_1{Lord of a Land} half_2{Lord of Three} half_3{Lord of Ten} streak_1{Kindled} streak_2{A Week of Roads} streak_3{Fortnight Faithful} streak_4{Moon\'s Turn} streak_5{Two Moons} streak_6{Hundred Dawns} streak_7{Unbroken} streak_8{A Year and a Day} beacon_1{First Shrine} beacon_2{Pilgrim\'s Path} beacon_3{Ten Shrines} beacon_4{Shrine Seeker} beacon_5{Keeper of Flames} beacon_6{Hundred Altars} beacon_7{High Priest of Paths} quest_1{First Quest} quest_2{Errand Runner} quest_3{Adventurer} quest_4{Questing Knight} quest_5{Hero of the Realm} quest_6{Saga} quest_7{Epic Cycle} weekly_1{Great Quest} weekly_2{Five Great Quests} weekly_3{Ten Great Quests} weekly_4{Champion of Weeks} weekly_5{A Year of Great Quests} days_1{Seven Days Out} days_2{A Month on the Road} days_3{Two Moons Out} days_4{Hundred Days} days_5{Two Hundred Days} days_6{A Year of Roads} bigday_1{Busy Day} bigday_2{Big Day Out} bigday_3{Day of Wonders} bigday_4{Day of Legend} longday_1{Five-League Day} longday_2{Ten-Kilometre Day} longday_3{Fifteen Strong} longday_4{Twenty Strong} longday_5{Thirty Strong} longday_6{Marathon of the Realm} night_1{Night Owl} night_2{Moonwalker} night_3{Shadow of the Streets} dawn_1{Early Bird} dawn_2{Herald of Dawn} dawn_3{Sunrise Warden} level_1{Level Five} level_2{Level Ten} level_3{Level Fifteen} level_4{Level Twenty} level_5{Level Twenty-Five} level_6{Level Thirty} level_7{Level Forty} level_8{Level Fifty} walks_1{First Journey} walks_2{Ten Journeys} walks_3{Fifty Journeys} walks_4{Hundred Journeys} walks_5{Two Hundred Fifty Journeys} walks_6{Five Hundred Journeys} gold_1{Coin Purse} gold_2{Heavy Purse} gold_3{Dragon\'s Gold} style_1{Weather Witch} style_2{Mistcaller} style_3{Master of Mists} other{}}'**
  String badgeTitleById(String id);

  /// Heading for a kind of deed in the book of deeds.
  ///
  /// In en, this message translates to:
  /// **'{group, select, km{Roads walked} area{Land charted} cells{Cells revealed} cache{Chests opened} rare{Rare chests} epic{Epic chests} legend{Legendary chests} relic{Relics} set{Relic sets} sector{Lands visited} charted{Lands charted} half{Lands ruled} streak{Streaks} beacon{Shrines} quest{Quests} weekly{Great quests} days{Days on the road} bigday{Great days} longday{Long days} night{Night journeys} dawn{Dawn journeys} level{Levels} walks{Journeys} gold{Gold} style{Mists} other{Mists}}'**
  String badgeGroupName(String group);

  /// No description provided for @fogStyleName.
  ///
  /// In en, this message translates to:
  /// **'{id, select, mist{Silver Mist} parchment{Old Parchment} snow{Winter\'s Breath} midnight{Starlit Night} ember{Dragon\'s Ash} aurora{Elven Lights} other{Silver Mist}}'**
  String fogStyleName(String id);

  /// No description provided for @fogStyleText.
  ///
  /// In en, this message translates to:
  /// **'{id, select, mist{The grey mist of the borderlands} parchment{A map from a wizard\'s tower} snow{Frost over the unknown lands} midnight{Deep night and scattered stars} ember{Smouldering ash of a dragon\'s flight} aurora{Elven lights over the city} other{The grey mist of the borderlands}}'**
  String fogStyleText(String id);

  /// Evening nudge while a streak is alive; index i0..i3.
  ///
  /// In en, this message translates to:
  /// **'{index, select, i0{A short journey keeps the flame alive. Twenty-five new cells will do.} i1{The mist creeps back over today. Go and push it away.} i2{Somewhere near you is a road no one has charted yet. You, at least.} i3{Your streak waits by the door, cloak on.} other{A short journey keeps the flame alive. Twenty-five new cells will do.}}'**
  String nudgeStreak(String index);

  /// Evening nudge with no streak; index i0..i3.
  ///
  /// In en, this message translates to:
  /// **'{index, select, i0{Today\'s shrine has awakened. Shall we see where?} i1{New chests appear every Monday. Some are close.} i2{A quarter of an hour is enough to chart a corner of the realm.} i3{The mist still hides the lands around you. Let\'s change that.} other{Today\'s shrine has awakened. Shall we see where?}}'**
  String nudgeFresh(String index);

  /// Line for the map's empty fog; index i0..i6.
  ///
  /// In en, this message translates to:
  /// **'{index, select, i0{Every road you walk stays on the map.} i1{The mist hides more than roads.} i2{Walk somewhere new today.} i3{Chests refill every Monday.} i4{The shrine always wakes where the mist is thickest.} i5{Turn left where you always turn right.} i6{An atlas is a chronicle written with your feet.} other{Every road you walk stays on the map.}}'**
  String mottoLine(String index);

  /// Sector adjective; form is "i" + index + gender of the noun (m, f, n or p for plural), e.g. i3f.
  ///
  /// In en, this message translates to:
  /// **'{form, select, i0m{Whispering} i1m{Silent} i2m{Golden} i3m{Hidden} i4m{Misty} i5m{Amber} i6m{Sleeping} i7m{Windy} i8m{Crooked} i9m{Lantern} i10m{Silver} i11m{Elder} i12m{Mossy} i13m{Copper} i14m{Quiet} i15m{Wandering} i16m{Velvet} i17m{Moonlit} i18m{Echoing} i19m{Forgotten} i20m{Northern} i21m{Distant} i22m{Starry} i23m{Sunlit} other{}}'**
  String sectorAdjective(String form);

  /// Sector noun; index i0..i23.
  ///
  /// In en, this message translates to:
  /// **'{index, select, i0{Hollow} i1{Grove} i2{Reach} i3{Heights} i4{Gate} i5{Market} i6{Harbour} i7{Bend} i8{Meadow} i9{Crossing} i10{Garden} i11{Ridge} i12{Keep} i13{Hills} i14{Court} i15{Steps} i16{Fields} i17{Corner} i18{Wharf} i19{Square} i20{Lanes} i21{Terrace} i22{Woods} i23{Vale} other{}}'**
  String sectorNoun(String index);

  /// Grammatical gender of sectorNoun: m, f, n or p. Picks the sectorAdjective form.
  ///
  /// In en, this message translates to:
  /// **'{index, select, other{m}}'**
  String sectorNounGender(String index);

  /// No description provided for @sectorNameFormat.
  ///
  /// In en, this message translates to:
  /// **'{adjective} {noun}'**
  String sectorNameFormat(String adjective, String noun);

  /// No description provided for @badgeKm.
  ///
  /// In en, this message translates to:
  /// **'Walk {count} km in total'**
  String badgeKm(int count);

  /// Deed text; area is a formatted km² number.
  ///
  /// In en, this message translates to:
  /// **'Chart {area} km² of the realm'**
  String badgeArea(String area);

  /// No description provided for @badgeCells.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Reveal {count} cell} other{Reveal {count} cells}}'**
  String badgeCells(int count);

  /// No description provided for @badgeCache.
  ///
  /// In en, this message translates to:
  /// **'Open {count} chests'**
  String badgeCache(int count);

  /// Deed text for the first cache deed (goal 1).
  ///
  /// In en, this message translates to:
  /// **'Open your first chest'**
  String get badgeCacheFirst;

  /// No description provided for @badgeRare.
  ///
  /// In en, this message translates to:
  /// **'Open {count} rare chests or better'**
  String badgeRare(int count);

  /// Deed text for the first rare deed (goal 1).
  ///
  /// In en, this message translates to:
  /// **'Open a rare chest'**
  String get badgeRareFirst;

  /// No description provided for @badgeEpic.
  ///
  /// In en, this message translates to:
  /// **'Open {count} epic chests or better'**
  String badgeEpic(int count);

  /// Deed text for the first epic deed (goal 1).
  ///
  /// In en, this message translates to:
  /// **'Open an epic chest'**
  String get badgeEpicFirst;

  /// No description provided for @badgeLegend.
  ///
  /// In en, this message translates to:
  /// **'Open {count} legendary chests'**
  String badgeLegend(int count);

  /// Deed text for the first legend deed (goal 1).
  ///
  /// In en, this message translates to:
  /// **'Open a legendary chest'**
  String get badgeLegendFirst;

  /// No description provided for @badgeRelic.
  ///
  /// In en, this message translates to:
  /// **'Collect {count} different relics'**
  String badgeRelic(int count);

  /// Deed text for collecting all 36 relics.
  ///
  /// In en, this message translates to:
  /// **'Collect every relic'**
  String get badgeRelicAll;

  /// No description provided for @badgeSet.
  ///
  /// In en, this message translates to:
  /// **'Complete {count} relic sets'**
  String badgeSet(int count);

  /// Deed text for the first set deed (goal 1).
  ///
  /// In en, this message translates to:
  /// **'Complete a relic set'**
  String get badgeSetFirst;

  /// No description provided for @badgeSector.
  ///
  /// In en, this message translates to:
  /// **'Set foot in {count} lands'**
  String badgeSector(int count);

  /// Deed text for the first sector deed (goal 1).
  ///
  /// In en, this message translates to:
  /// **'Set foot in a land'**
  String get badgeSectorFirst;

  /// No description provided for @badgeCharted.
  ///
  /// In en, this message translates to:
  /// **'Chart a quarter of {count} lands'**
  String badgeCharted(int count);

  /// Deed text for the first charted deed (goal 1).
  ///
  /// In en, this message translates to:
  /// **'Chart a quarter of a land'**
  String get badgeChartedFirst;

  /// No description provided for @badgeHalf.
  ///
  /// In en, this message translates to:
  /// **'Chart half of {count} lands'**
  String badgeHalf(int count);

  /// Deed text for the first half deed (goal 1).
  ///
  /// In en, this message translates to:
  /// **'Chart half of a land'**
  String get badgeHalfFirst;

  /// No description provided for @badgeStreak.
  ///
  /// In en, this message translates to:
  /// **'Journey {count} days in a row'**
  String badgeStreak(int count);

  /// No description provided for @badgeBeacon.
  ///
  /// In en, this message translates to:
  /// **'Reach {count} shrines'**
  String badgeBeacon(int count);

  /// Deed text for the first beacon deed (goal 1).
  ///
  /// In en, this message translates to:
  /// **'Reach a shrine of the day'**
  String get badgeBeaconFirst;

  /// No description provided for @badgeQuest.
  ///
  /// In en, this message translates to:
  /// **'Complete {count} quests'**
  String badgeQuest(int count);

  /// Deed text for the first quest deed (goal 1).
  ///
  /// In en, this message translates to:
  /// **'Complete a quest'**
  String get badgeQuestFirst;

  /// No description provided for @badgeWeekly.
  ///
  /// In en, this message translates to:
  /// **'Complete {count} great quests'**
  String badgeWeekly(int count);

  /// Deed text for the first weekly deed (goal 1).
  ///
  /// In en, this message translates to:
  /// **'Complete a great quest of the week'**
  String get badgeWeeklyFirst;

  /// No description provided for @badgeDays.
  ///
  /// In en, this message translates to:
  /// **'Be on the road on {count} different days'**
  String badgeDays(int count);

  /// No description provided for @badgeBigday.
  ///
  /// In en, this message translates to:
  /// **'Reveal {count} cells in one day'**
  String badgeBigday(int count);

  /// No description provided for @badgeLongday.
  ///
  /// In en, this message translates to:
  /// **'Walk {count} km in one day'**
  String badgeLongday(int count);

  /// No description provided for @badgeNight.
  ///
  /// In en, this message translates to:
  /// **'Reveal {count} cells after 22:00'**
  String badgeNight(int count);

  /// No description provided for @badgeDawn.
  ///
  /// In en, this message translates to:
  /// **'Reveal {count} cells before 7:00'**
  String badgeDawn(int count);

  /// No description provided for @badgeLevel.
  ///
  /// In en, this message translates to:
  /// **'Reach level {count}'**
  String badgeLevel(int count);

  /// No description provided for @badgeWalks.
  ///
  /// In en, this message translates to:
  /// **'Make {count} journeys'**
  String badgeWalks(int count);

  /// Deed text for the first walks deed (goal 1).
  ///
  /// In en, this message translates to:
  /// **'Finish your first journey'**
  String get badgeWalksFirst;

  /// No description provided for @badgeGold.
  ///
  /// In en, this message translates to:
  /// **'Earn {count} gold in all'**
  String badgeGold(int count);

  /// No description provided for @badgeStyle.
  ///
  /// In en, this message translates to:
  /// **'Own {count} mists'**
  String badgeStyle(int count);

  /// No description provided for @questCells.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Reveal {count} new cell} other{Reveal {count} new cells}}'**
  String questCells(int count);

  /// No description provided for @questMeters.
  ///
  /// In en, this message translates to:
  /// **'Walk {km} km'**
  String questMeters(String km);

  /// No description provided for @questCaches.
  ///
  /// In en, this message translates to:
  /// **'Open {count} chests'**
  String questCaches(int count);

  /// No description provided for @questCachesFirst.
  ///
  /// In en, this message translates to:
  /// **'Open a chest'**
  String get questCachesFirst;

  /// No description provided for @questRare.
  ///
  /// In en, this message translates to:
  /// **'Open a rare chest or better'**
  String get questRare;

  /// No description provided for @questBeacon.
  ///
  /// In en, this message translates to:
  /// **'Reach the shrine of the day'**
  String get questBeacon;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
