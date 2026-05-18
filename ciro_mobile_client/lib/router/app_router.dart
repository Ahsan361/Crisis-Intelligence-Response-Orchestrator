import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/splash_screen.dart';
import '../screens/landing_page.dart';
import '../screens/report_screen.dart';
import '../screens/trace_screen.dart';
import '../screens/trace_history_screen.dart';
import '../screens/all_alerts_screen.dart';
import '../screens/crisis_map_screen.dart';
import '../models/crisis_alert.dart';

abstract final class CiroRoutes {
  CiroRoutes._();

  static const String splash = '/';
  static const String landing = '/home';
  static const String report = '/report';
  static const String trace = '/trace';
  static const String alertDetail = '/alerts/:id';

  static const String splashName = 'splash';
  static const String landingName = 'landing';
  static const String reportName = 'report';
  static const String traceName = 'trace';
  static const String alertDetailName = 'alertDetail';

  static String alertDetailPath(String id) => '/alerts/$id';
}

final appRouter = GoRouter(
  initialLocation: CiroRoutes.splash,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: CiroRoutes.splash,
      name: CiroRoutes.splashName,
      pageBuilder: (context, state) => _fadePage(
        key: state.pageKey,
        child: const SplashScreen(),
      ),
    ),

    GoRoute(
      path: CiroRoutes.landing,
      name: CiroRoutes.landingName,
      pageBuilder: (context, state) => _fadePage(
        key: state.pageKey,
        child: const LandingPage(),
      ),
    ),

    GoRoute(
      path: CiroRoutes.report,
      name: CiroRoutes.reportName,
      pageBuilder: (context, state) => _fadePage(
        key: state.pageKey,
        child: const ReportScreen(),
      ),
    ),

    GoRoute(
      path: '/all-alerts',
      name: 'allAlerts',
      pageBuilder: (context, state) => _fadePage(
        key: state.pageKey,
        child: const AllAlertsScreen(),
      ),
    ),

    GoRoute(
      path: '/trace-history',
      name: 'traceHistory',
      pageBuilder: (context, state) => _fadePage(
        key: state.pageKey,
        child: const TraceHistoryScreen(),
      ),
    ),

    GoRoute(
      path: CiroRoutes.trace,
      name: CiroRoutes.traceName,
      pageBuilder: (context, state) {
        final result = state.extra as Map<String, dynamic>?;
        return _fadePage(
          key: state.pageKey,
          child: TraceScreen(pipelineResult: result),
        );
      },
    ),

    GoRoute(
      path: '/crisis-map',
      name: 'crisisMap',
      pageBuilder: (context, state) {
        final alert = state.extra as CrisisAlert;
        return _fadePage(
          key: state.pageKey,
          child: CrisisMapScreen(alert: alert),
        );
      },
    ),

    GoRoute(
      path: CiroRoutes.alertDetail,
      name: CiroRoutes.alertDetailName,
      pageBuilder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return _fadePage(
          key: state.pageKey,
          child: TraceHistoryScreen(),
        );
      },
    ),
  ],

  errorPageBuilder: (context, state) => _fadePage(
    key: state.pageKey,
    child: _RouterErrorScreen(error: state.error),
  ),
);

CustomTransitionPage<void> _fadePage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: child,
      );
    },
  );
}

class _RouterErrorScreen extends StatelessWidget {
  const _RouterErrorScreen({this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.report_problem_rounded,
                  size: 56,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 24),
                Text(
                  'Page Not Found',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'The requested screen does not exist.\nReturn to the home screen.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.goNamed(CiroRoutes.landingName),
                    icon: const Icon(Icons.home_rounded, size: 20),
                    label: const Text('Go to Home'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}