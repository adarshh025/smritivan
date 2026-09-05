// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get welcomeTitle =>
      'স্মৃতি, দৈনন্দিন রুটিন এবং আনন্দময় ক্রিয়াকলাপের জন্য একটি সহজ স্থান।';

  @override
  String get startBtn => 'শুরু করুন';

  @override
  String get caregiverSetupBtn => 'কেয়ারগিভার সেটআপ';

  @override
  String get languageQuestion => 'আপনার ভাষা নির্বাচন করুন';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिंदी';

  @override
  String get assamese => 'অসমীয়া';

  @override
  String get bengali => 'বাংলা';

  @override
  String get regionQuestion => 'আপনি কোথা থেকে এসেছেন?';

  @override
  String goodAfternoon(String name) {
    return 'শুভ বিকাল, $name';
  }

  @override
  String get howAreYouFeeling => 'আজ আপনি কেমন বোধ করছেন?';

  @override
  String get feelingGood => 'ভালো';

  @override
  String get feelingOkay => 'মোটামুটি';

  @override
  String get feelingNotGreat => 'খুব একটা ভালো না';

  @override
  String get wellbeingSaved => 'ওয়েল-বিয়িং চেক-ইন সংরক্ষণ করা হয়েছে!';

  @override
  String get cognitiveGames => '🧠 কগনিটিভ গেমস';

  @override
  String get cognitiveGamesDesc =>
      'আপনার স্মৃতি, মনোযোগ এবং চিন্তাভাবনা অনুশীলন করতে একটি কার্যকলাপ চয়ন করুন।';

  @override
  String get todaysReminders => '⏰ আজকের রিমাইন্ডার';

  @override
  String get noRemindersToday => 'আজ আপনার কোনো রিমাইন্ডার নেই।';

  @override
  String get viewAllReminders => 'সব রিমাইন্ডার দেখুন';

  @override
  String get activityLabel => '🧠 কার্যকলাপ';

  @override
  String get remindersLabel => '⏰ রিমাইন্ডার';

  @override
  String get wellbeingLabel => '❤️ ওয়েল-বিয়িং';

  @override
  String totalSessionsLabel(int count) {
    return 'মোট $count';
  }

  @override
  String todayCountLabel(int count) {
    return 'আজ $count';
  }

  @override
  String get play => 'খেলুন';

  @override
  String difficulty(String level) {
    return 'কাঠিন্য: $level';
  }

  @override
  String get adaptive => 'অ্যাডাপটিভ';

  @override
  String get gameMemoryMatch => 'মেমরি ম্যাচ';

  @override
  String get gameMemoryMatchDesc => 'স্মৃতি এবং মনোযোগ';

  @override
  String get gamePictureRecall => 'পিকচার রিকল';

  @override
  String get gamePictureRecallDesc => 'স্মৃতি এবং ধ্যান';

  @override
  String get gamePatternBuilder => 'প্যাটার্ন বিল্ডার';

  @override
  String get gamePatternBuilderDesc => 'যুক্তি এবং মনোযোগ';

  @override
  String get gameWordGarden => 'ওয়ার্ড গার্ডেন';

  @override
  String get gameWordGardenDesc => 'ভাষা এবং শব্দভাণ্ডার';

  @override
  String get gameCardRecall => 'কার্ড রিকল';

  @override
  String get gameCardRecallDesc => 'স্বল্পমেয়াদী স্মৃতি';

  @override
  String get gameDailyHelper => 'ডেইলি হেল্পার';

  @override
  String get gameDailyHelperDesc => 'পরিকল্পনা এবং অনুক্রম';

  @override
  String get markDone => 'সম্পূর্ণ হিসেবে চিহ্নিত করুন';

  @override
  String get done => 'সম্পূর্ণ';

  @override
  String get patientOverview => 'রোগীর ওভারভিউ';

  @override
  String get totalActivities => 'মোট কার্যকলাপ';

  @override
  String get engagementScore => 'এনগেজমেন্ট স্কোর';

  @override
  String get engagementScoreDesc =>
      'গেমপ্লে অংশগ্রহণ এবং কর্মক্ষমতা থেকে প্রাপ্ত কার্যকলাপ-ভিত্তিক স্কোর।';

  @override
  String remindersDone(int percent) {
    return '$percent% সম্পূর্ণ';
  }

  @override
  String get activityInsights => '💡 কার্যকলাপের অন্তর্দৃষ্টি';

  @override
  String get patientTimeline => 'রোগীর টাইমলাইন';

  @override
  String get noActivities => 'এখনও কোনও কার্যকলাপ রেকর্ড করা হয়নি।';

  @override
  String get manageReminders => 'রিমাইন্ডার পরিচালনা করুন';

  @override
  String get addReminder => 'রিমাইন্ডার যোগ করুন';

  @override
  String get cognitiveAnalysis => 'কগনিটিভ কার্যকলাপ বিশ্লেষণ';

  @override
  String get notEnoughData => 'এখনও পর্যাপ্ত কার্যকলাপ ডেটা নেই।';

  @override
  String get gameProgression => 'খেলার অগ্রগতি';

  @override
  String get gameHistory => 'খেলার ইতিহাস';

  @override
  String get noGameHistory => 'এখনও কোনও খেলা খেলা হয়নি।';

  @override
  String currentLevel(int level) {
    return 'বর্তমান স্তর: $level';
  }

  @override
  String highestLevel(int level) {
    return 'সর্বোচ্চ স্তর: $level';
  }

  @override
  String recentScore(int score) {
    return 'সাম্প্রতিক স্কোর: $score';
  }

  @override
  String get trendStable => 'স্থিতিশীল';

  @override
  String get trendImproving => '📈 উন্নতি হচ্ছে';

  @override
  String get trendNeedsPractice => '📉 অনুশীলনের প্রয়োজন';
}
