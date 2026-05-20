import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/crisis_alert.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
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
    final showShellChrome = activeTab == 0;

    return Scaffold(
      extendBody: false,
      appBar: showShellChrome ? _CiroAppBar(colors: colors) : null,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.03, 0),
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
// APP BAR — Transparent glass-style
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
      backgroundColor: colors.background,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Image.asset(
          'assets/images/ciro_shield.png',
          width: 28,
          height: 28,
          fit: BoxFit.contain,
          semanticLabel: 'CIRO shield',
        ),
      ),
      leadingWidth: 52,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CIRO',
            style: CiroTextStyles.of(context).title.copyWith(
                  letterSpacing: 1.5,
                  fontSize: 18,
                ),
          ),
          Text(
            'COMMAND CENTER',
            style: CiroTextStyles.of(context).caption.copyWith(
                  fontSize: 9,
                  letterSpacing: 2.0,
                  color: CiroColors.aiAccent.withAlpha(180),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
      actions: [
        Semantics(
          label: isDark ? 'Switch to light theme' : 'Switch to dark theme',
          button: true,
          child: IconButton(
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
        ),
        const SizedBox(width: 8),
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
    if (state == AppLifecycleState.resumed) {
      _performRefresh();
    }
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _performRefresh(),
    );
  }

  Future<void> _performRefresh() async {
    if (!mounted) return;
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
    final activeCount = ref.watch(activeAlertCountProvider);
    final criticalCount = ref.watch(criticalAlertCountProvider);

    return RefreshIndicator(
      onRefresh: _performRefresh,
      color: colors.primary,
      backgroundColor: colors.surface,
      displacement: 20,
      child: Stack(
        children: [
          // ── Background radial glow ──────────────────────────────────
          Positioned(
            top: -80,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: const BoxDecoration(
                gradient: CiroColors.headerGlow,
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────────────
          ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            children: [
              StatusBanner(status: status)
                  .animate()
                  .fadeIn(delay: 50.ms, duration: 350.ms),
              const SizedBox(height: 20),

              // ── Stats row ───────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'ACTIVE',
                      value: '$activeCount',
                      icon: Icons.warning_rounded,
                      color: CiroColors.severityHigh,
                      colors: colors,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'CRITICAL',
                      value: '$criticalCount',
                      icon: Icons.crisis_alert_rounded,
                      color: CiroColors.severityCritical,
                      colors: colors,
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 350.ms)
                  .slideY(begin: 0.05, end: 0, delay: 100.ms, duration: 350.ms),
              const SizedBox(height: 24),

              // ── Emergency button ────────────────────────────────────
              const _ReportButtonCard(),
              const SizedBox(height: 32),

              // ── Recent alerts ───────────────────────────────────────
              _RecentAlertsSection(
                alertsAsync: alertsAsync,
                lastRefreshed: _lastRefreshed,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STAT CARD — Compact metric display
// ═══════════════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.colors,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final CiroColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final ts = CiroTextStyles.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CiroColors.glassBorder),
        gradient: CiroColors.cardGradient,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: ts.display.copyWith(fontSize: 22, color: color),
              ),
              Text(
                label,
                style: ts.caption.copyWith(
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HERO REPORT BUTTON — Premium floating emergency panel
// ═══════════════════════════════════════════════════════════════════════════

class _ReportButtonCard extends StatefulWidget {
  const _ReportButtonCard();

  @override
  State<_ReportButtonCard> createState() => _ReportButtonCardState();
}

class _ReportButtonCardState extends State<_ReportButtonCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = CiroColors.of(context);
    final borderColor = Theme.of(context).brightness == Brightness.dark
        ? CiroColors.glassBorder
        : colors.onSurface.withAlpha(28);

    return Semantics(
      label: 'Report a crisis. Tap to submit an emergency report.',
      button: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () async {
          await Future.delayed(const Duration(milliseconds: 50));
          if (context.mounted) context.pushNamed(CiroRoutes.reportName);
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(CiroTheme.cardRadius),
              border: Border.all(color: borderColor),
              gradient: CiroColors.cardGradient,
              boxShadow: [
                BoxShadow(
                  color: CiroColors.severityCritical.withAlpha(20),
                  blurRadius: 30,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Emergency beacon ─────────────────────────────────
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        color: CiroColors.severityCritical.withAlpha(8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: CiroColors.severityCritical.withAlpha(15),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        gradient: CiroColors.emergencyGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: CiroColors.severityCritical.withAlpha(80),
                            blurRadius: 24,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.campaign_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                      begin: const Offset(0.97, 0.97),
                      end: const Offset(1.03, 1.03),
                      duration: 1800.ms,
                      curve: Curves.easeInOut,
                    ),

                const SizedBox(height: 14),

                Text(
                  'Report Emergency',
                  style: CiroTextStyles.of(context).title.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to submit a crisis report for AI analysis',
                  style: CiroTextStyles.of(context).bodySmall.copyWith(
                        color: colors.onSurface.withAlpha(150),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 150.ms, duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: 0.06, end: 0, delay: 150.ms, duration: 400.ms);
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
  bool _hasAnimated = false;

  @override
  Widget build(BuildContext context) {
    final ts = CiroTextStyles.of(context);
    final colors = CiroColors.of(context);

    final now = DateTime.now();
    final diff = now.difference(widget.lastRefreshed);
    final String timeStr =
        diff.inSeconds < 60 ? 'Just now' : '${diff.inMinutes}m ago';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recent Alerts',
                    style: ts.headline.copyWith(fontSize: 22)),
                const SizedBox(height: 4),
                Text(
                  'Updated $timeStr',
                  style: ts.caption.copyWith(
                    color: colors.onSurface.withAlpha(100),
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: colors.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.primary.withAlpha(30)),
              ),
              child: TextButton(
                onPressed: () => context.pushNamed('allAlerts'),
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 36),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                ),
                child: Text(
                  'View All',
                  style: ts.linkSmall.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 250.ms, duration: 350.ms),
        const SizedBox(height: 16),
        widget.alertsAsync.when(
          skipLoadingOnRefresh: true,
          data: (alerts) {
            if (alerts.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.check_circle_outline_rounded,
                          size: 48,
                          color: CiroColors.severityLow.withAlpha(100)),
                      const SizedBox(height: 16),
                      Text(
                        'No active alerts detected',
                        style: ts.bodySmall.copyWith(color: colors.onSurface),
                      ),
                    ],
                  ),
                ),
              );
            }

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
                  final delay = Duration(milliseconds: 300 + (i * 120));
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: i < alerts.length - 1 ? 12 : 0,
                    ),
                    child: card
                        .animate()
                        .fadeIn(
                            delay: delay,
                            duration: 400.ms,
                            curve: Curves.easeOut)
                        .slideY(
                          begin: 0.06,
                          end: 0.0,
                          delay: delay,
                          duration: 400.ms,
                          curve: Curves.easeOut,
                        ),
                  );
                }

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: i < alerts.length - 1 ? 12 : 0,
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
    final delay = Duration(milliseconds: 300 + (index * 120));

    return Container(
      width: double.infinity,
      height: 110,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withAlpha(100),
        borderRadius: BorderRadius.circular(CiroTheme.cardRadius),
        border: Border.all(color: CiroColors.glassBorder),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1500.ms,
          color: colors.surface.withAlpha(60),
        )
        .animate()
        .fadeIn(delay: delay, duration: 400.ms);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ERROR STATE
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
    final isNetwork =
        errStr.contains('socketexception') || errStr.contains('network');
    final title = isNetwork ? 'No Connection' : 'Server Unavailable';
    final subtitle = isNetwork
        ? 'Check your connection and try again.'
        : 'CIRO backend is unreachable.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.error.withAlpha(8),
        borderRadius: BorderRadius.circular(CiroTheme.cardRadius),
        border: Border.all(color: colors.error.withAlpha(25)),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded,
              color: colors.error.withAlpha(150), size: 36),
          const SizedBox(height: 16),
          Text(title,
              style: ts.title.copyWith(color: colors.error, fontSize: 18)),
          const SizedBox(height: 6),
          Text(subtitle, style: ts.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
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
    ).animate().fadeIn().shake(hz: 4, offset: const Offset(3, 0));
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FLOATING DOCK BOTTOM NAVIGATION
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
    (icon: Icons.home_rounded, activeIcon: Icons.home_rounded, label: 'Home'),
    (
      icon: Icons.add_alert_rounded,
      activeIcon: Icons.add_alert_rounded,
      label: 'Report'
    ),
    (icon: Icons.map_rounded, activeIcon: Icons.map_rounded, label: 'Map'),
    (
      icon: Icons.timeline_rounded,
      activeIcon: Icons.timeline_rounded,
      label: 'Trace'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? CiroColors.glassBorder
                : colors.onSurface.withAlpha(28),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 68,
          height: 68,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Icon with glow for active state ─────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isActive
                      ? colors.primary.withAlpha(20)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                  letterSpacing: 0.3,
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
