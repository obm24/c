import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/programme.dart';

// ===========================================================================
// FILTER MODEL
// ===========================================================================
enum ProgrammeSortBy {
  name,
  duration,
  dateAdded,
  goalCount,
  dayCount,
}

extension ProgrammeSortByExt on ProgrammeSortBy {
  String get label {
    switch (this) {
      case ProgrammeSortBy.name:
        return 'Name';
      case ProgrammeSortBy.duration:
        return 'Duration';
      case ProgrammeSortBy.dateAdded:
        return 'Date Added';
      case ProgrammeSortBy.goalCount:
        return 'Goals';
      case ProgrammeSortBy.dayCount:
        return 'Days';
    }
  }
}

class ProgrammesFilter extends Equatable {
  final ProgrammeSortBy sortBy;
  final bool ascending;
  final String statusFilter; // 'All' | 'Active' | 'Inactive' | 'Pinned'
  final String cycleFilter;  // 'All' | 'Microcycle' | 'Mesocycle' | 'Macrocycle'
  final int? maxDuration;
  final String goalFilter;   // 'All' | specific goal string

  const ProgrammesFilter({
    this.sortBy = ProgrammeSortBy.name,
    this.ascending = true,
    this.statusFilter = 'All',
    this.cycleFilter = 'All',
    this.maxDuration,
    this.goalFilter = 'All',
  });

  bool get isActive =>
      sortBy != ProgrammeSortBy.name ||
      !ascending ||
      statusFilter != 'All' ||
      cycleFilter != 'All' ||
      maxDuration != null ||
      goalFilter != 'All';

  ProgrammesFilter copyWith({
    ProgrammeSortBy? sortBy,
    bool? ascending,
    String? statusFilter,
    String? cycleFilter,
    int? maxDuration,
    bool clearMaxDuration = false,
    String? goalFilter,
  }) {
    return ProgrammesFilter(
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
      statusFilter: statusFilter ?? this.statusFilter,
      cycleFilter: cycleFilter ?? this.cycleFilter,
      maxDuration: clearMaxDuration ? null : (maxDuration ?? this.maxDuration),
      goalFilter: goalFilter ?? this.goalFilter,
    );
  }

  @override
  List<Object?> get props => [
        sortBy,
        ascending,
        statusFilter,
        cycleFilter,
        maxDuration,
        goalFilter,
      ];
}

// ===========================================================================
// EVENTS
// ===========================================================================
abstract class ProgrammesEvent extends Equatable {
  const ProgrammesEvent();

  @override
  List<Object?> get props => [];
}

class ProgrammesTabChanged extends ProgrammesEvent {
  final int tabIndex;
  const ProgrammesTabChanged(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

class ProgrammesFilterChanged extends ProgrammesEvent {
  final ProgrammesFilter filter;
  const ProgrammesFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

class ProgrammeTogglePin extends ProgrammesEvent {
  final String programmeId;
  const ProgrammeTogglePin(this.programmeId);

  @override
  List<Object?> get props => [programmeId];
}

class ProgrammeRemoved extends ProgrammesEvent {
  final String programmeId;
  const ProgrammeRemoved(this.programmeId);

  @override
  List<Object?> get props => [programmeId];
}

class ProgrammeDuplicated extends ProgrammesEvent {
  final String programmeId;
  const ProgrammeDuplicated(this.programmeId);

  @override
  List<Object?> get props => [programmeId];
}

class ProgrammeModifyRequested extends ProgrammesEvent {
  final String programmeId;
  const ProgrammeModifyRequested(this.programmeId);

  @override
  List<Object?> get props => [programmeId];
}

class ProgrammeCreateRequested extends ProgrammesEvent {
  final ProgrammeType type;
  const ProgrammeCreateRequested(this.type);

  @override
  List<Object?> get props => [type];
}

class ProgrammeUpserted extends ProgrammesEvent {
  final Programme programme;
  const ProgrammeUpserted(this.programme);

  @override
  List<Object?> get props => [programme];
}

// ===========================================================================
// STATE
// ===========================================================================
class ProgrammesState extends Equatable {
  final int activeTab;
  final List<Programme> programmes;
  final ProgrammesFilter filter;

  const ProgrammesState({
    this.activeTab = 0,
    this.programmes = const [],
    this.filter = const ProgrammesFilter(),
  });

  // ---------------------------------------------------------------------------
  // Raw typed lists (pinned-first, then alpha)
  // ---------------------------------------------------------------------------
  List<Programme> get trainingProgrammes => _sorted(
      programmes.where((p) => p.type == ProgrammeType.training).toList());

  List<Programme> get dietProgrammes => _sorted(
      programmes.where((p) => p.type == ProgrammeType.diet).toList());

  // ---------------------------------------------------------------------------
  // Filtered & sorted lists (respects the active filter)
  // ---------------------------------------------------------------------------
  List<Programme> get filteredTrainingProgrammes =>
      _applyFilter(trainingProgrammes);

  List<Programme> get filteredDietProgrammes =>
      _applyFilter(dietProgrammes);

  // ---------------------------------------------------------------------------
  // Filter application
  // ---------------------------------------------------------------------------
  List<Programme> _applyFilter(List<Programme> source) {
    var list = List<Programme>.from(source);

    // Status filter
    switch (filter.statusFilter) {
      case 'Active':
        list = list.where((p) => p.isActive).toList();
        break;
      case 'Inactive':
        list = list.where((p) => !p.isActive).toList();
        break;
      case 'Pinned':
        list = list.where((p) => p.isPinned).toList();
        break;
      default:
        break;
    }

    // Cycle type filter
    if (filter.cycleFilter != 'All') {
      final target = _cycleFromLabel(filter.cycleFilter);
      if (target != null) {
        list = list.where((p) => p.cycleType == target).toList();
      }
    }

    // Max duration filter
    if (filter.maxDuration != null) {
      list = list.where((p) => p.duration <= filter.maxDuration!).toList();
    }

    // Goal filter
    if (filter.goalFilter != 'All') {
      list = list
          .where((p) =>
              p.goals.any((g) =>
                  g.toLowerCase().contains(filter.goalFilter.toLowerCase())) ||
              p.targetGoal
                  .toLowerCase()
                  .contains(filter.goalFilter.toLowerCase()))
          .toList();
    }

    // Sort
    list.sort((a, b) {
      int cmp;
      switch (filter.sortBy) {
        case ProgrammeSortBy.name:
          cmp = a.name.compareTo(b.name);
          break;
        case ProgrammeSortBy.duration:
          cmp = a.duration.compareTo(b.duration);
          break;
        case ProgrammeSortBy.dateAdded:
          // Pinned programmes float when sorting by name only; otherwise raw
          cmp = 0;
          break;
        case ProgrammeSortBy.goalCount:
          cmp = a.goals.length.compareTo(b.goals.length);
          break;
        case ProgrammeSortBy.dayCount:
          cmp = a.workoutDays.length.compareTo(b.workoutDays.length);
          break;
      }
      return filter.ascending ? cmp : -cmp;
    });

    return list;
  }

  static ProgrammeCycleType? _cycleFromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'microcycle':
        return ProgrammeCycleType.microcycle;
      case 'mesocycle':
        return ProgrammeCycleType.mesocycle;
      case 'macrocycle':
        return ProgrammeCycleType.macrocycle;
      default:
        return null;
    }
  }

  // ---------------------------------------------------------------------------
  Programme? programmeById(String id) {
    for (final p in programmes) {
      if (p.id == id) return p;
    }
    return null;
  }

  ProgrammesState copyWith({
    int? activeTab,
    List<Programme>? programmes,
    ProgrammesFilter? filter,
  }) {
    return ProgrammesState(
      activeTab: activeTab ?? this.activeTab,
      programmes: programmes ?? this.programmes,
      filter: filter ?? this.filter,
    );
  }

  static List<Programme> _sorted(List<Programme> values) {
    values.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return a.name.compareTo(b.name);
    });
    return values;
  }

  @override
  List<Object?> get props => [activeTab, programmes, filter];
}

// ===========================================================================
// BLOC
// ===========================================================================
class ProgrammesBloc extends Bloc<ProgrammesEvent, ProgrammesState> {
  ProgrammesBloc()
      : super(const ProgrammesState(programmes: _mockProgrammes)) {
    on<ProgrammesTabChanged>(_onTabChanged);
    on<ProgrammesFilterChanged>(_onFilterChanged);
    on<ProgrammeTogglePin>(_onTogglePin);
    on<ProgrammeRemoved>(_onRemoved);
    on<ProgrammeDuplicated>(_onDuplicated);
    on<ProgrammeModifyRequested>(_onModifyRequested);
    on<ProgrammeCreateRequested>(_onCreateRequested);
    on<ProgrammeUpserted>(_onUpserted);
  }

  void _onTabChanged(ProgrammesTabChanged e, Emitter<ProgrammesState> emit) {
    emit(state.copyWith(activeTab: e.tabIndex));
  }

  void _onFilterChanged(
      ProgrammesFilterChanged e, Emitter<ProgrammesState> emit) {
    emit(state.copyWith(filter: e.filter));
  }

  void _onTogglePin(ProgrammeTogglePin e, Emitter<ProgrammesState> emit) {
    final updated = state.programmes.map((p) {
      if (p.id == e.programmeId) return p.copyWith(isPinned: !p.isPinned);
      return p;
    }).toList(growable: false);
    emit(state.copyWith(programmes: updated));
  }

  void _onRemoved(ProgrammeRemoved e, Emitter<ProgrammesState> emit) {
    final updated = state.programmes
        .where((p) => p.id != e.programmeId)
        .toList(growable: false);
    emit(state.copyWith(programmes: updated));
  }

  void _onDuplicated(ProgrammeDuplicated e, Emitter<ProgrammesState> emit) {
    final idx =
        state.programmes.indexWhere((p) => p.id == e.programmeId);
    if (idx < 0) return;
    final original = state.programmes[idx];
    final dup = original.copyWith(
      id: 'programme_${DateTime.now().microsecondsSinceEpoch}',
      name: '${original.name} Copy',
      isPinned: false,
      workoutDays: original.workoutDays
          .map((day) => day.copyWith(
                id: 'day_${DateTime.now().microsecondsSinceEpoch}_${day.id}',
                exercises: day.exercises
                    .map((ex) => ex.copyWith(
                          id:
                              'exercise_${DateTime.now().microsecondsSinceEpoch}_${ex.id}',
                        ))
                    .toList(growable: false),
              ))
          .toList(growable: false),
    );
    final updated = [...state.programmes]..insert(idx + 1, dup);
    emit(state.copyWith(programmes: updated));
  }

  void _onModifyRequested(
      ProgrammeModifyRequested e, Emitter<ProgrammesState> emit) {}

  void _onCreateRequested(
      ProgrammeCreateRequested e, Emitter<ProgrammesState> emit) {}

  void _onUpserted(ProgrammeUpserted e, Emitter<ProgrammesState> emit) {
    var replaced = false;
    final updated = state.programmes.map((p) {
      if (p.id == e.programme.id) {
        replaced = true;
        return e.programme;
      }
      return p;
    }).toList(growable: true);
    if (!replaced) updated.add(e.programme);
    emit(state.copyWith(programmes: updated));
  }
}

// ===========================================================================
// MOCK DATA
// ===========================================================================
const List<Programme> _mockProgrammes = [
  Programme(
    id: 'tp_001',
    name: 'Back & Biceps Hypertrophy',
    targetGoal: 'Muscle Gain',
    goals: ['Muscle Gain', 'Strength'],
    description: 'An 8-week hypertrophy block for upper-body pull strength.',
    color: '#7C4DFF',
    cycleType: ProgrammeCycleType.mesocycle,
    duration: 8,
    isPinned: true,
    isActive: true,
    workoutDays: [
      WorkoutDay(id: 'tp_001_day_1', name: 'Day 1', exercises: []),
      WorkoutDay(id: 'tp_001_day_2', name: 'Day 2', exercises: []),
    ],
  ),
  Programme(
    id: 'tp_002',
    name: 'Push / Pull / Legs Split',
    targetGoal: 'Strength',
    goals: ['Strength'],
    description: 'A structured 12-week split for compound lift progression.',
    color: '#2F80ED',
    cycleType: ProgrammeCycleType.macrocycle,
    duration: 12,
    workoutDays: [
      WorkoutDay(id: 'tp_002_day_1', name: 'Day 1', exercises: []),
      WorkoutDay(id: 'tp_002_day_2', name: 'Day 2', exercises: []),
      WorkoutDay(id: 'tp_002_day_3', name: 'Day 3', exercises: []),
    ],
  ),
  Programme(
    id: 'tp_003',
    name: 'Full Body Beginner',
    targetGoal: 'General Fitness',
    goals: ['General Fitness'],
    description: 'Simple full-body sessions for new trainees.',
    color: '#27AE60',
    cycleType: ProgrammeCycleType.microcycle,
    duration: 4,
    workoutDays: [
      WorkoutDay(id: 'tp_003_day_1', name: 'Day 1', exercises: []),
    ],
  ),
  Programme(
    id: 'tp_004',
    name: '8-Week Shred',
    targetGoal: 'Fat Loss',
    goals: ['Fat Loss', 'Conditioning'],
    description: 'Conditioning and resistance sessions for a cutting phase.',
    color: '#F2C94C',
    cycleType: ProgrammeCycleType.mesocycle,
    duration: 8,
    workoutDays: [
      WorkoutDay(id: 'tp_004_day_1', name: 'Day 1', exercises: []),
      WorkoutDay(id: 'tp_004_day_2', name: 'Day 2', exercises: []),
    ],
  ),
  Programme(
    id: 'dp_001',
    type: ProgrammeType.diet,
    name: 'Lean Bulking Macros',
    targetGoal: 'Bulking',
    goals: ['Bulking'],
    description: 'Macro targets and food structure for lean mass gain.',
    color: '#219653',
    isPinned: true,
    isActive: true,
  ),
  Programme(
    id: 'dp_002',
    type: ProgrammeType.diet,
    name: 'Cut Phase Protocol',
    targetGoal: 'Cutting',
    goals: ['Cutting'],
    description: 'A calorie-controlled nutrition programme for fat loss.',
    color: '#EB5757',
  ),
  Programme(
    id: 'dp_003',
    type: ProgrammeType.diet,
    name: 'Balanced Nutrition Plan',
    targetGoal: 'Maintenance',
    goals: ['Maintenance'],
    description: 'A sustainable maintenance approach for general health.',
    color: '#56CCF2',
  ),
];