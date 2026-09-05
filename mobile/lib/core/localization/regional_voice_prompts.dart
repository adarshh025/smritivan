// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (স্মৃতিवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

/// Localized spoken prompts and UI strings across 6 NER/National languages
class RegionalVoicePrompts {
  RegionalVoicePrompts._();

  static const Map<String, Map<String, String>> _prompts = {
    'as': {
      'game1_title': 'মুগা আৰু কাপোৰ চিনাক্তকৰণ',
      'game1_subtitle': 'Visual Handloom Memory',
      'game1_instruction': 'তলৰ কাপোৰৰ মাজৰ পৰা একে ধৰণৰ জোৰাটো বাছক',
      'game2_title': 'থলুৱা ধ্বনি অনুভৱ',
      'game2_subtitle': 'Auditory Focus & Sounds',
      'game2_instruction': 'শব্দটো শুনক আৰু সঠিক বাদ্য বা ধ্বনিটো চিনাক্ত কৰক',
      'game3_title': 'দৈনন্দিন স্মৃতিৰ ক্ৰম',
      'game3_subtitle': 'Daily Routine Sequencing',
      'game3_instruction': 'চাহ বনোৱাৰ সঠিক ক্ৰমটো এটা এটাকৈ সজাওক',
      'match_found': 'বৰ ধুনীয়া! সঠিক জোৰা মিলিছে।',
      'try_again': 'চিন্তা নকৰিব, পুনৰ চেষ্টা কৰক।',
      'well_done': 'অতি উত্তম কাম কৰিলে!',
      'cvs_summary': 'জ্ঞানীয় সক্ৰিয়তা সূচক (CVS)',
      'play_again': 'আকৌ খেলক',
      'back_home': 'ঘৰলৈ উভতি যাওক',
      'tap_to_listen': 'শব্দ শুনিবলৈ স্পৰ্শ কৰক',
    },
    'mni': {
      'game1_title': 'ফিবা লোয়ননা উনবা',
      'game1_subtitle': 'Visual Handloom Memory',
      'game1_instruction': 'মখাগী ফিশিং অসিদগী চপ মান্নবা ফিগী কাংলুপ অদু খল্লু',
      'game2_title': 'লোকেল খোন্থোক খঙদোকপা',
      'game2_subtitle': 'Auditory Focus & Sounds',
      'game2_instruction': 'খোন্থোক অসি তারগা অচুম্বা পোৎসক অদু খল্লু',
      'game3_title': 'নুমিৎ খুদিংগী থবক মথং-মনাও',
      'game3_subtitle': 'Daily Routine Sequencing',
      'game3_instruction': 'চা শেম্বগী মথং-মনাও অদু চুম্না থম্মু',
      'match_found': 'য়াম্না ফরে! অচুম্বা খল্লে।',
      'try_again': 'ৱাবা ফাওগনু, অমুক হন্না হোৎনৌ।',
      'well_done': 'য়াম্না থাগৎচরি!',
      'cvs_summary': 'কোগ্নিটিভ স্কোর (CVS)',
      'play_again': 'অমুক হন্না শানসি',
      'back_home': 'য়ুমদা হনবা',
      'tap_to_listen': 'খোন্থোক তাবা',
    },
    'kha': {
      'game1_title': 'Bishar ia ki Jingthain Jain',
      'game1_subtitle': 'Visual Handloom Memory',
      'game1_instruction': 'Jied ia ka dur jain kaba iadei bad thain',
      'game2_title': 'Sngap ia ki Sur Tynrai',
      'game2_subtitle': 'Auditory Focus & Sounds',
      'game2_instruction': 'Sngap ia ka sur bad jied ia kaba dei',
      'game3_title': 'Ka Rukom Shet Sha',
      'game3_subtitle': 'Daily Routine Sequencing',
      'game3_instruction': 'Buh ryntih ia ki rukom shet sha',
      'match_found': 'Bha shibun! Ka dei kaba biang.',
      'try_again': 'Wat khuslai, pyrshang biang.',
      'well_done': 'Leh bha shibun!',
      'cvs_summary': 'Jinglah Jingmut (CVS)',
      'play_again': 'Ialeh biang',
      'back_home': 'Leit sha ïing',
      'tap_to_listen': 'Khyndiat ban sngap',
    },
    'brx': {
      'game1_title': 'दखना आगर सायखनाय',
      'game1_subtitle': 'Visual Handloom Memory',
      'game1_instruction': 'गाहायनि आगरफोरनिफ्राय रोखोमसे आगरखौ सायख',
      'game2_title': 'गावनि गारां खनासं',
      'game2_subtitle': 'Auditory Focus & Sounds',
      'game2_instruction': 'गारांखौ खनासं आरो थार दामाखौ सायख',
      'game3_title': 'सानफ्रोमबोनि साहा बानायनाय',
      'game3_subtitle': 'Daily Routine Sequencing',
      'game3_instruction': 'साहा बानायनायनि फारिखौ थारै साजाय',
      'match_found': 'जोबोर मोजां! थारै मिलिजोबबाय।',
      'try_again': 'गिखांनो नाङा, फिन नाजा।',
      'well_done': 'साबबास!',
      'cvs_summary': 'सिखों सिन्थों (CVS)',
      'play_again': 'फिन गेले',
      'back_home': 'नआव थांफिन',
      'tap_to_listen': 'खनासंनो थु',
    },
    'hi': {
      'game1_title': 'हथकरघा पैटर्न मिलान',
      'game1_subtitle': 'Visual Handloom Memory',
      'game1_instruction': 'समान हथकरघा डिज़ाइन के कार्ड का मिलान करें',
      'game2_title': 'पूर्वोत्तर की ध्वनियाँ पहचानें',
      'game2_subtitle': 'Auditory Focus & Sounds',
      'game2_instruction': 'ध्वनि ध्यान से सुनें और सही विकल्प चुनें',
      'game3_title': 'दैनिक दिनचर्या अनुक्रम',
      'game3_subtitle': 'Daily Routine Sequencing',
      'game3_instruction': 'असम की चाय बनाने के चरणों को क्रमबद्ध करें',
      'match_found': 'शाबाश! बिल्कुल सही मिलान।',
      'try_again': 'कोई बात नहीं, दोबारा प्रयास करें।',
      'well_done': 'बहुत सुंदर प्रयास!',
      'cvs_summary': 'संज्ञानात्मक जीवन शक्ति स्कोर (CVS)',
      'play_again': 'पुनः खेलें',
      'back_home': 'मुख्य पृष्ठ पर जाएँ',
      'tap_to_listen': 'सुनने के लिए स्पर्श करें',
    },
    'en': {
      'game1_title': 'NER Handloom Match',
      'game1_subtitle': 'Visual Handloom Memory',
      'game1_instruction': 'Tap and match the identical traditional handloom weave patterns',
      'game2_title': 'Sounds of the North East',
      'game2_subtitle': 'Auditory Focus & Sounds',
      'game2_instruction': 'Listen to the natural sound and tap the matching source',
      'game3_title': 'Assam Tea Routine Recall',
      'game3_subtitle': 'Daily Routine Sequencing',
      'game3_instruction': 'Tap the steps in the correct order to prepare Assam tea',
      'match_found': 'Wonderful! Perfect Match.',
      'try_again': 'Take your time, let\'s try again.',
      'well_done': 'Excellent Cognitive Session!',
      'cvs_summary': 'Cognitive Vitality Score (CVS)',
      'play_again': 'Play Again',
      'back_home': 'Return Home',
      'tap_to_listen': 'Tap to Play Sound',
    },
  };

  static String get(String langCode, String key) {
    final langMap = _prompts[langCode.toLowerCase()] ?? _prompts['as']!;
    return langMap[key] ?? _prompts['en']![key] ?? key;
  }
}

