// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  final file = File('lib/core/custom_controls.dart');
  String content = file.readAsStringSync();

  if (!content.contains('class GroupedMultiSelectDialog')) {
    content += '''

// =============================================================================
// CATEGORIZED MULTI-SELECT DIALOG (FOR GOALS & SPECIALITIES)
// =============================================================================
class GroupedMultiSelectDialog extends StatefulWidget {
  final String title;
  final List<GoalCategory> categories;
  final List<String> initialSelections;

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
    file.writeAsStringSync(content);
    print('Added GroupedMultiSelectDialog');
  }
}
