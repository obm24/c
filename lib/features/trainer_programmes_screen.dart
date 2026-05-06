import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/b_program_builder.dart';
import '../core/c_constants.dart';
import '../core/c_ui_theme.dart';
import '../core/c_core_utils.dart';
import '../core/c_visual_effects.dart';
import '../models/m_programmes_exercise.dart';
import '../models/m_program_builder_models.dart';

// ===========================================================================
// ROOT SCREEN & SHELL
// ===========================================================================
// ===========================================================================
// ROOT SCREEN
// ===========================================================================

class ProgramBuilderScreen extends StatelessWidget {
  final TrainingProgram? initialProgram;
  final ClientBaseline? initialBaseline;

  const ProgramBuilderScreen({
    super.key,
    this.initialProgram,
    this.initialBaseline,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProgramBuilderBloc(
        initialProgram: initialProgram,
        initialBaseline: initialBaseline,
      ),
      child: const _ProgramBuilderBody(),
    );
  }
}

// ===========================================================================
// BODY
// ===========================================================================

class _ProgramBuilderBody extends StatefulWidget {
  const _ProgramBuilderBody();

  @override
  State<_ProgramBuilderBody> createState() => _ProgramBuilderBodyState();
}

class _ProgramBuilderBodyState extends State<_ProgramBuilderBody>
    with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _sidebarController;
  late final Animation<double> _sidebarAnimation;

  bool _analyticsExpanded = true;

  // Section keys for scroll-to navigation
  final List<GlobalKey> _sectionKeys = List.generate(8, (_) => GlobalKey());

  static const _sectionTitles = [
    'Client Baseline',
    'Program Meta',
    'Training Builder',
    'Nutrition Protocol',
    'Supplementation',
    'Lifestyle & Recovery',
    'Analytics',
    'Admin & Publishing',
  ];

  static const _sectionIcons = [
    Icons.person_rounded,
    Icons.edit_note_rounded,
    Icons.fitness_center_rounded,
    Icons.restaurant_rounded,
    Icons.medication_rounded,
    Icons.bedtime_rounded,
    Icons.bar_chart_rounded,
    Icons.publish_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _sidebarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      value: 1,
    );
    _sidebarAnimation = CurvedAnimation(
      parent: _sidebarController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _sidebarController.dispose();
    super.dispose();
  }

  void _scrollToSection(int index) {
    if (index < 0 || index >= _sectionKeys.length) return;
    final ctx = _sectionKeys[index].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
    context.read<ProgramBuilderBloc>().add(
          ProgramBuilderMetaChanged(),
        );
    HapticFeedback.selectionClick();
  }

  void _toggleSidebar() {
    setState(() => _analyticsExpanded = !_analyticsExpanded);
    if (_analyticsExpanded) {
      _sidebarController.forward();
    } else {
      _sidebarController.reverse();
    }
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 860;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: _buildAppBar(context),
      body: isWide ? _buildWideLayout(context) : _buildNarrowLayout(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppTheme.bg,
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      title: BlocBuilder<ProgramBuilderBloc, ProgramBuilderState>(
        buildWhen: (prev, curr) =>
            prev.program.name != curr.program.name ||
            prev.program.status != curr.program.status,
        builder: (context, state) {
          final name = state.program.name;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isEmpty ? 'New Program' : name,
                style: TextStyle(
                  color: name.isEmpty ? AppTheme.textSecondary : AppTheme.brand,
                  fontWeight: FontWeight.bold,
                  fontSize: AppConstants.kDefaultTitleFontSize,
                ),
              ),
              _StatusChip(status: state.program.status),
            ],
          );
        },
      ),
      actions: [
        BlocBuilder<ProgramBuilderBloc, ProgramBuilderState>(
          buildWhen: (p, c) => p.completionScore != c.completionScore,
          builder: (context, state) {
            return _CompletionBadge(score: state.completionScore);
          },
        ),
        const SizedBox(width: 8),
        _PublishButton(),
        const SizedBox(width: 8),
        _SaveButton(),
        const SizedBox(width: 8),
      ],
    );
  }

  // ── Wide layout (tablet / desktop) ────────────────────────────────────────

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left nav rail
        _SectionNavRail(
          sectionTitles: _sectionTitles,
          sectionIcons: _sectionIcons,
          onTap: _scrollToSection,
        ),

        // Main content
        Expanded(
          child: _MainScrollArea(
            scrollController: _scrollController,
            sectionKeys: _sectionKeys,
            sectionTitles: _sectionTitles,
            sectionIcons: _sectionIcons,
          ),
        ),

        // Analytics sidebar
        SizeTransition(
          sizeFactor: _sidebarAnimation,
          axis: Axis.horizontal,
          child: const _AnalyticsSidebar(),
        ),

        // Sidebar toggle
        _SidebarToggle(
          expanded: _analyticsExpanded,
          onTap: _toggleSidebar,
        ),
      ],
    );
  }

  // ── Narrow layout (phone) ─────────────────────────────────────────────────

  Widget _buildNarrowLayout(BuildContext context) {
    return Stack(
      children: [
        _MainScrollArea(
          scrollController: _scrollController,
          sectionKeys: _sectionKeys,
          sectionTitles: _sectionTitles,
          sectionIcons: _sectionIcons,
          bottomPadding: 80,
        ),

        // Bottom nav
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _MobileSectionBar(
            sectionIcons: _sectionIcons,
            onTap: _scrollToSection,
          ),
        ),

        // Analytics FAB
        Positioned(
          right: 16,
          bottom: 72,
          child: _AnalyticsFab(),
        ),
      ],
    );
  }
}

// ===========================================================================
// SECTION NAV RAIL (wide)
// ===========================================================================

class _SectionNavRail extends StatefulWidget {
  final List<String> sectionTitles;
  final List<IconData> sectionIcons;
  final ValueChanged<int> onTap;

  const _SectionNavRail({
    required this.sectionTitles,
    required this.sectionIcons,
    required this.onTap,
  });

  @override
  State<_SectionNavRail> createState() => _SectionNavRailState();
}

class _SectionNavRailState extends State<_SectionNavRail> {
  int _hovered = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      color: AppTheme.surfaceLow,
      child: Column(
        children: [
          const SizedBox(height: 8),
          ...List.generate(widget.sectionTitles.length, (i) {
            return MouseRegion(
              onEnter: (_) => setState(() => _hovered = i),
              onExit: (_) => setState(() => _hovered = -1),
              child: Tooltip(
                message: widget.sectionTitles[i],
                preferBelow: false,
                child: TnTPressable(
                  onTap: () => widget.onTap(i),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _hovered == i
                          ? AppTheme.brand.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.sectionIcons[i],
                          size: 20,
                          color: _hovered == i
                              ? AppTheme.brand
                              : AppTheme.textSecondary,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: _hovered == i
                                ? AppTheme.brand
                                : AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ===========================================================================
// MOBILE SECTION BAR
// ===========================================================================

class _MobileSectionBar extends StatelessWidget {
  final List<IconData> sectionIcons;
  final ValueChanged<int> onTap;

  const _MobileSectionBar({
    required this.sectionIcons,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLow,
        border: Border(top: BorderSide(color: AppTheme.outlineSoft)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        itemCount: sectionIcons.length,
        itemBuilder: (_, i) => TnTPressable(
          onTap: () => onTap(i),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 46,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: AppTheme.surfaceRaised,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.outlineSoft),
            ),
            child:
                Icon(sectionIcons[i], size: 18, color: AppTheme.textSecondary),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// MAIN SCROLL AREA
// ===========================================================================

class _MainScrollArea extends StatelessWidget {
  final ScrollController scrollController;
  final List<GlobalKey> sectionKeys;
  final List<String> sectionTitles;
  final List<IconData> sectionIcons;
  final double bottomPadding;

  const _MainScrollArea({
    required this.scrollController,
    required this.sectionKeys,
    required this.sectionTitles,
    required this.sectionIcons,
    this.bottomPadding = 32,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        // Program header hero
        SliverToBoxAdapter(
          child: _ProgramHeroHeader(),
        ),

        // Progress strip
        SliverToBoxAdapter(
          child: _CompletionProgressStrip(),
        ),

        // All 8 sections
        ...List.generate(8, (i) {
          return SliverToBoxAdapter(
            child: _SectionCard(
              key: sectionKeys[i],
              index: i,
              title: sectionTitles[i],
              icon: sectionIcons[i],
              child: _sectionContent(i),
            ),
          );
        }),

        SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
      ],
    );
  }

  Widget _sectionContent(int index) {
    switch (index) {
      case 0:
        return const ClientBaselineSection();
      case 1:
        return const _ProgramMetaSection();
      case 2:
        return const TrainingBuilderSection();
      case 3:
        return const NutritionProtocolSection();
      case 4:
        return const SupplementationSection();
      case 5:
        return const LifestyleSection();
      case 6:
        return const AnalyticsSummarySection();
      case 7:
        return const AdminSection();
      default:
        return const SizedBox.shrink();
    }
  }
}

// ===========================================================================
// SECTION CARD WRAPPER
// ===========================================================================

class _SectionCard extends StatefulWidget {
  final int index;
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    super.key,
    required this.index,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          TnTPressable(
            onTap: () {
              setState(() => _collapsed = !_collapsed);
              HapticFeedback.selectionClick();
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.brand.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(widget.icon, size: 16, color: AppTheme.brand),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  _SectionIndexBadge(index: widget.index + 1),
                  const SizedBox(width: 10),
                  AnimatedRotation(
                    turns: _collapsed ? -0.25 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(
                      Icons.expand_less_rounded,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Divider
          if (!_collapsed)
            Divider(height: 1, thickness: 1, color: AppTheme.outlineSoft),

          // Content
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            child: _collapsed
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: widget.child,
                  ),
          ),
        ],
      ),
    );
  }
}

class _SectionIndexBadge extends StatelessWidget {
  final int index;
  const _SectionIndexBadge({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.outlineSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$index / 8',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppTheme.textTertiary,
        ),
      ),
    );
  }
}

// ===========================================================================
// PROGRAM HERO HEADER
// ===========================================================================

class _ProgramHeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgramBuilderBloc, ProgramBuilderState>(
      buildWhen: (p, c) =>
          p.program.color != c.program.color ||
          p.program.name != c.program.name ||
          p.program.phaseObjective != c.program.phaseObjective,
      builder: (context, state) {
        final color = _parseColor(state.program.color) ?? AppTheme.brand;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.18),
                color.withValues(alpha: 0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              // Color dot / icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: color.withValues(alpha: 0.4), width: 2),
                ),
                child:
                    Icon(Icons.fitness_center_rounded, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.program.name.isEmpty
                          ? 'Untitled Program'
                          : state.program.name,
                      style: TextStyle(
                        color: state.program.name.isEmpty
                            ? AppTheme.textSecondary
                            : AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      state.program.phaseObjective.label,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // TDEE quick stat
              _QuickStat(
                label: 'TDEE',
                value: '${state.tdee.round()}',
                unit: 'kcal',
                color: color,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _QuickStat({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textTertiary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// COMPLETION PROGRESS STRIP
// ===========================================================================

class _CompletionProgressStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgramBuilderBloc, ProgramBuilderState>(
      buildWhen: (p, c) => p.completionScore != c.completionScore,
      builder: (context, state) {
        final pct = state.completionScore;
        final color = pct < 0.4
            ? const Color(0xFFEB5757)
            : pct < 0.75
                ? const Color(0xFFF2C94C)
                : const Color(0xFF27AE60);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppTheme.outlineSoft,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(pct * 100).round()}% complete',
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ===========================================================================
// SECTION 0 – CLIENT BASELINE
// ===========================================================================

class _BiometricTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _BiometricTile(
      {required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 9,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                    text: value,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                if (unit.isNotEmpty)
                  TextSpan(
                      text: ' $unit',
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetabolicCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final bool highlight;

  const _MetabolicCard({
    required this.label,
    required this.value,
    required this.unit,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: highlight
            ? AppTheme.brand.withValues(alpha: 0.1)
            : AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlight
              ? AppTheme.brand.withValues(alpha: 0.35)
              : AppTheme.outlineSoft,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: highlight ? AppTheme.brand : AppTheme.textTertiary,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: highlight ? AppTheme.brand : AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (unit.isNotEmpty)
            Text(
              unit,
              style: const TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

class _LimitationChip extends StatelessWidget {
  final MedicalLimitation limitation;
  final VoidCallback onRemove;

  const _LimitationChip({required this.limitation, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEB5757).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: const Color(0xFFEB5757).withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 14, color: Color(0xFFEB5757)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(limitation.condition,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                if (limitation.affectedBodyPart.isNotEmpty)
                  Text(limitation.affectedBodyPart,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 10)),
              ],
            ),
          ),
          TnTPressable(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close_rounded,
                  size: 14, color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// SECTION 1 – PROGRAM META
// ===========================================================================

class _ProgramMetaSection extends StatelessWidget {
  const _ProgramMetaSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgramBuilderBloc, ProgramBuilderState>(
      buildWhen: (p, c) => p.program != c.program,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PlaceholderField(
                label: 'Program Title', hint: 'e.g. 12-Week Hypertrophy Block'),
            const SizedBox(height: 12),
            _PlaceholderField(
                label: 'Description',
                hint: 'Brief overview of the program...',
                minLines: 3),
            const SizedBox(height: 16),
            _SubSectionLabel('Phase Objective'),
            const SizedBox(height: 10),
            _PhaseObjectiveSelector(current: state.program.phaseObjective),
            const SizedBox(height: 16),
            _SubSectionLabel('Timeline & Periodization'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Icons.loop_rounded,
                    label: 'Cycle Type',
                    value: state.program.cycleType.name,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.timer_outlined,
                    label: 'Duration',
                    value: '${state.program.duration} wks',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Icons.calendar_today_rounded,
                    label: 'Start Date',
                    value: state.program.startDate != null
                        ? _formatDate(state.program.startDate!)
                        : 'Not set',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.event_rounded,
                    label: 'End Date',
                    value: state.program.endDate != null
                        ? _formatDate(state.program.endDate!)
                        : 'Not set',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')} / ${dt.month.toString().padLeft(2, '0')} / ${dt.year}';
}

class _PhaseObjectiveSelector extends StatelessWidget {
  final PhaseObjective current;
  const _PhaseObjectiveSelector({required this.current});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PhaseObjective.values.map((phase) {
        final selected = phase == current;
        return TnTPressable(
          onTap: () {
            HapticFeedback.selectionClick();
            context.read<ProgramBuilderBloc>().add(
                  ProgramBuilderMetaChanged(phaseObjective: phase),
                );
          },
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: selected
                  ? AppTheme.brand.withValues(alpha: 0.15)
                  : AppTheme.surfaceRaised,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected
                    ? AppTheme.brand.withValues(alpha: 0.5)
                    : AppTheme.outlineSoft,
              ),
            ),
            child: Text(
              phase.label,
              style: TextStyle(
                color: selected ? AppTheme.brand : AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ===========================================================================
// SECTION 2 – TRAINING BUILDER (shell)
// ===========================================================================

// ===========================================================================
// SECTION 2 – TRAINING BUILDER
// ===========================================================================
class TrainingBuilderSection extends StatelessWidget {
  const TrainingBuilderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgramBuilderBloc, ProgramBuilderState>(
      buildWhen: (p, c) => p.program.workoutDays != c.program.workoutDays,
      builder: (context, state) {
        final days = state.program.workoutDays;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary badges
            _TrainingStatStrip(state: state),
            const SizedBox(height: 14),

            // Days – each is an expander
            if (days.isEmpty)
              _TrainingEmptyState(
                onAddDay: () => context
                    .read<ProgramBuilderBloc>()
                    .add(const ProgramBuilderDayAdded()),
              )
            else ...[
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: days.length,
                buildDefaultDragHandles: false,
                onReorder: (oldIdx, newIdx) {
                  if (newIdx > oldIdx) newIdx--;
                  final updated = List<AdvancedWorkoutDay>.from(days);
                  final item = updated.removeAt(oldIdx);
                  updated.insert(newIdx, item);
                  context.read<ProgramBuilderBloc>().add(
                        ProgramBuilderMetaChanged(),
                      );
                  // Emit updated days via a direct programme update event
                  // (requires a ProgramBuilderWorkoutDaysReordered event;
                  //  using MetaChanged as a no-op placeholder — wire to a
                  //  dedicated event when wiring the full repository layer)
                },
                itemBuilder: (ctx, idx) {
                  final day = days[idx];
                  return _WorkoutDayExpander(
                    key: ValueKey(day.id),
                    day: day,
                    dragIndex: idx,
                  );
                },
              ),
              const SizedBox(height: 10),
            ],

            // Add day button
            _AddDayButton(
              onTap: () {
                HapticFeedback.selectionClick();
                context
                    .read<ProgramBuilderBloc>()
                    .add(const ProgramBuilderDayAdded());
              },
            ),
          ],
        );
      },
    );
  }
}

// ===========================================================================
// TRAINING STAT STRIP
// ===========================================================================

class _TrainingStatStrip extends StatelessWidget {
  final ProgramBuilderState state;
  const _TrainingStatStrip({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatPill(
            icon: Icons.calendar_view_week_rounded,
            label: '${state.program.workoutDays.length}',
            sub: 'Days',
            color: AppTheme.brand,
          ),
          const SizedBox(width: 8),
          _StatPill(
            icon: Icons.repeat_rounded,
            label: '${state.totalWeeklyExercises}',
            sub: 'Exercises',
            color: const Color(0xFF2F80ED),
          ),
          const SizedBox(width: 8),
          _StatPill(
            icon: Icons.stacked_bar_chart_rounded,
            label: '${state.totalWeeklySets}',
            sub: 'Working Sets',
            color: const Color(0xFF27AE60),
          ),
          const SizedBox(width: 8),
          _StatPill(
            icon: Icons.local_fire_department_rounded,
            label: _topMuscle(state.weeklySetVolumePerMuscleGroup),
            sub: 'Top Muscle',
            color: const Color(0xFFEB5757),
          ),
        ],
      ),
    );
  }

  String _topMuscle(Map<String, int> map) {
    if (map.isEmpty) return '—';
    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color color;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: color, fontSize: 13, fontWeight: FontWeight.w800)),
              Text(sub,
                  style: const TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 9,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// WORKOUT DAY EXPANDER
// ===========================================================================

class _WorkoutDayExpander extends StatefulWidget {
  final AdvancedWorkoutDay day;
  final int dragIndex;

  const _WorkoutDayExpander({
    super.key,
    required this.day,
    required this.dragIndex,
  });

  @override
  State<_WorkoutDayExpander> createState() => _WorkoutDayExpanderState();
}

class _WorkoutDayExpanderState extends State<_WorkoutDayExpander>
    with SingleTickerProviderStateMixin {
  late final AnimationController _expandCtrl;
  late final Animation<double> _expandAnim;
  bool _expanded = true;
  bool _editingName = false;
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.day.name);
    _expandCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 260), value: 1);
    _expandAnim =
        CurvedAnimation(parent: _expandCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _expandCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() => _expanded = !_expanded);
    _expanded ? _expandCtrl.forward() : _expandCtrl.reverse();
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ProgramBuilderBloc>();
    final day = widget.day;
    final exCount = day.exercises.length;
    final setCount = day.setsPerBodyPart.values.fold(0, (s, v) => s + v);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Day header ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Drag handle
                ReorderableDragStartListener(
                  index: widget.dragIndex,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.drag_handle_rounded,
                        size: 18, color: AppTheme.textTertiary),
                  ),
                ),

                // Day name (tappable to edit)
                Expanded(
                  child: _editingName
                      ? TextField(
                          controller: _nameCtrl,
                          autofocus: true,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: (v) {
                            setState(() => _editingName = false);
                            if (v.trim().isNotEmpty) {
                              bloc.add(ProgramBuilderDayRenamed(
                                  dayId: day.id, name: v.trim()));
                            }
                          },
                        )
                      : GestureDetector(
                          onDoubleTap: () =>
                              setState(() => _editingName = true),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                day.name,
                                style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700),
                              ),
                              Text(
                                '$exCount exercise${exCount == 1 ? '' : 's'}  ·  $setCount working set${setCount == 1 ? '' : 's'}',
                                style: const TextStyle(
                                    color: AppTheme.textTertiary, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                ),

                // Actions
                _DayActionMenu(
                  onClone: () => bloc.add(ProgramBuilderDayCloned(day.id)),
                  onDelete: () => bloc.add(ProgramBuilderDayRemoved(day.id)),
                ),

                // Expand toggle
                TnTPressable(
                  onTap: _toggleExpand,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: AnimatedRotation(
                      turns: _expanded ? 0 : -0.25,
                      duration: const Duration(milliseconds: 220),
                      child: const Icon(Icons.expand_less_rounded,
                          size: 18, color: AppTheme.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Exercises ─────────────────────────────────────────────────────
          SizeTransition(
            sizeFactor: _expandAnim,
            child: Column(
              children: [
                Divider(height: 1, thickness: 1, color: AppTheme.outlineSoft),
                if (day.exercises.isEmpty)
                  _DayEmptyExercises(
                    onAddExercise: () => _openExercisePicker(context, day.id),
                  )
                else
                  ...day.exercises.map((ex) => _ExerciseTile(
                        key: ValueKey(ex.id),
                        exercise: ex,
                        dayId: day.id,
                      )),
                // Session notes
                if (day.sessionNotes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: _SessionNotesChip(notes: day.sessionNotes),
                  ),
                // Add exercise + notes
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SmallAddButton(
                          icon: Icons.add_rounded,
                          label: 'Add Exercise',
                          color: AppTheme.brand,
                          onTap: () => _openExercisePicker(context, day.id),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _SmallAddButton(
                        icon: Icons.notes_rounded,
                        label: 'Notes',
                        color: AppTheme.textSecondary,
                        onTap: () => _openSessionNotesSheet(context, day),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openExercisePicker(BuildContext context, String dayId) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: context.read<ProgramBuilderBloc>(),
        child: _ExercisePickerSheet(dayId: dayId),
      ),
    );
  }

  void _openSessionNotesSheet(BuildContext context, AdvancedWorkoutDay day) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: context.read<ProgramBuilderBloc>(),
        child: _SessionNotesSheet(day: day),
      ),
    );
  }
}

class _DayActionMenu extends StatelessWidget {
  final VoidCallback onClone;
  final VoidCallback onDelete;

  const _DayActionMenu({required this.onClone, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz_rounded,
          size: 18, color: AppTheme.textSecondary),
      color: AppTheme.surfaceRaised,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (v) {
        if (v == 'clone') onClone();
        if (v == 'delete') onDelete();
      },
      itemBuilder: (_) => [
        _menuItem(
            'clone', Icons.copy_rounded, 'Clone Day', AppTheme.textPrimary),
        _menuItem('delete', Icons.delete_outline_rounded, 'Delete Day',
            const Color(0xFFEB5757)),
      ],
    );
  }

  PopupMenuItem<String> _menuItem(
      String value, IconData icon, String label, Color color) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ===========================================================================
// EXERCISE TILE (within a day)
// ===========================================================================

class _ExerciseTile extends StatelessWidget {
  final AdvancedPrescribedExercise exercise;
  final String dayId;

  const _ExerciseTile({
    super.key,
    required this.exercise,
    required this.dayId,
  });

  @override
  Widget build(BuildContext context) {
    final m = exercise.metrics;
    final ex = exercise.exercise;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: name, modality, set type, menu
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Muscle colour dot
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4, right: 8),
                  decoration: BoxDecoration(
                    color: _bodyPartColor(ex.targetBodyPart),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ex.name.isEmpty ? 'Unnamed Exercise' : ex.name,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        spacing: 6,
                        children: [
                          if (ex.targetBodyPart.isNotEmpty)
                            _MicroChip(
                                label: ex.targetBodyPart,
                                color: _bodyPartColor(ex.targetBodyPart)),
                          _MicroChip(
                              label: m.setType.label,
                              color: _setTypeColor(m.setType)),
                          if (m.modality != ExerciseModality.straightSet)
                            _MicroChip(
                                label: m.modality.label, color: AppTheme.brand),
                        ],
                      ),
                    ],
                  ),
                ),
                _ExerciseActionMenu(
                  exercise: exercise,
                  dayId: dayId,
                  onEditMetrics: () => _openMetricsSheet(context),
                  onDelete: () => context.read<ProgramBuilderBloc>().add(
                        ProgramBuilderExerciseRemoved(
                            dayId: dayId, exerciseId: exercise.id),
                      ),
                ),
              ],
            ),
          ),

          // Metrics row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _MetricPill(label: 'Sets', value: '${m.sets}'),
                _MetricPill(label: 'Reps', value: m.reps),
                _MetricPill(label: 'Rest', value: m.restTime),
                if (m.rpe != null)
                  _MetricPill(label: 'RPE', value: m.rpe!.toStringAsFixed(1)),
                if (m.rir != null) _MetricPill(label: 'RIR', value: '${m.rir}'),
                if (m.percentOf1rm != null)
                  _MetricPill(
                      label: '1RM%', value: '${m.percentOf1rm!.round()}%'),
                if (m.tempo != null)
                  _MetricPill(label: 'Tempo', value: m.tempo!.code),
              ],
            ),
          ),

          // Cues strip
          if (m.trainerCues.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.brand.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.record_voice_over_rounded,
                      size: 12, color: AppTheme.brand),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      m.trainerCues,
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),

          // Alternative exercise
          if (exercise.alternativeExercise != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Row(
                children: [
                  const Icon(Icons.swap_horiz_rounded,
                      size: 12, color: AppTheme.textTertiary),
                  const SizedBox(width: 6),
                  Text(
                    'Alt: ${exercise.alternativeExercise!.name}',
                    style: const TextStyle(
                        color: AppTheme.textTertiary, fontSize: 10),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _openMetricsSheet(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: context.read<ProgramBuilderBloc>(),
        child: _ExerciseMetricsSheet(exercise: exercise, dayId: dayId),
      ),
    );
  }

  Color _bodyPartColor(String bp) {
    final h = bp.toLowerCase().hashCode;
    final palette = [
      const Color(0xFF7C4DFF),
      const Color(0xFF2F80ED),
      const Color(0xFF27AE60),
      const Color(0xFFF2C94C),
      const Color(0xFFEB5757),
      const Color(0xFF56CCF2),
      const Color(0xFFE991A0),
      const Color(0xFFFF8C42),
    ];
    return palette[h.abs() % palette.length];
  }

  Color _setTypeColor(SetType t) {
    switch (t) {
      case SetType.warmup:
        return const Color(0xFFF2C94C);
      case SetType.working:
        return const Color(0xFF27AE60);
      case SetType.feeder:
        return const Color(0xFF56CCF2);
      case SetType.backoff:
        return const Color(0xFF2F80ED);
      case SetType.amrap:
        return const Color(0xFFEB5757);
    }
  }
}

class _MicroChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MicroChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;

  const _MetricPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.outlineSoft),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 8,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ExerciseActionMenu extends StatelessWidget {
  final AdvancedPrescribedExercise exercise;
  final String dayId;
  final VoidCallback onEditMetrics;
  final VoidCallback onDelete;

  const _ExerciseActionMenu({
    required this.exercise,
    required this.dayId,
    required this.onEditMetrics,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded,
          size: 16, color: AppTheme.textSecondary),
      color: AppTheme.surfaceRaised,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (v) {
        switch (v) {
          case 'edit':
            onEditMetrics();
            break;
          case 'delete':
            onDelete();
            break;
          case 'alternative':
            _openAltPicker(context);
            break;
        }
      },
      itemBuilder: (_) => [
        _item('edit', Icons.tune_rounded, 'Edit Metrics', AppTheme.textPrimary),
        _item('alternative', Icons.swap_horiz_rounded, 'Set Alternative',
            AppTheme.textSecondary),
        _item('delete', Icons.delete_outline_rounded, 'Remove',
            const Color(0xFFEB5757)),
      ],
    );
  }

  void _openAltPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: context.read<ProgramBuilderBloc>(),
        child: _AlternativeExerciseSheet(
          dayId: dayId,
          exerciseId: exercise.id,
          current: exercise.alternativeExercise,
        ),
      ),
    );
  }

  PopupMenuItem<String> _item(
      String value, IconData icon, String label, Color color) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ===========================================================================
// EXERCISE METRICS SHEET
// ===========================================================================

class _ExerciseMetricsSheet extends StatefulWidget {
  final AdvancedPrescribedExercise exercise;
  final String dayId;

  const _ExerciseMetricsSheet({required this.exercise, required this.dayId});

  @override
  State<_ExerciseMetricsSheet> createState() => _ExerciseMetricsSheetState();
}

class _ExerciseMetricsSheetState extends State<_ExerciseMetricsSheet>
    with SingleTickerProviderStateMixin {
  late AdvancedExerciseMetrics _m;
  late final TabController _tabCtrl;

  // Local controllers
  late final TextEditingController _repsCtrl;
  late final TextEditingController _restCtrl;
  late final TextEditingController _cuesCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _tempoEcc;
  late final TextEditingController _tempoPb;
  late final TextEditingController _tempoCon;
  late final TextEditingController _tempoPt;

  @override
  void initState() {
    super.initState();
    _m = widget.exercise.metrics;
    _tabCtrl = TabController(length: 3, vsync: this);
    _repsCtrl = TextEditingController(text: _m.reps);
    _restCtrl = TextEditingController(text: _m.restTime);
    _cuesCtrl = TextEditingController(text: _m.trainerCues);
    _notesCtrl = TextEditingController(text: _m.notes);
    _tempoEcc = TextEditingController(text: _m.tempo?.eccentric ?? '2');
    _tempoPb = TextEditingController(text: _m.tempo?.pauseBottom ?? '0');
    _tempoCon = TextEditingController(text: _m.tempo?.concentric ?? '1');
    _tempoPt = TextEditingController(text: _m.tempo?.pauseTop ?? '0');
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _repsCtrl.dispose();
    _restCtrl.dispose();
    _cuesCtrl.dispose();
    _notesCtrl.dispose();
    _tempoEcc.dispose();
    _tempoPb.dispose();
    _tempoCon.dispose();
    _tempoPt.dispose();
    super.dispose();
  }

  void _commit() {
    final tempo = ExerciseTempo(
      eccentric: _tempoEcc.text.trim().isEmpty ? '2' : _tempoEcc.text.trim(),
      pauseBottom: _tempoPb.text.trim().isEmpty ? '0' : _tempoPb.text.trim(),
      concentric: _tempoCon.text.trim().isEmpty ? '1' : _tempoCon.text.trim(),
      pauseTop: _tempoPt.text.trim().isEmpty ? '0' : _tempoPt.text.trim(),
    );

    final updated = _m.copyWith(
      reps: _repsCtrl.text.trim(),
      restTime: _restCtrl.text.trim(),
      trainerCues: _cuesCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      tempo: tempo,
    );

    context.read<ProgramBuilderBloc>().add(
          ProgramBuilderExerciseMetricsChanged(
            dayId: widget.dayId,
            exerciseId: widget.exercise.id,
            metrics: updated,
          ),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            const _SheetHandle(),

            // Exercise name header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.exercise.exercise.name,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  TnTPressable(
                    onTap: _commit,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.brand,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Done',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),

            // Tabs: Base / Advanced / Cues
            TabBar(
              controller: _tabCtrl,
              indicatorColor: AppTheme.brand,
              labelColor: AppTheme.brand,
              unselectedLabelColor: AppTheme.textSecondary,
              labelStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              tabs: const [
                Tab(text: 'Base'),
                Tab(text: 'Advanced'),
                Tab(text: 'Cues & Notes'),
              ],
            ),

            SizedBox(
              height: 340,
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _BaseMetricsTab(
                    metrics: _m,
                    repsCtrl: _repsCtrl,
                    restCtrl: _restCtrl,
                    onSetsChanged: (v) =>
                        setState(() => _m = _m.copyWith(sets: v)),
                    onSetTypeChanged: (v) =>
                        setState(() => _m = _m.copyWith(setType: v)),
                    onModalityChanged: (v) =>
                        setState(() => _m = _m.copyWith(modality: v)),
                  ),
                  _AdvancedMetricsTab(
                    metrics: _m,
                    tempoEcc: _tempoEcc,
                    tempoPb: _tempoPb,
                    tempoCon: _tempoCon,
                    tempoPt: _tempoPt,
                    onRpeChanged: (v) =>
                        setState(() => _m = _m.copyWith(rpe: v)),
                    onRirChanged: (v) =>
                        setState(() => _m = _m.copyWith(rir: v)),
                    on1RmChanged: (v) =>
                        setState(() => _m = _m.copyWith(percentOf1rm: v)),
                    onTempoEnabledChanged: (v) =>
                        setState(() => _m = _m.copyWith(
                              tempo: v
                                  ? ExerciseTempo.fromCode(
                                      '${_tempoEcc.text}${_tempoPb.text}${_tempoCon.text}${_tempoPt.text}')
                                  : null,
                            )),
                  ),
                  _CuesTab(cuesCtrl: _cuesCtrl, notesCtrl: _notesCtrl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Base Metrics Tab ────────────────────────────────────────────────────────

class _BaseMetricsTab extends StatelessWidget {
  final AdvancedExerciseMetrics metrics;
  final TextEditingController repsCtrl;
  final TextEditingController restCtrl;
  final ValueChanged<int> onSetsChanged;
  final ValueChanged<SetType> onSetTypeChanged;
  final ValueChanged<ExerciseModality> onModalityChanged;

  const _BaseMetricsTab({
    required this.metrics,
    required this.repsCtrl,
    required this.restCtrl,
    required this.onSetsChanged,
    required this.onSetTypeChanged,
    required this.onModalityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Sets stepper
        _SheetRow(
          label: 'Sets',
          child: _IntStepper(
            value: metrics.sets,
            min: 1,
            max: 20,
            onChanged: onSetsChanged,
          ),
        ),
        const SizedBox(height: 14),

        // Reps
        _SheetRow(
          label: 'Reps / Range',
          child: _SheetTextField(
            controller: repsCtrl,
            hint: 'e.g. 8–12 or 10',
          ),
        ),
        const SizedBox(height: 14),

        // Rest
        _SheetRow(
          label: 'Rest Time',
          child: _SheetTextField(controller: restCtrl, hint: '90 sec'),
        ),
        const SizedBox(height: 16),

        // Set type
        _SubLabel('Set Type'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: SetType.values.map((t) {
            final sel = t == metrics.setType;
            return _ToggleChip(
              label: t.label,
              selected: sel,
              onTap: () => onSetTypeChanged(t),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Modality
        _SubLabel('Modality'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: ExerciseModality.values.map((m) {
            final sel = m == metrics.modality;
            return _ToggleChip(
              label: m.label,
              selected: sel,
              color: sel ? AppTheme.brand : null,
              onTap: () => onModalityChanged(m),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Advanced Metrics Tab ─────────────────────────────────────────────────────

class _AdvancedMetricsTab extends StatelessWidget {
  final AdvancedExerciseMetrics metrics;
  final TextEditingController tempoEcc;
  final TextEditingController tempoPb;
  final TextEditingController tempoCon;
  final TextEditingController tempoPt;
  final ValueChanged<double?> onRpeChanged;
  final ValueChanged<int?> onRirChanged;
  final ValueChanged<double?> on1RmChanged;
  final ValueChanged<bool> onTempoEnabledChanged;

  const _AdvancedMetricsTab({
    required this.metrics,
    required this.tempoEcc,
    required this.tempoPb,
    required this.tempoCon,
    required this.tempoPt,
    required this.onRpeChanged,
    required this.onRirChanged,
    required this.on1RmChanged,
    required this.onTempoEnabledChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // RPE slider 1–10
        _SubLabel('RPE (Rate of Perceived Exertion)'),
        const SizedBox(height: 4),
        _RpeSlider(
          value: metrics.rpe,
          onChanged: onRpeChanged,
        ),
        const SizedBox(height: 16),

        // RIR stepper
        _SheetRow(
          label: 'RIR (Reps in Reserve)',
          child: _NullableIntStepper(
            value: metrics.rir,
            min: 0,
            max: 10,
            onChanged: onRirChanged,
          ),
        ),
        const SizedBox(height: 14),

        // % of 1RM
        _SheetRow(
          label: '% of 1RM',
          child: _NullableDoubleStepper(
            value: metrics.percentOf1rm,
            min: 10,
            max: 100,
            step: 2.5,
            onChanged: on1RmChanged,
          ),
        ),
        const SizedBox(height: 16),

        // Tempo
        Row(
          children: [
            Expanded(child: _SubLabel('Tempo (4-digit)')),
            Switch(
              value: metrics.tempo != null,
              onChanged: onTempoEnabledChanged,
              activeColor: AppTheme.brand,
            ),
          ],
        ),
        if (metrics.tempo != null) ...[
          const SizedBox(height: 8),
          _TempoEditor(ecc: tempoEcc, pb: tempoPb, con: tempoCon, pt: tempoPt),
        ],
      ],
    );
  }
}

class _RpeSlider extends StatelessWidget {
  final double? value;
  final ValueChanged<double?> onChanged;

  const _RpeSlider({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final v = value ?? 0;
    return Row(
      children: [
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _rpeColor(v),
              thumbColor: _rpeColor(v),
              inactiveTrackColor: AppTheme.outlineSoft,
              overlayColor: _rpeColor(v).withValues(alpha: 0.15),
              trackHeight: 4,
            ),
            child: Slider(
              value: value ?? 0,
              min: 0,
              max: 10,
              divisions: 20,
              onChanged: (nv) => onChanged(nv == 0 ? null : nv),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 40,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: value == null
                ? AppTheme.surfaceRaised
                : _rpeColor(v).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: value == null
                  ? AppTheme.outlineSoft
                  : _rpeColor(v).withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            value == null ? '—' : v.toStringAsFixed(1),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: value == null ? AppTheme.textTertiary : _rpeColor(v),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Color _rpeColor(double v) {
    if (v <= 5) return const Color(0xFF27AE60);
    if (v <= 7.5) return const Color(0xFFF2C94C);
    return const Color(0xFFEB5757);
  }
}

class _TempoEditor extends StatelessWidget {
  final TextEditingController ecc;
  final TextEditingController pb;
  final TextEditingController con;
  final TextEditingController pt;

  const _TempoEditor({
    required this.ecc,
    required this.pb,
    required this.con,
    required this.pt,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TempoCell(ctrl: ecc, label: 'Ecc'),
        const _TempoDivider(),
        _TempoCell(ctrl: pb, label: 'Pause↓'),
        const _TempoDivider(),
        _TempoCell(ctrl: con, label: 'Con'),
        const _TempoDivider(),
        _TempoCell(ctrl: pt, label: 'Pause↑'),
      ],
    );
  }
}

class _TempoCell extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;

  const _TempoCell({required this.ctrl, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceRaised,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.outlineSoft),
        ),
        child: Column(
          children: [
            TextField(
              controller: ctrl,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900),
              keyboardType: TextInputType.text,
              maxLength: 1,
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 9,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

class _TempoDivider extends StatelessWidget {
  const _TempoDivider();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Text('–',
            style: TextStyle(color: AppTheme.textTertiary, fontSize: 16)),
      );
}

// ── Cues Tab ─────────────────────────────────────────────────────────────────

class _CuesTab extends StatelessWidget {
  final TextEditingController cuesCtrl;
  final TextEditingController notesCtrl;

  const _CuesTab({required this.cuesCtrl, required this.notesCtrl});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SubLabel('Trainer Cues (client-facing coaching notes)'),
        const SizedBox(height: 8),
        _MultiLineField(
            controller: cuesCtrl,
            hint:
                'e.g. "Drive elbows back, maintain 45° angle, pause at chest"',
            minLines: 3),
        const SizedBox(height: 16),
        _SubLabel('Internal Notes (trainer-only)'),
        const SizedBox(height: 8),
        _MultiLineField(
            controller: notesCtrl,
            hint:
                'e.g. "Client struggles with lower back rounding – watch closely"',
            minLines: 3),
      ],
    );
  }
}

// ===========================================================================
// EXERCISE PICKER SHEET
// ===========================================================================

class _ExercisePickerSheet extends StatefulWidget {
  final String dayId;

  const _ExercisePickerSheet({required this.dayId});

  @override
  State<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<_ExercisePickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  String? _selectedBodyPart;
  String? _selectedType;

  // Stub library – replace with real ExerciseRepository injection
  static final List<Exercise> _stubLibrary = List.generate(
    20,
    (i) => Exercise(
      id: i,
      name: _stubNames[i % _stubNames.length],
      videoUrl: '',
      targetBodyPart: _stubBodyParts[i % _stubBodyParts.length],
      trainingType: _stubTypes[i % _stubTypes.length],
    ),
  );

  static const _stubNames = [
    'Barbell Back Squat',
    'Romanian Deadlift',
    'Incline Dumbbell Press',
    'Pull-up',
    'Bent-Over Barbell Row',
    'Overhead Press',
    'Leg Press',
    'Cable Row',
    'Dumbbell Curl',
    'Tricep Pushdown',
    'Hip Thrust',
    'Face Pull',
    'Lateral Raise',
    'Leg Curl',
    'Chest Fly',
    'Shrug',
    'Front Squat',
    'Good Morning',
    'Arnold Press',
    'Preacher Curl',
  ];
  static const _stubBodyParts = [
    'Quads',
    'Hamstrings',
    'Chest',
    'Back',
    'Shoulders',
    'Biceps',
    'Triceps',
    'Glutes',
    'Lats',
    'Trapezius',
  ];
  static const _stubTypes = ['Compound', 'Isolation', 'Machine'];

  List<Exercise> get _filtered {
    var list = _stubLibrary;
    if (_query.isNotEmpty) {
      list = list
          .where((e) => e.name.toLowerCase().contains(_query.toLowerCase()))
          .toList();
    }
    if (_selectedBodyPart != null) {
      list = list.where((e) => e.targetBodyPart == _selectedBodyPart).toList();
    }
    if (_selectedType != null) {
      list = list.where((e) => e.trainingType == _selectedType).toList();
    }
    return list;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allBodyParts =
        _stubLibrary.map((e) => e.targetBodyPart).toSet().toList()..sort();
    final allTypes = _stubLibrary.map((e) => e.trainingType).toSet().toList()
      ..sort();
    final results = _filtered;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      maxChildSize: 0.95,
      builder: (_, sc) => Column(
        children: [
          // Handle + title
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SheetHandle(),
                const SizedBox(height: 4),
                const Text('Exercise Library',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                // Search
                _SearchBar(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 10),
                // Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected:
                            _selectedBodyPart == null && _selectedType == null,
                        onTap: () => setState(() {
                          _selectedBodyPart = null;
                          _selectedType = null;
                        }),
                      ),
                      const SizedBox(width: 6),
                      ...allBodyParts.map((bp) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _FilterChip(
                              label: bp,
                              selected: _selectedBodyPart == bp,
                              onTap: () => setState(() {
                                _selectedBodyPart =
                                    _selectedBodyPart == bp ? null : bp;
                              }),
                            ),
                          )),
                      const SizedBox(width: 4),
                      ...allTypes.map((t) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _FilterChip(
                              label: t,
                              selected: _selectedType == t,
                              color: const Color(0xFF2F80ED),
                              onTap: () => setState(() {
                                _selectedType = _selectedType == t ? null : t;
                              }),
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text('${results.length} results',
                    style: const TextStyle(
                        color: AppTheme.textTertiary, fontSize: 10)),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.outlineSoft),
          Expanded(
            child: ListView.builder(
              controller: sc,
              itemCount: results.length,
              itemBuilder: (_, i) {
                final ex = results[i];
                return TnTPressable(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.read<ProgramBuilderBloc>().add(
                          ProgramBuilderExerciseAdded(
                            dayId: widget.dayId,
                            exercise: ex,
                          ),
                        );
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceRaised,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.fitness_center_rounded,
                              size: 16, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ex.name,
                                  style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  _MicroChip(
                                      label: ex.targetBodyPart,
                                      color: AppTheme.brand),
                                  const SizedBox(width: 6),
                                  _MicroChip(
                                      label: ex.trainingType,
                                      color: const Color(0xFF2F80ED)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.add_circle_outline_rounded,
                            size: 20, color: AppTheme.brand),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// ALTERNATIVE EXERCISE SHEET
// ===========================================================================

class _AlternativeExerciseSheet extends StatefulWidget {
  final String dayId;
  final String exerciseId;
  final Exercise? current;

  const _AlternativeExerciseSheet({
    required this.dayId,
    required this.exerciseId,
    this.current,
  });

  @override
  State<_AlternativeExerciseSheet> createState() =>
      _AlternativeExerciseSheetState();
}

class _AlternativeExerciseSheetState extends State<_AlternativeExerciseSheet> {
  final TextEditingController _ctrl = TextEditingController();
  String _query = '';

  static final List<Exercise> _lib = List.generate(
    10,
    (i) => Exercise(
      id: 100 + i,
      name: _ExercisePickerSheetState
          ._stubNames[(i + 5) % _ExercisePickerSheetState._stubNames.length],
      videoUrl: '',
      targetBodyPart: _ExercisePickerSheetState
          ._stubBodyParts[i % _ExercisePickerSheetState._stubBodyParts.length],
      trainingType: 'Compound',
    ),
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _query.isEmpty
        ? _lib
        : _lib
            .where((e) => e.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      builder: (_, sc) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SheetHandle(),
                const SizedBox(height: 6),
                const Text('Set Alternative Exercise',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                _SearchBar(
                  controller: _ctrl,
                  onChanged: (v) => setState(() => _query = v),
                ),
                if (widget.current != null) ...[
                  const SizedBox(height: 10),
                  TnTPressable(
                    onTap: () {
                      context.read<ProgramBuilderBloc>().add(
                            ProgramBuilderAlternativeExerciseSet(
                              dayId: widget.dayId,
                              exerciseId: widget.exerciseId,
                              alternativeExercise: null,
                            ),
                          );
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEB5757).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color:
                                const Color(0xFFEB5757).withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.close_rounded,
                              size: 13, color: Color(0xFFEB5757)),
                          const SizedBox(width: 6),
                          Text('Clear: ${widget.current!.name}',
                              style: const TextStyle(
                                  color: Color(0xFFEB5757),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.outlineSoft),
          Expanded(
            child: ListView.builder(
              controller: sc,
              itemCount: results.length,
              itemBuilder: (_, i) {
                final ex = results[i];
                return TnTPressable(
                  onTap: () {
                    context.read<ProgramBuilderBloc>().add(
                          ProgramBuilderAlternativeExerciseSet(
                            dayId: widget.dayId,
                            exerciseId: widget.exerciseId,
                            alternativeExercise: ex,
                          ),
                        );
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(ex.name,
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ),
                        _MicroChip(
                            label: ex.targetBodyPart, color: AppTheme.brand),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// SESSION NOTES SHEET
// ===========================================================================

class _SessionNotesSheet extends StatefulWidget {
  final AdvancedWorkoutDay day;
  const _SessionNotesSheet({required this.day});

  @override
  State<_SessionNotesSheet> createState() => _SessionNotesSheetState();
}

class _SessionNotesSheetState extends State<_SessionNotesSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.day.sessionNotes);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text('${widget.day.name} – Session Notes',
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800)),
                ),
                TnTPressable(
                  onTap: () {
                    context.read<ProgramBuilderBloc>().add(
                          ProgramBuilderDayNotesChanged(
                              dayId: widget.day.id, notes: _ctrl.text.trim()),
                        );
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                        color: AppTheme.brand,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Text('Save',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _MultiLineField(
              controller: _ctrl,
              hint:
                  'e.g. "Rest at least 3 min between compound sets. Focus on mind-muscle connection."',
              minLines: 5,
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// EMPTY STATES
// ===========================================================================

class _TrainingEmptyState extends StatelessWidget {
  final VoidCallback onAddDay;
  const _TrainingEmptyState({required this.onAddDay});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.outlineSoft),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.brand.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calendar_today_rounded,
                color: AppTheme.brand, size: 26),
          ),
          const SizedBox(height: 12),
          const Text('No training days yet',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Add your first day to start building the programme',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          const SizedBox(height: 16),
          TnTPressable(
            onTap: onAddDay,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                  color: AppTheme.brand,
                  borderRadius: BorderRadius.circular(10)),
              child: const Text('Add First Day',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayEmptyExercises extends StatelessWidget {
  final VoidCallback onAddExercise;
  const _DayEmptyExercises({required this.onAddExercise});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: TnTPressable(
        onTap: onAddExercise,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.brand.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppTheme.brand.withValues(alpha: 0.15),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, size: 16, color: AppTheme.brand),
              SizedBox(width: 6),
              Text('Tap to add exercises',
                  style: TextStyle(
                      color: AppTheme.brand,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// ADD DAY BUTTON
// ===========================================================================

class _AddDayButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddDayButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TnTPressable(
      onTap: onTap,
      pressedScale: 0.97,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.brand.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.brand.withValues(alpha: 0.2)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 18, color: AppTheme.brand),
            SizedBox(width: 8),
            Text('Add Training Day',
                style: TextStyle(
                    color: AppTheme.brand,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// SHARED FORM WIDGETS
// ===========================================================================

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppTheme.outlineSoft,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _SheetRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _SheetTextField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.outlineSoft),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(color: AppTheme.textTertiary, fontSize: 13),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        ),
      ),
    );
  }
}

class _MultiLineField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int minLines;

  const _MultiLineField({
    required this.controller,
    required this.hint,
    this.minLines = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.outlineSoft),
      ),
      child: TextField(
        controller: controller,
        minLines: minLines,
        maxLines: null,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(color: AppTheme.textTertiary, fontSize: 12),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}

class _SubLabel extends StatelessWidget {
  final String text;
  const _SubLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.brand;
    return TnTPressable(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? c.withValues(alpha: 0.15) : AppTheme.surfaceRaised,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color:
                  selected ? c.withValues(alpha: 0.5) : AppTheme.outlineSoft),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: selected ? c : AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.brand;
    return TnTPressable(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? c.withValues(alpha: 0.15) : AppTheme.surfaceRaised,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color:
                  selected ? c.withValues(alpha: 0.4) : AppTheme.outlineSoft),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: selected ? c : AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineSoft),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
        decoration: const InputDecoration(
          hintText: 'Search exercises…',
          hintStyle: TextStyle(color: AppTheme.textTertiary, fontSize: 13),
          prefixIcon: Icon(Icons.search_rounded,
              size: 18, color: AppTheme.textTertiary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _IntStepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _IntStepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepperBtn(
          icon: Icons.remove_rounded,
          enabled: value > min,
          onTap: () => onChanged(value - 1),
        ),
        Container(
          width: 48,
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          child: Text('$value',
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
        ),
        _StepperBtn(
          icon: Icons.add_rounded,
          enabled: value < max,
          onTap: () => onChanged(value + 1),
        ),
      ],
    );
  }
}

class _NullableIntStepper extends StatelessWidget {
  final int? value;
  final int min;
  final int max;
  final ValueChanged<int?> onChanged;

  const _NullableIntStepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepperBtn(
          icon: Icons.remove_rounded,
          enabled: value != null && value! > min,
          onTap: value != null
              ? () => onChanged(value! <= min ? null : value! - 1)
              : () {},
        ),
        Container(
          width: 48,
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          child: Text(
            value?.toString() ?? '—',
            style: TextStyle(
              color:
                  value == null ? AppTheme.textTertiary : AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        _StepperBtn(
          icon: Icons.add_rounded,
          enabled: value == null || value! < max,
          onTap: () => onChanged(value == null ? min : (value! + 1)),
        ),
      ],
    );
  }
}

class _NullableDoubleStepper extends StatelessWidget {
  final double? value;
  final double min;
  final double max;
  final double step;
  final ValueChanged<double?> onChanged;

  const _NullableDoubleStepper({
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepperBtn(
          icon: Icons.remove_rounded,
          enabled: value != null && value! > min,
          onTap: value != null
              ? () {
                  final nv = value! - step;
                  onChanged(nv < min ? null : nv);
                }
              : () {},
        ),
        Container(
          width: 56,
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          child: Text(
            value == null ? '—' : '${value!.toStringAsFixed(1)}%',
            style: TextStyle(
              color:
                  value == null ? AppTheme.textTertiary : AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        _StepperBtn(
          icon: Icons.add_rounded,
          enabled: value == null || value! < max,
          onTap: () => onChanged(value == null ? min : value! + step),
        ),
      ],
    );
  }
}

class _StepperBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepperBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TnTPressable(
      onTap: enabled ? onTap : () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? AppTheme.surfaceRaised : AppTheme.surfaceLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.outlineSoft),
        ),
        child: Icon(
          icon,
          size: 14,
          color: enabled ? AppTheme.textPrimary : AppTheme.textTertiary,
        ),
      ),
    );
  }
}

class _SessionNotesChip extends StatelessWidget {
  final String notes;
  const _SessionNotesChip({required this.notes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.outlineSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.notes_rounded,
              size: 12, color: AppTheme.textTertiary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              notes,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallAddButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SmallAddButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TnTPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// SECTIONS 3, 4, 5 – NUTRITION / SUPPLEMENTATION / LIFESTYLE
// ===========================================================================
class NutritionProtocolSection extends StatelessWidget {
  const NutritionProtocolSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgramBuilderBloc, ProgramBuilderState>(
      buildWhen: (p, c) =>
          p.program.nutritionProtocol != c.program.nutritionProtocol ||
          p.tdee != c.tdee,
      builder: (context, state) {
        final nut = state.program.nutritionProtocol;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TDEE reference banner
            _TdeeBanner(tdee: state.tdee),
            const SizedBox(height: 16),

            // Macro target editor
            _NutritionSubHeader(label: 'Daily Macro Targets'),
            const SizedBox(height: 10),
            _MacroTargetEditor(targets: nut.baseTargets),
            const SizedBox(height: 20),

            // Macro distribution mini chart
            if (nut.baseTargets.calories > 0) ...[
              _NutritionSubHeader(label: 'Calorie Distribution'),
              const SizedBox(height: 10),
              _MacroDistributionBar(targets: nut.baseTargets),
              const SizedBox(height: 20),
            ],

            // Calorie / macro cycling
            _NutritionSubHeader(label: 'Cycling Strategy'),
            const SizedBox(height: 10),
            _CyclingStrategyEditor(protocol: nut),
            const SizedBox(height: 20),

            // Meal slots
            _NutritionSubHeader(
                label: 'Meal Plan (${nut.mealSlots.length} slots)'),
            const SizedBox(height: 10),
            _MealSlotList(protocol: nut),
            const SizedBox(height: 10),
            _OutlineAddButton(
              label: 'Add Meal Slot',
              icon: Icons.add_rounded,
              color: AppTheme.brand,
              onTap: () => _openMealSlotSheet(context, nut),
            ),
            const SizedBox(height: 20),

            // Micronutrient targets
            _NutritionSubHeader(
                label:
                    'Micronutrient Targets (${nut.micronutrientTargets.length})'),
            const SizedBox(height: 10),
            _MicronutrientList(targets: nut.micronutrientTargets),
            const SizedBox(height: 8),
            _OutlineAddButton(
              label: 'Add Micronutrient Target',
              icon: Icons.science_rounded,
              color: const Color(0xFF56CCF2),
              onTap: () => _openMicronutrientSheet(context, nut),
            ),
          ],
        );
      },
    );
  }

  void _openMealSlotSheet(BuildContext context, NutritionProtocol nut) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => BlocProvider.value(
        value: context.read<ProgramBuilderBloc>(),
        child: const _MealSlotSheet(),
      ),
    );
  }

  void _openMicronutrientSheet(BuildContext context, NutritionProtocol nut) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => BlocProvider.value(
        value: context.read<ProgramBuilderBloc>(),
        child: const _MicronutrientSheet(),
      ),
    );
  }
}

// ── TDEE Reference Banner ────────────────────────────────────────────────────

class _TdeeBanner extends StatelessWidget {
  final double tdee;
  const _TdeeBanner({required this.tdee});

  @override
  Widget build(BuildContext context) {
    if (tdee <= 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF27AE60).withValues(alpha: 0.12),
            const Color(0xFF27AE60).withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: const Color(0xFF27AE60).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department_rounded,
              size: 16, color: Color(0xFF27AE60)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estimated TDEE',
                    style: TextStyle(
                        color: Color(0xFF27AE60),
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
                Text('${tdee.round()} kcal/day',
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _TdeeVariant(label: '−500 (Cut)', value: tdee - 500),
              _TdeeVariant(label: '+300 (Bulk)', value: tdee + 300),
            ],
          ),
        ],
      ),
    );
  }
}

class _TdeeVariant extends StatelessWidget {
  final String label;
  final double value;
  const _TdeeVariant({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label: ${value.round()}',
      style: const TextStyle(
          color: AppTheme.textTertiary,
          fontSize: 9,
          fontWeight: FontWeight.w600),
    );
  }
}

// ── Macro Target Editor ───────────────────────────────────────────────────────

class _MacroTargetEditor extends StatefulWidget {
  final MacroTarget targets;
  const _MacroTargetEditor({required this.targets});

  @override
  State<_MacroTargetEditor> createState() => _MacroTargetEditorState();
}

class _MacroTargetEditorState extends State<_MacroTargetEditor> {
  late final TextEditingController _calCtrl;
  late final TextEditingController _proCtrl;
  late final TextEditingController _carbCtrl;
  late final TextEditingController _fatCtrl;
  late final TextEditingController _fiberCtrl;

  @override
  void initState() {
    super.initState();
    final t = widget.targets;
    _calCtrl = TextEditingController(
        text: t.calories > 0 ? t.calories.round().toString() : '');
    _proCtrl = TextEditingController(
        text: t.proteinG > 0 ? t.proteinG.round().toString() : '');
    _carbCtrl = TextEditingController(
        text: t.carbsG > 0 ? t.carbsG.round().toString() : '');
    _fatCtrl = TextEditingController(
        text: t.fatsG > 0 ? t.fatsG.round().toString() : '');
    _fiberCtrl = TextEditingController(
        text: t.fiberG > 0 ? t.fiberG.round().toString() : '');
  }

  @override
  void dispose() {
    _calCtrl.dispose();
    _proCtrl.dispose();
    _carbCtrl.dispose();
    _fatCtrl.dispose();
    _fiberCtrl.dispose();
    super.dispose();
  }

  void _commit() {
    final updated = MacroTarget(
      calories: double.tryParse(_calCtrl.text) ?? 0,
      proteinG: double.tryParse(_proCtrl.text) ?? 0,
      carbsG: double.tryParse(_carbCtrl.text) ?? 0,
      fatsG: double.tryParse(_fatCtrl.text) ?? 0,
      fiberG: double.tryParse(_fiberCtrl.text) ?? 0,
    );
    context.read<ProgramBuilderBloc>().add(
          ProgramBuilderNutritionChanged(
            context
                .read<ProgramBuilderBloc>()
                .state
                .program
                .nutritionProtocol
                .copyWith(baseTargets: updated),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Calories – full width
        _MacroInputRow(
          label: 'Calories',
          unit: 'kcal',
          color: const Color(0xFFF2C94C),
          controller: _calCtrl,
          onCommit: _commit,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MacroInputRow(
                label: 'Protein',
                unit: 'g',
                color: const Color(0xFF2F80ED),
                controller: _proCtrl,
                onCommit: _commit,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MacroInputRow(
                label: 'Carbs',
                unit: 'g',
                color: const Color(0xFF27AE60),
                controller: _carbCtrl,
                onCommit: _commit,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MacroInputRow(
                label: 'Fats',
                unit: 'g',
                color: const Color(0xFFEB5757),
                controller: _fatCtrl,
                onCommit: _commit,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MacroInputRow(
                label: 'Fiber',
                unit: 'g',
                color: const Color(0xFF56CCF2),
                controller: _fiberCtrl,
                onCommit: _commit,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MacroInputRow extends StatelessWidget {
  final String label;
  final String unit;
  final Color color;
  final TextEditingController controller;
  final VoidCallback onCommit;

  const _MacroInputRow({
    required this.label,
    required this.unit,
    required this.color,
    required this.controller,
    required this.onCommit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: color,
                        fontSize: 9,
                        fontWeight: FontWeight.w700)),
                TextField(
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: const TextStyle(
                        color: AppTheme.textTertiary, fontSize: 15),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    suffixText: unit,
                    suffixStyle: const TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500),
                  ),
                  onEditingComplete: onCommit,
                  onTapOutside: (_) {
                    FocusScope.of(context).unfocus();
                    onCommit();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}

// ── Macro Distribution Bar ────────────────────────────────────────────────────

class _MacroDistributionBar extends StatelessWidget {
  final MacroTarget targets;
  const _MacroDistributionBar({required this.targets});

  @override
  Widget build(BuildContext context) {
    final proKcal = targets.proteinG * 4;
    final carbKcal = targets.carbsG * 4;
    final fatKcal = targets.fatsG * 9;
    final total = proKcal + carbKcal + fatKcal;
    if (total <= 0) return const SizedBox.shrink();

    final proFrac = proKcal / total;
    final carbFrac = carbKcal / total;
    final fatFrac = fatKcal / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stacked bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 24,
            child: Row(
              children: [
                _BarSegment(
                    fraction: proFrac,
                    color: const Color(0xFF2F80ED),
                    label: '${(proFrac * 100).round()}% P'),
                _BarSegment(
                    fraction: carbFrac,
                    color: const Color(0xFF27AE60),
                    label: '${(carbFrac * 100).round()}% C'),
                _BarSegment(
                    fraction: fatFrac,
                    color: const Color(0xFFEB5757),
                    label: '${(fatFrac * 100).round()}% F'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Gram breakdown
        Row(
          children: [
            _MacroLegendRow(
                color: const Color(0xFF2F80ED),
                label: 'Protein',
                gram: targets.proteinG,
                kcal: proKcal),
            const SizedBox(width: 12),
            _MacroLegendRow(
                color: const Color(0xFF27AE60),
                label: 'Carbs',
                gram: targets.carbsG,
                kcal: carbKcal),
            const SizedBox(width: 12),
            _MacroLegendRow(
                color: const Color(0xFFEB5757),
                label: 'Fats',
                gram: targets.fatsG,
                kcal: fatKcal),
          ],
        ),
      ],
    );
  }
}

class _BarSegment extends StatelessWidget {
  final double fraction;
  final Color color;
  final String label;

  const _BarSegment({
    required this.fraction,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: (fraction * 100).round().clamp(1, 100),
      child: Container(
        color: color,
        alignment: Alignment.center,
        child: fraction > 0.12
            ? Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800))
            : null,
      ),
    );
  }
}

class _MacroLegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final double gram;
  final double kcal;

  const _MacroLegendRow({
    required this.color,
    required this.label,
    required this.gram,
    required this.kcal,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 9,
                    fontWeight: FontWeight.w600)),
            Text('${gram.round()}g · ${kcal.round()} kcal',
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}

// ── Cycling Strategy Editor ───────────────────────────────────────────────────

class _CyclingStrategyEditor extends StatelessWidget {
  final NutritionProtocol protocol;
  const _CyclingStrategyEditor({required this.protocol});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: MacroCycleStrategy.values.map((s) {
            final sel = s == protocol.cycleStrategy;
            return _CycleChip(
              label: _stratLabel(s),
              selected: sel,
              onTap: () {
                HapticFeedback.selectionClick();
                context.read<ProgramBuilderBloc>().add(
                      ProgramBuilderNutritionChanged(
                          protocol.copyWith(cycleStrategy: s)),
                    );
              },
            );
          }).toList(),
        ),
        if (protocol.cycleStrategy != MacroCycleStrategy.none) ...[
          const SizedBox(height: 14),
          _CycleDayList(protocol: protocol),
          const SizedBox(height: 8),
          _OutlineAddButton(
            label: 'Add Cycle Day',
            icon: Icons.add_rounded,
            color: const Color(0xFFF2C94C),
            onTap: () => _openCycleDaySheet(context, protocol),
          ),
        ],
      ],
    );
  }

  String _stratLabel(MacroCycleStrategy s) {
    switch (s) {
      case MacroCycleStrategy.none:
        return 'None';
      case MacroCycleStrategy.calorieCycling:
        return 'Calorie Cycling';
      case MacroCycleStrategy.carbCycling:
        return 'Carb Cycling';
      case MacroCycleStrategy.fatCycling:
        return 'Fat Cycling';
    }
  }

  void _openCycleDaySheet(BuildContext context, NutritionProtocol protocol) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => BlocProvider.value(
        value: context.read<ProgramBuilderBloc>(),
        child: _CycleDaySheet(protocol: protocol),
      ),
    );
  }
}

class _CycleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CycleChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TnTPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFF2C94C).withValues(alpha: 0.15)
              : AppTheme.surfaceRaised,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected
                  ? const Color(0xFFF2C94C).withValues(alpha: 0.5)
                  : AppTheme.outlineSoft),
        ),
        child: Text(
          label,
          style: TextStyle(
              color:
                  selected ? const Color(0xFFF2C94C) : AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _CycleDayList extends StatelessWidget {
  final NutritionProtocol protocol;
  const _CycleDayList({required this.protocol});

  @override
  Widget build(BuildContext context) {
    if (protocol.cycleDays.isEmpty) {
      return _EmptyNote(
          icon: Icons.loop_rounded, text: 'No cycle days defined yet');
    }
    return Column(
      children: protocol.cycleDays.asMap().entries.map((entry) {
        final i = entry.key;
        final day = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: AppTheme.surfaceRaised,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.outlineSoft),
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2C94C).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('${i + 1}',
                      style: const TextStyle(
                          color: Color(0xFFF2C94C),
                          fontSize: 10,
                          fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(day.label,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                    Text(
                        '${day.targets.calories.round()} kcal  ·  P ${day.targets.proteinG.round()}g  C ${day.targets.carbsG.round()}g  F ${day.targets.fatsG.round()}g',
                        style: const TextStyle(
                            color: AppTheme.textTertiary, fontSize: 10)),
                  ],
                ),
              ),
              TnTPressable(
                onTap: () {
                  final updated = List<MacroCycleDay>.from(protocol.cycleDays)
                    ..removeAt(i);
                  context.read<ProgramBuilderBloc>().add(
                        ProgramBuilderNutritionChanged(
                            protocol.copyWith(cycleDays: updated)),
                      );
                },
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close_rounded,
                      size: 14, color: AppTheme.textTertiary),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Meal Slot List ────────────────────────────────────────────────────────────

class _MealSlotList extends StatelessWidget {
  final NutritionProtocol protocol;
  const _MealSlotList({required this.protocol});

  @override
  Widget build(BuildContext context) {
    if (protocol.mealSlots.isEmpty) {
      return _EmptyNote(
          icon: Icons.restaurant_menu_rounded, text: 'No meal slots added');
    }
    return Column(
      children: protocol.mealSlots.map((slot) {
        final totals = slot.totals;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceRaised,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.outlineSoft),
          ),
          child: Column(
            children: [
              // Meal header
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Row(
                  children: [
                    const Icon(Icons.restaurant_rounded,
                        size: 14, color: AppTheme.brand),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(slot.displayName,
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                          if (slot.timeOfDay.isNotEmpty)
                            Text(slot.timeOfDay,
                                style: const TextStyle(
                                    color: AppTheme.textTertiary,
                                    fontSize: 10)),
                        ],
                      ),
                    ),
                    if (totals.calories > 0) _MacroMiniBar(totals: totals),
                    const SizedBox(width: 6),
                    TnTPressable(
                      onTap: () {
                        context.read<ProgramBuilderBloc>().add(
                              ProgramBuilderMealSlotRemoved(slot.id),
                            );
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.close_rounded,
                            size: 14, color: AppTheme.textTertiary),
                      ),
                    ),
                  ],
                ),
              ),
              // Food items
              if (slot.foods.isNotEmpty) ...[
                Divider(height: 1, color: AppTheme.outlineSoft),
                ...slot.foods.map((food) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.fiber_manual_record,
                              size: 6, color: AppTheme.textTertiary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(food.name,
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11)),
                          ),
                          Text(
                              '${food.quantityG.round()}g  ·  ${food.calories.round()} kcal',
                              style: const TextStyle(
                                  color: AppTheme.textTertiary, fontSize: 10)),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _MacroMiniBar extends StatelessWidget {
  final MacroTarget totals;
  const _MacroMiniBar({required this.totals});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('${totals.calories.round()} kcal',
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
        Text(
            'P${totals.proteinG.round()}  C${totals.carbsG.round()}  F${totals.fatsG.round()}',
            style: const TextStyle(color: AppTheme.textTertiary, fontSize: 9)),
      ],
    );
  }
}

// ── Micronutrient List ────────────────────────────────────────────────────────

class _MicronutrientList extends StatelessWidget {
  final List<MicronutrientTarget> targets;
  const _MicronutrientList({required this.targets});

  @override
  Widget build(BuildContext context) {
    if (targets.isEmpty) {
      return _EmptyNote(
          icon: Icons.science_rounded, text: 'No micronutrient targets set');
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: targets.map((t) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF56CCF2).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: const Color(0xFF56CCF2).withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.science_rounded,
                  size: 10, color: Color(0xFF56CCF2)),
              const SizedBox(width: 5),
              Text('${t.nutrientName}: ${t.targetAmount} ${t.unit}',
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 6),
              TnTPressable(
                onTap: () {
                  final updated = context
                      .read<ProgramBuilderBloc>()
                      .state
                      .program
                      .nutritionProtocol;
                  context.read<ProgramBuilderBloc>().add(
                        ProgramBuilderNutritionChanged(
                          updated.copyWith(
                            micronutrientTargets: updated.micronutrientTargets
                                .where((m) => m.nutrientName != t.nutrientName)
                                .toList(),
                          ),
                        ),
                      );
                },
                borderRadius: BorderRadius.circular(4),
                child: const Icon(Icons.close_rounded,
                    size: 11, color: AppTheme.textTertiary),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ===========================================================================
// MEAL SLOT SHEET
// ===========================================================================

class _MealSlotSheet extends StatefulWidget {
  const _MealSlotSheet();

  @override
  State<_MealSlotSheet> createState() => _MealSlotSheetState();
}

class _MealSlotSheetState extends State<_MealSlotSheet> {
  MealSlotType _type = MealSlotType.breakfast;
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _timeCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(
                  child: Text('Add Meal Slot',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                ),
                TnTPressable(
                  onTap: _save,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                        color: AppTheme.brand,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Text('Add',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Slot type
            const _FormLabel('Meal Type'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: MealSlotType.values.map((t) {
                final sel = t == _type;
                return TnTPressable(
                  onTap: () => setState(() => _type = t),
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppTheme.brand.withValues(alpha: 0.15)
                          : AppTheme.surfaceRaised,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: sel
                              ? AppTheme.brand.withValues(alpha: 0.4)
                              : AppTheme.outlineSoft),
                    ),
                    child: Text(t.label,
                        style: TextStyle(
                            color:
                                sel ? AppTheme.brand : AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            const _FormLabel('Custom Name (optional)'),
            const SizedBox(height: 6),
            _InlineField(
                controller: _nameCtrl, hint: 'e.g. Post-Workout Shake'),
            const SizedBox(height: 12),
            const _FormLabel('Time of Day'),
            const SizedBox(height: 6),
            _InlineField(controller: _timeCtrl, hint: 'e.g. 07:30'),
          ],
        ),
      ),
    );
  }

  void _save() {
    final slot = MealSlot(
      id: 'slot_${DateTime.now().microsecondsSinceEpoch}',
      type: _type,
      customName: _nameCtrl.text.trim(),
      timeOfDay: _timeCtrl.text.trim(),
    );
    context.read<ProgramBuilderBloc>().add(ProgramBuilderMealSlotAdded(slot));
    Navigator.pop(context);
  }
}

// ===========================================================================
// CYCLE DAY SHEET
// ===========================================================================

class _CycleDaySheet extends StatefulWidget {
  final NutritionProtocol protocol;
  const _CycleDaySheet({required this.protocol});

  @override
  State<_CycleDaySheet> createState() => _CycleDaySheetState();
}

class _CycleDaySheetState extends State<_CycleDaySheet> {
  final _labelCtrl = TextEditingController(text: 'High Carb');
  final _calCtrl = TextEditingController();
  final _proCtrl = TextEditingController();
  final _carbCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();

  @override
  void dispose() {
    _labelCtrl.dispose();
    _calCtrl.dispose();
    _proCtrl.dispose();
    _carbCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(
                  child: Text('Add Cycle Day',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                ),
                TnTPressable(
                  onTap: _save,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                        color: AppTheme.brand,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Text('Add',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _FormLabel('Day Label'),
            const SizedBox(height: 6),
            _InlineField(controller: _labelCtrl, hint: 'e.g. High Carb'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _CompactMacroField(
                        ctrl: _calCtrl, label: 'Calories', unit: 'kcal')),
                const SizedBox(width: 8),
                Expanded(
                    child: _CompactMacroField(
                        ctrl: _proCtrl, label: 'Protein', unit: 'g')),
                const SizedBox(width: 8),
                Expanded(
                    child: _CompactMacroField(
                        ctrl: _carbCtrl, label: 'Carbs', unit: 'g')),
                const SizedBox(width: 8),
                Expanded(
                    child: _CompactMacroField(
                        ctrl: _fatCtrl, label: 'Fats', unit: 'g')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final day = MacroCycleDay(
      label: _labelCtrl.text.trim().isEmpty
          ? 'Day ${widget.protocol.cycleDays.length + 1}'
          : _labelCtrl.text.trim(),
      targets: MacroTarget(
        calories: double.tryParse(_calCtrl.text) ?? 0,
        proteinG: double.tryParse(_proCtrl.text) ?? 0,
        carbsG: double.tryParse(_carbCtrl.text) ?? 0,
        fatsG: double.tryParse(_fatCtrl.text) ?? 0,
      ),
    );
    final updated = widget.protocol
        .copyWith(cycleDays: [...widget.protocol.cycleDays, day]);
    context
        .read<ProgramBuilderBloc>()
        .add(ProgramBuilderNutritionChanged(updated));
    Navigator.pop(context);
  }
}

class _CompactMacroField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String unit;

  const _CompactMacroField({
    required this.ctrl,
    required this.label,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ($unit)',
              style: const TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 8,
                  fontWeight: FontWeight.w600)),
          TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: '0',
              hintStyle: TextStyle(color: AppTheme.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// MICRONUTRIENT SHEET
// ===========================================================================

class _MicronutrientSheet extends StatefulWidget {
  const _MicronutrientSheet();

  @override
  State<_MicronutrientSheet> createState() => _MicronutrientSheetState();
}

class _MicronutrientSheetState extends State<_MicronutrientSheet> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _unit = 'mg';

  static const _commonNutrients = [
    ('Vitamin D', 'µg'),
    ('Vitamin C', 'mg'),
    ('Vitamin B12', 'µg'),
    ('Zinc', 'mg'),
    ('Magnesium', 'mg'),
    ('Iron', 'mg'),
    ('Calcium', 'mg'),
    ('Omega-3', 'g'),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(
                  child: Text('Add Micronutrient',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                ),
                TnTPressable(
                  onTap: _save,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                        color: AppTheme.brand,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Text('Add',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Quick-pick
            const _FormLabel('Quick Pick'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _commonNutrients.map((pair) {
                return TnTPressable(
                  onTap: () {
                    setState(() {
                      _nameCtrl.text = pair.$1;
                      _unit = pair.$2;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF56CCF2).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color:
                              const Color(0xFF56CCF2).withValues(alpha: 0.25)),
                    ),
                    child: Text(pair.$1,
                        style: const TextStyle(
                            color: Color(0xFF56CCF2),
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FormLabel('Nutrient Name'),
                      const SizedBox(height: 6),
                      _InlineField(
                          controller: _nameCtrl, hint: 'e.g. Vitamin D'),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FormLabel('Amount'),
                      const SizedBox(height: 6),
                      _InlineField(controller: _amountCtrl, hint: '0'),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FormLabel('Unit'),
                    const SizedBox(height: 6),
                    DropdownButton<String>(
                      value: _unit,
                      dropdownColor: AppTheme.surfaceRaised,
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 13),
                      underline: const SizedBox.shrink(),
                      items: ['mg', 'µg', 'g', 'IU']
                          .map(
                              (u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _unit = v);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    if (name.isEmpty) return;
    final target = MicronutrientTarget(
        nutrientName: name, targetAmount: amount, unit: _unit);
    final protocol =
        context.read<ProgramBuilderBloc>().state.program.nutritionProtocol;
    context.read<ProgramBuilderBloc>().add(
          ProgramBuilderNutritionChanged(
            protocol.copyWith(
              micronutrientTargets: [...protocol.micronutrientTargets, target],
            ),
          ),
        );
    Navigator.pop(context);
  }
}

// ===========================================================================
// LIFESTYLE SECTION
// ===========================================================================

class LifestyleSection extends StatelessWidget {
  const LifestyleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgramBuilderBloc, ProgramBuilderState>(
      buildWhen: (p, c) =>
          p.program.lifestyleProtocol != c.program.lifestyleProtocol,
      builder: (context, state) {
        final lp = state.program.lifestyleProtocol;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sleep & NEAT
            _NutritionSubHeader(label: 'Sleep & NEAT'),
            const SizedBox(height: 10),
            _SleepNeatEditor(protocol: lp),
            const SizedBox(height: 20),

            // Cardio
            _NutritionSubHeader(
                label:
                    'Cardio Prescriptions (${lp.cardioPrescriptions.length})'),
            const SizedBox(height: 10),
            _CardioList(protocol: lp),
            const SizedBox(height: 8),
            _OutlineAddButton(
              label: 'Add Cardio Prescription',
              icon: Icons.directions_run_rounded,
              color: const Color(0xFF2F80ED),
              onTap: () => _openCardioSheet(context),
            ),
            const SizedBox(height: 20),

            // Mobility
            _NutritionSubHeader(
                label: 'Mobility & Recovery (${lp.mobilityRoutines.length})'),
            const SizedBox(height: 10),
            _MobilityList(protocol: lp),
            const SizedBox(height: 8),
            _OutlineAddButton(
              label: 'Add Mobility / Recovery Routine',
              icon: Icons.self_improvement_rounded,
              color: const Color(0xFF56CCF2),
              onTap: () => _openMobilitySheet(context),
            ),
          ],
        );
      },
    );
  }

  void _openCardioSheet(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => BlocProvider.value(
        value: context.read<ProgramBuilderBloc>(),
        child: const _CardioSheet(),
      ),
    );
  }

  void _openMobilitySheet(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => BlocProvider.value(
        value: context.read<ProgramBuilderBloc>(),
        child: const _MobilitySheet(),
      ),
    );
  }
}

// ── Sleep & NEAT Editor ───────────────────────────────────────────────────────

class _SleepNeatEditor extends StatefulWidget {
  final LifestyleProtocol protocol;
  const _SleepNeatEditor({required this.protocol});

  @override
  State<_SleepNeatEditor> createState() => _SleepNeatEditorState();
}

class _SleepNeatEditorState extends State<_SleepNeatEditor> {
  late double _sleep;
  late int _steps;

  @override
  void initState() {
    super.initState();
    _sleep = widget.protocol.sleepTargetHours;
    _steps = widget.protocol.neatStepsTarget;
  }

  void _commit() {
    context.read<ProgramBuilderBloc>().add(
          ProgramBuilderLifestyleChanged(
            widget.protocol
                .copyWith(sleepTargetHours: _sleep, neatStepsTarget: _steps),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sleep slider
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceRaised,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.outlineSoft),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bedtime_rounded,
                      size: 16, color: Color(0xFF7C4DFF)),
                  const SizedBox(width: 8),
                  const Text('Sleep Target',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('${_sleep.toStringAsFixed(1)} hrs',
                      style: const TextStyle(
                          color: Color(0xFF7C4DFF),
                          fontSize: 16,
                          fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 6),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF7C4DFF),
                  thumbColor: const Color(0xFF7C4DFF),
                  inactiveTrackColor: AppTheme.outlineSoft,
                  overlayColor: const Color(0xFF7C4DFF).withValues(alpha: 0.15),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _sleep,
                  min: 5,
                  max: 12,
                  divisions: 14,
                  onChanged: (v) => setState(() => _sleep = v),
                  onChangeEnd: (_) => _commit(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('5h',
                      style:
                          TextStyle(color: AppTheme.textTertiary, fontSize: 9)),
                  Text('7–9h recommended',
                      style:
                          TextStyle(color: AppTheme.textTertiary, fontSize: 9)),
                  Text('12h',
                      style:
                          TextStyle(color: AppTheme.textTertiary, fontSize: 9)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Steps stepper
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceRaised,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.outlineSoft),
          ),
          child: Row(
            children: [
              const Icon(Icons.directions_walk_rounded,
                  size: 16, color: Color(0xFF27AE60)),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daily Steps (NEAT)',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    Text('Non-Exercise Activity Thermogenesis',
                        style: TextStyle(
                            color: AppTheme.textTertiary, fontSize: 9)),
                  ],
                ),
              ),
              _StepsCounter(
                value: _steps,
                onChanged: (v) {
                  setState(() => _steps = v);
                  _commit();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepsCounter extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _StepsCounter({required this.value, required this.onChanged});

  static const _presets = [3000, 5000, 7500, 10000, 12500, 15000];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepBtn(
          icon: Icons.remove_rounded,
          enabled: value > 1000,
          onTap: () => onChanged((value - 1000).clamp(0, 20000)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            _formatSteps(value),
            style: const TextStyle(
                color: Color(0xFF27AE60),
                fontSize: 16,
                fontWeight: FontWeight.w900),
          ),
        ),
        _StepBtn(
          icon: Icons.add_rounded,
          enabled: value < 20000,
          onTap: () => onChanged((value + 1000).clamp(0, 20000)),
        ),
      ],
    );
  }

  String _formatSteps(int v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return '$v';
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
      onTap: enabled ? onTap : () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppTheme.surfaceLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.outlineSoft),
        ),
        child: Icon(icon,
            size: 14,
            color: enabled ? AppTheme.textPrimary : AppTheme.textTertiary),
      ),
    );
  }
}

// ── Cardio List ───────────────────────────────────────────────────────────────

class _CardioList extends StatelessWidget {
  final LifestyleProtocol protocol;
  const _CardioList({required this.protocol});

  @override
  Widget build(BuildContext context) {
    if (protocol.cardioPrescriptions.isEmpty) {
      return _EmptyNote(
          icon: Icons.directions_run_rounded, text: 'No cardio prescribed');
    }
    return Column(
      children: protocol.cardioPrescriptions.map((c) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2F80ED).withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: const Color(0xFF2F80ED).withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF2F80ED).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.directions_run_rounded,
                    size: 18, color: Color(0xFF2F80ED)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.type.label,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: [
                        _InfoLabel(
                            icon: Icons.timer_outlined,
                            text: '${c.durationMinutes} min'),
                        _InfoLabel(
                            icon: Icons.repeat_rounded,
                            text: '${c.sessionsPerWeek}x/week'),
                        if (c.targetHeartRateBpm != null)
                          _InfoLabel(
                              icon: Icons.favorite_rounded,
                              text: '~${c.targetHeartRateBpm} BPM'),
                        if (c.workRestRatio != null)
                          _InfoLabel(
                              icon: Icons.swap_vert_rounded,
                              text: c.workRestRatio!),
                      ],
                    ),
                    if (c.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(c.notes,
                          style: const TextStyle(
                              color: AppTheme.textTertiary,
                              fontSize: 10,
                              fontStyle: FontStyle.italic)),
                    ],
                  ],
                ),
              ),
              TnTPressable(
                onTap: () {
                  context.read<ProgramBuilderBloc>().add(
                        ProgramBuilderCardioRemoved(c.id),
                      );
                },
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close_rounded,
                      size: 14, color: AppTheme.textTertiary),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _InfoLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoLabel({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: AppTheme.textTertiary),
        const SizedBox(width: 3),
        Text(text,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
      ],
    );
  }
}

// ── Mobility List ─────────────────────────────────────────────────────────────

class _MobilityList extends StatelessWidget {
  final LifestyleProtocol protocol;
  const _MobilityList({required this.protocol});

  @override
  Widget build(BuildContext context) {
    if (protocol.mobilityRoutines.isEmpty) {
      return _EmptyNote(
          icon: Icons.self_improvement_rounded,
          text: 'No mobility routines defined');
    }
    return Column(
      children: protocol.mobilityRoutines.map((r) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF56CCF2).withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: const Color(0xFF56CCF2).withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.self_improvement_rounded,
                  size: 16, color: Color(0xFF56CCF2)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.name,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    if (r.targetAreas.isNotEmpty)
                      Text(r.targetAreas.join(' · '),
                          style: const TextStyle(
                              color: AppTheme.textTertiary, fontSize: 10)),
                  ],
                ),
              ),
              Text('${r.durationMinutes} min',
                  style: const TextStyle(
                      color: Color(0xFF56CCF2),
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
              const SizedBox(width: 6),
              TnTPressable(
                onTap: () {/* TODO: remove mobility */},
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close_rounded,
                      size: 14, color: AppTheme.textTertiary),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ===========================================================================
// CARDIO SHEET
// ===========================================================================

class _CardioSheet extends StatefulWidget {
  const _CardioSheet();

  @override
  State<_CardioSheet> createState() => _CardioSheetState();
}

class _CardioSheetState extends State<_CardioSheet> {
  CardioType _type = CardioType.liss;
  int _duration = 30;
  int _sessionsPerWeek = 3;
  final _hrCtrl = TextEditingController();
  final _workRestCtrl = TextEditingController(text: '1:2');
  final _roundsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _hrCtrl.dispose();
    _workRestCtrl.dispose();
    _roundsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  bool get _isHiit =>
      _type == CardioType.hiit ||
      _type == CardioType.emom ||
      _type == CardioType.tabata;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      builder: (_, sc) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SheetHandle(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Expanded(
                        child: Text('Add Cardio Prescription',
                            style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w800))),
                    TnTPressable(
                      onTap: _save,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                            color: AppTheme.brand,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Text('Add',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 20, color: AppTheme.outlineSoft),
          Expanded(
            child: ListView(
              controller: sc,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Cardio type
                const _FormLabel('Cardio Type'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: CardioType.values.map((t) {
                    final sel = t == _type;
                    return TnTPressable(
                      onTap: () => setState(() => _type = t),
                      borderRadius: BorderRadius.circular(8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: sel
                              ? const Color(0xFF2F80ED).withValues(alpha: 0.15)
                              : AppTheme.surfaceRaised,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: sel
                                  ? const Color(0xFF2F80ED)
                                      .withValues(alpha: 0.4)
                                  : AppTheme.outlineSoft),
                        ),
                        child: Text(t.label,
                            style: TextStyle(
                                color: sel
                                    ? const Color(0xFF2F80ED)
                                    : AppTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Duration & sessions
                Row(
                  children: [
                    Expanded(
                      child: _LabeledStepper(
                        label: 'Duration (min)',
                        value: _duration,
                        min: 5,
                        max: 120,
                        step: 5,
                        onChanged: (v) => setState(() => _duration = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LabeledStepper(
                        label: 'Sessions / week',
                        value: _sessionsPerWeek,
                        min: 1,
                        max: 7,
                        step: 1,
                        onChanged: (v) => setState(() => _sessionsPerWeek = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // HIIT-specific
                if (_isHiit) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FormLabel('Work:Rest Ratio'),
                            const SizedBox(height: 6),
                            _InlineField(
                                controller: _workRestCtrl, hint: '1:2'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FormLabel('Rounds'),
                            const SizedBox(height: 6),
                            _InlineField(controller: _roundsCtrl, hint: '8'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],

                // Target HR
                const _FormLabel('Target Heart Rate (BPM, optional)'),
                const SizedBox(height: 6),
                _InlineField(
                    controller: _hrCtrl, hint: 'e.g. 130', numeric: true),
                const SizedBox(height: 14),

                // Notes
                const _FormLabel('Notes'),
                const SizedBox(height: 6),
                _MultiLineField(
                    controller: _notesCtrl,
                    hint: 'e.g. Incline treadmill, low impact',
                    minLines: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    final cardio = CardioPrescription(
      id: 'cardio_${DateTime.now().microsecondsSinceEpoch}',
      type: _type,
      durationMinutes: _duration,
      sessionsPerWeek: _sessionsPerWeek,
      targetHeartRateBpm: int.tryParse(_hrCtrl.text),
      workRestRatio: _isHiit && _workRestCtrl.text.isNotEmpty
          ? _workRestCtrl.text.trim()
          : null,
      rounds: int.tryParse(_roundsCtrl.text),
      notes: _notesCtrl.text.trim(),
    );
    context.read<ProgramBuilderBloc>().add(ProgramBuilderCardioAdded(cardio));
    Navigator.pop(context);
  }
}

class _LabeledStepper extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  const _LabeledStepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormLabel(label),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.surfaceRaised,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.outlineSoft),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StepBtn(
                icon: Icons.remove_rounded,
                enabled: value > min,
                onTap: () => onChanged(value - step),
              ),
              Text('$value',
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800)),
              _StepBtn(
                icon: Icons.add_rounded,
                enabled: value < max,
                onTap: () => onChanged(value + step),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// MOBILITY SHEET
// ===========================================================================

class _MobilitySheet extends StatefulWidget {
  const _MobilitySheet();

  @override
  State<_MobilitySheet> createState() => _MobilitySheetState();
}

class _MobilitySheetState extends State<_MobilitySheet> {
  final _nameCtrl = TextEditingController();
  final _areasCtrl = TextEditingController();
  int _duration = 10;

  static const _presetRoutines = [
    'Morning Mobility Flow',
    'Hip Flexor Protocol',
    'Thoracic Mobility',
    'Shoulder Complex',
    'Ankle & Calf Work',
    'Full Body Stretch',
    'Foam Rolling Protocol',
    'Post-Workout Cooldown',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _areasCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(
                    child: Text('Add Mobility / Recovery',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800))),
                TnTPressable(
                  onTap: _save,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                        color: AppTheme.brand,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Text('Add',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Preset quick-pick
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _presetRoutines
                  .map((r) => TnTPressable(
                        onTap: () => setState(() => _nameCtrl.text = r),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF56CCF2).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFF56CCF2)
                                    .withValues(alpha: 0.25)),
                          ),
                          child: Text(r,
                              style: const TextStyle(
                                  color: Color(0xFF56CCF2),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 14),
            const _FormLabel('Routine Name'),
            const SizedBox(height: 6),
            _InlineField(
                controller: _nameCtrl, hint: 'e.g. Hip Flexor Protocol'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FormLabel('Target Areas (comma separated)'),
                      const SizedBox(height: 6),
                      _InlineField(
                          controller: _areasCtrl,
                          hint: 'e.g. Hip Flexors, Glutes'),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FormLabel('Duration'),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _StepBtn(
                          icon: Icons.remove_rounded,
                          enabled: _duration > 5,
                          onTap: () => setState(
                              () => _duration = (_duration - 5).clamp(5, 90)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text('${_duration}m',
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800)),
                        ),
                        _StepBtn(
                          icon: Icons.add_rounded,
                          enabled: _duration < 90,
                          onTap: () => setState(
                              () => _duration = (_duration + 5).clamp(5, 90)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final areas = _areasCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final routine = MobilityRoutine(
      id: 'mobility_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      durationMinutes: _duration,
      targetAreas: areas,
    );
    final updated = context
        .read<ProgramBuilderBloc>()
        .state
        .program
        .lifestyleProtocol
        .copyWith(mobilityRoutines: [
      ...context
          .read<ProgramBuilderBloc>()
          .state
          .program
          .lifestyleProtocol
          .mobilityRoutines,
      routine,
    ]);
    context
        .read<ProgramBuilderBloc>()
        .add(ProgramBuilderLifestyleChanged(updated));
    Navigator.pop(context);
  }
}

// ===========================================================================
// SUPPLEMENTATION SECTION
// ===========================================================================

class SupplementationSection extends StatelessWidget {
  const SupplementationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgramBuilderBloc, ProgramBuilderState>(
      buildWhen: (p, c) =>
          p.program.lifestyleProtocol.supplements !=
          c.program.lifestyleProtocol.supplements,
      builder: (context, state) {
        final supps = state.program.lifestyleProtocol.supplements;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (supps.isEmpty)
              _EmptyNote(
                  icon: Icons.medication_outlined,
                  text: 'No supplements added to this protocol')
            else
              ...supps.map((s) => _SupplementCard(supplement: s)),
            const SizedBox(height: 10),
            _OutlineAddButton(
              label: 'Add Supplement',
              icon: Icons.add_rounded,
              color: const Color(0xFF27AE60),
              onTap: () {
                HapticFeedback.selectionClick();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: AppTheme.bg,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(22))),
                  builder: (ctx) => BlocProvider.value(
                    value: context.read<ProgramBuilderBloc>(),
                    child: const _SupplementSheet(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _SupplementCard extends StatelessWidget {
  final SupplementEntry supplement;
  const _SupplementCard({required this.supplement});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF27AE60).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFF27AE60).withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF27AE60).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.medication_rounded,
                size: 18, color: Color(0xFF27AE60)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(supplement.name,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: [
                    if (supplement.dosage.isNotEmpty)
                      _InfoLabel(
                          icon: Icons.monitor_weight_outlined,
                          text: supplement.dosage),
                    if (supplement.timing.isNotEmpty)
                      _InfoLabel(
                          icon: Icons.schedule_rounded,
                          text: supplement.timing),
                    if (supplement.frequency.isNotEmpty)
                      _InfoLabel(
                          icon: Icons.loop_rounded, text: supplement.frequency),
                  ],
                ),
                if (supplement.purpose.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(supplement.purpose,
                        style: const TextStyle(
                            color: Color(0xFF27AE60),
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
          ),
          TnTPressable(
            onTap: () {
              context
                  .read<ProgramBuilderBloc>()
                  .add(ProgramBuilderSupplementRemoved(supplement.id));
            },
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close_rounded,
                  size: 14, color: AppTheme.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// SUPPLEMENT SHEET
// ===========================================================================

class _SupplementSheet extends StatefulWidget {
  const _SupplementSheet();

  @override
  State<_SupplementSheet> createState() => _SupplementSheetState();
}

class _SupplementSheetState extends State<_SupplementSheet> {
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _timingCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();
  String _frequency = 'Daily';

  static const _common = [
    ('Creatine', '5g', 'Post-workout / daily', 'Strength & Power'),
    ('Whey Protein', '30g', 'Post-workout', 'Muscle Protein Synthesis'),
    ('Vitamin D3', '2000 IU', 'Morning with food', 'Hormone & Immunity'),
    ('Omega-3', '3g', 'With meals', 'Joint Health & Recovery'),
    ('Magnesium', '400mg', 'Before bed', 'Sleep & Recovery'),
    ('Caffeine', '200mg', 'Pre-workout', 'Performance & Focus'),
    ('Beta-Alanine', '3.2g', 'Pre-workout', 'Endurance'),
    ('Zinc', '25mg', 'Before bed', 'Hormone Support'),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    _timingCtrl.dispose();
    _purposeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      builder: (_, sc) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                const Expanded(
                    child: Text('Add Supplement',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800))),
                TnTPressable(
                  onTap: _save,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                        color: AppTheme.brand,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Text('Add',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          const _SheetHandle(),
          Expanded(
            child: ListView(
              controller: sc,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Quick presets
                const _FormLabel('Common Supplements'),
                const SizedBox(height: 8),
                ...List.generate((_common.length / 2).ceil(), (row) {
                  final a = _common[row * 2];
                  final bIdx = row * 2 + 1;
                  final b = bIdx < _common.length ? _common[bIdx] : null;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(
                            child:
                                _PresetSuppTile(data: a, onTap: _fillPreset)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: b != null
                              ? _PresetSuppTile(data: b, onTap: _fillPreset)
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 14),
                Divider(color: AppTheme.outlineSoft),
                const SizedBox(height: 10),
                const _FormLabel('Supplement Name'),
                const SizedBox(height: 6),
                _InlineField(
                    controller: _nameCtrl, hint: 'e.g. Creatine Monohydrate'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FormLabel('Dosage'),
                          const SizedBox(height: 6),
                          _InlineField(
                              controller: _dosageCtrl, hint: 'e.g. 5g'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FormLabel('Timing'),
                          const SizedBox(height: 6),
                          _InlineField(
                              controller: _timingCtrl,
                              hint: 'e.g. Post-workout'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _FormLabel('Frequency'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ['Daily', 'Training Days', '3x/week', 'As needed']
                      .map((f) {
                    final sel = f == _frequency;
                    return TnTPressable(
                      onTap: () => setState(() => _frequency = f),
                      borderRadius: BorderRadius.circular(8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 130),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: sel
                              ? const Color(0xFF27AE60).withValues(alpha: 0.15)
                              : AppTheme.surfaceRaised,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: sel
                                  ? const Color(0xFF27AE60)
                                      .withValues(alpha: 0.4)
                                  : AppTheme.outlineSoft),
                        ),
                        child: Text(f,
                            style: TextStyle(
                                color: sel
                                    ? const Color(0xFF27AE60)
                                    : AppTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                const _FormLabel('Purpose'),
                const SizedBox(height: 6),
                _InlineField(
                    controller: _purposeCtrl,
                    hint: 'e.g. Muscle Protein Synthesis'),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _fillPreset((String, String, String, String) d) {
    setState(() {
      _nameCtrl.text = d.$1;
      _dosageCtrl.text = d.$2;
      _timingCtrl.text = d.$3;
      _purposeCtrl.text = d.$4;
    });
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final supp = SupplementEntry(
      id: 'supp_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      dosage: _dosageCtrl.text.trim(),
      timing: _timingCtrl.text.trim(),
      frequency: _frequency,
      purpose: _purposeCtrl.text.trim(),
    );
    context.read<ProgramBuilderBloc>().add(ProgramBuilderSupplementAdded(supp));
    Navigator.pop(context);
  }
}

class _PresetSuppTile extends StatelessWidget {
  final (String, String, String, String) data;
  final ValueChanged<(String, String, String, String)> onTap;

  const _PresetSuppTile({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TnTPressable(
      onTap: () => onTap(data),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceRaised,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.outlineSoft),
        ),
        child: Row(
          children: [
            const Icon(Icons.add_circle_outline_rounded,
                size: 14, color: Color(0xFF27AE60)),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.$1,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                  Text(data.$2,
                      style: const TextStyle(
                          color: AppTheme.textTertiary, fontSize: 9)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// SHARED HELPERS
// ===========================================================================

class _NutritionSubHeader extends StatelessWidget {
  final String label;
  const _NutritionSubHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
          color: AppTheme.textTertiary,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2),
    );
  }
}

class _OutlineAddButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _OutlineAddButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TnTPressable(
      onTap: onTap,
      pressedScale: 0.97,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 7),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _EmptyNote extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyNote({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.outlineSoft),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppTheme.textTertiary),
          const SizedBox(width: 8),
          Text(text,
              style:
                  const TextStyle(color: AppTheme.textTertiary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700));
  }
}

class _InlineField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool numeric;

  const _InlineField({
    required this.controller,
    required this.hint,
    this.numeric = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.outlineSoft),
      ),
      child: TextField(
        controller: controller,
        keyboardType: numeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(color: AppTheme.textTertiary, fontSize: 13),
          border: InputBorder.none,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
      ),
    );
  }
}

// Reuse _StepBtn from training section (avoid duplication in real project)
class ClientBaselineSection extends StatelessWidget {
  const ClientBaselineSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgramBuilderBloc, ProgramBuilderState>(
      buildWhen: (p, c) => p.baseline != c.baseline,
      builder: (context, state) {
        final b = state.baseline;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Biometrics grid ──────────────────────────────────────────────
            _SubHeader('Biometrics'),
            const SizedBox(height: 10),
            _BiometricGrid(baseline: b),
            const SizedBox(height: 8),
            _InlineTextButton(
              label: 'Edit biometrics',
              icon: Icons.edit_rounded,
              onTap: () => _openBiometricsSheet(context, b),
            ),
            const SizedBox(height: 18),

            // ── Metabolic calculations ───────────────────────────────────────
            _SubHeader('Metabolic Calculations'),
            const SizedBox(height: 10),
            _MetabolicStrip(
              bmr: state.bmr,
              tdee: state.tdee,
              lbm: state.lbm,
              bmi: state.bmi,
            ),
            const SizedBox(height: 8),
            _MetabolicFormulaBanner(),
            const SizedBox(height: 18),

            // ── Goals ─────────────────────────────────────────────────────────
            _SubHeader('Primary Goal'),
            const SizedBox(height: 8),
            _GoalEditor(baseline: b),
            const SizedBox(height: 18),

            // ── Dietary restrictions ──────────────────────────────────────────
            _SubHeader('Dietary Restrictions & Allergies'),
            const SizedBox(height: 8),
            _DietaryChipRow(baseline: b),
            const SizedBox(height: 18),

            // ── Medical limitations ───────────────────────────────────────────
            _SubHeader('Medical Limitations'),
            const SizedBox(height: 8),
            if (b.medicalLimitations.isEmpty)
              _EmptyCard(
                icon: Icons.health_and_safety_rounded,
                label: 'No medical limitations recorded',
              )
            else
              ...b.medicalLimitations.map(
                (l) => _LimitationRow(
                  limitation: l,
                  onRemove: () => context
                      .read<ProgramBuilderBloc>()
                      .add(ProgramBuilderMedicalLimitationRemoved(l.id)),
                ),
              ),
            const SizedBox(height: 8),
            _OutlinedAddBtn(
              label: 'Add Medical Limitation',
              color: const Color(0xFFEB5757),
              onTap: () => _openLimitationSheet(context),
            ),

            // ── Trainer notes ─────────────────────────────────────────────────
            const SizedBox(height: 18),
            _SubHeader('Trainer Notes (Baseline)'),
            const SizedBox(height: 8),
            _TrainerNotesField(baseline: b),
          ],
        );
      },
    );
  }

  void _openBiometricsSheet(BuildContext context, ClientBaseline b) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => BlocProvider.value(
        value: context.read<ProgramBuilderBloc>(),
        child: _BiometricsEditSheet(baseline: b),
      ),
    );
  }

  void _openLimitationSheet(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => BlocProvider.value(
        value: context.read<ProgramBuilderBloc>(),
        child: const _LimitationSheet(),
      ),
    );
  }
}

// ── Biometric grid ────────────────────────────────────────────────────────────

class _BiometricGrid extends StatelessWidget {
  final ClientBaseline baseline;

  const _BiometricGrid({required this.baseline});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _BiometricCell(
        label: 'Age',
        value: baseline.ageYears > 0 ? '${baseline.ageYears}' : '-',
        unit: 'yrs',
      ),
      _BiometricCell(
        label: 'Sex',
        value: _sexLabel(baseline.sex),
        unit: '',
      ),
      _BiometricCell(
        label: 'Height',
        value:
            baseline.heightCm > 0 ? baseline.heightCm.toStringAsFixed(1) : '-',
        unit: 'cm',
      ),
      _BiometricCell(
        label: 'Weight',
        value:
            baseline.weightKg > 0 ? baseline.weightKg.toStringAsFixed(1) : '-',
        unit: 'kg',
      ),
      _BiometricCell(
        label: 'Body Fat',
        value: baseline.bodyFatPercent > 0
            ? baseline.bodyFatPercent.toStringAsFixed(1)
            : '-',
        unit: '%',
      ),
      _BiometricCell(
        label: 'Activity',
        value: _activityLabel(baseline.activityLevel),
        unit: '',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 620 ? 3 : 2;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: columns == 3 ? 2.8 : 2.4,
          children: tiles,
        );
      },
    );
  }

  String _sexLabel(BiologicalSex sex) {
    switch (sex) {
      case BiologicalSex.male:
        return 'Male';
      case BiologicalSex.female:
        return 'Female';
      case BiologicalSex.other:
        return 'Other';
    }
  }

  String _activityLabel(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 'Sedentary';
      case ActivityLevel.lightlyActive:
        return 'Light';
      case ActivityLevel.moderatelyActive:
        return 'Moderate';
      case ActivityLevel.veryActive:
        return 'Very Active';
      case ActivityLevel.extraActive:
        return 'Extra Active';
    }
  }
}

class _BiometricCell extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _BiometricCell(
      {required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 9,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: value,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800)),
              if (unit.isNotEmpty)
                TextSpan(
                    text: ' $unit',
                    style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w500)),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Metabolic strip ───────────────────────────────────────────────────────────

class _MetabolicStrip extends StatelessWidget {
  final double bmr;
  final double tdee;
  final double lbm;
  final double bmi;

  const _MetabolicStrip({
    required this.bmr,
    required this.tdee,
    required this.lbm,
    required this.bmi,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MetCard(
          label: 'BMR',
          value: bmr > 0 ? '${bmr.round()}' : '-',
          unit: 'kcal',
        ),
        const SizedBox(width: 8),
        _MetCard(
          label: 'TDEE',
          value: tdee > 0 ? '${tdee.round()}' : '-',
          unit: 'kcal',
          highlight: true,
        ),
        const SizedBox(width: 8),
        _MetCard(
          label: 'LBM',
          value: lbm > 0 ? lbm.toStringAsFixed(1) : '-',
          unit: 'kg',
        ),
        const SizedBox(width: 8),
        _MetCard(
          label: 'BMI',
          value: bmi > 0 ? bmi.toStringAsFixed(1) : '-',
          unit: '',
          bmiValue: bmi > 0 ? bmi : null,
        ),
      ],
    );
  }
}

class _MetCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final bool highlight;
  final double? bmiValue;

  const _MetCard({
    required this.label,
    required this.value,
    required this.unit,
    this.highlight = false,
    this.bmiValue,
  });

  @override
  Widget build(BuildContext context) {
    final color = bmiValue != null
        ? _bmiColor(bmiValue!)
        : highlight
            ? AppTheme.brand
            : AppTheme.textSecondary;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 9, fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 16, fontWeight: FontWeight.w900)),
            if (unit.isNotEmpty)
              Text(unit,
                  style: const TextStyle(
                      color: AppTheme.textTertiary, fontSize: 9)),
            if (bmiValue != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(_bmiLabel(bmiValue!),
                    style: TextStyle(
                        color: color,
                        fontSize: 8,
                        fontWeight: FontWeight.w700)),
              ),
          ],
        ),
      ),
    );
  }

  Color _bmiColor(double v) {
    if (v < 18.5) return const Color(0xFF56CCF2);
    if (v < 25) return const Color(0xFF27AE60);
    if (v < 30) return const Color(0xFFF2C94C);
    return const Color(0xFFEB5757);
  }

  String _bmiLabel(double v) {
    if (v < 18.5) return 'Underweight';
    if (v < 25) return 'Normal';
    if (v < 30) return 'Overweight';
    return 'Obese';
  }
}

class _MetabolicFormulaBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.brand.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.brand.withValues(alpha: 0.12)),
      ),
      child: const Text(
        'BMR via Mifflin–St Jeor  ·  TDEE = BMR × activity multiplier  ·  LBM = weight × (1 − BF%)',
        style: TextStyle(
            color: AppTheme.textTertiary,
            fontSize: 9,
            fontStyle: FontStyle.italic),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ── Goal editor ───────────────────────────────────────────────────────────────

class _GoalEditor extends StatefulWidget {
  final ClientBaseline baseline;
  const _GoalEditor({required this.baseline});

  @override
  State<_GoalEditor> createState() => _GoalEditorState();
}

class _GoalEditorState extends State<_GoalEditor> {
  late final TextEditingController _ctrl;

  static const _presets = [
    'Muscle Gain',
    'Fat Loss',
    'Strength',
    'General Fitness',
    'Athletic Performance',
    'Endurance',
    'Recomposition',
    'Maintenance',
    'Post-Rehab',
    'Sport-Specific',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.baseline.primaryGoal);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _commit(String value) {
    context.read<ProgramBuilderBloc>().add(
          ProgramBuilderBaselineUpdated(
            widget.baseline.copyWith(primaryGoal: value),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FlatTextField(
          controller: _ctrl,
          hint: 'e.g. Muscle Gain',
          onSubmitted: _commit,
          onTapOutside: () => _commit(_ctrl.text.trim()),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _presets.map((p) {
            final sel = p == widget.baseline.primaryGoal;
            return _ToggleChipSmall(
              label: p,
              selected: sel,
              onTap: () {
                _ctrl.text = p;
                _commit(p);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Dietary restrictions ──────────────────────────────────────────────────────

class _DietaryChipRow extends StatelessWidget {
  final ClientBaseline baseline;

  const _DietaryChipRow({required this.baseline});

  static const _restrictionOptions = [
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Lactose-Free',
    'Halal',
    'Kosher',
    'Nut-Free',
    'Low-FODMAP',
    'Keto',
    'Paleo',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _restrictionOptions.map((r) {
        final active = baseline.dietaryRestrictions.contains(r);
        return _ToggleChipSmall(
          label: r,
          selected: active,
          color: const Color(0xFF27AE60),
          onTap: () {
            final updated = List<String>.from(baseline.dietaryRestrictions);
            if (active) {
              updated.remove(r);
            } else {
              updated.add(r);
            }
            context.read<ProgramBuilderBloc>().add(
                  ProgramBuilderBaselineUpdated(
                      baseline.copyWith(dietaryRestrictions: updated)),
                );
          },
        );
      }).toList(),
    );
  }
}

// ── Trainer notes field ───────────────────────────────────────────────────────

class _TrainerNotesField extends StatefulWidget {
  final ClientBaseline baseline;
  const _TrainerNotesField({required this.baseline});

  @override
  State<_TrainerNotesField> createState() => _TrainerNotesFieldState();
}

class _TrainerNotesFieldState extends State<_TrainerNotesField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.baseline.trainerNotes);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FlatTextField(
      controller: _ctrl,
      hint:
          'Internal notes about this client\'s baseline — not visible to client',
      minLines: 3,
      onTapOutside: () {
        context.read<ProgramBuilderBloc>().add(
              ProgramBuilderBaselineUpdated(
                widget.baseline.copyWith(trainerNotes: _ctrl.text.trim()),
              ),
            );
      },
    );
  }
}

// ── Limitation row ────────────────────────────────────────────────────────────

class _LimitationRow extends StatelessWidget {
  final MedicalLimitation limitation;
  final VoidCallback onRemove;

  const _LimitationRow({required this.limitation, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEB5757).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: const Color(0xFFEB5757).withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 14, color: Color(0xFFEB5757)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(limitation.condition,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
                if (limitation.affectedBodyPart.isNotEmpty)
                  Text('Affects: ${limitation.affectedBodyPart}',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 10)),
                if (limitation.restrictedExercises.isNotEmpty)
                  Text(
                      'Restricted: ${limitation.restrictedExercises.join(', ')}',
                      style: const TextStyle(
                          color: AppTheme.textTertiary, fontSize: 10)),
                if (limitation.notes.isNotEmpty)
                  Text(limitation.notes,
                      style: const TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 10,
                          fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          TnTPressable(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close_rounded,
                  size: 14, color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// BIOMETRICS EDIT SHEET
// ===========================================================================

class _BiometricsEditSheet extends StatefulWidget {
  final ClientBaseline baseline;
  const _BiometricsEditSheet({required this.baseline});

  @override
  State<_BiometricsEditSheet> createState() => _BiometricsEditSheetState();
}

class _BiometricsEditSheetState extends State<_BiometricsEditSheet> {
  late BiologicalSex _sex;
  late ActivityLevel _activity;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _bfCtrl;
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    final b = widget.baseline;
    _sex = b.sex;
    _activity = b.activityLevel;
    _ageCtrl =
        TextEditingController(text: b.ageYears > 0 ? '${b.ageYears}' : '');
    _heightCtrl = TextEditingController(
        text: b.heightCm > 0 ? b.heightCm.toStringAsFixed(1) : '');
    _weightCtrl = TextEditingController(
        text: b.weightKg > 0 ? b.weightKg.toStringAsFixed(1) : '');
    _bfCtrl = TextEditingController(
        text: b.bodyFatPercent > 0 ? b.bodyFatPercent.toStringAsFixed(1) : '');
    _nameCtrl = TextEditingController(text: b.clientName);
  }

  @override
  void dispose() {
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _bfCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final updated = widget.baseline.copyWith(
      clientName: _nameCtrl.text.trim(),
      ageYears: int.tryParse(_ageCtrl.text) ?? widget.baseline.ageYears,
      heightCm: double.tryParse(_heightCtrl.text) ?? widget.baseline.heightCm,
      weightKg: double.tryParse(_weightCtrl.text) ?? widget.baseline.weightKg,
      bodyFatPercent:
          double.tryParse(_bfCtrl.text) ?? widget.baseline.bodyFatPercent,
      sex: _sex,
      activityLevel: _activity,
    );
    context
        .read<ProgramBuilderBloc>()
        .add(ProgramBuilderBaselineUpdated(updated));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.82,
          maxChildSize: 0.95,
          builder: (_, sc) => Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: [
                    const _SheetHandle(),
                    const Expanded(
                      child: Text('Edit Client Biometrics',
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800)),
                    ),
                    TnTPressable(
                      onTap: _save,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 9),
                        decoration: BoxDecoration(
                            color: AppTheme.brand,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Text('Save',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView(
                  controller: sc,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Client name
                    _FLabel('Client Name'),
                    const SizedBox(height: 6),
                    _FlatTextField(controller: _nameCtrl, hint: 'Full name'),
                    const SizedBox(height: 14),

                    // Numeric fields grid
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FLabel('Age (years)'),
                              const SizedBox(height: 6),
                              _FlatTextField(
                                  controller: _ageCtrl,
                                  hint: '25',
                                  numeric: true),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FLabel('Height (cm)'),
                              const SizedBox(height: 6),
                              _FlatTextField(
                                  controller: _heightCtrl,
                                  hint: '175.0',
                                  numeric: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FLabel('Weight (kg)'),
                              const SizedBox(height: 6),
                              _FlatTextField(
                                  controller: _weightCtrl,
                                  hint: '80.0',
                                  numeric: true),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FLabel('Body Fat (%)'),
                              const SizedBox(height: 6),
                              _FlatTextField(
                                  controller: _bfCtrl,
                                  hint: '15.0',
                                  numeric: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Sex
                    _FLabel('Biological Sex'),
                    const SizedBox(height: 8),
                    Row(
                      children: BiologicalSex.values.map((s) {
                        final sel = s == _sex;
                        final label = s == BiologicalSex.male
                            ? 'Male'
                            : s == BiologicalSex.female
                                ? 'Female'
                                : 'Other';
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: TnTPressable(
                              onTap: () => setState(() => _sex = s),
                              borderRadius: BorderRadius.circular(10),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 140),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: sel
                                      ? AppTheme.brand.withValues(alpha: 0.14)
                                      : AppTheme.surfaceRaised,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: sel
                                          ? AppTheme.brand
                                              .withValues(alpha: 0.45)
                                          : AppTheme.outlineSoft),
                                ),
                                child: Text(label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: sel
                                            ? AppTheme.brand
                                            : AppTheme.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Activity level
                    _FLabel('Activity Level'),
                    const SizedBox(height: 8),
                    ...ActivityLevel.values.map((a) {
                      final sel = a == _activity;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: TnTPressable(
                          onTap: () => setState(() => _activity = a),
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 140),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 11),
                            decoration: BoxDecoration(
                              color: sel
                                  ? AppTheme.brand.withValues(alpha: 0.1)
                                  : AppTheme.surfaceRaised,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: sel
                                      ? AppTheme.brand.withValues(alpha: 0.4)
                                      : AppTheme.outlineSoft),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(a.label,
                                      style: TextStyle(
                                          color: sel
                                              ? AppTheme.brand
                                              : AppTheme.textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                ),
                                Text('×${a.multiplier}',
                                    style: TextStyle(
                                        color: sel
                                            ? AppTheme.brand
                                            : AppTheme.textTertiary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// LIMITATION SHEET
// ===========================================================================

class _LimitationSheet extends StatefulWidget {
  const _LimitationSheet();

  @override
  State<_LimitationSheet> createState() => _LimitationSheetState();
}

class _LimitationSheetState extends State<_LimitationSheet> {
  final _condCtrl = TextEditingController();
  final _partCtrl = TextEditingController();
  final _restCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  static const _commonConditions = [
    'Lower Back Pain',
    'Knee Injury',
    'Shoulder Impingement',
    'Rotator Cuff',
    'Herniated Disc',
    'Hip Labral Tear',
    'Plantar Fasciitis',
    'Wrist Pain',
    'Achilles Tendinopathy',
  ];

  @override
  void dispose() {
    _condCtrl.dispose();
    _partCtrl.dispose();
    _restCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(
                  child: Text('Add Medical Limitation',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                ),
                TnTPressable(
                  onTap: _save,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                        color: const Color(0xFFEB5757),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Text('Add',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _commonConditions
                  .map((c) => TnTPressable(
                        onTap: () => setState(() => _condCtrl.text = c),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFEB5757).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFFEB5757)
                                    .withValues(alpha: 0.2)),
                          ),
                          child: Text(c,
                              style: const TextStyle(
                                  color: Color(0xFFEB5757),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 14),
            _FLabel('Condition'),
            const SizedBox(height: 6),
            _FlatTextField(controller: _condCtrl, hint: 'e.g. Lower Back Pain'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FLabel('Affected Body Part'),
                        const SizedBox(height: 6),
                        _FlatTextField(
                            controller: _partCtrl, hint: 'e.g. Lumbar'),
                      ]),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FLabel('Restricted Exercises'),
                        const SizedBox(height: 6),
                        _FlatTextField(
                            controller: _restCtrl, hint: 'comma separated'),
                      ]),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _FLabel('Notes'),
            const SizedBox(height: 6),
            _FlatTextField(
                controller: _notesCtrl,
                hint: 'Additional context for this limitation'),
          ],
        ),
      ),
    );
  }

  void _save() {
    final cond = _condCtrl.text.trim();
    if (cond.isEmpty) return;
    final restricted = _restCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    context.read<ProgramBuilderBloc>().add(
          ProgramBuilderMedicalLimitationAdded(MedicalLimitation(
            id: 'limit_${DateTime.now().microsecondsSinceEpoch}',
            condition: cond,
            affectedBodyPart: _partCtrl.text.trim(),
            restrictedExercises: restricted,
            notes: _notesCtrl.text.trim(),
          )),
        );
    Navigator.pop(context);
  }
}

// ===========================================================================
// SECTION 7 – ADMIN (final)
// ===========================================================================

class AdminSection extends StatelessWidget {
  const AdminSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgramBuilderBloc, ProgramBuilderState>(
      buildWhen: (p, c) =>
          p.program.status != c.program.status ||
          p.program.isTemplate != c.program.isTemplate ||
          p.program.progressionRules != c.program.progressionRules ||
          p.saveStatus != c.saveStatus,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status toggles
            _SubHeader('Visibility & Status'),
            const SizedBox(height: 10),
            _ToggleRow(
              icon: Icons.publish_rounded,
              label: 'Published',
              subtitle: state.program.status == ProgramStatus.published
                  ? 'Visible to client'
                  : 'Saved as draft – not yet visible',
              value: state.program.status == ProgramStatus.published,
              activeColor: const Color(0xFF27AE60),
              onChanged: (_) => context
                  .read<ProgramBuilderBloc>()
                  .add(const ProgramBuilderPublishToggled()),
            ),
            const SizedBox(height: 8),
            _ToggleRow(
              icon: Icons.bookmark_rounded,
              label: 'Save as Template',
              subtitle: 'Reuse this structure for new clients',
              value: state.program.isTemplate,
              activeColor: AppTheme.brand,
              onChanged: (v) => context
                  .read<ProgramBuilderBloc>()
                  .add(ProgramBuilderMetaChanged(isTemplate: v)),
            ),
            const SizedBox(height: 20),

            // Progression rules
            _SubHeader('Auto-Regulation & Progression Rules'),
            const SizedBox(height: 10),
            ProgressionRulesSection(rules: state.program.progressionRules),
            const SizedBox(height: 20),

            // Import / export
            _SubHeader('Import / Export'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ActionBtn(
                    icon: Icons.upload_file_rounded,
                    label: 'Import Program',
                    color: const Color(0xFF2F80ED),
                    onTap: () {/* TODO: pick JSON / template */},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionBtn(
                    icon: Icons.download_rounded,
                    label: 'Export as JSON',
                    color: const Color(0xFF27AE60),
                    onTap: () {
                      final json = context
                          .read<ProgramBuilderBloc>()
                          .state
                          .program
                          .toJson()
                          .toString();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Exported to clipboard (stub)'),
                          backgroundColor: AppTheme.surfaceRaised,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Danger zone
            _SubHeader('Danger Zone'),
            const SizedBox(height: 10),
            _DangerZone(),
          ],
        );
      },
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: value
            ? activeColor.withValues(alpha: 0.07)
            : AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: value
                ? activeColor.withValues(alpha: 0.3)
                : AppTheme.outlineSoft),
      ),
      child: Row(
        children: [
          Icon(icon,
              size: 16, color: value ? activeColor : AppTheme.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: value ? activeColor : AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppTheme.textTertiary, fontSize: 10)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: activeColor),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TnTPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 7),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEB5757).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFEB5757).withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 14, color: Color(0xFFEB5757)),
              SizedBox(width: 6),
              Text('Destructive Actions',
                  style: TextStyle(
                      color: Color(0xFFEB5757),
                      fontSize: 12,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TnTPressable(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    _confirmReset(context);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEB5757).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color:
                              const Color(0xFFEB5757).withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_forever_rounded,
                            size: 14, color: Color(0xFFEB5757)),
                        SizedBox(width: 6),
                        Text('Reset Program',
                            style: TextStyle(
                                color: Color(0xFFEB5757),
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceRaised,
        title: const Text('Reset Program?',
            style: TextStyle(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w800)),
        content: const Text(
            'This will clear all training days, nutrition, and lifestyle data. This cannot be undone.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<ProgramBuilderBloc>()
                  .add(const ProgramBuilderResetRequested());
            },
            child: const Text('Reset',
                style: TextStyle(
                    color: Color(0xFFEB5757), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// PROGRESSION RULES SECTION
// ===========================================================================

class ProgressionRulesSection extends StatelessWidget {
  final List<ProgressionRule> rules;
  const ProgressionRulesSection({super.key, required this.rules});

  static const _presets = [
    (
      'Double Progression',
      'All sets completed at top of rep range for 2 consecutive sessions',
      'Increase load by 2.5 kg next session',
    ),
    (
      'Rep PR',
      'Achieved a rep PR on the top set',
      'Keep load, push for another PR next session',
    ),
    (
      'RPE Autoregulation',
      'RPE consistently below target by ≥1 for 2 sessions',
      'Increase load by 1–2.5 kg',
    ),
    (
      'Deload Trigger',
      'Missed reps on 2+ exercises for 2 consecutive sessions',
      'Reduce load by 10% and deload for 1 week',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (rules.isEmpty)
          _EmptyCard(
            icon: Icons.trending_up_rounded,
            label: 'No progression rules — add auto-regulation logic',
          )
        else
          ...rules.map((r) => _RuleCard(rule: r)),
        const SizedBox(height: 10),

        // Preset quick-add
        _SubHeader('Preset Rules'),
        const SizedBox(height: 8),
        ..._presets.map((p) => _PresetRuleTile(
              title: p.$1,
              trigger: p.$2,
              action: p.$3,
              onAdd: () {
                context.read<ProgramBuilderBloc>().add(
                      ProgramBuilderProgressionRuleAdded(ProgressionRule(
                        id: 'rule_${DateTime.now().microsecondsSinceEpoch}',
                        trigger: p.$2,
                        action: p.$3,
                        notes: p.$1,
                      )),
                    );
              },
            )),
        const SizedBox(height: 8),
        _OutlinedAddBtn(
          label: 'Add Custom Rule',
          color: AppTheme.brand,
          onTap: () {
            HapticFeedback.selectionClick();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: AppTheme.bg,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(22))),
              builder: (ctx) => BlocProvider.value(
                value: context.read<ProgramBuilderBloc>(),
                child: const _ProgressionRuleSheet(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _RuleCard extends StatelessWidget {
  final ProgressionRule rule;
  const _RuleCard({required this.rule});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.brand.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.brand.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.brand.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.trending_up_rounded,
                size: 14, color: AppTheme.brand),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (rule.notes.isNotEmpty)
                  Text(rule.notes,
                      style: const TextStyle(
                          color: AppTheme.brand,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                _RuleClause(
                    prefix: 'IF',
                    text: rule.trigger,
                    color: const Color(0xFFF2C94C)),
                const SizedBox(height: 3),
                _RuleClause(
                    prefix: 'THEN',
                    text: rule.action,
                    color: const Color(0xFF27AE60)),
              ],
            ),
          ),
          TnTPressable(
            onTap: () => context
                .read<ProgramBuilderBloc>()
                .add(ProgramBuilderProgressionRuleRemoved(rule.id)),
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close_rounded,
                  size: 14, color: AppTheme.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleClause extends StatelessWidget {
  final String prefix;
  final String text;
  final Color color;

  const _RuleClause(
      {required this.prefix, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          margin: const EdgeInsets.only(right: 6, top: 1),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(prefix,
              style: TextStyle(
                  color: color, fontSize: 8, fontWeight: FontWeight.w800)),
        ),
        Expanded(
          child: Text(text,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        ),
      ],
    );
  }
}

class _PresetRuleTile extends StatelessWidget {
  final String title;
  final String trigger;
  final String action;
  final VoidCallback onAdd;

  const _PresetRuleTile({
    required this.title,
    required this.trigger,
    required this.action,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return TnTPressable(
      onTap: onAdd,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceRaised,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.outlineSoft),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('IF: $trigger',
                      style: const TextStyle(
                          color: AppTheme.textTertiary, fontSize: 9),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.add_circle_outline_rounded,
                size: 18, color: AppTheme.brand),
          ],
        ),
      ),
    );
  }
}

class _ProgressionRuleSheet extends StatefulWidget {
  const _ProgressionRuleSheet();

  @override
  State<_ProgressionRuleSheet> createState() => _ProgressionRuleSheetState();
}

class _ProgressionRuleSheetState extends State<_ProgressionRuleSheet> {
  final _triggerCtrl = TextEditingController();
  final _actionCtrl = TextEditingController();
  final _labelCtrl = TextEditingController();

  @override
  void dispose() {
    _triggerCtrl.dispose();
    _actionCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(
                  child: Text('Custom Progression Rule',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                ),
                TnTPressable(
                  onTap: _save,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                        color: AppTheme.brand,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Text('Add',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _FLabel('Rule Label (optional)'),
            const SizedBox(height: 6),
            _FlatTextField(
                controller: _labelCtrl, hint: 'e.g. Double Progression'),
            const SizedBox(height: 12),
            _FLabel('IF (trigger condition)'),
            const SizedBox(height: 6),
            _FlatTextField(
              controller: _triggerCtrl,
              hint:
                  'e.g. All sets completed at top of rep range for 2 sessions',
              minLines: 2,
            ),
            const SizedBox(height: 12),
            _FLabel('THEN (action)'),
            const SizedBox(height: 6),
            _FlatTextField(
              controller: _actionCtrl,
              hint: 'e.g. Increase load by 2.5 kg next session',
              minLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final trigger = _triggerCtrl.text.trim();
    final action = _actionCtrl.text.trim();
    if (trigger.isEmpty || action.isEmpty) return;
    context.read<ProgramBuilderBloc>().add(
          ProgramBuilderProgressionRuleAdded(ProgressionRule(
            id: 'rule_${DateTime.now().microsecondsSinceEpoch}',
            trigger: trigger,
            action: action,
            notes: _labelCtrl.text.trim(),
          )),
        );
    Navigator.pop(context);
  }
}

// ===========================================================================
// SECTION 6 – ANALYTICS SUMMARY (final / upgraded)
// ===========================================================================

class AnalyticsSummarySection extends StatelessWidget {
  const AnalyticsSummarySection({super.key});

  // MEV = Minimum Effective Volume, MRV = Maximum Recoverable Volume
  // Values from Israetel et al. – rough heuristics for display only
  static const _mev = <String, int>{
    'Chest': 10,
    'Back': 10,
    'Shoulders': 8,
    'Biceps': 8,
    'Triceps': 6,
    'Quads': 8,
    'Hamstrings': 6,
    'Glutes': 8,
    'Calves': 8,
    'Abs': 10,
    'Lats': 10,
    'Trapezius': 8,
    'Forearms': 6,
  };
  static const _mrv = <String, int>{
    'Chest': 22,
    'Back': 25,
    'Shoulders': 26,
    'Biceps': 26,
    'Triceps': 22,
    'Quads': 25,
    'Hamstrings': 20,
    'Glutes': 20,
    'Calves': 16,
    'Abs': 25,
    'Lats': 25,
    'Trapezius': 20,
    'Forearms': 20,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgramBuilderBloc, ProgramBuilderState>(
      builder: (context, state) {
        final volume = state.weeklySetVolumePerMuscleGroup;
        final macros = state.macroTargets;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Macro summary ────────────────────────────────────────────────
            _SubHeader('Macro Distribution'),
            const SizedBox(height: 12),
            _FullMacroPie(
              protein: state.proteinCaloriePercent,
              carbs: state.carbCaloriePercent,
              fat: state.fatCaloriePercent,
              targets: macros,
            ),
            const SizedBox(height: 20),

            // ── Volume per muscle ────────────────────────────────────────────
            _SubHeader('Weekly Set Volume per Muscle Group'),
            const SizedBox(height: 6),
            const Text(
              'Green = within MEV–MRV  ·  Yellow = below MEV  ·  Red = above MRV',
              style: TextStyle(color: AppTheme.textTertiary, fontSize: 9),
            ),
            const SizedBox(height: 10),
            if (volume.isEmpty)
              _EmptyCard(
                icon: Icons.stacked_bar_chart_rounded,
                label: 'Add exercises to see weekly volume',
              )
            else
              _VolumeTable(volume: volume, mev: _mev, mrv: _mrv),
            const SizedBox(height: 20),

            // ── Summary KPIs ─────────────────────────────────────────────────
            _SubHeader('Program KPIs'),
            const SizedBox(height: 10),
            _KpiGrid(state: state),
            const SizedBox(height: 20),

            // ── Metabolic recap ───────────────────────────────────────────────
            _SubHeader('Metabolic Recap'),
            const SizedBox(height: 10),
            _MetabolicStrip(
              bmr: state.bmr,
              tdee: state.tdee,
              lbm: state.lbm,
              bmi: state.bmi,
            ),
          ],
        );
      },
    );
  }
}

class _FullMacroPie extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fat;
  final MacroTarget targets;

  const _FullMacroPie({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.targets,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = targets.calories > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.outlineSoft),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: hasData
                ? CustomPaint(
                    painter: _PieChartPainter(
                        protein: protein, carbs: carbs, fat: fat),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${targets.calories.round()}',
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900)),
                          const Text('kcal',
                              style: TextStyle(
                                  color: AppTheme.textTertiary, fontSize: 9)),
                        ],
                      ),
                    ),
                  )
                : const Center(
                    child: Text('Set macro\ntargets',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppTheme.textTertiary, fontSize: 11))),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PieLegend(
                    color: const Color(0xFF2F80ED),
                    label: 'Protein',
                    grams: targets.proteinG,
                    pct: protein),
                const SizedBox(height: 10),
                _PieLegend(
                    color: const Color(0xFF27AE60),
                    label: 'Carbohydrates',
                    grams: targets.carbsG,
                    pct: carbs),
                const SizedBox(height: 10),
                _PieLegend(
                    color: const Color(0xFFEB5757),
                    label: 'Fats',
                    grams: targets.fatsG,
                    pct: fat),
                if (targets.fiberG > 0) ...[
                  const SizedBox(height: 10),
                  _PieLegend(
                      color: const Color(0xFF56CCF2),
                      label: 'Fiber',
                      grams: targets.fiberG,
                      pct: 0,
                      showPct: false),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PieLegend extends StatelessWidget {
  final Color color;
  final String label;
  final double grams;
  final double pct;
  final bool showPct;

  const _PieLegend({
    required this.color,
    required this.label,
    required this.grams,
    required this.pct,
    this.showPct = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),
              Row(
                children: [
                  Text('${grams.round()}g',
                      style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w800)),
                  if (showPct && pct > 0) ...[
                    const SizedBox(width: 6),
                    Text('${pct.toStringAsFixed(0)}%',
                        style: const TextStyle(
                            color: AppTheme.textTertiary, fontSize: 10)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final double protein;
  final double carbs;
  final double fat;

  const _PieChartPainter(
      {required this.protein, required this.carbs, required this.fat});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;
    final strokeW = size.width * 0.14;

    const colors = [Color(0xFF2F80ED), Color(0xFF27AE60), Color(0xFFEB5757)];
    final fractions = [protein / 100, carbs / 100, fat / 100];

    var startAngle = -math.pi / 2;
    const gap = 0.06;

    for (var i = 0; i < 3; i++) {
      final sweep = fractions[i] * 2 * math.pi;
      if (sweep <= 0) continue;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + gap / 2,
        math.max(0, sweep - gap),
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_PieChartPainter old) =>
      old.protein != protein || old.carbs != carbs || old.fat != fat;
}

class _VolumeTable extends StatelessWidget {
  final Map<String, int> volume;
  final Map<String, int> mev;
  final Map<String, int> mrv;

  const _VolumeTable(
      {required this.volume, required this.mev, required this.mrv});

  @override
  Widget build(BuildContext context) {
    final sorted = volume.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxSets = sorted.isEmpty ? 1 : sorted.first.value;

    return Column(
      children: sorted.map((entry) {
        final muscle = entry.key;
        final sets = entry.value;
        final muscleMev = mev[muscle] ?? 8;
        final muscleMrv = mrv[muscle] ?? 20;
        final fraction = sets / math.max(maxSets, muscleMrv);

        final Color barColor;
        final String statusLabel;
        if (sets < muscleMev) {
          barColor = const Color(0xFFF2C94C);
          statusLabel = 'Below MEV';
        } else if (sets > muscleMrv) {
          barColor = const Color(0xFFEB5757);
          statusLabel = 'Above MRV';
        } else {
          barColor = const Color(0xFF27AE60);
          statusLabel = 'Optimal';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.surfaceRaised,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.outlineSoft),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(muscle,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: barColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(statusLabel,
                        style: TextStyle(
                            color: barColor,
                            fontSize: 8,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 8),
                  Text('$sets sets',
                      style: TextStyle(
                          color: barColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 6),
              Stack(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppTheme.outlineSoft,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: fraction.clamp(0.0, 1.0),
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('MEV: $muscleMev',
                      style: const TextStyle(
                          color: AppTheme.textTertiary, fontSize: 8)),
                  Text('MRV: $muscleMrv',
                      style: const TextStyle(
                          color: AppTheme.textTertiary, fontSize: 8)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final ProgramBuilderState state;
  const _KpiGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final dayCount = state.program.workoutDays.length;
    final exerciseCount = state.totalWeeklyExercises;
    final setCount = state.totalWeeklySets;
    final supCount = state.program.lifestyleProtocol.supplements.length;
    final mealCount = state.program.nutritionProtocol.mealSlots.length;
    final ruleCount = state.program.progressionRules.length;

    final kpis = [
      (
        'Training Days',
        '$dayCount',
        Icons.calendar_today_rounded,
        AppTheme.brand
      ),
      (
        'Exercises / wk',
        '$exerciseCount',
        Icons.fitness_center_rounded,
        const Color(0xFF2F80ED)
      ),
      (
        'Sets / wk',
        '$setCount',
        Icons.stacked_bar_chart_rounded,
        const Color(0xFF27AE60)
      ),
      (
        'Calories / day',
        '${state.macroTargets.calories.round()}',
        Icons.local_fire_department_rounded,
        const Color(0xFFF2C94C)
      ),
      (
        'Meal Slots',
        '$mealCount',
        Icons.restaurant_rounded,
        const Color(0xFF27AE60)
      ),
      (
        'Supplements',
        '$supCount',
        Icons.medication_rounded,
        const Color(0xFFEB5757)
      ),
      (
        'Sleep Target',
        '${state.program.lifestyleProtocol.sleepTargetHours.toStringAsFixed(1)}h',
        Icons.bedtime_rounded,
        const Color(0xFF7C4DFF)
      ),
      (
        'Prog. Rules',
        '$ruleCount',
        Icons.trending_up_rounded,
        const Color(0xFF56CCF2)
      ),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.1,
      children: kpis.map((kpi) {
        return Container(
          decoration: BoxDecoration(
            color: (kpi.$4 as Color).withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: (kpi.$4 as Color).withValues(alpha: 0.18)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(kpi.$3 as IconData, size: 14, color: kpi.$4 as Color),
              const SizedBox(height: 4),
              Text(kpi.$2 as String,
                  style: TextStyle(
                      color: kpi.$4 as Color,
                      fontSize: 16,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text(kpi.$1 as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 8,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ===========================================================================
// SHARED MICRO-WIDGETS (used across patched sections)
// ===========================================================================

class _SubHeader extends StatelessWidget {
  final String text;
  const _SubHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
          color: AppTheme.textTertiary,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const _EmptyCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.outlineSoft),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppTheme.textTertiary),
          const SizedBox(width: 8),
          Text(label,
              style:
                  const TextStyle(color: AppTheme.textTertiary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _FlatTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool numeric;
  final int minLines;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTapOutside;

  const _FlatTextField({
    required this.controller,
    required this.hint,
    this.numeric = false,
    this.minLines = 1,
    this.onSubmitted,
    this.onTapOutside,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.outlineSoft),
      ),
      child: TextField(
        controller: controller,
        minLines: minLines,
        maxLines: minLines == 1 ? 1 : null,
        keyboardType: numeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
        onSubmitted: onSubmitted,
        onTapOutside: onTapOutside != null ? (_) => onTapOutside!() : null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(color: AppTheme.textTertiary, fontSize: 13),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}

class _FLabel extends StatelessWidget {
  final String text;
  const _FLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700));
  }
}

class _ToggleChipSmall extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _ToggleChipSmall({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.brand;
    return TnTPressable(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? c.withValues(alpha: 0.14) : AppTheme.surfaceRaised,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color:
                  selected ? c.withValues(alpha: 0.45) : AppTheme.outlineSoft),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: selected ? c : AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
        ),
      ),
    );
  }
}

class _OutlinedAddBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _OutlinedAddBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TnTPressable(
      onTap: onTap,
      pressedScale: 0.97,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 14, color: color),
            const SizedBox(width: 7),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _InlineTextButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _InlineTextButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TnTPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.brand),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.brand,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ===========================================================================
// ANALYTICS SIDEBAR, APP BAR WIDGETS & SHARED HELPERS
// ===========================================================================
class _AnalyticsSidebar extends StatelessWidget {
  const _AnalyticsSidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLow,
        border: Border(left: BorderSide(color: AppTheme.outlineSoft)),
      ),
      child: BlocBuilder<ProgramBuilderBloc, ProgramBuilderState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(14),
            children: [
              const _SidebarHeading('Live Analytics'),
              const SizedBox(height: 14),

              // Macro chart
              const _SidebarSubHeading('Macro Distribution'),
              const SizedBox(height: 8),
              _MacroPieWidget(
                protein: state.proteinCaloriePercent,
                carbs: state.carbCaloriePercent,
                fat: state.fatCaloriePercent,
                calories: state.macroTargets.calories,
                compact: true,
              ),
              const SizedBox(height: 20),

              // Volume chart
              const _SidebarSubHeading('Weekly Set Volume'),
              const SizedBox(height: 8),
              _VolumeBarChart(
                volumeMap: state.weeklySetVolumePerMuscleGroup,
                compact: true,
              ),
              const SizedBox(height: 20),

              // Metabolic recap
              const _SidebarSubHeading('Metabolic'),
              const SizedBox(height: 8),
              _SidebarStatRow(label: 'BMR', value: '${state.bmr.round()} kcal'),
              _SidebarStatRow(
                  label: 'TDEE',
                  value: '${state.tdee.round()} kcal',
                  highlight: true),
              _SidebarStatRow(
                  label: 'LBM', value: '${state.lbm.toStringAsFixed(1)} kg'),
              _SidebarStatRow(
                  label: 'BMI', value: state.bmi.toStringAsFixed(1)),
              const SizedBox(height: 20),

              // Volume summary
              const _SidebarSubHeading('Volume Summary'),
              const SizedBox(height: 8),
              _SidebarStatRow(
                  label: 'Total Sets / week',
                  value: '${state.totalWeeklySets}'),
              _SidebarStatRow(
                  label: 'Total Exercises',
                  value: '${state.totalWeeklyExercises}'),
              _SidebarStatRow(
                  label: 'Training Days',
                  value: '${state.program.workoutDays.length}'),
            ],
          );
        },
      ),
    );
  }
}

class _SidebarHeading extends StatelessWidget {
  final String text;
  const _SidebarHeading(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.brand,
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _SidebarSubHeading extends StatelessWidget {
  final String text;
  const _SidebarSubHeading(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppTheme.textTertiary,
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _SidebarStatRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _SidebarStatRow(
      {required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                    color: highlight ? AppTheme.brand : AppTheme.textSecondary,
                    fontSize: 11)),
          ),
          Text(value,
              style: TextStyle(
                color: highlight ? AppTheme.brand : AppTheme.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }
}

// ===========================================================================
// SIDEBAR TOGGLE
// ===========================================================================

class _SidebarToggle extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;

  const _SidebarToggle({required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 20,
        color: AppTheme.surfaceLow,
        child: Center(
          child: AnimatedRotation(
            turns: expanded ? 0 : 0.5,
            duration: const Duration(milliseconds: 280),
            child: const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppTheme.textTertiary),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// ANALYTICS FAB (mobile)
// ===========================================================================

class _AnalyticsFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TnTPressable(
      onTap: () {
        HapticFeedback.selectionClick();
        showModalBottomSheet(
          context: context,
          backgroundColor: AppTheme.surfaceLow,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) => BlocProvider.value(
            value: context.read<ProgramBuilderBloc>(),
            child: const _AnalyticsBottomSheet(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.brand,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: AppTheme.brand.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child:
            const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}

class _AnalyticsBottomSheet extends StatelessWidget {
  const _AnalyticsBottomSheet();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgramBuilderBloc, ProgramBuilderState>(
      builder: (context, state) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.92,
          builder: (_, sc) => ListView(
            controller: sc,
            padding: const EdgeInsets.all(20),
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.outlineSoft,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const Text(
                'Live Analytics',
                style: TextStyle(
                    color: AppTheme.brand,
                    fontSize: 16,
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              const _SidebarSubHeading('Macro Distribution'),
              const SizedBox(height: 10),
              _MacroPieWidget(
                protein: state.proteinCaloriePercent,
                carbs: state.carbCaloriePercent,
                fat: state.fatCaloriePercent,
                calories: state.macroTargets.calories,
              ),
              const SizedBox(height: 20),
              const _SidebarSubHeading('Weekly Set Volume'),
              const SizedBox(height: 10),
              _VolumeBarChart(volumeMap: state.weeklySetVolumePerMuscleGroup),
            ],
          ),
        );
      },
    );
  }
}

// ===========================================================================
// MACRO PIE WIDGET (custom painter)
// ===========================================================================

class _MacroPieWidget extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fat;
  final double calories;
  final bool compact;

  const _MacroPieWidget({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.calories,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = calories > 0;
    final chartSize = compact ? 80.0 : 120.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: chartSize,
          height: chartSize,
          child: hasData
              ? CustomPaint(
                  painter:
                      _PiePainter(protein: protein, carbs: carbs, fat: fat),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${calories.round()}',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: compact ? 13 : 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'kcal',
                          style: TextStyle(
                              color: AppTheme.textTertiary,
                              fontSize: compact ? 8 : 10),
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Text('No targets set',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppTheme.textTertiary, fontSize: 10)),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MacroLegend(
                  color: const Color(0xFF2F80ED),
                  label: 'Protein',
                  value: '${protein.toStringAsFixed(0)}%'),
              const SizedBox(height: 4),
              _MacroLegend(
                  color: const Color(0xFF27AE60),
                  label: 'Carbs',
                  value: '${carbs.toStringAsFixed(0)}%'),
              const SizedBox(height: 4),
              _MacroLegend(
                  color: const Color(0xFFEB5757),
                  label: 'Fats',
                  value: '${fat.toStringAsFixed(0)}%'),
            ],
          ),
        ),
      ],
    );
  }
}

class _MacroLegend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _MacroLegend(
      {required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 10))),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _PiePainter extends CustomPainter {
  final double protein;
  final double carbs;
  final double fat;

  const _PiePainter(
      {required this.protein, required this.carbs, required this.fat});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final innerRect = Rect.fromCenter(
      center: rect.center,
      width: size.width * 0.55,
      height: size.height * 0.55,
    );

    const colors = [Color(0xFF2F80ED), Color(0xFF27AE60), Color(0xFFEB5757)];
    final values = [protein, carbs, fat];
    final total = values.fold(0.0, (s, v) => s + v);
    if (total <= 0) return;

    var startAngle = -math.pi / 2;
    for (var i = 0; i < 3; i++) {
      final sweep = (values[i] / 100) * 2 * math.pi;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.13
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCenter(
          center: rect.center,
          width: size.width * 0.82,
          height: size.height * 0.82,
        ),
        startAngle + 0.04,
        math.max(0, sweep - 0.08),
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_PiePainter old) =>
      old.protein != protein || old.carbs != carbs || old.fat != fat;
}

// ===========================================================================
// VOLUME BAR CHART
// ===========================================================================

class _VolumeBarChart extends StatelessWidget {
  final Map<String, int> volumeMap;
  final bool compact;

  const _VolumeBarChart({required this.volumeMap, this.compact = false});

  @override
  Widget build(BuildContext context) {
    if (volumeMap.isEmpty) {
      return _EmptySubSection(
        icon: Icons.stacked_bar_chart_rounded,
        label: 'No exercises added yet',
      );
    }

    final sorted = volumeMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.first.value;
    final displayed = compact ? sorted.take(5).toList() : sorted;

    return Column(
      children: displayed.map((entry) {
        final fraction = maxVal > 0 ? entry.value / maxVal : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              SizedBox(
                width: compact ? 56 : 80,
                child: Text(
                  entry.key,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: compact ? 16 : 20,
                      decoration: BoxDecoration(
                        color: AppTheme.outlineSoft,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: fraction,
                      child: Container(
                        height: compact ? 16 : 20,
                        decoration: BoxDecoration(
                          color: AppTheme.brand.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 28,
                child: Text(
                  '${entry.value}',
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ===========================================================================
// APP BAR WIDGETS
// ===========================================================================

class _CompletionBadge extends StatelessWidget {
  final double score;
  const _CompletionBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final pct = (score * 100).round();
    final color = pct < 40
        ? const Color(0xFFEB5757)
        : pct < 75
            ? const Color(0xFFF2C94C)
            : const Color(0xFF27AE60);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$pct%',
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ProgramStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case ProgramStatus.draft:
        color = AppTheme.textTertiary;
        break;
      case ProgramStatus.published:
        color = const Color(0xFF27AE60);
        break;
      case ProgramStatus.archived:
        color = const Color(0xFFEB5757);
        break;
    }

    return Text(
      status.name.toUpperCase(),
      style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8),
    );
  }
}

class _PublishButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgramBuilderBloc, ProgramBuilderState>(
      buildWhen: (p, c) => p.program.status != c.program.status,
      builder: (context, state) {
        final published = state.program.status == ProgramStatus.published;
        return TnTPressable(
          onTap: () {
            HapticFeedback.selectionClick();
            context
                .read<ProgramBuilderBloc>()
                .add(const ProgramBuilderPublishToggled());
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: published
                  ? const Color(0xFF27AE60).withValues(alpha: 0.12)
                  : AppTheme.surfaceRaised,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: published
                    ? const Color(0xFF27AE60).withValues(alpha: 0.4)
                    : AppTheme.outlineSoft,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  published
                      ? Icons.check_circle_rounded
                      : Icons.publish_rounded,
                  size: 14,
                  color: published
                      ? const Color(0xFF27AE60)
                      : AppTheme.textSecondary,
                ),
                const SizedBox(width: 5),
                Text(
                  published ? 'Published' : 'Publish',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: published
                        ? const Color(0xFF27AE60)
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SaveButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgramBuilderBloc, ProgramBuilderState>(
      buildWhen: (p, c) => p.saveStatus != c.saveStatus,
      builder: (context, state) {
        final saving = state.saveStatus == ProgramBuilderSaveStatus.saving;
        return TnTPressable(
          onTap: saving
              ? () {}
              : () {
                  HapticFeedback.selectionClick();
                  context
                      .read<ProgramBuilderBloc>()
                      .add(const ProgramBuilderSaveRequested());
                },
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: saving
                  ? AppTheme.brand.withValues(alpha: 0.5)
                  : AppTheme.brand,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (saving)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                else
                  const Icon(Icons.save_rounded, size: 14, color: Colors.white),
                const SizedBox(width: 5),
                const Text(
                  'Save',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ===========================================================================
// SHARED HELPER WIDGETS
// ===========================================================================

class _SubSectionLabel extends StatelessWidget {
  final String text;
  const _SubSectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppTheme.textTertiary,
        fontSize: 9,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _EmptySubSection extends StatelessWidget {
  final IconData icon;
  final String label;

  const _EmptySubSection({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: AppTheme.outlineSoft, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: AppTheme.textTertiary),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textTertiary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _AddButton({
    required this.label,
    required this.onTap,
    this.icon = Icons.add_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return TnTPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.brand.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: AppTheme.brand.withValues(alpha: 0.2),
              style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppTheme.brand),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                  color: AppTheme.brand,
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.outlineSoft),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 9,
                        fontWeight: FontWeight.w600)),
                Text(value,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppTheme.brand),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderField extends StatelessWidget {
  final String label;
  final String hint;
  final int minLines;

  const _PlaceholderField({
    required this.label,
    required this.hint,
    this.minLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceRaised,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.outlineSoft),
          ),
          child: TextField(
            minLines: minLines,
            maxLines: minLines == 1 ? 1 : null,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: AppTheme.textTertiary, fontSize: 13),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// HELPERS
// ===========================================================================

Color? _parseColor(String value) {
  final trimmed = value.trim().replaceFirst('#', '');
  final normalized = trimmed.length == 6 ? 'FF$trimmed' : trimmed;
  final parsed = int.tryParse(normalized, radix: 16);
  if (parsed == null) return null;
  return Color(parsed);
}
