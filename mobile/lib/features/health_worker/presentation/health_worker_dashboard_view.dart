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
import '../../../core/localization/ner_localization_config.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/state_widgets.dart';
import '../../auth_profile/domain/user_model.dart';
import '../application/health_worker_provider.dart';
import '../domain/health_worker_model.dart';
import 'patient_clinical_detail_view.dart';
import 'health_worker_auth_view.dart';

class HealthWorkerDashboardView extends ConsumerStatefulWidget {
  const HealthWorkerDashboardView({Key? key}) : super(key: key);

  @override
  ConsumerState<HealthWorkerDashboardView> createState() => _HealthWorkerDashboardViewState();
}

class _HealthWorkerDashboardViewState extends ConsumerState<HealthWorkerDashboardView> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthWorkerPatientsProvider.notifier).loadPatients();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showEditProfileDialog(HealthWorkerProfile profile) {
    final nameCtrl = TextEditingController(text: profile.name);
    final desigCtrl = TextEditingController(text: profile.designation);
    final facCtrl = TextEditingController(text: profile.facilityName);
    final workerIdCtrl = TextEditingController(text: profile.workerId);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Health Worker Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Healthcare Professional Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: desigCtrl,
                decoration: const InputDecoration(labelText: 'Designation / Role', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: facCtrl,
                decoration: const InputDecoration(labelText: 'Health Facility / Centre', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: workerIdCtrl,
                decoration: const InputDecoration(labelText: 'Worker ID / Authorization ID', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.deepSageGreen),
            onPressed: () async {
              final updated = HealthWorkerProfile(
                id: profile.id,
                workerId: workerIdCtrl.text.trim().isEmpty ? profile.workerId : workerIdCtrl.text.trim(),
                name: nameCtrl.text.trim().isEmpty ? profile.name : nameCtrl.text.trim(),
                designation: desigCtrl.text.trim().isEmpty ? profile.designation : desigCtrl.text.trim(),
                facilityName: facCtrl.text.trim().isEmpty ? profile.facilityName : facCtrl.text.trim(),
                state: profile.state,
                phone: profile.phone,
                email: profile.email,
                registeredAt: profile.registeredAt,
              );
              await ref.read(healthWorkerAuthProvider.notifier).updateProfile(updated);
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text('Save Profile', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(healthWorkerAuthProvider);
    final patientsState = ref.watch(healthWorkerPatientsProvider);
    final worker = authState.profile ?? HealthWorkerProfile.defaultWorker();
    final filteredPatients = patientsState.filteredPatients;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Healthcare Worker Space • স্বাস্থ্যকর্মী",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              "${worker.name} • ${worker.facilityName}",
              style: const TextStyle(fontSize: 12, color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: AppColors.deepSageGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.badge_outlined),
            tooltip: 'Worker Profile',
            onPressed: () => _showEditProfileDialog(worker),
          ),
          IconButton(
            icon: const Icon(Icons.lock_reset),
            tooltip: 'Change PIN',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HealthWorkerAuthView(isResetMode: true)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Patients',
            onPressed: () => ref.read(healthWorkerPatientsProvider.notifier).loadPatients(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Clinical Surveillance Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: const Color(0xFFE8F4F8),
              child: Row(
                children: [
                  const Icon(Icons.health_and_safety, color: Color(0xFF1D3557), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "NER Cognitive Surveillance & Patient Monitoring",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D3557),
                          ),
                        ),
                        Text(
                          "Authorized for Community Health Officers, ASHA & Clinical Caregivers in NER",
                          style: TextStyle(
                            fontSize: 11,
                            color: const Color(0xFF1D3557).withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Search & Filter Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (val) => ref.read(healthWorkerPatientsProvider.notifier).setSearchQuery(val),
                decoration: InputDecoration(
                  hintText: 'Search patients by name or ID...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.deepSageGreen),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchCtrl.clear();
                            ref.read(healthWorkerPatientsProvider.notifier).setSearchQuery('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.paleParchment),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.paleParchment),
                  ),
                ),
              ),
            ),

            // 3. 8-State Filter Chips
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildStateFilterChip('All', 'All States (${patientsState.allPatients.length})', patientsState.stateFilter == 'All'),
                  ...NerLocalizationConfig.allStates.map((st) {
                    final isSelected = patientsState.stateFilter == st.name;
                    return _buildStateFilterChip(st.name, "${st.icon} ${st.name}", isSelected);
                  }),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 4. Patients List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Authorized Patients (${filteredPatients.length})",
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textCharcoal,
                    ),
                  ),
                  Text(
                    "Offline SQLite Grounded",
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 12,
                      color: const Color(0xFF2A9D8F),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 5. Patient Cards List
            Expanded(
              child: patientsState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredPatients.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: AppEmptyState(
                              message: _searchCtrl.text.isNotEmpty
                                  ? 'No registered patients found matching "${_searchCtrl.text}".'
                                  : 'No patients found for selected filter.',
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: filteredPatients.length,
                          itemBuilder: (context, index) {
                            final patient = filteredPatients[index];
                            return _buildPatientMonitoringCard(context, patient);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateFilterChip(String stateValue, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : AppColors.textCharcoal,
        ),
        backgroundColor: Colors.white,
        selectedColor: AppColors.deepSageGreen,
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.deepSageGreen : AppColors.paleParchment,
          ),
        ),
        onSelected: (_) => ref.read(healthWorkerPatientsProvider.notifier).setStateFilter(stateValue),
      ),
    );
  }

  Widget _buildPatientMonitoringCard(BuildContext context, UserModel patient) {
    return Consumer(
      builder: (context, ref, child) {
        final detailAsync = ref.watch(patientClinicalDetailProvider(patient.id));

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.white,
            borderColor: AppColors.paleParchment,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.softSageGreen.withValues(alpha: 0.4),
                      child: Text(
                        patient.name.isNotEmpty ? patient.name[0].toUpperCase() : 'P',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: AppColors.deepSageGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient.name,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textCharcoal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.paleParchment.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  "ID: ${patient.id}",
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F4F8),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  "${patient.state} • ${patient.nativeLanguage.toUpperCase()}",
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D3557)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFFEEBA)),
                      ),
                      child: Text(
                        patient.dementiaStage,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF856404),
                        ),
                      ),
                    ),
                  ],
                ),

                const Divider(height: 24, thickness: 1, color: AppColors.paleParchment),

                // Metrics Snippet from Single Source of Truth
                detailAsync.when(
                  data: (summary) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMetricItem(
                              label: "Total Activities",
                              value: "${summary.totalSessions}",
                              icon: Icons.games_outlined,
                              color: AppColors.deepSageGreen,
                            ),
                            _buildMetricItem(
                              label: "Avg Accuracy",
                              value: summary.totalSessions > 0 ? "${summary.avgAccuracy.toStringAsFixed(0)}%" : "—",
                              icon: Icons.track_changes,
                              color: summary.avgAccuracy >= 75 ? const Color(0xFF2A9D8F) : const Color(0xFFE76F51),
                            ),
                            _buildMetricItem(
                              label: "Adherence",
                              value: "${summary.adherence.adherenceRate.toStringAsFixed(0)}%",
                              icon: Icons.alarm_on,
                              color: summary.adherence.adherenceRate >= 80 ? const Color(0xFF2A9D8F) : const Color(0xFFE76F51),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (summary.observations.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: summary.observations.first.severity == ObservationSeverity.positive
                                  ? const Color(0xFFE8F8F5)
                                  : summary.observations.first.severity == ObservationSeverity.attention
                                      ? const Color(0xFFFDF2E9)
                                      : const Color(0xFFEBF5FB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  summary.observations.first.severity == ObservationSeverity.positive
                                      ? Icons.check_circle_outline
                                      : summary.observations.first.severity == ObservationSeverity.attention
                                          ? Icons.info_outline
                                          : Icons.lightbulb_outline,
                                  size: 16,
                                  color: summary.observations.first.severity == ObservationSeverity.positive
                                      ? const Color(0xFF2A9D8F)
                                      : summary.observations.first.severity == ObservationSeverity.attention
                                          ? const Color(0xFFE76F51)
                                          : const Color(0xFF2980B9),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    summary.observations.first.title,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: summary.observations.first.severity == ObservationSeverity.positive
                                          ? const Color(0xFF2A9D8F)
                                          : summary.observations.first.severity == ObservationSeverity.attention
                                              ? const Color(0xFFE76F51)
                                              : const Color(0xFF2980B9),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    );
                  },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                ),
                error: (_, __) => const Text("Error loading telemetry", style: TextStyle(fontSize: 11, color: Colors.grey)),
              ),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.deepSageGreen,
                    side: const BorderSide(color: AppColors.deepSageGreen),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.analytics_outlined, size: 18),
                  label: const Text(
                    "Inspect Longitudinal Telemetry →",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PatientClinicalDetailView(patientId: patient.id),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Widget _buildMetricItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
