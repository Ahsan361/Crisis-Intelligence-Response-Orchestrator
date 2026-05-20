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
  /// - Android Emulator: Uses 10.0.2.2 to access host's localhost.
  /// - Web / iOS Simulator: Uses localhost.
  static String get apiBaseUrl {
  if (kIsWeb) return 'http://localhost:8000';
  // Real device over USB/WiFi — replace with your computer's IPv4 from ipconfig
  return 'http://192.168.1.8:8000';
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
