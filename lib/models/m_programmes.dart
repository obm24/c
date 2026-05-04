import 'package:equatable/equatable.dart';

import 'm_programmes_exercise.dart';

enum ProgrammeType { training, diet }

enum ProgrammeCycleType { microcycle, mesocycle, macrocycle }

class ExerciseMetrics extends Equatable {
  final int sets;
  final String reps;
  final String restTime;
  final String notes;
  final String rpe;

  const ExerciseMetrics({
    this.sets = 3,
    this.reps = '10',
    this.restTime = '60 sec',
    this.notes = '',
    this.rpe = '',
  });

  factory ExerciseMetrics.fromJson(Map<String, dynamic> json) {
    return ExerciseMetrics(
      sets: _readInt(json['sets'], fallback: 3),
      reps: _readString(json['reps'], fallback: '10'),
      restTime: _readString(json['restTime'], fallback: '60 sec'),
      notes: _readString(json['notes']),
      rpe: _readString(json['rpe']),
    );
  }

  ExerciseMetrics copyWith({
    int? sets,
    String? reps,
    String? restTime,
    String? notes,
    String? rpe,
  }) {
    return ExerciseMetrics(
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      restTime: restTime ?? this.restTime,
      notes: notes ?? this.notes,
      rpe: rpe ?? this.rpe,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sets': sets,
      'reps': reps,
      'restTime': restTime,
      'notes': notes,
      'rpe': rpe,
    };
  }

  static int _readInt(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static String _readString(Object? value, {String fallback = ''}) {
    if (value is String) return value;
    return fallback;
  }

  @override
  List<Object?> get props => [sets, reps, restTime, notes, rpe];
}

class PrescribedExercise extends Equatable {
  final String id;
  final Exercise exercise;
  final ExerciseMetrics metrics;

  const PrescribedExercise({
    required this.id,
    required this.exercise,
    this.metrics = const ExerciseMetrics(),
  });

  factory PrescribedExercise.fromJson(Map<String, dynamic> json) {
    final exerciseValue = json['exercise'];
    final metricsValue = json['metrics'];
    return PrescribedExercise(
      id: _readString(json['id']),
      exercise: exerciseValue is Map<String, dynamic>
          ? Exercise.fromJson(exerciseValue)
          : const Exercise(
              id: 0,
              name: '',
              videoUrl: '',
              targetBodyPart: '',
              trainingType: '',
            ),
      metrics: metricsValue is Map<String, dynamic>
          ? ExerciseMetrics.fromJson(metricsValue)
          : const ExerciseMetrics(),
    );
  }

  PrescribedExercise copyWith({
    String? id,
    Exercise? exercise,
    ExerciseMetrics? metrics,
  }) {
    return PrescribedExercise(
      id: id ?? this.id,
      exercise: exercise ?? this.exercise,
      metrics: metrics ?? this.metrics,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exercise': exercise.toJson(),
      'metrics': metrics.toJson(),
    };
  }

  static String _readString(Object? value) {
    if (value is String) return value;
    return '';
  }

  @override
  List<Object?> get props => [id, exercise, metrics];
}

class WorkoutDay extends Equatable {
  final String id;
  final String name;
  final List<PrescribedExercise> exercises;

  const WorkoutDay({
    required this.id,
    required this.name,
    this.exercises = const [],
  });

  factory WorkoutDay.fromJson(Map<String, dynamic> json) {
    final exercisesValue = json['exercises'];
    return WorkoutDay(
      id: _readString(json['id']),
      name: _readString(json['name']),
      exercises: exercisesValue is List
          ? exercisesValue
              .whereType<Map<String, dynamic>>()
              .map(PrescribedExercise.fromJson)
              .toList(growable: false)
          : const <PrescribedExercise>[],
    );
  }

  WorkoutDay copyWith({
    String? id,
    String? name,
    List<PrescribedExercise>? exercises,
  }) {
    return WorkoutDay(
      id: id ?? this.id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
    };
  }

  static String _readString(Object? value) {
    if (value is String) return value;
    return '';
  }

  @override
  List<Object?> get props => [id, name, exercises];
}

class Programme extends Equatable {
  final String id;
  final ProgrammeType type;
  final String name;
  final String targetGoal;
  final List<String> goals;
  final String description;
  final String color;
  final ProgrammeCycleType cycleType;
  final int duration;
  final List<WorkoutDay> workoutDays;
  final bool isPinned;
  final bool isActive;

  const Programme({
    required this.id,
    this.type = ProgrammeType.training,
    required this.name,
    this.targetGoal = '',
    this.goals = const [],
    this.description = '',
    this.color = '#6C63FF',
    this.cycleType = ProgrammeCycleType.mesocycle,
    this.duration = 8,
    this.workoutDays = const [],
    this.isPinned = false,
    this.isActive = true,
  });

  factory Programme.emptyTraining() {
    return Programme(
      id: 'programme_${DateTime.now().microsecondsSinceEpoch}',
      name: '',
      targetGoal: '',
      goals: const [],
      description: '',
    );
  }

  factory Programme.fromJson(Map<String, dynamic> json) {
    final workoutDaysValue = json['workoutDays'];
    final goals = _readStringList(json['goals']);
    final targetGoal = _readString(json['targetGoal']);
    return Programme(
      id: _readString(json['id']),
      type: _readType(json['type']),
      name: _readString(json['name']),
      targetGoal: targetGoal,
      goals: goals.isEmpty && targetGoal.isNotEmpty ? [targetGoal] : goals,
      description: _readString(json['description']),
      color: _readString(json['color'], fallback: '#6C63FF'),
      cycleType: _readCycleType(json['cycleType']),
      duration: _readInt(json['duration'], fallback: 8),
      workoutDays: workoutDaysValue is List
          ? workoutDaysValue
              .whereType<Map<String, dynamic>>()
              .map(WorkoutDay.fromJson)
              .toList(growable: false)
          : const <WorkoutDay>[],
      isPinned: _readBool(json['isPinned']),
      isActive: _readBool(json['isActive'], fallback: true),
    );
  }

  Programme copyWith({
    String? id,
    ProgrammeType? type,
    String? name,
    String? targetGoal,
    List<String>? goals,
    String? description,
    String? color,
    ProgrammeCycleType? cycleType,
    int? duration,
    List<WorkoutDay>? workoutDays,
    bool? isPinned,
    bool? isActive,
  }) {
    return Programme(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      targetGoal: targetGoal ?? this.targetGoal,
      goals: goals ?? this.goals,
      description: description ?? this.description,
      color: color ?? this.color,
      cycleType: cycleType ?? this.cycleType,
      duration: duration ?? this.duration,
      workoutDays: workoutDays ?? this.workoutDays,
      isPinned: isPinned ?? this.isPinned,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'targetGoal': targetGoal,
      'goals': goals,
      'description': description,
      'color': color,
      'cycleType': cycleType.name,
      'duration': duration,
      'workoutDays': workoutDays.map((day) => day.toJson()).toList(),
      'isPinned': isPinned,
      'isActive': isActive,
    };
  }

  static ProgrammeType _readType(Object? value) {
    if (value is String) {
      for (final type in ProgrammeType.values) {
        if (type.name == value) return type;
      }
    }
    return ProgrammeType.training;
  }

  static ProgrammeCycleType _readCycleType(Object? value) {
    if (value is String) {
      for (final type in ProgrammeCycleType.values) {
        if (type.name == value) return type;
      }
    }
    return ProgrammeCycleType.mesocycle;
  }

  static int _readInt(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static String _readString(Object? value, {String fallback = ''}) {
    if (value is String) return value;
    return fallback;
  }

  static List<String> _readStringList(Object? value) {
    if (value is! List) return const [];
    return value.whereType<String>().toList(growable: false);
  }

  static bool _readBool(Object? value, {bool fallback = false}) {
    if (value is bool) return value;
    return fallback;
  }

  @override
  List<Object?> get props => [
        id,
        type,
        name,
        targetGoal,
        goals,
        description,
        color,
        cycleType,
        duration,
        workoutDays,
        isPinned,
        isActive,
      ];
}
