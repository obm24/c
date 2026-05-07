import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'core/c_ui_theme.dart';
import 'core/c_state.dart';
import 'core/c_error_screen.dart';
import 'core/animations/anim_motion.dart';
import 'repositories/exercise_repository.dart';

// Adjust path depending on your code generation/l10n setup
import 'l10n/app_localizations.dart';

import 'features/dashboard_screen.dart';
import 'features/f_auth_screen.dart';
import 'features/trainer_programmes_screen.dart';
import 'models/m_programmes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _useHighestAndroidRefreshRate();
  AppErrorWidgetBuilder.install();
  final exerciseRepository = await ExerciseRepository.loadFromAssetBundle(
    rootBundle,
  );
  runApp(TnTApp(exerciseRepository: exerciseRepository));
}

Future<void> _useHighestAndroidRefreshRate() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

  try {
    final modes = await FlutterDisplayMode.supported;
    final displayModes =
        modes.where((mode) => mode.refreshRate > 0).toList(growable: false);
    if (displayModes.isEmpty) return;

    var preferredMode = displayModes.first;
    for (final mode in displayModes.skip(1)) {
      if (_isBetterDisplayMode(mode, preferredMode)) {
        preferredMode = mode;
      }
    }

    await FlutterDisplayMode.setPreferredMode(preferredMode);
  } on PlatformException {
    return;
  } on MissingPluginException {
    return;
  }
}

bool _isBetterDisplayMode(DisplayMode candidate, DisplayMode current) {
  if (candidate.refreshRate != current.refreshRate) {
    return candidate.refreshRate > current.refreshRate;
  }

  final candidatePixels = candidate.width * candidate.height;
  final currentPixels = current.width * current.height;
  return candidatePixels > currentPixels;
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
            child: _DashboardRoute(role: role),
          );
        },
      ),
      GoRoute(
        path: '/programmes',
        pageBuilder: (context, state) => AppMotion.goRouterPage(
          key: state.pageKey,
          child: const ProgramBuilderScreen(),
        ),
      ),
      GoRoute(
        path: '/programmes/builder',
        pageBuilder: (context, state) {
          final extra = state.extra;
          return AppMotion.goRouterPage(
            key: state.pageKey,
            child: _TrainingPlanBuilderRoute(
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

class _DashboardRoute extends StatefulWidget {
  final String role;

  const _DashboardRoute({
    required this.role,
  });

  @override
  State<_DashboardRoute> createState() => _DashboardRouteState();
}

class _DashboardRouteState extends State<_DashboardRoute> {
  String get _normalizedRole {
    final normalizedRole = widget.role.trim().toLowerCase();
    return normalizedRole == 'trainee' ? 'Trainee' : 'Trainer';
  }

  @override
  void initState() {
    super.initState();
    _syncRole();
  }

  @override
  void didUpdateWidget(covariant _DashboardRoute oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.role != widget.role) {
      _syncRole();
    }
  }

  void _syncRole() {
    final nextRole = _normalizedRole;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || appState.currentRole == nextRole) return;
      appState.setRole(nextRole);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScreen(role: _normalizedRole);
  }
}

class _TrainingPlanBuilderRoute extends StatelessWidget {
  final Programme? initialProgramme;

  const _TrainingPlanBuilderRoute({
    this.initialProgramme,
  });

  @override
  Widget build(BuildContext context) {
    final title = AppLocalizations.of(context)?.trainingPlanBuilder ??
        'Training Plan Builder';
    final message = AppLocalizations.of(context)?.programmeBuilderComingSoon ??
        'Programme builder coming soon.';

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.bg,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.brand,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            initialProgramme?.name ?? message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
