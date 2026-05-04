import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/m_goal_model.dart';
import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_en.dart';
import 'animations/anim_motion.dart';
import 'c_constants.dart';
import 'c_ui_theme.dart';
import 'c_warnings.dart';

enum ExperienceLevel {
  zeroYears,
  oneToTwoYears,
  threeToFiveYears,
  sixToNineYears,
  tenPlusYears,
}

class TrainingExperienceOption {
  final ExperienceLevel level;
  final int years;
  final int minYears;
  final int? maxYears;
  final String label;
  final Color color;
  final String description;

  const TrainingExperienceOption({
    required this.level,
    required this.years,
    required this.minYears,
    required this.maxYears,
    required this.label,
    required this.color,
    required this.description,
  });

  bool containsYears(int value) {
    final clamped = value < 0 ? 0 : value;
    final ceiling = maxYears;
    if (ceiling == null) return clamped >= minYears;
    return clamped >= minYears && clamped <= ceiling;
  }

  String localizedLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    switch (level) {
      case ExperienceLevel.zeroYears:
        return l10n.experienceLevelZeroYears;
      case ExperienceLevel.oneToTwoYears:
        return l10n.experienceLevelOneToTwoYears;
      case ExperienceLevel.threeToFiveYears:
        return l10n.experienceLevelThreeToFiveYears;
      case ExperienceLevel.sixToNineYears:
        return l10n.experienceLevelSixToNineYears;
      case ExperienceLevel.tenPlusYears:
        return l10n.experienceLevelTenPlusYears;
    }
  }

  String localizedDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    switch (level) {
      case ExperienceLevel.zeroYears:
        return l10n.experienceLevelZeroYearsDescription;
      case ExperienceLevel.oneToTwoYears:
        return l10n.experienceLevelOneToTwoYearsDescription;
      case ExperienceLevel.threeToFiveYears:
        return l10n.experienceLevelThreeToFiveYearsDescription;
      case ExperienceLevel.sixToNineYears:
        return l10n.experienceLevelSixToNineYearsDescription;
      case ExperienceLevel.tenPlusYears:
        return l10n.experienceLevelTenPlusYearsDescription;
    }
  }
}

class TraineeTrainingExperienceData {
  static const List<TrainingExperienceOption> options = [
    TrainingExperienceOption(
      level: ExperienceLevel.zeroYears,
      years: 0,
      minYears: 0,
      maxYears: 0,
      label: '0 Years',
      color: Color(0xFF94A3B8),
      description: 'No consistent structured training yet.',
    ),
    TrainingExperienceOption(
      level: ExperienceLevel.oneToTwoYears,
      years: 1,
      minYears: 1,
      maxYears: 2,
      label: '1-2 Years',
      color: Color(0xFF38BDF8),
      description:
          'Beginner/early foundation, learning consistency, basic form, and basic routines.',
    ),
    TrainingExperienceOption(
      level: ExperienceLevel.threeToFiveYears,
      years: 3,
      minYears: 3,
      maxYears: 5,
      label: '3-5 Years',
      color: Color(0xFF34D399),
      description:
          'Intermediate, familiar with structured training, progressive overload, and multiple exercise types.',
    ),
    TrainingExperienceOption(
      level: ExperienceLevel.sixToNineYears,
      years: 6,
      minYears: 6,
      maxYears: 9,
      label: '6-9 Years',
      color: Color(0xFFF59E0B),
      description:
          'Advanced recreational trainee, long-term consistency and strong body awareness.',
    ),
    TrainingExperienceOption(
      level: ExperienceLevel.tenPlusYears,
      years: 10,
      minYears: 10,
      maxYears: null,
      label: '+10 Years',
      color: Color(0xFFC084FC),
      description:
          'Highly experienced trainee with extensive long-term training exposure.',
    ),
  ];

  static int normalizeYears(dynamic value) {
    if (value is ExperienceLevel) {
      return optionForLevel(value).years;
    }
    if (value is int) {
      if (value < 0) return 0;
      if (value > 10) return 10;
      return value;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized.contains('+10')) return 10;
      if (normalized.contains('1-2') || normalized.contains('1\u20132')) {
        return 1;
      }
      if (normalized.contains('3-5') || normalized.contains('3\u20135')) {
        return 3;
      }
      if (normalized.contains('6-9') || normalized.contains('6\u20139')) {
        return 6;
      }
      final match = RegExp(r'\d+').firstMatch(normalized);
      if (match != null) {
        return normalizeYears(int.tryParse(match.group(0) ?? '') ?? 0);
      }
    }
    return 0;
  }

  static TrainingExperienceOption optionForLevel(ExperienceLevel level) {
    return options.firstWhere(
      (option) => option.level == level,
      orElse: () => options.first,
    );
  }

  static TrainingExperienceOption optionFor(dynamic value) {
    final years = normalizeYears(value);
    return options.firstWhere(
      (option) => option.containsYears(years),
      orElse: () => options.first,
    );
  }

  static String labelFor(dynamic value) => optionFor(value).label;

  static Future<void> showOptionHelpDialog(
    BuildContext context,
    TrainingExperienceOption option,
  ) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    return AppMotion.showPremiumDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        titlePadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
        ),
        title: _DialogTitle(title: option.localizedLabel(context)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.trainingExperienceDialogIntro,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: AppConstants.kDefaultSubtitleFontSize,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              _ExperienceGuideRow(
                label: option.localizedLabel(context),
                color: option.color,
                text: option.localizedDescription(context),
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
            child: Text(
              l10n.close,
              style: const TextStyle(
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
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    return AppMotion.showPremiumDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        titlePadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
        ),
        title: _DialogTitle(title: l10n.trainingExperienceDialogTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.trainingExperienceDialogIntro,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: AppConstants.kDefaultSubtitleFontSize,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              ...options.map(
                (option) => _ExperienceGuideRow(
                  label: option.localizedLabel(context),
                  color: option.color,
                  text: option.localizedDescription(context),
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
            child: Text(
              l10n.close,
              style: const TextStyle(
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
    final selectedStorageYears = selectedOption?.years;
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
            child: AnimatedContainer(
              duration: AppMotion.duration(context, AppDurations.standard),
              curve: AppCurves.entrance,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                border: Border.all(
                  color: selectedOption == null
                      ? AppTheme.textSecondary
                      : AppTheme.cardGreen,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(
                        AppConstants.kDefaultBorderRadius),
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
                              selectedOption?.localizedLabel(context) ??
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
                          if (selectedOption != null) ...[
                            const Icon(
                              Icons.check_circle,
                              color: AppTheme.cardGreen,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                          ],
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
                          groupValue: selectedStorageYears,
                          onChanged: (years) {
                            if (years == null) return;
                            HapticFeedback.selectionClick();
                            widget.onSelected(years);
                            setState(() => _expanded = false);
                          },
                          child: Column(
                            children: TraineeTrainingExperienceData.options
                                .map((option) {
                              final selected =
                                  option.years == selectedStorageYears;
                              return RadioListTile<int>(
                                value: option.years,
                                activeColor: option.color,
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 0,
                                ),
                                title: Text(
                                  option.localizedLabel(context),
                                  style: TextStyle(
                                    color: selected
                                        ? option.color
                                        : AppTheme.textSecondary,
                                    fontSize:
                                        AppConstants.kDefaultSubtitleFontSize,
                                    fontWeight: selected
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
          ),
          if (selectedOption == null && widget.showRequiredWarning)
            StandardFormWarningBanner(
              message: warningText,
              isValid: false,
              margin: const EdgeInsets.only(top: 10),
            )
          else if (selectedOption != null)
            StandardFormWarningBanner(
              message: l10n.trainingExperienceSelected,
              isValid: true,
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
