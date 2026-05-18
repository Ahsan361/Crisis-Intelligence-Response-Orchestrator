import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/crisis_alert.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/status_banner.dart';
import '../widgets/crisis_card.dart';
import '../router/app_router.dart';
import 'report_screen.dart';
import 'trace_history_screen.dart';
import 'map_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════
// LANDING PAGE
// ═══════════════════════════════════════════════════════════════════════════

class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(activeTabProvider);
    final colors = CiroColors.of(context);

    return Scaffold(
      appBar: _CiroAppBar(colors: colors),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            )),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(activeTab),
          child: [
            const _HomeTabBody(),
            const ReportScreen(),
            const MapScreen(),
            const TraceHistoryScreen(),
          ][activeTab],
        ),
      ),
      bottomNavigationBar: _CiroBottomNav(
        activeIndex: activeTab,
        onTap: (i) => ref.read(activeTabProvider.notifier).setTab(i),
        colors: colors,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// APP BAR
// ═══════════════════════════════════════════════════════════════════════════

class _CiroAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _CiroAppBar({required this.colors});

  final CiroColorScheme colors;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Image.asset(
          'assets/images/ciro_shield.png',
          width: 24,
          height: 24,
          fit: BoxFit.contain,
          semanticLabel: 'CIRO shield',
        ),
      ),
      leadingWidth: 48,
      title: Text('CIRO', style: CiroTextStyles.of(context).title),
      actions: [
        Semantics(
          label: isDark ? 'Switch to light theme' : 'Switch to dark theme',
          button: true,
          child: IconButton(
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
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
              tapTargetSize: MaterialTapTargetSize.padded,
            ),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HOME TAB BODY
// ═══════════════════════════════════════════════════════════════════════════

class _HomeTabBody extends ConsumerStatefulWidget {
  const _HomeTabBody();

  @override
  ConsumerState<_HomeTabBody> createState() => _HomeTabBodyState();
}

class _HomeTabBodyState extends ConsumerState<_HomeTabBody>
    with WidgetsBindingObserver {
  Timer? _pollingTimer;
  DateTime _lastRefreshed = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh data when app returns from background
    if (state == AppLifecycleState.resumed) {
      _performRefresh();
    }
  }

  void _startPolling() {
    // Poll every 15 seconds per requirements
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _performRefresh(),
    );
  }

  Future<void> _performRefresh() async {
    if (!mounted) return;

    // Trigger the refresh on the notifier
    // AlertsNotifier.refresh() handles the silent background fetch
    await ref.read(allAlertsProvider.notifier).refresh();

    if (mounted) {
      setState(() => _lastRefreshed = DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(recentAlertsProvider);
    final status = ref.watch(systemStatusProvider);
    final colors = CiroColors.of(context);

    return RefreshIndicator(
      onRefresh: _performRefresh,
      color: colors.primary,
      backgroundColor: colors.surface,
      displacement: 20,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          StatusBanner(status: status)
              .animate()
              .fadeIn(delay: 50.ms, duration: 350.ms),
          const SizedBox(height: 20),
          const _ReportButtonCard(),
          const SizedBox(height: 28),
          _RecentAlertsSection(
            alertsAsync: alertsAsync,
            lastRefreshed: _lastRefreshed,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HERO REPORT BUTTON CARD
// ═══════════════════════════════════════════════════════════════════════════

class _ReportButtonCard extends StatefulWidget {
  const _ReportButtonCard();

  @override
  State<_ReportButtonCard> createState() => _ReportButtonCardState();
}

class _ReportButtonCardState extends State<_ReportButtonCard> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails _) => setState(() => _isPressed = true);
  void _onTapUp(TapUpDetails _) => setState(() => _isPressed = false);
  void _onTapCancel() => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Report a crisis. Tap to submit an emergency report.',
      button: true,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: () async {
          await Future.delayed(const Duration(milliseconds: 50));
          if (context.mounted) context.pushNamed(CiroRoutes.reportName);
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: _ReportButtonContent(),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 150.ms, duration: 400.ms, curve: Curves.easeOut)
        .slideY(
          begin: 0.08,
          end: 0.0,
          delay: 150.ms,
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }
}

class _ReportButtonContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = CiroColors.of(context);
    
    // Coral red color from user screenshot
    const coralRed = Color(0xFFFF4D5A);
    final ring1Color = coralRed.withValues(alpha: isDark ? 0.12 : 0.15);
    final ring2Color = coralRed.withValues(alpha: isDark ? 0.05 : 0.07);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.divider.withValues(alpha: isDark ? 0.15 : 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Concentric Pulsing Emergency Beacon ─────────────────────
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer Ripple Ring 2 (Largest)
              Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  color: ring2Color,
                  shape: BoxShape.circle,
                ),
              ),
              // Outer Ripple Ring 1 (Middle)
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: ring1Color,
                  shape: BoxShape.circle,
                ),
              ),
              // Main Circular Button (Center)
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: coralRed,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: coralRed.withValues(alpha: isDark ? 0.5 : 0.35),
                      blurRadius: 24,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.campaign_rounded, // Premium emergency beacon megaphone icon
                  color: Colors.white,
                  size: 52,
                ),
              ),
            ],
          )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(
            begin: const Offset(0.97, 0.97),
            end: const Offset(1.03, 1.03),
            duration: 1500.ms,
            curve: Curves.easeInOut,
          ),
          
          const SizedBox(height: 24),
          
          // ── Text Labels ────────────────────────────────────────────
          Text(
            'Tap in case of emergency',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFF0F6FC) : const Color(0xFF1F2328),
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 6),
          
          Text(
            'Tap to submit an emergency report',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: colors.onSurface.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RECENT ALERTS SECTION
// ═══════════════════════════════════════════════════════════════════════════

class _RecentAlertsSection extends ConsumerStatefulWidget {
  const _RecentAlertsSection({
    required this.alertsAsync,
    required this.lastRefreshed,
  });

  final AsyncValue<List<CrisisAlert>> alertsAsync;
  final DateTime lastRefreshed;

  @override
  ConsumerState<_RecentAlertsSection> createState() =>
      _RecentAlertsSectionState();
}

class _RecentAlertsSectionState extends ConsumerState<_RecentAlertsSection> {
  /// Track if we've already performed the entrance animation.
  bool _hasAnimated = false;

  @override
  Widget build(BuildContext context) {
    final ts = CiroTextStyles.of(context);
    final colors = CiroColors.of(context);

    // Compute "last updated" string
    final now = DateTime.now();
    final diff = now.difference(widget.lastRefreshed);
    final String timeStr =
        diff.inSeconds < 60 ? 'Just now' : '${diff.inMinutes}m ago';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recent Alerts', style: ts.headline),
                const SizedBox(height: 2),
                Text(
                  'Last updated: $timeStr',
                  style: ts.bodySmall.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                context.pushNamed('allAlerts');
              },
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text('View All', style: ts.link),
            ),
          ],
        ).animate().fadeIn(delay: 250.ms, duration: 350.ms),
        const SizedBox(height: 12),
        widget.alertsAsync.when(
          // Background refreshes are silent — skip loading callback if data exists.
          skipLoadingOnRefresh: true,
          data: (alerts) {
            if (alerts.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'No active alerts detected.',
                    style: ts.bodySmall.copyWith(color: colors.onSurface),
                  ),
                ),
              );
            }

            // Flag that entrance animation should happen only once
            final bool shouldAnimate = !_hasAnimated;
            if (shouldAnimate) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _hasAnimated = true);
              });
            }

            return Column(
              children: List.generate(alerts.length, (i) {
                final card = CrisisCard(
                  alert: alerts[i],
                  onTap: () => context.pushNamed(
                    CiroRoutes.traceName,
                    extra: {
                      'report_id': alerts[i].id,
                      'crisis_type': alerts[i].crisisType?.value,
                      'severity': alerts[i].severity?.value,
                      'crisis_confidence': alerts[i].crisisConfidence,
                      'detected_language': alerts[i].detectedLanguage,
                      'normalized_location': alerts[i].areaName,
                      'action_plan': [],
                      'simulation_result': alerts[i].simulationResult ?? {},
                      'trace': alerts[i].agentTrace ?? [],
                    },
                  ),
                );

                if (shouldAnimate) {
                  final delay = Duration(milliseconds: 300 + (i * 150));
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: i < alerts.length - 1 ? 10 : 0,
                    ),
                    child: card
                        .animate()
                        .fadeIn(
                            delay: delay,
                            duration: 400.ms,
                            curve: Curves.easeOut)
                        .slideX(
                          begin: 0.06,
                          end: 0.0,
                          delay: delay,
                          duration: 400.ms,
                          curve: Curves.easeOut,
                        ),
                  );
                }

                // Subsequent refreshes: no entrance animation
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: i < alerts.length - 1 ? 10 : 0,
                  ),
                  child: card,
                );
              }),
            );
          },
          loading: () => Column(
            children: List.generate(3, (i) => _SkeletonCard(index: i)),
          ),
          error: (err, stack) => _ErrorState(
            error: err,
            onRetry: () => ref.refresh(allAlertsProvider),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SKELETON LOADING CARD
// ═══════════════════════════════════════════════════════════════════════════

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = CiroColors.of(context);
    final delay = Duration(milliseconds: 300 + (index * 150));

    return Container(
      width: double.infinity,
      height: 110,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.divider.withValues(alpha: 0.5)),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1200.ms,
          color: colors.surface.withValues(alpha: 0.3),
        )
        .animate()
        .fadeIn(delay: delay, duration: 400.ms);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ERROR STATE WIDGET
// ═══════════════════════════════════════════════════════════════════════════

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ts = CiroTextStyles.of(context);
    final colors = CiroColors.of(context);

    final errStr = error.toString().toLowerCase();
    final isNetwork = errStr.contains('socketexception') || errStr.contains('network');
    final title = isNetwork ? 'No Internet Connection' : 'Server Unavailable';
    final subtitle = isNetwork ? 'Check your connection and try again.' : 'CIRO backend is unreachable. Make sure the server is running.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.error.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, color: colors.error, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: ts.titleMedium.copyWith(color: colors.error),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: ts.bodySmall.copyWith(color: colors.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: const Text('Retry Connection'),
            style: TextButton.styleFrom(
              foregroundColor: colors.primary,
              backgroundColor: colors.primary.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().shake(hz: 4, offset: const Offset(4, 0));
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BOTTOM NAVIGATION BAR
// ═══════════════════════════════════════════════════════════════════════════

class _CiroBottomNav extends StatelessWidget {
  const _CiroBottomNav({
    required this.activeIndex,
    required this.onTap,
    required this.colors,
  });

  final int activeIndex;
  final ValueChanged<int> onTap;
  final CiroColorScheme colors;

  static const _items = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.add_alert_rounded, label: 'Report'),
    (icon: Icons.map_rounded, label: 'Map'),
    (icon: Icons.timeline_rounded, label: 'Trace'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.divider, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              return _NavItem(
                icon: _items[i].icon,
                label: _items[i].label,
                isActive: activeIndex == i,
                onTap: () => onTap(i),
                colors: colors,
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final CiroColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? colors.primary : colors.onSurface;

    return Semantics(
      label: label,
      button: true,
      selected: isActive,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 72,
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  key: ValueKey(isActive),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

