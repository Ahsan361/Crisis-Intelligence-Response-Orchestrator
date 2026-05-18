import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/alerts_repository.dart';
import '../models/crisis_alert.dart';
import '../models/system_status.dart';
import '../services/api_service.dart';
import '../services/reports_service.dart';
import '../services/routing_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
// CIRO — APP PROVIDERS
//
// Refactored for Riverpod 3.0 Notifier API.
// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// INFRASTRUCTURE — Singletons
// ═══════════════════════════════════════════════════════════════════════════

/// Provides the base [ApiService] (Dio wrapper).
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

/// Provides the [ReportsService] which handles raw API calls.
final reportsServiceProvider = Provider<ReportsService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return ReportsService(api);
});

/// Provides the [AlertsRepository] which coordinates API and mock fallbacks.
final alertsRepositoryProvider = Provider<AlertsRepository>((ref) {
  final service = ref.watch(reportsServiceProvider);
  return AlertsRepository(service);
});

/// Provides the [RoutingService] for coordinates calculations.
final routingServiceProvider = Provider<RoutingService>((ref) {
  final dio = ref.watch(apiServiceProvider).client;
  return RoutingService(dio);
});

// ═══════════════════════════════════════════════════════════════════════════
// DATA PROVIDERS — Async State
// ═══════════════════════════════════════════════════════════════════════════

/// Notifier that manages the full list of crisis alerts fetched from the API.
class AlertsNotifier extends AsyncNotifier<List<CrisisAlert>> {
  bool _isFirstLoad = true;

  @override
  Future<List<CrisisAlert>> build() async {
    final repo = ref.watch(alertsRepositoryProvider);
    final results = await repo.getAlerts();
    _isFirstLoad = false;
    return results;
  }

  /// Refetches alerts from the API and updates the state.
  Future<void> refresh() async {
    if (_isFirstLoad && !state.hasValue) {
      state = const AsyncValue.loading();
    }

    final result = await AsyncValue.guard(
      () => ref.read(alertsRepositoryProvider).getAlerts(),
    );

    if (result.hasValue) {
      _isFirstLoad = false;
    }
    
    state = result;
  }

  /// Submits a new report and refreshes the list on success.
  Future<void> submitReport(CrisisAlert report) async {
    final repo = ref.read(alertsRepositoryProvider);
    await repo.createAlert(report);
    await refresh();
  }
}

/// The main provider for all alerts in the system.
final allAlertsProvider = AsyncNotifierProvider<AlertsNotifier, List<CrisisAlert>>(
  AlertsNotifier.new,
);

/// Filtered view of [allAlertsProvider] showing the top 3 high-priority alerts.
final recentAlertsProvider = Provider<AsyncValue<List<CrisisAlert>>>((ref) {
  return ref.watch(allAlertsProvider).whenData((list) => list.take(3).toList());
});

/// Fetches a single alert by ID from the current async state.
final alertByIdProvider = Provider.family<AsyncValue<CrisisAlert?>, String>((ref, id) {
  return ref.watch(allAlertsProvider).whenData((list) {
    try {
      return list.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// ACTION PROVIDERS — Notifiers
// ═══════════════════════════════════════════════════════════════════════════

/// FIX 1: Migrated AnalyzeAlertNotifier from StateNotifier to Notifier.
class AnalyzeAlertNotifier extends Notifier<AsyncValue<Map<String, dynamic>?>> {
  @override
  AsyncValue<Map<String, dynamic>?> build() {
    return const AsyncValue.data(null);
  }

  /// Triggers the analysis pipeline for a specific report.
  Future<void> analyze({
    required String reportId,
    required String reportText,
    required String areaName,
    required double locationLat,
    required double locationLng,
  }) async {
    final repo = ref.read(alertsRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repo.analyzeAlert(
          reportId: reportId,
          reportText: reportText,
          areaName: areaName,
          locationLat: locationLat,
          locationLng: locationLng,
        ));
  }

  /// Resets the analysis state.
  void reset() => state = const AsyncValue.data(null);
}

/// Provider for the analysis action state.
final analyzeAlertProvider =
    NotifierProvider<AnalyzeAlertNotifier, AsyncValue<Map<String, dynamic>?>>(
  AnalyzeAlertNotifier.new,
);

// ═══════════════════════════════════════════════════════════════════════════
// DERIVED PROVIDERS — Logic
// ═══════════════════════════════════════════════════════════════════════════

/// Current CIRO system operational status — derived from async alert state.
final systemStatusProvider = Provider<SystemStatus>((ref) {
  final alertsAsync = ref.watch(allAlertsProvider);
  
  return alertsAsync.maybeWhen(
    data: (alerts) {
      final activeSeverities = alerts
          .where((a) => a.status != ReportStatus.resolved)
          .map((a) => a.severityKey);
      return SystemStatus.fromActiveSeverities(activeSeverities);
    },
    orElse: () => SystemStatus.operational,
  );
});

/// Count of active alerts for UI badge indicators.
final activeAlertCountProvider = Provider<int>((ref) {
  final alertsAsync = ref.watch(allAlertsProvider);
  return alertsAsync.maybeWhen(
    data: (alerts) => alerts.where((a) => a.status != ReportStatus.resolved).length,
    orElse: () => 0,
  );
});

/// Count of critical-severity active alerts for urgent UI indicators.
final criticalAlertCountProvider = Provider<int>((ref) {
  final alertsAsync = ref.watch(allAlertsProvider);
  return alertsAsync.maybeWhen(
    data: (alerts) => alerts
        .where((a) =>
            a.status != ReportStatus.resolved &&
            a.severity == CrisisSeverity.critical)
        .length,
    orElse: () => 0,
  );
});

// ═══════════════════════════════════════════════════════════════════════════
// UI STATE — Notifiers
// ═══════════════════════════════════════════════════════════════════════════

/// FIX 2: Migrated themeModeProvider from StateProvider to Notifier.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void setTheme(ThemeMode mode) => state = mode;
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// FIX 3: Migrated activeTabProvider from StateProvider to Notifier.
class ActiveTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) => state = index;
}

final activeTabProvider = NotifierProvider<ActiveTabNotifier, int>(
  ActiveTabNotifier.new,
);