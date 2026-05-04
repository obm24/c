import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../core/c_ui_theme.dart';
import '../core/c_constants.dart';
import '../core/c_core_utils.dart';
import '../core/c_state.dart';
import '../core/c_visual_effects.dart';
import 'nutrition_search_screen.dart';

// TIME-OF-DAY GREETING
String greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

class TraineeWorkoutPage extends StatelessWidget {
  const TraineeWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final name = appState.profileFirstName;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${greeting()}, $name 🔥',
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: AppConstants.kDefaultTitleFontSize,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ready to crush your goals today?',
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),

        // Today's Progress Card
        const TnTAppear(child: _TodayProgressCard()),
        const SizedBox(height: 28),

        const Text('Your Programmes',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TnTAppear(
          delay: const Duration(milliseconds: 45),
          child: _WorkoutCard(
            title: context.l10n.trainingSchedule,
            subtitle: context.l10n.viewWeeklyPlan,
            icon: CupertinoIcons.calendar,
            color: AppTheme.cardPurple,
            onTap: () => Navigator.push(context,
                AppRoutes.noTransitionRoute(const TrainingScheduleScreen())),
          ),
        ),
        const SizedBox(height: 14),
        TnTAppear(
          delay: const Duration(milliseconds: 90),
          child: _WorkoutCard(
            title: context.l10n.dietProgramme,
            subtitle: context.l10n.yourNutritionPlan,
            icon: CupertinoIcons.chart_bar,
            color: AppTheme.cardGreen,
            onTap: () => Navigator.push(context,
                AppRoutes.noTransitionRoute(const DietProgrammeScreen())),
          ),
        ),
      ]),
    );
  }
}

// ---------- Today's Progress Card ----------
class _TodayProgressCard extends StatelessWidget {
  const _TodayProgressCard();

  @override
  Widget build(BuildContext context) {
    const double progress = 0.65;
    final bw = appState.bodyComposition['Body Weight'] ?? '-';
    final unit = appState.weightUnit == 'metric' ? 'kg' : 'lbs';

    return TnTPremiumCard(
      padding: const EdgeInsets.all(22),
      radius: 24,
      accentColor: AppTheme.cardGreen,
      child: Row(
        children: [
          SizedBox(
            height: 80,
            width: 80,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 7,
                  backgroundColor: AppTheme.divider,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppTheme.textPrimary),
                  strokeCap: StrokeCap.round,
                ),
                const Center(
                    child: Text('65%',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 17))),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Today's Progress",
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('1,200 / 2,000 kcal',
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 3),
                Text('45 min active · $bw $unit',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ---------- Workout Card ----------
class _WorkoutCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _WorkoutCard(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TnTPremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      radius: 20,
      accentColor: color,
      child: Row(children: [
        Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 26)),
        const SizedBox(width: 16),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 4),
          Text(subtitle,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        ])),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(Icons.arrow_forward_ios_rounded, color: color, size: 13),
        ),
      ]),
    );
  }
}

// =============================================================================
// TRAINING SCHEDULE SCREEN
// =============================================================================
class TrainingScheduleScreen extends StatelessWidget {
  const TrainingScheduleScreen({super.key});

  Widget _card(
      String title, String bodyParts, String day, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 140,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)),
      child: Stack(children: [
        Positioned(
            right: -10,
            bottom: -10,
            child: Icon(icon,
                color: Colors.black.withValues(alpha: 0.05), size: 120)),
        Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          letterSpacing: 1.0)),
                  const SizedBox(height: 8),
                  Text(bodyParts,
                      style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(day,
                      style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                ])),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
          elevation: 0,
          iconTheme: const IconThemeData(color: AppTheme.textPrimary),
          title: Text(context.l10n.trainingSchedule,
              style: const TextStyle(color: AppTheme.brand))),
      body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            _card('UPPER BODY', 'Chest, Back & Arms', 'Monday / Thursday',
                AppTheme.cardPurple, Icons.fitness_center),
            _card(
                'LOWER BODY',
                'Quads, Hamstrings & Calves',
                'Tuesday / Friday',
                const Color(0xFFC6F432),
                Icons.directions_run),
            _card('FULL BODY', 'Core & Stability', 'Wednesday',
                const Color(0xFF32F4D6), Icons.accessibility_new),
          ]),
    );
  }
}

// =============================================================================
// DIET PROGRAMME SCREEN
// =============================================================================
class DietProgrammeScreen extends StatelessWidget {
  const DietProgrammeScreen({super.key});

  Widget _card(
      String title, String desc, String timing, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 140,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)),
      child: Stack(children: [
        Positioned(
            right: -10,
            bottom: -10,
            child: Icon(icon,
                color: Colors.black.withValues(alpha: 0.05), size: 120)),
        Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          letterSpacing: 1.0)),
                  const SizedBox(height: 8),
                  Text(desc,
                      style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(timing,
                      style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                ])),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
          elevation: 0,
          iconTheme: const IconThemeData(color: AppTheme.textPrimary),
          title: Text(context.l10n.dietProgramme,
              style: const TextStyle(color: AppTheme.brand))),
      body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            // --- Search Food Database Button ---
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.push(
                  context,
                  AppRoutes.noTransitionRoute(const NutritionSearchScreen()),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius:
                      BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.cardGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.search_rounded,
                          color: AppTheme.cardGreen, size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Search Food Database',
                              style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          SizedBox(height: 3),
                          Text('Look up nutrition values for any food',
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: AppTheme.textSecondary.withValues(alpha: 0.5),
                        size: 14),
                  ],
                ),
              ),
            ),

            _card(
                'BREAKFAST',
                'High Protein & Complex Carbs',
                'Everyday · 7:00 - 8:00 AM',
                AppTheme.cardYellow,
                Icons.breakfast_dining),
            _card(
                'LUNCH',
                'Balanced Meal with Lean Meat',
                'Everyday · 12:30 - 1:30 PM',
                AppTheme.cardPink,
                Icons.lunch_dining),
            _card('DINNER', 'Low Carb with Greens', 'Everyday · 7:00 - 8:00 PM',
                AppTheme.cardBlue, Icons.dinner_dining),
          ]),
    );
  }
}
