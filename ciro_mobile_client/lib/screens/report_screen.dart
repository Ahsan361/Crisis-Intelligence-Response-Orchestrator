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
import '../theme/app_theme.dart';
import '../widgets/glow_button.dart';
import '../widgets/animated_pulse.dart';

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
  int _activeStepIndex = -1;
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

      setState(() {
        _state = ReportScreenState.analyzing;
        _activeStepIndex = 0;
      });

      _startVisualProgression();

      await ref.read(analyzeAlertProvider.notifier).analyze(
            reportId: createdReport.id,
            reportText: createdReport.reportText,
            areaName: createdReport.areaName ?? '',
            locationLat: _locationLat,
            locationLng: _locationLng,
          );

      final analysisState = ref.read(analyzeAlertProvider);
      final resultData = analysisState.value;

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
    final CiroTextStyleSet ts = CiroTextStyles.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
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
            // ── Header ─────────────────────────────────────────────────
            Text('Report Details', style: ts.headline.copyWith(fontSize: 22)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.smart_toy_rounded,
                    size: 14, color: CiroColors.aiAccent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'AI agents will analyze your report in real-time.',
                    style: ts.caption
                        .copyWith(color: CiroColors.aiAccent.withAlpha(180)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Crisis Description ─────────────────────────────────────
            _buildFieldLabel('CRISIS DESCRIPTION', ts, colors),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(CiroTheme.buttonRadius),
                border: Border.all(color: CiroColors.glassBorder),
                gradient: CiroColors.cardGradient,
              ),
              child: TextFormField(
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
            ),
            const SizedBox(height: 24),

            // ── Area / Location ────────────────────────────────────────
            _buildFieldLabel('AREA / LOCATION', ts, colors),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(CiroTheme.buttonRadius),
                border: Border.all(color: CiroColors.glassBorder),
                gradient: CiroColors.cardGradient,
              ),
              child: TextFormField(
                controller: _areaNameController,
                style: ts.body,
                decoration: _inputDecoration(
                  'e.g. G-10 Markaz, Blue Area, F-7',
                  colors,
                ).copyWith(
                  suffixIcon: _isFetchingAddress
                      ? const Padding(
                          padding: EdgeInsets.all(14),
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
            ),
            const SizedBox(height: 24),

            // ── Map ────────────────────────────────────────────────────
            _buildFieldLabel('INCIDENT LOCATION', ts, colors),
            const SizedBox(height: 10),
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(CiroTheme.cardRadius),
                border: Border.all(color: CiroColors.glassBorder),
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
                            color: CiroColors.severityCritical,
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
                color: _locationSet
                    ? colors.primary
                    : colors.onSurface.withAlpha(100),
              ),
            ),
            const SizedBox(height: 24),

            // ── Report Source ───────────────────────────────────────────
            _buildFieldLabel('REPORT SOURCE', ts, colors),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ReportSource.values.map((s) {
                final isSelected = _selectedSource == s;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSource = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.primary.withAlpha(20)
                          : colors.surfaceVariant.withAlpha(100),
                      borderRadius: BorderRadius.circular(CiroTheme.chipRadius),
                      border: Border.all(
                        color: isSelected
                            ? colors.primary.withAlpha(80)
                            : CiroColors.glassBorder,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      s.displayName,
                      style: ts.bodySmall.copyWith(
                        color: isSelected ? colors.primary : colors.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Reporter ───────────────────────────────────────────────
            _buildFieldLabel('REPORTER (OPTIONAL)', ts, colors),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(CiroTheme.buttonRadius),
                border: Border.all(color: CiroColors.glassBorder),
                gradient: CiroColors.cardGradient,
              ),
              child: TextFormField(
                controller: _reportedByController,
                style: ts.body,
                decoration:
                    _inputDecoration('Your name or source identifier', colors),
              ),
            ),
            const SizedBox(height: 40),

            // ── Submit Button ──────────────────────────────────────────
            GlowButton(
              label: 'Submit & Analyze',
              icon: Icons.rocket_launch_rounded,
              onPressed: _submitAndAnalyze,
              gradient: CiroColors.reportButtonGradient,
              glowColor: colors.primary,
              isLoading: _state == ReportScreenState.submitting,
              enabled: _state != ReportScreenState.submitting,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(
      String label, CiroTextStyleSet ts, CiroColorScheme colors) {
    return Text(
      label,
      style: ts.caption.copyWith(
        fontSize: 11,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w700,
        color: colors.primary.withAlpha(180),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, CiroColorScheme colors) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: colors.onSurface.withAlpha(150),
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.transparent,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CiroTheme.buttonRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CiroTheme.buttonRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CiroTheme.buttonRadius),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PIPELINE PROGRESS VIEW — Premium AI operations display
// ═══════════════════════════════════════════════════════════════════════════

class _PipelineProgressView extends StatelessWidget {
  const _PipelineProgressView({
    required this.stepIndex,
    required this.isComplete,
  });

  final int stepIndex;
  final bool isComplete;

  static const _steps = [
    (
      name: 'Signal Collector',
      icon: Icons.sensors_rounded,
      color: Color(0xFFB26BFF)
    ),
    (
      name: 'Crisis Detector',
      icon: Icons.emergency_rounded,
      color: Color(0xFFFF4D5E)
    ),
    (
      name: 'Reasoning Analyzer',
      icon: Icons.psychology_rounded,
      color: Color(0xFFFFC857)
    ),
    (
      name: 'Action Planner',
      icon: Icons.task_alt_rounded,
      color: Color(0xFF3DDC97)
    ),
    (name: 'Simulator', icon: Icons.speed_rounded, color: Color(0xFF4DA3FF)),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = CiroColors.of(context);
    final ts = CiroTextStyles.of(context);
    final progress = isComplete ? 1.0 : (stepIndex + 0.5) / _steps.length;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Header ─────────────────────────────────────────────────
            Icon(
              isComplete ? Icons.check_circle_rounded : Icons.smart_toy_rounded,
              size: 48,
              color: isComplete ? CiroColors.severityLow : CiroColors.aiAccent,
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
            const SizedBox(height: 20),
            Text(
              isComplete ? 'Analysis Complete' : 'AI Agents Running',
              style: ts.headline,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isComplete
                  ? 'Pipeline finished. Redirecting to trace view...'
                  : 'Orchestrating multi-agent reasoning',
              style: ts.bodySmall.copyWith(
                color: colors.onSurface.withAlpha(150),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // ── Progress Bar ───────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Stack(
                children: [
                  Container(
                    height: 4,
                    width: double.infinity,
                    color: colors.surfaceVariant,
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    height: 4,
                    width: MediaQuery.of(context).size.width * 0.75 * progress,
                    decoration: BoxDecoration(
                      gradient: CiroColors.reportButtonGradient,
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withAlpha(100),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // ── Agent Steps ────────────────────────────────────────────
            ...List.generate(_steps.length, (i) {
              final isDone = i < stepIndex || isComplete;
              final isActive = i == stepIndex && !isComplete;
              final step = _steps[i];

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isActive
                      ? step.color.withAlpha(10)
                      : colors.surfaceVariant.withAlpha(isDone ? 100 : 40),
                  borderRadius: BorderRadius.circular(CiroTheme.chipRadius),
                  border: Border.all(
                    color: isActive
                        ? step.color.withAlpha(40)
                        : CiroColors.glassBorder,
                  ),
                ),
                child: Row(
                  children: [
                    // Status indicator
                    if (isDone)
                      Icon(Icons.check_circle_rounded,
                          size: 20, color: step.color)
                    else if (isActive)
                      AnimatedPulse(color: step.color, size: 8)
                    else
                      Icon(Icons.circle_outlined,
                          size: 20, color: colors.onSurface.withAlpha(40)),
                    const SizedBox(width: 14),
                    Icon(step.icon,
                        size: 18,
                        color: isDone || isActive
                            ? step.color
                            : colors.onSurface.withAlpha(60)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        step.name,
                        style: ts.body.copyWith(
                          color: isDone || isActive
                              ? colors.onBackground
                              : colors.onSurface.withAlpha(80),
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (isActive)
                      Text(
                        'ACTIVE',
                        style: ts.caption.copyWith(
                          color: step.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat())
                          .fadeIn(duration: 600.ms)
                          .then()
                          .fadeOut(duration: 600.ms),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: (i * 100).ms, duration: 300.ms)
                  .slideX(begin: 0.05, end: 0, delay: (i * 100).ms);
            }),
          ],
        ),
      ),
    );
  }
}
