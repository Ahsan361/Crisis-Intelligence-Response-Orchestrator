import 'dart:io';
import 'package:flutter/foundation.dart';


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
  // Production deployed backend
  return 'https://crisis-intelligence-response-orchestrator.onrender.com/';
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
  static const String orsApiKey = 'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImFlZThlMWNjMGNiNjQ2ZDA4ZGYwYzAzNDU5ZmNmMzAyIiwiaCI6Im11cm11cjY0In0=';

  static const String orsBaseUrl = 'https://api.openrouteservice.org';
}
