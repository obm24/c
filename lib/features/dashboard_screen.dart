import 'package:flutter/material.dart';

import 'dashboard_trainer_screen.dart';
import 'dashboard_trainee_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String role;

  const DashboardScreen({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedRole = role.trim().toLowerCase();
    if (normalizedRole == 'trainee') {
      return const TraineeWorkoutPage();
    }
    return const TrainerWorkoutPage();
  }
}
