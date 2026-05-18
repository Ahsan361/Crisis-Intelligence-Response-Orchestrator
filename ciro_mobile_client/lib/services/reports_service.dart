import '../models/crisis_alert.dart';
import '../config/app_config.dart';
import 'api_service.dart';

/// Service class responsible for all report-related API interactions.
/// 
/// Maps API responses directly to [CrisisAlert] domain models.
class ReportsService {
  final ApiService _api;

  ReportsService(this._api);

  /// Fetches all reports from the backend.
  /// 
  /// Endpoint: GET /reports
  Future<List<CrisisAlert>> getReports() async {
    final response = await _api.get(AppConfig.reports);
    
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => CrisisAlert.fromJson(json)).toList();
    }
    
    throw Exception('Failed to fetch reports: ${response.statusMessage}');
  }

  /// Submits a new crisis report and returns the processed version.
  /// 
  /// Endpoint: POST /reports
  Future<CrisisAlert> createReport(CrisisAlert report) async {
    final response = await _api.post(
      AppConfig.reports,
      data: report.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CrisisAlert.fromJson(response.data);
    }

    throw Exception('Failed to create report: ${response.statusMessage}');
  }

  /// Triggers the agent analysis pipeline for a specific report.
  /// 
  /// Endpoint: POST /analyze-report/{id}
  Future<Map<String, dynamic>> analyzeReport({
  required String reportId,
  required String reportText,
  required String areaName,
  required double locationLat,
  required double locationLng,
}) async {
  final response = await _api.post(
    AppConfig.analyze,
    data: {
      'report_id': reportId,
      'report_text': reportText,
      'area_name': areaName,
      'location_lat': locationLat,
      'location_lng': locationLng,
    },
  );
  if (response.statusCode == 200) {
    return response.data as Map<String, dynamic>;
  }
  throw Exception('Pipeline analysis failed: ${response.statusMessage}');
}
}
