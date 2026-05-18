# CIRO Mobile Client — Crisis Intelligence Interface

> The field-ready command interface for the Crisis Intelligence & Response Orchestrator.

The **CIRO Mobile Client** is a high-performance Flutter application designed for emergency responders and citizens. It provides a real-time window into the CIRO agentic pipeline, allowing users to report crises and monitor the system's reasoning and simulation results as they happen.

---

## ✨ Features

- **🚨 Instant Reporting**: Simplified form to submit crisis alerts with automatic location tagging.
- **👁️ Agent Trace Timeline**: A detailed, step-by-step visualization of how the 5-agent pipeline processed each report.
- **📊 Priority Dashboard**: Reports are automatically sorted by priority score, calculated using severity, source count, and crisis type.
- **🗺️ Simulation Viewer**: Before-and-after route analysis for emergency services (Rescue 1122, Police, etc.).
- **🔄 Real-Time Updates**: Seamless synchronization with the Supabase backend—new reports and analysis results appear instantly.
- **🌘 Mission Control UI**: A premium, NASA-inspired dark theme designed for high visibility in emergency situations.

---

## 🛠️ Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: [Riverpod](https://riverpod.dev/)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
- **Theming**: Custom Dark/Light theme with `flutter_animate` for smooth transitions.
- **Networking**: [Dio](https://pub.dev/packages/dio) with background polling fallback.
- **Real-time**: [Supabase Flutter SDK](https://supabase.com/docs/reference/dart/initializing).

---

## 📸 Screenshots

| Dashboard | Report Analysis | Submission |
| :---: | :---: | :---: |
| ![Dashboard](https://via.placeholder.com/200x400?text=Dashboard) | ![Analysis](https://via.placeholder.com/200x400?text=Agent+Trace) | ![Submit](https://via.placeholder.com/200x400?text=Submit+Report) |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 3.0.0)

### Installation
1.  **Clone the repository**:
    ```bash
    git clone https://github.com/your-repo/ciro.git
    cd ciro/ciro_mobile_client
    ```
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Configure Environment**:
    Create a `lib/config/app_config.dart` (or use `.env`) and add your backend details:
    ```dart
    const String backendBaseUrl = 'http://127.0.0.1:8000';
    const String supabaseUrl = 'YOUR_SUPABASE_URL';
    const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
    ```
4.  **Run the app**:
    ```bash
    flutter run
    ```

---

## 📁 Folder Structure

- `lib/screens/`: Main UI screens (Dashboard, ReportDetail, SubmitReport).
- `lib/providers/`: Business logic and state management using Riverpod.
- `lib/services/`: API clients and third-party integrations.
- `lib/widgets/`: Reusable UI components (CrisisCard, AgentTraceTimeline).
- `lib/theme/`: Visual identity system and typography.

---

Built with Flutter for the **Innovista Hackathon 2026**.
