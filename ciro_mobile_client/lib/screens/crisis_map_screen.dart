import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../models/crisis_alert.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/severity_badge.dart';

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

      // Call ORS directions API for direct (blocked) route
      final blocked = await routingService.getRoute(
        startLat: startLat,
        startLng: startLng,
        endLat: destLat,
        endLng: destLng,
      );

      // Call ORS directions API for detour (alternate) route
      // Use slightly offset start to force a visually distinct detour route
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

    // Coordinate defaults
    final startLat = widget.alert.locationLat ?? 33.6844;
    final startLng = widget.alert.locationLng ?? 73.0479;

    // Simulation mapping details
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

    return Scaffold(
      appBar: AppBar(
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
              style: ts.labelTiny.copyWith(color: colors.onSurface),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Detailed Map View
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
                    // Red direct blocked route
                    Polyline(
                      points: blockedRoute,
                      strokeWidth: 4.5,
                      color: colors.error,
                    ),
                    // Green alternate bypass route
                    Polyline(
                      points: alternateRoute,
                      strokeWidth: 4.5,
                      color: colors.secondary,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    // Crisis Incident Pin
                    Marker(
                      point: LatLng(startLat, startLng),
                      width: 50,
                      height: 50,
                      child: Icon(
                        Icons.location_on_rounded,
                        color: CiroColors.forSeverity(
                            widget.alert.severity?.value ?? 'medium'),
                        size: 44,
                      ),
                    ),
                    // Response Destination Pin
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
                              color: colors.primary.withValues(alpha: 0.4),
                              blurRadius: 8,
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

          // Loading Overlays
          if (isLoadingRoutes)
            Container(
              color: colors.background.withValues(alpha: 0.6),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.divider),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text('Calculating routes...', style: ts.body),
                    ],
                  ),
                ),
              ),
            ),

          // Premium bottom sheet detail overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: colors.divider),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Bottom Sheet Drag Indicator
                  const SizedBox(height: 8),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.onSurface.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Header section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(
                          _getTypeIconData(
                              widget.alert.crisisType?.value ?? 'unknown'),
                          color: colors.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.alert.areaName ?? 'Islamabad',
                                style: ts.titleMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Destination: $destName',
                                style: ts.bodySmall
                                    .copyWith(color: colors.onSurface),
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
                  const SizedBox(height: 12),
                  const Divider(height: 1),

                  // Route times & stats
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Blocked route ETA
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: colors.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'BLOCKED ROUTE:',
                                style: ts.bodySmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$beforeEta mins — $beforeCongestion congestion',
                                  style: ts.bodySmall
                                      .copyWith(color: colors.error),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Alternate route ETA
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: colors.secondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'ALTERNATE DETOUR:',
                                style: ts.bodySmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$afterEta mins — $afterCongestion congestion',
                                  style: ts.bodySmall
                                      .copyWith(color: colors.secondary),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Savings Banner
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              color: colors.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  color: colors.secondary,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'CIRO saved $saved minutes in responder dispatch time.',
                                    style: ts.bodySmall.copyWith(
                                      color: colors.secondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Actions
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // Build trace extra model to go back to detailed reasoning trace
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
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.timeline_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'View Full Trace',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
