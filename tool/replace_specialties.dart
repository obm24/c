// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  final file = File('lib/features/auth_screens.dart');
  String content = file.readAsStringSync();

  final startStr = '  void _openSpecialtiesSelect() {';
  final startIndex = content.indexOf(startStr);
  if (startIndex == -1) {
    print('Could not find start index');
    return;
  }

  // Find the matching end brace for the function
  int braceCount = 0;
  int endIndex = -1;
  for (int i = startIndex + startStr.length - 1; i < content.length; i++) {
    if (content[i] == '{') braceCount++;
    if (content[i] == '}') {
      braceCount--;
      if (braceCount == 0) {
        endIndex = i + 1;
        break;
      }
    }
  }

  if (endIndex == -1) {
    print('Could not find end index');
    return;
  }

  final newFunc = '''  void _openSpecialtiesSelect() async {
    final categories = MedicalData.getCategorizedGoals(context);
    final results = await showDialog<List<String>>(
      context: context,
      builder: (ctx) => GroupedMultiSelectDialog(
        title: context.l10n.specialities,
        categories: categories,
        initialSelections: _trainerSpecialties,
      ),
    );
    if (results != null) {
      setState(() => _trainerSpecialties = results);
    }
  }''';

  final newContent = content.replaceRange(startIndex, endIndex, newFunc);
  file.writeAsStringSync(newContent);
  print('Replaced _openSpecialtiesSelect successfully');
}
