// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/game_progression_service.dart';
import '../../auth_profile/presentation/user_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';

class LevelSelectionView extends ConsumerStatefulWidget {
  final String gameType;
  final String gameTitle;
  final String gameIcon;
  final Color gameColor;
  final Widget Function(double level) gameBuilder;

  const LevelSelectionView({
    Key? key,
    required this.gameType,
    required this.gameTitle,
    required this.gameIcon,
    required this.gameColor,
    required this.gameBuilder,
  }) : super(key: key);

  @override
  ConsumerState<LevelSelectionView> createState() => _LevelSelectionViewState();
}

class _LevelSelectionViewState extends ConsumerState<LevelSelectionView> {
  bool _isLoading = true;
  String? _errorMessage;
  double _maxUnlocked = 1.0;
  double _recommended = 1.0;

  @override
  void initState() {
    super.initState();
    _loadProgression();
  }
  Future<void> _loadProgression() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final service = ref.read(gameProgressionProvider);
      final user = ref.read(activeUserProvider).value;
      final userId = user?.id ?? 'patient_ner_001';
      final unlocked = await service.getUnlockedLevel(userId, widget.gameType);
      final recommended = await service.getRecommendedLevel(userId, widget.gameType);

      if (mounted) {
        setState(() {
          _maxUnlocked = unlocked;
          _recommended = recommended;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Unable to start this game";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: Text(widget.gameTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: widget.gameColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _loadProgression,
                              child: const Text("Try Again"),
                            ),
                            const SizedBox(width: 16),
                            OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("Back"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Text(widget.gameIcon, style: const TextStyle(fontSize: 64)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Choose a Level",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF264653)),
                  ),
                  const SizedBox(height: 32),
                  
                  // Big prominent RECOMMENDED button for simple mode
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 32),
                    child: AppButton.primary(
                      text: "Recommended: Level ${_recommended.toInt()}",
                      icon: Icons.play_arrow,
                      onPressed: () => _launchGame(_recommended),
                    ),
                  ),

                  const Text(
                    "Advanced Selection",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  _buildLevelCard(1, "Very Easy", l10n),
                  _buildLevelCard(2, "Easy", l10n),
                  _buildLevelCard(3, "Moderate", l10n),
                  _buildLevelCard(4, "Challenging", l10n),
                  _buildLevelCard(5, "Advanced", l10n),
                ],
              ),
            ),
    );
  }

  Widget _buildLevelCard(int level, String label, AppLocalizations l10n) {
    bool isUnlocked = level <= _maxUnlocked;
    bool isCompleted = level < _maxUnlocked;
    bool isRecommended = level == _recommended.toInt();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AppCard(
        padding: EdgeInsets.zero,
        backgroundColor: isUnlocked ? Colors.white : Colors.grey[200],
        onTap: isUnlocked ? () => _launchGame(level.toDouble()) : null,
        child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Icon(
          isCompleted ? Icons.check_circle : (isUnlocked ? Icons.play_circle_fill : Icons.lock),
          color: isCompleted ? Colors.green : (isUnlocked ? widget.gameColor : Colors.grey),
          size: 32,
        ),
        title: Text(
          isCompleted 
            ? l10n.currentLevel(level).replaceAll('Current Level: ', 'Level ') + " - Completed"
            : l10n.currentLevel(level).replaceAll('Current Level: ', 'Level '),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isUnlocked ? const Color(0xFF264653) : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: isUnlocked ? Colors.black87 : Colors.grey)),
            if (isRecommended) 
              const Text("⭐ Recommended", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: isUnlocked
            ? const Icon(Icons.chevron_right, color: Colors.grey)
            : null,
      ),
    ),
  );
}

  Future<void> _launchGame(double level) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => widget.gameBuilder(level)),
    );
    if (mounted) {
      _loadProgression();
    }
  }
}
