// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  final file = File('lib/features/trainee_public_profile_screen.dart');
  String content = file.readAsStringSync();

  final classStart = 'class MedicalData {';
  final idx = content.indexOf(classStart);
  if (idx != -1) {
    int bracketCount = 0;
    int endIdx = -1;
    for (int i = idx + classStart.length - 1; i < content.length; i++) {
      if (content[i] == '{') bracketCount++;
      if (content[i] == '}') {
        bracketCount--;
        if (bracketCount == 0) {
          endIdx = i + 1;
          break;
        }
      }
    }
    if (endIdx != -1) {
      content = content.replaceRange(idx, endIdx, '');
      file.writeAsStringSync(content);
      print('Removed MedicalData from trainee_public_profile_screen.dart');
    }
  } else {
    print('MedicalData not found in trainee_public_profile_screen.dart');
  }
}
