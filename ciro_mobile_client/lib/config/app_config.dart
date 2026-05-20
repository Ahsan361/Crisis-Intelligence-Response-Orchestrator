import 'dart:io';
import 'package:flutter/foundation.dart';

/// Central configuration for the CIRO application.
///
/// Handles environment-specific variables like API base URLs
/// and global timeout settings.
abstract final class AppConfig {
  AppConfig._();

  /// The FastAPI backend base URL.
  ///
  /// Logic:
  /// - Web: localhost
  /// - Android Emulator: 10.0.2.2
  /// - iOS Simulator: localhost
  /// - Physical Device: Your PC IPv4 address
  static String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }

    if (Platform.isAndroid) {
      // Android Emulator
      return 'http://10.0.2.2:8000';
    }

    if (Platform.isIOS) {
      // iOS Simulator
      return 'http://localhost:8000';
    }

    // Physical device over WiFi/USB
    return 'http://192.168.1.2:8000';
  }

  // ── Endpoints ───────────────────────────────────────────────────────────
  static const String reports = '/reports';
  static const String analyze = '/analyze-report';

  // ── Network Settings ────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 5);
  static const Duration receiveTimeout = Duration(minutes: 3);

  /// Toggle this to force mock data even if the API is reachable.
  /// Useful for UI-only development.
  static const bool forceMockData = false;

  // ── OpenRouteService Settings ───────────────────────────────────────────
  static const String orsApiKey = 'YOUR_ORS_API_KEY';

  static const String orsBaseUrl = 'https://api.openrouteservice.org';
}
