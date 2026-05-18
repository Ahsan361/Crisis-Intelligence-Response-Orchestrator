import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/crisis_alert.dart';
import '../providers/app_providers.dart';
import '../router/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/severity_badge.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ═══════════════════════════════════════════════════════════════════════════
// TRACE HISTORY SCREEN
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
            title: Text('Analysis History', style: ts.title),
            centerTitle: false,
          ),
          alertsAsync.when(
            data: (alerts) {
              // Filter for reports that have been analyzed (simulated status or have trace)
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
                          Icon(Icons.history_rounded, size: 48, color: colors.onSurface.withValues(alpha: 0.2)),
                          const SizedBox(height: 16),
                          Text(
                            'No analyzed reports yet.',
                            style: ts.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Submit a report to see how AI agents process the crisis.',
                            style: ts.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final alert = traceReports[index];
                      return _TraceHistoryCard(alert: alert)
                          .animate()
                          .fadeIn(delay: (index * 100).ms)
                          .slideY(begin: 0.1, end: 0);
                    },
                    childCount: traceReports.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
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

class _TraceHistoryCard extends StatelessWidget {
  const _TraceHistoryCard({required this.alert});
  final CrisisAlert alert;

  Map<String, dynamic> _buildPipelineResultFromAlert(CrisisAlert alert) {
    return {
      'report_id': alert.id,
      'crisis_type': alert.crisisType?.value,
      'severity': alert.severity?.value,
      'crisis_confidence': alert.crisisConfidence,
      'detected_language': alert.detectedLanguage,
      'normalized_location': alert.areaName,
      'action_plan': [], // Usually empty for historical viewing unless saved
      'simulation_result': alert.simulationResult ?? {},
      'trace': alert.agentTrace ?? [],
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = CiroColors.of(context);
    final ts = CiroTextStyles.of(context);
    
    // Time ago logic
    final now = DateTime.now();
    final diff = alert.createdAt != null ? now.difference(alert.createdAt!) : null;
    final timeAgo = diff == null 
        ? 'Unknown' 
        : diff.inHours > 24 
            ? '${diff.inDays}d ago' 
            : diff.inMinutes > 60 
                ? '${diff.inHours}h ago' 
                : '${diff.inMinutes}m ago';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.divider),
      ),
      child: InkWell(
        onTap: () {
          context.pushNamed(
            CiroRoutes.traceName,
            extra: _buildPipelineResultFromAlert(alert),
          );
        },
        borderRadius: BorderRadius.circular(12),
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
                      _getTypeIcon(alert.crisisType, colors),
                      const SizedBox(width: 12),
                      Text(
                        alert.crisisType?.displayName.toUpperCase() ?? 'UNKNOWN',
                        style: ts.labelTiny.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SeverityBadge(severity: alert.severity?.value ?? 'unknown'),
                ],
              ),
              const SizedBox(height: 12),
              Text(alert.areaName ?? 'Islamabad', style: ts.titleMedium),
              const SizedBox(height: 4),
              Text(
                alert.reportText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ts.bodySmall.copyWith(color: colors.onSurface.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 14, color: colors.onSurface),
                      const SizedBox(width: 4),
                      Text(timeAgo, style: ts.labelTiny),
                    ],
                  ),
                  _StatusChip(status: alert.status, colors: colors, ts: ts),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getTypeIcon(CrisisType? type, CiroColorScheme colors) {
    IconData icon;
    switch (type) {
      case CrisisType.flood: icon = Icons.water_rounded; break;
      case CrisisType.accident: icon = Icons.car_crash_rounded; break;
      case CrisisType.heatwave: icon = Icons.wb_sunny_rounded; break;
      case CrisisType.blockage: icon = Icons.traffic_rounded; break;
      case CrisisType.infrastructure: icon = Icons.construction_rounded; break;
      default: icon = Icons.emergency_rounded;
    }
    return Icon(icon, size: 20, color: colors.primary);
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.colors, required this.ts});
  final ReportStatus status;
  final CiroColorScheme colors;
  final CiroTextStyleSet ts;

  @override
  Widget build(BuildContext context) {
    Color color = colors.onSurface;
    if (status == ReportStatus.simulated) color = colors.secondary;
    if (status == ReportStatus.analyzing) color = colors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.displayName.toUpperCase(),
        style: ts.labelTiny.copyWith(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}
