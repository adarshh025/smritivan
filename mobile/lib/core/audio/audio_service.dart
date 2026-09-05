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

import '../../features/auth_profile/presentation/user_provider.dart';

class AudioService {
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();

  final bool soundEffectsEnabled;
  final bool voiceGuidanceEnabled;
  final String nativeLanguage;

  bool _isTtsInitialized = false;

  AudioService({
    required this.soundEffectsEnabled,
    required this.voiceGuidanceEnabled,
    required this.nativeLanguage,
  }) {
    _initTts();
  }

  Future<void> _initTts() async {
    // Map internal language codes to TTS locales
    String ttsLang = "en-US";
    switch (nativeLanguage) {
      case 'hi': ttsLang = "hi-IN"; break;
      // Other regional languages might fallback to 'en-US' or generic 'hi-IN' if unsupported by native TTS
      // For MVP we just use the platform's default or English.
      default: ttsLang = "en-US"; break;
    }
    
    await _tts.setLanguage(ttsLang);
    await _tts.setSpeechRate(0.4); // Slower for elderly comprehension
    await _tts.setPitch(1.0);
    _isTtsInitialized = true;
  }

  /// Check if asset exists in the bundle
  Future<bool> _assetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Speaks the given text using TTS
  Future<void> speakInstruction(String text) async {
    if (!voiceGuidanceEnabled) return;
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
        // audioplayers expects path relative to 'assets/'
        String cleanPath = assetPath.replaceAll('assets/', '');
        await _sfxPlayer.play(AssetSource(cleanPath));
      } else {
        developer.log("Audio asset missing: $assetPath. Falling back to TTS.");
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
      // Try playing a success sound if we had one
      // Since we don't have a reliable success.mp3, fallback to TTS
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
    nativeLanguage: user?.nativeLanguage ?? 'en',
  );
  
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});
