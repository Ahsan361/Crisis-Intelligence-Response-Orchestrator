import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/crisis_card.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ALL ALERTS SCREEN — Full crisis report list
// ═══════════════════════════════════════════════════════════════════════════

class AllAlertsScreen extends ConsumerWidget {
  const AllAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = CiroColors.of(context);
    final ts = CiroTextStyles.of(context);
    final alertsAsync = ref.watch(allAlertsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('All Reports', style: ts.title),
            alertsAsync.whenOrNull(
              data: (alerts) => Text(
                '${alerts.length} total',
                style: ts.caption.copyWith(
                  color: colors.onSurface.withAlpha(100),
                ),
              ),
            ) ?? const SizedBox.shrink(),
          ],
        ),
      ),
      body: alertsAsync.when(
        data: (alerts) {
          if (alerts.isEmpty) {
            return Center(
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
                      child: Icon(
                        Icons.check_circle_outline_rounded,
                        size: 40,
                        color: CiroColors.severityLow.withAlpha(100),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No reports found',
                      style: ts.title,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'When crisis reports are submitted, they will appear here.',
                      style: ts.bodySmall.copyWith(
                        color: colors.onSurface.withAlpha(120),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            itemCount: alerts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final alert = alerts[i];
              return CrisisCard(
                alert: alert,
                onTap: () => context.pushNamed(
                  'trace',
                  extra: {
                    'report_id': alert.id,
                    'crisis_type': alert.crisisType?.value,
                    'severity': alert.severity?.value,
                    'crisis_confidence': alert.crisisConfidence,
                    'detected_language': alert.detectedLanguage,
                    'normalized_location': alert.areaName,
                    'action_plan': [],
                    'simulation_result': alert.simulationResult ?? {},
                    'trace': alert.agentTrace ?? [],
                  },
                ),
              )
                  .animate()
                  .fadeIn(delay: (i * 80).ms, duration: 300.ms)
                  .slideY(begin: 0.04, end: 0, delay: (i * 80).ms);
            },
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            color: colors.primary,
            strokeWidth: 2.5,
          ),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off_rounded, size: 40,
                    color: colors.error.withAlpha(150)),
                const SizedBox(height: 16),
                Text(
                  'Failed to load reports',
                  style: ts.title.copyWith(color: colors.error),
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  style: ts.bodySmall.copyWith(color: colors.onSurface.withAlpha(120)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: () => ref.refresh(allAlertsProvider),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retry'),
                  style: TextButton.styleFrom(
                    foregroundColor: colors.primary,
                    backgroundColor: colors.primary.withAlpha(15),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(CiroTheme.chipRadius),
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
}
