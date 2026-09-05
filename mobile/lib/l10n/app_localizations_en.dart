// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeTitle =>
      'A simple space for memory, daily routines and joyful activities.';

  @override
  String get startBtn => 'Let\'s Begin';

  @override
  String get caregiverSetupBtn => 'Caregiver Setup';

  @override
  String get languageQuestion => 'Choose your language';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिंदी';

  @override
  String get assamese => 'অসমীয়া';

  @override
  String get bengali => 'বাংলা';

  @override
  String get regionQuestion => 'Where are you from?';

  @override
  String goodAfternoon(String name) {
    return 'Good afternoon, $name';
  }

  @override
  String get howAreYouFeeling => 'How are you feeling today?';

  @override
  String get feelingGood => 'Good';

  @override
  String get feelingOkay => 'Okay';

  @override
  String get feelingNotGreat => 'Not great';

  @override
  String get wellbeingSaved => 'Well-being check-in saved!';

  @override
  String get cognitiveGames => '🧠 Cognitive Games';

  @override
  String get cognitiveGamesDesc =>
      'Choose an activity to exercise your memory, attention and thinking.';

  @override
  String get todaysReminders => '⏰ Today\'s Reminders';

  @override
  String get noRemindersToday => 'You have no reminders today.';

  @override
  String get viewAllReminders => 'View All Reminders';

  @override
  String get activityLabel => '🧠 Activity';

  @override
  String get remindersLabel => '⏰ Reminders';

  @override
  String get wellbeingLabel => '❤️ Wellbeing';

  @override
  String totalSessionsLabel(int count) {
    return '$count total';
  }

  @override
  String todayCountLabel(int count) {
    return '$count today';
  }

  @override
  String get play => 'Play';

  @override
  String difficulty(String level) {
    return 'Difficulty: $level';
  }

  @override
  String get adaptive => 'Adaptive';

  @override
  String get gameMemoryMatch => 'Memory Match';

  @override
  String get gameMemoryMatchDesc => 'Memory & concentration';

  @override
  String get gamePictureRecall => 'Picture Recall';

  @override
  String get gamePictureRecallDesc => 'Memory & attention';

  @override
  String get gamePatternBuilder => 'Pattern Builder';

  @override
  String get gamePatternBuilderDesc => 'Reasoning & attention';

  @override
  String get gameWordGarden => 'Word Garden';

  @override
  String get gameWordGardenDesc => 'Language & vocabulary';

  @override
  String get gameCardRecall => 'Card Recall';

  @override
  String get gameCardRecallDesc => 'Short-term memory';

  @override
  String get gameDailyHelper => 'Daily Helper';

  @override
  String get gameDailyHelperDesc => 'Planning & sequencing';

  @override
  String get markDone => 'Mark Done';

  @override
  String get done => 'Done';

  @override
  String get patientOverview => 'Patient Overview';

  @override
  String get totalActivities => 'Total Activities';

  @override
  String get engagementScore => 'Engagement Score';

  @override
  String get engagementScoreDesc =>
      'Activity-based score derived from gameplay participation and performance.';

  @override
  String remindersDone(int percent) {
    return '$percent% Done';
  }

  @override
  String get activityInsights => '💡 Activity Insights';

  @override
  String get patientTimeline => 'Patient Timeline';

  @override
  String get noActivities => 'No activities recorded yet.';

  @override
  String get manageReminders => 'Manage Reminders';

  @override
  String get addReminder => 'Add Reminder';

  @override
  String get cognitiveAnalysis => 'Cognitive Activity Analysis';

  @override
  String get notEnoughData => 'Not enough activity data yet.';

  @override
  String get gameProgression => 'Game Progression';

  @override
  String get gameHistory => 'Game History';

  @override
  String get noGameHistory => 'No games played yet.';

  @override
  String currentLevel(int level) {
    return 'Current Level: $level';
  }

  @override
  String highestLevel(int level) {
    return 'Highest Level: $level';
  }

  @override
  String recentScore(int score) {
    return 'Recent Score: $score';
  }

  @override
  String get trendStable => 'Stable';

  @override
  String get trendImproving => '📈 Improving';

  @override
  String get trendNeedsPractice => '📉 Needs Practice';
}
