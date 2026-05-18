import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/crisis_alert.dart';
import '../providers/app_providers.dart';
import '../router/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';


// ═══════════════════════════════════════════════════════════════════════════
// REPORT SCREEN STATE ENUM
// ═══════════════════════════════════════════════════════════════════════════

enum ReportScreenState { idle, submitting, analyzing, complete, error }

// ═══════════════════════════════════════════════════════════════════════════
// REPORT SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _reportTextController = TextEditingController();
  final _areaNameController = TextEditingController();
  final _reportedByController = TextEditingController();
  ReportSource _selectedSource = ReportSource.manual;

  // Location State
  double _locationLat = 33.6844;
  double _locationLng = 73.0479;
  bool _locationSet = false;

  // Screen State
  ReportScreenState _state = ReportScreenState.idle;
  int _activeStepIndex = -1; // -1 to 4
  Timer? _visualTimer;
  bool _isFetchingAddress = false;

  @override
  void dispose() {
    _reportTextController.dispose();
    _areaNameController.dispose();
    _reportedByController.dispose();
    _visualTimer?.cancel();
    super.dispose();
  }

  // ── Logic ───────────────────────────────────────────────────────────────

  Future<void> _submitAndAnalyze() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _state = ReportScreenState.submitting);

    try {
      // 1. Submit Report
      final repo = ref.read(alertsRepositoryProvider);

      final newReport = CrisisAlert(
        id: 'placeholder-uuid',
        reportText: _reportTextController.text,
        source: _selectedSource,
        status: ReportStatus.pending,
        areaName: _areaNameController.text,
        reportedBy: _reportedByController.text.isEmpty
            ? null
            : _reportedByController.text,
        locationLat: _locationLat,
        locationLng: _locationLng,
        createdAt: DateTime.now(),
      );

      final createdReport = await repo.createAlert(newReport);

      // 2. Start Analysis Pipeline
      setState(() {
        _state = ReportScreenState.analyzing;
        _activeStepIndex = 0; // Step 0 (Signal Collector) active immediately
      });

      // Start visual auto-progression (capped at Step 3)
      _startVisualProgression();

      // FIX 3: analyze() returns void. We await it, then read the state.
      await ref.read(analyzeAlertProvider.notifier).analyze(
            reportId: createdReport.id,
            reportText: createdReport.reportText,
            areaName: createdReport.areaName ?? '',
            locationLat: _locationLat,
            locationLng: _locationLng,
          );

      // Read result from the provider state
      final analysisState = ref.read(analyzeAlertProvider);
      final resultData = analysisState.value;

      // 3. Pipeline Success Logic
      _onPipelineBackendResponse(resultData);
    } catch (e) {
      if (mounted) {
        setState(() => _state = ReportScreenState.error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pipeline failed: $e')),
        );
        setState(() => _state = ReportScreenState.idle);
      }
    }
  }

  void _startVisualProgression() {
    _visualTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      if (_activeStepIndex < 3) {
        setState(() => _activeStepIndex++);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _fetchAreaName(double lat, double lng) async {
    setState(() => _isFetchingAddress = true);
    try {
      final dio = ref.read(apiServiceProvider).client;
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': lat,
          'lon': lng,
          'zoom': 18,
          'addressdetails': 1,
        },
        options: Options(
          headers: {'User-Agent': 'CIRO-Mobile-App'},
        ),
      );

      if (response.data != null) {
        final addr = response.data['address'] ?? {};
        // Hierarchy: neighbourhood -> suburb -> city_district -> fallback
        String? name = addr['neighbourhood'] ??
            addr['suburb'] ??
            addr['city_district'] ??
            addr['village'] ??
            addr['town'];

        if (name == null) {
          final displayName = response.data['display_name'] as String?;
          if (displayName != null) {
            name = displayName.split(',').first;
          }
        }

        if (name != null && mounted) {
          _areaNameController.text = name;
        }
      }
    } catch (e) {
      debugPrint('Reverse geocoding failed: $e');
    } finally {
      if (mounted) setState(() => _isFetchingAddress = false);
    }
  }

  void _onPipelineBackendResponse(Map<String, dynamic>? result) {
    _visualTimer?.cancel();

    setState(() {
      _activeStepIndex = 4;
      _state = ReportScreenState.complete;
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        context.pushNamed(
          CiroRoutes.traceName,
          extra: result,
        );
      }
    });
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = CiroColors.of(context);
    // FIX 2: CiroTextStyleSet is the correct type from app_text_styles.dart
    final CiroTextStyleSet ts = CiroTextStyles.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Report', style: ts.title),
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => context.pop(),
              )
            : null,
        automaticallyImplyLeading: false,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _state == ReportScreenState.analyzing ||
                _state == ReportScreenState.complete
            ? _PipelineProgressView(
                stepIndex: _activeStepIndex,
                isComplete: _state == ReportScreenState.complete,
              )
            : _buildForm(colors, ts),
      ),
    );
  }

  Widget _buildForm(CiroColorScheme colors, CiroTextStyleSet ts) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Report Details', style: ts.headline),
            const SizedBox(height: 8),
            Text(
              'Provide accurate information to help agents analyze the situation.',
              style: ts.bodySmall
                  .copyWith(color: colors.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 24),
            _buildFieldLabel('CRISIS DESCRIPTION', ts, colors),
            const SizedBox(height: 8),
            TextFormField(
              controller: _reportTextController,
              maxLines: 5,
              minLines: 4,
              maxLength: 500,
              style: ts.body,
              decoration: _inputDecoration(
                'Describe the crisis... (English, Urdu, or Roman Urdu)',
                colors,
              ),
              validator: (v) {
                if (v == null || v.length < 10)
                  return 'Min 10 characters required';
                return null;
              },
            ),
            const SizedBox(height: 24),
            _buildFieldLabel('AREA / LOCATION', ts, colors),
            const SizedBox(height: 8),
            TextFormField(
              controller: _areaNameController,
              style: ts.body,
              decoration: _inputDecoration(
                'e.g. G-10 Markaz, Blue Area, F-7',
                colors,
              ).copyWith(
                suffixIcon: _isFetchingAddress
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Area name is required';
                return null;
              },
            ),
            const SizedBox(height: 24),
            _buildFieldLabel('INCIDENT LOCATION', ts, colors),
            const SizedBox(height: 8),
            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.divider),
              ),
              clipBehavior: Clip.antiAlias,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: const LatLng(33.6844, 73.0479),
                  initialZoom: 13,
                  onTap: (tapPosition, point) {
                    setState(() {
                      _locationLat = point.latitude;
                      _locationLng = point.longitude;
                      _locationSet = true;
                    });
                    _fetchAreaName(point.latitude, point.longitude);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.ciro.app',
                  ),
                  if (_locationSet)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(_locationLat, _locationLng),
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.location_on_rounded,
                            color: colors.error,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _locationSet
                  ? '📍 ${_locationLat.toStringAsFixed(4)}, ${_locationLng.toStringAsFixed(4)}'
                  : '📍 Tap map to set location',
              style: ts.mono.copyWith(
                fontSize: 10,
                color: _locationSet ? colors.primary : colors.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            _buildFieldLabel('REPORT SOURCE', ts, colors),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ReportSource.values.map((s) {
                final isSelected = _selectedSource == s;
                return ChoiceChip(
                  label: Text(s.displayName),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedSource = s);
                  },
                  selectedColor: colors.primary.withValues(alpha: 0.2),
                  labelStyle: ts.bodySmall.copyWith(
                    color: isSelected ? colors.primary : colors.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _buildFieldLabel('REPORTER (OPTIONAL)', ts, colors),
            const SizedBox(height: 8),
            TextFormField(
              controller: _reportedByController,
              style: ts.body,
              decoration:
                  _inputDecoration('Your name or source identifier', colors),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _state == ReportScreenState.submitting
                    ? null
                    : _submitAndAnalyze,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  shadowColor: colors.primary.withValues(alpha: 0.4),
                ),
                child: _state == ReportScreenState.submitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Submit & Analyze',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(
      String label, CiroTextStyleSet ts, CiroColorScheme colors) {
    return Text(
      label,
      style: ts.bodySmall.copyWith(
        fontSize: 11,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
        color: colors.primary,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, CiroColorScheme colors) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: colors.onSurface.withValues(alpha: 0.3)),
      filled: true,
      fillColor: colors.surfaceVariant.withValues(alpha: 0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PIPELINE PROGRESS VIEW
// ═══════════════════════════════════════════════════════════════════════════

class _PipelineProgressView extends StatelessWidget {
  const _PipelineProgressView({
    required this.stepIndex,
    required this.isComplete,
  });

  final int stepIndex;
  final bool isComplete;

  static const _steps = [
    'Signal Collector',
    'Crisis Detector',
    'Reasoning Analyzer',
    'Action Planner',
    'Simulator',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = CiroColors.of(context);
    final ts = CiroTextStyles.of(context);
    final progress = isComplete ? 1.0 : (stepIndex + 0.5) / _steps.length;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isComplete ? 'Analysis Complete' : 'AI Agents Running',
              style: ts.headline,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isComplete
                  ? 'The pipeline has finished processing. Redirecting...'
                  : 'Orchestrating multi-agent reasoning for the reported crisis.',
              style: ts.bodySmall
                  .copyWith(color: colors.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Stack(
              children: [
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  height: 6,
                  width: MediaQuery.of(context).size.width * 0.8 * progress,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Column(
              children: List.generate(_steps.length, (i) {
                final isDone = i < stepIndex || isComplete;
                final isActive = i == stepIndex && !isComplete;

                return _StepItem(
                  label: _steps[i],
                  isDone: isDone,
                  isActive: isActive,
                  colors: colors,
                  ts: ts,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.label,
    required this.isDone,
    required this.isActive,
    required this.colors,
    required this.ts,
  });

  final String label;
  final bool isDone;
  final bool isActive;
  final CiroColorScheme colors;
  final CiroTextStyleSet ts;

  @override
  Widget build(BuildContext context) {
    Color iconColor = colors.onSurface.withValues(alpha: 0.2);
    Widget icon = Icon(Icons.circle_outlined, size: 20, color: iconColor);

    if (isDone) {
      iconColor = Colors.greenAccent[700]!;
      icon = Icon(Icons.check_circle_rounded, size: 20, color: iconColor);
    } else if (isActive) {
      iconColor = colors.primary;
      icon = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, value: null),
      )
          .animate(onPlay: (c) => c.repeat())
          .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.1, 1.1),
            duration: 800.ms,
            curve: Curves.easeInOut,
          )
          .then()
          .scale(
            begin: const Offset(1.1, 1.1),
            end: const Offset(0.8, 0.8),
            duration: 800.ms,
            curve: Curves.easeInOut,
          );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              label,
              style: ts.body.copyWith(
                color: isActive || isDone
                    ? colors.onSurface
                    : colors.onSurface.withValues(alpha: 0.3),
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (isActive)
            Text(
              'ACTIVE',
              style: ts.bodySmall.copyWith(
                color: colors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .fadeIn(duration: 500.ms)
                .then()
                .fadeOut(duration: 500.ms),
        ],
      ),
    );
  }
}
