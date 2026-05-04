import 'package:equatable/equatable.dart';

import 'm_programmes_exercise.dart';
import 'm_programmes.dart';

// ===========================================================================
// ENUMS
// ===========================================================================

enum BiologicalSex { male, female, other }

enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  extraActive,
}

extension ActivityLevelExt on ActivityLevel {
  String get label {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Sedentary (desk job, no exercise)';
      case ActivityLevel.lightlyActive:
        return 'Lightly Active (1–3 days/week)';
      case ActivityLevel.moderatelyActive:
        return 'Moderately Active (3–5 days/week)';
      case ActivityLevel.veryActive:
        return 'Very Active (6–7 days/week)';
      case ActivityLevel.extraActive:
        return 'Extra Active (physical job + training)';
    }
  }

  double get multiplier {
    switch (this) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.lightlyActive:
        return 1.375;
      case ActivityLevel.moderatelyActive:
        return 1.55;
      case ActivityLevel.veryActive:
        return 1.725;
      case ActivityLevel.extraActive:
        return 1.9;
    }
  }
}

enum PhaseObjective {
  accumulation,
  intensification,
  peaking,
  deload,
  realization,
  base,
  maintenance,
}

extension PhaseObjectiveExt on PhaseObjective {
  String get label {
    switch (this) {
      case PhaseObjective.accumulation:
        return 'Accumulation';
      case PhaseObjective.intensification:
        return 'Intensification';
      case PhaseObjective.peaking:
        return 'Peaking';
      case PhaseObjective.deload:
        return 'Deload';
      case PhaseObjective.realization:
        return 'Realization';
      case PhaseObjective.base:
        return 'Base Building';
      case PhaseObjective.maintenance:
        return 'Maintenance';
    }
  }
}

enum ExerciseModality {
  straightSet,
  superset,
  triSet,
  giantSet,
  dropSet,
  myoRep,
  restPause,
  cluster,
  pyramid,
  reversePyramid,
  mtor,
  partialReps,
  mechanicalDropSet,
}

extension ExerciseModalityExt on ExerciseModality {
  String get label {
    switch (this) {
      case ExerciseModality.straightSet:
        return 'Straight Set';
      case ExerciseModality.superset:
        return 'Superset';
      case ExerciseModality.triSet:
        return 'Tri-Set';
      case ExerciseModality.giantSet:
        return 'Giant Set';
      case ExerciseModality.dropSet:
        return 'Drop Set';
      case ExerciseModality.myoRep:
        return 'Myo-Rep';
      case ExerciseModality.restPause:
        return 'Rest-Pause';
      case ExerciseModality.cluster:
        return 'Cluster Set';
      case ExerciseModality.pyramid:
        return 'Pyramid';
      case ExerciseModality.reversePyramid:
        return 'Reverse Pyramid';
      case ExerciseModality.mtor:
        return 'mTOR Activation';
      case ExerciseModality.partialReps:
        return 'Partial Reps';
      case ExerciseModality.mechanicalDropSet:
        return 'Mechanical Drop Set';
    }
  }
}

enum SetType { warmup, working, feeder, backoff, amrap }

extension SetTypeExt on SetType {
  String get label {
    switch (this) {
      case SetType.warmup:
        return 'Warm-up';
      case SetType.working:
        return 'Working';
      case SetType.feeder:
        return 'Feeder';
      case SetType.backoff:
        return 'Back-off';
      case SetType.amrap:
        return 'AMRAP';
    }
  }
}

enum CardioType { liss, hiit, mict, emom, tabata, fartlek }

extension CardioTypeExt on CardioType {
  String get label {
    switch (this) {
      case CardioType.liss:
        return 'LISS';
      case CardioType.hiit:
        return 'HIIT';
      case CardioType.mict:
        return 'MICT';
      case CardioType.emom:
        return 'EMOM';
      case CardioType.tabata:
        return 'Tabata';
      case CardioType.fartlek:
        return 'Fartlek';
    }
  }
}

enum MacroCycleStrategy { none, calorieCycling, carbCycling, fatCycling }

enum MealSlotType { breakfast, midMorning, lunch, preWorkout, postWorkout, dinner, eveningSnack, other }

extension MealSlotTypeExt on MealSlotType {
  String get label {
    switch (this) {
      case MealSlotType.breakfast:
        return 'Breakfast';
      case MealSlotType.midMorning:
        return 'Mid-Morning';
      case MealSlotType.lunch:
        return 'Lunch';
      case MealSlotType.preWorkout:
        return 'Pre-Workout';
      case MealSlotType.postWorkout:
        return 'Post-Workout';
      case MealSlotType.dinner:
        return 'Dinner';
      case MealSlotType.eveningSnack:
        return 'Evening Snack';
      case MealSlotType.other:
        return 'Other';
    }
  }
}

enum ProgramStatus { draft, published, archived }

// ===========================================================================
// CLIENT BASELINE
// ===========================================================================

class MedicalLimitation extends Equatable {
  final String id;
  final String condition;
  final String affectedBodyPart;
  final List<String> restrictedExercises;
  final String notes;

  const MedicalLimitation({
    required this.id,
    required this.condition,
    this.affectedBodyPart = '',
    this.restrictedExercises = const [],
    this.notes = '',
  });

  factory MedicalLimitation.fromJson(Map<String, dynamic> json) {
    return MedicalLimitation(
      id: _str(json['id']),
      condition: _str(json['condition']),
      affectedBodyPart: _str(json['affectedBodyPart']),
      restrictedExercises: _strList(json['restrictedExercises']),
      notes: _str(json['notes']),
    );
  }

  MedicalLimitation copyWith({
    String? id,
    String? condition,
    String? affectedBodyPart,
    List<String>? restrictedExercises,
    String? notes,
  }) {
    return MedicalLimitation(
      id: id ?? this.id,
      condition: condition ?? this.condition,
      affectedBodyPart: affectedBodyPart ?? this.affectedBodyPart,
      restrictedExercises: restrictedExercises ?? this.restrictedExercises,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'condition': condition,
        'affectedBodyPart': affectedBodyPart,
        'restrictedExercises': restrictedExercises,
        'notes': notes,
      };

  @override
  List<Object?> get props => [id, condition, affectedBodyPart, restrictedExercises, notes];
}

class ClientBaseline extends Equatable {
  // ── Biometrics ──────────────────────────────────────────────────────────
  final String clientId;
  final String clientName;
  final int ageYears;
  final double heightCm;
  final double weightKg;
  final double bodyFatPercent;
  final BiologicalSex sex;
  final ActivityLevel activityLevel;

  // ── Dietary Restrictions ─────────────────────────────────────────────────
  final List<String> dietaryRestrictions;
  final List<String> foodAllergies;
  final List<MedicalLimitation> medicalLimitations;

  // ── Goal ─────────────────────────────────────────────────────────────────
  final String primaryGoal;
  final List<String> secondaryGoals;
  final String trainerNotes;

  const ClientBaseline({
    required this.clientId,
    this.clientName = '',
    this.ageYears = 25,
    this.heightCm = 170,
    this.weightKg = 70,
    this.bodyFatPercent = 15,
    this.sex = BiologicalSex.male,
    this.activityLevel = ActivityLevel.moderatelyActive,
    this.dietaryRestrictions = const [],
    this.foodAllergies = const [],
    this.medicalLimitations = const [],
    this.primaryGoal = '',
    this.secondaryGoals = const [],
    this.trainerNotes = '',
  });

  factory ClientBaseline.empty() => ClientBaseline(
        clientId: 'client_${DateTime.now().microsecondsSinceEpoch}',
      );

  factory ClientBaseline.fromJson(Map<String, dynamic> json) {
    return ClientBaseline(
      clientId: _str(json['clientId']),
      clientName: _str(json['clientName']),
      ageYears: _int(json['ageYears'], fallback: 25),
      heightCm: _dbl(json['heightCm'], fallback: 170),
      weightKg: _dbl(json['weightKg'], fallback: 70),
      bodyFatPercent: _dbl(json['bodyFatPercent'], fallback: 15),
      sex: _sex(json['sex']),
      activityLevel: _activity(json['activityLevel']),
      dietaryRestrictions: _strList(json['dietaryRestrictions']),
      foodAllergies: _strList(json['foodAllergies']),
      medicalLimitations: _limitList(json['medicalLimitations']),
      primaryGoal: _str(json['primaryGoal']),
      secondaryGoals: _strList(json['secondaryGoals']),
      trainerNotes: _str(json['trainerNotes']),
    );
  }

  // ── Computed Properties ───────────────────────────────────────────────────

  /// Lean Body Mass in kg
  double get leanBodyMassKg => weightKg * (1 - bodyFatPercent / 100);

  /// Body Mass Index
  double get bmi {
    final heightM = heightCm / 100;
    if (heightM <= 0) return 0;
    return weightKg / (heightM * heightM);
  }

  /// Basal Metabolic Rate – Mifflin-St Jeor equation
  double get bmr {
    final base = 10 * weightKg + 6.25 * heightCm - 5 * ageYears;
    return sex == BiologicalSex.male ? base + 5 : base - 161;
  }

  /// Total Daily Energy Expenditure
  double get tdee => bmr * activityLevel.multiplier;

  ClientBaseline copyWith({
    String? clientId,
    String? clientName,
    int? ageYears,
    double? heightCm,
    double? weightKg,
    double? bodyFatPercent,
    BiologicalSex? sex,
    ActivityLevel? activityLevel,
    List<String>? dietaryRestrictions,
    List<String>? foodAllergies,
    List<MedicalLimitation>? medicalLimitations,
    String? primaryGoal,
    List<String>? secondaryGoals,
    String? trainerNotes,
  }) {
    return ClientBaseline(
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      ageYears: ageYears ?? this.ageYears,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bodyFatPercent: bodyFatPercent ?? this.bodyFatPercent,
      sex: sex ?? this.sex,
      activityLevel: activityLevel ?? this.activityLevel,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      foodAllergies: foodAllergies ?? this.foodAllergies,
      medicalLimitations: medicalLimitations ?? this.medicalLimitations,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      secondaryGoals: secondaryGoals ?? this.secondaryGoals,
      trainerNotes: trainerNotes ?? this.trainerNotes,
    );
  }

  Map<String, dynamic> toJson() => {
        'clientId': clientId,
        'clientName': clientName,
        'ageYears': ageYears,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'bodyFatPercent': bodyFatPercent,
        'sex': sex.name,
        'activityLevel': activityLevel.name,
        'dietaryRestrictions': dietaryRestrictions,
        'foodAllergies': foodAllergies,
        'medicalLimitations': medicalLimitations.map((l) => l.toJson()).toList(),
        'primaryGoal': primaryGoal,
        'secondaryGoals': secondaryGoals,
        'trainerNotes': trainerNotes,
      };

  @override
  List<Object?> get props => [
        clientId,
        clientName,
        ageYears,
        heightCm,
        weightKg,
        bodyFatPercent,
        sex,
        activityLevel,
        dietaryRestrictions,
        foodAllergies,
        medicalLimitations,
        primaryGoal,
        secondaryGoals,
        trainerNotes,
      ];
}

// ===========================================================================
// PRESCRIBED EXERCISE (ADVANCED)
// ===========================================================================

/// 4-digit tempo: eccentric / pause-bottom / concentric / pause-top
/// 'X' means explosive. Example: '3010' = 3s down, 0 pause, 1s up, 0 pause.
class ExerciseTempo extends Equatable {
  final String eccentric;
  final String pauseBottom;
  final String concentric;
  final String pauseTop;

  const ExerciseTempo({
    this.eccentric = '2',
    this.pauseBottom = '0',
    this.concentric = '1',
    this.pauseTop = '0',
  });

  factory ExerciseTempo.fromCode(String code) {
    final c = code.trim().padRight(4, '0');
    return ExerciseTempo(
      eccentric: c.substring(0, 1),
      pauseBottom: c.substring(1, 2),
      concentric: c.substring(2, 3),
      pauseTop: c.substring(3, 4),
    );
  }

  factory ExerciseTempo.fromJson(Map<String, dynamic> json) => ExerciseTempo(
        eccentric: _str(json['eccentric']),
        pauseBottom: _str(json['pauseBottom']),
        concentric: _str(json['concentric']),
        pauseTop: _str(json['pauseTop']),
      );

  ExerciseTempo copyWith({
    String? eccentric,
    String? pauseBottom,
    String? concentric,
    String? pauseTop,
  }) {
    return ExerciseTempo(
      eccentric: eccentric ?? this.eccentric,
      pauseBottom: pauseBottom ?? this.pauseBottom,
      concentric: concentric ?? this.concentric,
      pauseTop: pauseTop ?? this.pauseTop,
    );
  }

  String get code => '$eccentric$pauseBottom$concentric$pauseTop';

  Map<String, dynamic> toJson() => {
        'eccentric': eccentric,
        'pauseBottom': pauseBottom,
        'concentric': concentric,
        'pauseTop': pauseTop,
      };

  @override
  List<Object?> get props => [eccentric, pauseBottom, concentric, pauseTop];
}

class AdvancedExerciseMetrics extends Equatable {
  final int sets;
  final String reps;
  final String restTime;
  final String notes;

  /// Rate of Perceived Exertion (1–10)
  final double? rpe;

  /// Reps in Reserve (0 = failure)
  final int? rir;

  /// Percentage of 1-Rep Max (0–100)
  final double? percentOf1rm;

  final ExerciseTempo? tempo;
  final ExerciseModality modality;
  final SetType setType;

  /// Superset group identifier – exercises sharing this ID are paired
  final String? supersetGroupId;

  /// Trainer-facing cues and technique notes
  final String trainerCues;

  const AdvancedExerciseMetrics({
    this.sets = 3,
    this.reps = '8–12',
    this.restTime = '90 sec',
    this.notes = '',
    this.rpe,
    this.rir,
    this.percentOf1rm,
    this.tempo,
    this.modality = ExerciseModality.straightSet,
    this.setType = SetType.working,
    this.supersetGroupId,
    this.trainerCues = '',
  });

  factory AdvancedExerciseMetrics.fromJson(Map<String, dynamic> json) {
    return AdvancedExerciseMetrics(
      sets: _int(json['sets'], fallback: 3),
      reps: _str(json['reps']),
      restTime: _str(json['restTime']),
      notes: _str(json['notes']),
      rpe: json['rpe'] is num ? (json['rpe'] as num).toDouble() : null,
      rir: json['rir'] is int ? json['rir'] as int : null,
      percentOf1rm: json['percentOf1rm'] is num ? (json['percentOf1rm'] as num).toDouble() : null,
      tempo: json['tempo'] is Map<String, dynamic>
          ? ExerciseTempo.fromJson(json['tempo'] as Map<String, dynamic>)
          : null,
      modality: _modality(json['modality']),
      setType: _setType(json['setType']),
      supersetGroupId: json['supersetGroupId'] is String ? json['supersetGroupId'] as String : null,
      trainerCues: _str(json['trainerCues']),
    );
  }

  AdvancedExerciseMetrics copyWith({
    int? sets,
    String? reps,
    String? restTime,
    String? notes,
    Object? rpe = _notSet,
    Object? rir = _notSet,
    Object? percentOf1rm = _notSet,
    Object? tempo = _notSet,
    ExerciseModality? modality,
    SetType? setType,
    Object? supersetGroupId = _notSet,
    String? trainerCues,
  }) {
    return AdvancedExerciseMetrics(
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      restTime: restTime ?? this.restTime,
      notes: notes ?? this.notes,
      rpe: rpe == _notSet ? this.rpe : rpe as double?,
      rir: rir == _notSet ? this.rir : rir as int?,
      percentOf1rm: percentOf1rm == _notSet ? this.percentOf1rm : percentOf1rm as double?,
      tempo: tempo == _notSet ? this.tempo : tempo as ExerciseTempo?,
      modality: modality ?? this.modality,
      setType: setType ?? this.setType,
      supersetGroupId: supersetGroupId == _notSet ? this.supersetGroupId : supersetGroupId as String?,
      trainerCues: trainerCues ?? this.trainerCues,
    );
  }

  Map<String, dynamic> toJson() => {
        'sets': sets,
        'reps': reps,
        'restTime': restTime,
        'notes': notes,
        'rpe': rpe,
        'rir': rir,
        'percentOf1rm': percentOf1rm,
        'tempo': tempo?.toJson(),
        'modality': modality.name,
        'setType': setType.name,
        'supersetGroupId': supersetGroupId,
        'trainerCues': trainerCues,
      };

  @override
  List<Object?> get props => [
        sets,
        reps,
        restTime,
        notes,
        rpe,
        rir,
        percentOf1rm,
        tempo,
        modality,
        setType,
        supersetGroupId,
        trainerCues,
      ];
}

class AdvancedPrescribedExercise extends Equatable {
  final String id;
  final Exercise exercise;
  final AdvancedExerciseMetrics metrics;

  /// Alternative/substitute exercise if primary is unavailable
  final Exercise? alternativeExercise;

  /// Order within the workout day (0-indexed)
  final int order;

  const AdvancedPrescribedExercise({
    required this.id,
    required this.exercise,
    this.metrics = const AdvancedExerciseMetrics(),
    this.alternativeExercise,
    this.order = 0,
  });

  factory AdvancedPrescribedExercise.fromJson(Map<String, dynamic> json) {
    return AdvancedPrescribedExercise(
      id: _str(json['id']),
      exercise: json['exercise'] is Map<String, dynamic>
          ? Exercise.fromJson(json['exercise'] as Map<String, dynamic>)
          : const Exercise(id: 0, name: '', videoUrl: '', targetBodyPart: '', trainingType: ''),
      metrics: json['metrics'] is Map<String, dynamic>
          ? AdvancedExerciseMetrics.fromJson(json['metrics'] as Map<String, dynamic>)
          : const AdvancedExerciseMetrics(),
      alternativeExercise: json['alternativeExercise'] is Map<String, dynamic>
          ? Exercise.fromJson(json['alternativeExercise'] as Map<String, dynamic>)
          : null,
      order: _int(json['order']),
    );
  }

  AdvancedPrescribedExercise copyWith({
    String? id,
    Exercise? exercise,
    AdvancedExerciseMetrics? metrics,
    Object? alternativeExercise = _notSet,
    int? order,
  }) {
    return AdvancedPrescribedExercise(
      id: id ?? this.id,
      exercise: exercise ?? this.exercise,
      metrics: metrics ?? this.metrics,
      alternativeExercise:
          alternativeExercise == _notSet ? this.alternativeExercise : alternativeExercise as Exercise?,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'exercise': exercise.toJson(),
        'metrics': metrics.toJson(),
        'alternativeExercise': alternativeExercise?.toJson(),
        'order': order,
      };

  @override
  List<Object?> get props => [id, exercise, metrics, alternativeExercise, order];
}

// ===========================================================================
// WORKOUT DAY (ADVANCED)
// ===========================================================================

class AdvancedWorkoutDay extends Equatable {
  final String id;
  final String name;
  final List<AdvancedPrescribedExercise> exercises;

  /// Optional day-level trainer notes
  final String sessionNotes;

  /// Estimated session duration in minutes
  final int? estimatedDurationMinutes;

  const AdvancedWorkoutDay({
    required this.id,
    required this.name,
    this.exercises = const [],
    this.sessionNotes = '',
    this.estimatedDurationMinutes,
  });

  factory AdvancedWorkoutDay.fromJson(Map<String, dynamic> json) {
    return AdvancedWorkoutDay(
      id: _str(json['id']),
      name: _str(json['name']),
      exercises: json['exercises'] is List
          ? (json['exercises'] as List)
              .whereType<Map<String, dynamic>>()
              .map(AdvancedPrescribedExercise.fromJson)
              .toList(growable: false)
          : const [],
      sessionNotes: _str(json['sessionNotes']),
      estimatedDurationMinutes: json['estimatedDurationMinutes'] is int
          ? json['estimatedDurationMinutes'] as int
          : null,
    );
  }

  /// Sets per body part for this day
  Map<String, int> get setsPerBodyPart {
    final result = <String, int>{};
    for (final ex in exercises) {
      if (ex.metrics.setType == SetType.warmup) continue;
      final bp = ex.exercise.targetBodyPart;
      if (bp.isEmpty) continue;
      result[bp] = (result[bp] ?? 0) + ex.metrics.sets;
    }
    return result;
  }

  AdvancedWorkoutDay copyWith({
    String? id,
    String? name,
    List<AdvancedPrescribedExercise>? exercises,
    String? sessionNotes,
    Object? estimatedDurationMinutes = _notSet,
  }) {
    return AdvancedWorkoutDay(
      id: id ?? this.id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
      sessionNotes: sessionNotes ?? this.sessionNotes,
      estimatedDurationMinutes: estimatedDurationMinutes == _notSet
          ? this.estimatedDurationMinutes
          : estimatedDurationMinutes as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'sessionNotes': sessionNotes,
        'estimatedDurationMinutes': estimatedDurationMinutes,
      };

  @override
  List<Object?> get props => [id, name, exercises, sessionNotes, estimatedDurationMinutes];
}

// ===========================================================================
// NUTRITION PROTOCOL
// ===========================================================================

class MacroTarget extends Equatable {
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatsG;
  final double fiberG;

  const MacroTarget({
    this.calories = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatsG = 0,
    this.fiberG = 0,
  });

  factory MacroTarget.fromJson(Map<String, dynamic> json) => MacroTarget(
        calories: _dbl(json['calories']),
        proteinG: _dbl(json['proteinG']),
        carbsG: _dbl(json['carbsG']),
        fatsG: _dbl(json['fatsG']),
        fiberG: _dbl(json['fiberG']),
      );

  MacroTarget copyWith({
    double? calories,
    double? proteinG,
    double? carbsG,
    double? fatsG,
    double? fiberG,
  }) {
    return MacroTarget(
      calories: calories ?? this.calories,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatsG: fatsG ?? this.fatsG,
      fiberG: fiberG ?? this.fiberG,
    );
  }

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'proteinG': proteinG,
        'carbsG': carbsG,
        'fatsG': fatsG,
        'fiberG': fiberG,
      };

  @override
  List<Object?> get props => [calories, proteinG, carbsG, fatsG, fiberG];
}

class FoodItem extends Equatable {
  final String id;
  final String name;
  final double quantityG;

  /// Macros per 100g – runtime calculated for the given quantity
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatsPer100g;

  const FoodItem({
    required this.id,
    required this.name,
    this.quantityG = 100,
    this.caloriesPer100g = 0,
    this.proteinPer100g = 0,
    this.carbsPer100g = 0,
    this.fatsPer100g = 0,
  });

  double get calories => caloriesPer100g * quantityG / 100;
  double get protein => proteinPer100g * quantityG / 100;
  double get carbs => carbsPer100g * quantityG / 100;
  double get fats => fatsPer100g * quantityG / 100;

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
        id: _str(json['id']),
        name: _str(json['name']),
        quantityG: _dbl(json['quantityG'], fallback: 100),
        caloriesPer100g: _dbl(json['caloriesPer100g']),
        proteinPer100g: _dbl(json['proteinPer100g']),
        carbsPer100g: _dbl(json['carbsPer100g']),
        fatsPer100g: _dbl(json['fatsPer100g']),
      );

  FoodItem copyWith({
    String? id,
    String? name,
    double? quantityG,
    double? caloriesPer100g,
    double? proteinPer100g,
    double? carbsPer100g,
    double? fatsPer100g,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantityG: quantityG ?? this.quantityG,
      caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
      proteinPer100g: proteinPer100g ?? this.proteinPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      fatsPer100g: fatsPer100g ?? this.fatsPer100g,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantityG': quantityG,
        'caloriesPer100g': caloriesPer100g,
        'proteinPer100g': proteinPer100g,
        'carbsPer100g': carbsPer100g,
        'fatsPer100g': fatsPer100g,
      };

  @override
  List<Object?> get props => [id, name, quantityG, caloriesPer100g, proteinPer100g, carbsPer100g, fatsPer100g];
}

class MealSlot extends Equatable {
  final String id;
  final MealSlotType type;
  final String customName;
  final String timeOfDay;
  final List<FoodItem> foods;
  final String notes;

  const MealSlot({
    required this.id,
    this.type = MealSlotType.other,
    this.customName = '',
    this.timeOfDay = '',
    this.foods = const [],
    this.notes = '',
  });

  String get displayName => customName.isNotEmpty ? customName : type.label;

  MacroTarget get totals {
    var cal = 0.0, pro = 0.0, carb = 0.0, fat = 0.0;
    for (final f in foods) {
      cal += f.calories;
      pro += f.protein;
      carb += f.carbs;
      fat += f.fats;
    }
    return MacroTarget(calories: cal, proteinG: pro, carbsG: carb, fatsG: fat);
  }

  factory MealSlot.fromJson(Map<String, dynamic> json) => MealSlot(
        id: _str(json['id']),
        type: _mealSlotType(json['type']),
        customName: _str(json['customName']),
        timeOfDay: _str(json['timeOfDay']),
        foods: json['foods'] is List
            ? (json['foods'] as List).whereType<Map<String, dynamic>>().map(FoodItem.fromJson).toList()
            : const [],
        notes: _str(json['notes']),
      );

  MealSlot copyWith({
    String? id,
    MealSlotType? type,
    String? customName,
    String? timeOfDay,
    List<FoodItem>? foods,
    String? notes,
  }) {
    return MealSlot(
      id: id ?? this.id,
      type: type ?? this.type,
      customName: customName ?? this.customName,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      foods: foods ?? this.foods,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'customName': customName,
        'timeOfDay': timeOfDay,
        'foods': foods.map((f) => f.toJson()).toList(),
        'notes': notes,
      };

  @override
  List<Object?> get props => [id, type, customName, timeOfDay, foods, notes];
}

/// Day-level cycling override (null fields inherit from base targets)
class MacroCycleDay extends Equatable {
  final String label; // e.g. 'High Carb', 'Low Carb', 'Rest Day'
  final MacroTarget targets;

  const MacroCycleDay({required this.label, required this.targets});

  factory MacroCycleDay.fromJson(Map<String, dynamic> json) => MacroCycleDay(
        label: _str(json['label']),
        targets: MacroTarget.fromJson((json['targets'] as Map<String, dynamic>?) ?? {}),
      );

  MacroCycleDay copyWith({String? label, MacroTarget? targets}) =>
      MacroCycleDay(label: label ?? this.label, targets: targets ?? this.targets);

  Map<String, dynamic> toJson() => {'label': label, 'targets': targets.toJson()};

  @override
  List<Object?> get props => [label, targets];
}

class MicronutrientTarget extends Equatable {
  final String nutrientName;
  final double targetAmount;
  final String unit;

  const MicronutrientTarget({
    required this.nutrientName,
    required this.targetAmount,
    required this.unit,
  });

  factory MicronutrientTarget.fromJson(Map<String, dynamic> json) => MicronutrientTarget(
        nutrientName: _str(json['nutrientName']),
        targetAmount: _dbl(json['targetAmount']),
        unit: _str(json['unit']),
      );

  MicronutrientTarget copyWith({String? nutrientName, double? targetAmount, String? unit}) =>
      MicronutrientTarget(
        nutrientName: nutrientName ?? this.nutrientName,
        targetAmount: targetAmount ?? this.targetAmount,
        unit: unit ?? this.unit,
      );

  Map<String, dynamic> toJson() => {
        'nutrientName': nutrientName,
        'targetAmount': targetAmount,
        'unit': unit,
      };

  @override
  List<Object?> get props => [nutrientName, targetAmount, unit];
}

class NutritionProtocol extends Equatable {
  final MacroTarget baseTargets;
  final MacroCycleStrategy cycleStrategy;

  /// Ordered cycle pattern (e.g. [High, Low, Low, High, Low, Moderate, Rest])
  final List<MacroCycleDay> cycleDays;

  final List<MealSlot> mealSlots;
  final List<MicronutrientTarget> micronutrientTargets;
  final String notes;

  const NutritionProtocol({
    this.baseTargets = const MacroTarget(),
    this.cycleStrategy = MacroCycleStrategy.none,
    this.cycleDays = const [],
    this.mealSlots = const [],
    this.micronutrientTargets = const [],
    this.notes = '',
  });

  factory NutritionProtocol.fromJson(Map<String, dynamic> json) => NutritionProtocol(
        baseTargets: json['baseTargets'] is Map<String, dynamic>
            ? MacroTarget.fromJson(json['baseTargets'] as Map<String, dynamic>)
            : const MacroTarget(),
        cycleStrategy: _cyclestrat(json['cycleStrategy']),
        cycleDays: json['cycleDays'] is List
            ? (json['cycleDays'] as List)
                .whereType<Map<String, dynamic>>()
                .map(MacroCycleDay.fromJson)
                .toList()
            : const [],
        mealSlots: json['mealSlots'] is List
            ? (json['mealSlots'] as List)
                .whereType<Map<String, dynamic>>()
                .map(MealSlot.fromJson)
                .toList()
            : const [],
        micronutrientTargets: json['micronutrientTargets'] is List
            ? (json['micronutrientTargets'] as List)
                .whereType<Map<String, dynamic>>()
                .map(MicronutrientTarget.fromJson)
                .toList()
            : const [],
        notes: _str(json['notes']),
      );

  NutritionProtocol copyWith({
    MacroTarget? baseTargets,
    MacroCycleStrategy? cycleStrategy,
    List<MacroCycleDay>? cycleDays,
    List<MealSlot>? mealSlots,
    List<MicronutrientTarget>? micronutrientTargets,
    String? notes,
  }) {
    return NutritionProtocol(
      baseTargets: baseTargets ?? this.baseTargets,
      cycleStrategy: cycleStrategy ?? this.cycleStrategy,
      cycleDays: cycleDays ?? this.cycleDays,
      mealSlots: mealSlots ?? this.mealSlots,
      micronutrientTargets: micronutrientTargets ?? this.micronutrientTargets,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'baseTargets': baseTargets.toJson(),
        'cycleStrategy': cycleStrategy.name,
        'cycleDays': cycleDays.map((d) => d.toJson()).toList(),
        'mealSlots': mealSlots.map((m) => m.toJson()).toList(),
        'micronutrientTargets': micronutrientTargets.map((m) => m.toJson()).toList(),
        'notes': notes,
      };

  @override
  List<Object?> get props => [baseTargets, cycleStrategy, cycleDays, mealSlots, micronutrientTargets, notes];
}

// ===========================================================================
// LIFESTYLE PROTOCOL
// ===========================================================================

class SupplementEntry extends Equatable {
  final String id;
  final String name;
  final String dosage;
  final String timing;
  final String frequency;
  final String purpose;
  final String notes;

  const SupplementEntry({
    required this.id,
    required this.name,
    this.dosage = '',
    this.timing = '',
    this.frequency = 'Daily',
    this.purpose = '',
    this.notes = '',
  });

  factory SupplementEntry.fromJson(Map<String, dynamic> json) => SupplementEntry(
        id: _str(json['id']),
        name: _str(json['name']),
        dosage: _str(json['dosage']),
        timing: _str(json['timing']),
        frequency: _str(json['frequency']),
        purpose: _str(json['purpose']),
        notes: _str(json['notes']),
      );

  SupplementEntry copyWith({
    String? id,
    String? name,
    String? dosage,
    String? timing,
    String? frequency,
    String? purpose,
    String? notes,
  }) {
    return SupplementEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      timing: timing ?? this.timing,
      frequency: frequency ?? this.frequency,
      purpose: purpose ?? this.purpose,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'timing': timing,
        'frequency': frequency,
        'purpose': purpose,
        'notes': notes,
      };

  @override
  List<Object?> get props => [id, name, dosage, timing, frequency, purpose, notes];
}

class CardioPrescription extends Equatable {
  final String id;
  final CardioType type;
  final int durationMinutes;

  /// LISS: target BPM / HIIT: work BPM
  final int? targetHeartRateBpm;

  /// HIIT: rest BPM
  final int? restHeartRateBpm;

  /// HIIT: work:rest ratio string e.g. '1:2'
  final String? workRestRatio;

  /// Number of rounds/intervals
  final int? rounds;

  final int sessionsPerWeek;
  final String notes;

  const CardioPrescription({
    required this.id,
    this.type = CardioType.liss,
    this.durationMinutes = 30,
    this.targetHeartRateBpm,
    this.restHeartRateBpm,
    this.workRestRatio,
    this.rounds,
    this.sessionsPerWeek = 3,
    this.notes = '',
  });

  factory CardioPrescription.fromJson(Map<String, dynamic> json) => CardioPrescription(
        id: _str(json['id']),
        type: _cardioType(json['type']),
        durationMinutes: _int(json['durationMinutes'], fallback: 30),
        targetHeartRateBpm: json['targetHeartRateBpm'] is int ? json['targetHeartRateBpm'] as int : null,
        restHeartRateBpm: json['restHeartRateBpm'] is int ? json['restHeartRateBpm'] as int : null,
        workRestRatio: json['workRestRatio'] is String ? json['workRestRatio'] as String : null,
        rounds: json['rounds'] is int ? json['rounds'] as int : null,
        sessionsPerWeek: _int(json['sessionsPerWeek'], fallback: 3),
        notes: _str(json['notes']),
      );

  CardioPrescription copyWith({
    String? id,
    CardioType? type,
    int? durationMinutes,
    Object? targetHeartRateBpm = _notSet,
    Object? restHeartRateBpm = _notSet,
    Object? workRestRatio = _notSet,
    Object? rounds = _notSet,
    int? sessionsPerWeek,
    String? notes,
  }) {
    return CardioPrescription(
      id: id ?? this.id,
      type: type ?? this.type,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      targetHeartRateBpm: targetHeartRateBpm == _notSet ? this.targetHeartRateBpm : targetHeartRateBpm as int?,
      restHeartRateBpm: restHeartRateBpm == _notSet ? this.restHeartRateBpm : restHeartRateBpm as int?,
      workRestRatio: workRestRatio == _notSet ? this.workRestRatio : workRestRatio as String?,
      rounds: rounds == _notSet ? this.rounds : rounds as int?,
      sessionsPerWeek: sessionsPerWeek ?? this.sessionsPerWeek,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'durationMinutes': durationMinutes,
        'targetHeartRateBpm': targetHeartRateBpm,
        'restHeartRateBpm': restHeartRateBpm,
        'workRestRatio': workRestRatio,
        'rounds': rounds,
        'sessionsPerWeek': sessionsPerWeek,
        'notes': notes,
      };

  @override
  List<Object?> get props => [
        id, type, durationMinutes, targetHeartRateBpm,
        restHeartRateBpm, workRestRatio, rounds, sessionsPerWeek, notes,
      ];
}

class MobilityRoutine extends Equatable {
  final String id;
  final String name;
  final int durationMinutes;
  final List<String> targetAreas;
  final String notes;

  const MobilityRoutine({
    required this.id,
    required this.name,
    this.durationMinutes = 10,
    this.targetAreas = const [],
    this.notes = '',
  });

  factory MobilityRoutine.fromJson(Map<String, dynamic> json) => MobilityRoutine(
        id: _str(json['id']),
        name: _str(json['name']),
        durationMinutes: _int(json['durationMinutes'], fallback: 10),
        targetAreas: _strList(json['targetAreas']),
        notes: _str(json['notes']),
      );

  MobilityRoutine copyWith({
    String? id,
    String? name,
    int? durationMinutes,
    List<String>? targetAreas,
    String? notes,
  }) {
    return MobilityRoutine(
      id: id ?? this.id,
      name: name ?? this.name,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      targetAreas: targetAreas ?? this.targetAreas,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'durationMinutes': durationMinutes,
        'targetAreas': targetAreas,
        'notes': notes,
      };

  @override
  List<Object?> get props => [id, name, durationMinutes, targetAreas, notes];
}

class LifestyleProtocol extends Equatable {
  /// Target sleep duration in hours
  final double sleepTargetHours;
  final String sleepNotes;

  /// NEAT – daily step target
  final int neatStepsTarget;

  final List<CardioPrescription> cardioPrescriptions;
  final List<MobilityRoutine> mobilityRoutines;
  final List<SupplementEntry> supplements;

  const LifestyleProtocol({
    this.sleepTargetHours = 8,
    this.sleepNotes = '',
    this.neatStepsTarget = 8000,
    this.cardioPrescriptions = const [],
    this.mobilityRoutines = const [],
    this.supplements = const [],
  });

  factory LifestyleProtocol.fromJson(Map<String, dynamic> json) => LifestyleProtocol(
        sleepTargetHours: _dbl(json['sleepTargetHours'], fallback: 8),
        sleepNotes: _str(json['sleepNotes']),
        neatStepsTarget: _int(json['neatStepsTarget'], fallback: 8000),
        cardioPrescriptions: json['cardioPrescriptions'] is List
            ? (json['cardioPrescriptions'] as List)
                .whereType<Map<String, dynamic>>()
                .map(CardioPrescription.fromJson)
                .toList()
            : const [],
        mobilityRoutines: json['mobilityRoutines'] is List
            ? (json['mobilityRoutines'] as List)
                .whereType<Map<String, dynamic>>()
                .map(MobilityRoutine.fromJson)
                .toList()
            : const [],
        supplements: json['supplements'] is List
            ? (json['supplements'] as List)
                .whereType<Map<String, dynamic>>()
                .map(SupplementEntry.fromJson)
                .toList()
            : const [],
      );

  LifestyleProtocol copyWith({
    double? sleepTargetHours,
    String? sleepNotes,
    int? neatStepsTarget,
    List<CardioPrescription>? cardioPrescriptions,
    List<MobilityRoutine>? mobilityRoutines,
    List<SupplementEntry>? supplements,
  }) {
    return LifestyleProtocol(
      sleepTargetHours: sleepTargetHours ?? this.sleepTargetHours,
      sleepNotes: sleepNotes ?? this.sleepNotes,
      neatStepsTarget: neatStepsTarget ?? this.neatStepsTarget,
      cardioPrescriptions: cardioPrescriptions ?? this.cardioPrescriptions,
      mobilityRoutines: mobilityRoutines ?? this.mobilityRoutines,
      supplements: supplements ?? this.supplements,
    );
  }

  Map<String, dynamic> toJson() => {
        'sleepTargetHours': sleepTargetHours,
        'sleepNotes': sleepNotes,
        'neatStepsTarget': neatStepsTarget,
        'cardioPrescriptions': cardioPrescriptions.map((c) => c.toJson()).toList(),
        'mobilityRoutines': mobilityRoutines.map((m) => m.toJson()).toList(),
        'supplements': supplements.map((s) => s.toJson()).toList(),
      };

  @override
  List<Object?> get props => [
        sleepTargetHours,
        sleepNotes,
        neatStepsTarget,
        cardioPrescriptions,
        mobilityRoutines,
        supplements,
      ];
}

// ===========================================================================
// TRAINING PROGRAM (ROOT DOCUMENT)
// ===========================================================================

class ProgressionRule extends Equatable {
  final String id;
  final String trigger; // e.g. 'all_sets_completed_at_top_rep'
  final String action; // e.g. 'increase_weight_by_2.5kg'
  final String notes;

  const ProgressionRule({
    required this.id,
    required this.trigger,
    required this.action,
    this.notes = '',
  });

  factory ProgressionRule.fromJson(Map<String, dynamic> json) => ProgressionRule(
        id: _str(json['id']),
        trigger: _str(json['trigger']),
        action: _str(json['action']),
        notes: _str(json['notes']),
      );

  ProgressionRule copyWith({String? id, String? trigger, String? action, String? notes}) =>
      ProgressionRule(
        id: id ?? this.id,
        trigger: trigger ?? this.trigger,
        action: action ?? this.action,
        notes: notes ?? this.notes,
      );

  Map<String, dynamic> toJson() => {'id': id, 'trigger': trigger, 'action': action, 'notes': notes};

  @override
  List<Object?> get props => [id, trigger, action, notes];
}

class TrainingProgram extends Equatable {
  // ── Meta ──────────────────────────────────────────────────────────────────
  final String id;
  final String name;
  final String description;
  final String color;

  // ── Timeline ──────────────────────────────────────────────────────────────
  final DateTime? startDate;
  final DateTime? endDate;
  final ProgrammeCycleType cycleType;
  final int duration;

  // ── Phase ─────────────────────────────────────────────────────────────────
  final PhaseObjective phaseObjective;
  final List<String> goals;

  // ── Content ───────────────────────────────────────────────────────────────
  final List<AdvancedWorkoutDay> workoutDays;
  final NutritionProtocol nutritionProtocol;
  final LifestyleProtocol lifestyleProtocol;
  final List<ProgressionRule> progressionRules;

  // ── Admin ─────────────────────────────────────────────────────────────────
  final ProgramStatus status;
  final bool isTemplate;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TrainingProgram({
    required this.id,
    this.name = '',
    this.description = '',
    this.color = '#6C63FF',
    this.startDate,
    this.endDate,
    this.cycleType = ProgrammeCycleType.mesocycle,
    this.duration = 8,
    this.phaseObjective = PhaseObjective.accumulation,
    this.goals = const [],
    this.workoutDays = const [],
    this.nutritionProtocol = const NutritionProtocol(),
    this.lifestyleProtocol = const LifestyleProtocol(),
    this.progressionRules = const [],
    this.status = ProgramStatus.draft,
    this.isTemplate = false,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TrainingProgram.empty() {
    final now = DateTime.now();
    return TrainingProgram(
      id: 'program_${now.microsecondsSinceEpoch}',
      createdAt: now,
      updatedAt: now,
    );
  }

  factory TrainingProgram.fromJson(Map<String, dynamic> json) {
    return TrainingProgram(
      id: _str(json['id']),
      name: _str(json['name']),
      description: _str(json['description']),
      color: _str(json['color'], fallback: '#6C63FF'),
      startDate: json['startDate'] is String ? DateTime.tryParse(json['startDate'] as String) : null,
      endDate: json['endDate'] is String ? DateTime.tryParse(json['endDate'] as String) : null,
      cycleType: _cycleType(json['cycleType']),
      duration: _int(json['duration'], fallback: 8),
      phaseObjective: _phase(json['phaseObjective']),
      goals: _strList(json['goals']),
      workoutDays: json['workoutDays'] is List
          ? (json['workoutDays'] as List)
              .whereType<Map<String, dynamic>>()
              .map(AdvancedWorkoutDay.fromJson)
              .toList()
          : const [],
      nutritionProtocol: json['nutritionProtocol'] is Map<String, dynamic>
          ? NutritionProtocol.fromJson(json['nutritionProtocol'] as Map<String, dynamic>)
          : const NutritionProtocol(),
      lifestyleProtocol: json['lifestyleProtocol'] is Map<String, dynamic>
          ? LifestyleProtocol.fromJson(json['lifestyleProtocol'] as Map<String, dynamic>)
          : const LifestyleProtocol(),
      progressionRules: json['progressionRules'] is List
          ? (json['progressionRules'] as List)
              .whereType<Map<String, dynamic>>()
              .map(ProgressionRule.fromJson)
              .toList()
          : const [],
      status: _status(json['status']),
      isTemplate: json['isTemplate'] is bool ? json['isTemplate'] as bool : false,
      isPinned: json['isPinned'] is bool ? json['isPinned'] as bool : false,
      createdAt: json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] is String
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  TrainingProgram copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    Object? startDate = _notSet,
    Object? endDate = _notSet,
    ProgrammeCycleType? cycleType,
    int? duration,
    PhaseObjective? phaseObjective,
    List<String>? goals,
    List<AdvancedWorkoutDay>? workoutDays,
    NutritionProtocol? nutritionProtocol,
    LifestyleProtocol? lifestyleProtocol,
    List<ProgressionRule>? progressionRules,
    ProgramStatus? status,
    bool? isTemplate,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrainingProgram(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      startDate: startDate == _notSet ? this.startDate : startDate as DateTime?,
      endDate: endDate == _notSet ? this.endDate : endDate as DateTime?,
      cycleType: cycleType ?? this.cycleType,
      duration: duration ?? this.duration,
      phaseObjective: phaseObjective ?? this.phaseObjective,
      goals: goals ?? this.goals,
      workoutDays: workoutDays ?? this.workoutDays,
      nutritionProtocol: nutritionProtocol ?? this.nutritionProtocol,
      lifestyleProtocol: lifestyleProtocol ?? this.lifestyleProtocol,
      progressionRules: progressionRules ?? this.progressionRules,
      status: status ?? this.status,
      isTemplate: isTemplate ?? this.isTemplate,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'color': color,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'cycleType': cycleType.name,
        'duration': duration,
        'phaseObjective': phaseObjective.name,
        'goals': goals,
        'workoutDays': workoutDays.map((d) => d.toJson()).toList(),
        'nutritionProtocol': nutritionProtocol.toJson(),
        'lifestyleProtocol': lifestyleProtocol.toJson(),
        'progressionRules': progressionRules.map((r) => r.toJson()).toList(),
        'status': status.name,
        'isTemplate': isTemplate,
        'isPinned': isPinned,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id, name, description, color, startDate, endDate, cycleType,
        duration, phaseObjective, goals, workoutDays, nutritionProtocol,
        lifestyleProtocol, progressionRules, status, isTemplate, isPinned,
        createdAt, updatedAt,
      ];
}

// ===========================================================================
// PRIVATE HELPERS
// ===========================================================================

const Object _notSet = Object();

String _str(Object? v, {String fallback = ''}) => v is String ? v : fallback;

int _int(Object? v, {int fallback = 0}) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

double _dbl(Object? v, {double fallback = 0.0}) {
  if (v is double) return v;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}

List<String> _strList(Object? v) =>
    v is List ? v.whereType<String>().toList(growable: false) : const [];

List<MedicalLimitation> _limitList(Object? v) => v is List
    ? v.whereType<Map<String, dynamic>>().map(MedicalLimitation.fromJson).toList()
    : const [];

BiologicalSex _sex(Object? v) {
  if (v is String) {
    for (final s in BiologicalSex.values) {
      if (s.name == v) return s;
    }
  }
  return BiologicalSex.male;
}

ActivityLevel _activity(Object? v) {
  if (v is String) {
    for (final a in ActivityLevel.values) {
      if (a.name == v) return a;
    }
  }
  return ActivityLevel.moderatelyActive;
}

ExerciseModality _modality(Object? v) {
  if (v is String) {
    for (final m in ExerciseModality.values) {
      if (m.name == v) return m;
    }
  }
  return ExerciseModality.straightSet;
}

SetType _setType(Object? v) {
  if (v is String) {
    for (final s in SetType.values) {
      if (s.name == v) return s;
    }
  }
  return SetType.working;
}

CardioType _cardioType(Object? v) {
  if (v is String) {
    for (final c in CardioType.values) {
      if (c.name == v) return c;
    }
  }
  return CardioType.liss;
}

MealSlotType _mealSlotType(Object? v) {
  if (v is String) {
    for (final m in MealSlotType.values) {
      if (m.name == v) return m;
    }
  }
  return MealSlotType.other;
}

MacroCycleStrategy _cyclestrat(Object? v) {
  if (v is String) {
    for (final s in MacroCycleStrategy.values) {
      if (s.name == v) return s;
    }
  }
  return MacroCycleStrategy.none;
}

ProgrammeCycleType _cycleType(Object? v) {
  if (v is String) {
    for (final c in ProgrammeCycleType.values) {
      if (c.name == v) return c;
    }
  }
  return ProgrammeCycleType.mesocycle;
}

PhaseObjective _phase(Object? v) {
  if (v is String) {
    for (final p in PhaseObjective.values) {
      if (p.name == v) return p;
    }
  }
  return PhaseObjective.accumulation;
}

ProgramStatus _status(Object? v) {
  if (v is String) {
    for (final s in ProgramStatus.values) {
      if (s.name == v) return s;
    }
  }
  return ProgramStatus.draft;
}
