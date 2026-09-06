// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/caregiver_dashboard_provider.dart';
import '../../reminders/application/reminder_service.dart';
import '../../reminders/domain/reminder_model.dart';
import '../../auth_profile/presentation/user_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../personalization/application/personalization_provider.dart';
import '../../daily_plan/application/daily_plan_provider.dart';
import '../../daily_plan/domain/daily_plan_model.dart';
import '../application/caregiver_alert_provider.dart';
import '../domain/caregiver_alert.dart';
import 'caregiver_auth_view.dart';
import '../../health_worker/presentation/health_worker_auth_view.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/patient_progress_chart.dart';

class CaregiverDashboardView extends ConsumerStatefulWidget {
  const CaregiverDashboardView({Key? key}) : super(key: key);

  @override
  ConsumerState<CaregiverDashboardView> createState() => _CaregiverDashboardViewState();
}

class _CaregiverDashboardViewState extends ConsumerState<CaregiverDashboardView> {
  int _selectedIndex = 0;
  String _analyticsTimeFilter = '30d';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(caregiverDashboardProvider.notifier).loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(caregiverDashboardProvider);
    final personalizationState = ref.watch(personalizationStateProvider);
    final dailyPlanState = ref.watch(dailyPlanProvider);
    final alertState = ref.watch(caregiverAlertsProvider);
    final user = ref.watch(activeUserProvider).value;
    final patientName = user?.name ?? "Unknown Patient";
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: Text("👤 $patientName (Patient)", style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.medical_services_outlined),
            tooltip: "Health Worker Space",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HealthWorkerAuthView()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.lock_reset),
            tooltip: "Change PIN",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CaregiverAuthView(isResetMode: true)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(caregiverDashboardProvider.notifier).loadData(),
            tooltip: "Refresh Data",
          )
        ],
      ),
      body: SafeArea(
        child: dashboardState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Row(
                children: [
                  if (MediaQuery.of(context).size.width > 600)
                    NavigationRail(
                      backgroundColor: Colors.white,
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
                      labelType: NavigationRailLabelType.all,
                      destinations: const [
                        NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Overview')), // Assuming we don't fully translate these labels unless needed
                        NavigationRailDestination(icon: Icon(Icons.timeline), label: Text('Timeline')),
                        NavigationRailDestination(icon: Icon(Icons.alarm), label: Text('Reminders')),
                        NavigationRailDestination(icon: Icon(Icons.psychology), label: Text('Analytics')),
                      ],
                    ),
                  if (MediaQuery.of(context).size.width > 600)
                    const VerticalDivider(thickness: 1, width: 1),
                  
                  Expanded(
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: [
                        _buildOverviewTab(dashboardState, personalizationState, alertState, l10n, patientName),
                        _buildTimelineTab(dashboardState, dailyPlanState, l10n),
                        _buildRemindersTab(context, ref, dashboardState, l10n, patientName),
                        _buildAnalyticsTab(dashboardState, l10n),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      // Removed redundant global FloatingActionButton (Problem C & D)
      bottomNavigationBar: MediaQuery.of(context).size.width <= 600
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (idx) => setState(() => _selectedIndex = idx),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF264653),
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Overview'),
                BottomNavigationBarItem(icon: Icon(Icons.timeline), label: 'Timeline'),
                BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'Reminders'),
                BottomNavigationBarItem(icon: Icon(Icons.psychology), label: 'Analytics'),
              ],
            )
          : null,
    );
  }

  Widget _buildOverviewTab(CaregiverDashboardState state, PersonalizationState pState, CaregiverAlertState alertState, AppLocalizations l10n, String patientName) {
    int totalSessions = state.gameStats['total_sessions'] ?? 0;
    double avgLatency = (state.gameStats['avg_latency'] as num?)?.toDouble() ?? 0;
    
    // Calculate simple adherence
    int totalRem = state.reminders.length;
    int doneRem = state.reminders.where((r) => r.status == 'done').length;
    double adherence = totalRem == 0 ? 0 : (doneRem / totalRem);

    String latestWellbeing = state.wellbeing.isNotEmpty ? state.wellbeing.first.status : "Unknown";

    // Composite engagement score: weighted average of game sessions, reminder adherence, and recency
    // Sessions (max 50 pts) + Adherence (max 30 pts) + Wellbeing (max 20 pts)
    int sessionPts = (totalSessions * 5).clamp(0, 50);
    int adherencePts = (adherence * 30).toInt();
    int wellbeingPts = latestWellbeing == 'good' ? 20 : (latestWellbeing == 'okay' ? 12 : 5);
    int engagementScore = (sessionPts + adherencePts + wellbeingPts).clamp(0, 100);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      children: [
        Text(l10n.patientOverview, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF264653))),
        const SizedBox(height: 24),
        
        LayoutBuilder(builder: (context, constraints) {
          int cols = constraints.maxWidth > 800 ? 4 : (constraints.maxWidth > 400 ? 2 : 1);
          return GridView.count(
            crossAxisCount: cols,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: constraints.maxWidth > 800 ? 1.8 : 1.4,
            children: [
              _buildStatCard(l10n.totalActivities, "$totalSessions", Icons.games, Colors.green),
              _buildStatCard(
                l10n.engagementScore, 
                "$engagementScore / 100", 
                Icons.psychology, 
                const Color(0xFFE9C46A),
                subtitle: l10n.engagementScoreDesc
              ),
              _buildStatCard("Reminders", l10n.remindersDone((adherence * 100).toInt()), Icons.check_circle, const Color(0xFF2A9D8F)),
              _buildStatCard("Well-being", latestWellbeing.toUpperCase(), Icons.favorite, const Color(0xFFE76F51)),
            ],
          );
        }),

        const SizedBox(height: 24),
        // Quick Reminder Action Card for Caregiver
        AppCard(
          padding: const EdgeInsets.all(20),
          backgroundColor: Colors.white,
          borderColor: const Color(0xFF2A9D8F).withOpacity(0.4),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 400) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A9D8F).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.alarm_add_rounded, color: Color(0xFF2A9D8F), size: 30),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            "Set Patient Reminder",
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF264653)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Schedule medication, meals, walks, or hydration for $patientName.",
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        key: const Key('btn_overview_set_reminder'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A9D8F),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text("Set Reminder", style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () => _showAddReminderDialog(context, ref, patientName),
                      ),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A9D8F).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.alarm_add_rounded, color: Color(0xFF2A9D8F), size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Set Patient Reminder",
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF264653)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Schedule medication, meals, walks, or hydration for $patientName.",
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    key: const Key('btn_overview_set_reminder'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A9D8F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Set Reminder", style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => _showAddReminderDialog(context, ref, patientName),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 32),
        Text("🔔 Caregiver Insights", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF264653))),
        const SizedBox(height: 16),
        
        if (alertState.isLoading)
           const Center(child: CircularProgressIndicator())
        else if (alertState.alerts.isEmpty)
           const Text("No recent insights to display.")
        else
           ...alertState.alerts.map((a) => _buildAlertCard(a)).toList(),
           
        const SizedBox(height: 32),
        Text(l10n.activityInsights, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF264653))),
        const SizedBox(height: 16),
        
        if (!pState.isLoading)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2A9D8F), Color(0xFF264653)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.insights, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text("Personalized Activity Insights", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInsightRow(Icons.access_time, "Preferred Time", pState.profile.preferredActivityTime),
                const SizedBox(height: 8),
                _buildInsightRow(Icons.timer, "Typical Session", pState.profile.typicalSessionLength),
                const SizedBox(height: 8),
                _buildInsightRow(Icons.star, "Strongest Area", pState.profile.strongestActivity),
                const SizedBox(height: 8),
                _buildInsightRow(Icons.fitness_center, "Needs Practice", pState.profile.practiceArea),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.recommend, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Today's Recommendation: Level ${pState.recommendation.recommendedLevel.toInt()} ${pState.recommendation.recommendedGameType.replaceAll('_', ' ').toUpperCase()}\n${pState.recommendation.reason}",
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator())),
      ],
    );
  }

  Widget _buildInsightRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Text("$label:", style: const TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAlertCard(CaregiverAlert alert) {
    Color cardColor;
    IconData icon;
    String badgeText;

    if (alert.urgency == AlertUrgency.important) {
      cardColor = Colors.red[50]!;
      icon = Icons.warning;
      badgeText = "Important";
    } else if (alert.urgency == AlertUrgency.attention) {
      cardColor = Colors.orange[50]!;
      icon = Icons.priority_high;
      badgeText = "Attention";
    } else {
      cardColor = Colors.green[50]!;
      icon = Icons.lightbulb;
      badgeText = "Info";
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        backgroundColor: cardColor,
        borderColor: cardColor.withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.black54),
              const SizedBox(width: 8),
              Expanded(child: Text(alert.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              if (alert.occurrences > 1)
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                   decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12)),
                   child: Text("${alert.occurrences}x", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                 )
            ],
          ),
          const SizedBox(height: 8),
          Text(alert.description, style: const TextStyle(fontSize: 14)),
          if (alert.suggestedAction != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.arrow_forward, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(alert.suggestedAction!, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13))),
                ],
              ),
            )
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton.text(
              text: "Dismiss",
              onPressed: () => ref.read(caregiverAlertsProvider.notifier).dismissAlert(alert.alertId),
            ),
          )
        ],
      ),
    ),
  );
}

  Widget _buildTimelineTab(CaregiverDashboardState state, DailyPlanState planState, AppLocalizations l10n) {
    if (state.isLoading) return const Center(child: CircularProgressIndicator());

    // Build unified list of real recorded events
    final List<_TimelineEventItem> events = [];

    for (final g in state.gameHistory) {
      final dt = DateTime.tryParse(g.timestamp)?.toLocal() ?? DateTime.now();
      final name = g.gameType.replaceAll('_', ' ').split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
      events.add(_TimelineEventItem(
        dateTime: dt,
        title: "$name • Level ${g.difficultyLevel.toInt()} Completed",
        subtitle: "Score: ${g.cvsScore.round()}/100 • Latency: ${g.reactionTimeMs}ms • Duration: ${g.durationSeconds}s",
        icon: Icons.videogame_asset_rounded,
        color: const Color(0xFF2A9D8F),
        badge: "GAME",
      ));
    }

    for (final r in state.reminders) {
      final dt = DateTime.tryParse(r.createdAt)?.toLocal() ?? DateTime.now();
      final isDone = r.status == 'done';
      events.add(_TimelineEventItem(
        dateTime: dt,
        title: "Reminder: ${r.title}",
        subtitle: "Scheduled at ${r.time} • Priority: ${r.priority.toUpperCase()}",
        icon: r.icon,
        color: isDone ? Colors.green : const Color(0xFFE9C46A),
        badge: isDone ? "COMPLETED" : "PENDING",
      ));
    }

    for (final w in state.wellbeing) {
      final dt = DateTime.tryParse(w.timestamp)?.toLocal() ?? DateTime.now();
      events.add(_TimelineEventItem(
        dateTime: dt,
        title: "Well-being Check-in",
        subtitle: "Patient felt: ${w.displayStatus}${w.notes != null && w.notes!.isNotEmpty ? ' — ${w.notes}' : ''}",
        icon: Icons.favorite_rounded,
        color: const Color(0xFFE76F51),
        badge: "CHECK-IN",
      ));
    }

    // Sort newest first
    events.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      children: [
        Text(l10n.patientTimeline, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF264653))),
        const SizedBox(height: 8),
        Text(
          "Chronological log of patient cognitive games, check-ins, and reminders.",
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        if (events.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Column(
              children: [
                Icon(Icons.timeline_rounded, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  "No patient activities recorded yet.",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF264653)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6),
                Text(
                  "When the patient plays games, logs moods, or marks reminders, activities will appear here automatically.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...events.map((e) {
            final timeStr = "${e.dateTime.month}/${e.dateTime.day}\n${e.dateTime.hour.toString().padLeft(2, '0')}:${e.dateTime.minute.toString().padLeft(2, '0')}";
            return _buildTimelineItem(timeStr, "${e.title}\n${e.subtitle}", e.icon, e.color, e.badge);
          }).toList(),
      ],
    );
  }

  Widget _buildRemindersTab(BuildContext context, WidgetRef ref, CaregiverDashboardState state, AppLocalizations l10n, String patientName) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 450) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.manageReminders,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF264653)),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    key: const Key('btn_reminders_tab_add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF264653),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add_alarm_rounded, size: 20),
                    label: const Text("Set New Reminder", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    onPressed: () => _showAddReminderDialog(context, ref, patientName),
                  ),
                ],
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.manageReminders,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF264653)),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  key: const Key('btn_reminders_tab_add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF264653),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.add_alarm_rounded, size: 20),
                  label: const Text("Set Reminder", style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => _showAddReminderDialog(context, ref, patientName),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),

        if (state.reminders.isEmpty)
          AppCard(
            padding: const EdgeInsets.all(32),
            backgroundColor: Colors.white,
            borderColor: Colors.grey.shade300,
            child: Column(
              children: [
                const Icon(Icons.alarm_off_rounded, size: 54, color: Color(0xFF2A9D8F)),
                const SizedBox(height: 16),
                Text(
                  "No Reminders Scheduled",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF264653)),
                ),
                const SizedBox(height: 8),
                Text(
                  "Create medication, meal, hydration, or walk reminders for $patientName.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A9D8F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text("Set First Reminder", style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => _showAddReminderDialog(context, ref, patientName),
                ),
              ],
            ),
          ),
        ...state.reminders.map((r) {
          final isDone = r.status == 'done';
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isDone ? Colors.green.withOpacity(0.4) : Colors.grey.shade300,
                width: isDone ? 1.5 : 1.0,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: isDone,
                    activeColor: Colors.green,
                    onChanged: (_) {
                      ref.read(caregiverDashboardProvider.notifier).toggleReminder(r.id);
                    },
                  ),
                  Icon(r.icon, color: r.accentColor),
                ],
              ),
              title: Text(
                r.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  color: isDone ? Colors.grey : const Color(0xFF264653),
                ),
              ),
              subtitle: Text("${r.time} • ${r.priority.toUpperCase()} Priority"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Color(0xFF2A9D8F)),
                    tooltip: 'Edit Reminder',
                    onPressed: () => _showEditReminderDialog(context, ref, r),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    tooltip: 'Delete Reminder',
                    onPressed: () => _confirmDeleteReminder(context, ref, r.id),
                  ),
                ],
              ),
              onTap: () {
                ref.read(caregiverDashboardProvider.notifier).toggleReminder(r.id);
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  void _showAddReminderDialog(BuildContext context, WidgetRef ref, String patientName) {
    final titleController = TextEditingController();
    final timeController = TextEditingController(text: '08:00 AM');
    String selectedType = 'medication';
    String selectedPriority = 'high';
    String? titleError;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.add_alarm_rounded, color: Color(0xFF2A9D8F)),
              SizedBox(width: 10),
              Expanded(
                child: Text('Set Patient Reminder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF264653).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person, size: 16, color: Color(0xFF264653)),
                      const SizedBox(width: 6),
                      Text("For: $patientName", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF264653))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Reminder Title *',
                    hintText: 'e.g. Morning Medication, Drink Water',
                    errorText: titleError,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.title),
                  ),
                  onChanged: (_) {
                    if (titleError != null) setDialogState(() => titleError = null);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: timeController,
                        decoration: const InputDecoration(
                          labelText: 'Time *',
                          hintText: '08:00 AM',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      icon: const Icon(Icons.schedule),
                      tooltip: "Pick Time",
                      style: IconButton.styleFrom(backgroundColor: const Color(0xFF2A9D8F)),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 8, minute: 0),
                        );
                        if (picked != null) {
                          final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
                          final minute = picked.minute.toString().padLeft(2, '0');
                          final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
                          setDialogState(() {
                            timeController.text = "${hour.toString().padLeft(2, '0')}:$minute $period";
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text("Quick Presets:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ActionChip(
                        avatar: const Text("💊"),
                        label: const Text("08:00 AM Meds"),
                        onPressed: () => setDialogState(() {
                          titleController.text = "Morning Medication";
                          timeController.text = "08:00 AM";
                          selectedType = "medication";
                          selectedPriority = "high";
                        }),
                      ),
                      const SizedBox(width: 6),
                      ActionChip(
                        avatar: const Text("💧"),
                        label: const Text("11:00 AM Water"),
                        onPressed: () => setDialogState(() {
                          titleController.text = "Drink Water";
                          timeController.text = "11:00 AM";
                          selectedType = "water";
                          selectedPriority = "normal";
                        }),
                      ),
                      const SizedBox(width: 6),
                      ActionChip(
                        avatar: const Text("🍲"),
                        label: const Text("01:00 PM Lunch"),
                        onPressed: () => setDialogState(() {
                          titleController.text = "Afternoon Lunch";
                          timeController.text = "01:00 PM";
                          selectedType = "meal";
                          selectedPriority = "normal";
                        }),
                      ),
                      const SizedBox(width: 6),
                      ActionChip(
                        avatar: const Text("🚶"),
                        label: const Text("05:00 PM Walk"),
                        onPressed: () => setDialogState(() {
                          titleController.text = "Evening Garden Walk";
                          timeController.text = "05:00 PM";
                          selectedType = "exercise/walk";
                          selectedPriority = "normal";
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'medication', child: Text('💊 Medication')),
                    DropdownMenuItem(value: 'water', child: Text('💧 Hydration / Water')),
                    DropdownMenuItem(value: 'meal', child: Text('🍲 Meal / Nutrition')),
                    DropdownMenuItem(value: 'exercise/walk', child: Text('🚶 Walk / Exercise')),
                    DropdownMenuItem(value: 'family', child: Text('👨‍👩‍👧 Family Connect')),
                  ],
                  onChanged: (v) => setDialogState(() => selectedType = v ?? 'medication'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedPriority,
                  decoration: const InputDecoration(labelText: 'Priority Level', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'high', child: Text('🔴 High Priority')),
                    DropdownMenuItem(value: 'normal', child: Text('🟡 Normal Priority')),
                    DropdownMenuItem(value: 'low', child: Text('🟢 Low Priority')),
                  ],
                  onChanged: (v) => setDialogState(() => selectedPriority = v ?? 'normal'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF264653),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: isSaving ? null : () async {
                final title = titleController.text.trim();
                final time = timeController.text.trim();
                if (title.isEmpty) {
                  setDialogState(() => titleError = 'Please enter a reminder title');
                  return;
                }
                setDialogState(() => isSaving = true);
                try {
                  await ref.read(caregiverDashboardProvider.notifier).addReminder(
                    title,
                    time.isEmpty ? '08:00 AM' : time,
                    selectedType,
                    priority: selectedPriority,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✓ Reminder "$title" scheduled for $patientName!'),
                        backgroundColor: const Color(0xFF2A9D8F),
                      ),
                    );
                  }
                } catch (e) {
                  setDialogState(() => isSaving = false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to save reminder: $e'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              },
              child: isSaving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Reminder', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditReminderDialog(BuildContext context, WidgetRef ref, ReminderModel reminder) {
    final titleController = TextEditingController(text: reminder.title);
    final timeController = TextEditingController(text: reminder.time);
    String selectedType = reminder.type;
    String selectedPriority = reminder.priority;
    String? titleError;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.edit_calendar_rounded, color: Color(0xFF2A9D8F)),
              SizedBox(width: 8),
              Text('Edit Reminder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Reminder Title *',
                    errorText: titleError,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.title),
                  ),
                  onChanged: (_) {
                    if (titleError != null) setDialogState(() => titleError = null);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: timeController,
                        decoration: const InputDecoration(
                          labelText: 'Scheduled Time',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      icon: const Icon(Icons.schedule),
                      tooltip: "Pick Time",
                      style: IconButton.styleFrom(backgroundColor: const Color(0xFF2A9D8F)),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 8, minute: 0),
                        );
                        if (picked != null) {
                          final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
                          final minute = picked.minute.toString().padLeft(2, '0');
                          final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
                          setDialogState(() {
                            timeController.text = "${hour.toString().padLeft(2, '0')}:$minute $period";
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: ['medication', 'water', 'meal', 'exercise/walk', 'family'].contains(selectedType) ? selectedType : 'medication',
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'medication', child: Text('💊 Medication')),
                    DropdownMenuItem(value: 'water', child: Text('💧 Hydration / Water')),
                    DropdownMenuItem(value: 'meal', child: Text('🍲 Meal / Nutrition')),
                    DropdownMenuItem(value: 'exercise/walk', child: Text('🚶 Walk / Exercise')),
                    DropdownMenuItem(value: 'family', child: Text('👨‍👩‍👧 Family Connect')),
                  ],
                  onChanged: (v) => setDialogState(() => selectedType = v ?? 'medication'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: ['high', 'normal', 'low'].contains(selectedPriority) ? selectedPriority : 'normal',
                  decoration: const InputDecoration(labelText: 'Priority Level', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'high', child: Text('🔴 High Priority')),
                    DropdownMenuItem(value: 'normal', child: Text('🟡 Normal Priority')),
                    DropdownMenuItem(value: 'low', child: Text('🟢 Low Priority')),
                  ],
                  onChanged: (v) => setDialogState(() => selectedPriority = v ?? 'normal'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF264653),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: isSaving ? null : () async {
                final title = titleController.text.trim();
                final time = timeController.text.trim();
                if (title.isEmpty) {
                  setDialogState(() => titleError = 'Please enter a reminder title');
                  return;
                }
                setDialogState(() => isSaving = true);
                try {
                  final updated = reminder.copyWith(
                    title: title,
                    time: time.isEmpty ? reminder.time : time,
                    type: selectedType,
                    priority: selectedPriority,
                    updatedAt: DateTime.now().toIso8601String(),
                  );
                  await ref.read(caregiverDashboardProvider.notifier).updateReminder(updated);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✓ Reminder updated!'),
                        backgroundColor: Color(0xFF2A9D8F),
                      ),
                    );
                  }
                } catch (e) {
                  setDialogState(() => isSaving = false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update reminder: $e'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              },
              child: isSaving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteReminder(BuildContext context, WidgetRef ref, String reminderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () async {
              await ref.read(caregiverDashboardProvider.notifier).deleteReminder(reminderId);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✓ Reminder deleted')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(CaregiverDashboardState state, AppLocalizations l10n) {
    final hasData = state.gameHistory.isNotEmpty;

    // Calculate real dynamic trend and domain metrics
    String trendMessage = "";
    Color trendColor = Colors.grey;

    int memoryScore = 0;
    int attentionScore = 0;
    int speedScore = 0;

    if (hasData) {
      final total = state.gameHistory.length;
      final avgScore = state.gameHistory.map((g) => g.cvsScore).reduce((a, b) => a + b) / total;
      final recentCount = total > 3 ? 3 : total;
      final recentAvg = state.gameHistory.take(recentCount).map((g) => g.cvsScore).reduce((a, b) => a + b) / recentCount;
      final delta = recentAvg - avgScore;

      if (delta > 2.0) {
        trendMessage = "Recent game performance is higher than earlier sessions.\n📈 +${delta.toStringAsFixed(1)} percentage points";
        trendColor = Colors.green;
      } else if (delta < -2.0) {
        trendMessage = "Recent performance showed mild decline.\n📉 ${delta.toStringAsFixed(1)} percentage points";
        trendColor = Colors.orange;
      } else {
        trendMessage = "Cognitive performance has remained remarkably stable.\n➡️ Stable across sessions";
        trendColor = const Color(0xFF2A9D8F);
      }

      // Memory domain
      final memoryGames = state.gameHistory.where((g) => ['memory_match', 'picture_recall', 'card_recall', 'visual_handloom'].contains(g.gameType)).toList();
      if (memoryGames.isNotEmpty) {
        memoryScore = (memoryGames.map((g) => g.cvsScore).reduce((a, b) => a + b) / memoryGames.length).round().clamp(0, 100);
      } else {
        memoryScore = avgScore.round().clamp(0, 100);
      }

      // Executive / Attention domain
      final attentionGames = state.gameHistory.where((g) => ['pattern_builder', 'word_garden', 'daily_helper', 'routine_tea'].contains(g.gameType)).toList();
      if (attentionGames.isNotEmpty) {
        attentionScore = (attentionGames.map((g) => g.cvsScore).reduce((a, b) => a + b) / attentionGames.length).round().clamp(0, 100);
      } else {
        attentionScore = (avgScore * 0.95).round().clamp(0, 100);
      }

      // Speed / Latency score
      final avgLatency = (state.gameStats['avg_latency'] as num?)?.toInt() ?? 1500;
      speedScore = ((3000 - avgLatency) / 25).round().clamp(10, 100);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      children: [
        Text(l10n.cognitiveAnalysis, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF264653))),
        const SizedBox(height: 8),
        if (hasData)
          Text(trendMessage, style: TextStyle(color: trendColor, fontWeight: FontWeight.bold, height: 1.3))
        else
          Text(
            "Track cognitive vitality trends and clinical domain breakdowns.",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        const SizedBox(height: 20),

        // 1. Primary Line Graph from SQLite Records
        PatientProgressChart(
          sessions: state.gameHistory,
          activeTimeFilter: _analyticsTimeFilter,
          title: "Patient Longitudinal Trend",
          onFilterChanged: (filter) {
            setState(() => _analyticsTimeFilter = filter);
          },
        ),
        const SizedBox(height: 24),
        
        if (hasData) ...[
          Text("Clinical Domain Breakdown", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF264653))),
          const SizedBox(height: 16),
          _buildDomainTrend("Memory Recall", memoryScore, memoryScore >= 70, isStable: (memoryScore - 70).abs() < 5),
          _buildDomainTrend("Attention & Logic", attentionScore, attentionScore >= 70, isStable: (attentionScore - 70).abs() < 5),
          _buildDomainTrend("Processing Speed", speedScore, speedScore >= 70, isStable: (speedScore - 70).abs() < 5),
          const SizedBox(height: 24),
        ],

        Text(l10n.gameProgression, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF264653))),
        const SizedBox(height: 16),
        _buildGameProgressionSummary(state.gameHistory, l10n),

        const SizedBox(height: 32),
        Text(l10n.gameHistory, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF264653))),
        const SizedBox(height: 16),
        
        if (state.gameHistory.isEmpty) 
          Text(l10n.noGameHistory, style: const TextStyle(color: Colors.grey, fontSize: 15))
        else
          ...state.gameHistory.map((g) {
            final dt = DateTime.tryParse(g.timestamp)?.toLocal() ?? DateTime.now();
            final timeStr = "${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
            final name = g.gameType.replaceAll('_', ' ').toUpperCase();
            return _buildHistoryItem(
              name, 
              timeStr, 
              "Level: ${g.difficultyLevel.toInt()} | Score: ${g.cvsScore.round()}/100 | Latency: ${g.reactionTimeMs}ms"
            );
          }).toList(),
      ],
    );
  }

  // --- Helper Widgets ---

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {String? subtitle}) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      backgroundColor: Colors.white,
      borderColor: Colors.grey[200]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF264653)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              )
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
          ]
        ],
      ),
    );
  }

  Widget _buildInsightCard(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        backgroundColor: Colors.white,
        borderColor: Colors.grey[200]!,
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    ),
  );
}

  Widget _buildTimelineItem(String time, String title, IconData icon, Color color, String statusLabel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(time, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF264653))),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(statusLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDomainTrend(String domain, int score, bool isUp, {bool isStable = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        backgroundColor: Colors.white,
        borderColor: Colors.grey[200]!,
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(domain, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF264653)),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Text(score.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Icon(
            isStable ? Icons.arrow_forward : (isUp ? Icons.arrow_upward : Icons.arrow_downward),
            color: isStable ? Colors.grey : (isUp ? Colors.green : Colors.red),
            size: 20,
          )
        ],
      ),
    ),
  );
}

  Widget _buildHistoryItem(String game, String time, String stats) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: Color(0xFF264653), child: Icon(Icons.gamepad, color: Colors.white)),
        title: Text(game, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(time, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text(stats),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildGameProgressionSummary(List<dynamic> history, AppLocalizations l10n) {
    if (history.isEmpty) return Text(l10n.noGameHistory);

    // Group by gameType
    Map<String, List<dynamic>> grouped = {};
    for (var g in history) {
      grouped.putIfAbsent(g.gameType, () => []).add(g);
    }

    return Column(
      children: grouped.entries.map((entry) {
        final games = entry.value;
        games.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Newest first

        double highestLvl = 1.0;
        double currentLvl = 1.0;
        if (games.isNotEmpty) {
          currentLvl = games.first.difficultyLevel;
          for (var g in games) {
            if (g.difficultyLevel > highestLvl) highestLvl = g.difficultyLevel;
          }
        }
        
        // Very basic trend (compare last 2)
        String trend = l10n.trendStable;
        if (games.length >= 2) {
          double last = games[0].cvsScore;
          double prev = games[1].cvsScore;
          if (last > prev + 5) trend = l10n.trendImproving;
          else if (last < prev - 5) trend = l10n.trendNeedsPractice;
        }

        // Prettify game name
        String title = entry.key.replaceAll('_', ' ').toUpperCase();

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: AppCard(
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.white,
            borderColor: Colors.grey[200]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.currentLevel(currentLvl.toInt())),
                  Text(l10n.highestLevel(highestLvl.toInt())),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.recentScore(games.first.cvsScore.toInt())),
                  Text(trend, style: TextStyle(
                    color: trend.contains('Improving') ? Colors.green : (trend.contains('Practice') ? Colors.orange : Colors.grey),
                    fontWeight: FontWeight.bold
                  )),
                ],
              )
            ],
          ),
        ),
      );
    }).toList(),
    );
  }
}

class _TimelineEventItem {
  final DateTime dateTime;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String badge;

  _TimelineEventItem({
    required this.dateTime,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.badge,
  });
}

