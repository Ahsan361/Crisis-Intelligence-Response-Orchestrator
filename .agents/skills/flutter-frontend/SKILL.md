---
name: flutter-frontend
description: Build responsive Flutter screens with Riverpod and GoRouter.
---

# Flutter Frontend Skill

## Instructions
1. **State Management:** Use Riverpod 3.0. Create classes extending `Notifier` or `AsyncNotifier` for business logic, and expose them via standard providers.
2. **Navigation:** Use `GoRouter` configured in `lib/router/app_router.dart`. Use `context.pushNamed(CiroRoutes.routeName)` instead of pushing un-named paths.
3. **Theming:** Strictly adhere to the CIRO visual identity. Access colors via `CiroColors.of(context)` and text styles via `CiroTextStyles.of(context)`.

## Constraints
- Do not make HTTP calls directly from UI Widgets. Offload network requests to repository classes or Riverpod Notifiers (e.g., `api_service.dart`).
- Do not use `setState` for complex global state. Confine `setState` strictly to ephemeral UI changes (like animations or form field active states).

## Common Pitfalls
- **Deprecated Riverpod APIs:** Avoid `StateNotifierProvider`. The project has migrated to the modern `NotifierProvider` syntax.
- **Hardcoded Styles:** Manually setting `TextStyle(color: Colors.white)` breaks the Dark/Light mode theme engine. Always rely on `CiroTextStyles`.
