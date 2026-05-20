import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../models/crisis_alert.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/severity_badge.dart';
import '../widgets/glow_button.dart';

class CrisisMapScreen extends ConsumerStatefulWidget {
  final CrisisAlert alert;

  const CrisisMapScreen({super.key, required this.alert});

  @override
  ConsumerState<CrisisMapScreen> createState() => _CrisisMapScreenState();
}

class _CrisisMapScreenState extends ConsumerState<CrisisMapScreen> {
  List<LatLng> blockedRoute = [];
  List<LatLng> alternateRoute = [];
  bool isLoadingRoutes = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRoutes();
    });
  }

  Future<void> _loadRoutes() async {
    final startLat = widget.alert.locationLat ?? 33.6844;
    final startLng = widget.alert.locationLng ?? 73.0479;

    final sim = widget.alert.simulationResult;
    final destination = sim?['destination'] as Map?;
    final destLat =
        (destination?['lat'] as num?)?.toDouble() ?? (startLat + 0.015);
    final destLng =
        (destination?['lng'] as num?)?.toDouble() ?? (startLng + 0.015);

    try {
      final routingService = ref.read(routingServiceProvider);

      final blocked = await routingService.getRoute(
        startLat: startLat,
        startLng: startLng,
        endLat: destLat,
        endLng: destLng,
      );

      final alternate = await routingService.getRoute(
        startLat: startLat + 0.0015,
        startLng: startLng + 0.0015,
        endLat: destLat,
        endLng: destLng,
      );

      if (mounted) {
        setState(() {
          blockedRoute = blocked;
          alternateRoute = alternate;
          isLoadingRoutes = false;
        });
      }
    } catch (e) {
      debugPrint('Routing failed: $e. Using straight line fallbacks.');
      if (mounted) {
        setState(() {
          blockedRoute = [LatLng(startLat, startLng), LatLng(destLat, destLng)];
          alternateRoute = [
            LatLng(startLat, startLng),
            LatLng((startLat + destLat) / 2 + 0.003,
                (startLng + destLng) / 2 - 0.003),
            LatLng(destLat, destLng),
          ];
          isLoadingRoutes = false;
        });
      }
    }
  }

  IconData _getTypeIconData(String type) {
    switch (type.toLowerCase()) {
      case 'flood':
        return Icons.water_rounded;
      case 'accident':
        return Icons.car_crash_rounded;
      case 'heatwave':
        return Icons.wb_sunny_rounded;
      case 'blockage':
        return Icons.traffic_rounded;
      case 'infrastructure':
        return Icons.engineering_rounded;
      default:
        return Icons.emergency_rounded;
    }
  }

  IconData _getDestinationIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('hospital') ||
        lowerName.contains('clinic') ||
        lowerName.contains('pims')) {
      return Icons.local_hospital_rounded;
    } else if (lowerName.contains('police') || lowerName.contains('traffic')) {
      return Icons.local_police_rounded;
    } else if (lowerName.contains('cda') || lowerName.contains('engineering')) {
      return Icons.engineering_rounded;
    } else {
      return Icons.health_and_safety_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CiroColors.of(context);
    final ts = CiroTextStyles.of(context);

    final startLat = widget.alert.locationLat ?? 33.6844;
    final startLng = widget.alert.locationLng ?? 73.0479;

    final sim = widget.alert.simulationResult;
    final before = sim?['before_route'] as Map?;
    final after = sim?['after_route'] as Map?;
    final destination = sim?['destination'] as Map?;

    final int beforeEta = before?['eta_minutes'] ?? 28;
    final String beforeCongestion = before?['congestion_level'] ?? 'Heavy';
    final int afterEta = after?['eta_minutes'] ?? 14;
    final String afterCongestion = after?['congestion_level'] ?? 'Moderate';
    final String destName = destination?['name'] ?? 'Rescue 1122 HQ';
    final double destLat =
        (destination?['lat'] as num?)?.toDouble() ?? (startLat + 0.015);
    final double destLng =
        (destination?['lng'] as num?)?.toDouble() ?? (startLng + 0.015);
    final int saved = beforeEta - afterEta;

    final centerLat = (startLat + destLat) / 2;
    final centerLng = (startLng + destLng) / 2;

    final severityColor = CiroColors.forSeverity(widget.alert.severity?.value ?? 'medium');

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
            Text(widget.alert.areaName ?? 'Crisis Detail', style: ts.title),
            Text(
              widget.alert.crisisType?.displayName ?? 'Emergency Alert',
              style: ts.caption.copyWith(
                color: colors.onSurface.withAlpha(120),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // ── Map ──────────────────────────────────────────────────────
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(centerLat, centerLng),
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ciro.app',
              ),
              if (!isLoadingRoutes) ...[
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: blockedRoute,
                      strokeWidth: 4.5,
                      color: CiroColors.severityCritical,
                    ),
                    Polyline(
                      points: alternateRoute,
                      strokeWidth: 4.5,
                      color: CiroColors.severityLow,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(startLat, startLng),
                      width: 50,
                      height: 50,
                      child: Icon(
                        Icons.location_on_rounded,
                        color: severityColor,
                        size: 44,
                      ),
                    ),
                    Marker(
                      point: LatLng(destLat, destLng),
                      width: 50,
                      height: 50,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withAlpha(100),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          _getDestinationIcon(destName),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),

          // ── Loading overlay ──────────────────────────────────────────
          if (isLoadingRoutes)
            Container(
              color: colors.background.withAlpha(150),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(CiroTheme.cardRadius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                      decoration: BoxDecoration(
                        color: colors.surface.withAlpha(220),
                        borderRadius: BorderRadius.circular(CiroTheme.cardRadius),
                        border: Border.all(color: CiroColors.glassBorder),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: colors.primary, strokeWidth: 2.5),
                          const SizedBox(height: 16),
                          Text('Calculating routes...', style: ts.body),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Premium bottom detail sheet ───────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surface.withAlpha(240),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    border: Border.all(color: CiroColors.glassBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(80),
                        blurRadius: 24,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Drag handle ─────────────────────────────────
                        const SizedBox(height: 10),
                        Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colors.onSurface.withAlpha(60),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Header ──────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: severityColor.withAlpha(15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  _getTypeIconData(
                                      widget.alert.crisisType?.value ?? 'unknown'),
                                  color: severityColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.alert.areaName ?? 'Islamabad',
                                      style: ts.title.copyWith(fontSize: 18),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Dest: $destName',
                                      style: ts.caption.copyWith(
                                        color: colors.onSurface.withAlpha(120),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              SeverityBadge(
                                  severity: widget.alert.severity?.value ?? 'medium'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Route comparison ────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              Expanded(
                                child: _RouteCard(
                                  label: 'BLOCKED',
                                  eta: beforeEta,
                                  congestion: beforeCongestion,
                                  color: CiroColors.severityCritical,
                                  colors: colors,
                                  ts: ts,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _RouteCard(
                                  label: 'OPTIMIZED',
                                  eta: afterEta,
                                  congestion: afterCongestion,
                                  color: CiroColors.severityLow,
                                  colors: colors,
                                  ts: ts,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── Savings banner ──────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                            decoration: BoxDecoration(
                              color: CiroColors.severityLow.withAlpha(12),
                              borderRadius: BorderRadius.circular(CiroTheme.chipRadius),
                              border: Border.all(
                                color: CiroColors.severityLow.withAlpha(30),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.bolt_rounded,
                                    color: CiroColors.severityLow, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'CIRO saved $saved mins in response time',
                                    style: ts.bodySmall.copyWith(
                                      color: CiroColors.severityLow,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Action button ───────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: GlowButton(
                            label: 'View Full Trace',
                            icon: Icons.timeline_rounded,
                            onPressed: () {
                              final traceResult = {
                                'report_id': widget.alert.id,
                                'crisis_type': widget.alert.crisisType?.value,
                                'severity': widget.alert.severity?.value,
                                'crisis_confidence': widget.alert.crisisConfidence,
                                'detected_language': widget.alert.detectedLanguage,
                                'normalized_location': widget.alert.areaName,
                                'action_plan': widget.alert.agentTrace ?? [],
                                'simulation_result':
                                    widget.alert.simulationResult ?? {},
                                'trace': widget.alert.agentTrace ?? [],
                              };
                              context.pushNamed('trace', extra: traceResult);
                            },
                            gradient: CiroColors.reportButtonGradient,
                            glowColor: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
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

class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.label,
    required this.eta,
    required this.congestion,
    required this.color,
    required this.colors,
    required this.ts,
  });

  final String label;
  final int eta;
  final String congestion;
  final Color color;
  final CiroColorScheme colors;
  final CiroTextStyleSet ts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(8),
        borderRadius: BorderRadius.circular(CiroTheme.chipRadius),
        border: Border.all(color: color.withAlpha(25)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: ts.caption.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              fontSize: 10,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$eta min',
            style: ts.display.copyWith(fontSize: 22, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            congestion,
            style: ts.caption.copyWith(
              color: color.withAlpha(180),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
