// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  final file = File('lib/features/profile_screens.dart');
  String content = file.readAsStringSync();

  final regex = RegExp(
    r'onTap:\s*\(\)\s*\{\s*HapticFeedback\.lightImpact\(\);\s*_openMedicalMultiSelect\(label,\s*type,\s*options,\s*current,\s*hasDesc:\s*hasDesc,\s*descriptions:\s*descriptions\);\s*\},',
    multiLine: true,
  );

  final newTap = '''onTap: () async {
            HapticFeedback.lightImpact();
            if (type == 'goals' || type == 'trainer_specialties') {
              final categories = MedicalData.getCategorizedGoals(context);
              final results = await showDialog<List<String>>(
                context: context,
                builder: (ctx) => GroupedMultiSelectDialog(
                  title: label,
                  categories: categories,
                  initialSelections: current,
                ),
              );
              if (results != null) {
                if (type == 'trainer_specialties') {
                  setState(() => _trainerSpecialties = results);
                } else {
                  appState.updateMedical(type, results);
                }
              }
            } else {
              _openMedicalMultiSelect(label, type, options, current,
                  hasDesc: hasDesc, descriptions: descriptions);
            }
          },''';

  if (regex.hasMatch(content)) {
    content = content.replaceFirst(regex, newTap);
    file.writeAsStringSync(content);
    print('Successfully updated _buildMedicalSelector in profile_screens.dart');
  } else {
    print('Could not find the old onTap string via regex.');
  }
}
