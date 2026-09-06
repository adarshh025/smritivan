import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_as.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ne.dart';

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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('as'),
    Locale('bn'),
    Locale('en'),
    Locale('hi'),
    Locale('ne')
  ];

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'A simple space for memory, daily routines and joyful activities.'**
  String get welcomeTitle;

  /// No description provided for @startBtn.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Begin'**
  String get startBtn;

  /// No description provided for @caregiverSetupBtn.
  ///
  /// In en, this message translates to:
  /// **'Caregiver Setup'**
  String get caregiverSetupBtn;

  /// No description provided for @languageQuestion.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languageQuestion;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिंदी'**
  String get hindi;

  /// No description provided for @assamese.
  ///
  /// In en, this message translates to:
  /// **'অসমীয়া'**
  String get assamese;

  /// No description provided for @bengali.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get bengali;

  /// No description provided for @regionQuestion.
  ///
  /// In en, this message translates to:
  /// **'Where are you from?'**
  String get regionQuestion;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}'**
  String goodAfternoon(String name);

  /// No description provided for @howAreYouFeeling.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today?'**
  String get howAreYouFeeling;

  /// No description provided for @feelingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get feelingGood;

  /// No description provided for @feelingOkay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get feelingOkay;

  /// No description provided for @feelingNotGreat.
  ///
  /// In en, this message translates to:
  /// **'Not great'**
  String get feelingNotGreat;

  /// No description provided for @wellbeingSaved.
  ///
  /// In en, this message translates to:
  /// **'Well-being check-in saved!'**
  String get wellbeingSaved;

  /// No description provided for @cognitiveGames.
  ///
  /// In en, this message translates to:
  /// **'🧠 Cognitive Games'**
  String get cognitiveGames;

  /// No description provided for @cognitiveGamesDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose an activity to exercise your memory, attention and thinking.'**
  String get cognitiveGamesDesc;

  /// No description provided for @todaysReminders.
  ///
  /// In en, this message translates to:
  /// **'⏰ Today\'s Reminders'**
  String get todaysReminders;

  /// No description provided for @noRemindersToday.
  ///
  /// In en, this message translates to:
  /// **'You have no reminders today.'**
  String get noRemindersToday;

  /// No description provided for @viewAllReminders.
  ///
  /// In en, this message translates to:
  /// **'View All Reminders'**
  String get viewAllReminders;

  /// No description provided for @activityLabel.
  ///
  /// In en, this message translates to:
  /// **'🧠 Activity'**
  String get activityLabel;

  /// No description provided for @remindersLabel.
  ///
  /// In en, this message translates to:
  /// **'⏰ Reminders'**
  String get remindersLabel;

  /// No description provided for @wellbeingLabel.
  ///
  /// In en, this message translates to:
  /// **'❤️ Wellbeing'**
  String get wellbeingLabel;

  /// No description provided for @totalSessionsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String totalSessionsLabel(int count);

  /// No description provided for @todayCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} today'**
  String todayCountLabel(int count);

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty: {level}'**
  String difficulty(String level);

  /// No description provided for @adaptive.
  ///
  /// In en, this message translates to:
  /// **'Adaptive'**
  String get adaptive;

  /// No description provided for @gameMemoryMatch.
  ///
  /// In en, this message translates to:
  /// **'Memory Match'**
  String get gameMemoryMatch;

  /// No description provided for @gameMemoryMatchDesc.
  ///
  /// In en, this message translates to:
  /// **'Memory & concentration'**
  String get gameMemoryMatchDesc;

  /// No description provided for @gamePictureRecall.
  ///
  /// In en, this message translates to:
  /// **'Picture Recall'**
  String get gamePictureRecall;

  /// No description provided for @gamePictureRecallDesc.
  ///
  /// In en, this message translates to:
  /// **'Memory & attention'**
  String get gamePictureRecallDesc;

  /// No description provided for @gamePatternBuilder.
  ///
  /// In en, this message translates to:
  /// **'Pattern Builder'**
  String get gamePatternBuilder;

  /// No description provided for @gamePatternBuilderDesc.
  ///
  /// In en, this message translates to:
  /// **'Reasoning & attention'**
  String get gamePatternBuilderDesc;

  /// No description provided for @gameWordGarden.
  ///
  /// In en, this message translates to:
  /// **'Word Garden'**
  String get gameWordGarden;

  /// No description provided for @gameWordGardenDesc.
  ///
  /// In en, this message translates to:
  /// **'Language & vocabulary'**
  String get gameWordGardenDesc;

  /// No description provided for @gameCardRecall.
  ///
  /// In en, this message translates to:
  /// **'Card Recall'**
  String get gameCardRecall;

  /// No description provided for @gameCardRecallDesc.
  ///
  /// In en, this message translates to:
  /// **'Short-term memory'**
  String get gameCardRecallDesc;

  /// No description provided for @gameDailyHelper.
  ///
  /// In en, this message translates to:
  /// **'Daily Helper'**
  String get gameDailyHelper;

  /// No description provided for @gameDailyHelperDesc.
  ///
  /// In en, this message translates to:
  /// **'Planning & sequencing'**
  String get gameDailyHelperDesc;

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Mark Done'**
  String get markDone;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @patientOverview.
  ///
  /// In en, this message translates to:
  /// **'Patient Overview'**
  String get patientOverview;

  /// No description provided for @totalActivities.
  ///
  /// In en, this message translates to:
  /// **'Total Activities'**
  String get totalActivities;

  /// No description provided for @engagementScore.
  ///
  /// In en, this message translates to:
  /// **'Engagement Score'**
  String get engagementScore;

  /// No description provided for @engagementScoreDesc.
  ///
  /// In en, this message translates to:
  /// **'Activity-based score derived from gameplay participation and performance.'**
  String get engagementScoreDesc;

  /// No description provided for @remindersDone.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Done'**
  String remindersDone(int percent);

  /// No description provided for @activityInsights.
  ///
  /// In en, this message translates to:
  /// **'💡 Activity Insights'**
  String get activityInsights;

  /// No description provided for @patientTimeline.
  ///
  /// In en, this message translates to:
  /// **'Patient Timeline'**
  String get patientTimeline;

  /// No description provided for @noActivities.
  ///
  /// In en, this message translates to:
  /// **'No activities recorded yet.'**
  String get noActivities;

  /// No description provided for @manageReminders.
  ///
  /// In en, this message translates to:
  /// **'Manage Reminders'**
  String get manageReminders;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get addReminder;

  /// No description provided for @cognitiveAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Cognitive Activity Analysis'**
  String get cognitiveAnalysis;

  /// No description provided for @notEnoughData.
  ///
  /// In en, this message translates to:
  /// **'Not enough activity data yet.'**
  String get notEnoughData;

  /// No description provided for @gameProgression.
  ///
  /// In en, this message translates to:
  /// **'Game Progression'**
  String get gameProgression;

  /// No description provided for @gameHistory.
  ///
  /// In en, this message translates to:
  /// **'Game History'**
  String get gameHistory;

  /// No description provided for @noGameHistory.
  ///
  /// In en, this message translates to:
  /// **'No games played yet.'**
  String get noGameHistory;

  /// No description provided for @currentLevel.
  ///
  /// In en, this message translates to:
  /// **'Current Level: {level}'**
  String currentLevel(int level);

  /// No description provided for @highestLevel.
  ///
  /// In en, this message translates to:
  /// **'Highest Level: {level}'**
  String highestLevel(int level);

  /// No description provided for @recentScore.
  ///
  /// In en, this message translates to:
  /// **'Recent Score: {score}'**
  String recentScore(int score);

  /// No description provided for @trendStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get trendStable;

  /// No description provided for @trendImproving.
  ///
  /// In en, this message translates to:
  /// **'📈 Improving'**
  String get trendImproving;

  /// No description provided for @trendNeedsPractice.
  ///
  /// In en, this message translates to:
  /// **'📉 Needs Practice'**
  String get trendNeedsPractice;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['as', 'bn', 'en', 'hi', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'as':
      return AppLocalizationsAs();
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ne':
      return AppLocalizationsNe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
