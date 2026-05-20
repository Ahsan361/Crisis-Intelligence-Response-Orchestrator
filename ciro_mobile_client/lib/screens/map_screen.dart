import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../models/crisis_alert.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_pulse.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = CiroColors.of(context);
    final ts = CiroTextStyles.of(context);
    final alertsAsync = ref.watch(allAlertsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return alertsAsync.when(
      data: (alerts) =>
          _buildMapContent(context, ref, alerts, colors, ts, isDark),
      loading: () => Stack(
        children: [
          _buildMapBase(const []),
          Container(
            color: colors.background.withAlpha(128),
            child: Center(
              child: CircularProgressIndicator(color: colors.primary),
            ),
          ),
        ],
      ),
      error: (err, stack) => Stack(
        children: [
          _buildMapBase(const []),
          Container(
            color: colors.background.withAlpha(200),
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 48, color: colors.error),
                  const SizedBox(height: 16),
                  Text('Failed to load active reports', style: ts.title),
                  const SizedBox(height: 8),
                  Text(err.toString(),
                      style: ts.bodySmall, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(allAlertsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapBase(List<Marker> markers) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(33.6938, 73.0479),
        initialZoom: 12,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.ciro.app',
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }

  Widget _buildMapContent(
    BuildContext context,
    WidgetRef ref,
    List<CrisisAlert> alerts,
    CiroColorScheme colors,
    CiroTextStyleSet ts,
    bool isDark,
  ) {
    // Generate markers with glow effects
    final markers = alerts.map((alert) {
      double lat = alert.locationLat ?? 33.6938;
      double lng = alert.locationLng ?? 73.0479;

      if (lat == 33.6844 && lng == 73.0479) {
        final hash = alert.id.hashCode;
        lat += ((hash % 10) - 5) * 0.0015;
        lng += (((hash ~/ 10) % 10) - 5) * 0.0015;
      }

      final severityStr = alert.severity?.value ?? 'medium';
      final severityColor = CiroColors.forSeverity(severityStr);

      double circleSize = 14;
      bool isCritical = false;

      if (severityStr.toLowerCase() == 'critical') {
        circleSize = 20;
        isCritical = true;
      } else if (severityStr.toLowerCase() == 'high') {
        circleSize = 16;
      } else if (severityStr.toLowerCase() == 'medium') {
        circleSize = 14;
      } else if (severityStr.toLowerCase() == 'low') {
        circleSize = 12;
      }

      Widget markerIcon = Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          color: severityColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withAlpha(200), width: 2),
          boxShadow: [
            BoxShadow(
              color: severityColor.withAlpha(150),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
      );

      if (isCritical) {
        markerIcon = markerIcon
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.3, 1.3),
              duration: 1000.ms,
              curve: Curves.easeInOut,
            );
      }

      return Marker(
        point: LatLng(lat, lng),
        width: 48,
        height: 48,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            context.pushNamed('crisisMap', extra: alert);
          },
          child: Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: Center(child: markerIcon),
            ),
          ),
        ),
      );
    }).toList();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Crisis Map', style: ts.title),
            Text(
              '${alerts.length} active reports',
              style: ts.caption.copyWith(
                color: colors.onSurface.withAlpha(170),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: colors.onSurface,
              size: 20,
            ),
            tooltip: isDark ? 'Light theme' : 'Dark theme',
            onPressed: () {
              ref.read(themeModeProvider.notifier).setTheme(
                    isDark ? ThemeMode.light : ThemeMode.dark,
                  );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildMapBase(markers),

          // ── Premium glass severity legend ─────────────────────────
          Positioned(
            bottom: 24,
            left: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: colors.surface.withAlpha(220),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: CiroColors.glassBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(50),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'SEVERITY',
                        style: ts.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          letterSpacing: 1.5,
                          color: colors.primary.withAlpha(180),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _LegendItem(
                          color: CiroColors.severityCritical,
                          label: 'Critical',
                          ts: ts),
                      const SizedBox(height: 7),
                      _LegendItem(
                          color: CiroColors.severityHigh,
                          label: 'High',
                          ts: ts),
                      const SizedBox(height: 7),
                      _LegendItem(
                          color: CiroColors.severityMedium,
                          label: 'Medium',
                          ts: ts),
                      const SizedBox(height: 7),
                      _LegendItem(
                          color: CiroColors.severityLow, label: 'Low', ts: ts),
                    ],
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0, delay: 300.ms),
          ),

          // ── Stats overlay (top right) ────────────────────────────
          Positioned(
            top: 16,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(CiroTheme.chipRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.surface.withAlpha(200),
                    borderRadius: BorderRadius.circular(CiroTheme.chipRadius),
                    border: Border.all(color: CiroColors.glassBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedPulse(
                        color:
                            alerts.any((a) => a.severity?.value == 'critical')
                                ? CiroColors.severityCritical
                                : CiroColors.statusOperational,
                        size: 8,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'LIVE',
                        style: ts.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          fontSize: 10,
                          color: colors.onBackground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
          ),

          // ── Empty state ──────────────────────────────────────────
          if (alerts.isEmpty)
            IgnorePointer(
              child: Container(
                color: colors.background.withAlpha(100),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(CiroTheme.cardRadius),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 24),
                        decoration: BoxDecoration(
                          color: colors.surface.withAlpha(220),
                          borderRadius:
                              BorderRadius.circular(CiroTheme.cardRadius),
                          border: Border.all(color: CiroColors.glassBorder),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline_rounded,
                                size: 40,
                                color: CiroColors.severityLow.withAlpha(120)),
                            const SizedBox(height: 12),
                            Text(
                              'No active crisis reports',
                              style:
                                  ts.body.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final CiroTextStyleSet ts;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.ts,
  });

  @override
  Widget build(BuildContext context) {
    final colors = CiroColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(80),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: ts.bodySmall.copyWith(
            color: colors.onBackground,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
