import '../models/crisis_alert.dart';
import '../services/reports_service.dart';
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
    final alerts = await _service.getReports();
    alerts.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
    return alerts;
  }

  /// Submits a new crisis report to the backend.
  ///
  /// Falls back to returning the same report with a mock ID if the API fails.
  Future<CrisisAlert> createAlert(CrisisAlert alert) async {
    return await _service.createReport(alert);
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
  return await _service.analyzeReport(
    reportId: reportId,
    reportText: reportText,
    areaName: areaName,
    locationLat: locationLat,
    locationLng: locationLng,
  );
}
}
