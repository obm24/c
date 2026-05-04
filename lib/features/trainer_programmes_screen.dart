import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/b_programmes.dart';
import '../core/c_constants.dart';
import '../core/c_ui_theme.dart';
import '../core/c_core_utils.dart';
import '../core/animations/anim_motion.dart';
import '../core/c_visual_effects.dart';
import '../models/m_programmes.dart';

// ---------------------------------------------------------------------------
// Root screen
// ---------------------------------------------------------------------------
class ProgrammesScreen extends StatelessWidget {
  const ProgrammesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProgrammesBloc(),
      child: const _ProgrammesBody(),
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------
class _ProgrammesBody extends StatefulWidget {
  const _ProgrammesBody();

  @override
  State<_ProgrammesBody> createState() => _ProgrammesBodyState();
}

class _ProgrammesBodyState extends State<_ProgrammesBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _filterOpen = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context
            .read<ProgrammesBloc>()
            .add(ProgrammesTabChanged(_tabController.index));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: _buildAppBar(context),
      body: BlocBuilder<ProgrammesBloc, ProgrammesState>(
        builder: (context, state) {
          return Column(
            children: [
              // Filter & Sort panel
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: _filterOpen
                    ? _FilterSortPanel(
                        filter: state.filter,
                        onChanged: (f) => context
                            .read<ProgrammesBloc>()
                            .add(ProgrammesFilterChanged(f)),
                        onClose: () => setState(() => _filterOpen = false),
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _ProgrammesList(
                      programmes: state.filteredTrainingProgrammes,
                      allProgrammes: state.trainingProgrammes,
                      emptyIcon: Icons.fitness_center_rounded,
                      emptyTitle: context.l10n.noProgrammesTraining,
                      emptyMessage:
                          'Create your first training programme to get started.',
                      type: ProgrammeType.training,
                      isFiltered: state.filter.isActive,
                    ),
                    _ProgrammesList(
                      programmes: state.filteredDietProgrammes,
                      allProgrammes: state.dietProgrammes,
                      emptyIcon: Icons.restaurant_rounded,
                      emptyTitle: context.l10n.noProgrammesDiet,
                      emptyMessage:
                          'Create your first diet programme to get started.',
                      type: ProgrammeType.diet,
                      isFiltered: state.filter.isActive,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppTheme.bg,
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      title: Text(
        context.l10n.programmes,
        style: const TextStyle(
          color: AppTheme.brand,
          fontWeight: FontWeight.bold,
          fontSize: AppConstants.kDefaultTitleFontSize,
        ),
      ),
      actions: [
        BlocBuilder<ProgrammesBloc, ProgrammesState>(
          builder: (context, state) {
            final active = state.filter.isActive;
            return TnTPressable(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _filterOpen = !_filterOpen);
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: active
                      ? AppTheme.brand.withValues(alpha: 0.15)
                      : AppTheme.surfaceRaised,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: active
                        ? AppTheme.brand.withValues(alpha: 0.5)
                        : AppTheme.outlineSoft,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 14,
                      color: active ? AppTheme.brand : AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      active ? 'Filtered' : 'Filter',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: active ? AppTheme.brand : AppTheme.textSecondary,
                      ),
                    ),
                    if (active) ...[
                      const SizedBox(width: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.brand,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.brand,
          labelColor: AppTheme.brand,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: [
            Tab(text: context.l10n.trainingProgrammes),
            Tab(text: context.l10n.dietProgrammes),
          ],
        ),
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: AppTheme.brand,
      elevation: 0,
      icon: const Icon(Icons.add_rounded, color: AppTheme.bg, size: 22),
      label: Text(
        context.l10n.newProgramme,
        style: const TextStyle(color: AppTheme.bg, fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        HapticFeedback.selectionClick();
        _openBuilder(context);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Filter & Sort Panel
// ---------------------------------------------------------------------------
class _FilterSortPanel extends StatefulWidget {
  final ProgrammesFilter filter;
  final ValueChanged<ProgrammesFilter> onChanged;
  final VoidCallback onClose;

  const _FilterSortPanel({
    required this.filter,
    required this.onChanged,
    required this.onClose,
  });

  @override
  State<_FilterSortPanel> createState() => _FilterSortPanelState();
}

class _FilterSortPanelState extends State<_FilterSortPanel> {
  late ProgrammesFilter _f;

  @override
  void initState() {
    super.initState();
    _f = widget.filter;
  }

  void _update(ProgrammesFilter f) {
    setState(() => _f = f);
    widget.onChanged(f);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
        border: Border.all(color: AppTheme.outlineSoft),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: AppTheme.brand, size: 15),
              const SizedBox(width: 6),
              const Text(
                'Filter & Sort',
                style: TextStyle(
                  color: AppTheme.brand,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              if (_f.isActive)
                TnTPressable(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _update(const ProgrammesFilter());
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppTheme.error.withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      'Clear all',
                      style: TextStyle(
                        color: AppTheme.error,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 6),
              TnTPressable(
                onTap: widget.onClose,
                borderRadius: BorderRadius.circular(6),
                child: const Icon(Icons.close_rounded,
                    color: AppTheme.textSecondary, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Sort By
          _SectionLabel('Sort by'),
          const SizedBox(height: 6),
          _ChipRow(
            options: ProgrammeSortBy.values.map((s) => s.label).toList(),
            selected: _f.sortBy.label,
            onSelect: (val) {
              final s =
                  ProgrammeSortBy.values.firstWhere((e) => e.label == val);
              _update(_f.copyWith(sortBy: s));
            },
          ),
          const SizedBox(height: 10),

          // Sort direction
          Row(
            children: [
              _SortDirBtn(
                label: 'Asc',
                icon: Icons.arrow_upward_rounded,
                selected: _f.ascending,
                onTap: () => _update(_f.copyWith(ascending: true)),
              ),
              const SizedBox(width: 6),
              _SortDirBtn(
                label: 'Desc',
                icon: Icons.arrow_downward_rounded,
                selected: !_f.ascending,
                onTap: () => _update(_f.copyWith(ascending: false)),
              ),
            ],
          ),

          const _Divider(),

          // Status
          _SectionLabel('Status'),
          const SizedBox(height: 6),
          _ChipRow(
            options: const ['All', 'Active', 'Inactive', 'Pinned'],
            selected: _f.statusFilter,
            onSelect: (val) => _update(_f.copyWith(statusFilter: val)),
          ),

          const _Divider(),

          // Cycle type (training only)
          _SectionLabel('Cycle type'),
          const SizedBox(height: 6),
          _ChipRow(
            options: const ['All', 'Microcycle', 'Mesocycle', 'Macrocycle'],
            selected: _f.cycleFilter,
            onSelect: (val) => _update(_f.copyWith(cycleFilter: val)),
          ),

          const _Divider(),

          // Duration range
          _SectionLabel('Max duration'),
          const SizedBox(height: 6),
          _StepperRow(
            label: _f.maxDuration == null
                ? 'Any'
                : '${_f.maxDuration} ${_f.maxDuration == 1 ? 'unit' : 'units'}',
            onDecrement: _f.maxDuration == null || _f.maxDuration! <= 1
                ? null
                : () => _update(_f.copyWith(maxDuration: _f.maxDuration! - 1)),
            onIncrement: () => _update(
              _f.copyWith(maxDuration: (_f.maxDuration ?? 0) + 1),
            ),
            onClear: _f.maxDuration == null
                ? null
                : () => _update(_f.copyWith(clearMaxDuration: true)),
          ),

          const _Divider(),

          // Goal tags
          _SectionLabel('Goal'),
          const SizedBox(height: 6),
          _ChipRow(
            options: const [
              'All',
              'Muscle Gain',
              'Strength',
              'Fat Loss',
              'Conditioning',
              'General Fitness',
              'Bulking',
              'Cutting',
              'Maintenance',
            ],
            selected: _f.goalFilter,
            onSelect: (val) => _update(_f.copyWith(goalFilter: val)),
            wrap: true,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Divider(color: AppTheme.divider, height: 1),
    );
  }
}

class _ChipRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;
  final bool wrap;

  const _ChipRow({
    required this.options,
    required this.selected,
    required this.onSelect,
    this.wrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final chips = options.map((o) {
      final sel = selected == o;
      return TnTPressable(
        onTap: () {
          HapticFeedback.selectionClick();
          onSelect(o);
        },
        pressedScale: 0.95,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color:
                sel ? AppTheme.brand : AppTheme.brand.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color:
                  sel ? AppTheme.brand : AppTheme.brand.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            o,
            style: TextStyle(
              color: sel ? AppTheme.bg : AppTheme.brand,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }).toList();

    if (wrap) {
      return Wrap(spacing: 6, runSpacing: 6, children: chips);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.expand((c) => [c, const SizedBox(width: 6)]).toList()
          ..removeLast(),
      ),
    );
  }
}

class _SortDirBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SortDirBtn({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TnTPressable(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      pressedScale: 0.95,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.brand.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? AppTheme.brand.withValues(alpha: 0.4)
                : AppTheme.outlineSoft,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 11,
                color: selected ? AppTheme.brand : AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: selected ? AppTheme.brand : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  final String label;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback? onClear;

  const _StepperRow({
    required this.label,
    required this.onDecrement,
    required this.onIncrement,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepBtn(
          icon: Icons.remove_rounded,
          enabled: onDecrement != null,
          onTap: onDecrement ?? () {},
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.outlineSoft),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _StepBtn(icon: Icons.add_rounded, enabled: true, onTap: onIncrement),
        if (onClear != null) ...[
          const SizedBox(width: 6),
          TnTPressable(
            onTap: onClear,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.close_rounded,
                  size: 12, color: AppTheme.error),
            ),
          ),
        ],
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepBtn(
      {required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TnTPressable(
      onTap: enabled
          ? () {
              HapticFeedback.selectionClick();
              onTap();
            }
          : null,
      enabled: enabled,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: enabled
              ? AppTheme.surfaceRaised
              : AppTheme.surfaceLow.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled ? AppTheme.outlineSoft : Colors.transparent,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? AppTheme.textPrimary : AppTheme.textSecondary,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// List wrapper
// ---------------------------------------------------------------------------
class _ProgrammesList extends StatelessWidget {
  final List<Programme> programmes;
  final List<Programme> allProgrammes;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;
  final ProgrammeType type;
  final bool isFiltered;

  const _ProgrammesList({
    required this.programmes,
    required this.allProgrammes,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.type,
    required this.isFiltered,
  });

  @override
  Widget build(BuildContext context) {
    if (allProgrammes.isEmpty) {
      return _EmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        message: emptyMessage,
        type: type,
      );
    }

    if (programmes.isEmpty && isFiltered) {
      return _EmptyState(
        icon: Icons.filter_list_off_rounded,
        title: 'No matches',
        message: 'No programmes match the current filters.',
        type: type,
        showCreate: false,
      );
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _SummaryBanner(
            allProgrammes: allProgrammes,
            shownCount: programmes.length,
            type: type,
            isFiltered: isFiltered,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return TnTAppear(
                  delay: Duration(milliseconds: 40 * index),
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: index < programmes.length - 1 ? 12 : 0,
                    ),
                    child: _ProgrammeCard(programme: programmes[index]),
                  ),
                );
              },
              childCount: programmes.length,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Summary banner
// ---------------------------------------------------------------------------
class _SummaryBanner extends StatelessWidget {
  final List<Programme> allProgrammes;
  final int shownCount;
  final ProgrammeType type;
  final bool isFiltered;

  const _SummaryBanner({
    required this.allProgrammes,
    required this.shownCount,
    required this.type,
    required this.isFiltered,
  });

  @override
  Widget build(BuildContext context) {
    final pinned = allProgrammes.where((p) => p.isPinned).length;
    final active = allProgrammes.where((p) => p.isActive).length;
    final total = allProgrammes.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
        border: Border.all(color: AppTheme.outlineSoft),
        gradient: AppTheme.surfaceGradient,
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          _StatCell(
            icon: type == ProgrammeType.training
                ? Icons.fitness_center_rounded
                : Icons.restaurant_rounded,
            value: isFiltered ? '$shownCount/$total' : '$total',
            label: 'Total',
            color: AppTheme.brand,
          ),
          _VertDivider(),
          _StatCell(
            icon: Icons.bolt_rounded,
            value: '$active',
            label: 'Active',
            color: AppTheme.cardGreen,
          ),
          _VertDivider(),
          _StatCell(
            icon: Icons.push_pin_rounded,
            value: '$pinned',
            label: 'Pinned',
            color: AppTheme.cardYellow,
          ),
          _VertDivider(),
          _StatCell(
            icon: Icons.bar_chart_rounded,
            value: type == ProgrammeType.training
                ? '${_totalDays(allProgrammes)}'
                : '${_totalGoals(allProgrammes)}',
            label: type == ProgrammeType.training ? 'Days' : 'Goals',
            color: AppTheme.cardBlue,
          ),
        ],
      ),
    );
  }

  static int _totalDays(List<Programme> p) =>
      p.fold(0, (s, x) => s + x.workoutDays.length);
  static int _totalGoals(List<Programme> p) =>
      p.fold(0, (s, x) => s + x.goals.length);
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCell(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: AppTheme.divider);
}

// ---------------------------------------------------------------------------
// Programme card
// ---------------------------------------------------------------------------
class _ProgrammeCard extends StatelessWidget {
  final Programme programme;

  const _ProgrammeCard({required this.programme});

  Color get _accentColor {
    final parsed = _parseProgrammeColor(programme.color);
    if (parsed != null) return parsed;
    if (programme.type == ProgrammeType.diet) return AppTheme.cardGreen;
    final goal = programme.targetGoal.toLowerCase();
    if (goal.contains('strength')) return AppTheme.cardBlue;
    if (goal.contains('fat') || goal.contains('cut')) {
      return AppTheme.cardYellow;
    }
    if (goal.contains('beginner') || goal.contains('general')) {
      return AppTheme.cardGreen;
    }
    return AppTheme.cardPurple;
  }

  IconData get _icon => _goalIcon(programme);

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;
    final dayCount = programme.workoutDays.length;
    final exerciseCount =
        programme.workoutDays.fold<int>(0, (t, d) => t + d.exercises.length);
    final goals = programme.goals.isEmpty
        ? [programme.targetGoal].where((g) => g.trim().isNotEmpty).toList()
        : programme.goals;

    return TnTPremiumCard(
      padding: EdgeInsets.zero,
      accentColor: accent,
      onTap: () {
        HapticFeedback.selectionClick();
        _openBuilder(context, programme: programme);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top accent bar
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: programme.isActive ? accent : AppTheme.divider,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppConstants.kDefaultBorderRadius),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IconBadge(
                  icon: _icon,
                  accent: accent,
                  isPinned: programme.isPinned,
                  isActive: programme.isActive,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              programme.name.trim().isEmpty
                                  ? context.l10n.untitledProgramme
                                  : programme.name,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Badges row
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (programme.isActive) _ActivePill(),
                          _Badge(
                            label: programme.type == ProgrammeType.training
                                ? context.l10n.training
                                : context.l10n.diet,
                            color: programme.type == ProgrammeType.training
                                ? AppTheme.cardBlue
                                : AppTheme.cardGreen,
                          ),
                          if (programme.type == ProgrammeType.training)
                            _Badge(
                              label: _cycleLabel(context, programme.cycleType),
                              color: AppTheme.cardPurple,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Goal tags — just like injuries/conditions
                      if (goals.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: goals.map((g) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                    color: accent.withValues(alpha: 0.35)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_goalIconFromString(g),
                                      size: 10, color: accent),
                                  const SizedBox(width: 4),
                                  Text(
                                    g,
                                    style: TextStyle(
                                      color: accent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
                _ProgrammePopupMenu(programme: programme),
              ],
            ),
          ),

          // Stats row — training only
          if (programme.type == ProgrammeType.training) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: _StatsRow(
                accent: accent,
                dayCount: dayCount,
                exerciseCount: exerciseCount,
                duration: programme.duration,
                cycleType: programme.cycleType,
              ),
            ),
          ],

          // Description
          if (programme.description.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Text(
                programme.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stats row
// ---------------------------------------------------------------------------
class _StatsRow extends StatelessWidget {
  final Color accent;
  final int dayCount;
  final int exerciseCount;
  final int duration;
  final ProgrammeCycleType cycleType;

  const _StatsRow({
    required this.accent,
    required this.dayCount,
    required this.exerciseCount,
    required this.duration,
    required this.cycleType,
  });

  @override
  Widget build(BuildContext context) {
    final unit = cycleType == ProgrammeCycleType.microcycle
        ? 'd'
        : cycleType == ProgrammeCycleType.mesocycle
            ? 'w'
            : 'mo';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.15)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _StatPill(
              icon: Icons.calendar_view_week_outlined,
              label: context.l10n.daysCount(dayCount),
              accent: accent,
            ),
            _StatDivider(accent: accent),
            _StatPill(
              icon: Icons.fitness_center_rounded,
              label: context.l10n.exercisesCount(exerciseCount),
              accent: accent,
            ),
            _StatDivider(accent: accent),
            _StatPill(
              icon: Icons.loop_rounded,
              label: '${_cycleLabel(context, cycleType)} · $duration$unit',
              accent: accent,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;

  const _StatPill(
      {required this.icon, required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 12, color: accent),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                  color: accent, fontSize: 11, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  final Color accent;
  const _StatDivider({required this.accent});

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        margin: const EdgeInsets.symmetric(vertical: 2),
        color: accent.withValues(alpha: 0.25),
      );
}

// ---------------------------------------------------------------------------
// Shared small widgets
// ---------------------------------------------------------------------------
class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final bool isPinned;
  final bool isActive;

  const _IconBadge(
      {required this.icon,
      required this.accent,
      required this.isPinned,
      required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: isActive
                ? Border.all(color: accent.withValues(alpha: 0.4), width: 1.5)
                : null,
            boxShadow: isActive
                ? [
                    BoxShadow(
                        color: accent.withValues(alpha: 0.22),
                        blurRadius: 8,
                        spreadRadius: 0)
                  ]
                : null,
          ),
          child: Icon(icon, color: accent, size: 24),
        ),
        if (isPinned)
          Positioned(
            top: -3,
            right: -3,
            child: Container(
              width: 17,
              height: 17,
              decoration: BoxDecoration(
                color: AppTheme.brand,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.surface, width: 1.5),
              ),
              child: const Icon(Icons.push_pin_rounded,
                  size: 9, color: AppTheme.bg),
            ),
          ),
      ],
    );
  }
}

class _ActivePill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.cardGreen.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.cardGreen.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
                color: AppTheme.cardGreen, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          const Text('Active',
              style: TextStyle(
                  color: AppTheme.cardGreen,
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Popup menu
// ---------------------------------------------------------------------------
class _ProgrammePopupMenu extends StatelessWidget {
  final Programme programme;
  const _ProgrammePopupMenu({required this.programme});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius)),
      icon: const Icon(Icons.more_vert_rounded,
          color: AppTheme.textSecondary, size: 20),
      onSelected: (v) => _handleAction(context, v),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'view',
          child: _MenuRow(
              icon: Icons.open_in_new_rounded, label: 'View Programme'),
        ),
        PopupMenuItem(
          value: 'pin',
          child: _MenuRow(
            icon: programme.isPinned
                ? Icons.push_pin_outlined
                : Icons.push_pin_rounded,
            label: programme.isPinned
                ? context.l10n.unpinProgramme
                : context.l10n.pinProgramme,
          ),
        ),
        PopupMenuItem(
          value: 'modify',
          child: _MenuRow(
              icon: Icons.edit_outlined, label: context.l10n.modifyProgramme),
        ),
        PopupMenuItem(
          value: 'duplicate',
          child:
              _MenuRow(icon: Icons.copy_rounded, label: context.l10n.duplicate),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'remove',
          child: _MenuRow(
              icon: Icons.delete_outline_rounded,
              label: context.l10n.removeProgramme,
              color: AppTheme.error),
        ),
      ],
    );
  }

  void _handleAction(BuildContext context, String action) {
    final bloc = context.read<ProgrammesBloc>();
    switch (action) {
      case 'view':
        HapticFeedback.selectionClick();
        _openBuilder(context, programme: programme);
        break;
      case 'pin':
        HapticFeedback.selectionClick();
        bloc.add(ProgrammeTogglePin(programme.id));
        AppUtils.showToast(
            context,
            programme.isPinned
                ? context.l10n.programmeUnpinned
                : context.l10n.programmePinned);
        break;
      case 'modify':
        HapticFeedback.lightImpact();
        bloc.add(ProgrammeModifyRequested(programme.id));
        _openBuilder(context, programme: programme);
        break;
      case 'duplicate':
        HapticFeedback.selectionClick();
        bloc.add(ProgrammeDuplicated(programme.id));
        AppUtils.showToast(context, context.l10n.duplicate);
        break;
      case 'remove':
        _showDeleteConfirmation(context);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    HapticFeedback.lightImpact();
    AppMotion.showPremiumDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.kDefaultBorderRadius)),
          title: Text(context.l10n.removeProgramme,
              style: const TextStyle(
                  color: AppTheme.error, fontWeight: FontWeight.bold)),
          content: Text(context.l10n.removeProgrammeWarning(programme.name),
              style:
                  const TextStyle(color: AppTheme.textPrimary, height: 1.45)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(context.l10n.cancel)),
            TextButton(
                onPressed: () {
                  context
                      .read<ProgrammesBloc>()
                      .add(ProgrammeRemoved(programme.id));
                  Navigator.pop(dialogContext);
                  AppUtils.showToast(context, context.l10n.programmeDeleted);
                },
                child: Text(context.l10n.delete,
                    style: const TextStyle(color: AppTheme.error))),
          ],
        );
      },
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MenuRow(
      {required this.icon,
      required this.label,
      this.color = AppTheme.textPrimary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: color, fontSize: 14)),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) =>
      TnTChip(label: label, color: color, compact: true);
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final ProgrammeType type;
  final bool showCreate;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.type,
    this.showCreate = true,
  });

  @override
  Widget build(BuildContext context) {
    return TnTEmptyState(
      icon: icon,
      title: title,
      message: message,
      action: showCreate
          ? TnTPressable(
              onTap: () {
                HapticFeedback.selectionClick();
                _openBuilder(context);
              },
              borderRadius:
                  BorderRadius.circular(AppConstants.kDefaultBorderRadius),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.brand,
                  borderRadius:
                      BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, color: AppTheme.bg, size: 18),
                    const SizedBox(width: 6),
                    Text(context.l10n.newProgramme,
                        style: const TextStyle(
                            color: AppTheme.bg,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Colour palette — used by the builder form
// ---------------------------------------------------------------------------

/// The 14 personalisation colours available when creating a programme.
const List<_ProgrammeColour> _programmeColours = [
  _ProgrammeColour('Red', '#E53935'),
  _ProgrammeColour('Orange', '#FB8C00'),
  _ProgrammeColour('Yellow', '#FDD835'),
  _ProgrammeColour('Green', '#43A047'),
  _ProgrammeColour('Blue', '#1E88E5'),
  _ProgrammeColour('Indigo', '#3949AB'),
  _ProgrammeColour('Violet', '#8E24AA'),
  _ProgrammeColour('Black', '#212121'),
  _ProgrammeColour('White', '#F5F5F5'),
  _ProgrammeColour('Grey', '#757575'),
  _ProgrammeColour('Brown', '#6D4C41'),
  _ProgrammeColour('Pink', '#E91E8C'),
  _ProgrammeColour('Cyan', '#00ACC1'),
  _ProgrammeColour('Magenta', '#D81B60'),
];

class _ProgrammeColour {
  final String name;
  final String hex;
  const _ProgrammeColour(this.name, this.hex);
  Color get color => _parseProgrammeColor(hex) ?? Colors.grey;
}

/// Colour picker widget — drop this into your builder form.
class ProgrammeColourPicker extends StatelessWidget {
  final String? selectedHex;
  final ValueChanged<String> onSelected;

  const ProgrammeColourPicker({
    super.key,
    required this.selectedHex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _programmeColours.map((pc) {
        final sel = selectedHex == pc.hex;
        return TnTPressable(
          onTap: () {
            HapticFeedback.selectionClick();
            onSelected(pc.hex);
          },
          pressedScale: 0.9,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: pc.color,
              shape: BoxShape.circle,
              border: sel
                  ? Border.all(color: AppTheme.brand, width: 3)
                  : Border.all(
                      color: Colors.white.withValues(alpha: 0.18), width: 1.5),
              boxShadow: sel
                  ? [
                      BoxShadow(
                          color: pc.color.withValues(alpha: 0.5), blurRadius: 8)
                    ]
                  : null,
            ),
            child: sel
                ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Stepper widget for duration in the builder form
// ---------------------------------------------------------------------------
class ProgrammeDurationStepper extends StatelessWidget {
  final int value;
  final ProgrammeCycleType cycleType;
  final ValueChanged<int> onChanged;

  const ProgrammeDurationStepper({
    super.key,
    required this.value,
    required this.cycleType,
    required this.onChanged,
  });

  int get _max {
    switch (cycleType) {
      case ProgrammeCycleType.microcycle:
        return 14;
      case ProgrammeCycleType.mesocycle:
        return 12;
      case ProgrammeCycleType.macrocycle:
        return 12;
    }
  }

  String get _unit {
    switch (cycleType) {
      case ProgrammeCycleType.microcycle:
        return value == 1 ? 'day' : 'days';
      case ProgrammeCycleType.mesocycle:
        return value == 1 ? 'week' : 'weeks';
      case ProgrammeCycleType.macrocycle:
        return value == 1 ? 'month' : 'months';
    }
  }

  @override
  Widget build(BuildContext context) {
    final canDecrement = value > 1;
    final canIncrement = value < _max;

    return Row(
      children: [
        _StepBtn(
          icon: Icons.remove_rounded,
          enabled: canDecrement,
          onTap: canDecrement ? () => onChanged(value - 1) : () {},
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.outlineSoft),
            ),
            alignment: Alignment.center,
            child: Text(
              '$value $_unit',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _StepBtn(
          icon: Icons.add_rounded,
          enabled: canIncrement,
          onTap: canIncrement ? () => onChanged(value + 1) : () {},
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
String _cycleLabel(BuildContext context, ProgrammeCycleType cycleType) {
  switch (cycleType) {
    case ProgrammeCycleType.microcycle:
      return context.l10n.microcycle;
    case ProgrammeCycleType.mesocycle:
      return context.l10n.mesocycle;
    case ProgrammeCycleType.macrocycle:
      return context.l10n.macrocycle;
  }
}

Color? _parseProgrammeColor(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  final hex = trimmed.replaceFirst('#', '');
  final normalized = hex.length == 6 ? 'FF$hex' : hex;
  final parsed = int.tryParse(normalized, radix: 16);
  if (parsed == null) return null;
  return Color(parsed);
}

/// Returns the designated icon for the programme's primary goal.
IconData _goalIcon(Programme p) {
  if (p.type == ProgrammeType.diet) return Icons.restaurant_rounded;
  return _goalIconFromString(p.goals.isNotEmpty ? p.goals.first : p.targetGoal);
}

/// Returns a designated icon per goal string.
IconData _goalIconFromString(String goal) {
  final g = goal.toLowerCase();
  if (g.contains('bodybuilding') ||
      g.contains('hypertrophy') ||
      g.contains('muscle')) {
    return Icons.sports_gymnastics_rounded;
  }
  if (g.contains('powerlifting') ||
      g.contains('strength') ||
      g.contains('power')) {
    return Icons.fitness_center_rounded;
  }
  if (g.contains('olympic') || g.contains('weightlifting')) {
    return Icons.flag_rounded;
  }
  if (g.contains('strongman')) {
    return Icons.construction_rounded;
  }
  if (g.contains('sports') || g.contains('athletic')) {
    return Icons.sports_rounded;
  }
  if (g.contains('functional')) {
    return Icons.accessible_forward_rounded;
  }
  if (g.contains('callisthenics') || g.contains('calisthenics')) {
    return Icons.self_improvement_rounded;
  }
  if (g.contains('combat') || g.contains('mma') || g.contains('martial')) {
    return Icons.sports_mma_rounded;
  }
  if (g.contains('corrective')) {
    return Icons.healing_rounded;
  }
  if (g.contains('rehabilitation') || g.contains('rehab')) {
    return Icons.medical_services_rounded;
  }
  if (g.contains('mobility') || g.contains('flexibility')) {
    return Icons.airline_seat_recline_extra_rounded;
  }
  if (g.contains('hiit') || g.contains('conditioning')) {
    return Icons.local_fire_department_rounded;
  }
  if (g.contains('endurance') || g.contains('cardio')) {
    return Icons.directions_run_rounded;
  }
  if (g.contains('yoga')) {
    return Icons.spa_rounded;
  }
  if (g.contains('pilates')) {
    return Icons.accessibility_new_rounded;
  }
  if (g.contains('prenatal') || g.contains('natal') || g.contains('senior')) {
    return Icons.favorite_rounded;
  }
  if (g.contains('youth')) {
    return Icons.child_care_rounded;
  }
  if (g.contains('fat') || g.contains('cut') || g.contains('weight loss')) {
    return Icons.local_fire_department_rounded;
  }
  if (g.contains('bulk') || g.contains('gain')) {
    return Icons.trending_up_rounded;
  }
  if (g.contains('maintenance') || g.contains('general')) {
    return Icons.balance_rounded;
  }
  return Icons.fitness_center_rounded;
}

Future<void> _openBuilder(
  BuildContext context, {
  Programme? programme,
}) async {
  final bloc = context.read<ProgrammesBloc>();
  final result = await context.push<Programme>(
    '/programmes/builder',
    extra: programme,
  );
  if (!context.mounted || result == null) return;
  bloc.add(ProgrammeUpserted(result));
}
