import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// ═══════════════════════════════════════════════════════════════════════════
// SYSTEM STATUS ENUM
//
// Represents the operational health of the CIRO monitoring system as shown
// in the StatusBanner on the landing page.
//
// This is a client-side UI concept — not a Supabase column.
// The value is derived at runtime from live report data:
//   • operational  → no unresolved critical/high alerts
//   • degraded     → one or more high alerts active
//   • crisis       → one or more critical alerts active
// ═══════════════════════════════════════════════════════════════════════════

enum SystemStatus {
  operational,
  degraded,
  crisis;

  // ── Display strings ──────────────────────────────────────────────────────

  /// Short status label shown in the banner chip.
  String get label {
    switch (this) {
      case SystemStatus.operational:
        return 'All Systems Operational';
      case SystemStatus.degraded:
        return 'Degraded — High Alerts Active';
      case SystemStatus.crisis:
        return 'Crisis Mode — Immediate Action Required';
    }
  }

  /// Full banner message including the monitor prefix.
  String get bannerMessage {
    switch (this) {
      case SystemStatus.operational:
        return 'Islamabad Crisis Monitor — All Systems Operational';
      case SystemStatus.degraded:
        return 'Islamabad Crisis Monitor — High Alerts Detected';
      case SystemStatus.crisis:
        return 'Islamabad Crisis Monitor — CRISIS MODE ACTIVE';
    }
  }

  /// Accessibility label for screen readers.
  String get semanticLabel {
    switch (this) {
      case SystemStatus.operational:
        return 'System status: operational. No active crises detected.';
      case SystemStatus.degraded:
        return 'System status: degraded. High severity alerts are active.';
      case SystemStatus.crisis:
        return 'System status: crisis. Critical emergency response required.';
    }
  }

  // ── Colour tokens ────────────────────────────────────────────────────────

  /// Dot / indicator colour for this status state.
  Color get dotColor {
    switch (this) {
      case SystemStatus.operational:
        return CiroColors.statusOperational; // #3FB950
      case SystemStatus.degraded:
        return CiroColors.statusDegraded;    // #E3B341
      case SystemStatus.crisis:
        return CiroColors.statusCrisis;      // #F85149
    }
  }

  /// Text colour used for the banner label in this state.
  Color get textColor {
    switch (this) {
      case SystemStatus.operational:
        return CiroColors.statusOperational;
      case SystemStatus.degraded:
        return CiroColors.statusDegraded;
      case SystemStatus.crisis:
        return CiroColors.statusCrisis;
    }
  }

  /// Icon representing the system health state.
  IconData get icon {
    switch (this) {
      case SystemStatus.operational:
        return Icons.check_circle_rounded;
      case SystemStatus.degraded:
        return Icons.warning_rounded;
      case SystemStatus.crisis:
        return Icons.crisis_alert_rounded;
    }
  }

  // ── Behaviour flags ──────────────────────────────────────────────────────

  /// Whether the status dot should pulse (animate) in the banner.
  /// Pulses only when there is something to draw attention to.
  bool get shouldPulse => this != SystemStatus.operational;

  /// Whether the banner should use a coloured background tint.
  bool get hasElevatedBackground => this == SystemStatus.crisis;

  // ── Factory ──────────────────────────────────────────────────────────────

  /// Derives the system status from a list of active [CrisisSeverity] values.
  ///
  /// Rules (in priority order):
  ///   1. Any critical severity → [SystemStatus.crisis]
  ///   2. Any high severity     → [SystemStatus.degraded]
  ///   3. Otherwise             → [SystemStatus.operational]
  ///
  /// Pass the severities of all currently unresolved reports.
  static SystemStatus fromActiveSeverities(Iterable<String> severities) {
    final all = severities.map((s) => s.toLowerCase()).toList();
    if (all.contains('critical')) return SystemStatus.crisis;
    if (all.contains('high')) return SystemStatus.degraded;
    return SystemStatus.operational;
  }
}
