import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/m_programmes_exercise.dart';
import '../models/m_programmes_exercise_metadata.dart';

class ExerciseRepository {
  static const String defaultAssetPath = 'assets/training-data/exercises.json';

  final List<Exercise> _exercises;
  final ExerciseMetadata metadata;

  const ExerciseRepository({
    required List<Exercise> exercises,
    required this.metadata,
  }) : _exercises = exercises;

  factory ExerciseRepository.fromJson(Map<String, dynamic> json) {
    final exerciseValues = json['exercises'];
    final metadataValue = json['metadata'];

    final exercises = exerciseValues is List
        ? exerciseValues
            .whereType<Map<String, dynamic>>()
            .map(Exercise.fromJson)
            .toList(growable: false)
        : const <Exercise>[];

    final metadata = metadataValue is Map<String, dynamic>
        ? ExerciseMetadata.fromJson(metadataValue)
        : _deriveMetadata(exercises);

    return ExerciseRepository(
      exercises: exercises,
      metadata: metadata,
    );
  }

  factory ExerciseRepository.fromList(List<dynamic> values) {
    final exercises = values
        .whereType<Map<String, dynamic>>()
        .map(Exercise.fromJson)
        .toList(growable: false);
    return ExerciseRepository(
      exercises: exercises,
      metadata: _deriveMetadata(exercises),
    );
  }

  static Future<ExerciseRepository> loadFromAssetBundle(
    AssetBundle bundle, {
    String assetPath = defaultAssetPath,
  }) async {
    final rawJson = await bundle.loadString(assetPath);
    final decoded = jsonDecode(rawJson);
    if (decoded is Map<String, dynamic>) {
      return ExerciseRepository.fromJson(decoded);
    }
    if (decoded is List) return ExerciseRepository.fromList(decoded);
    return const ExerciseRepository(
      exercises: [],
      metadata: ExerciseMetadata.empty(),
    );
  }

  List<Exercise> get exercises => List.unmodifiable(_exercises);

  List<Exercise> filterExercises({
    String? targetBodyPart,
    String? trainingType,
  }) {
    if (_isBlank(targetBodyPart) && _isBlank(trainingType)) {
      return exercises;
    }

    return _exercises.where((exercise) {
      final matchesBodyPart = _isBlank(targetBodyPart) ||
          exercise.targetBodyPart.toLowerCase() ==
              targetBodyPart?.trim().toLowerCase();
      final matchesTrainingType = _isBlank(trainingType) ||
          exercise.trainingType.toLowerCase() ==
              trainingType?.trim().toLowerCase();
      return matchesBodyPart && matchesTrainingType;
    }).toList(growable: false);
  }

  List<Exercise> searchExercises({
    String? query,
    String? targetBodyPart,
    String? trainingType,
  }) {
    final filtered = filterExercises(
      targetBodyPart: targetBodyPart,
      trainingType: trainingType,
    );
    if (_isBlank(query)) return filtered;

    final normalizedQuery = query?.trim().toLowerCase();
    return filtered.where((exercise) {
      return exercise.name.toLowerCase().contains(normalizedQuery ?? '') ||
          exercise.targetBodyPart.toLowerCase().contains(normalizedQuery ?? '');
    }).toList(growable: false);
  }

  static bool _isBlank(String? value) {
    return value == null || value.trim().isEmpty;
  }

  static ExerciseMetadata _deriveMetadata(List<Exercise> exercises) {
    final trainingTypes = exercises
        .map((exercise) => exercise.trainingType)
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final bodyParts = exercises
        .map((exercise) => exercise.targetBodyPart)
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ExerciseMetadata(
      trainingTypes: trainingTypes,
      bodyParts: bodyParts,
    );
  }
}
