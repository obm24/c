import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/b_programmes_nutrition_search.dart';
import '../core/c_ui_theme.dart';
import '../core/c_constants.dart';
import '../core/c_core_utils.dart';
import '../models/m_programmes_food_nutrition_model.dart';

// ============================================================================
// NutritionSearchScreen — entry point that provides the BLoC
// ============================================================================

class NutritionSearchScreen extends StatelessWidget {
  const NutritionSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          NutritionSearchBloc()..add(const NutritionDatabaseLoadRequested()),
      child: const _NutritionSearchBody(),
    );
  }
}

// ============================================================================
// Body — search field + results DataTable
// ============================================================================

class _NutritionSearchBody extends StatefulWidget {
  const _NutritionSearchBody();

  @override
  State<_NutritionSearchBody> createState() => _NutritionSearchBodyState();
}

class _NutritionSearchBodyState extends State<_NutritionSearchBody> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      context
          .read<NutritionSearchBloc>()
          .add(NutritionSearchQueryChanged(value));
    });
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<NutritionSearchBloc>().add(const NutritionSearchCleared());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          context.l10n.dietProgramme,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: AppConstants.kDefaultTitleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- Search Bar ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius:
                    BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08), width: 1),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: AppConstants.kDefaultSubtitleFontSize,
                ),
                decoration: InputDecoration(
                  hintText: context.l10n.searchExplore,
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary.withValues(alpha: 0.6),
                    fontSize: AppConstants.kDefaultSubtitleFontSize,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppTheme.textSecondary, size: 22),
                  suffixIcon:
                      BlocBuilder<NutritionSearchBloc, NutritionSearchState>(
                    buildWhen: (prev, curr) => prev.query != curr.query,
                    builder: (context, state) {
                      if (state.query.isEmpty) return const SizedBox.shrink();
                      return IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppTheme.textSecondary, size: 20),
                        onPressed: _clearSearch,
                      );
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // --- Content ---
          Expanded(
            child: BlocBuilder<NutritionSearchBloc, NutritionSearchState>(
              builder: (context, state) {
                // Loading database
                if (state.status == NutritionDatabaseStatus.loading ||
                    state.status == NutritionDatabaseStatus.initial) {
                  return const _LoadingIndicator();
                }
                // Error state
                if (state.status == NutritionDatabaseStatus.error) {
                  return _ErrorView(message: state.errorMessage);
                }
                // Empty query — prompt
                if (state.query.isEmpty) {
                  return const _EmptySearchPrompt();
                }
                // No results
                if (state.results.isEmpty) {
                  return _NoResultsView(query: state.query);
                }
                // Results DataTable
                return _NutritionResultsTable(results: state.results);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Loading indicator
// ============================================================================

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              color: AppTheme.brand,
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading nutrition database…',
            style: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
              fontSize: AppConstants.kDefaultSubtitleFontSize,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Empty search prompt
// ============================================================================

class _EmptySearchPrompt extends StatelessWidget {
  const _EmptySearchPrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant_menu_rounded,
              size: 64,
              color: AppTheme.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'Search for any food to view its\ncomplete nutritional breakdown.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary.withValues(alpha: 0.6),
                fontSize: AppConstants.kDefaultSubtitleFontSize,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Error view
// ============================================================================

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppTheme.error),
            const SizedBox(height: 16),
            Text(
              context.l10n.errorOccurred,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: AppConstants.kDefaultFormTitleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.textSecondary.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// No results view
// ============================================================================

class _NoResultsView extends StatelessWidget {
  final String query;
  const _NoResultsView({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 56,
              color: AppTheme.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.noResultsFound,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: AppConstants.kDefaultFormTitleFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '"$query"',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary.withValues(alpha: 0.5),
                fontSize: AppConstants.kDefaultSubtitleFontSize,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Results DataTable — horizontally scrollable with fixed food description col
// ============================================================================

class _NutritionResultsTable extends StatelessWidget {
  final List<FoodNutritionData> results;
  const _NutritionResultsTable({required this.results});

  /// Ceiling round to 1 decimal place.
  /// e.g. 3.33 → 3.4, 0.001 → 0.1
  static String _formatAmount(double amount) {
    final rounded = (amount * 10).ceilToDouble() / 10;
    return rounded.toStringAsFixed(1);
  }

  /// Build the column header widget.
  /// If the name contains parentheses, split into two lines:
  ///   Line 1: main name + [unit]  (bold)
  ///   Line 2: parenthetical text  (smaller, normal weight)
  static Widget _buildHeaderCell(NutrientColumn col) {
    final name = col.displayName;
    final unit = col.unit;

    // Check for parenthetical content
    final parenStart = name.indexOf('(');
    if (parenStart > 0) {
      final mainName = name.substring(0, parenStart).trim();
      final parenText = name.substring(parenStart); // includes the parentheses

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$mainName [$unit]',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            parenText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
              fontWeight: FontWeight.normal,
              fontSize: 10,
            ),
          ),
        ],
      );
    }

    // No parentheses — single line
    return Text(
      '$name [$unit]',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results count header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            context.l10n.showingResults(results.length.toString()),
            style: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Divider(color: AppTheme.divider, height: 1),

        // Scrollable DataTable
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 24),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    AppTheme.surface.withValues(alpha: 0.8),
                  ),
                  dataRowColor: WidgetStateProperty.resolveWith<Color>(
                    (states) {
                      if (states.contains(WidgetState.hovered)) {
                        return Colors.white.withValues(alpha: 0.03);
                      }
                      return Colors.transparent;
                    },
                  ),
                  columnSpacing: 20,
                  horizontalMargin: 16,
                  headingRowHeight: 56,
                  dataRowMinHeight: 42,
                  dataRowMaxHeight: 48,
                  border: TableBorder(
                    horizontalInside: BorderSide(
                        color: AppTheme.divider.withValues(alpha: 0.5),
                        width: 0.5),
                  ),
                  columns: [
                    // Food description — left aligned
                    const DataColumn(
                      label: Text(
                        'Food Description',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    // 32 nutrient columns — center aligned
                    ...kNutrientColumns.map((col) => DataColumn(
                          label: _buildHeaderCell(col),
                          numeric: true,
                        )),
                  ],
                  rows: results.map((food) {
                    return DataRow(
                      cells: [
                        // Food description cell — left aligned
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 280,
                              minWidth: 180,
                            ),
                            child: Text(
                              food.description,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        // 32 nutrient value cells — center aligned
                        ...kNutrientColumns.map((col) {
                          final value = col.valueExtractor(food);
                          return DataCell(
                            Center(
                              child: Text(
                                _formatAmount(value),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: value > 0
                                      ? AppTheme.textPrimary
                                      : AppTheme.textSecondary
                                          .withValues(alpha: 0.4),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
