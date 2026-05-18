import '../models/crisis_alert.dart';
import '../services/reports_service.dart';
import 'mock_data.dart';

/// Repository responsible for coordinating alert data between the API and local fallbacks.
/// 
/// Follows the repository pattern to decouple UI providers from specific service implementations.
class AlertsRepository {
  final ReportsService _service;

  AlertsRepository(this._service);

  /// Retrieves all alerts from the live backend.
  /// 
  /// Gracefully falls back to [CiroMockData.allAlerts] if the backend is unreachable
  /// or returns an error, ensuring a smooth demo experience.
  Future<List<CrisisAlert>> getAlerts() async {
    try {
      final alerts = await _service.getReports();
      // Sort by priority score descending as per spec
      alerts.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
      return alerts;
    } catch (e) {
      // Fallback to mock data for offline/demo robustness
      return CiroMockData.allAlerts;
    }
  }

  /// Submits a new crisis report to the backend.
  /// 
  /// Falls back to returning the same report with a mock ID if the API fails.
  Future<CrisisAlert> createAlert(CrisisAlert alert) async {
    try {
      return await _service.createReport(alert);
    } catch (e) {
      return alert.copyWith(
        id: 'mock-${DateTime.now().millisecondsSinceEpoch}',
      );
    }
  }

  /// Triggers the full agent pipeline for a specific report.
  /// 
  /// Requires full report context to provide to the backend agents.
  Future<Map<String, dynamic>> analyzeAlert({
    required String reportId,
    required String reportText,
    required String areaName,
    required double locationLat,
    required double locationLng,
  }) async {
    try {
      return await _service.analyzeReport(
        reportId: reportId,
        reportText: reportText,
        areaName: areaName,
        locationLat: locationLat,
        locationLng: locationLng,
      );
    } catch (e) {
      // Fallback — return mock pipeline state for demo robustness
      return {
        'crisis_type': 'flood',
        'severity': 'high',
        'trace': [],
        'simulation_result': {},
      };
    }
  }
}
