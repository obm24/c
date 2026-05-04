import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'core/c_ui_theme.dart';
import 'core/c_state.dart';
import 'core/c_error_screen.dart';
import 'core/animations/app_motion.dart';
import 'repositories/exercise_repository.dart';

// Adjust path depending on your code generation/l10n setup
import 'l10n/app_localizations.dart';

import 'features/f_auth_screen.dart';
import 'features/trainer_programmes_screen.dart';
import 'models/programme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppErrorWidgetBuilder.install();
  final exerciseRepository = await ExerciseRepository.loadFromAssetBundle(
    rootBundle,
  );
  runApp(TnTApp(exerciseRepository: exerciseRepository));
}

class TnTApp extends StatelessWidget {
  final ExerciseRepository exerciseRepository;

  TnTApp({
    super.key,
    required this.exerciseRepository,
  });

  late final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => AppMotion.goRouterPage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/dashboard/:role',
        pageBuilder: (context, state) {
          final role = state.pathParameters['role'] ?? 'Trainer';
          return AppMotion.goRouterPage(
            key: state.pageKey,
            child: DashboardScreen(role: role),
          );
        },
      ),
      GoRoute(
        path: '/programmes',
        pageBuilder: (context, state) => AppMotion.goRouterPage(
          key: state.pageKey,
          child: const ProgrammesScreen(),
        ),
      ),
      GoRoute(
        path: '/programmes/builder',
        pageBuilder: (context, state) {
          final extra = state.extra;
          return AppMotion.goRouterPage(
            key: state.pageKey,
            child: TrainingPlanBuilderScreen(
              initialProgramme: extra is Programme ? extra : null,
            ),
          );
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: exerciseRepository,
      child: AnimatedBuilder(
        animation: appState,
        builder: (context, child) {
          return MaterialApp.router(
            onGenerateTitle: (context) {
              return AppLocalizations.of(context)?.appName ?? 'TnT';
            },
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            debugShowCheckedModeBanner: false,

            // App wide responsiveness using ResponsiveFramework
            builder: (context, child) => ResponsiveBreakpoints.builder(
              child: AppFadeSlideTransition(
                duration: AppDurations.standard,
                offset: const Offset(0, 0.018),
                child: child ?? const SizedBox.shrink(),
              ),
              breakpoints: [
                const Breakpoint(start: 0, end: 450, name: MOBILE),
                const Breakpoint(start: 451, end: 800, name: TABLET),
                const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
              ],
            ),
            theme: AppTheme.theme,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
