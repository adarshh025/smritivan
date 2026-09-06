// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/patient_progress_chart.dart';
import '../../../shared/widgets/state_widgets.dart';
import '../application/health_worker_provider.dart';
import '../domain/health_worker_model.dart';

class PatientClinicalDetailView extends ConsumerStatefulWidget {
  final String patientId;
  const PatientClinicalDetailView({Key? key, required this.patientId}) : super(key: key);

  @override
  ConsumerState<PatientClinicalDetailView> createState() => _PatientClinicalDetailViewState();
}

class _PatientClinicalDetailViewState extends ConsumerState<PatientClinicalDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _activeChartFilter = '30d';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(patientClinicalDetailProvider(widget.patientId));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text(
          "Patient Clinical Telemetry",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.deepSageGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Telemetry',
            onPressed: () => ref.refresh(patientClinicalDetailProvider(widget.patientId)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.analytics, size: 20), text: "Cognitive Performance"),
            Tab(icon: Icon(Icons.timeline, size: 20), text: "Activity Timeline"),
            Tab(icon: Icon(Icons.alarm_on, size: 20), text: "Reminders & Adherence"),
            Tab(icon: Icon(Icons.mood, size: 20), text: "Wellbeing History"),
            Tab(icon: Icon(Icons.lightbulb_outline, size: 20), text: "Observations & Alerts"),
          ],
        ),
      ),
      body: detailAsync.when(
        data: (summary) => _buildDetailContent(summary),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: AppEmptyState(message: 'Error loading clinical telemetry: $err'),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailContent(PatientClinicalSummary summary) {
    return Column(
      children: [
        // 1. Patient Demographics & NER Context Header
        _buildPatientDemographicsHeader(summary),

        // 2. Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCognitivePerformanceTab(summary),
              _buildActivityTimelineTab(summary),
              _buildRemindersAdherenceTab(summary),
              _buildWellbeingHistoryTab(summary),
              _buildObservationsTab(summary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPatientDemographicsHeader(PatientClinicalSummary summary) {
    final p = summary.patient;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.paleParchment, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.softSageGreen.withValues(alpha: 0.4),
                child: Text(
                  p.name.isNotEmpty ? p.name[0].toUpperCase() : 'P',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.deepSageGreen),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${p.name} ${p.age != null ? '(${p.age} yrs)' : ''}",
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textCharcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "State: ${p.state} • Lang: ${p.nativeLanguage.toUpperCase()} • ID: ${p.id}",
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFEEBA)),
                ),
                child: Text(
                  p.dementiaStage,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF856404),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 1: Cognitive Performance & Progress Charts
  // ===========================================================================
  Widget _buildCognitivePerformanceTab(PatientClinicalSummary summary) {
    final playtimeMinutes = (summary.totalPlaytimeSeconds / 60).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Aggregate KPI Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: [
              _buildKpiCard("Total Sessions", "${summary.totalSessions}", Icons.videogame_asset, AppColors.deepSageGreen),
              _buildKpiCard("Average Accuracy", summary.totalSessions > 0 ? "${summary.avgAccuracy.toStringAsFixed(1)}%" : "—", Icons.track_changes, summary.avgAccuracy >= 75 ? const Color(0xFF2A9D8F) : const Color(0xFFE76F51)),
              _buildKpiCard("Average Latency", "${summary.avgLatencyMs} ms", Icons.timer_outlined, const Color(0xFF1D3557)),
              _buildKpiCard("Total Playtime", "$playtimeMinutes mins", Icons.hourglass_bottom, const Color(0xFF457B9D)),
            ],
          ),

          const SizedBox(height: 16),

          // Longitudinal Progress Chart (Real SQLite Data)
          PatientProgressChart(
            sessions: summary.allSessions,
            activeTimeFilter: _activeChartFilter,
            onFilterChanged: (filter) => setState(() => _activeChartFilter = filter),
            title: "Longitudinal Cognitive Trend",
          ),

          const SizedBox(height: 20),

          // Level Progression Matrix
          Text(
            "Level Progression Matrix (Levels 1–5)",
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textCharcoal,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Current unlocked challenge tier per cognitive domain based on verified level completions:",
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          _buildLevelProgressionMatrix(summary),

          const SizedBox(height: 20),

          // Game-by-Game Analytical Breakdown
          Text(
            "Cognitive Domain Breakdown",
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textCharcoal,
            ),
          ),
          const SizedBox(height: 10),
          ...summary.gameMetrics.map((gm) => _buildGamePerformanceCard(gm)).toList(),

          const SizedBox(height: 24),
          _buildDisclaimerBanner(),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      backgroundColor: Colors.white,
      borderColor: AppColors.paleParchment,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgressionMatrix(PatientClinicalSummary summary) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: Colors.white,
      borderColor: AppColors.paleParchment,
      child: Column(
        children: summary.gameMetrics.map((gm) {
          final maxUnlocked = gm.maxLevelUnlocked.floor();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Text(gm.icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Text(
                    gm.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (idx) {
                      final level = idx + 1;
                      final isUnlocked = level <= maxUnlocked;
                      return Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: isUnlocked ? const Color(0xFF2A9D8F) : const Color(0xFFE0E0E0),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "$level",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isUnlocked ? Colors.white : Colors.black45,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGamePerformanceCard(GamePerformanceMetric gm) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        backgroundColor: Colors.white,
        borderColor: AppColors.paleParchment,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(gm.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      gm.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textCharcoal),
                    ),
                  ],
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.softSageGreen.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "Level ${gm.maxLevelUnlocked.toStringAsFixed(0)} Unlocked",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.deepSageGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSubMetric("Sessions", "${gm.totalSessions}"),
              _buildSubMetric("Avg Accuracy", gm.totalSessions > 0 ? "${gm.avgAccuracy.toStringAsFixed(0)}%" : "—"),
              _buildSubMetric("Best Accuracy", gm.totalSessions > 0 ? "${gm.bestAccuracy.toStringAsFixed(0)}%" : "—"),
              _buildSubMetric("Latency", gm.totalSessions > 0 ? "${gm.avgLatencyMs}ms" : "—"),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildSubMetric(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textCharcoal)),
        const SizedBox(height: 1),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }

  // ===========================================================================
  // TAB 2: Activity Timeline
  // ===========================================================================
  Widget _buildActivityTimelineTab(PatientClinicalSummary summary) {
    if (summary.allSessions.isEmpty && summary.wellbeingHistory.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: AppEmptyState(message: "No activity sessions recorded for this patient yet."),
        ),
      );
    }

    // Merge sessions and wellbeing check-ins into unified timeline
    final List<Map<String, dynamic>> events = [];

    for (final s in summary.allSessions) {
      events.add({
        'type': 'game',
        'timestamp': s.timestamp,
        'title': s.gameType.replaceAll('_', ' ').toUpperCase(),
        'detail': "Level ${s.difficultyLevel.toStringAsFixed(0)} • Accuracy: ${((1.0 - s.errorRate) * 100).toStringAsFixed(0)}% • Duration: ${s.durationSeconds}s",
        'icon': Icons.videogame_asset_outlined,
        'color': AppColors.deepSageGreen,
      });
    }

    for (final w in summary.wellbeingHistory) {
      events.add({
        'type': 'wellbeing',
        'timestamp': w.timestamp,
        'title': "Wellbeing Check-in: ${w.status.toUpperCase()}",
        'detail': w.notes != null && w.notes!.isNotEmpty ? w.notes! : "Self-reported mood entry",
        'icon': Icons.mood,
        'color': w.status == 'good' ? const Color(0xFF2A9D8F) : w.status == 'low' ? const Color(0xFFE76F51) : const Color(0xFFF4A261),
      });
    }

    events.sort((a, b) => (b['timestamp'] as String).compareTo(a['timestamp'] as String));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final ev = events[index];
        final dt = DateTime.tryParse(ev['timestamp'] as String)?.toLocal() ?? DateTime.now();
        final timeStr = "${dt.day}/${dt.month} • ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            padding: const EdgeInsets.all(12),
            backgroundColor: Colors.white,
            borderColor: AppColors.paleParchment,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (ev['color'] as Color).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(ev['icon'] as IconData, size: 18, color: ev['color'] as Color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ev['title'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textCharcoal),
                          ),
                          Text(
                            timeStr,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        ev['detail'] as String,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // TAB 3: Reminders & Adherence
  // ===========================================================================
  Widget _buildRemindersAdherenceTab(PatientClinicalSummary summary) {
    final adh = summary.adherence;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Adherence Rate Card
          AppCard(
            padding: const EdgeInsets.all(20),
            backgroundColor: Colors.white,
            borderColor: AppColors.paleParchment,
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: CircularProgressIndicator(
                        value: adh.adherenceRate / 100.0,
                        strokeWidth: 8,
                        backgroundColor: const Color(0xFFE0E0E0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          adh.adherenceRate >= 80 ? const Color(0xFF2A9D8F) : const Color(0xFFE76F51),
                        ),
                      ),
                    ),
                    Text(
                      "${adh.adherenceRate.toStringAsFixed(0)}%",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textCharcoal),
                    ),
                  ],
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Overall Reminder Adherence",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textCharcoal),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${adh.completedReminders} completed of ${adh.totalReminders} scheduled daily reminders.",
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Text(
            "Adherence Guidelines for Care Coordinators",
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textCharcoal),
          ),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.all(16),
            backgroundColor: const Color(0xFFE8F4F8),
            borderColor: const Color(0xFFD0E1E8),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "• In early to moderate dementia stages, reminder adherence can fluctuate depending on daily circadian rhythm (sundowning).",
                  style: TextStyle(fontSize: 12, color: Color(0xFF1D3557)),
                ),
                SizedBox(height: 6),
                Text(
                  "• Ensure family caregivers verify physical medicine administration regardless of digital prompt completion.",
                  style: TextStyle(fontSize: 12, color: Color(0xFF1D3557)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 4: Wellbeing & Mood History
  // ===========================================================================
  Widget _buildWellbeingHistoryTab(PatientClinicalSummary summary) {
    if (summary.wellbeingHistory.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: AppEmptyState(message: "No wellbeing check-ins logged for this patient yet."),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: summary.wellbeingHistory.length,
      itemBuilder: (context, index) {
        final w = summary.wellbeingHistory[index];
        final dt = DateTime.tryParse(w.timestamp)?.toLocal() ?? DateTime.now();
        final dateStr = "${dt.day}/${dt.month}/${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";

        final emoji = w.status == 'good' ? "😊" : w.status == 'low' ? "😔" : "😐";
        final statusLabel = w.status == 'good' ? "Good / Calm" : w.status == 'low' ? "Low / Distressed" : "Okay / Neutral";

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: Colors.white,
            borderColor: AppColors.paleParchment,
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusLabel,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textCharcoal),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateStr,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      if (w.notes != null && w.notes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          w.notes!,
                          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // TAB 5: Clinical Observations & Alerts
  // ===========================================================================
  Widget _buildObservationsTab(PatientClinicalSummary summary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Rule-Based Clinical Observations",
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textCharcoal),
          ),
          const SizedBox(height: 4),
          const Text(
            "Automated, non-diagnostic observational insights derived from SQLite game telemetry and reminder logs:",
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          ...summary.observations.map((obs) => _buildObservationCard(obs)).toList(),
          const SizedBox(height: 20),
          _buildDisclaimerBanner(),
        ],
      ),
    );
  }

  Widget _buildObservationCard(ClinicalObservation obs) {
    Color cardBg;
    Color borderCol;
    Color iconCol;
    IconData iconData;

    switch (obs.severity) {
      case ObservationSeverity.positive:
        cardBg = const Color(0xFFE8F8F5);
        borderCol = const Color(0xFFA3E4D7);
        iconCol = const Color(0xFF2A9D8F);
        iconData = Icons.check_circle_outline;
        break;
      case ObservationSeverity.attention:
        cardBg = const Color(0xFFFDF2E9);
        borderCol = const Color(0xFFFAD7A0);
        iconCol = const Color(0xFFE76F51);
        iconData = Icons.warning_amber_rounded;
        break;
      case ObservationSeverity.neutral:
      default:
        cardBg = const Color(0xFFEBF5FB);
        borderCol = const Color(0xFFAED6F1);
        iconCol = const Color(0xFF2980B9);
        iconData = Icons.info_outline;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        backgroundColor: cardBg,
        borderColor: borderCol,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              Icon(iconData, size: 20, color: iconCol),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  obs.title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: iconCol),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  obs.category,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: iconCol),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            obs.message,
            style: const TextStyle(fontSize: 13, color: AppColors.textCharcoal),
          ),
          if (obs.recommendation != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb, size: 16, color: Color(0xFFD4AC0D)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Recommendation: ${obs.recommendation}",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF7D6608)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

  Widget _buildDisclaimerBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: Color(0xFFB78103), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Medical & Clinical Decision Support Notice",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFB78103)),
                ),
                SizedBox(height: 2),
                Text(
                  "SMRITIVAN provides cognitive stimulation tracking and longitudinal engagement metrics for healthcare workers and caregivers. Game scores and engagement trends are observational and DO NOT constitute an automated medical or neurological diagnosis for dementia, Alzheimer's, or clinical depression. Always consult a qualified medical professional for diagnostic assessments.",
                  style: TextStyle(fontSize: 11, color: Color(0xFF6D4C00)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
