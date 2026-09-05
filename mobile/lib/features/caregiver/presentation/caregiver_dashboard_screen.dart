// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (স্মৃতিवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../auth_profile/presentation/user_provider.dart';
import '../../games/data/caregiver_alert_repository.dart';
import '../../games/domain/game_session_model.dart';
import '../../games/presentation/game_telemetry_provider.dart';
import '../../reminders/presentation/reminder_provider.dart';
import 'crdt_sync_provider.dart';

/// Caregiver Clinical Analytics & Offline-Sync Management Dashboard
class CaregiverDashboardScreen extends ConsumerStatefulWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  ConsumerState<CaregiverDashboardScreen> createState() => _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends ConsumerState<CaregiverDashboardScreen> {
  List<GameSessionModel> _sessionHistory = [];
  List<CaregiverAlertModel> _alerts = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final user = ref.read(activeUserProvider).value;
    final userId = user?.id ?? 'patient_ner_001';

    final sessionRepo = ref.read(gameSessionRepositoryProvider);
    final alertRepo = ref.read(caregiverAlertRepositoryProvider);

    final history = await sessionRepo.getSessionHistory(userId, limit: 15);
    final alertsList = await alertRepo.getRecentAlerts(limit: 10);
    final aggregates = await sessionRepo.getAggregateStats(userId);

    if (mounted) {
      setState(() {
        _sessionHistory = history;
        _alerts = alertsList;
        _stats = aggregates;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(activeUserProvider).value;
    final syncState = ref.watch(crdtSyncProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Clinical Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 28),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.deepSageGreen))
            : SingleChildScrollView(
                padding: AppDimensions.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Patient Header Summary
                    _buildPatientProfileCard(user),

                    const SizedBox(height: AppDimensions.spaceMD),

                    // Key Clinical Metrics Row
                    _buildAggregateMetricCards(),

                    const SizedBox(height: AppDimensions.spaceMD),

                    // MMSE / CVS Longitudinal Chart
                    _buildCognitiveTrajectoryChart(),

                    const SizedBox(height: AppDimensions.spaceMD),

                    // CRDT Offline Sync Manager Panel
                    _buildCrdtSyncCard(syncState),

                    const SizedBox(height: AppDimensions.spaceMD),

                    // Clinical Anomaly Alerts Feed
                    _buildAlertsSection(),

                    const SizedBox(height: AppDimensions.spaceMD),

                    // Fast Reminder Management Quick Action
                    _buildRemindersQuickManager(),

                    const SizedBox(height: AppDimensions.spaceLG),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPatientProfileCard(dynamic user) {
    return Container(
      padding: AppDimensions.cardPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimensions.cardBorderRadius,
        border: Border.all(color: AppColors.paleParchment, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.softSageGreen.withAlpha(80),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.medical_information_outlined, size: 34, color: AppColors.deepSageGreen),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Bhaben Bora',
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Stage: ${user?.dementiaStage ?? "Early-Stage MCI"}',
                  style: AppTypography.metricLabel.copyWith(color: AppColors.deepSageGreen, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Region: Assam / NER  •  Language: ${user?.nativeLanguage?.toUpperCase() ?? "AS"}',
                  style: AppTypography.metricLabel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAggregateMetricCards() {
    final hasSessions = _sessionHistory.isNotEmpty || (_stats['total_sessions'] as int? ?? 0) > 0;
    final avgCvs = _stats['avg_cvs'] as double? ?? (_sessionHistory.isNotEmpty ? (_sessionHistory.map((s) => s.cvsScore).reduce((a, b) => a + b) / _sessionHistory.length) : 0.0);
    final avgLatency = _stats['avg_latency'] as int? ?? (_sessionHistory.isNotEmpty ? (_sessionHistory.map((s) => s.reactionTimeMs).reduce((a, b) => a + b) ~/ _sessionHistory.length) : 0);
    final totalSessions = _stats['total_sessions'] as int? ?? _sessionHistory.length;

    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            'Avg CVS Score',
            hasSessions ? '${avgCvs.toStringAsFixed(1)}/100' : '-- / 100',
            Icons.psychology,
            AppColors.deepSageGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricTile(
            'Avg Latency',
            hasSessions ? '$avgLatency ms' : '-- ms',
            Icons.timer_outlined,
            AppColors.mutedTeal,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricTile(
            'Total Games',
            '$totalSessions',
            Icons.videogame_asset_outlined,
            AppColors.gentleAmber,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimensions.cardBorderRadius,
        border: Border.all(color: AppColors.paleParchment, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(title, style: AppTypography.metricLabel),
        ],
      ),
    );
  }

  Widget _buildCognitiveTrajectoryChart() {
    if (_sessionHistory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppDimensions.cardBorderRadius,
          border: Border.all(color: AppColors.paleParchment, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart_rounded, color: AppColors.deepSageGreen, size: 28),
                const SizedBox(width: 10),
                Text('Cognitive Vitality & MMSE Trajectory', style: AppTypography.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Text(
                  'Not enough activity data yet.\nChart will appear as the patient completes cognitive sessions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.4),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final reversedHistory = _sessionHistory.reversed.toList();
    final List<FlSpot> spots = [];
    for (int i = 0; i < reversedHistory.length; i++) {
      spots.add(FlSpot(i.toDouble(), reversedHistory[i].cvsScore));
    }

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimensions.cardBorderRadius,
        border: Border.all(color: AppColors.paleParchment, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart_rounded, color: AppColors.deepSageGreen, size: 28),
              const SizedBox(width: 10),
              Text('Cognitive Vitality & MMSE Trajectory', style: AppTypography.titleMedium),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Longitudinal CVS tracking calculated by local adaptive DDA heuristic',
            style: AppTypography.metricLabel,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 40,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.paleParchment, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (v, _) => Text('${v.toInt()}', style: AppTypography.metricLabel),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (v, _) => Text('S${v.toInt() + 1}', style: AppTypography.metricLabel),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: spots.length > 1,
                    color: AppColors.deepSageGreen,
                    barWidth: 3.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.softSageGreen.withAlpha(40),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrdtSyncCard(CrdtSyncState syncState) {
    return Container(
      padding: AppDimensions.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.softCream,
        borderRadius: AppDimensions.cardBorderRadius,
        border: Border.all(color: AppColors.mutedTeal.withAlpha(100), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sync_alt_rounded, color: AppColors.mutedTeal, size: 28),
              const SizedBox(width: 10),
              Text('CRDT Offline-First Sync Target', style: AppTypography.titleMedium),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: syncState.pendingDeltaCount > 0 ? AppColors.warmTerracotta : AppColors.successSage,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                ),
                child: Text(
                  syncState.pendingDeltaCount > 0 ? '${syncState.pendingDeltaCount} Queued' : 'Synced',
                  style: AppTypography.metricLabel.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            syncState.syncMessage ?? 'Offline SQLite engine tracking causal HLC timestamps.',
            style: AppTypography.bodyMedium,
          ),
          if (syncState.lastSyncTime != null) ...[
            const SizedBox(height: 4),
            Text('Last Cloud Flush: ${syncState.lastSyncTime}', style: AppTypography.metricLabel),
          ],
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mutedTeal,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
            ),
            icon: syncState.isSyncing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.cloud_upload_outlined, size: 24),
            label: Text(syncState.isSyncing ? 'Replicating Deltas...' : 'Sync Now with Cloud (FastAPI)'),
            onPressed: syncState.isSyncing
                ? null
                : () async {
                    await ref.read(crdtSyncProvider.notifier).syncWithCloud();
                    await _loadDashboardData();
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection() {
    return Container(
      padding: AppDimensions.cardPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimensions.cardBorderRadius,
        border: Border.all(color: AppColors.paleParchment, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined, color: AppColors.warmTerracotta, size: 28),
              const SizedBox(width: 10),
              Text('Clinical Telemetry & Anomaly Alerts', style: AppTypography.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          if (_alerts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'No clinical anomalies flagged. Patient cognitive state is stable within target parameters.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.successSage),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _alerts.length,
              separatorBuilder: (_, __) => const Divider(height: 20),
              itemBuilder: (context, idx) {
                final alert = _alerts[idx];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: alert.urgency == 'HIGH' ? AppColors.warmTerracotta.withAlpha(30) : AppColors.gentleAmber.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 20,
                        color: alert.urgency == 'HIGH' ? AppColors.warmTerracotta : AppColors.gentleAmber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.triggerReason,
                            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Urgency: ${alert.urgency}  •  ${alert.timestamp.split('T')[0]}',
                            style: AppTypography.metricLabel,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRemindersQuickManager() {
    final reminders = ref.watch(remindersListProvider).value ?? [];

    return Container(
      padding: AppDimensions.cardPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimensions.cardBorderRadius,
        border: Border.all(color: AppColors.paleParchment, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Active Caregiver Reminders', style: AppTypography.titleMedium),
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.deepSageGreen, size: 30),
                tooltip: 'Add new reminder',
                onPressed: _showAddReminderDialog,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...reminders.map((rem) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(rem.icon, color: rem.accentColor),
                title: Text(rem.time, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text('Type: ${rem.type} • Status: ${rem.status}', style: AppTypography.metricLabel),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.textMuted),
                  onPressed: () {
                    ref.read(remindersListProvider.notifier).removeReminder(rem.id);
                  },
                ),
              )),
        ],
      ),
    );
  }

  void _showAddReminderDialog() {
    String selectedType = 'medicine';
    final timeController = TextEditingController(text: '02:00 PM');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Clinical Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(labelText: 'Reminder Category'),
              items: const [
                DropdownMenuItem(value: 'medicine', child: Text('Medicine (ঔষধ)')),
                DropdownMenuItem(value: 'water', child: Text('Hydration / Water (পানী)')),
                DropdownMenuItem(value: 'walk', child: Text('Evening Walk (সন্ধিয়া খোজ)')),
              ],
              onChanged: (v) => selectedType = v ?? 'medicine',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Time (e.g. 02:00 PM)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(remindersListProvider.notifier).addReminder(
                    type: selectedType,
                    time: timeController.text.trim(),
                    assetUrl: 'assets/audio/ner_sounds/as_morning_meds.mp3',
                  );
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

