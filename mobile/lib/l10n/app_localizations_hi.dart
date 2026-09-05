// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get welcomeTitle =>
      'स्मृति, दैनिक दिनचर्या और आनंदमय गतिविधियों के लिए एक सरल स्थान।';

  @override
  String get startBtn => 'शुरू करें';

  @override
  String get caregiverSetupBtn => 'देखभालकर्ता सेटअप';

  @override
  String get languageQuestion => 'अपनी भाषा चुनें';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिंदी';

  @override
  String get assamese => 'অসমীয়া';

  @override
  String get bengali => 'বাংলা';

  @override
  String get regionQuestion => 'आप कहाँ से हैं?';

  @override
  String goodAfternoon(String name) {
    return 'शुभ दोपहर, $name';
  }

  @override
  String get howAreYouFeeling => 'आज आप कैसा महसूस कर रहे हैं?';

  @override
  String get feelingGood => 'अच्छा';

  @override
  String get feelingOkay => 'ठीक-ठाक';

  @override
  String get feelingNotGreat => 'बहुत अच्छा नहीं';

  @override
  String get wellbeingSaved => 'कल्याण चेक-इन सहेजा गया!';

  @override
  String get cognitiveGames => '🧠 संज्ञानात्मक खेल';

  @override
  String get cognitiveGamesDesc =>
      'अपनी स्मृति, ध्यान और सोच का व्यायाम करने के लिए एक गतिविधि चुनें।';

  @override
  String get todaysReminders => '⏰ आज के रिमाइंडर';

  @override
  String get noRemindersToday => 'आज आपके पास कोई रिमाइंडर नहीं है।';

  @override
  String get viewAllReminders => 'सभी रिमाइंडर देखें';

  @override
  String get activityLabel => '🧠 गतिविधि';

  @override
  String get remindersLabel => '⏰ रिमाइंडर';

  @override
  String get wellbeingLabel => '❤️ कल्याण';

  @override
  String totalSessionsLabel(int count) {
    return '$count कुल';
  }

  @override
  String todayCountLabel(int count) {
    return '$count आज';
  }

  @override
  String get play => 'खेलें';

  @override
  String difficulty(String level) {
    return 'कठिनाई: $level';
  }

  @override
  String get adaptive => 'अनुकूली';

  @override
  String get gameMemoryMatch => 'स्मृति मिलान';

  @override
  String get gameMemoryMatchDesc => 'स्मृति और एकाग्रता';

  @override
  String get gamePictureRecall => 'चित्र स्मरण';

  @override
  String get gamePictureRecallDesc => 'स्मृति और ध्यान';

  @override
  String get gamePatternBuilder => 'पैटर्न निर्माता';

  @override
  String get gamePatternBuilderDesc => 'तर्क और ध्यान';

  @override
  String get gameWordGarden => 'शब्दों का बगीचा';

  @override
  String get gameWordGardenDesc => 'भाषा और शब्दावली';

  @override
  String get gameCardRecall => 'कार्ड स्मरण';

  @override
  String get gameCardRecallDesc => 'अल्पकालिक स्मृति';

  @override
  String get gameDailyHelper => 'दैनिक सहायक';

  @override
  String get gameDailyHelperDesc => 'योजना और अनुक्रमण';

  @override
  String get markDone => 'पूरा हुआ';

  @override
  String get done => 'पूर्ण';

  @override
  String get patientOverview => 'मरीज का अवलोकन';

  @override
  String get totalActivities => 'कुल गतिविधियाँ';

  @override
  String get engagementScore => 'जुड़ाव स्कोर';

  @override
  String get engagementScoreDesc =>
      'गेमप्ले भागीदारी और प्रदर्शन से प्राप्त गतिविधि-आधारित स्कोर।';

  @override
  String remindersDone(int percent) {
    return '$percent% पूर्ण';
  }

  @override
  String get activityInsights => '💡 गतिविधि अंतर्दृष्टि';

  @override
  String get patientTimeline => 'मरीज की समयरेखा';

  @override
  String get noActivities => 'अभी तक कोई गतिविधि दर्ज नहीं की गई।';

  @override
  String get manageReminders => 'रिमाइंडर प्रबंधित करें';

  @override
  String get addReminder => 'रिमाइंडर जोड़ें';

  @override
  String get cognitiveAnalysis => 'संज्ञानात्मक गतिविधि विश्लेषण';

  @override
  String get notEnoughData => 'अभी तक पर्याप्त गतिविधि डेटा नहीं है।';

  @override
  String get gameProgression => 'खेल की प्रगति';

  @override
  String get gameHistory => 'खेल का इतिहास';

  @override
  String get noGameHistory => 'अभी तक कोई खेल नहीं खेला गया।';

  @override
  String currentLevel(int level) {
    return 'वर्तमान स्तर: $level';
  }

  @override
  String highestLevel(int level) {
    return 'उच्चतम स्तर: $level';
  }

  @override
  String recentScore(int score) {
    return 'हाल का स्कोर: $score';
  }

  @override
  String get trendStable => 'स्थिर';

  @override
  String get trendImproving => '📈 सुधार हो रहा है';

  @override
  String get trendNeedsPractice => '📉 अभ्यास की आवश्यकता है';
}
