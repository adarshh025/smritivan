// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../features/games/domain/game_session_model.dart';
import 'app_card.dart';

/// Real Patient Progress Line Chart with Touch Tooltips & Time Range Filtering.
/// Strictly renders authentic SQLite records with NO fake/interpolated data points.
class PatientProgressChart extends StatefulWidget {
  final List<GameSessionModel> sessions;
  final String activeTimeFilter; // '7d', '30d', 'all'
  final ValueChanged<String>? onFilterChanged;
  final bool showFilters;
  final String title;

  const PatientProgressChart({
    Key? key,
    required this.sessions,
    this.activeTimeFilter = '30d',
    this.onFilterChanged,
    this.showFilters = true,
    this.title = 'Activity & Game Progress',
  }) : super(key: key);

  @override
  State<PatientProgressChart> createState() => _PatientProgressChartState();
}

class _PatientProgressChartState extends State<PatientProgressChart> {
  int? _selectedPointIndex;

  String _formatGameTitle(String gameType) {
    if (gameType.isEmpty) return 'Cognitive Activity';
    return gameType
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  String _formatDateTime(String timestamp) {
    final dt = DateTime.tryParse(timestamp)?.toLocal() ?? DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return "${dt.day} ${months[dt.month - 1]}, $hour:$minute $period";
  }

  String _formatShortDate(String timestamp) {
    final dt = DateTime.tryParse(timestamp)?.toLocal() ?? DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${dt.day} ${months[dt.month - 1]}";
  }

  @override
  Widget build(BuildContext context) {
    // Filter sessions chronologically (oldest to newest for left-to-right plotting)
    final sortedSessions = List<GameSessionModel>.from(widget.sessions)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Apply time filter
    final filteredSessions = _applyTimeFilter(sortedSessions, widget.activeTimeFilter);

    return AppCard(
      padding: const EdgeInsets.all(20.0),
      backgroundColor: Colors.white,
      borderColor: AppColors.paleParchment,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + Filter Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepSageGreen,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Cognitive Engagement Trend (0–100)",
                      style: AppTypography.metricLabel.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.showFilters && widget.onFilterChanged != null)
                _buildTimeFilterSelector(),
            ],
          ),
          const SizedBox(height: 20),

          // Chart Body depending on data availability
          if (filteredSessions.isEmpty)
            _buildEmptyState()
          else if (filteredSessions.length == 1)
            _buildSingleSessionView(filteredSessions.first)
          else
            _buildMultiPointChartView(filteredSessions),

          // Selected Point Details Card (Tooltip info box)
          if (filteredSessions.isNotEmpty && _selectedPointIndex != null && _selectedPointIndex! < filteredSessions.length) ...[
            const SizedBox(height: 16),
            _buildPointDetailCard(filteredSessions[_selectedPointIndex!]),
          ],
        ],
      ),
    );
  }

  List<GameSessionModel> _applyTimeFilter(List<GameSessionModel> items, String filter) {
    if (filter == 'all') return items;
    final now = DateTime.now();
    final days = filter == '7d' ? 7 : 30;
    final cutoff = now.subtract(Duration(days: days));

    return items.where((s) {
      final dt = DateTime.tryParse(s.timestamp)?.toLocal();
      if (dt == null) return true;
      return dt.isAfter(cutoff);
    }).toList();
  }

  Widget _buildTimeFilterSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.warmSand,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFilterChip('7d', '7 Days'),
          _buildFilterChip('30d', '30 Days'),
          _buildFilterChip('all', 'All Time'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = widget.activeTimeFilter == key;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        setState(() => _selectedPointIndex = null);
        widget.onFilterChanged?.call(key);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.deepSageGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textCharcoal,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool hasGlobalSessions = widget.sessions.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.warmSand.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.paleParchment),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.softSageGreen.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasGlobalSessions ? Icons.history_toggle_off_rounded : Icons.show_chart_rounded,
              size: 38,
              color: AppColors.deepSageGreen,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            hasGlobalSessions ? "No activities in selected timeframe" : "No activities recorded yet",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textCharcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasGlobalSessions
                ? "You have ${widget.sessions.length} recorded session${widget.sessions.length > 1 ? 's' : ''} in total. Switch timeframe to \"All Time\" to view your graph."
                : "Complete your first cognitive game to begin tracking your engagement progress.",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          if (hasGlobalSessions && widget.onFilterChanged != null) ...[
            const SizedBox(height: 14),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepSageGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.all_inclusive, size: 18),
              label: const Text("View All Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              onPressed: () => widget.onFilterChanged!('all'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSingleSessionView(GameSessionModel session) {
    final score = session.cvsScore.round();
    final gameTitle = _formatGameTitle(session.gameType);
    final dateStr = _formatDateTime(session.timestamp);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softSageGreen.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.deepSageGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    "$score",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gameTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textCharcoal,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Level ${session.difficultyLevel.toInt()} • $dateStr",
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.paleParchment),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMiniMetric("Reaction Latency", "${session.reactionTimeMs} ms"),
                _buildMiniMetric("Duration", "${session.durationSeconds}s"),
                _buildMiniMetric("Errors", "${(session.errorRate * 100).toInt()}%"),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "✓ Single session recorded. Complete additional games to generate a longitudinal trend line.",
            style: TextStyle(
              fontSize: 12,
              color: AppColors.deepSageGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textCharcoal)),
      ],
    );
  }

  Widget _buildMultiPointChartView(List<GameSessionModel> sessions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sessions.length <= 3)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: AppColors.deepSageGreen),
                const SizedBox(width: 6),
                Text(
                  "Preliminary Trend (${sessions.length} sessions)",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepSageGreen,
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          height: 200,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTapDown: (details) {
                  final renderBox = context.findRenderObject() as RenderBox?;
                  if (renderBox == null) return;
                  final localPosition = details.localPosition;
                  final index = _findNearestPointIndex(localPosition, constraints.biggest, sessions);
                  setState(() {
                    _selectedPointIndex = index;
                  });
                },
                child: CustomPaint(
                  size: Size(constraints.maxWidth, 200),
                  painter: _ChartPainter(
                    sessions: sessions,
                    selectedIndex: _selectedPointIndex,
                    formatShortDate: _formatShortDate,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            "💡 Tap any point on the graph to inspect session details",
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  int? _findNearestPointIndex(Offset touchPos, Size size, List<GameSessionModel> sessions) {
    if (sessions.isEmpty) return null;
    const paddingLeft = 32.0;
    const paddingRight = 16.0;
    const paddingTop = 20.0;
    const paddingBottom = 28.0;

    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingTop - paddingBottom;
    final stepX = chartWidth / (sessions.length - 1);

    int? closestIdx;
    double minDistance = double.infinity;

    for (int i = 0; i < sessions.length; i++) {
      final x = paddingLeft + i * stepX;
      final normalizedScore = (sessions[i].cvsScore.clamp(0.0, 100.0)) / 100.0;
      final y = paddingTop + chartHeight * (1.0 - normalizedScore);

      final distance = (Offset(x, y) - touchPos).distance;
      if (distance < 40 && distance < minDistance) {
        minDistance = distance;
        closestIdx = i;
      }
    }

    return closestIdx;
  }

  Widget _buildPointDetailCard(GameSessionModel session) {
    final score = session.cvsScore.round();
    final gameTitle = _formatGameTitle(session.gameType);
    final dateStr = _formatDateTime(session.timestamp);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6F0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.softSageGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.deepSageGreen, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    gameTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textCharcoal),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.deepSageGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Score: $score / 100",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Level ${session.difficultyLevel.toInt()}  •  $dateStr",
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                "⚡ Latency: ${session.reactionTimeMs} ms",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textCharcoal),
              ),
              const SizedBox(width: 16),
              Text(
                "⏱ Duration: ${session.durationSeconds}s",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textCharcoal),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<GameSessionModel> sessions;
  final int? selectedIndex;
  final String Function(String) formatShortDate;

  _ChartPainter({
    required this.sessions,
    required this.selectedIndex,
    required this.formatShortDate,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (sessions.isEmpty) return;

    const paddingLeft = 32.0;
    const paddingRight = 16.0;
    const paddingTop = 20.0;
    const paddingBottom = 28.0;

    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingTop - paddingBottom;

    // Grid paint
    final gridPaint = Paint()
      ..color = AppColors.paleParchment
      ..strokeWidth = 1.0;

    // Text style for axis labels
    const axisTextStyle = TextStyle(
      color: AppColors.textSecondary,
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );

    // 1. Draw horizontal grid lines & Y-axis labels (0, 25, 50, 75, 100)
    for (int level = 0; level <= 4; level++) {
      final value = level * 25;
      final y = paddingTop + chartHeight * (1.0 - level / 4.0);

      // Line
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(size.width - paddingRight, y),
        gridPaint,
      );

      // Label
      final textPainter = TextPainter(
        text: TextSpan(text: '$value', style: axisTextStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(paddingLeft - textPainter.width - 6, y - textPainter.height / 2),
      );
    }

    // Calculate points
    final count = sessions.length;
    final stepX = count > 1 ? chartWidth / (count - 1) : 0.0;
    final points = <Offset>[];

    for (int i = 0; i < count; i++) {
      final x = paddingLeft + (count > 1 ? i * stepX : chartWidth / 2);
      final normalized = (sessions[i].cvsScore.clamp(0.0, 100.0)) / 100.0;
      final y = paddingTop + chartHeight * (1.0 - normalized);
      points.add(Offset(x, y));
    }

    // 2. Draw Area Gradient & Trend Line
    if (points.length > 1) {
      final linePath = Path();
      linePath.moveTo(points.first.dx, points.first.dy);

      for (int i = 1; i < points.length; i++) {
        linePath.lineTo(points[i].dx, points[i].dy);
      }

      // Fill Path
      final fillPath = Path.from(linePath);
      fillPath.lineTo(points.last.dx, paddingTop + chartHeight);
      fillPath.lineTo(points.first.dx, paddingTop + chartHeight);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.deepSageGreen.withOpacity(0.25),
            AppColors.deepSageGreen.withOpacity(0.02),
          ],
        ).createShader(Rect.fromLTWH(0, paddingTop, size.width, chartHeight));

      canvas.drawPath(fillPath, fillPaint);

      // Stroke Line
      final linePaint = Paint()
        ..color = AppColors.deepSageGreen
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      canvas.drawPath(linePath, linePaint);
    }

    // 3. Draw Point Dots and Values
    final dotPaint = Paint()..color = AppColors.deepSageGreen;
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final highlightDotPaint = Paint()..color = const Color(0xFFE76F51);
    final highlightBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      final isSelected = selectedIndex == i;

      // Draw outer shadow for dot
      canvas.drawCircle(pt, isSelected ? 8 : 5, Paint()..color = Colors.black.withOpacity(0.1));

      // Draw dot
      canvas.drawCircle(pt, isSelected ? 7 : 4.5, isSelected ? highlightDotPaint : dotPaint);
      canvas.drawCircle(pt, isSelected ? 7 : 4.5, isSelected ? highlightBorderPaint : dotBorderPaint);

      // If only 2-4 points, draw score values directly above
      if (count <= 4 && !isSelected) {
        final scoreText = '${sessions[i].cvsScore.round()}';
        final textPainter = TextPainter(
          text: TextSpan(
            text: scoreText,
            style: const TextStyle(
              color: AppColors.deepSageGreen,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          Offset(pt.dx - textPainter.width / 2, pt.dy - textPainter.height - 4),
        );
      }
    }

    // 4. Draw X-axis Date Labels (smart interval)
    final labelInterval = count <= 6 ? 1 : (count / 4).ceil();

    for (int i = 0; i < count; i += labelInterval) {
      final pt = points[i];
      final dateText = formatShortDate(sessions[i].timestamp);

      final textPainter = TextPainter(
        text: TextSpan(text: dateText, style: axisTextStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(pt.dx - textPainter.width / 2, paddingTop + chartHeight + 8),
      );
    }

    // Ensure the last date label is always printed if skipped
    if ((count - 1) % labelInterval != 0) {
      final pt = points.last;
      final dateText = formatShortDate(sessions.last.timestamp);

      final textPainter = TextPainter(
        text: TextSpan(text: dateText, style: axisTextStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(pt.dx - textPainter.width / 2, paddingTop + chartHeight + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.sessions != sessions || oldDelegate.selectedIndex != selectedIndex;
  }
}
