import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ═══════════════════════════════════════════════════════════════════════════
// SEVERITY BADGE
//
// Compact pill that communicates crisis severity at a glance.
//
// Sizes:
//   SeverityBadge(severity: 'critical')          → standard (card use)
//   SeverityBadge.large(severity: 'critical')    → detail screen header
//   SeverityBadge.dot(severity: 'critical')      → list indicator dot only
//
// Usage:
//   SeverityBadge(severity: alert.severityKey)
//   SeverityBadge(severity: 'high')
// ═══════════════════════════════════════════════════════════════════════════

enum _BadgeSize { standard, large, dot }

class SeverityBadge extends StatelessWidget {
  const SeverityBadge({
    super.key,
    required this.severity,
  }) : _size = _BadgeSize.standard;

  /// Large variant — used on the Report Detail screen header.
  const SeverityBadge.large({
    super.key,
    required this.severity,
  }) : _size = _BadgeSize.large;

  /// Dot-only variant — used in dense list rows where space is tight.
  const SeverityBadge.dot({
    super.key,
    required this.severity,
  }) : _size = _BadgeSize.dot;

  /// Lowercase severity string: 'critical' | 'high' | 'medium' | 'low' | 'unknown'.
  final String severity;
  final _BadgeSize _size;

  // ── Derived values ─────────────────────────────────────────────────────

  Color get _color => CiroColors.forSeverity(severity);

  String get _label => _BadgeLabel.from(severity);

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Severity: $_label',
      child: switch (_size) {
        _BadgeSize.standard => _StandardBadge(
            label: _label,
            color: _color,
          ),
        _BadgeSize.large => _LargeBadge(
            label: _label,
            color: _color,
          ),
        _BadgeSize.dot => _DotBadge(color: _color),
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STANDARD BADGE — used on CrisisCard
// ═══════════════════════════════════════════════════════════════════════════

class _StandardBadge extends StatelessWidget {
  const _StandardBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.40), width: 1),
      ),
      child: Text(
        label,
        style: CiroTextStyles.severityBadge.copyWith(color: color),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LARGE BADGE — used on detail screen header / report summary
// ═══════════════════════════════════════════════════════════════════════════

class _LargeBadge extends StatelessWidget {
  const _LargeBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Filled dot
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DOT BADGE — compact indicator dot for dense lists
// ═══════════════════════════════════════════════════════════════════════════

class _DotBadge extends StatelessWidget {
  const _DotBadge({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.50),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BADGE LABEL HELPER
// Maps severity key → uppercase display string.
// Kept here so the badge is self-contained with no model import.
// ═══════════════════════════════════════════════════════════════════════════

abstract final class _BadgeLabel {
  static String from(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return 'CRITICAL';
      case 'high':
        return 'HIGH';
      case 'medium':
        return 'MEDIUM';
      case 'low':
        return 'LOW';
      default:
        return 'UNKNOWN';
    }
  }
}
