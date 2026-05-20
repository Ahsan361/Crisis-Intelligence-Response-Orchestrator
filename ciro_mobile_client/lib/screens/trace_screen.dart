import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/severity_badge.dart';

// ═══════════════════════════════════════════════════════════════════════════
// TRACE SCREEN — AI Operations Center
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
              style: ts.mono.copyWith(
                fontSize: 10,
                color: colors.onSurface.withAlpha(120),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: CiroColors.aiAccent.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: CiroColors.aiAccent.withAlpha(30)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.smart_toy_rounded, size: 12, color: CiroColors.aiAccent),
                const SizedBox(width: 4),
                Text(
                  'AI OPS',
                  style: ts.caption.copyWith(
                    color: CiroColors.aiAccent,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Crisis Summary Card ──────────────────────────────────
          SliverToBoxAdapter(
            child:
                _SummarySection(data: pipelineResult!, colors: colors, ts: ts)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.05, end: 0),
          ),

          // ── Simulation Comparison ────────────────────────────────
          SliverToBoxAdapter(
            child: _SimulationSection(
              sim: pipelineResult?['simulation_result'],
              colors: colors,
              ts: ts,
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          ),

          // ── Response Actions ─────────────────────────────────────
          SliverToBoxAdapter(
            child: _ActionPlanSection(
              actions: (pipelineResult?['action_plan'] as List?)
                  ?.map((e) => Map<String, dynamic>.from(e as Map))
                  .toList(),
              colors: colors,
              ts: ts,
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
          ),

          // ── Alerts Dispatched ────────────────────────────────────
          SliverToBoxAdapter(
            child: _AlertsDispatchedSection(
              alerts: (pipelineResult?['simulation_result']
                      ?['alerts_dispatched'] as List?)
                  ?.cast<String>(),
              colors: colors,
              ts: ts,
            ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
          ),

          // ── Agent Trace Log Header ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pipeline Reasoning', style: ts.headline.copyWith(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text(
                    'Multi-agent orchestration trace',
                    style: ts.caption.copyWith(color: colors.onSurface.withAlpha(100)),
                  ),
                ],
              ),
            ),
          ),

          // ── Agent Trace Timeline ─────────────────────────────────
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
                    .fadeIn(delay: (800 + (index * 120)).ms, duration: 350.ms)
                    .slideX(begin: 0.04, end: 0);
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
      backgroundColor: colors.background,
      body: Center(
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
                child: Icon(Icons.timeline_rounded,
                    size: 48, color: colors.onSurface.withAlpha(60)),
              ),
              const SizedBox(height: 24),
              Text(
                'No trace data available',
                style: ts.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Submit a report to see the pipeline reasoning in real-time.',
                style: ts.bodySmall.copyWith(color: colors.onSurface.withAlpha(120)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Go Back'),
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
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SUMMARY SECTION — Glass card with severity-tinted glow
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
    final severityColor = CiroColors.forSeverity(severity);

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(CiroTheme.cardRadius),
        border: Border.all(color: severityColor.withAlpha(30)),
        gradient: CiroColors.cardGradient,
        boxShadow: [
          BoxShadow(
            color: severityColor.withAlpha(15),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    _getTypeIcon(type, severityColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        type.toUpperCase(),
                        style: ts.title.copyWith(
                          letterSpacing: 1,
                          fontSize: 18,
                        ),
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
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: CiroColors.glassBorder,
          ),
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
            valueColor: CiroColors.aiAccent,
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

  Widget _getTypeIcon(String type, Color color) {
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
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: color, size: 24),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    required this.ts,
    required this.colors,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final CiroTextStyleSet ts;
  final CiroColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: colors.onSurface.withAlpha(120)),
        const SizedBox(width: 10),
        Text('$label:', style: ts.bodySmall.copyWith(
          color: colors.onSurface.withAlpha(150),
        )),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: ts.bodySmall.copyWith(
              color: valueColor ?? colors.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SIMULATION SECTION — Before/after comparison
// ═══════════════════════════════════════════════════════════════════════════

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
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(CiroTheme.cardRadius),
        border: Border.all(color: CiroColors.glassBorder),
        gradient: CiroColors.cardGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed_rounded, size: 18, color: colors.primary),
              const SizedBox(width: 8),
              Text('Route Simulation', style: ts.titleMedium),
            ],
          ),
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
                  ts: ts,
                ),
              ),
              Column(
                children: [
                  Icon(Icons.arrow_forward_rounded,
                      color: colors.onSurface.withAlpha(60), size: 20),
                  const SizedBox(height: 4),
                  Text(
                    '-$saved',
                    style: ts.caption.copyWith(
                      color: CiroColors.severityLow,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: _SimCol(
                  label: 'AFTER CIRO',
                  eta: afterEta,
                  congestion: after?['congestion_level'],
                  isPositive: true,
                  colors: colors,
                  ts: ts,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CiroColors.severityLow.withAlpha(10),
              borderRadius: BorderRadius.circular(CiroTheme.chipRadius),
              border: Border.all(color: CiroColors.severityLow.withAlpha(25)),
            ),
            child: Row(
              children: [
                Icon(Icons.bolt_rounded, color: CiroColors.severityLow, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Agents saved $saved minutes of response time',
                    style: ts.bodySmall.copyWith(
                      color: CiroColors.severityLow,
                      fontWeight: FontWeight.w600,
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
                Text(
                  'TICKET:',
                  style: ts.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: colors.onSurface.withAlpha(120),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ticket['ticket_id'] ?? 'N/A',
                    style: ts.mono.copyWith(
                      fontSize: 12,
                      color: CiroColors.aiAccent,
                    ),
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
  const _SimCol({
    required this.label,
    required this.eta,
    required this.congestion,
    required this.isPositive,
    required this.colors,
    required this.ts,
  });
  final String label;
  final int eta;
  final String? congestion;
  final bool isPositive;
  final CiroColorScheme colors;
  final CiroTextStyleSet ts;

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? CiroColors.severityLow : CiroColors.severityCritical;
    return Column(
      children: [
        Text(
          label,
          style: ts.caption.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
            fontSize: 10,
            color: color.withAlpha(180),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$eta mins',
          style: ts.display.copyWith(color: color, fontSize: 24),
        ),
        Text(
          congestion?.toUpperCase() ?? 'NONE',
          style: ts.caption.copyWith(
            color: color.withAlpha(150),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ACTION PLAN — Glass cards with priority color strips
// ═══════════════════════════════════════════════════════════════════════════

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
          Row(
            children: [
              Icon(Icons.task_alt_rounded, size: 18, color: CiroColors.severityLow),
              const SizedBox(width: 8),
              Text('Response Actions', style: ts.titleMedium),
            ],
          ),
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
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(CiroTheme.chipRadius),
        border: Border.all(color: CiroColors.glassBorder),
        gradient: CiroColors.cardGradient,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Priority color strip
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
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
                        Text(
                          action['action_type']?.toString().toUpperCase() ?? 'ACTION',
                          style: ts.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: priorityColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: priorityColor.withAlpha(15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: priorityColor.withAlpha(30)),
                          ),
                          child: Text(
                            priority.toUpperCase(),
                            style: ts.caption.copyWith(
                              color: priorityColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      action['description'] ?? '',
                      style: ts.bodySmall.copyWith(
                        color: colors.onBackground,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Assigned to: ${action['assigned_to'] ?? 'Unknown'}',
                      style: ts.caption.copyWith(
                        color: colors.onSurface.withAlpha(100),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ALERTS DISPATCHED
// ═══════════════════════════════════════════════════════════════════════════

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
          Row(
            children: [
              Icon(Icons.campaign_rounded, size: 18, color: CiroColors.severityHigh),
              const SizedBox(width: 8),
              Text('Alerts Dispatched', style: ts.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          ...alerts!.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: CiroColors.severityHigh.withAlpha(8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: CiroColors.severityHigh.withAlpha(20)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.notifications_active_rounded,
                          size: 16, color: CiroColors.severityHigh.withAlpha(180)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          a.toString(),
                          style: ts.bodySmall.copyWith(
                            color: colors.onBackground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TIMELINE ITEM — Agent trace with colored nodes and glow
// ═══════════════════════════════════════════════════════════════════════════

class _TraceTimelineItem extends StatelessWidget {
  const _TraceTimelineItem({
    required this.entry,
    required this.isLast,
    required this.colors,
    required this.ts,
  });
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
    final agentColor = _getAgentColor(agent);
    final timeStr = _formatTime(entry['timestamp']);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Timeline rail ──────────────────────────────────────
            Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: agentColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: agentColor.withAlpha(100),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            agentColor.withAlpha(60),
                            agentColor.withAlpha(15),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 18),

            // ── Content card ───────────────────────────────────────
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(CiroTheme.chipRadius),
                  border: Border.all(color: agentColor.withAlpha(25)),
                  gradient: CiroColors.cardGradient,
                ),
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
                              color: agentColor,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeStr,
                          style: ts.mono.copyWith(
                            fontSize: 10,
                            color: colors.onSurface.withAlpha(100),
                          ),
                        ),
                      ],
                    ),
                    if (entry['confidence'] != null) ...[
                      const SizedBox(height: 8),
                      // Confidence bar
                      Row(
                        children: [
                          Text(
                            'Confidence: ${entry['confidence']}%',
                            style: ts.caption.copyWith(
                              color: CiroColors.aiAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: SizedBox(
                                height: 3,
                                child: LinearProgressIndicator(
                                  value: (entry['confidence'] as num) / 100,
                                  backgroundColor: colors.surfaceVariant,
                                  valueColor: AlwaysStoppedAnimation(CiroColors.aiAccent),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),
                    Text(
                      entry['decision'] ?? '',
                      style: ts.bodySmall.copyWith(
                        color: colors.onBackground,
                        height: 1.5,
                      ),
                    ),
                    if (entry['input_summary'] != null) ...[
                      const SizedBox(height: 12),
                      _TraceMeta(
                        label: 'INPUT',
                        value: entry['input_summary'],
                        colors: colors,
                        ts: ts,
                      ),
                    ],
                    if (entry['output_summary'] != null) ...[
                      const SizedBox(height: 6),
                      _TraceMeta(
                        label: 'OUTPUT',
                        value: entry['output_summary'],
                        colors: colors,
                        ts: ts,
                      ),
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

  Color _getAgentColor(String agent) {
    switch (agent) {
      case 'Orchestrator':
        return const Color(0xFF4DA3FF);    // Blue
      case 'SignalCollector':
        return const Color(0xFFB26BFF);    // Purple
      case 'CrisisDetector':
        return const Color(0xFFFF4D5E);    // Red
      case 'ReasoningAnalyzer':
        return const Color(0xFFFFC857);    // Amber
      case 'ActionPlanner':
        return const Color(0xFF3DDC97);    // Green
      case 'Simulator':
        return const Color(0xFF2DD4BF);    // Teal
      default:
        return const Color(0xFF9AA4B2);    // Muted
    }
  }
}

class _TraceMeta extends StatelessWidget {
  const _TraceMeta({
    required this.label,
    required this.value,
    required this.colors,
    required this.ts,
  });
  final String label;
  final String value;
  final CiroColorScheme colors;
  final CiroTextStyleSet ts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.background.withAlpha(100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: ts.caption.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: colors.onSurface.withAlpha(100),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: ts.bodySmall.copyWith(
              fontSize: 12,
              color: colors.onSurface.withAlpha(180),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
