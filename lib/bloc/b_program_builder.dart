import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/m_programmes.dart';
import '../models/m_programmes_exercise.dart';
import '../models/m_program_builder_models.dart';

// ===========================================================================
// EVENTS
// ===========================================================================

abstract class ProgramBuilderEvent extends Equatable {
  const ProgramBuilderEvent();

  @override
  List<Object?> get props => [];
}

// ── Client Baseline ──────────────────────────────────────────────────────────

class ProgramBuilderBaselineUpdated extends ProgramBuilderEvent {
  final ClientBaseline baseline;
  const ProgramBuilderBaselineUpdated(this.baseline);

  @override
  List<Object?> get props => [baseline];
}

class ProgramBuilderBiometricsChanged extends ProgramBuilderEvent {
  final int? ageYears;
  final double? heightCm;
  final double? weightKg;
  final double? bodyFatPercent;
  final BiologicalSex? sex;
  final ActivityLevel? activityLevel;

  const ProgramBuilderBiometricsChanged({
    this.ageYears,
    this.heightCm,
    this.weightKg,
    this.bodyFatPercent,
    this.sex,
    this.activityLevel,
  });

  @override
  List<Object?> get props =>
      [ageYears, heightCm, weightKg, bodyFatPercent, sex, activityLevel];
}

class ProgramBuilderMedicalLimitationAdded extends ProgramBuilderEvent {
  final MedicalLimitation limitation;
  const ProgramBuilderMedicalLimitationAdded(this.limitation);

  @override
  List<Object?> get props => [limitation];
}

class ProgramBuilderMedicalLimitationRemoved extends ProgramBuilderEvent {
  final String limitationId;
  const ProgramBuilderMedicalLimitationRemoved(this.limitationId);

  @override
  List<Object?> get props => [limitationId];
}

// ── Program Meta ─────────────────────────────────────────────────────────────

class ProgramBuilderMetaChanged extends ProgramBuilderEvent {
  final String? name;
  final String? description;
  final String? color;
  final ProgrammeCycleType? cycleType;
  final int? duration;
  final PhaseObjective? phaseObjective;
  final List<String>? goals;
  final DateTime? startDate;
  final DateTime? endDate;
  final ProgramStatus? status;
  final bool? isTemplate;

  const ProgramBuilderMetaChanged({
    this.name,
    this.description,
    this.color,
    this.cycleType,
    this.duration,
    this.phaseObjective,
    this.goals,
    this.startDate,
    this.endDate,
    this.status,
    this.isTemplate,
  });

  @override
  List<Object?> get props => [
        name,
        description,
        color,
        cycleType,
        duration,
        phaseObjective,
        goals,
        startDate,
        endDate,
        status,
        isTemplate,
      ];
}

// ── Workout Days ──────────────────────────────────────────────────────────────

class ProgramBuilderDayAdded extends ProgramBuilderEvent {
  const ProgramBuilderDayAdded();
}

class ProgramBuilderDayRenamed extends ProgramBuilderEvent {
  final String dayId;
  final String name;
  const ProgramBuilderDayRenamed({required this.dayId, required this.name});

  @override
  List<Object?> get props => [dayId, name];
}

class ProgramBuilderDayRemoved extends ProgramBuilderEvent {
  final String dayId;
  const ProgramBuilderDayRemoved(this.dayId);

  @override
  List<Object?> get props => [dayId];
}

class ProgramBuilderDayCloned extends ProgramBuilderEvent {
  final String dayId;
  const ProgramBuilderDayCloned(this.dayId);

  @override
  List<Object?> get props => [dayId];
}

class ProgramBuilderDayNotesChanged extends ProgramBuilderEvent {
  final String dayId;
  final String notes;
  const ProgramBuilderDayNotesChanged(
      {required this.dayId, required this.notes});

  @override
  List<Object?> get props => [dayId, notes];
}

// ── Exercises ─────────────────────────────────────────────────────────────────

class ProgramBuilderExerciseAdded extends ProgramBuilderEvent {
  final String dayId;
  final Exercise exercise;
  const ProgramBuilderExerciseAdded(
      {required this.dayId, required this.exercise});

  @override
  List<Object?> get props => [dayId, exercise];
}

class ProgramBuilderExerciseRemoved extends ProgramBuilderEvent {
  final String dayId;
  final String exerciseId;
  const ProgramBuilderExerciseRemoved(
      {required this.dayId, required this.exerciseId});

  @override
  List<Object?> get props => [dayId, exerciseId];
}

class ProgramBuilderExerciseMetricsChanged extends ProgramBuilderEvent {
  final String dayId;
  final String exerciseId;
  final AdvancedExerciseMetrics metrics;
  const ProgramBuilderExerciseMetricsChanged({
    required this.dayId,
    required this.exerciseId,
    required this.metrics,
  });

  @override
  List<Object?> get props => [dayId, exerciseId, metrics];
}

class ProgramBuilderAlternativeExerciseSet extends ProgramBuilderEvent {
  final String dayId;
  final String exerciseId;
  final Exercise? alternativeExercise;
  const ProgramBuilderAlternativeExerciseSet({
    required this.dayId,
    required this.exerciseId,
    this.alternativeExercise,
  });

  @override
  List<Object?> get props => [dayId, exerciseId, alternativeExercise];
}

class ProgramBuilderExerciseReordered extends ProgramBuilderEvent {
  final String dayId;
  final int oldIndex;
  final int newIndex;
  const ProgramBuilderExerciseReordered({
    required this.dayId,
    required this.oldIndex,
    required this.newIndex,
  });

  @override
  List<Object?> get props => [dayId, oldIndex, newIndex];
}

// ── Nutrition ──────────────────────────────────────────────────────────────────

class ProgramBuilderNutritionChanged extends ProgramBuilderEvent {
  final NutritionProtocol nutrition;
  const ProgramBuilderNutritionChanged(this.nutrition);

  @override
  List<Object?> get props => [nutrition];
}

class ProgramBuilderMealSlotAdded extends ProgramBuilderEvent {
  final MealSlot slot;
  const ProgramBuilderMealSlotAdded(this.slot);

  @override
  List<Object?> get props => [slot];
}

class ProgramBuilderMealSlotRemoved extends ProgramBuilderEvent {
  final String slotId;
  const ProgramBuilderMealSlotRemoved(this.slotId);

  @override
  List<Object?> get props => [slotId];
}

// ── Lifestyle ──────────────────────────────────────────────────────────────────

class ProgramBuilderLifestyleChanged extends ProgramBuilderEvent {
  final LifestyleProtocol lifestyle;
  const ProgramBuilderLifestyleChanged(this.lifestyle);

  @override
  List<Object?> get props => [lifestyle];
}

class ProgramBuilderSupplementAdded extends ProgramBuilderEvent {
  final SupplementEntry supplement;
  const ProgramBuilderSupplementAdded(this.supplement);

  @override
  List<Object?> get props => [supplement];
}

class ProgramBuilderSupplementRemoved extends ProgramBuilderEvent {
  final String supplementId;
  const ProgramBuilderSupplementRemoved(this.supplementId);

  @override
  List<Object?> get props => [supplementId];
}

class ProgramBuilderCardioAdded extends ProgramBuilderEvent {
  final CardioPrescription cardio;
  const ProgramBuilderCardioAdded(this.cardio);

  @override
  List<Object?> get props => [cardio];
}

class ProgramBuilderCardioRemoved extends ProgramBuilderEvent {
  final String cardioId;
  const ProgramBuilderCardioRemoved(this.cardioId);

  @override
  List<Object?> get props => [cardioId];
}

// ── Progression Rules ──────────────────────────────────────────────────────────

class ProgramBuilderProgressionRuleAdded extends ProgramBuilderEvent {
  final ProgressionRule rule;
  const ProgramBuilderProgressionRuleAdded(this.rule);

  @override
  List<Object?> get props => [rule];
}

class ProgramBuilderProgressionRuleRemoved extends ProgramBuilderEvent {
  final String ruleId;
  const ProgramBuilderProgressionRuleRemoved(this.ruleId);

  @override
  List<Object?> get props => [ruleId];
}

// ── Admin ──────────────────────────────────────────────────────────────────────

class ProgramBuilderSaveRequested extends ProgramBuilderEvent {
  const ProgramBuilderSaveRequested();
}

class ProgramBuilderPublishToggled extends ProgramBuilderEvent {
  const ProgramBuilderPublishToggled();
}

class ProgramBuilderResetRequested extends ProgramBuilderEvent {
  const ProgramBuilderResetRequested();
}

class ProgramBuilderImported extends ProgramBuilderEvent {
  final TrainingProgram program;
  const ProgramBuilderImported(this.program);

  @override
  List<Object?> get props => [program];
}

// ===========================================================================
// STATE
// ===========================================================================

enum ProgramBuilderSaveStatus { idle, saving, saved, error }

class ProgramBuilderState extends Equatable {
  final ClientBaseline baseline;
  final TrainingProgram program;
  final int activeSection; // 0–7 matching blueprint sections
  final ProgramBuilderSaveStatus saveStatus;
  final String errorMessage;

  const ProgramBuilderState({
    required this.baseline,
    required this.program,
    this.activeSection = 0,
    this.saveStatus = ProgramBuilderSaveStatus.idle,
    this.errorMessage = '',
  });

  factory ProgramBuilderState.initial() {
    return ProgramBuilderState(
      baseline: ClientBaseline.empty(),
      program: TrainingProgram.empty(),
    );
  }

  // ── Analytics: Weekly Set Volume per Muscle Group ─────────────────────────

  /// Tallies working sets per body part across all workout days.
  /// Warm-up sets are excluded.
  Map<String, int> get weeklySetVolumePerMuscleGroup {
    final result = <String, int>{};
    for (final day in program.workoutDays) {
      for (final entry in day.setsPerBodyPart.entries) {
        result[entry.key] = (result[entry.key] ?? 0) + entry.value;
      }
    }
    return result;
  }

  /// Sorted descending by set count for easy display.
  List<MapEntry<String, int>> get sortedMuscleVolume {
    final entries = weeklySetVolumePerMuscleGroup.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  /// Total weekly sets across all muscle groups (working sets only)
  int get totalWeeklySets =>
      weeklySetVolumePerMuscleGroup.values.fold(0, (sum, v) => sum + v);

  /// Total weekly exercise count
  int get totalWeeklyExercises =>
      program.workoutDays.fold(0, (sum, d) => sum + d.exercises.length);

  // ── Analytics: Macro Distribution ─────────────────────────────────────────

  MacroTarget get macroTargets => program.nutritionProtocol.baseTargets;

  /// Protein as % of total calories (1g protein = 4 kcal)
  double get proteinCaloriePercent {
    final cals = macroTargets.calories;
    if (cals <= 0) return 0;
    return (macroTargets.proteinG * 4) / cals * 100;
  }

  /// Carbs as % of total calories (1g carbs = 4 kcal)
  double get carbCaloriePercent {
    final cals = macroTargets.calories;
    if (cals <= 0) return 0;
    return (macroTargets.carbsG * 4) / cals * 100;
  }

  /// Fats as % of total calories (1g fat = 9 kcal)
  double get fatCaloriePercent {
    final cals = macroTargets.calories;
    if (cals <= 0) return 0;
    return (macroTargets.fatsG * 9) / cals * 100;
  }

  // ── Metabolic Shortcuts ───────────────────────────────────────────────────

  double get bmr => baseline.bmr;
  double get tdee => baseline.tdee;
  double get lbm => baseline.leanBodyMassKg;
  double get bmi => baseline.bmi;

  // ── Completion Heuristic ──────────────────────────────────────────────────

  /// 0.0–1.0 overall form completion estimate
  double get completionScore {
    var score = 0.0;
    if (program.name.isNotEmpty) score += 0.15;
    if (program.goals.isNotEmpty) score += 0.10;
    if (baseline.weightKg > 0 && baseline.heightCm > 0) score += 0.15;
    if (program.workoutDays.isNotEmpty) score += 0.20;
    if (program.workoutDays.any((d) => d.exercises.isNotEmpty)) score += 0.15;
    if (macroTargets.calories > 0) score += 0.15;
    if (program.lifestyleProtocol.supplements.isNotEmpty) score += 0.05;
    if (program.progressionRules.isNotEmpty) score += 0.05;
    return score.clamp(0.0, 1.0);
  }

  ProgramBuilderState copyWith({
    ClientBaseline? baseline,
    TrainingProgram? program,
    int? activeSection,
    ProgramBuilderSaveStatus? saveStatus,
    String? errorMessage,
  }) {
    return ProgramBuilderState(
      baseline: baseline ?? this.baseline,
      program: program ?? this.program,
      activeSection: activeSection ?? this.activeSection,
      saveStatus: saveStatus ?? this.saveStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [baseline, program, activeSection, saveStatus, errorMessage];
}

// ===========================================================================
// BLOC
// ===========================================================================

class ProgramBuilderBloc
    extends Bloc<ProgramBuilderEvent, ProgramBuilderState> {
  ProgramBuilderBloc(
      {TrainingProgram? initialProgram, ClientBaseline? initialBaseline})
      : super(
          initialProgram != null
              ? ProgramBuilderState(
                  baseline: initialBaseline ?? ClientBaseline.empty(),
                  program: initialProgram,
                )
              : ProgramBuilderState.initial(),
        ) {
    // Baseline
    on<ProgramBuilderBaselineUpdated>(_onBaselineUpdated);
    on<ProgramBuilderBiometricsChanged>(_onBiometricsChanged);
    on<ProgramBuilderMedicalLimitationAdded>(_onLimitationAdded);
    on<ProgramBuilderMedicalLimitationRemoved>(_onLimitationRemoved);

    // Meta
    on<ProgramBuilderMetaChanged>(_onMetaChanged);

    // Days
    on<ProgramBuilderDayAdded>(_onDayAdded);
    on<ProgramBuilderDayRenamed>(_onDayRenamed);
    on<ProgramBuilderDayRemoved>(_onDayRemoved);
    on<ProgramBuilderDayCloned>(_onDayCloned);
    on<ProgramBuilderDayNotesChanged>(_onDayNotesChanged);

    // Exercises
    on<ProgramBuilderExerciseAdded>(_onExerciseAdded);
    on<ProgramBuilderExerciseRemoved>(_onExerciseRemoved);
    on<ProgramBuilderExerciseMetricsChanged>(_onMetricsChanged);
    on<ProgramBuilderAlternativeExerciseSet>(_onAlternativeSet);
    on<ProgramBuilderExerciseReordered>(_onExerciseReordered);

    // Nutrition
    on<ProgramBuilderNutritionChanged>(_onNutritionChanged);
    on<ProgramBuilderMealSlotAdded>(_onMealSlotAdded);
    on<ProgramBuilderMealSlotRemoved>(_onMealSlotRemoved);

    // Lifestyle
    on<ProgramBuilderLifestyleChanged>(_onLifestyleChanged);
    on<ProgramBuilderSupplementAdded>(_onSupplementAdded);
    on<ProgramBuilderSupplementRemoved>(_onSupplementRemoved);
    on<ProgramBuilderCardioAdded>(_onCardioAdded);
    on<ProgramBuilderCardioRemoved>(_onCardioRemoved);

    // Progression
    on<ProgramBuilderProgressionRuleAdded>(_onRuleAdded);
    on<ProgramBuilderProgressionRuleRemoved>(_onRuleRemoved);

    // Admin
    on<ProgramBuilderSaveRequested>(_onSaveRequested);
    on<ProgramBuilderPublishToggled>(_onPublishToggled);
    on<ProgramBuilderResetRequested>(_onReset);
    on<ProgramBuilderImported>(_onImported);
  }

  // ── Baseline handlers ─────────────────────────────────────────────────────

  void _onBaselineUpdated(
      ProgramBuilderBaselineUpdated e, Emitter<ProgramBuilderState> emit) {
    emit(state.copyWith(baseline: e.baseline));
  }

  void _onBiometricsChanged(
      ProgramBuilderBiometricsChanged e, Emitter<ProgramBuilderState> emit) {
    emit(state.copyWith(
      baseline: state.baseline.copyWith(
        ageYears: e.ageYears,
        heightCm: e.heightCm,
        weightKg: e.weightKg,
        bodyFatPercent: e.bodyFatPercent,
        sex: e.sex,
        activityLevel: e.activityLevel,
      ),
    ));
  }

  void _onLimitationAdded(ProgramBuilderMedicalLimitationAdded e,
      Emitter<ProgramBuilderState> emit) {
    emit(state.copyWith(
      baseline: state.baseline.copyWith(
        medicalLimitations: [
          ...state.baseline.medicalLimitations,
          e.limitation
        ],
      ),
    ));
  }

  void _onLimitationRemoved(ProgramBuilderMedicalLimitationRemoved e,
      Emitter<ProgramBuilderState> emit) {
    emit(state.copyWith(
      baseline: state.baseline.copyWith(
        medicalLimitations: state.baseline.medicalLimitations
            .where((l) => l.id != e.limitationId)
            .toList(),
      ),
    ));
  }

  // ── Meta handlers ─────────────────────────────────────────────────────────

  void _onMetaChanged(
      ProgramBuilderMetaChanged e, Emitter<ProgramBuilderState> emit) {
    emit(state.copyWith(
      program: state.program.copyWith(
        name: e.name,
        description: e.description,
        color: e.color,
        cycleType: e.cycleType,
        duration: e.duration,
        phaseObjective: e.phaseObjective,
        goals: e.goals,
        startDate: e.startDate ?? _notSetDt,
        endDate: e.endDate ?? _notSetDt,
        status: e.status,
        isTemplate: e.isTemplate,
        updatedAt: DateTime.now(),
      ),
    ));
  }

  // ── Day handlers ──────────────────────────────────────────────────────────

  void _onDayAdded(
      ProgramBuilderDayAdded e, Emitter<ProgramBuilderState> emit) {
    final nextNumber = state.program.workoutDays.length + 1;
    final day = AdvancedWorkoutDay(
      id: 'day_${DateTime.now().microsecondsSinceEpoch}',
      name: 'Day $nextNumber',
    );
    emit(state.copyWith(
      program: state.program.copyWith(
        workoutDays: [...state.program.workoutDays, day],
        updatedAt: DateTime.now(),
      ),
    ));
  }

  void _onDayRenamed(
      ProgramBuilderDayRenamed e, Emitter<ProgramBuilderState> emit) {
    emit(state.copyWith(
      program: state.program.copyWith(
        workoutDays: state.program.workoutDays
            .map((d) => d.id == e.dayId ? d.copyWith(name: e.name) : d)
            .toList(),
        updatedAt: DateTime.now(),
      ),
    ));
  }

  void _onDayRemoved(
      ProgramBuilderDayRemoved e, Emitter<ProgramBuilderState> emit) {
    emit(state.copyWith(
      program: state.program.copyWith(
        workoutDays:
            state.program.workoutDays.where((d) => d.id != e.dayId).toList(),
        updatedAt: DateTime.now(),
      ),
    ));
  }

  void _onDayCloned(
      ProgramBuilderDayCloned e, Emitter<ProgramBuilderState> emit) {
    final idx = state.program.workoutDays.indexWhere((d) => d.id == e.dayId);
    if (idx < 0) return;
    final original = state.program.workoutDays[idx];
    final ts = DateTime.now().microsecondsSinceEpoch;
    final clone = original.copyWith(
      id: 'day_${ts}',
      name: '${original.name} Copy',
      exercises: original.exercises
          .map((ex) => ex.copyWith(
                id: 'ex_${ts}_${ex.id}',
                order: ex.order,
              ))
          .toList(),
    );
    final updated = [...state.program.workoutDays]..insert(idx + 1, clone);
    emit(state.copyWith(
      program: state.program
          .copyWith(workoutDays: updated, updatedAt: DateTime.now()),
    ));
  }

  void _onDayNotesChanged(
      ProgramBuilderDayNotesChanged e, Emitter<ProgramBuilderState> emit) {
    emit(state.copyWith(
      program: state.program.copyWith(
        workoutDays: state.program.workoutDays
            .map((d) => d.id == e.dayId ? d.copyWith(sessionNotes: e.notes) : d)
            .toList(),
        updatedAt: DateTime.now(),
      ),
    ));
  }

  // ── Exercise handlers ─────────────────────────────────────────────────────

  void _onExerciseAdded(
      ProgramBuilderExerciseAdded e, Emitter<ProgramBuilderState> emit) {
    final prescription = AdvancedPrescribedExercise(
      id: 'ex_${DateTime.now().microsecondsSinceEpoch}',
      exercise: e.exercise,
      order: _exerciseCountForDay(e.dayId),
    );
    emit(state.copyWith(
      program: state.program.copyWith(
        workoutDays: _mapDays(
          e.dayId,
          (d) => d.copyWith(exercises: [...d.exercises, prescription]),
        ),
        updatedAt: DateTime.now(),
      ),
    ));
  }

  void _onExerciseRemoved(
      ProgramBuilderExerciseRemoved e, Emitter<ProgramBuilderState> emit) {
    emit(state.copyWith(
      program: state.program.copyWith(
        workoutDays: _mapDays(
          e.dayId,
          (d) => d.copyWith(
              exercises:
                  d.exercises.where((ex) => ex.id != e.exerciseId).toList()),
        ),
        updatedAt: DateTime.now(),
      ),
    ));
  }

  void _onMetricsChanged(ProgramBuilderExerciseMetricsChanged e,
      Emitter<ProgramBuilderState> emit) {
    emit(state.copyWith(
      program: state.program.copyWith(
        workoutDays: _mapDays(
          e.dayId,
          (d) => d.copyWith(
            exercises: d.exercises
                .map((ex) => ex.id == e.exerciseId
                    ? ex.copyWith(metrics: e.metrics)
                    : ex)
                .toList(),
          ),
        ),
        updatedAt: DateTime.now(),
      ),
    ));
  }

  void _onAlternativeSet(ProgramBuilderAlternativeExerciseSet e,
      Emitter<ProgramBuilderState> emit) {
    emit(state.copyWith(
      program: state.program.copyWith(
        workoutDays: _mapDays(
          e.dayId,
          (d) => d.copyWith(
            exercises: d.exercises
                .map((ex) => ex.id == e.exerciseId
                    ? ex.copyWith(alternativeExercise: e.alternativeExercise)
                    : ex)
                .toList(),
          ),
        ),
        updatedAt: DateTime.now(),
      ),
    ));
  }

  void _onExerciseReordered(
      ProgramBuilderExerciseReordered e, Emitter<ProgramBuilderState> emit) {
    emit(state.copyWith(
      program: state.program.copyWith(
        workoutDays: _mapDays(e.dayId, (d) {
          final list = List<AdvancedPrescribedExercise>.from(d.exercises);
          if (e.oldIndex < 0 || e.oldIndex >= list.length) return d;
          if (e.newIndex < 0 || e.newIndex >= list.length) return d;
          final item = list.removeAt(e.oldIndex);
          list.insert(e.newIndex, item);
          final reordered = list.asMap().entries.map((entry) {
            return entry.value.copyWith(order: entry.key);
          }).toList();
          return d.copyWith(exercises: reordered);
        }),
        updatedAt: DateTime.now(),
      ),
    ));
  }

  // ── Nutrition handlers ────────────────────────────────────────────────────

  void _onNutritionChanged(
      ProgramBuilderNutritionChanged e, Emitter<ProgramBuilderState> emit) {
    emit(state.copyWith(
      program: state.program.copyWith(
        nutritionProtocol: e.nutrition,
        updatedAt: DateTime.now(),
      ),
    ));
  }

  void _onMealSlotAdded(
      ProgramBuilderMealSlotAdded e, Emitter<ProgramBuilderState> emit) {
    final updated = state.program.nutritionProtocol.copyWith(
      mealSlots: [...state.program.nutritionProtocol.mealSlots, e.slot],
    );
    emit(state.copyWith(
      program: state.program
          .copyWith(nutritionProtocol: updated, updatedAt: DateTime.now()),
    ));
  }

  void _onMealSlotRemoved(
      ProgramBuilderMealSlotRemoved e, Emitter<ProgramBuilderState> emit) {
    final updated = state.program.nutritionProtocol.copyWith(
      mealSlots: state.program.nutritionProtocol.mealSlots
          .where((s) => s.id != e.slotId)
          .toList(),
    );
    emit(state.copyWith(
      program: state.program
          .copyWith(nutritionProtocol: updated, updatedAt: DateTime.now()),
    ));
  }

  // ── Lifestyle handlers ────────────────────────────────────────────────────

  void _onLifestyleChanged(
      ProgramBuilderLifestyleChanged e, Emitter<ProgramBuilderState> emit) {
    emit(state.copyWith(
      program: state.program.copyWith(
        lifestyleProtocol: e.lifestyle,
        updatedAt: DateTime.now(),
      ),
    ));
  }

  void _onSupplementAdded(
      ProgramBuilderSupplementAdded e, Emitter<ProgramBuilderState> emit) {
    final updated = state.program.lifestyleProtocol.copyWith(
      supplements: [
        ...state.program.lifestyleProtocol.supplements,
        e.supplement
      ],
    );
    emit(state.copyWith(
      program: state.program
          .copyWith(lifestyleProtocol: updated, updatedAt: DateTime.now()),
    ));
  }

  void _onSupplementRemoved(
      ProgramBuilderSupplementRemoved e, Emitter<ProgramBuilderState> emit) {
    final updated = state.program.lifestyleProtocol.copyWith(
      supplements: state.program.lifestyleProtocol.supplements
          .where((s) => s.id != e.supplementId)
          .toList(),
    );
    emit(state.copyWith(
      program: state.program
          .copyWith(lifestyleProtocol: updated, updatedAt: DateTime.now()),
    ));
  }

  void _onCardioAdded(
      ProgramBuilderCardioAdded e, Emitter<ProgramBuilderState> emit) {
    final updated = state.program.lifestyleProtocol.copyWith(
      cardioPrescriptions: [
        ...state.program.lifestyleProtocol.cardioPrescriptions,
        e.cardio
      ],
    );
    emit(state.copyWith(
      program: state.program
          .copyWith(lifestyleProtocol: updated, updatedAt: DateTime.now()),
    ));
  }

  void _onCardioRemoved(
      ProgramBuilderCardioRemoved e, Emitter<ProgramBuilderState> emit) {
    final updated = state.program.lifestyleProtocol.copyWith(
      cardioPrescriptions: state.program.lifestyleProtocol.cardioPrescriptions
          .where((c) => c.id != e.cardioId)
          .toList(),
    );
    emit(state.copyWith(
      program: state.program
          .copyWith(lifestyleProtocol: updated, updatedAt: DateTime.now()),
    ));
  }

  // ── Progression handlers ──────────────────────────────────────────────────

  void _onRuleAdded(
      ProgramBuilderProgressionRuleAdded e, Emitter<ProgramBuilderState> emit) {
    emit(state.copyWith(
      program: state.program.copyWith(
        progressionRules: [...state.program.progressionRules, e.rule],
        updatedAt: DateTime.now(),
      ),
    ));
  }

  void _onRuleRemoved(ProgramBuilderProgressionRuleRemoved e,
      Emitter<ProgramBuilderState> emit) {
    emit(state.copyWith(
      program: state.program.copyWith(
        progressionRules: state.program.progressionRules
            .where((r) => r.id != e.ruleId)
            .toList(),
        updatedAt: DateTime.now(),
      ),
    ));
  }

  // ── Admin handlers ────────────────────────────────────────────────────────

  Future<void> _onSaveRequested(
    ProgramBuilderSaveRequested e,
    Emitter<ProgramBuilderState> emit,
  ) async {
    emit(state.copyWith(saveStatus: ProgramBuilderSaveStatus.saving));
    // Temporary local save delay until repository persistence is connected.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    emit(state.copyWith(
      saveStatus: ProgramBuilderSaveStatus.saved,
      program: state.program.copyWith(updatedAt: DateTime.now()),
    ));
  }

  void _onPublishToggled(
      ProgramBuilderPublishToggled e, Emitter<ProgramBuilderState> emit) {
    final current = state.program.status;
    final next = current == ProgramStatus.published
        ? ProgramStatus.draft
        : ProgramStatus.published;
    emit(state.copyWith(
      program: state.program.copyWith(status: next, updatedAt: DateTime.now()),
    ));
  }

  void _onReset(
      ProgramBuilderResetRequested e, Emitter<ProgramBuilderState> emit) {
    emit(ProgramBuilderState.initial());
  }

  void _onImported(
      ProgramBuilderImported e, Emitter<ProgramBuilderState> emit) {
    emit(state.copyWith(program: e.program));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<AdvancedWorkoutDay> _mapDays(
    String dayId,
    AdvancedWorkoutDay Function(AdvancedWorkoutDay) transform,
  ) {
    return state.program.workoutDays
        .map((d) => d.id == dayId ? transform(d) : d)
        .toList(growable: false);
  }

  int _exerciseCountForDay(String dayId) {
    final day =
        state.program.workoutDays.where((d) => d.id == dayId).firstOrNull;
    return day?.exercises.length ?? 0;
  }
}

/// Sentinel value for optional DateTime fields in copyWith.
final DateTime _notSetDt = DateTime.fromMillisecondsSinceEpoch(0);
