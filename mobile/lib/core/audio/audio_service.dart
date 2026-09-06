// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter/services.dart' show rootBundle;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;

import '../localization/ner_localization_config.dart';
import '../../features/auth_profile/presentation/user_provider.dart';

class AudioService {
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();

  final bool soundEffectsEnabled;
  final bool voiceGuidanceEnabled;
  final String nativeLanguage;

  bool _isTtsInitialized = false;
  String _activeTtsLocale = 'en-IN';
  bool _isCurrentLocaleSupported = true;

  AudioService({
    required this.soundEffectsEnabled,
    required this.voiceGuidanceEnabled,
    required this.nativeLanguage,
  }) {
    _initTts();
  }

  String get activeTtsLocale => _activeTtsLocale;
  bool get isCurrentLocaleSupported => _isCurrentLocaleSupported;

  Future<void> _initTts() async {
    try {
      final targetLocale = NerLocalizationConfig.getTtsLocaleForLanguage(nativeLanguage);
      _activeTtsLocale = targetLocale;

      // Check if the target locale is supported on this device TTS engine
      try {
        final availability = await _tts.isLanguageAvailable(targetLocale);
        if (availability == 1 || availability == true) {
          await _tts.setLanguage(targetLocale);
          _isCurrentLocaleSupported = true;
        } else {
          // Try base language code without country tag (e.g. 'as', 'bn', 'hi', 'ne')
          final baseCode = nativeLanguage.toLowerCase();
          final baseAvailability = await _tts.isLanguageAvailable(baseCode);
          if (baseAvailability == 1 || baseAvailability == true) {
            await _tts.setLanguage(baseCode);
            _activeTtsLocale = baseCode;
            _isCurrentLocaleSupported = true;
          } else {
            // Regional language TTS voice package is not present on this device's TTS engine.
            // Rather than speaking English words masquerading as regional text, flag capability
            _isCurrentLocaleSupported = false;
            developer.log("TTS for $targetLocale not natively installed on device TTS engine.");
            // Fallback to en-IN for general English prompts if user prefers
            await _tts.setLanguage("en-IN");
          }
        }
      } catch (e) {
        developer.log("TTS capability check error: $e");
        await _tts.setLanguage("en-IN");
      }

      await _tts.setSpeechRate(0.4); // Slower speech rate for elderly comprehension
      await _tts.setPitch(1.0);
      _isTtsInitialized = true;
    } catch (e) {
      developer.log("TTS Initialization failed: $e");
    }
  }

  /// Check if an asset exists in the bundle
  Future<bool> _assetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Speaks the given text using TTS in the user's selected regional language
  Future<void> speakInstruction(String text) async {
    if (!voiceGuidanceEnabled || text.trim().isEmpty) return;
    try {
      await _tts.stop();
      if (!_isTtsInitialized) await _initTts();
      await _tts.speak(text);
    } catch (e) {
      developer.log("TTS Error: $e");
    }
  }

  /// Plays a specific audio asset, falling back to TTS text if missing.
  Future<void> playInstructionWithFallback(String assetPath, String fallbackText) async {
    if (!voiceGuidanceEnabled) return;

    try {
      await _tts.stop();
      await _sfxPlayer.stop();

      bool exists = await _assetExists(assetPath);
      if (exists) {
        String cleanPath = assetPath.replaceAll('assets/', '');
        await _sfxPlayer.play(AssetSource(cleanPath));
      } else {
        await speakInstruction(fallbackText);
      }
    } catch (e) {
      developer.log("Audio play error: $e. Falling back to TTS.");
      await speakInstruction(fallbackText);
    }
  }

  Future<void> playGentleSuccessChime() async {
    if (!soundEffectsEnabled) return;
    try {
      await _tts.stop();
      await _sfxPlayer.stop();
      await speakInstruction("Well done!");
    } catch (_) {}
  }

  Future<void> playErrorChime() async {
    if (!soundEffectsEnabled) return;
    try {
      await _tts.stop();
      await _sfxPlayer.stop();
      await speakInstruction("Try again.");
    } catch (_) {}
  }

  Future<void> playAmbient(String assetPath) async {
    if (!soundEffectsEnabled) return;
    try {
      String cleanPath = assetPath.replaceAll('assets/', '');
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.play(AssetSource(cleanPath));
    } catch (_) {}
  }

  Future<void> stopAmbient() async {
    try {
      await _bgmPlayer.stop();
    } catch (_) {}
  }

  Future<void> stopAll() async {
    try {
      await _tts.stop();
      await _sfxPlayer.stop();
      await _bgmPlayer.stop();
    } catch (_) {}
  }

  void dispose() {
    _tts.stop();
    _sfxPlayer.dispose();
    _bgmPlayer.dispose();
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final user = ref.watch(activeUserProvider).value;

  final service = AudioService(
    soundEffectsEnabled: user?.soundEffectsEnabled ?? true,
    voiceGuidanceEnabled: user?.voiceGuidanceEnabled ?? true,
    nativeLanguage: user?.nativeLanguage ?? 'as',
  );

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});
