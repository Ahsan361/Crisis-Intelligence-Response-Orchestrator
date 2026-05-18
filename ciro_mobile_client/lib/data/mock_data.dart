import '../models/crisis_alert.dart';

// ═══════════════════════════════════════════════════════════════════════════
// CIRO MOCK DATA
//
// Realistic Islamabad/Pakistan crisis scenario data used during development
// and UI prototyping before the live Supabase connection is active.
//
// All areas, coordinates, and report texts are real locations in Islamabad.
// Coordinates are approximate WGS-84 values.
//
// USAGE:
//   import 'package:ciro_mobile_client/data/mock_data.dart';
//   final alerts = CiroMockData.recentAlerts;
//
// Replace with real API calls in providers once the backend is live.
// ═══════════════════════════════════════════════════════════════════════════

abstract final class CiroMockData {
  CiroMockData._();

  // ═══════════════════════════════════════════════════════════════════════
  // RECENT ALERTS — landing page "Recent Alerts" section
  // 3 entries per spec: critical flood, high blockage, medium heatwave
  // ═══════════════════════════════════════════════════════════════════════

  static final List<CrisisAlert> recentAlerts = [
    // ── 1. Critical flood — G-10 Markaz ─────────────────────────────────
    CrisisAlert(
      id: 'cir-2024-08-17-001',
      reportText:
          'G-10 mein pani bhar gaya hai. Main road completely submerged. '
          'Multiple cars stranded near the underpass. Rescue needed urgently.',
      source: ReportSource.socialMedia,
      status: ReportStatus.simulated,
      reportedBy: 'Twitter Feed (@IslamabadAlerts)',
      areaName: 'G-10 Markaz',
      locationLat: 33.6938,
      locationLng: 73.0146,
      crisisType: CrisisType.flood,
      severity: CrisisSeverity.critical,
      priorityScore: 89,
      agentTrace: [
        {
          'agent': 'SignalCollector',
          'timestamp': '2024-08-17T08:12:00Z',
          'decision': 'Urdu/English mixed text detected. Crisis keywords: pani, submerged.',
          'confidence': 95,
        },
        {
          'agent': 'CrisisDetector',
          'timestamp': '2024-08-17T08:12:04Z',
          'decision': 'Crisis type: flood. Heavy rainfall confirmed via weather API.',
          'confidence': 97,
        },
        {
          'agent': 'ReasoningAnalyzer',
          'timestamp': '2024-08-17T08:12:08Z',
          'decision': 'Severity: critical. Multiple vehicles stranded, rescue required.',
          'confidence': 92,
        },
      ],
      simulationResult: {
        'before_route': {'duration_mins': 22, 'distance_km': 4.1},
        'after_route': {'duration_mins': 38, 'distance_km': 6.7},
        'emergency_ticket': {
          'unit': 'Rescue 1122 Islamabad',
          'eta_mins': 8,
          'dispatched': true,
        },
        'alerts_dispatched': [
          'NDMA flood alert — G-10 Markaz',
          'CDA road closure — G-10 underpass',
        ],
      },
      createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 3)),
    ),

    // ── 2. High blockage — Blue Area ─────────────────────────────────────
    CrisisAlert(
      id: 'cir-2024-08-17-002',
      reportText:
          'Massive traffic jam on Constitution Avenue near Blue Area. '
          'Protest march has blocked all lanes. No alternate route visible. '
          'Emergency vehicles cannot pass.',
      source: ReportSource.trafficApi,
      status: ReportStatus.analyzing,
      reportedBy: 'Google Traffic API',
      areaName: 'Blue Area',
      locationLat: 33.7294,
      locationLng: 73.0931,
      crisisType: CrisisType.blockage,
      severity: CrisisSeverity.high,
      priorityScore: 71,
      agentTrace: [
        {
          'agent': 'SignalCollector',
          'timestamp': '2024-08-17T07:50:00Z',
          'decision': 'Traffic API signal. Speed drop to 0 km/h across 2.3km stretch.',
          'confidence': 99,
        },
        {
          'agent': 'CrisisDetector',
          'timestamp': '2024-08-17T07:50:03Z',
          'decision': 'Crisis type: blockage. Full lane closure confirmed.',
          'confidence': 94,
        },
      ],
      simulationResult: null,
      createdAt: DateTime.now().subtract(const Duration(minutes: 34)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),

    // ── 3. Medium heatwave — F-7 Sector ──────────────────────────────────
    CrisisAlert(
      id: 'cir-2024-08-17-003',
      reportText:
          'Temperature in F-7 has crossed 46°C. Several elderly residents '
          'reported heat exhaustion near Jinnah Super Market. '
          'No power for 4 hours due to load shedding.',
      source: ReportSource.weatherApi,
      status: ReportStatus.pending,
      reportedBy: 'OpenWeatherMap API',
      areaName: 'F-7 Sector',
      locationLat: 33.7215,
      locationLng: 73.0580,
      crisisType: CrisisType.heatwave,
      severity: CrisisSeverity.medium,
      priorityScore: 54,
      agentTrace: null,
      simulationResult: null,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════
  // FULL ALERTS LIST — used by the "View All" alerts screen
  // Includes recentAlerts above plus additional resolved/simulated entries.
  // ═══════════════════════════════════════════════════════════════════════

  static final List<CrisisAlert> allAlerts = [
    ...recentAlerts,

    // ── 4. Resolved accident — I-8 Markaz ────────────────────────────────
    CrisisAlert(
      id: 'cir-2024-08-16-004',
      reportText:
          'Multi-vehicle collision on Kashmir Highway near I-8 Markaz interchange. '
          '3 vehicles involved. Ambulance requested. Road partially blocked.',
      source: ReportSource.manual,
      status: ReportStatus.resolved,
      reportedBy: 'Citizen Report',
      areaName: 'I-8 Markaz',
      locationLat: 33.6706,
      locationLng: 73.0851,
      crisisType: CrisisType.accident,
      severity: CrisisSeverity.high,
      priorityScore: 66,
      agentTrace: null,
      simulationResult: null,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),

    // ── 5. Low infrastructure — E-11 ─────────────────────────────────────
    CrisisAlert(
      id: 'cir-2024-08-16-005',
      reportText:
          'Street lights on E-11 main boulevard non-functional for past 3 days. '
          'Risk of road accidents at night. Reported to IESCO — no response.',
      source: ReportSource.manual,
      status: ReportStatus.pending,
      reportedBy: 'Resident — E-11/3',
      areaName: 'E-11 Sector',
      locationLat: 33.7396,
      locationLng: 72.9887,
      crisisType: CrisisType.infrastructure,
      severity: CrisisSeverity.low,
      priorityScore: 23,
      agentTrace: null,
      simulationResult: null,
      createdAt: DateTime.now().subtract(const Duration(hours: 9)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 9)),
    ),
  ];
}
