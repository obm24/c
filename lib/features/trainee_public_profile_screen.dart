import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/c_ui_theme.dart';
import '../core/c_constants.dart';
import '../core/c_state.dart';
import '../core/c_core_utils.dart';
import '../core/c_custom_controls.dart';
import '../core/c_trainee_profile.dart';
import '../core/c_visual_effects.dart';

// =============================================================================
// MEDICAL DATA CATALOGUE
// =============================================================================

// =============================================================================
// BODY COMPOSITION CANONICAL DATA
// =============================================================================
class BodyCompData {
  static const Map<String, String> descriptions = {
    'Total Body Weight':
        'The absolute total mass of the body, including all tissues, fluids, and bones.',
    'BMI':
        'A general health screening ratio of weight to height (kg/m²). It does not distinguish between fat and muscle.',
    'Body Fat %': 'The proportion of total body weight that is made up of fat.',
    'Fat Mass':
        'The actual weight of all the fat in the body, measured in kilograms or pounds.',
    'Lean Body Mass':
        'The total weight of the body minus fat mass. Includes muscle, bone, water, skin, and organs.',
    'Fat-Free Mass':
        'Clinically distinct from LBM — FFM excludes ALL fat, including essential lipids found in cell membranes and the central nervous system.',
    'Skeletal Muscle Mass':
        'The specific weight of striated muscles attached to the skeleton, which are grown through resistance training.',
    'Right Arm Lean':
        'Lean mass in the right arm segment. Used to detect left–right muscular imbalances.',
    'Left Arm Lean':
        'Lean mass in the left arm segment. Used to detect left–right muscular imbalances.',
    'Trunk Lean':
        'Lean mass in the trunk segment (chest, abdomen, back). Central strength indicator.',
    'Right Leg Lean':
        'Lean mass in the right leg segment. Used to detect lower-limb imbalances.',
    'Left Leg Lean':
        'Lean mass in the left leg segment. Used to detect lower-limb imbalances.',
    'Bone Mineral Content':
        'The absolute weight of bone mineral in the body. Indicator of bone density and osteoporosis risk.',
    'Total Body Water':
        'The absolute total volume of fluid in the body. Comprises intracellular and extracellular water.',
    'Intracellular Water':
        'Water contained inside the body\'s cells. High ICW indicates cellular health, glycogen storage, and muscle volume.',
    'Extracellular Water':
        'Water located outside the cells — blood plasma, interstitial fluid, lymphatic fluid. Elevated ECW can signal inflammation or oedema.',
    'BMR':
        'The minimum calories the body requires to sustain basic life functions at complete rest, calculated directly from lean mass and structural data.',
  };

  static const Map<String, String> units = {
    'Total Body Weight': 'kg',
    'BMI': 'kg/m²',
    'Body Fat %': '%',
    'Fat Mass': 'kg',
    'Lean Body Mass': 'kg',
    'Fat-Free Mass': 'kg',
    'Skeletal Muscle Mass': 'kg',
    'Right Arm Lean': 'kg',
    'Left Arm Lean': 'kg',
    'Trunk Lean': 'kg',
    'Right Leg Lean': 'kg',
    'Left Leg Lean': 'kg',
    'Bone Mineral Content': 'kg',
    'Total Body Water': 'L',
    'Intracellular Water': 'L',
    'Extracellular Water': 'L',
    'BMR': 'kcal',
  };

  static IconData iconFor(String key) {
    const m = <String, IconData>{
      'Total Body Weight': Icons.monitor_weight_outlined,
      'BMI': Icons.calculate_outlined,
      'Body Fat %': Icons.local_fire_department_outlined,
      'Fat Mass': Icons.water_drop_outlined,
      'Lean Body Mass': Icons.directions_run,
      'Fat-Free Mass': Icons.sports_gymnastics,
      'Skeletal Muscle Mass': Icons.fitness_center,
      'Right Arm Lean': Icons.sports_handball_outlined,
      'Left Arm Lean': Icons.sports_handball_outlined,
      'Trunk Lean': Icons.accessibility_new,
      'Right Leg Lean': Icons.directions_walk,
      'Left Leg Lean': Icons.directions_walk,
      'Bone Mineral Content': Icons.invert_colors_outlined,
      'Total Body Water': Icons.waves_outlined,
      'Intracellular Water': Icons.opacity,
      'Extracellular Water': Icons.water,
      'BMR': Icons.bolt_outlined,
    };
    return m[key] ?? Icons.bar_chart;
  }
}

// =============================================================================
// TRAINEE PUBLIC PROFILE SCREEN
// =============================================================================
class TraineePublicProfileScreen extends StatefulWidget {
  final Map<String, dynamic> trainee;
  const TraineePublicProfileScreen({super.key, required this.trainee});

  @override
  State<TraineePublicProfileScreen> createState() =>
      _TraineePublicProfileScreenState();
}

class _TraineePublicProfileScreenState
    extends State<TraineePublicProfileScreen> {
  bool _isFollowing = false;

  int _computeAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  Widget _sectionHeader(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppTheme.brand, size: 16),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionDivider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Divider(color: AppTheme.divider, height: 1),
      );

  Widget _buildChipList(
    BuildContext context,
    List<String> items,
    Color color,
  ) {
    if (items.isEmpty) {
      return TnTPremiumCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        elevated: false,
        child: Row(
          children: [
            Icon(Icons.check_circle_outline,
                color: AppTheme.textSecondary.withValues(alpha: 0.5), size: 16),
            const SizedBox(width: 8),
            Text(
              context.l10n.noneReported,
              style: TextStyle(
                  color: AppTheme.textSecondary.withValues(alpha: 0.6),
                  fontSize: 13,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map((item) => PremiumSelectionButton(
                label: item,
                color: color,
                selected: true,
              ))
          .toList(),
    );
  }

  Widget _statCol(String label, String value) => Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
        ),
      );

  Widget _activityScoreBadge(int score) {
    final Color color;
    final String label;
    if (score >= 90) {
      color = AppTheme.cardGreen;
      label = 'Elite';
    } else if (score >= 75) {
      color = AppTheme.cardBlue;
      label = 'Advanced';
    } else if (score >= 55) {
      color = AppTheme.cardYellow;
      label = 'Intermediate';
    } else {
      color = AppTheme.textSecondary;
      label = 'Beginner';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$label  ·  $score / 100',
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _metricMapFrom(dynamic value) {
    if (value is! Map) return const {};
    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  Widget _bodyMetricButton({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return TnTPremiumCard(
      onTap: onTap,
      elevated: false,
      muted: !enabled,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      accentColor: enabled ? color : null,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: enabled ? 0.14 : 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withValues(alpha: enabled ? 0.32 : 0.14),
              ),
            ),
            child: Icon(
              icon,
              color: enabled ? color : AppTheme.textSecondary,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color:
                        enabled ? AppTheme.textPrimary : AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppTheme.textSecondary.withValues(alpha: 0.82),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            color: enabled
                ? AppTheme.textSecondary
                : AppTheme.textSecondary.withValues(alpha: 0.35),
            size: 20,
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final reasons = [
      'Fake or impersonated profile',
      'Inappropriate content',
      'Spam or misleading information',
      'Harassment or abusive behaviour',
      'Other',
    ];
    String? selected;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheet) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppTheme.divider,
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Report Profile',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Why are you reporting this profile?',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                const Divider(color: AppTheme.divider, height: 1),
                const SizedBox(height: 8),
                ...reasons.map((r) => GestureDetector(
                      onTap: () => setSheet(() => selected = r),
                      child: Container(
                        color: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: selected == r
                                        ? AppTheme.brand
                                        : AppTheme.divider,
                                    width: 2),
                                color: selected == r
                                    ? AppTheme.brand
                                    : Colors.transparent,
                              ),
                              child: selected == r
                                  ? const Icon(Icons.check,
                                      color: AppTheme.bg, size: 12)
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Text(r,
                                style: const TextStyle(
                                    color: AppTheme.textPrimary, fontSize: 14)),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 16),
                SolidConfirmButton(
                  label: 'Submit Report',
                  icon: Icons.flag_outlined,
                  height: AppConstants.kDefaultButtonHeightLarge,
                  onPressed: selected == null
                      ? null
                      : () {
                          HapticFeedback.selectionClick();
                          Navigator.pop(ctx);
                          AppUtils.showToast(
                              context, 'Report submitted. Thank you.');
                        },
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _showFeedbackModal(BuildContext context) {
    final List<Map<String, dynamic>> mockFeedback = [
      {
        'author': 'Trainer Ahmed',
        'rating': 5,
        'date': '2024-03-22',
        'content':
            'Incredible commitment throughout the programme. Adherence to the nutrition plan was near-perfect. An ideal client.',
        'verified': true,
      },
      {
        'author': 'Coach Sarah',
        'rating': 5,
        'date': '2024-02-15',
        'content':
            'Always on time, fully prepared, and pushes through every set. Communication is excellent.',
        'verified': true,
      },
      {
        'author': 'Mike D.',
        'rating': 4,
        'date': '2024-01-10',
        'content':
            'Great work ethic and strong discipline. Missed one check-in but quickly caught up.',
        'verified': false,
      },
      {
        'author': 'Anonymous',
        'rating': 3,
        'date': '2023-12-05',
        'content':
            'Good effort but response time over the holidays was slower than usual.',
        'verified': false,
      },
    ];

    String selectedFilter = 'All';
    String selectedSort = 'Newest';

    final avg =
        mockFeedback.map((r) => r['rating'] as int).reduce((a, b) => a + b) /
            mockFeedback.length;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          List<Map<String, dynamic>> displayed = mockFeedback.where((r) {
            if (selectedFilter == 'All') return true;
            return r['rating'].toString() == selectedFilter.split(' ')[0];
          }).toList();

          if (selectedSort == 'Highest') {
            displayed.sort((a, b) => b['rating'].compareTo(a['rating']));
          } else if (selectedSort == 'Lowest') {
            displayed.sort((a, b) => a['rating'].compareTo(b['rating']));
          } else if (selectedSort == 'Oldest') {
            displayed.sort((a, b) => a['date'].compareTo(b['date']));
          } else {
            displayed.sort((a, b) => b['date'].compareTo(a['date']));
          }

          return DraggableScrollableSheet(
            initialChildSize: 0.82,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  const SizedBox(height: 14),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AppTheme.divider,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Trainer Feedback',
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              avg.toStringAsFixed(1),
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: List.generate(
                                    5,
                                    (i) => Icon(
                                      i < avg.round()
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: i < avg.round()
                                          ? AppTheme.cardYellow
                                          : AppTheme.divider,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${mockFeedback.length} reviews',
                                  style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(color: AppTheme.divider, height: 1),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ModalDropdown(
                            value: selectedFilter,
                            items: const [
                              'All',
                              '5 Stars',
                              '4 Stars',
                              '3 Stars'
                            ],
                            onChanged: (v) {
                              if (v == null) return;
                              setModalState(() => selectedFilter = v);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ModalDropdown(
                            value: selectedSort,
                            items: const [
                              'Newest',
                              'Oldest',
                              'Highest',
                              'Lowest'
                            ],
                            onChanged: (v) {
                              if (v == null) return;
                              setModalState(() => selectedSort = v);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.divider, height: 1),
                  Expanded(
                    child: displayed.isEmpty
                        ? const Center(
                            child: Text(
                              'No reviews match this filter.',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.all(24),
                            itemCount: displayed.length,
                            separatorBuilder: (_, __) => const Divider(
                                color: AppTheme.divider, height: 32),
                            itemBuilder: (context, index) {
                              final r = displayed[index];
                              return _ReviewTile(review: r);
                            },
                          ),
                  ),
                ],
              );
            },
          );
        });
      },
    );
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppTheme.divider,
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Share Profile',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 14),
              const Divider(color: AppTheme.divider, height: 1),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppTheme.bg,
                    borderRadius: BorderRadius.circular(
                        AppConstants.kDefaultBorderRadius),
                    border: Border.all(color: AppTheme.divider)),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.link,
                        color: AppTheme.textSecondary, size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'TnT.app/u/${widget.trainee['username']}',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Clipboard.setData(ClipboardData(
                            text:
                                'https://TnT.app/u/${widget.trainee['username']}'));
                        Navigator.pop(context);
                        AppUtils.showToast(context, 'Link copied!');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppTheme.brand.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppTheme.brand.withValues(alpha: 0.3)),
                        ),
                        child: const Text(
                          'Copy',
                          style: TextStyle(
                              color: AppTheme.brand,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final trainee = widget.trainee;

    final currentInjuries = (trainee['currentInjuries'] as List<dynamic>? ?? [])
        .cast<String>()
        .where((i) => MedicalData.commonInjuries.contains(i))
        .toList();
    final pastInjuries = (trainee['pastInjuries'] as List<dynamic>? ?? [])
        .cast<String>()
        .where((i) => MedicalData.commonInjuries.contains(i))
        .toList();
    final medicalConditions =
        (trainee['medicalConditions'] as List<dynamic>? ?? [])
            .cast<String>()
            .where((c) => MedicalData.commonConditions.contains(c))
            .toList();
    final validGoals = MedicalData.getCategorizedGoals(context)
        .expand((c) => c.items.map((i) => i.title))
        .toList();
    final goals = (trainee['goals'] as List<dynamic>? ?? [])
        .cast<String>()
        .where((g) => validGoals.contains(g))
        .toList();
    final experienceOption = TraineeTrainingExperienceData.optionFor(
        trainee['trainingExperienceYears'] ??
            trainee['trainingExperienceLabel']);
    final preferredDiets =
        (trainee['preferredDiets'] as List<dynamic>? ?? const [])
            .whereType<String>()
            .where((diet) => TraineeDietData.allLabels.contains(diet))
            .toList();
    final dietSummary = (trainee['diet'] as String?)?.trim();
    final dietItems = preferredDiets.isNotEmpty
        ? preferredDiets
        : <String>[
            dietSummary != null && dietSummary.isNotEmpty
                ? dietSummary
                : context.l10n.flexibleNoRestrictions,
          ];
    final bodyCompositionData = _metricMapFrom(
      trainee['bodyComp'] ?? trainee['bodyComposition'],
    );
    final bodyCircumferenceData = _metricMapFrom(trainee['circumferences']);

    final dob = trainee['dob'] as DateTime?;
    final int? age = dob != null ? _computeAge(dob) : null;
    final gender = (trainee['gender'] as String? ?? '').trim();

    const int activityScore = 84;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 76,
                    left: 24,
                    right: 24,
                    bottom: MediaQuery.of(context).padding.bottom + 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileAvatar(trainee, experienceOption),
                      const SizedBox(height: 18),
                      Text(
                        '@${trainee['username'] ?? ''}',
                        style: const TextStyle(
                          color: AppTheme.brand,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              '${trainee['firstName'] ?? ''} ${trainee['lastName'] ?? ''}',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),
                          ),
                          if (gender.isNotEmpty) ...[
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.cardBlue.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: AppTheme.cardBlue
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                gender,
                                style: const TextStyle(
                                    color: AppTheme.cardBlue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildLocationMeta(trainee, age),
                      const SizedBox(height: 12),
                      _activityScoreBadge(activityScore),
                      const SizedBox(height: 22),
                      TnTPremiumCard(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        accentColor: AppTheme.brand,
                        child: Row(
                          children: [
                            _statCol('Posts', '${trainee['posts'] ?? '18'}'),
                            Container(
                                width: 1, height: 32, color: AppTheme.divider),
                            _statCol('Followers',
                                '${trainee['followers'] ?? '1.6K'}'),
                            Container(
                                width: 1, height: 32, color: AppTheme.divider),
                            _statCol('Following',
                                '${trainee['following'] ?? '342'}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TnTPremiumCard(
                        onTap: () => _showFeedbackModal(context),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        accentColor: AppTheme.cardYellow,
                        child: Row(
                          children: [
                            ...List.generate(
                              5,
                              (i) => Icon(
                                i < 4 ? Icons.star : Icons.star_half,
                                color: AppTheme.cardYellow,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '4.3  ·  24 trainer reviews',
                              style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right,
                                color: AppTheme.textSecondary, size: 18),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if ((trainee['bio'] as String?)?.trim().isNotEmpty ==
                          true) ...[
                        TnTPremiumCard(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          accentColor: AppTheme.brand,
                          child: Text(
                            trainee['bio'] as String,
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                                height: 1.55),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: OutlineActionButton(
                              label: _isFollowing ? 'Following' : 'Follow',
                              icon: Icon(
                                _isFollowing
                                    ? Icons.check
                                    : Icons.person_add_outlined,
                                color: AppTheme.brand,
                                size: 18,
                              ),
                              height: AppConstants.kDefaultButtonHeightLarge,
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                setState(() => _isFollowing = !_isFollowing);
                                AppUtils.showToast(
                                    context,
                                    _isFollowing
                                        ? 'Now following!'
                                        : 'Unfollowed');
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SolidConfirmButton(
                              label: 'Message',
                              icon: Icons.chat_bubble_outline,
                              height: AppConstants.kDefaultButtonHeightLarge,
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                AppUtils.launchLink(
                                  context,
                                  'https://example.com/message/${trainee['username']}',
                                  fromChat: false,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      OutlineActionButton(
                        label: 'Invite to Train',
                        icon: const Icon(CupertinoIcons.person_badge_plus,
                            color: AppTheme.brand, size: 18),
                        height: AppConstants.kDefaultButtonHeightLarge,
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          AppUtils.showToast(context, 'Invitation sent!');
                        },
                      ),
                      if (bodyCompositionData.isNotEmpty ||
                          bodyCircumferenceData.isNotEmpty) ...[
                        _sectionDivider(),
                        _sectionHeader('Body Metrics',
                            icon: Icons.monitor_heart_outlined),
                        _bodyMetricButton(
                          label: context.l10n.bodyComposition,
                          subtitle: 'Review body composition and trends',
                          icon: Icons.insights_outlined,
                          color: AppTheme.cardBlue,
                          onTap: bodyCompositionData.isEmpty
                              ? null
                              : () {
                                  HapticFeedback.selectionClick();
                                  Navigator.push(
                                    context,
                                    AppRoutes.noTransitionRoute(
                                      _ReadOnlyStatsScreen(
                                        title: context.l10n.bodyComposition,
                                        data: bodyCompositionData,
                                      ),
                                    ),
                                  );
                                },
                        ),
                        const SizedBox(height: 10),
                        _bodyMetricButton(
                          label: context.l10n.circumferences,
                          subtitle: 'Review circumference measurements',
                          icon: Icons.straighten,
                          color: AppTheme.cardGreen,
                          onTap: bodyCircumferenceData.isEmpty
                              ? null
                              : () {
                                  HapticFeedback.selectionClick();
                                  Navigator.push(
                                    context,
                                    AppRoutes.noTransitionRoute(
                                      BodyCircumferenceTrackerScreen(
                                        title: context.l10n.circumferences,
                                        data: bodyCircumferenceData,
                                        measurementUnit:
                                            appState.measurementUnit == 'metric'
                                                ? 'cm'
                                                : 'in',
                                      ),
                                    ),
                                  );
                                },
                        ),
                      ],
                      _sectionDivider(),
                      _sectionHeader(context.l10n.trainingGoals,
                          icon: Icons.flag_outlined),
                      _buildChipList(context, goals, AppTheme.brand),
                      _sectionDivider(),
                      _sectionHeader(context.l10n.dietaryApproach,
                          icon: Icons.restaurant_outlined),
                      _buildChipList(context, dietItems, AppTheme.cardGreen),
                      _sectionDivider(),
                      _sectionHeader(context.l10n.healthAndMedical,
                          icon: CupertinoIcons.heart),
                      _subLabel(context.l10n.currentInjuries),
                      const SizedBox(height: 10),
                      _buildChipList(context, currentInjuries, AppTheme.error),
                      const SizedBox(height: 20),
                      _subLabel(context.l10n.pastInjuries),
                      const SizedBox(height: 10),
                      _buildChipList(
                          context, pastInjuries, AppTheme.cardYellow),
                      const SizedBox(height: 20),
                      _subLabel(context.l10n.medicalConditions),
                      const SizedBox(height: 10),
                      _buildChipList(
                          context, medicalConditions, AppTheme.cardBlue),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 14,
            child: _FloatingIconButton(
              icon: Icons.arrow_back,
              onTap: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 14,
            child: Row(
              children: [
                _FloatingIconButton(
                  icon: CupertinoIcons.share,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showShareSheet(context);
                  },
                ),
                const SizedBox(width: 8),
                _FloatingIconButton(
                  icon: Icons.flag_outlined,
                  iconColor: Colors.redAccent,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showReportDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _subLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      );

  Widget _buildProfileAvatar(
    Map<String, dynamic> trainee,
    TrainingExperienceOption experienceOption,
  ) {
    final name =
        '${trainee['firstName'] ?? ''} ${trainee['lastName'] ?? ''}'.trim();
    final username = (trainee['username'] as String? ?? '').trim();
    final role = (trainee['role'] as String? ?? 'Trainee').trim();
    final isTrainer = role.toLowerCase() == 'trainer';
    final experienceLabel = experienceOption.localizedLabel(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 112,
          height: 112,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.bg,
            border: Border.all(color: AppTheme.divider, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: _GeneratedTraineeAvatar(
            name: name,
            username: username,
            size: 104,
          ),
        ),
        if (isTrainer)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.bg,
                border: Border.all(color: AppTheme.bg, width: 2),
              ),
              child: const Icon(
                CupertinoIcons.checkmark_seal_fill,
                color: AppTheme.brand,
                size: 24,
              ),
            ),
          )
        else
          Positioned(
            bottom: -6,
            right: -22,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                TraineeTrainingExperienceData.showHelpDialog(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: experienceOption.color,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppTheme.bg, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      experienceLabel,
                      style: const TextStyle(
                        color: AppTheme.bg,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.help_outline_rounded,
                        color: AppTheme.bg, size: 12),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLocationMeta(Map<String, dynamic> trainee, int? age) {
    final rawCountry = trainee['countryOfResidence'] as String?;
    final countryEntry = _resolveCountryEntry(rawCountry);
    final fallbackCountry = _fallbackCountryLabel(rawCountry);
    final region = (trainee['region'] as String? ?? '').trim();

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.location_solid,
                color: AppTheme.textSecondary, size: 13),
            const SizedBox(width: 5),
            if (countryEntry != null)
              DefaultTextStyle.merge(
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
                child: CountryFlagWidget(textData: countryEntry),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.public,
                      color: AppTheme.textSecondary, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    fallbackCountry.isNotEmpty
                        ? fallbackCountry
                        : 'Location not set',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
          ],
        ),
        if (region.isNotEmpty) _metaDotText(region),
        if (age != null) _metaDotText('$age years old'),
      ],
    );
  }

  Widget _metaDotText(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 3,
          height: 3,
          decoration: BoxDecoration(
            color: AppTheme.textSecondary.withValues(alpha: 0.65),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
      ],
    );
  }

  String? _resolveCountryEntry(String? rawCountry) {
    final raw = rawCountry?.trim() ?? '';
    if (raw.isEmpty) return null;

    final rawPath = raw.flagSvgPath;
    final rawLabel = raw.textWithoutFlag.toLowerCase();
    for (final entry in AppConstants.kCountriesOnly) {
      if (rawPath.isNotEmpty && entry.flagSvgPath == rawPath) return entry;
      if (rawLabel.isNotEmpty &&
          entry.textWithoutFlag.toLowerCase() == rawLabel) {
        return entry;
      }
    }
    return null;
  }

  String _fallbackCountryLabel(String? rawCountry) {
    final raw = rawCountry?.trim() ?? '';
    if (raw.isEmpty) return '';
    final label = raw.textWithoutFlag.trim();
    return label.startsWith('assets/images/flags/') ? '' : label;
  }
}

// =============================================================================
// GENERATED MOCK AVATAR
// =============================================================================
class _GeneratedTraineeAvatar extends StatelessWidget {
  final String name;
  final String username;
  final double size;

  const _GeneratedTraineeAvatar({
    required this.name,
    required this.username,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final seedText = '$name$username'.trim();
    final seed = seedText.codeUnits.fold<int>(0, (sum, code) => sum + code);
    final palettes = [
      const [Color(0xFF2667FF), Color(0xFF42E8D4)],
      const [Color(0xFF18A058), Color(0xFFE6C64A)],
      const [Color(0xFFE85D75), Color(0xFF7C5CFF)],
      const [Color(0xFFEF7D3C), Color(0xFF23B8D4)],
    ];
    final palette = palettes[seed % palettes.length];
    final initials = name.trim().split(RegExp(r'\s+')).take(2).map((w) {
      return w.isNotEmpty ? w[0].toUpperCase() : '';
    }).join();

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: palette,
                ),
              ),
            ),
            Positioned(
              top: -size * 0.18,
              right: -size * 0.12,
              child: Container(
                width: size * 0.58,
                height: size * 0.58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -size * 0.16,
              bottom: -size * 0.14,
              child: Container(
                width: size * 0.5,
                height: size * 0.5,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Center(
              child: Text(
                initials.isNotEmpty ? initials : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
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
// FLOATING ICON BUTTON
// =============================================================================
class _FloatingIconButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  const _FloatingIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: AppTheme.bg.withValues(alpha: 0.88),
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.divider.withValues(alpha: 0.6)),
        ),
        child: Icon(icon, color: iconColor ?? AppTheme.textPrimary, size: 19),
      ),
    );
  }
}

// =============================================================================
// MODAL DROPDOWN HELPER
// =============================================================================
class _ModalDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _ModalDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: AppTheme.surface,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppTheme.textSecondary, size: 18),
          isExpanded: true,
          style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600),
          items: items
              .map((v) => DropdownMenuItem<String>(value: v, child: Text(v)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// =============================================================================
// REVIEW TILE
// =============================================================================
class _ReviewTile extends StatelessWidget {
  final Map<String, dynamic> review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppTheme.brand.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: AppTheme.brand.withValues(alpha: 0.2)),
                ),
                alignment: Alignment.center,
                child: Text(
                  (review['author'] as String).isNotEmpty
                      ? (review['author'] as String)[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      color: AppTheme.brand,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(review['author'],
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    if (review['verified'] == true) ...[
                      const SizedBox(width: 5),
                      const Icon(CupertinoIcons.checkmark_seal_fill,
                          color: AppTheme.brand, size: 14),
                    ],
                  ]),
                  Text(review['date'],
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11)),
                ],
              ),
            ]),
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < (review['rating'] as int)
                      ? Icons.star
                      : Icons.star_border,
                  color: i < (review['rating'] as int)
                      ? AppTheme.cardYellow
                      : AppTheme.divider,
                  size: 15,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          review['content'],
          style: const TextStyle(
              color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
        ),
      ],
    );
  }
}

// =============================================================================
// READ-ONLY STATS SCREEN
// =============================================================================
// ignore: unused_element
class _ReadOnlyStatsScreen extends StatefulWidget {
  final String title;
  final Map<String, dynamic> data;
  final bool isCircumference;

  const _ReadOnlyStatsScreen({
    required this.title,
    required this.data,
    // ignore: unused_element_parameter
    this.isCircumference = false,
  });

  @override
  State<_ReadOnlyStatsScreen> createState() => _ReadOnlyStatsScreenState();
}

class _ReadOnlyStatsScreenState extends State<_ReadOnlyStatsScreen> {
  String _selectedTimeline = 'Currently';

  // ── CHANGE 1: Canonical circumference order matching the screenshot ─────────
  // Order: Neck, Shoulder, Chest, Arms, Forearms, Waist, Hips, Thighs, Legs
  // ignore: unused_field
  static const List<String> _circOrder = [
    'Neck',
    'Shoulder',
    'Chest',
    'Arms',
    'Forearms',
    'Waist',
    'Hips',
    'Thighs',
    'Legs',
  ];

  // ── CHANGE 2: Track which series are hidden (toggled off) ────────────────────
  late final BodyPartVisibilityBloc _bodyPartVisibilityBloc;

  @override
  void initState() {
    super.initState();
    _bodyPartVisibilityBloc =
        BodyPartVisibilityBloc(availableBodyParts: _sortedKeys);
  }

  @override
  void dispose() {
    _bodyPartVisibilityBloc.close();
    super.dispose();
  }

  /// Returns keys in canonical order (circumference) or declaration order (body comp).
  List<String> get _sortedKeys {
    return _displayData.keys.toList(growable: false);
  }

  Map<String, dynamic> get _displayData {
    if (!widget.isCircumference) {
      return widget.data;
    }
    return normalizeBodyCircumferenceData(widget.data);
  }

  Set<String> get _hiddenKeys => _bodyPartVisibilityBloc.state.hiddenBodyParts;

  // ignore: unused_element
  List<String> get _visibleKeys =>
      _sortedKeys.where((key) => !_hiddenKeys.contains(key)).toList();

  List<String> get _timelines => ['Currently', 'Weekly', 'Monthly', 'Annually'];

  List<String> _getXLabels() {
    if (_selectedTimeline == 'Currently') return ['Now'];
    if (_selectedTimeline == 'Weekly') {
      return ['16 Jun', '23 Jun', '30 Jun', '07 Jul'];
    }
    if (_selectedTimeline == 'Monthly') {
      return ['Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
    }
    if (_selectedTimeline == 'Annually') {
      return ['2020', '2021', '2022', '2023', '2024', '2025'];
    }
    return [];
  }

  List<double> _getMetricValues(String metricKey) {
    final baseVal = _currentValueForKey(metricKey);
    final isDesc = metricKey == 'Total Body Weight' ||
        metricKey == 'Fat Mass' ||
        metricKey == 'Body Fat %' ||
        metricKey == 'Waist';
    final sign = isDesc ? 1.0 : -1.0;

    if (_selectedTimeline == 'Weekly') {
      return [
        baseVal + sign * 2.5,
        baseVal + sign * 1.8,
        baseVal + sign * 1.0,
        baseVal
      ];
    } else if (_selectedTimeline == 'Monthly') {
      return [
        baseVal + sign * 8.0,
        baseVal + sign * 6.0,
        baseVal + sign * 4.0,
        baseVal + sign * 2.0,
        baseVal + sign * 1.0,
        baseVal,
      ];
    } else if (_selectedTimeline == 'Annually') {
      return [
        baseVal + sign * 15.0,
        baseVal + sign * 12.0,
        baseVal + sign * 9.0,
        baseVal + sign * 6.0,
        baseVal + sign * 3.0,
        baseVal,
      ];
    }
    return [baseVal];
  }

  double _currentValueForKey(String key) {
    final valStr = _displayData[key]?.toString() ?? '';
    final match = RegExp(r'[0-9]+(\.[0-9]+)?').firstMatch(valStr);
    final numericValue = match?.group(0);
    return numericValue != null ? double.parse(numericValue) : 0.0;
  }

  String _unitForKey(String key) {
    if (!widget.isCircumference) {
      return BodyCompData.units[key] != null
          ? ' ${BodyCompData.units[key]}'
          : '';
    }
    final valStr = _displayData[key]?.toString() ?? '';
    final match = RegExp(r'[a-zA-Z%]+').firstMatch(valStr);
    return match != null ? ' ${match.group(0)}' : ' cm';
  }

  // ── CHANGE 3: Color index is now based on position in _sortedKeys (stable) ──
  /// Specific overrides for circumference body-part colours.
  // ignore: unused_field
  static const Map<String, Color> _circColorOverrides = {
    'Forearms': Color(0xFFCB89B7),
    'Hips': Color(0xFF8C564B),
  };

  Color _getColor(int indexInSortedKeys, {String? key}) {
    if (widget.isCircumference && key != null) {
      final series = bodyCircumferenceSeriesForKey(key);
      if (series != null) {
        return series.color;
      }
    }
    const colors = [
      Color(0xFF1F77B4),
      Color(0xFFFF7F0E),
      Color(0xFF2CA02C),
      Color(0xFFD62728),
      Color(0xFF9467BD),
      Color(0xFF8C564B),
      Color(0xFFE377C2),
      Color(0xFFBCBD22),
      Color(0xFF6CE7E3),
      Color(0xFF29B6F6),
      Color(0xFF66BB6A),
      Color(0xFFFF7043),
      Color(0xFFE91E63),
      Color(0xFF00BCD4),
      Color(0xFF8BC34A),
      Color(0xFFFF9800),
      Color(0xFF607D8B),
    ];
    return colors[indexInSortedKeys % colors.length];
  }

  IconData _iconFor(String key) {
    if (!widget.isCircumference) {
      return BodyCompData.iconFor(key);
    }
    return bodyCircumferenceSeriesForKey(key)?.icon ?? Icons.straighten;
  }

  String _circAssetPath(String key) {
    return bodyCircumferenceSeriesForKey(key)?.assetPath ??
        'assets/images/body_circumference/1_cleidomastoids.png';
  }

  void _showDescriptionDialog(BuildContext context, String key, Color color) {
    final desc = widget.isCircumference
        ? _circDescription(key)
        : (BodyCompData.descriptions[key] ?? 'No description available.');
    final unit =
        widget.isCircumference ? 'cm / in' : (BodyCompData.units[key] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.kDefaultBorderRadius)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 60),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle),
                  child: Icon(_iconFor(key), color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            widget.isCircumference
                                ? (bodyCircumferenceSeriesForKey(key)
                                        ?.localizedLabel(context) ??
                                    key)
                                : key,
                            style: TextStyle(
                                color: color,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        if (unit.isNotEmpty)
                          Text('Unit: $unit',
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 11)),
                      ]),
                ),
              ]),
              const SizedBox(height: 16),
              const Divider(color: AppTheme.divider),
              const SizedBox(height: 12),
              Text(desc,
                  style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.6)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlineActionButton(
                  label: 'Got it',
                  height: AppConstants.kDefaultButtonHeightLarge,
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _circDescription(String key) {
    final normalizedDescription =
        bodyCircumferenceSeriesForKey(key)?.description;
    if (normalizedDescription != null) {
      return normalizedDescription;
    }
    const m = <String, String>{
      'Neck':
          'Circumference of the neck at its narrowest point. Elevated neck girth can correlate with sleep apnea risk and cardiovascular markers.',
      'Shoulder':
          'Circumference around the widest part of the shoulders. Tracks upper body development and shoulder width relative to waist (V-taper).',
      'Chest':
          'Circumference around the fullest part of the chest. A primary hypertrophy indicator for the pectorals, lats, and upper back.',
      'Arms':
          'Circumference of the upper arm (bicep peak, typically flexed). The classic measure of arm muscle development.',
      'Forearms':
          'Circumference of the forearm at its widest point. Reflects grip strength development and lower arm hypertrophy.',
      'Wrist':
          'Circumference of the wrist joint. Used as a frame-size indicator in body composition formulas.',
      'Waist':
          'Circumference at the narrowest torso point, typically at the navel or just above the iliac crest. A key health risk indicator — lower is better.',
      'Hips':
          'Circumference at the widest point of the hips/glutes. Used alongside waist to calculate the Waist-to-Hip ratio, a cardiovascular risk marker.',
      'Thighs':
          'Circumference of the upper thigh at its widest point. Tracks quadriceps, hamstring, and adductor hypertrophy.',
      'Legs':
          'Circumference of the calf muscle at its fullest point. One of the hardest muscle groups to develop; a measure of lower leg power.',
    };
    return m[key] ?? 'Circumference measurement for this body segment.';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bodyPartVisibilityBloc,
      child: Scaffold(
        backgroundColor: AppTheme.bg,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppTheme.bg,
          iconTheme: const IconThemeData(color: AppTheme.textPrimary),
          title:
              Text(widget.title, style: const TextStyle(color: AppTheme.brand)),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Timeline pills ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: _timelines.map((tl) {
                  final isSelected = tl == _selectedTimeline;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedTimeline = tl);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color:
                                isSelected ? AppTheme.brand : AppTheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: isSelected
                                    ? AppTheme.brand
                                    : AppTheme.divider)),
                        child: Text(tl,
                            style: TextStyle(
                                color: isSelected
                                    ? AppTheme.bg
                                    : AppTheme.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            if (_selectedTimeline != 'Currently') ...[
              Expanded(child: _buildMultiLineChart()),
              const SizedBox(height: 16),
            ] else ...[
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(_sortedKeys.length, (index) {
                      final key = _sortedKeys[index];
                      final color = _getColor(index, key: key);
                      // Card width: (screen - padding - gaps) / 3
                      final cardWidth =
                          (MediaQuery.of(context).size.width - 28 - 20) / 3;
                      return SizedBox(
                        width: cardWidth,
                        height: cardWidth / 0.82,
                        child: Container(
                          decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(
                                  AppConstants.kDefaultBorderRadius),
                              border: Border.all(color: AppTheme.divider)),
                          child: Stack(children: [
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // SVG/PNG renders without a color tint; fallback icon keeps its color
                                  widget.isCircumference
                                      ? Image.asset(
                                          _circAssetPath(key),
                                          width: 81,
                                          height: 81,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) => Icon(
                                              _iconFor(key),
                                              color: color,
                                              size: 58.5),
                                        )
                                      : Icon(_iconFor(key),
                                          color: color, size: 39),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6),
                                    child: Text(
                                        widget.isCircumference
                                            ? (bodyCircumferenceSeriesForKey(
                                                        key)
                                                    ?.localizedLabel(context) ??
                                                key)
                                            : key,
                                        style: TextStyle(
                                            color: AppTheme.textSecondary
                                                .withValues(alpha: 0.85),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(_displayData[key].toString(),
                                          style: TextStyle(
                                              color: color,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 3),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 1),
                                        child: Text(
                                          widget.isCircumference
                                              ? (appState.measurementUnit ==
                                                      'metric'
                                                  ? 'cm'
                                                  : 'in')
                                              : (BodyCompData.units[key] ?? ''),
                                          style: TextStyle(
                                              color:
                                                  color.withValues(alpha: 0.65),
                                              fontSize: 9,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ]),
                            // ? info button — retains its per-body-part color tint
                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  _showDescriptionDialog(context, key, color);
                                },
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.18),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: color.withValues(alpha: 0.4),
                                        width: 1),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('?',
                                      style: TextStyle(
                                          color: color,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          height: 1)),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  double _toLog(double v) => v > 0 ? (math.log(v) / math.ln10) : 0.0;
  double _fromLog(double logV) => math.pow(10, logV).toDouble();

  Widget _buildMultiLineChart() {
    final xLabels = _getXLabels();
    if (xLabels.isEmpty) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<BodyPartVisibilityBloc, BodyPartVisibilityState>(
      builder: (context, state) {
        // ── CHANGE 4: Use _sortedKeys for stable color mapping; only render visible ones ──
        final allKeys = _sortedKeys;
        final visibleKeys = allKeys
            .where((key) => state.isVisible(key))
            .toList(growable: false);

        List<LineChartBarData> lineBarsData = [];
        double globalMinLog = double.infinity;
        double globalMaxLog = double.negativeInfinity;

        for (final key in visibleKeys) {
          // stable color index from full sorted list
          final colorIdx = allKeys.indexOf(key);
          final rawValues = _getMetricValues(key);
          final color = _getColor(colorIdx, key: key);
          final logValues = rawValues
              .map((v) =>
                  _toLog(v.abs().clamp(0.01, double.infinity).toDouble()))
              .toList();

          for (final lv in logValues) {
            if (lv < globalMinLog) globalMinLog = lv;
            if (lv > globalMaxLog) globalMaxLog = lv;
          }

          final spots = logValues
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), e.value))
              .toList();

          lineBarsData.add(LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: color,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
                radius: 3.5,
                color: color,
                strokeWidth: 1.5,
                strokeColor: AppTheme.bg,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color.withValues(alpha: 0.08), Colors.transparent],
              ),
            ),
          ));
        }

        if (globalMinLog == double.infinity) {
          globalMinLog = 0;
          globalMaxLog = 2;
        }
        final double logRange = (globalMaxLog - globalMinLog)
            .clamp(0.1, double.infinity)
            .toDouble();
        final double minY = globalMinLog - logRange * 0.08;
        final double maxY = globalMaxLog + logRange * 0.08;
        final xCount = xLabels.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Chart ────────────────────────────────────────────────────────────
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                padding: const EdgeInsets.fromLTRB(4, 16, 12, 4),
                decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(
                        AppConstants.kDefaultBorderRadius),
                    border: Border.all(color: AppTheme.divider)),
                child: lineBarsData.isEmpty
                    ? Center(
                        child: Text(
                            '${context.l10n.allSeriesHidden}\n${context.l10n.tapBodyPartToShowSeries}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13)),
                      )
                    : LineChart(
                        LineChartData(
                          minY: minY,
                          maxY: maxY,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: logRange / 4,
                            getDrawingHorizontalLine: (_) => FlLine(
                              color: AppTheme.divider.withValues(alpha: 0.5),
                              strokeWidth: 1,
                              dashArray: [4, 6],
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 42,
                                getTitlesWidget: (logV, meta) {
                                  final real = _fromLog(logV);
                                  String label;
                                  if (real >= 1000) {
                                    label =
                                        '${(real / 1000).toStringAsFixed(1)}k';
                                  } else if (real >= 100) {
                                    label = real.toStringAsFixed(0);
                                  } else {
                                    label = real.toStringAsFixed(1);
                                  }
                                  return Text(label,
                                      style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w500));
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  final i = value.toInt();
                                  if (i < 0 || i >= xCount) {
                                    return const SizedBox.shrink();
                                  }
                                  final skipEvery = xCount > 5 ? 2 : 1;
                                  if (xCount > 5 && i % skipEvery != 0) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(xLabels[i],
                                        style: const TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500)),
                                  );
                                },
                              ),
                            ),
                          ),
                          lineTouchData: LineTouchData(
                            handleBuiltInTouches: true,
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (_) => const Color(0xFF0D0F11)
                                  .withValues(alpha: 0.97),
                              fitInsideHorizontally: true,
                              fitInsideVertically: true,
                              tooltipBorder: const BorderSide(
                                  color: Color(0xFF2A2D32), width: 1),
                              tooltipPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              getTooltipItems: (touchedSpots) {
                                final sorted = [...touchedSpots]
                                  ..sort((a, b) => b.y.compareTo(a.y));
                                return sorted.map((LineBarSpot s) {
                                  // map bar index back to visible key
                                  final key = visibleKeys[s.barIndex];
                                  final colorIdx = allKeys.indexOf(key);
                                  final color = _getColor(colorIdx, key: key);
                                  final unit = _unitForKey(key);
                                  final realVal = _fromLog(s.y);
                                  final valStr = realVal >= 1000
                                      ? '${(realVal / 1000).toStringAsFixed(1)}k'
                                      : realVal >= 100
                                          ? realVal.toStringAsFixed(0)
                                          : realVal.toStringAsFixed(1);
                                  return LineTooltipItem(
                                    '',
                                    const TextStyle(fontSize: 0),
                                    children: [
                                      TextSpan(
                                        text: '▌ ',
                                        style: TextStyle(
                                            color: color,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: widget.isCircumference
                                            ? (bodyCircumferenceSeriesForKey(
                                                        key)
                                                    ?.localizedLabel(context) ??
                                                key)
                                            : key,
                                        style: TextStyle(
                                            color: AppTheme.textSecondary
                                                .withValues(alpha: 0.9),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const TextSpan(
                                        text: '  ·  ',
                                        style: TextStyle(
                                            color: AppTheme.divider,
                                            fontSize: 11),
                                      ),
                                      TextSpan(
                                        text: '$valStr$unit',
                                        style: TextStyle(
                                            color: color,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          lineBarsData: lineBarsData,
                        ),
                      ),
              ),
            ),

            // ── Legend / filter tags — icon + text, left-aligned, horizontally scrollable ──
            Container(
              margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius:
                    BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                border: Border.all(color: AppTheme.divider),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(allKeys.length, (i) {
                    final key = allKeys[i];
                    final color = _getColor(i, key: key);
                    final isHidden = !state.isVisible(key);
                    final iconData = widget.isCircumference
                        ? _iconFor(key)
                        : BodyCompData.iconFor(key);
                    final label = widget.isCircumference
                        ? (bodyCircumferenceSeriesForKey(key)
                                ?.localizedLabel(context) ??
                            key)
                        : key;
                    return Padding(
                      padding: EdgeInsets.only(
                          right: i < allKeys.length - 1 ? 6 : 0),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          context
                              .read<BodyPartVisibilityBloc>()
                              .add(ToggleBodyPartVisibility(key));
                        },
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: isHidden ? 0.4 : 1.0,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isHidden
                                  ? AppTheme.surfaceLow
                                  : color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isHidden
                                    ? AppTheme.outlineSoft
                                    : color.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  iconData,
                                  color:
                                      isHidden ? AppTheme.textTertiary : color,
                                  size: 13,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  label,
                                  style: TextStyle(
                                    color: isHidden
                                        ? AppTheme.textTertiary
                                        : color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (isHidden) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.visibility_off_outlined,
                                    color: AppTheme.textTertiary,
                                    size: 10,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
