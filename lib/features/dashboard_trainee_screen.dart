import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../core/c_ui_theme.dart';
import '../core/c_constants.dart';
import '../core/c_core_utils.dart';
import '../core/c_state.dart';
import '../core/c_visual_effects.dart';
import 'nutrition_search_screen.dart';

// NOTE: greeting() is defined in dashboard_trainer_screen.dart as
// dashboardGreeting(). Reuse it here — do NOT redeclare to avoid
// duplicate-symbol compile errors.
// Import it via the trainer file or move to c_core_utils.dart.
// For now we call dashboardGreeting() imported from that file.

// =============================================================================
// TRAINEE WORKOUT / HOME PAGE
// =============================================================================
class TraineeWorkoutPage extends StatelessWidget {
  const TraineeWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final name = appState.profileFirstName;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 108),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Greeting header ────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${dashboardGreeting()}, $name 🔥',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: AppConstants.kDefaultTitleFontSize,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ready to crush your goals today?',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Today's Progress Card ──────────────────────────────────────
          const TnTAppear(child: _TodayProgressCard()),
          const SizedBox(height: 20),

          // ── Daily Stats Row ────────────────────────────────────────────
          const TnTAppear(
            delay: Duration(milliseconds: 30),
            child: _DailyStatsRow(),
          ),
          const SizedBox(height: 28),

          // ── Programmes section ─────────────────────────────────────────
          const Text(
            'Your Programmes',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 14),

          TnTAppear(
            delay: const Duration(milliseconds: 45),
            child: _WorkoutCard(
              title: context.l10n.trainingSchedule,
              subtitle: context.l10n.viewWeeklyPlan,
              icon: CupertinoIcons.calendar,
              color: AppTheme.cardPurple,
              badge: 'Today: Upper Body',
              onTap: () => Navigator.push(
                context,
                AppRoutes.noTransitionRoute(const TrainingScheduleScreen()),
              ),
            ),
          ),
          const SizedBox(height: 12),

          TnTAppear(
            delay: const Duration(milliseconds: 90),
            child: _WorkoutCard(
              title: context.l10n.dietProgramme,
              subtitle: context.l10n.yourNutritionPlan,
              icon: CupertinoIcons.chart_bar,
              color: AppTheme.cardGreen,
              badge: '1,200 / 2,000 kcal',
              onTap: () => Navigator.push(
                context,
                AppRoutes.noTransitionRoute(const DietProgrammeScreen()),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ── Coach Card ─────────────────────────────────────────────────
          const TnTAppear(
            delay: Duration(milliseconds: 135),
            child: _MyCoachCard(),
          ),
          const SizedBox(height: 28),

          // ── Upcoming Sessions ──────────────────────────────────────────
          const TnTAppear(
            delay: Duration(milliseconds: 180),
            child: _UpcomingSessionsSection(),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TODAY'S PROGRESS CARD — circular progress + key metrics
// =============================================================================
class _TodayProgressCard extends StatelessWidget {
  const _TodayProgressCard();

  @override
  Widget build(BuildContext context) {
    const double progress = 0.65;
    final bw = appState.bodyComposition['Body Weight'] ?? '-';
    final unit = appState.weightUnit == 'metric' ? 'kg' : 'lbs';

    return TnTPremiumCard(
      padding: const EdgeInsets.all(20),
      radius: AppConstants.kDefaultBorderRadius,
      accentColor: AppTheme.cardGreen,
      child: Row(
        children: [
          // Circular progress indicator
          SizedBox(
            height: 84,
            width: 84,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 7,
                  backgroundColor: AppTheme.divider,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppTheme.cardGreen),
                  strokeCap: StrokeCap.round,
                ),
                const Center(
                  child: Text(
                    '65%',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Progress",
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 10),
                _MetricRow(
                  icon: CupertinoIcons.flame_fill,
                  color: const Color(0xFFFF6B35),
                  label: '1,200 / 2,000 kcal',
                ),
                const SizedBox(height: 6),
                _MetricRow(
                  icon: CupertinoIcons.timer,
                  color: AppTheme.cardPurple,
                  label: '45 min active',
                ),
                const SizedBox(height: 6),
                _MetricRow(
                  icon: CupertinoIcons.person_fill,
                  color: AppTheme.cardGreen,
                  label: '$bw $unit',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _MetricRow(
      {required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12.5,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// DAILY STATS ROW — steps, water, sleep
// =============================================================================
class _DailyStatsRow extends StatelessWidget {
  const _DailyStatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStatCard(
            icon: CupertinoIcons.arrow_right_arrow_left_circle_fill,
            label: 'Steps',
            value: '7,842',
            color: const Color(0xFF4776E6),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStatCard(
            icon: CupertinoIcons.drop_fill,
            label: 'Water',
            value: '1.8 L',
            color: const Color(0xFF12D8FA),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStatCard(
            icon: CupertinoIcons.moon_fill,
            label: 'Sleep',
            value: '7h 20m',
            color: const Color(0xFF8E54E9),
          ),
        ),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _MiniStatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return TnTPremiumCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      radius: AppConstants.kDefaultBorderRadius,
      accentColor: color,
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10.5,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MY COACH CARD
// =============================================================================
class _MyCoachCard extends StatelessWidget {
  const _MyCoachCard();

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0xFF4776E6);

    return TnTPressable(
      onTap: () => AppUtils.showToast(context, 'Coach profile — coming soon'),
      pressedScale: 0.975,
      child: TnTPremiumCard(
        padding: const EdgeInsets.all(18),
        radius: AppConstants.kDefaultBorderRadius,
        accentColor: accentColor,
        child: Row(
          children: [
            // Avatar with glowing ring
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [accentColor, Color(0xFF8E54E9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFF1E1E2E),
                child: Text(
                  'AD',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Ahmed al-Demerdash',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.verified_rounded,
                          color: accentColor, size: 14),
                    ],
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Your Coach · NASM-CPT',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Online indicator
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF38EF7D),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'Active now',
                        style: TextStyle(
                          color: Color(0xFF38EF7D),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Message shortcut
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                CupertinoIcons.chat_bubble_fill,
                color: accentColor,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// UPCOMING SESSIONS SECTION
// =============================================================================
class _UpcomingSessionsSection extends StatelessWidget {
  const _UpcomingSessionsSection();

  static const List<Map<String, dynamic>> _sessions = [
    {
      'day': 'Today',
      'time': '6:00 PM',
      'title': 'Upper Body — Chest & Back',
      'duration': '60 min',
      'color': Color(0xFF4776E6),
    },
    {
      'day': 'Tomorrow',
      'time': '7:00 AM',
      'title': 'Lower Body — Quads & Hams',
      'duration': '55 min',
      'color': Color(0xFF11998E),
    },
    {
      'day': 'Thu',
      'time': '6:00 PM',
      'title': 'Full Body — Core & Cardio',
      'duration': '45 min',
      'color': Color(0xFF6A3093),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming Sessions',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
            GestureDetector(
              onTap: () =>
                  AppUtils.showToast(context, 'Full schedule — coming soon'),
              child: const Text(
                'See All',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ..._sessions.asMap().entries.map((entry) {
          final i = entry.key;
          final s = entry.value;
          return TnTAppear(
            delay: Duration(milliseconds: i * 40),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SessionTile(session: s),
            ),
          );
        }),
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  final Map<String, dynamic> session;
  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final color = session['color'] as Color;
    return TnTPressable(
      onTap: () =>
          AppUtils.showToast(context, '${session['title']} — coming soon'),
      pressedScale: 0.975,
      child: TnTPremiumCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        radius: AppConstants.kDefaultBorderRadius,
        accentColor: color,
        child: Row(
          children: [
            // Day/time column
            SizedBox(
              width: 52,
              child: Column(
                children: [
                  Text(
                    session['day'] as String,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    session['time'] as String,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10.5,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 36,
              color: color.withValues(alpha: 0.30),
              margin: const EdgeInsets.symmetric(horizontal: 14),
            ),
            Expanded(
              child: Text(
                session['title'] as String,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                session['duration'] as String,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// WORKOUT CARD — navigation shortcut tile
// =============================================================================
class _WorkoutCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _WorkoutCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return TnTPressable(
      onTap: onTap,
      pressedScale: 0.975,
      child: TnTPremiumCard(
        padding: const EdgeInsets.all(18),
        radius: AppConstants.kDefaultBorderRadius,
        accentColor: color,
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 25),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.5,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12.5,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(height: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        badge!,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: color,
                size: 13,
              ),
            ),
          ],
        ),
      ),
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
      margin: const EdgeInsets.only(bottom: 16),
      height: 140,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(icon,
                color: Colors.black.withValues(alpha: 0.06), size: 120),
          ),
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
                      letterSpacing: 0.8,
                      decoration: TextDecoration.none,
                    )),
                const SizedBox(height: 8),
                Text(bodyParts,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    )),
                const SizedBox(height: 4),
                Text(day,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.bg,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        title: Text(
          context.l10n.trainingSchedule,
          style: const TextStyle(color: AppTheme.brand),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          _card('UPPER BODY', 'Chest, Back & Arms', 'Monday / Thursday',
              AppTheme.cardPurple, Icons.fitness_center),
          _card('LOWER BODY', 'Quads, Hamstrings & Calves', 'Tuesday / Friday',
              const Color(0xFFC6F432), Icons.directions_run),
          _card('FULL BODY', 'Core & Stability', 'Wednesday',
              const Color(0xFF32F4D6), Icons.accessibility_new),
        ],
      ),
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
      margin: const EdgeInsets.only(bottom: 16),
      height: 140,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(icon,
                color: Colors.black.withValues(alpha: 0.06), size: 120),
          ),
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
                      letterSpacing: 0.8,
                      decoration: TextDecoration.none,
                    )),
                const SizedBox(height: 8),
                Text(desc,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    )),
                const SizedBox(height: 4),
                Text(timing,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.bg,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        title: Text(
          context.l10n.dietProgramme,
          style: const TextStyle(color: AppTheme.brand),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          // Search food database shortcut
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.push(
                context,
                AppRoutes.noTransitionRoute(const NutritionSearchScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
                        Text(
                          'Search Food Database',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Look up nutrition values for any food',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppTheme.textSecondary.withValues(alpha: 0.5),
                    size: 14,
                  ),
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
        ],
      ),
    );
  }
}