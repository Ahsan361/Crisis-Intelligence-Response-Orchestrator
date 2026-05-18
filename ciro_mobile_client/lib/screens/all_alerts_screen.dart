import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/crisis_card.dart';

class AllAlertsScreen extends ConsumerWidget {
  const AllAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = CiroColors.of(context);
    final ts = CiroTextStyles.of(context);
    final alertsAsync = ref.watch(allAlertsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('All Reports', style: ts.title),
      ),
      body: alertsAsync.when(
        data: (alerts) {
          if (alerts.isEmpty) {
            return Center(
              child: Text(
                'No reports found.',
                style: ts.bodySmall.copyWith(color: colors.onSurface),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: alerts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
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
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Error: $err',
              style: ts.bodySmall.copyWith(color: colors.error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
