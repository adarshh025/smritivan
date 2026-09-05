// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_session_tracker.dart';

class CognitiveGameEngine extends ConsumerStatefulWidget {
  final String gameTitle;
  final Widget child;
  final double initialDifficulty;

  const CognitiveGameEngine({
    Key? key,
    required this.gameTitle,
    required this.child,
    required this.initialDifficulty,
  }) : super(key: key);

  @override
  ConsumerState<CognitiveGameEngine> createState() => _CognitiveGameEngineState();
}

class _CognitiveGameEngineState extends ConsumerState<CognitiveGameEngine> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameSessionProvider.notifier).startInteraction();
    });
  }

  void _finalizeAndExit() {
    final results = ref.read(gameSessionProvider.notifier).finalizeSession(widget.initialDifficulty);
    Navigator.of(context).pop(results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameTitle),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 32),
          onPressed: _finalizeAndExit,
          tooltip: "End Session",
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: widget.child,
        ),
      ),
    );
  }
}

