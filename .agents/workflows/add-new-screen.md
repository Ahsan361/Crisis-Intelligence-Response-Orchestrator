# Workflow: Adding a New Flutter Screen

Follow these steps to introduce a new screen into the CIRO mobile app:

1. **Create the Screen Widget:**
   Create a new Dart file in `ciro_mobile_client/lib/screens/`, e.g., `new_screen.dart`. Define it as a `StatelessWidget` or `ConsumerWidget` (if using Riverpod).

2. **Define Route Constant:**
   Open `ciro_mobile_client/lib/router/app_router.dart`.
   Add a string constant in the `CiroRoutes` abstract class:
   ```dart
   static const String newScreen = '/new-screen';
   static const String newScreenName = 'newScreen';
   ```

3. **Register the Route:**
   In the same `app_router.dart`, locate the `GoRouter` instance (`appRouter`) and add a new `GoRoute`:
   ```dart
   GoRoute(
     path: CiroRoutes.newScreen,
     name: CiroRoutes.newScreenName,
     pageBuilder: (context, state) => _fadePage(
       key: state.pageKey,
       child: const NewScreen(),
     ),
   ),
   ```

4. **Manage State (Optional):**
   If the screen requires dynamic state, create a Notifier in `lib/providers/`.
   ```dart
   class NewScreenNotifier extends Notifier<NewScreenState> {
     @override
     NewScreenState build() => NewScreenState.initial();
     // methods...
   }
   final newScreenProvider = NotifierProvider<NewScreenNotifier, NewScreenState>(() => NewScreenNotifier());
   ```

5. **Apply Theming:**
   Ensure the screen utilizes CIRO aesthetics by reading from the theme context:
   ```dart
   final colors = CiroColors.of(context);
   final ts = CiroTextStyles.of(context);
   ```
