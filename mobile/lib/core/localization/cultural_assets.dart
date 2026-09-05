// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
class CulturalAssets {
  static const Map<String, List<Map<String, String>>> visualPatterns = {
    'assam': [
      {'name': 'Muga Silk Pattern', 'image': 'assets/images/muga_silk.jpg'},
      {'name': 'Eri Silk Design', 'image': 'assets/images/eri_silk.jpg'},
      {'name': 'Majuli Mask', 'image': 'assets/images/majuli_mask.jpg'},
      {'name': 'Naga Shawl Pattern', 'image': 'assets/images/naga_shawl.jpg'}
    ],
    'general': [
      {'name': 'Muga Silk Pattern', 'image': 'assets/images/muga_silk.jpg'},
      {'name': 'Eri Silk Design', 'image': 'assets/images/eri_silk.jpg'},
      {'name': 'Majuli Mask', 'image': 'assets/images/majuli_mask.jpg'},
      {'name': 'Naga Shawl Pattern', 'image': 'assets/images/naga_shawl.jpg'}
    ]
  };

  static List<Map<String, String>> getPatternsForRegion(String region) {
    return visualPatterns[region.toLowerCase()] ?? visualPatterns['general']!;
  }
}

