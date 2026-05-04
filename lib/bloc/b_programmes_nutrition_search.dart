import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../core/c_nutrition_database.dart';
import '../models/m_programmes_food_nutrition_model.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

abstract class NutritionSearchEvent extends Equatable {
  const NutritionSearchEvent();
  @override
  List<Object?> get props => [];
}

/// Triggers initial loading of the JSON database.
class NutritionDatabaseLoadRequested extends NutritionSearchEvent {
  const NutritionDatabaseLoadRequested();
}

/// Fires when the user types in the search field.
class NutritionSearchQueryChanged extends NutritionSearchEvent {
  final String query;
  const NutritionSearchQueryChanged(this.query);
  @override
  List<Object?> get props => [query];
}

/// Clears the current search and results.
class NutritionSearchCleared extends NutritionSearchEvent {
  const NutritionSearchCleared();
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

enum NutritionDatabaseStatus { initial, loading, loaded, error }

class NutritionSearchState extends Equatable {
  final NutritionDatabaseStatus status;
  final String query;
  final List<FoodNutritionData> results;
  final String errorMessage;

  const NutritionSearchState({
    this.status = NutritionDatabaseStatus.initial,
    this.query = '',
    this.results = const [],
    this.errorMessage = '',
  });

  NutritionSearchState copyWith({
    NutritionDatabaseStatus? status,
    String? query,
    List<FoodNutritionData>? results,
    String? errorMessage,
  }) {
    return NutritionSearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      results: results ?? this.results,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, query, results, errorMessage];
}

// ---------------------------------------------------------------------------
// BLoC
// ---------------------------------------------------------------------------

class NutritionSearchBloc
    extends Bloc<NutritionSearchEvent, NutritionSearchState> {
  final NutritionDatabase _database;

  NutritionSearchBloc({NutritionDatabase? database})
      : _database = database ?? NutritionDatabase(),
        super(const NutritionSearchState()) {
    on<NutritionDatabaseLoadRequested>(_onLoadRequested);
    on<NutritionSearchQueryChanged>(_onQueryChanged);
    on<NutritionSearchCleared>(_onCleared);
  }

  Future<void> _onLoadRequested(
    NutritionDatabaseLoadRequested event,
    Emitter<NutritionSearchState> emit,
  ) async {
    if (_database.isLoaded) {
      emit(state.copyWith(status: NutritionDatabaseStatus.loaded));
      return;
    }
    emit(state.copyWith(status: NutritionDatabaseStatus.loading));
    try {
      await _database.load();
      emit(state.copyWith(status: NutritionDatabaseStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: NutritionDatabaseStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onQueryChanged(
    NutritionSearchQueryChanged event,
    Emitter<NutritionSearchState> emit,
  ) {
    final trimmed = event.query.trim();
    if (trimmed.isEmpty) {
      emit(state.copyWith(query: '', results: []));
      return;
    }
    final matches = _database.search(trimmed);
    emit(state.copyWith(query: trimmed, results: matches));
  }

  void _onCleared(
    NutritionSearchCleared event,
    Emitter<NutritionSearchState> emit,
  ) {
    emit(state.copyWith(query: '', results: []));
  }
}
