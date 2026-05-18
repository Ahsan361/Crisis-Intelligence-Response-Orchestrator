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

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = CiroColors.of(context);
    final ts = CiroTextStyles.of(context);
    final alertsAsync = ref.watch(allAlertsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return alertsAsync.when(
      data: (alerts) => _buildMapContent(context, ref, alerts, colors, ts, isDark),
      loading: () => Stack(
        children: [
          _buildMapBase(const []),
          Container(
            color: colors.background.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
      error: (err, stack) => Stack(
        children: [
          _buildMapBase(const []),
          Container(
            color: colors.background.withOpacity(0.8),
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
                  const SizedBox(height: 16),
                  Text('Failed to load active reports', style: ts.title),
                  const SizedBox(height: 8),
                  Text(err.toString(), style: ts.bodySmall, textAlign: TextAlign.center),
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
        initialCenter: LatLng(33.6938, 73.0479), // Islamabad Center
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
    // Generate markers
    final markers = alerts.map((alert) {
      double lat = alert.locationLat ?? 33.6938;
      double lng = alert.locationLng ?? 73.0479;

      // Handle placeholder coordinate jittering to prevent overlapping
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
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: severityColor.withOpacity(0.6),
              blurRadius: 8,
              spreadRadius: 2,
            )
          ],
        ),
      );

      if (isCritical) {
        markerIcon = markerIcon
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.2, 1.2),
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
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Crisis Map', style: ts.title),
            Text(
              '${alerts.length} active reports',
              style: ts.labelTiny.copyWith(color: colors.onSurface),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: colors.onSurface,
              size: 22,
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

          // Severity Legend (Bottom Left Corner)
          Positioned(
            bottom: 24,
            left: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colors.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.divider),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SEVERITY LEGEND',
                    style: ts.bodySmall.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 1.1,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _LegendItem(color: CiroColors.severityCritical, label: 'Critical', ts: ts),
                  const SizedBox(height: 6),
                  _LegendItem(color: CiroColors.severityHigh, label: 'High', ts: ts),
                  const SizedBox(height: 6),
                  _LegendItem(color: CiroColors.severityMedium, label: 'Medium', ts: ts),
                  const SizedBox(height: 6),
                  _LegendItem(color: CiroColors.severityLow, label: 'Low', ts: ts),
                ],
              ),
            ),
          ),

          // Empty state overlay
          if (alerts.isEmpty)
            IgnorePointer(
              child: Container(
                color: colors.background.withOpacity(0.4),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: colors.surface.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.divider),
                    ),
                    child: Text(
                      'No active crisis reports',
                      style: ts.body.copyWith(fontWeight: FontWeight.bold),
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
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: ts.bodySmall.copyWith(
            color: colors.onBackground,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
