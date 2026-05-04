import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/goal_model.dart';
import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_en.dart';
import 'animations/motion.dart';
import 'c_constants.dart';
import 'c_ui_theme.dart';
import 'c_warnings.dart';

class TrainingExperienceOption {
  final int years;
  final String label;
  final Color color;
  final String description;

  const TrainingExperienceOption({
    required this.years,
    required this.label,
    required this.color,
    required this.description,
  });
}

class TraineeTrainingExperienceData {
  static const List<TrainingExperienceOption> options = [
    TrainingExperienceOption(
      years: 0,
      label: '0 Years',
      color: Color(0xFF94A3B8),
      description:
          'Select this if you have not trained consistently yet, are starting structured workouts for the first time, or have only had occasional and inconsistent exposure. This means personal physical training experience, not professional coaching experience.',
    ),
    TrainingExperienceOption(
      years: 1,
      label: '1 Year',
      color: AppTheme.cardBlue,
      description:
          'Select this if you have basic beginner experience and are still learning consistency, common exercises, safe technique, and how your body responds to training. Choose this honestly even if you have tried several workouts before.',
    ),
    TrainingExperienceOption(
      years: 2,
      label: '2 Years',
      color: Color(0xFF38BDF8),
      description:
          'Select this if you have built stronger foundations, understand basic routines, and have some exposure to gradual progression. You may still need guidance with programming, exercise selection, and technique refinement.',
    ),
    TrainingExperienceOption(
      years: 3,
      label: '3 Years',
      color: AppTheme.cardGreen,
      description:
          'Select this if you are early-intermediate: you can follow structured plans, recognize common exercise patterns, and understand the basics of warming up, form, effort, and recovery.',
    ),
    TrainingExperienceOption(
      years: 4,
      label: '4 Years',
      color: Color(0xFF22C55E),
      description:
          'Select this if you have consistent intermediate experience, better body awareness, and more confidence with training variety. You likely know which movements suit you, but still benefit from expert planning and feedback.',
    ),
    TrainingExperienceOption(
      years: 5,
      label: '5 Years',
      color: AppTheme.cardYellow,
      description:
          'Select this if you have solid intermediate experience and understand progressive overload, recovery, and training consistency. This level reflects reliable personal training history, not certification or coaching authority.',
    ),
    TrainingExperienceOption(
      years: 6,
      label: '6 Years',
      color: Color(0xFFF59E0B),
      description:
          'Select this if you are an advanced recreational trainee with long-term consistency and experience managing more structured training phases. You may understand deloads, goal blocks, and fatigue better than most casual trainees.',
    ),
    TrainingExperienceOption(
      years: 7,
      label: '7 Years',
      color: AppTheme.cardPink,
      description:
          'Select this if you have strong practical experience, broad exercise familiarity, and better self-monitoring. You likely recognize when technique, load, recovery, or programming needs adjustment.',
    ),
    TrainingExperienceOption(
      years: 8,
      label: '8 Years',
      color: AppTheme.cardPurple,
      description:
          'Select this if you have extensive training exposure, strong body awareness, and experience with multiple goals or methods. This can include strength, physique, conditioning, sport preparation, or mixed training styles.',
    ),
    TrainingExperienceOption(
      years: 9,
      label: '9 Years',
      color: AppTheme.cardIndigo,
      description:
          'Select this if you are highly experienced recreationally and likely understand technique, progression, recovery, and consistency very well. Choose this based on sustained personal practice, not occasional years away from training.',
    ),
    TrainingExperienceOption(
      years: 10,
      label: '+10 Years',
      color: AppTheme.cardRed,
      description:
          'Select this if you have a long-term, extensive personal training history across many years. This does not automatically mean you are a certified trainer or coach; it only describes your own physical training background.',
    ),
  ];

  static int normalizeYears(dynamic value) {
    if (value is int) {
      if (value < 0) return 0;
      if (value > 10) return 10;
      return value;
    }
    if (value is String) {
      final normalized = value.trim();
      if (normalized.contains('+10')) return 10;
      final match = RegExp(r'\d+').firstMatch(normalized);
      if (match != null) {
        return normalizeYears(int.tryParse(match.group(0) ?? '') ?? 0);
      }
    }
    return 0;
  }

  static TrainingExperienceOption optionFor(dynamic value) {
    final years = normalizeYears(value);
    return options.firstWhere(
      (option) => option.years == years,
      orElse: () => options.first,
    );
  }

  static String labelFor(dynamic value) => optionFor(value).label;

  static Future<void> showOptionHelpDialog(
    BuildContext context,
    TrainingExperienceOption option,
  ) {
    return AppMotion.showPremiumDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        titlePadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
        ),
        title: _DialogTitle(title: option.label),
        content: SingleChildScrollView(
          child: Text(
            option.description,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: AppConstants.kDefaultSubtitleFontSize,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(ctx);
            },
            child: const Text(
              'Close',
              style: TextStyle(
                color: AppTheme.brand,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  static Future<void> showHelpDialog(BuildContext context) {
    return AppMotion.showPremiumDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        titlePadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
        ),
        title: const _DialogTitle(title: 'Training Experience'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose the level that best reflects your own consistent physical training history. This is about personal training experience, not professional coaching experience.',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: AppConstants.kDefaultSubtitleFontSize,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Base your choice on consistency, exposure to structured workouts, technique awareness, progression, recovery habits, and your ability to train safely without constant supervision.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              ...options.map(
                (option) => _ExperienceGuideRow(
                  label: option.label,
                  color: option.color,
                  text: option.description,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Selecting honestly helps trainers match the right intensity, cues, progressions, and safety checks to your real background.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(ctx);
            },
            child: const Text(
              'Close',
              style: TextStyle(
                color: AppTheme.brand,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class TrainingExperienceSelector extends StatefulWidget {
  final String title;
  final int? selectedYears;
  final ValueChanged<int> onSelected;
  final bool showRequiredWarning;
  final String warningText;

  const TrainingExperienceSelector({
    super.key,
    this.title = 'Training Experience',
    required this.selectedYears,
    required this.onSelected,
    this.showRequiredWarning = false,
    this.warningText = 'Please select your training experience.',
  });

  @override
  State<TrainingExperienceSelector> createState() =>
      _TrainingExperienceSelectorState();
}

class _TrainingExperienceSelectorState
    extends State<TrainingExperienceSelector> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final selectedOption = widget.selectedYears == null
        ? null
        : TraineeTrainingExperienceData.optionFor(widget.selectedYears);
    final title = widget.title == 'Physical Training Experience' ||
            widget.title == 'Training Experience'
        ? l10n.physicalTrainingExperience
        : widget.title;
    final warningText = widget.warningText ==
                'Please select your physical training experience.' ||
            widget.warningText == 'Please select your training experience.'
        ? l10n.trainingExperienceRequired
        : widget.warningText;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: AppConstants.kDefaultSubtitleFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(
                  minHeight: 36,
                  minWidth: 36,
                ),
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.help_outline_rounded,
                  color: AppTheme.brand,
                  size: 20,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  TraineeTrainingExperienceData.showHelpDialog(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: AppConstants.kDefaultButtonHeightLarge,
            ),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(AppConstants.kDefaultBorderRadius),
              border: Border.all(color: AppTheme.textSecondary, width: 1.5),
            ),
            child: Column(
              children: [
                InkWell(
                  borderRadius:
                      BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _expanded = !_expanded);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedOption?.label ??
                                l10n.trainingExperienceRequired,
                            style: TextStyle(
                              color: selectedOption == null
                                  ? AppTheme.textSecondary
                                  : AppTheme.textPrimary,
                              fontSize: AppConstants.kDefaultSubtitleFontSize,
                              fontWeight: selectedOption == null
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 180),
                          child: const Icon(
                            Icons.arrow_drop_down,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    children: [
                      const Divider(color: AppTheme.divider, height: 1),
                      RadioGroup<int>(
                        groupValue: widget.selectedYears,
                        onChanged: (years) {
                          if (years == null) return;
                          HapticFeedback.selectionClick();
                          widget.onSelected(years);
                          setState(() => _expanded = false);
                        },
                        child: Column(
                          children: TraineeTrainingExperienceData.options
                              .map((option) {
                            return RadioListTile<int>(
                              value: option.years,
                              activeColor: option.color,
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 0,
                              ),
                              secondary: IconButton(
                                visualDensity: VisualDensity.compact,
                                constraints: const BoxConstraints(
                                  minHeight: 36,
                                  minWidth: 36,
                                ),
                                splashRadius: 18,
                                icon: Icon(
                                  Icons.help_outline_rounded,
                                  color: option.color,
                                  size: 18,
                                ),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  TraineeTrainingExperienceData
                                      .showOptionHelpDialog(context, option);
                                },
                              ),
                              title: Text(
                                option.label,
                                style: TextStyle(
                                  color: option.years == widget.selectedYears
                                      ? option.color
                                      : AppTheme.textSecondary,
                                  fontSize:
                                      AppConstants.kDefaultSubtitleFontSize,
                                  fontWeight:
                                      option.years == widget.selectedYears
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 180),
                  sizeCurve: Curves.easeOutCubic,
                ),
              ],
            ),
          ),
          if (widget.showRequiredWarning)
            StandardFormWarningBanner(
              message: warningText,
              isValid: false,
              margin: const EdgeInsets.only(top: 10),
            ),
        ],
      ),
    );
  }
}

class _ExperienceGuideRow extends StatelessWidget {
  final String label;
  final Color color;
  final String text;

  const _ExperienceGuideRow({
    required this.label,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 86,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogTitle extends StatelessWidget {
  final String title;

  const _DialogTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.brand,
              fontWeight: FontWeight.bold,
              fontSize: AppConstants.kDefaultTitleFontSize,
            ),
          ),
        ),
        const Divider(color: AppTheme.divider, height: 1),
      ],
    );
  }
}

class TraineeDietData {
  static const String balancedHealthyEating =
      'Balanced / General healthy eating';

  static const List<GoalCategory> categories = [
    GoalCategory(
      id: 'diet_everyday',
      name: 'Everyday nutrition',
      items: [
        GoalItem(
          id: 'diet_balanced',
          categoryId: 'diet_everyday',
          title: balancedHealthyEating,
          description:
              'A flexible approach built around varied meals, steady portions, and mostly minimally processed foods without strict macro rules. It is useful when you want a sustainable baseline that can support different training goals. Examples: lean protein, whole grains, vegetables.',
        ),
        GoalItem(
          id: 'diet_high_protein',
          categoryId: 'diet_everyday',
          title: 'High-protein diet',
          description:
              'Prioritizes protein intake to support satiety, muscle repair, and training recovery while still balancing carbohydrates, fats, and micronutrients. Examples: eggs, chicken, Greek yogurt.',
        ),
        GoalItem(
          id: 'diet_mediterranean',
          categoryId: 'diet_everyday',
          title: 'Mediterranean diet',
          description:
              'Emphasizes plant-forward meals, olive oil, seafood, legumes, whole grains, and simple minimally processed ingredients. It can be adapted for performance or general health goals without requiring rigid tracking. Examples: grilled fish, lentil soup, Greek salad.',
        ),
        GoalItem(
          id: 'diet_low_fat',
          categoryId: 'diet_everyday',
          title: 'Low-fat diet',
          description:
              'Keeps dietary fat relatively lower while still including essential fats and enough total energy for training. This can suit users who prefer higher carbohydrate meals or lighter cooking methods. Examples: lean meats, rice, low-fat dairy.',
        ),
      ],
    ),
    GoalCategory(
      id: 'diet_macros',
      name: 'Macro-focused approaches',
      items: [
        GoalItem(
          id: 'diet_low_carb',
          categoryId: 'diet_macros',
          title: 'Low-carb diet',
          description:
              'Reduces carbohydrate intake while usually increasing protein, vegetables, and healthy fats. It should still be planned around training demands, energy levels, and food preference. Examples: eggs, chicken, non-starchy vegetables.',
        ),
        GoalItem(
          id: 'diet_ketogenic',
          categoryId: 'diet_macros',
          title: 'Ketogenic diet',
          description:
              'A very-low-carbohydrate, higher-fat pattern that requires consistent carbohydrate restriction and careful food planning. It is a preference, not a universally better approach, and may need extra attention around intense training. Examples: eggs, fish, avocado.',
        ),
        GoalItem(
          id: 'diet_paleo',
          categoryId: 'diet_macros',
          title: 'Paleo-style diet',
          description:
              'Focuses on whole foods inspired by pre-agricultural eating patterns while limiting many processed foods, grains, legumes, and dairy. It can be flexible, but may require planning to cover training fuel and variety. Examples: meat, eggs, fruit.',
        ),
      ],
    ),
    GoalCategory(
      id: 'diet_plant_forward',
      name: 'Plant-forward preferences',
      items: [
        GoalItem(
          id: 'diet_vegetarian',
          categoryId: 'diet_plant_forward',
          title: 'Vegetarian diet',
          description:
              'Excludes meat and fish while often including dairy and eggs depending on preference. Protein, iron-rich foods, and meal variety should be planned intentionally for training support. Examples: eggs, lentils, tofu.',
        ),
        GoalItem(
          id: 'diet_vegan',
          categoryId: 'diet_plant_forward',
          title: 'Vegan diet',
          description:
              'Excludes animal-derived foods and relies fully on plant sources. It can support training well when protein, calories, key micronutrients, and food variety are planned carefully. Examples: tofu, legumes, fortified soy milk.',
        ),
        GoalItem(
          id: 'diet_pescatarian',
          categoryId: 'diet_plant_forward',
          title: 'Pescatarian diet',
          description:
              'Plant-forward eating that includes fish and seafood while usually excluding meat and poultry. It can offer flexible protein options while keeping most meals centered on plants. Examples: salmon, shrimp, legumes.',
        ),
      ],
    ),
    GoalCategory(
      id: 'diet_restrictions',
      name: 'Restrictions and requirements',
      items: [
        GoalItem(
          id: 'diet_gluten_free',
          categoryId: 'diet_restrictions',
          title: 'Gluten-free diet',
          description:
              'Avoids gluten-containing grains such as wheat, barley, and rye. This may be a medical requirement or preference, so food labels and cross-contact risk can matter for some users. Examples: rice, potatoes, quinoa.',
        ),
        GoalItem(
          id: 'diet_dairy_free',
          categoryId: 'diet_restrictions',
          title: 'Dairy-free diet',
          description:
              'Avoids milk-based foods and ingredients while using other foods to cover protein, calcium, and overall energy needs. It can be combined with many other diet styles. Examples: soy yogurt, tofu, dairy-free milk.',
        ),
        GoalItem(
          id: 'diet_halal',
          categoryId: 'diet_restrictions',
          title: 'Halal diet',
          description:
              'Follows Islamic dietary rules by avoiding pork and alcohol and choosing permissible foods and ingredients. Training nutrition can still be balanced within these boundaries. Examples: halal-certified meats, fish, legumes.',
        ),
      ],
    ),
    GoalCategory(
      id: 'diet_timing_custom',
      name: 'Timing and custom',
      items: [
        GoalItem(
          id: 'diet_intermittent_fasting',
          categoryId: 'diet_timing_custom',
          title: 'Intermittent fasting',
          description:
              'Uses planned eating and fasting windows without requiring a specific food list. Meal timing should still support energy, recovery, hydration, and enough total nutrition during the eating window. Examples: 12:12, 14:10, 16:8.',
        ),
        GoalItem(
          id: 'diet_custom',
          categoryId: 'diet_timing_custom',
          title: 'Custom / Other',
          description:
              'Use this when your preference does not fit the listed options or needs personal context. This helps trainers avoid assumptions and ask the right follow-up questions. Examples: food allergies, cultural pattern, custom macros.',
        ),
      ],
    ),
  ];

  static List<String> get allLabels => categories
      .expand((category) => category.items)
      .map((item) => item.title)
      .toList(growable: false);

  static String summary(List<String> diets) {
    if (diets.isEmpty) return 'Flexible / No specific preference';
    if (diets.length <= 2) return diets.join(', ');
    return '${diets.take(2).join(', ')} +${diets.length - 2} more';
  }
}
