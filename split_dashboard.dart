// ignore_for_file: curly_braces_in_flow_control_structures, prefer_interpolation_to_compose_strings

import 'dart:io';

void main() async {
  final file = File('lib/features/dashboard_screens.dart');
  final content = await file.readAsString();
  final lines = content.split('\n');

  final headerImports = <String>[];
  final workoutCode = <String>[];
  final exploreCode = <String>[];
  final feedCode = <String>[];
  final dashCode = <String>[];

  String current = 'dash';

  for (final line in lines) {
    if (line.startsWith('import ')) {
      if (!headerImports.contains(line)) {
        headerImports.add(line);
        dashCode.add(line);
      }
      continue;
    }

    if (line.contains('// GLOBAL SEARCH BAR')) {
      current = 'explore';
    } else if (line.contains('// TIME-OF-DAY GREETING')) {
      current = 'workout';
    } else if (line.contains('// TAB 0 - TRAINER WORKOUT PAGE')) {
      current = 'workout';
    } else if (line.contains('// TAB 0 - TRAINEE WORKOUT PAGE')) {
      current = 'workout';
    } else if (line.contains('// TAB 1 - EXPLORE PAGE')) {
      current = 'explore';
    } else if (line.contains('// TAB 2 - HOME FEED PAGE')) {
      current = 'feed';
    } else if (line.contains('// TRAINING SCHEDULE SCREEN')) {
      current = 'workout';
    } else if (line.contains('// DIET PROGRAMME SCREEN')) {
      current = 'workout';
    } else if (line.contains('// TAB 3 - MESSAGES PAGE')) {
      current = 'messages';
    }

    if (current == 'dash')
      dashCode.add(line);
    else if (current == 'workout')
      workoutCode.add(line);
    else if (current == 'explore')
      exploreCode.add(line);
    else if (current == 'feed') feedCode.add(line);
  }

  String importsStr = headerImports.join('\n') + '\n';

  // Make private classes public so they can be accessed from DashboardScreen
  String makePublic(String code) {
    return code
        .replaceAll('_TrainerWorkoutPage', 'TrainerWorkoutPage')
        .replaceAll('_TraineeWorkoutPage', 'TraineeWorkoutPage')
        .replaceAll('_ExplorePage', 'ExplorePage')
        .replaceAll('_HomeFeedPage', 'HomeFeedPage')
        .replaceAll('const TrainerWorkoutPage()', 'const TrainerWorkoutPage()')
        .replaceAll('const TraineeWorkoutPage()', 'const TraineeWorkoutPage()')
        .replaceAll('const ExplorePage()', 'const ExplorePage()')
        .replaceAll('const HomeFeedPage()', 'const HomeFeedPage()');
  }

  // Add the public classes rename in dashCode as well
  String finalDash = makePublic(dashCode.join('\n'));

  // Now modify dashCode to remove MessagesPage and add the new imports
  final newImports = '''
import 'workout_dashboard_screen.dart';
import 'explore_dashboard_screen.dart';
import 'feed_dashboard_screen.dart';
''';

  finalDash = finalDash.replaceFirst("import 'posts_screens.dart';",
      "import 'posts_screens.dart';\n" + newImports);

  // Remove messages page from _pages array
  finalDash = finalDash.replaceAll('const _MessagesPage(),', '');

  // Remove Messages nav item completely
  final navItemRegex = RegExp(
      r"\_NavItem\(\s*icon: CupertinoIcons\.chat_bubble,\s*selectedIcon: CupertinoIcons\.chat_bubble_fill,\s*label: 'Messages',\s*selected: _currentTab == 3,\s*onTap: \(\) \{\s*HapticFeedback\.selectionClick\(\);\s*setState\(\(\) => _currentTab = 3\);\s*\},\s*\),",
      multiLine: true,
      dotAll: true);
  finalDash = finalDash.replaceAll(navItemRegex, '');

  // Ensure the imports are appended to the new files
  final finalWorkout = importsStr + '\n' + makePublic(workoutCode.join('\n'));

  // explore_dashboard_screen might need GlobalSearchBar imported if it was moved to feed? No, GlobalSearchBar is in exploreCode
  // But exploreCode also uses _AppDrawer? No, AppDrawer is in dashCode.
  // Wait, _UserAvatar is in dashCode. Does anyone else use it?

  // Add part/part of or just imports. We are doing imports.
  // So the classes in workout, explore, feed might need models from dashCode? No, dashCode has _DashboardScreen, _UserAvatar, _NavItem, _AppDrawer. None of them are used in workout/explore/feed.
  // Actually, explore_dashboard_screen has GlobalSearchBar which uses trainer_public.TrainerPublicProfileScreen etc. which are in the imports.

  // Wait, _ExplorePage and others use `_greeting()`. `_greeting` is in workoutCode.
  // Let's move `_greeting()` to be public `greeting()` in workoutCode.
  String finalWorkoutFix = finalWorkout
      .replaceAll('String _greeting()', 'String greeting()')
      .replaceAll('_greeting()', 'greeting()');
  finalDash = finalDash.replaceAll('_greeting()', 'greeting()');

  // Let's also do the same for explore/feed if needed.
  String finalExplore = importsStr + '\n' + makePublic(exploreCode.join('\n'));
  String finalFeed = importsStr + '\n' + makePublic(feedCode.join('\n'));

  // Save the files
  await File('lib/features/workout_dashboard_screen.dart')
      .writeAsString(finalWorkoutFix);
  await File('lib/features/explore_dashboard_screen.dart')
      .writeAsString(finalExplore);
  await File('lib/features/feed_dashboard_screen.dart')
      .writeAsString(finalFeed);
  await file.writeAsString(finalDash);
}
