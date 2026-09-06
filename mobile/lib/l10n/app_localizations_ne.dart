// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get welcomeTitle =>
      'स्मृति, दैनिक दिनचर्या र आनन्दमय गतिविधिको लागि एक सरल ठाउँ।';

  @override
  String get startBtn => 'सुरु गरौँ';

  @override
  String get caregiverSetupBtn => 'हेरचाहकर्ता सेटअप';

  @override
  String get languageQuestion => 'आफ्नो भाषा छान्नुहोस्';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिंदी';

  @override
  String get assamese => 'অসমীয়া';

  @override
  String get bengali => 'বাংলা';

  @override
  String get regionQuestion => 'तपाईं कुन राज्यबाट हुनुहुन्छ?';

  @override
  String goodAfternoon(String name) {
    return 'शुभ दिउँसो, $name';
  }

  @override
  String get howAreYouFeeling => 'आज तपाईंलाई कस्तो महसुस हुँदैछ?';

  @override
  String get feelingGood => 'राम्रो';

  @override
  String get feelingOkay => 'ठिकै';

  @override
  String get feelingNotGreat => 'राम्रो छैन';

  @override
  String get wellbeingSaved => 'स्वास्थ्य स्थिति सुरक्षित गरियो!';

  @override
  String get cognitiveGames => '🧠 संज्ञानात्मक खेलहरू';

  @override
  String get cognitiveGamesDesc =>
      'आफ्नो स्मृति, ध्यान र सोचको अभ्यास गर्न गतिविधि छान्नुहोस्।';

  @override
  String get todaysReminders => '⏰ आजका सम्झौनाहरू';

  @override
  String get noRemindersToday => 'आज कुनै सम्झौना छैन।';

  @override
  String get viewAllReminders => 'सबै सम्झौनाहरू हेर्नुहोस्';

  @override
  String get activityLabel => '🧠 गतिविधि';

  @override
  String get remindersLabel => '⏰ सम्झौनाहरू';

  @override
  String get wellbeingLabel => '❤️ स्वास्थ्य';

  @override
  String totalSessionsLabel(int count) {
    return '$count जम्मा';
  }

  @override
  String todayCountLabel(int count) {
    return '$count आज';
  }

  @override
  String get play => 'खेल्नुहोस्';

  @override
  String difficulty(String level) {
    return 'कठिनाई: $level';
  }

  @override
  String get adaptive => 'अनुकूलनीय';

  @override
  String get gameMemoryMatch => 'स्मृति मिलान';

  @override
  String get gameMemoryMatchDesc => 'स्मृति र एकाग्रता';

  @override
  String get gamePictureRecall => 'तस्बिर सम्झना';

  @override
  String get gamePictureRecallDesc => 'स्मृति र ध्यान';

  @override
  String get gamePatternBuilder => 'ढाँचा निर्माण';

  @override
  String get gamePatternBuilderDesc => 'तर्क र ध्यान';

  @override
  String get gameWordGarden => 'शब्द बगैँचा';

  @override
  String get gameWordGardenDesc => 'भाषा र शब्दावली';

  @override
  String get gameCardRecall => 'कार्ड सम्झना';

  @override
  String get gameCardRecallDesc => 'अल्पकालीन स्मृति';

  @override
  String get gameDailyHelper => 'दैनिक सहयोगी';

  @override
  String get gameDailyHelperDesc => 'योजना र क्रमबद्धता';

  @override
  String get markDone => 'सम्पन्न भयो';

  @override
  String get done => 'सम्पन्न';

  @override
  String get patientOverview => 'बिरामी सिंहावलोकन';

  @override
  String get totalActivities => 'कुल गतिविधिहरू';

  @override
  String get engagementScore => 'संलग्नता स्कोर';

  @override
  String get engagementScoreDesc =>
      'खेल सहभागिता र प्रदर्शनबाट प्राप्त गतिविधि स्कोर।';

  @override
  String remindersDone(int percent) {
    return '$percent% सम्पन्न';
  }

  @override
  String get activityInsights => '💡 गतिविधि अन्तरदृष्टि';

  @override
  String get patientTimeline => 'बिरामी समयरेखा';

  @override
  String get noActivities => 'अहिलेसम्म कुनै गतिविधि रेकर्ड गरिएको छैन।';

  @override
  String get manageReminders => 'सम्झौना व्यवस्थापन';

  @override
  String get addReminder => 'सम्झौना थप्नुहोस्';

  @override
  String get cognitiveAnalysis => 'संज्ञानात्मक गतिविधि विश्लेषण';

  @override
  String get notEnoughData => 'अहिलेसम्म पर्याप्त गतिविधि डाटा छैन।';

  @override
  String get gameProgression => 'खेल प्रगति';

  @override
  String get gameHistory => 'खेल इतिहास';

  @override
  String get noGameHistory => 'अहिलेसम्म कुनै खेल खेलिएको छैन।';

  @override
  String currentLevel(int level) {
    return 'हालको स्तर: $level';
  }

  @override
  String highestLevel(int level) {
    return 'उच्चतम स्तर: $level';
  }

  @override
  String recentScore(int score) {
    return 'हालको स्कोर: $score';
  }

  @override
  String get trendStable => 'स्थिर';

  @override
  String get trendImproving => '📈 सुधारिँदै';

  @override
  String get trendNeedsPractice => '📉 थप अभ्यास चाहिन्छ';
}
