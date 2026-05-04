// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'dart:io';

void main() {
  final file = File('lib/core/custom_controls.dart');
  String content = file.readAsStringSync();

  String insertion = '''

  static List<GoalCategory> getCategorizedGoals(BuildContext context) {
    final l = context.l10n;
    return [
      GoalCategory(
        id: 'cat_strength',
        name: l.catStrength,
        items: [
          GoalItem(id: 'goal_bodybuilding', categoryId: 'cat_strength', title: l.goalBodybuildingTitle, description: l.goalBodybuildingDesc),
          GoalItem(id: 'goal_powerlifting', categoryId: 'cat_strength', title: l.goalPowerliftingTitle, description: l.goalPowerliftingDesc),
          GoalItem(id: 'goal_olympic', categoryId: 'cat_strength', title: l.goalOlympicTitle, description: l.goalOlympicDesc),
          GoalItem(id: 'goal_strongman', categoryId: 'cat_strength', title: l.goalStrongmanTitle, description: l.goalStrongmanDesc),
        ],
      ),
      GoalCategory(
        id: 'cat_athletic',
        name: l.catAthletic,
        items: [
          GoalItem(id: 'goal_sports', categoryId: 'cat_athletic', title: l.goalSportsTitle, description: l.goalSportsDesc),
          GoalItem(id: 'goal_functional', categoryId: 'cat_athletic', title: l.goalFunctionalTitle, description: l.goalFunctionalDesc),
          GoalItem(id: 'goal_callisthenics', categoryId: 'cat_athletic', title: l.goalCallisthenicsTitle, description: l.goalCallisthenicsDesc),
          GoalItem(id: 'goal_combat', categoryId: 'cat_athletic', title: l.goalCombatTitle, description: l.goalCombatDesc),
        ],
      ),
      GoalCategory(
        id: 'cat_recovery',
        name: l.catRecovery,
        items: [
          GoalItem(id: 'goal_corrective', categoryId: 'cat_recovery', title: l.goalCorrectiveTitle, description: l.goalCorrectiveDesc),
          GoalItem(id: 'goal_rehabilitation', categoryId: 'cat_recovery', title: l.goalRehabilitationTitle, description: l.goalRehabilitationDesc),
          GoalItem(id: 'goal_mobility', categoryId: 'cat_recovery', title: l.goalMobilityTitle, description: l.goalMobilityDesc),
        ],
      ),
      GoalCategory(
        id: 'cat_cardio',
        name: l.catCardio,
        items: [
          GoalItem(id: 'goal_hiit', categoryId: 'cat_cardio', title: l.goalHiitTitle, description: l.goalHiitDesc),
          GoalItem(id: 'goal_endurance', categoryId: 'cat_cardio', title: l.goalEnduranceTitle, description: l.goalEnduranceDesc),
        ],
      ),
      GoalCategory(
        id: 'cat_mindbody',
        name: l.catMindbody,
        items: [
          GoalItem(id: 'goal_yoga', categoryId: 'cat_mindbody', title: l.goalYogaTitle, description: l.goalYogaDesc),
          GoalItem(id: 'goal_pilates', categoryId: 'cat_mindbody', title: l.goalPilatesTitle, description: l.goalPilatesDesc),
        ],
      ),
      GoalCategory(
        id: 'cat_specialised',
        name: l.catSpecialised,
        items: [
          GoalItem(id: 'goal_prenatal', categoryId: 'cat_specialised', title: l.goalPrenatalTitle, description: l.goalPrenatalDesc),
          GoalItem(id: 'goal_senior', categoryId: 'cat_specialised', title: l.goalSeniorTitle, description: l.goalSeniorDesc),
          GoalItem(id: 'goal_youth', categoryId: 'cat_specialised', title: l.goalYouthTitle, description: l.goalYouthDesc),
        ],
      ),
    ];
  }
''';

  content = content.replaceFirst(
      'static final List<String> trainerSpecialties = [',
      insertion + '\\n  static final List<String> trainerSpecialties = [');

  String dialogCode = '''

// =============================================================================
// CATEGORIZED MULTI-SELECT DIALOG (FOR GOALS & SPECIALITIES)
// =============================================================================
class GroupedMultiSelectDialog extends StatefulWidget {
  final String title;
  final List<GoalCategory> categories;
  final List<String> initialSelections; // list of goal/speciality IDs or Titles

  const GroupedMultiSelectDialog({
    super.key,
    required this.title,
    required this.categories,
    required this.initialSelections,
  });

  @override
  State<GroupedMultiSelectDialog> createState() => _GroupedMultiSelectDialogState();
}

class _GroupedMultiSelectDialogState extends State<GroupedMultiSelectDialog> {
  late List<String> _selections;

  @override
  void initState() {
    super.initState();
    _selections = List.from(widget.initialSelections);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(widget.title,
                  style: const TextStyle(
                      color: AppTheme.brand,
                      fontWeight: FontWeight.bold,
                      fontSize: AppConstants.kDefaultTitleFontSize)),
            ),
            const Divider(color: AppTheme.divider, height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: widget.categories.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, catIndex) {
                  final category = widget.categories[catIndex];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        color: Colors.white.withValues(alpha: 0.05),
                        child: Text(category.name,
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ),
                      ...category.items.map((item) {
                        final isSelected = _selections.contains(item.title);
                        return Column(
                          children: [
                            InkWell(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  if (isSelected) {
                                    _selections.remove(item.title);
                                  } else {
                                    _selections.add(item.title);
                                  }
                                });
                              },
                              child: Container(
                                color: isSelected ? AppTheme.brand : Colors.transparent,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(item.title,
                                          style: TextStyle(
                                              color: isSelected
                                                  ? AppTheme.confirmationButtonText
                                                  : AppTheme.textPrimary,
                                              fontSize: AppConstants.kDefaultSubtitleFontSize,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            backgroundColor: AppTheme.surface,
                                            titlePadding: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius)),
                                            title: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(20),
                                                  child: Text(item.title,
                                                      style: const TextStyle(
                                                          color: AppTheme.brand,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: AppConstants.kDefaultTitleFontSize)),
                                                ),
                                                const Divider(color: AppTheme.divider, height: 1),
                                              ],
                                            ),
                                            content: Text(item.description,
                                                style: const TextStyle(
                                                    color: AppTheme.textPrimary,
                                                    fontSize: AppConstants.kDefaultSubtitleFontSize,
                                                    height: 1.5)),
                                            actions: [
                                              TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: Text(
                                                      context.l10n.close,
                                                      style: const TextStyle(
                                                          color: AppTheme.brand, fontWeight: FontWeight.bold)))
                                            ],
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 15),
                                        child: Icon(
                                          Icons.help_outline_rounded,
                                          color: isSelected ? AppTheme.confirmationButtonText : AppTheme.brand,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(color: AppTheme.divider, height: 1),
                          ],
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SolidConfirmButton(
                      label: context.l10n.confirm,
                      height: AppConstants.kDefaultButtonHeightLarge,
                      onPressed: () {
                        Navigator.pop(context, _selections);
                      }),
                  const SizedBox(height: 10),
                  OutlineActionButton(
                    label: context.l10n.cancel,
                    height: AppConstants.kDefaultButtonHeightLarge,
                    textColor: AppTheme.textPrimary,
                    borderColor: AppTheme.textSecondary,
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
''';

  content += dialogCode;

  if (!content.contains('goal_model.dart')) {
    content = content.replaceFirst("import 'package:equatable/equatable.dart';",
        "import 'package:equatable/equatable.dart';\nimport '../models/goal_model.dart';");
  }

  file.writeAsStringSync(content);
  print('Injected custom UI control successfully.');
}
