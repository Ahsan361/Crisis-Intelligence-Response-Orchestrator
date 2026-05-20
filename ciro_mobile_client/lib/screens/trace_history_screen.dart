import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/crisis_alert.dart';
import '../providers/app_providers.dart';
import '../router/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/severity_badge.dart';

// ═══════════════════════════════════════════════════════════════════════════
// TRACE HISTORY SCREEN — Analysis history with premium cards
// ═══════════════════════════════════════════════════════════════════════════

class TraceHistoryScreen extends ConsumerWidget {
  const TraceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(allAlertsProvider);
    final colors = CiroColors.of(context);
    final ts = CiroTextStyles.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: colors.background,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Analysis History', style: ts.title),
                Text(
                  'Past AI pipeline traces',
                  style: ts.caption.copyWith(
                    color: colors.onSurface.withAlpha(100),
                  ),
                ),
              ],
            ),
            centerTitle: false,
          ),
          alertsAsync.when(
            data: (alerts) {
              final traceReports = alerts.where((a) =>
                a.status == ReportStatus.simulated ||
                (a.agentTrace != null && a.agentTrace!.isNotEmpty)
              ).toList();

              if (traceReports.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: colors.surfaceVariant.withAlpha(80),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.history_rounded,
                                size: 40, color: colors.onSurface.withAlpha(60)),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No analyzed reports yet',
                            style: ts.title,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Submit a report to see how AI agents process the crisis.',
                            style: ts.bodySmall.copyWith(
                              color: colors.onSurface.withAlpha(120),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final alert = traceReports[index];
                      return _TraceHistoryCard(alert: alert)
                          .animate()
                          .fadeIn(delay: (index * 100).ms, duration: 350.ms)
                          .slideY(begin: 0.05, end: 0, delay: (index * 100).ms);
                    },
                    childCount: traceReports.length,
                  ),
                ),
              );
            },
            loading: () => SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: colors.primary,
                  strokeWidth: 2.5,
                ),
              ),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(
                child: Text('Failed to load history: $err', style: ts.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TraceHistoryCard extends StatefulWidget {
  const _TraceHistoryCard({required this.alert});
  final CrisisAlert alert;

  @override
  State<_TraceHistoryCard> createState() => _TraceHistoryCardState();
}

class _TraceHistoryCardState extends State<_TraceHistoryCard> {
  bool _isPressed = false;

  Map<String, dynamic> _buildPipelineResultFromAlert(CrisisAlert alert) {
    return {
      'report_id': alert.id,
      'crisis_type': alert.crisisType?.value,
      'severity': alert.severity?.value,
      'crisis_confidence': alert.crisisConfidence,
      'detected_language': alert.detectedLanguage,
      'normalized_location': alert.areaName,
      'action_plan': [],
      'simulation_result': alert.simulationResult ?? {},
      'trace': alert.agentTrace ?? [],
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = CiroColors.of(context);
    final ts = CiroTextStyles.of(context);
    final severityColor = CiroColors.forSeverity(widget.alert.severity?.value ?? 'unknown');

    final now = DateTime.now();
    final diff = widget.alert.createdAt != null
        ? now.difference(widget.alert.createdAt!)
        : null;
    final timeAgo = diff == null
        ? 'Unknown'
        : diff.inHours > 24
            ? '${diff.inDays}d ago'
            : diff.inMinutes > 60
                ? '${diff.inHours}h ago'
                : '${diff.inMinutes}m ago';

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        context.pushNamed(
          CiroRoutes.traceName,
          extra: _buildPipelineResultFromAlert(widget.alert),
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colors.surfaceVariant,
            borderRadius: BorderRadius.circular(CiroTheme.cardRadius),
            border: Border.all(
              color: _isPressed
                  ? severityColor.withAlpha(40)
                  : CiroColors.glassBorder,
            ),
            gradient: CiroColors.cardGradient,
            boxShadow: [
              BoxShadow(
                color: severityColor.withAlpha(_isPressed ? 20 : 8),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // ── Severity accent bar ──────────────────────────────
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: severityColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(22),
                      bottomLeft: Radius.circular(22),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                _getTypeIcon(widget.alert.crisisType, severityColor),
                                const SizedBox(width: 10),
                                Text(
                                  widget.alert.crisisType?.displayName.toUpperCase() ?? 'UNKNOWN',
                                  style: ts.caption.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                    color: severityColor,
                                  ),
                                ),
                              ],
                            ),
                            SeverityBadge(severity: widget.alert.severity?.value ?? 'unknown'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.alert.areaName ?? 'Islamabad',
                          style: ts.title.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.alert.reportText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: ts.bodySmall.copyWith(
                            color: colors.onSurface.withAlpha(150),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.access_time_rounded,
                                    size: 12, color: colors.onSurface.withAlpha(100)),
                                const SizedBox(width: 4),
                                Text(
                                  timeAgo,
                                  style: ts.caption.copyWith(
                                    color: colors.onSurface.withAlpha(100),
                                  ),
                                ),
                              ],
                            ),
                            _StatusChip(status: widget.alert.status, colors: colors, ts: ts),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getTypeIcon(CrisisType? type, Color color) {
    IconData icon;
    switch (type) {
      case CrisisType.flood: icon = Icons.water_rounded; break;
      case CrisisType.accident: icon = Icons.car_crash_rounded; break;
      case CrisisType.heatwave: icon = Icons.wb_sunny_rounded; break;
      case CrisisType.blockage: icon = Icons.traffic_rounded; break;
      case CrisisType.infrastructure: icon = Icons.construction_rounded; break;
      default: icon = Icons.emergency_rounded;
    }
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.colors, required this.ts});
  final ReportStatus status;
  final CiroColorScheme colors;
  final CiroTextStyleSet ts;

  Color get _color {
    switch (status) {
      case ReportStatus.pending:
        return CiroColors.severityMedium;
      case ReportStatus.analyzing:
        return CiroColors.aiAccent;
      case ReportStatus.resolved:
        return CiroColors.severityLow;
      case ReportStatus.simulated:
        return CiroColors.severityLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withAlpha(15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withAlpha(30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            status.displayName.toUpperCase(),
            style: ts.caption.copyWith(
              color: _color,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
