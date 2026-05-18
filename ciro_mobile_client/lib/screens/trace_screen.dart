import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/severity_badge.dart';

// ═══════════════════════════════════════════════════════════════════════════
// TRACE SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class TraceScreen extends StatelessWidget {
  const TraceScreen({super.key, required this.pipelineResult});

  final Map<String, dynamic>? pipelineResult;

  @override
  Widget build(BuildContext context) {
    final colors = CiroColors.of(context);
    final ts = CiroTextStyles.of(context);

    if (pipelineResult == null) {
      return _buildNullState(context, colors, ts);
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Agent Trace', style: ts.title),
            Text(
              'ID: ${pipelineResult?['report_id'] ?? 'Unknown'}',
              style: ts.mono.copyWith(fontSize: 10, color: colors.onSurface),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Crisis Summary Card ──────────────────────────────────────────
          SliverToBoxAdapter(
            child:
                _SummarySection(data: pipelineResult!, colors: colors, ts: ts)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
          ),

          // ── Simulation Comparison ────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SimulationSection(
              sim: pipelineResult?['simulation_result'],
              colors: colors,
              ts: ts,
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          ),

          // ── Response Actions ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _ActionPlanSection(
              actions: (pipelineResult?['action_plan'] as List?)
                  ?.map((e) => Map<String, dynamic>.from(e as Map))
                  .toList(),
              colors: colors,
              ts: ts,
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
          ),

          // ── Alerts Dispatched ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _AlertsDispatchedSection(
              alerts: (pipelineResult?['simulation_result']
                      ?['alerts_dispatched'] as List?)
                  ?.cast<String>(),
              colors: colors,
              ts: ts,
            ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
          ),

          // ── Agent Trace Log ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
              child: Text('Pipeline Reasoning', style: ts.headline),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final traceList = pipelineResult?['trace'] as List?;
                if (traceList == null || index >= traceList.length) return null;

                final entry = traceList[index] as Map<String, dynamic>;
                return _TraceTimelineItem(
                  entry: entry,
                  isLast: index == traceList.length - 1,
                  colors: colors,
                  ts: ts,
                )
                    .animate()
                    .fadeIn(delay: (800 + (index * 100)).ms)
                    .slideX(begin: 0.05, end: 0);
              },
              childCount: (pipelineResult?['trace'] as List?)?.length ?? 0,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 64)),
        ],
      ),
    );
  }

  Widget _buildNullState(
      BuildContext context, CiroColorScheme colors, CiroTextStyleSet ts) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timeline_rounded,
                  size: 64, color: colors.onSurface.withValues(alpha: 0.2)),
              const SizedBox(height: 24),
              Text(
                'No trace data available',
                style: ts.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Submit a report to see the pipeline reasoning in real-time.',
                style: ts.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTIONS
// ═══════════════════════════════════════════════════════════════════════════

class _SummarySection extends StatelessWidget {
  const _SummarySection(
      {required this.data, required this.colors, required this.ts});
  final Map<String, dynamic> data;
  final CiroColorScheme colors;
  final CiroTextStyleSet ts;

  @override
  Widget build(BuildContext context) {
    final severity = data['severity']?.toString() ?? 'unknown';
    final type = data['crisis_type']?.toString() ?? 'unknown';
    final confidence = data['crisis_confidence'] ?? 0;

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    _getTypeIcon(type, colors),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        type.toUpperCase(),
                        style: ts.title.copyWith(letterSpacing: 1),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SeverityBadge(severity: severity),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          _SummaryRow(
            icon: Icons.location_on_rounded,
            label: 'Location',
            value: data['normalized_location'] ?? 'Islamabad',
            ts: ts,
            colors: colors,
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            icon: Icons.psychology_rounded,
            label: 'Confidence',
            value: '$confidence%',
            ts: ts,
            colors: colors,
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            icon: Icons.translate_rounded,
            label: 'Language',
            value: data['detected_language'] ?? 'English',
            ts: ts,
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _getTypeIcon(String type, CiroColorScheme colors) {
    IconData iconData;
    switch (type.toLowerCase()) {
      case 'flood':
        iconData = Icons.water_rounded;
        break;
      case 'accident':
        iconData = Icons.car_crash_rounded;
        break;
      case 'heatwave':
        iconData = Icons.wb_sunny_rounded;
        break;
      case 'blockage':
        iconData = Icons.traffic_rounded;
        break;
      default:
        iconData = Icons.emergency_rounded;
    }
    return Icon(iconData, color: colors.primary, size: 28);
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(
      {required this.icon,
      required this.label,
      required this.value,
      required this.ts,
      required this.colors});
  final IconData icon;
  final String label;
  final String value;
  final CiroTextStyleSet ts;
  final CiroColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: colors.onSurface),
        const SizedBox(width: 8),
        Text('$label:', style: ts.bodySmall),
        const SizedBox(width: 8),
        Expanded(
            child: Text(value,
                style: ts.bodySmall.copyWith(
                    color: colors.onBackground, fontWeight: FontWeight.bold))),
      ],
    );
  }
}

class _SimulationSection extends StatelessWidget {
  const _SimulationSection({this.sim, required this.colors, required this.ts});
  final Map<String, dynamic>? sim;
  final CiroColorScheme colors;
  final CiroTextStyleSet ts;

  @override
  Widget build(BuildContext context) {
    if (sim == null) return const SizedBox.shrink();

    final before = (sim!['before_route'] as Map?)?.cast<String, dynamic>();
    final after = (sim!['after_route'] as Map?)?.cast<String, dynamic>();
    final ticket = (sim!['emergency_ticket'] as Map?)?.cast<String, dynamic>();

    final int beforeEta = before?['eta_minutes'] ?? 0;
    final int afterEta = after?['eta_minutes'] ?? 0;
    final int saved = beforeEta - afterEta;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Route Simulation', style: ts.titleMedium),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: _SimCol(
                      label: 'BEFORE',
                      eta: beforeEta,
                      congestion: before?['congestion_level'],
                      isPositive: false,
                      colors: colors,
                      ts: ts)),
              Icon(Icons.arrow_forward_rounded,
                  color: colors.onSurface.withValues(alpha: 0.3)),
              Expanded(
                  child: _SimCol(
                      label: 'AFTER CIRO',
                      eta: afterEta,
                      congestion: after?['congestion_level'],
                      isPositive: true,
                      colors: colors,
                      ts: ts)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.bolt_rounded, color: colors.secondary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Agents saved $saved minutes of response time',
                    style: ts.bodySmall.copyWith(
                      color: colors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (ticket != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Text('EMERGENCY TICKET:', style: ts.labelTiny),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ticket['ticket_id'] ?? 'N/A',
                    style:
                        ts.mono.copyWith(fontSize: 12, color: colors.primary),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SimCol extends StatelessWidget {
  const _SimCol(
      {required this.label,
      required this.eta,
      required this.congestion,
      required this.isPositive,
      required this.colors,
      required this.ts});
  final String label;
  final int eta;
  final String? congestion;
  final bool isPositive;
  final CiroColorScheme colors;
  final CiroTextStyleSet ts;

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? colors.secondary : colors.error;
    return Column(
      children: [
        Text(label, style: ts.labelTiny.copyWith(letterSpacing: 1)),
        const SizedBox(height: 8),
        Text('$eta mins',
            style: ts.display.copyWith(color: color, fontSize: 24)),
        Text(congestion?.toUpperCase() ?? 'NONE',
            style: ts.labelTiny.copyWith(color: color)),
      ],
    );
  }
}

class _ActionPlanSection extends StatelessWidget {
  const _ActionPlanSection(
      {this.actions, required this.colors, required this.ts});
  final List? actions;
  final CiroColorScheme colors;
  final CiroTextStyleSet ts;

  @override
  Widget build(BuildContext context) {
    if (actions == null || actions!.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Response Actions', style: ts.titleMedium),
          const SizedBox(height: 12),
          ...actions!.map((a) => _ActionCard(
              action: a as Map<String, dynamic>, colors: colors, ts: ts)),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard(
      {required this.action, required this.colors, required this.ts});
  final Map<String, dynamic> action;
  final CiroColorScheme colors;
  final CiroTextStyleSet ts;

  @override
  Widget build(BuildContext context) {
    final priority = action['priority']?.toString().toLowerCase() ?? 'medium';
    final priorityColor = CiroColors.forSeverity(priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child:
                Icon(Icons.task_alt_rounded, size: 20, color: colors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        action['action_type']?.toString().toUpperCase() ??
                            'ACTION',
                        style:
                            ts.labelTiny.copyWith(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(priority.toUpperCase(),
                          style: ts.labelTiny
                              .copyWith(color: priorityColor, fontSize: 9)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(action['description'] ?? '',
                    style: ts.bodySmall.copyWith(color: colors.onBackground)),
                const SizedBox(height: 8),
                Text('Assigned to: ${action['assigned_to'] ?? 'Unknown'}',
                    style: ts.labelTiny),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertsDispatchedSection extends StatelessWidget {
  const _AlertsDispatchedSection(
      {this.alerts, required this.colors, required this.ts});
  final List? alerts;
  final CiroColorScheme colors;
  final CiroTextStyleSet ts;

  @override
  Widget build(BuildContext context) {
    if (alerts == null || alerts!.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Alerts Dispatched', style: ts.titleMedium),
          const SizedBox(height: 12),
          ...alerts!.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.campaign_rounded,
                        size: 18, color: colors.warning),
                    const SizedBox(width: 12),
                    Expanded(child: Text(a.toString(), style: ts.bodySmall)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _TraceTimelineItem extends StatelessWidget {
  const _TraceTimelineItem(
      {required this.entry,
      required this.isLast,
      required this.colors,
      required this.ts});
  final Map<String, dynamic> entry;
  final bool isLast;
  final CiroColorScheme colors;
  final CiroTextStyleSet ts;

  String _formatTime(String? isoTimestamp) {
    if (isoTimestamp == null) return '--:--:--';
    final dt = DateTime.tryParse(isoTimestamp);
    if (dt == null) return '--:--:--';
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}:'
        '${local.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final agent = entry['agent']?.toString() ?? 'Unknown';
    final agentColor = _getAgentColor(agent, colors);
    final timeStr = _formatTime(entry['timestamp']);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline Line & Node
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: agentColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: agentColor.withValues(alpha: 0.4),
                          blurRadius: 6,
                          spreadRadius: 1)
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: colors.divider,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 20),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            agent,
                            style: ts.body.copyWith(
                                color: agentColor, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(timeStr,
                            style: ts.mono.copyWith(
                                fontSize: 11, color: colors.onSurface)),
                      ],
                    ),
                    if (entry['confidence'] != null) ...[
                      const SizedBox(height: 4),
                      Text('Confidence: ${entry['confidence']}%',
                          style:
                              ts.labelTiny.copyWith(color: colors.secondary)),
                    ],
                    const SizedBox(height: 8),
                    Text(entry['decision'] ?? '',
                        style: ts.bodySmall
                            .copyWith(color: colors.onBackground, height: 1.4)),
                    if (entry['input_summary'] != null) ...[
                      const SizedBox(height: 12),
                      _TraceMeta(
                          label: 'INPUT',
                          value: entry['input_summary'],
                          colors: colors,
                          ts: ts),
                    ],
                    if (entry['output_summary'] != null) ...[
                      const SizedBox(height: 4),
                      _TraceMeta(
                          label: 'OUTPUT',
                          value: entry['output_summary'],
                          colors: colors,
                          ts: ts),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAgentColor(String agent, CiroColorScheme colors) {
    switch (agent) {
      case 'Orchestrator':
        return colors.primary;
      case 'SignalCollector':
        return Colors.purpleAccent;
      case 'CrisisDetector':
        return colors.error;
      case 'ReasoningAnalyzer':
        return colors.warning;
      case 'ActionPlanner':
        return colors.secondary;
      case 'Simulator':
        return Colors.tealAccent;
      default:
        return colors.onSurface;
    }
  }
}

class _TraceMeta extends StatelessWidget {
  const _TraceMeta(
      {required this.label,
      required this.value,
      required this.colors,
      required this.ts});
  final String label;
  final String value;
  final CiroColorScheme colors;
  final CiroTextStyleSet ts;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: ts.labelTiny.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: colors.onSurface)),
        const SizedBox(height: 2),
        Text(value,
            style: ts.bodySmall.copyWith(
                fontSize: 12, color: colors.onSurface.withValues(alpha: 0.8))),
      ],
    );
  }
}
