import 'package:flutter/foundation.dart';

// ═══════════════════════════════════════════════════════════════════════════
// REPORT SOURCE ENUM
// Mirrors: report_source enum in Supabase
// Values:  social_media | weather_api | traffic_api | manual
// ═══════════════════════════════════════════════════════════════════════════

enum ReportSource {
  socialMedia,
  weatherApi,
  trafficApi,
  manual;

  /// Supabase / API wire value (snake_case string).
  String get value {
    switch (this) {
      case ReportSource.socialMedia:
        return 'social_media';
      case ReportSource.weatherApi:
        return 'weather_api';
      case ReportSource.trafficApi:
        return 'traffic_api';
      case ReportSource.manual:
        return 'manual';
    }
  }

  String get displayName {
    switch (this) {
      case ReportSource.socialMedia:
        return 'Social Media';
      case ReportSource.weatherApi:
        return 'Weather API';
      case ReportSource.trafficApi:
        return 'Traffic API';
      case ReportSource.manual:
        return 'Manual';
    }
  }

  static ReportSource fromString(String raw) {
    switch (raw.toLowerCase()) {
      case 'social_media':
        return ReportSource.socialMedia;
      case 'weather_api':
        return ReportSource.weatherApi;
      case 'traffic_api':
        return ReportSource.trafficApi;
      case 'manual':
      default:
        return ReportSource.manual;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CRISIS TYPE ENUM
// Mirrors: crisis_type enum in Supabase
// Values:  flood | accident | heatwave | blockage | infrastructure
// ═══════════════════════════════════════════════════════════════════════════

enum CrisisType {
  flood,
  accident,
  heatwave,
  blockage,
  infrastructure,
  unknown; // client-only fallback — not a DB value

  /// Supabase / API wire value.
  String get value => this == CrisisType.unknown ? 'unknown' : name;

  String get displayName {
    switch (this) {
      case CrisisType.flood:
        return 'Flood';
      case CrisisType.accident:
        return 'Accident';
      case CrisisType.heatwave:
        return 'Heatwave';
      case CrisisType.blockage:
        return 'Blockage';
      case CrisisType.infrastructure:
        return 'Infrastructure';
      case CrisisType.unknown:
        return 'Unknown';
    }
  }

  /// Local asset path for this crisis type's icon.
  String get iconAsset {
    switch (this) {
      case CrisisType.flood:
        return 'assets/icons/flood.png';
      case CrisisType.accident:
        return 'assets/icons/accident.png';
      case CrisisType.heatwave:
        return 'assets/icons/heatwave.png';
      case CrisisType.blockage:
        return 'assets/icons/blockage.png';
      case CrisisType.infrastructure:
        return 'assets/icons/infrastructure.png';
      case CrisisType.unknown:
        return 'assets/icons/blockage.png'; // client fallback
    }
  }

  static CrisisType fromString(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'flood':
        return CrisisType.flood;
      case 'accident':
        return CrisisType.accident;
      case 'heatwave':
        return CrisisType.heatwave;
      case 'blockage':
        return CrisisType.blockage;
      case 'infrastructure':
        return CrisisType.infrastructure;
      default:
        return CrisisType.unknown;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CRISIS SEVERITY ENUM
// Mirrors: severity_level enum in Supabase
// Values:  low | medium | high | critical
// ═══════════════════════════════════════════════════════════════════════════

enum CrisisSeverity {
  low,
  medium,
  high,
  critical,
  unknown; // client-only fallback — not a DB value

  /// Supabase / API wire value (lowercase).
  String get value => this == CrisisSeverity.unknown ? 'unknown' : name;

  String get displayName {
    switch (this) {
      case CrisisSeverity.low:
        return 'Low';
      case CrisisSeverity.medium:
        return 'Medium';
      case CrisisSeverity.high:
        return 'High';
      case CrisisSeverity.critical:
        return 'Critical';
      case CrisisSeverity.unknown:
        return 'Unknown';
    }
  }

  static CrisisSeverity fromString(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'low':
        return CrisisSeverity.low;
      case 'medium':
        return CrisisSeverity.medium;
      case 'high':
        return CrisisSeverity.high;
      case 'critical':
        return CrisisSeverity.critical;
      default:
        return CrisisSeverity.unknown;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// REPORT STATUS ENUM
// Mirrors: report_status enum in Supabase
// Values:  pending | analyzing | resolved | simulated
// ═══════════════════════════════════════════════════════════════════════════

enum ReportStatus {
  pending,
  analyzing,
  resolved,
  simulated;

  /// Supabase / API wire value.
  String get value => name;

  String get displayName {
    switch (this) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.analyzing:
        return 'Analyzing';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.simulated:
        return 'Simulated';
    }
  }

  static ReportStatus fromString(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'analyzing':
        return ReportStatus.analyzing;
      case 'resolved':
        return ReportStatus.resolved;
      case 'simulated':
        return ReportStatus.simulated;
      case 'pending':
      default:
        return ReportStatus.pending;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CRISIS ALERT MODEL
// Mirrors the full Supabase `reports` table row.
// Column names in fromJson/toJson match the DB snake_case keys exactly.
// ═══════════════════════════════════════════════════════════════════════════

@immutable
class CrisisAlert {
  const CrisisAlert({
    required this.id,
    required this.reportText,
    required this.source,
    required this.status,
    this.reportedBy,
    this.areaName,
    this.locationLat,
    this.locationLng,
    this.crisisType,
    this.severity,
    this.priorityScore = 0,
    this.agentTrace,
    this.simulationResult,
    this.crisisConfidence = 0,
    this.detectedLanguage = 'Unknown',
    this.createdAt,
    this.updatedAt,
  });

  // ── Required fields (NOT NULL in DB) ──────────────────────────────────

  /// uuid primary key.
  final String id;

  /// Raw crisis report text submitted by the user.
  final String reportText;

  /// Origin of the report.
  final ReportSource source;

  /// Pipeline processing state.
  final ReportStatus status;

  // ── Optional / nullable fields ─────────────────────────────────────────

  /// Free-text reporter identifier — no auth required.
  final String? reportedBy;

  /// Human-readable area name, e.g. "G-10 Markaz".
  final String? areaName;

  /// WGS-84 latitude, nullable until set on submission.
  final double? locationLat;

  /// WGS-84 longitude, nullable until set on submission.
  final double? locationLng;

  /// Filled by CrisisDetector agent; null while pending.
  final CrisisType? crisisType;

  /// Filled by ReasoningAnalyzer agent; null while pending.
  final CrisisSeverity? severity;

  /// 0-100 priority score; filled by the pipeline.
  final int priorityScore;

  /// Full agent pipeline reasoning log (jsonb array from DB).
  final List<dynamic>? agentTrace;

  /// Before/after simulation data (jsonb object from DB).
  final Map<String, dynamic>? simulationResult;

  /// Confidence score from the detector (0-100).
  final int crisisConfidence;

  /// Detected language from the signal collector.
  final String detectedLanguage;

  /// Auto-set by Supabase on INSERT.
  final DateTime? createdAt;

  /// Auto-updated by Supabase trigger on UPDATE.
  final DateTime? updatedAt;

  // ── Derived / computed getters ─────────────────────────────────────────

  /// Icon asset path resolved from [crisisType].
  /// Falls back to blockage icon when type is null/unknown.
  String get iconAsset =>
      (crisisType ?? CrisisType.unknown).iconAsset;

  /// Severity as a lowercase string used by [CiroColors.forSeverity].
  /// Returns 'unknown' when severity has not been set yet.
  String get severityKey =>
      (severity ?? CrisisSeverity.unknown).value;

  /// Human-readable elapsed time computed from [createdAt].
  /// Returns "Just now" when createdAt is null (e.g. optimistic local insert).
  String get timeAgo {
    if (createdAt == null) return 'Just now';
    final diff = DateTime.now().difference(createdAt!);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m min${m == 1 ? '' : 's'} ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h hr${h == 1 ? '' : 's'} ago';
    }
    final d = diff.inDays;
    return '$d day${d == 1 ? '' : 's'} ago';
  }

  // ── Serialisation ──────────────────────────────────────────────────────

  /// Creates a [CrisisAlert] from a Supabase JSON row.
  /// Column keys match the DB schema exactly (snake_case).
  factory CrisisAlert.fromJson(Map<String, dynamic> json) {
    return CrisisAlert(
      id: json['id'] as String,
      reportText: json['report_text'] as String,
      source: ReportSource.fromString(
          (json['source'] as String?) ?? 'manual'),
      status: ReportStatus.fromString(
          (json['status'] as String?) ?? 'pending'),
      reportedBy: json['reported_by'] as String?,
      areaName: json['area_name'] as String?,
      locationLat: (json['location_lat'] as num?)?.toDouble(),
      locationLng: (json['location_lng'] as num?)?.toDouble(),
      crisisType: CrisisType.fromString(json['crisis_type'] as String?),
      severity: CrisisSeverity.fromString(json['severity'] as String?),
      priorityScore: (json['priority_score'] as int?) ?? 0,
      agentTrace: json['agent_trace'] as List<dynamic>?,
      simulationResult:
          json['simulation_result'] as Map<String, dynamic>?,
      crisisConfidence: (json['crisis_confidence'] as int?) ?? 0,
      detectedLanguage: (json['detected_language'] as String?) ?? 'Unknown',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Serialises to a Supabase-compatible JSON map.
  /// Null fields are omitted so PATCH requests only update changed columns.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_text': reportText,
      'source': source.value,
      'status': status.value,
      if (reportedBy != null) 'reported_by': reportedBy,
      if (areaName != null) 'area_name': areaName,
      if (locationLat != null) 'location_lat': locationLat,
      if (locationLng != null) 'location_lng': locationLng,
      if (crisisType != null && crisisType != CrisisType.unknown)
        'crisis_type': crisisType!.value,
      if (severity != null && severity != CrisisSeverity.unknown)
        'severity': severity!.value,
      'priority_score': priorityScore,
      'crisis_confidence': crisisConfidence,
      'detected_language': detectedLanguage,
      if (agentTrace != null) 'agent_trace': agentTrace,
      if (simulationResult != null) 'simulation_result': simulationResult,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Returns a copy with updated fields — used for optimistic UI updates.
  CrisisAlert copyWith({
    String? id,
    String? reportText,
    ReportSource? source,
    ReportStatus? status,
    String? reportedBy,
    String? areaName,
    double? locationLat,
    double? locationLng,
    CrisisType? crisisType,
    CrisisSeverity? severity,
    int? priorityScore,
    List<dynamic>? agentTrace,
    Map<String, dynamic>? simulationResult,
    int? crisisConfidence,
    String? detectedLanguage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CrisisAlert(
      id: id ?? this.id,
      reportText: reportText ?? this.reportText,
      source: source ?? this.source,
      status: status ?? this.status,
      reportedBy: reportedBy ?? this.reportedBy,
      areaName: areaName ?? this.areaName,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      crisisType: crisisType ?? this.crisisType,
      severity: severity ?? this.severity,
      priorityScore: priorityScore ?? this.priorityScore,
      agentTrace: agentTrace ?? this.agentTrace,
      simulationResult: simulationResult ?? this.simulationResult,
      crisisConfidence: crisisConfidence ?? this.crisisConfidence,
      detectedLanguage: detectedLanguage ?? this.detectedLanguage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'CrisisAlert(id: $id, type: ${crisisType?.name}, '
      'severity: ${severity?.name}, area: $areaName, status: ${status.name})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrisisAlert &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
