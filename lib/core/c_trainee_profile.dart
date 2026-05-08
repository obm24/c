import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/m_goal_model.dart';
import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_en.dart';
import 'animations/anim_motion.dart';
import 'c_constants.dart';
import 'c_ui_theme.dart';
import 'c_warnings.dart';

class BodyCircumferenceSeries extends Equatable {
  final String key;
  final List<String> aliases;
  final Color color;
  final IconData icon;
  final String assetPath;
  final String description;

  const BodyCircumferenceSeries({
    required this.key,
    required this.aliases,
    required this.color,
    required this.icon,
    required this.assetPath,
    required this.description,
  });

  String localizedLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    switch (key) {
      case 'Neck':
        return l10n.neck;
      case 'Shoulder':
        return l10n.shoulder;
      case 'Chest':
        return l10n.chest;
      case 'Arms':
        return l10n.arms;
      case 'Forearms':
        return l10n.forearms;
      case 'Waist':
        return l10n.waist;
      case 'Hips':
        return l10n.hips;
      case 'Thighs':
        return l10n.thighs;
      case 'Legs':
        return l10n.legs;
      default:
        return key;
    }
  }

  @override
  List<Object?> get props =>
      [key, aliases, color, icon, assetPath, description];
}

const List<BodyCircumferenceSeries> bodyCircumferenceSeries = [
  BodyCircumferenceSeries(
    key: 'Neck',
    aliases: ['Neck'],
    color: Color(0xFF1F77B4),
    icon: Icons.airline_seat_flat,
    assetPath: 'assets/images/body_circumference/1_cleidomastoids.png',
    description:
        'Circumference of the neck at its narrowest point. Elevated neck girth can correlate with sleep apnea risk and cardiovascular markers.',
  ),
  BodyCircumferenceSeries(
    key: 'Shoulder',
    aliases: ['Shoulder', 'Shoulders'],
    color: Color(0xFFFF7F0E),
    icon: Icons.accessibility_new,
    assetPath: 'assets/images/body_circumference/2_shoulders.png',
    description:
        'Circumference around the widest part of the shoulders. Tracks upper body development and shoulder width relative to waist for V-taper progress.',
  ),
  BodyCircumferenceSeries(
    key: 'Chest',
    aliases: ['Chest'],
    color: Color(0xFF2CA02C),
    icon: Icons.favorite_border,
    assetPath: 'assets/images/body_circumference/3_chest.png',
    description:
        'Circumference around the fullest part of the chest. A primary hypertrophy indicator for the pectorals, lats, and upper back.',
  ),
  BodyCircumferenceSeries(
    key: 'Arms',
    aliases: ['Arms', 'Arm'],
    color: Color(0xFFD62728),
    icon: Icons.sports_handball_outlined,
    assetPath: 'assets/images/body_circumference/4_arms.png',
    description:
        'Circumference of the upper arm, usually measured at the biceps peak. It is a classic marker of arm muscle development.',
  ),
  BodyCircumferenceSeries(
    key: 'Forearms',
    aliases: ['Forearms', 'Forearm', 'Wrist'],
    color: Color(0xFFCB89B7),
    icon: Icons.sports_handball_outlined,
    assetPath: 'assets/images/body_circumference/7_forearms.png',
    description:
        'Circumference of the forearm at its widest point. Reflects grip strength development and lower arm hypertrophy.',
  ),
  BodyCircumferenceSeries(
    key: 'Waist',
    aliases: ['Waist'],
    color: Color(0xFF9467BD),
    icon: Icons.straighten,
    assetPath: 'assets/images/body_circumference/5_waist.png',
    description:
        'Circumference at the narrowest torso point, typically at the navel or just above the iliac crest. It is a key health-risk indicator.',
  ),
  BodyCircumferenceSeries(
    key: 'Hips',
    aliases: ['Hips', 'Hip'],
    color: Color(0xFF8C564B),
    icon: Icons.directions_walk,
    assetPath: 'assets/images/body_circumference/6_hips.png',
    description:
        'Circumference at the widest point of the hips and glutes. Often paired with waist measurement for waist-to-hip ratio tracking.',
  ),
  BodyCircumferenceSeries(
    key: 'Thighs',
    aliases: ['Thighs', 'Thigh'],
    color: Color(0xFF6CE7E3),
    icon: Icons.directions_walk,
    assetPath: 'assets/images/body_circumference/8_thighs.png',
    description:
        'Circumference of the upper thigh at its widest point. Tracks quadriceps, hamstring, and adductor hypertrophy.',
  ),
  BodyCircumferenceSeries(
    key: 'Legs',
    aliases: ['Legs', 'Leg', 'Calves', 'Calf'],
    color: Color(0xFFBCBD22),
    icon: Icons.directions_run,
    assetPath: 'assets/images/body_circumference/9_legs.png',
    description:
        'Circumference of the calf muscle at its fullest point. A useful lower-leg development marker that is often resistant to change.',
  ),
];

BodyCircumferenceSeries? bodyCircumferenceSeriesForKey(String key) {
  final normalizedKey = key.trim().toLowerCase();
  for (final series in bodyCircumferenceSeries) {
    if (series.key.toLowerCase() == normalizedKey ||
        series.aliases.any((alias) => alias.toLowerCase() == normalizedKey)) {
      return series;
    }
  }
  return null;
}

Map<String, dynamic> normalizeBodyCircumferenceData(
    Map<String, dynamic> rawData) {
  final normalized = <String, dynamic>{};
  for (final series in bodyCircumferenceSeries) {
    for (final alias in <String>{series.key, ...series.aliases}) {
      if (rawData.containsKey(alias)) {
        normalized[series.key] = rawData[alias];
        break;
      }
    }
  }
  return normalized;
}

abstract class BodyPartVisibilityEvent extends Equatable {
  const BodyPartVisibilityEvent();

  @override
  List<Object?> get props => [];
}

class ToggleBodyPartVisibility extends BodyPartVisibilityEvent {
  final String bodyPart;

  const ToggleBodyPartVisibility(this.bodyPart);

  @override
  List<Object?> get props => [bodyPart];
}

class BodyPartVisibilityState extends Equatable {
  final Set<String> availableBodyParts;
  final Set<String> hiddenBodyParts;

  const BodyPartVisibilityState({
    required this.availableBodyParts,
    this.hiddenBodyParts = const {},
  });

  BodyPartVisibilityState copyWith({
    Set<String>? availableBodyParts,
    Set<String>? hiddenBodyParts,
  }) {
    return BodyPartVisibilityState(
      availableBodyParts: availableBodyParts ?? this.availableBodyParts,
      hiddenBodyParts: hiddenBodyParts ?? this.hiddenBodyParts,
    );
  }

  bool isVisible(String bodyPart) => !hiddenBodyParts.contains(bodyPart);

  @override
  List<Object?> get props => [
        availableBodyParts.toList()..sort(),
        hiddenBodyParts.toList()..sort(),
      ];
}

class BodyPartVisibilityBloc
    extends Bloc<BodyPartVisibilityEvent, BodyPartVisibilityState> {
  BodyPartVisibilityBloc({
    required Iterable<String> availableBodyParts,
  }) : super(
          BodyPartVisibilityState(
            availableBodyParts: Set<String>.from(availableBodyParts),
          ),
        ) {
    on<ToggleBodyPartVisibility>(_onToggleBodyPartVisibility);
  }

  void _onToggleBodyPartVisibility(
    ToggleBodyPartVisibility event,
    Emitter<BodyPartVisibilityState> emit,
  ) {
    if (!state.availableBodyParts.contains(event.bodyPart)) {
      return;
    }

    final nextHiddenBodyParts = Set<String>.from(state.hiddenBodyParts);
    if (nextHiddenBodyParts.contains(event.bodyPart)) {
      nextHiddenBodyParts.remove(event.bodyPart);
    } else {
      nextHiddenBodyParts.add(event.bodyPart);
    }

    emit(state.copyWith(hiddenBodyParts: nextHiddenBodyParts));
  }
}

typedef BodyCircumferenceEditCallback = void Function(
  BuildContext context,
  BodyCircumferenceSeries series,
  String currentValue,
);

class BodyCircumferenceTrackerScreen extends StatefulWidget {
  final String title;
  final Map<String, dynamic> data;
  final String measurementUnit;
  final BodyCircumferenceEditCallback? onEditMeasurement;

  const BodyCircumferenceTrackerScreen({
    super.key,
    required this.title,
    required this.data,
    required this.measurementUnit,
    this.onEditMeasurement,
  });

  @override
  State<BodyCircumferenceTrackerScreen> createState() =>
      _BodyCircumferenceTrackerScreenState();
}

class _BodyCircumferenceTrackerScreenState
    extends State<BodyCircumferenceTrackerScreen> {
  static const List<String> _timelines = [
    'Currently',
    'Weekly',
    'Monthly',
    'Annually',
  ];

  late final BodyPartVisibilityBloc _bodyPartVisibilityBloc;
  String _selectedTimeline = 'Currently';

  @override
  void initState() {
    super.initState();
    _bodyPartVisibilityBloc = BodyPartVisibilityBloc(
      availableBodyParts: bodyCircumferenceSeries.map((series) => series.key),
    );
  }

  @override
  void dispose() {
    _bodyPartVisibilityBloc.close();
    super.dispose();
  }

  Map<String, dynamic> get _displayData =>
      normalizeBodyCircumferenceData(widget.data);

  List<String> _getXLabels() {
    if (_selectedTimeline == 'Currently') return ['Now'];
    if (_selectedTimeline == 'Weekly') {
      return ['16 Jun', '23 Jun', '30 Jun', '07 Jul'];
    }
    if (_selectedTimeline == 'Monthly') {
      return ['Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
    }
    if (_selectedTimeline == 'Annually') {
      return ['2020', '2021', '2022', '2023', '2024', '2025'];
    }
    return const [];
  }

  String _rawValueForSeries(BodyCircumferenceSeries series) {
    final value = _displayData[series.key];
    if (value != null) return value.toString();
    return '0.0';
  }

  String _displayValueForSeries(BodyCircumferenceSeries series) {
    final rawValue = _rawValueForSeries(series);
    final match = RegExp(r'[0-9]+(\.[0-9]+)?').firstMatch(rawValue);
    return match?.group(0) ?? '0.0';
  }

  double _currentValueForKey(String key) {
    final series = bodyCircumferenceSeriesForKey(key);
    if (series == null) return 0.0;
    final numericValue = _displayValueForSeries(series);
    return double.tryParse(numericValue) ?? 0.0;
  }

  List<double> _getMetricValues(String key) {
    final baseVal = _currentValueForKey(key);
    final pointCount = switch (_selectedTimeline) {
      'Weekly' => 4,
      'Monthly' => 6,
      'Annually' => 6,
      _ => 1,
    };
    if (baseVal <= 0) {
      return List<double>.filled(pointCount, 0.01);
    }

    final isDescendingTarget = key == 'Waist';
    final sign = isDescendingTarget ? 1.0 : -1.0;

    if (_selectedTimeline == 'Weekly') {
      return [
        baseVal + sign * 2.5,
        baseVal + sign * 1.8,
        baseVal + sign * 1.0,
        baseVal,
      ];
    }
    if (_selectedTimeline == 'Monthly') {
      return [
        baseVal + sign * 8.0,
        baseVal + sign * 6.0,
        baseVal + sign * 4.0,
        baseVal + sign * 2.0,
        baseVal + sign * 1.0,
        baseVal,
      ];
    }
    if (_selectedTimeline == 'Annually') {
      return [
        baseVal + sign * 15.0,
        baseVal + sign * 12.0,
        baseVal + sign * 9.0,
        baseVal + sign * 6.0,
        baseVal + sign * 3.0,
        baseVal,
      ];
    }
    return [baseVal];
  }

  double _toLog(double value) =>
      value > 0 ? (math.log(value) / math.ln10) : 0.0;

  double _fromLog(double logValue) => math.pow(10, logValue).toDouble();

  String _formatLegendValue(BodyCircumferenceSeries series) {
    final value = _currentValueForKey(series.key);
    if (value == 0) return '0';
    return value.truncateToDouble() == value
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }

  void _showDescriptionDialog(
    BuildContext context,
    BodyCircumferenceSeries series,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 60),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: series.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: _BodyPartAssetIcon(series: series, size: 25),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          series.localizedLabel(context),
                          style: TextStyle(
                            color: series.color,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Unit: cm / in',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppTheme.divider),
              const SizedBox(height: 12),
              Text(
                series.description,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: AppConstants.kDefaultButtonHeightLarge,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.brand,
                    side: const BorderSide(color: AppTheme.brand),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.kDefaultBorderRadius,
                      ),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Got it',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleBodyPart(BuildContext context, String key) {
    HapticFeedback.selectionClick();
    context.read<BodyPartVisibilityBloc>().add(ToggleBodyPartVisibility(key));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bodyPartVisibilityBloc,
      child: Scaffold(
        backgroundColor: AppTheme.bg,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppTheme.bg,
          iconTheme: const IconThemeData(color: AppTheme.textPrimary),
          title: Text(
            widget.title,
            style: const TextStyle(color: AppTheme.brand),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: _timelines.map((timeline) {
                  final isSelected = timeline == _selectedTimeline;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedTimeline = timeline);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 8,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.brand : AppTheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                isSelected ? AppTheme.brand : AppTheme.divider,
                          ),
                        ),
                        child: AutoSizeText(
                          timeline,
                          maxLines: 1,
                          minFontSize: 9,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected
                                ? AppTheme.bg
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            if (_selectedTimeline == 'Currently')
              Expanded(child: _buildCurrentGrid(context))
            else ...[
              Expanded(child: _buildChart(context)),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const horizontalPadding = 14.0;
        const spacing = 10.0;
        final availableWidth =
            constraints.maxWidth - horizontalPadding * 2 - spacing * 2;
        final cardWidth = math.max(86.0, availableWidth / 3);
        final cardHeight = math.max(128.0, cardWidth / 0.82);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            horizontalPadding,
            4,
            horizontalPadding,
            24,
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            spacing: spacing,
            runSpacing: spacing,
            children: bodyCircumferenceSeries.map((series) {
              final value = _displayValueForSeries(series);
              return SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: GestureDetector(
                  onTap: widget.onEditMeasurement == null
                      ? null
                      : () {
                          HapticFeedback.selectionClick();
                          widget.onEditMeasurement!(context, series, value);
                        },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(
                        AppConstants.kDefaultBorderRadius,
                      ),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(7, 11, 7, 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _BodyPartAssetIcon(
                                  series: series,
                                  size: math.min(70, cardWidth * 0.58),
                                ),
                                const SizedBox(height: 8),
                                AutoSizeText(
                                  series.localizedLabel(context),
                                  maxLines: 1,
                                  minFontSize: 8,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppTheme.textSecondary
                                        .withValues(alpha: 0.85),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                _MeasurementValueText(
                                  value: value,
                                  unit: widget.measurementUnit,
                                  color: series.color,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          bottom: 31,
                          child: _InfoBadge(
                            color: series.color,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _showDescriptionDialog(context, series);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(growable: false),
          ),
        );
      },
    );
  }

  Widget _buildChart(BuildContext context) {
    final xLabels = _getXLabels();
    if (xLabels.isEmpty) return const SizedBox.shrink();

    return BlocBuilder<BodyPartVisibilityBloc, BodyPartVisibilityState>(
      builder: (context, state) {
        final visibleSeries = bodyCircumferenceSeries
            .where((series) => state.isVisible(series.key))
            .toList(growable: false);

        final lineBarsData = <LineChartBarData>[];
        double globalMinLog = double.infinity;
        double globalMaxLog = double.negativeInfinity;

        for (final series in visibleSeries) {
          final logValues = _getMetricValues(series.key)
              .map((value) =>
                  _toLog(value.abs().clamp(0.01, double.infinity).toDouble()))
              .toList(growable: false);

          for (final logValue in logValues) {
            if (logValue < globalMinLog) globalMinLog = logValue;
            if (logValue > globalMaxLog) globalMaxLog = logValue;
          }

          final spots = logValues
              .asMap()
              .entries
              .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
              .toList(growable: false);

          lineBarsData.add(
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: series.color,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
                  radius: 3.5,
                  color: series.color,
                  strokeWidth: 1.5,
                  strokeColor: AppTheme.bg,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    series.color.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          );
        }

        if (globalMinLog == double.infinity) {
          globalMinLog = 0;
          globalMaxLog = 2;
        }
        final logRange = (globalMaxLog - globalMinLog)
            .clamp(0.1, double.infinity)
            .toDouble();
        final minY = globalMinLog - logRange * 0.08;
        final maxY = globalMaxLog + logRange * 0.08;
        final xCount = xLabels.length;
        final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                padding: const EdgeInsets.fromLTRB(4, 16, 12, 4),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(
                    AppConstants.kDefaultBorderRadius,
                  ),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const preferredLegendLeft = 48.0;
                    final maxLegendWidth =
                        math.max(140.0, constraints.maxWidth - 12);
                    final legendWidth = math.min(330.0, maxLegendWidth);
                    final maxLegendLeft =
                        math.max(0.0, constraints.maxWidth - legendWidth);
                    final desiredLegendLeft =
                        (constraints.maxWidth - legendWidth) / 2;
                    final legendLeft = math.min(
                      preferredLegendLeft,
                      desiredLegendLeft.clamp(0.0, maxLegendLeft),
                    );
                    final legendMaxHeight =
                        math.max(120.0, constraints.maxHeight - 40);

                    return Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        Positioned.fill(
                          child: lineBarsData.isEmpty
                              ? Center(
                                  child: Text(
                                    '${l10n.allSeriesHidden}\n'
                                    '${l10n.tapBodyPartToShowSeries}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                )
                              : LineChart(
                                  LineChartData(
                                    minX: 0,
                                    maxX: (xCount - 1).toDouble(),
                                    minY: minY,
                                    maxY: maxY,
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval: logRange / 4,
                                      getDrawingHorizontalLine: (_) => FlLine(
                                        color: AppTheme.divider
                                            .withValues(alpha: 0.5),
                                        strokeWidth: 1,
                                        dashArray: [4, 6],
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 42,
                                          getTitlesWidget: (logValue, meta) {
                                            final real = _fromLog(logValue);
                                            final label = real >= 1000
                                                ? '${(real / 1000).toStringAsFixed(1)}k'
                                                : real >= 100
                                                    ? real.toStringAsFixed(0)
                                                    : real.toStringAsFixed(1);
                                            return Text(
                                              label,
                                              style: const TextStyle(
                                                color: AppTheme.textSecondary,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      rightTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 32,
                                          interval: 1,
                                          getTitlesWidget: (value, meta) {
                                            final index = value.toInt();
                                            if (index < 0 || index >= xCount) {
                                              return const SizedBox.shrink();
                                            }
                                            final skipEvery =
                                                xCount > 5 ? 2 : 1;
                                            if (xCount > 5 &&
                                                index % skipEvery != 0) {
                                              return const SizedBox.shrink();
                                            }
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 6),
                                              child: Text(
                                                xLabels[index],
                                                style: const TextStyle(
                                                  color: AppTheme.textSecondary,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    lineTouchData:
                                        LineTouchData(enabled: false),
                                    lineBarsData: lineBarsData,
                                  ),
                                ),
                        ),
                        if (lineBarsData.isNotEmpty)
                          Positioned(
                            top: 20,
                            left: legendLeft,
                            child: SizedBox(
                              width: legendWidth,
                              height: legendMaxHeight,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.topLeft,
                                child: SizedBox(
                                  width: legendWidth,
                                  child: _BodyCircumferenceLegend(
                                    series: bodyCircumferenceSeries,
                                    unit: widget.measurementUnit,
                                    isVisible: state.isVisible,
                                    valueFor: _formatLegendValue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            _BodyPartFilterTags(
              series: bodyCircumferenceSeries,
              isVisible: state.isVisible,
              onToggle: (key) => _toggleBodyPart(context, key),
            ),
          ],
        );
      },
    );
  }
}

class _MeasurementValueText extends StatelessWidget {
  final String value;
  final String unit;
  final Color color;

  const _MeasurementValueText({
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: AutoSizeText(
              value,
              maxLines: 1,
              minFontSize: 10,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 3),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: AutoSizeText(
              unit,
              maxLines: 1,
              minFontSize: 7,
              style: TextStyle(
                color: color.withValues(alpha: 0.65),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _InfoBadge({
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '?',
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _BodyPartAssetIcon extends StatelessWidget {
  final BodyCircumferenceSeries series;
  final double size;

  const _BodyPartAssetIcon({
    required this.series,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      series.assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => Icon(
        series.icon,
        color: series.color,
        size: size * 0.72,
      ),
    );
  }
}

class _BodyCircumferenceLegend extends StatelessWidget {
  final List<BodyCircumferenceSeries> series;
  final String unit;
  final bool Function(String key) isVisible;
  final String Function(BodyCircumferenceSeries series) valueFor;

  const _BodyCircumferenceLegend({
    required this.series,
    required this.unit,
    required this.isVisible,
    required this.valueFor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF080A0A).withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A2D32), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int index = 0; index < series.length; index++) ...[
            if (index > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: AppTheme.divider.withValues(alpha: 0.8),
              ),
            _BodyCircumferenceLegendRow(
              series: series[index],
              unit: unit,
              value: valueFor(series[index]),
              visible: isVisible(series[index].key),
            ),
          ],
        ],
      ),
    );
  }
}

class _BodyCircumferenceLegendRow extends StatelessWidget {
  final BodyCircumferenceSeries series;
  final String value;
  final String unit;
  final bool visible;

  const _BodyCircumferenceLegendRow({
    required this.series,
    required this.value,
    required this.unit,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    final color = visible ? series.color : AppTheme.textTertiary;
    return Opacity(
      opacity: visible ? 1 : 0.42,
      child: SizedBox(
        height: 34,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 32,
              child: Center(
                child: _BodyPartAssetIcon(series: series, size: 27),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 6,
              child: Align(
                alignment: Alignment.centerLeft,
                child: AutoSizeText(
                  series.localizedLabel(context),
                  maxLines: 1,
                  minFontSize: 10,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Container(
              width: 1,
              height: double.infinity,
              color: AppTheme.divider.withValues(alpha: 0.8),
              margin: const EdgeInsets.symmetric(horizontal: 10),
            ),
            Expanded(
              flex: 5,
              child: Align(
                alignment: Alignment.centerLeft,
                child: AutoSizeText(
                  '$value $unit',
                  maxLines: 1,
                  minFontSize: 10,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BodyPartFilterTags extends StatelessWidget {
  final List<BodyCircumferenceSeries> series;
  final bool Function(String key) isVisible;
  final ValueChanged<String> onToggle;

  const _BodyPartFilterTags({
    required this.series,
    required this.isVisible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 8.0;
          final firstRowCount = (series.length / 2).ceil();
          final maxChipWidth =
              (constraints.maxWidth - spacing * (firstRowCount - 1)) /
                  firstRowCount;
          final chipWidth = maxChipWidth.clamp(40.0, 92.0).toDouble();
          final firstRow = series.take(firstRowCount).toList(growable: false);
          final secondRow = series.skip(firstRowCount).toList(growable: false);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BodyPartFilterTagRow(
                items: firstRow,
                chipWidth: chipWidth,
                spacing: spacing,
                isVisible: isVisible,
                onToggle: onToggle,
              ),
              const SizedBox(height: 8),
              _BodyPartFilterTagRow(
                items: secondRow,
                chipWidth: chipWidth,
                spacing: spacing,
                isVisible: isVisible,
                onToggle: onToggle,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BodyPartFilterTagRow extends StatelessWidget {
  final List<BodyCircumferenceSeries> items;
  final double chipWidth;
  final double spacing;
  final bool Function(String key) isVisible;
  final ValueChanged<String> onToggle;

  const _BodyPartFilterTagRow({
    required this.items,
    required this.chipWidth,
    required this.spacing,
    required this.isVisible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int index = 0; index < items.length; index++) ...[
          if (index > 0) SizedBox(width: spacing),
          _BodyPartFilterTag(
            series: items[index],
            width: chipWidth,
            selected: isVisible(items[index].key),
            onTap: () => onToggle(items[index].key),
          ),
        ],
      ],
    );
  }
}

class _BodyPartFilterTag extends StatelessWidget {
  final BodyCircumferenceSeries series;
  final double width;
  final bool selected;
  final VoidCallback onTap;

  const _BodyPartFilterTag({
    required this.series,
    required this.width,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: selected ? 1 : 0.45,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: width,
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: selected
                ? series.color.withValues(alpha: 0.11)
                : AppTheme.surfaceLow,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? series.color.withValues(alpha: 0.45)
                  : AppTheme.outlineSoft,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _BodyPartAssetIcon(series: series, size: 16),
              const SizedBox(width: 3),
              Flexible(
                child: AutoSizeText(
                  series.localizedLabel(context),
                  maxLines: 1,
                  minFontSize: 7,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? series.color : AppTheme.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum ExperienceLevel {
  zeroYears,
  oneToTwoYears,
  threeToFiveYears,
  sixToNineYears,
  tenPlusYears,
}

class TrainingExperienceOption {
  final ExperienceLevel level;
  final int years;
  final int minYears;
  final int? maxYears;
  final String label;
  final Color color;
  final String description;

  const TrainingExperienceOption({
    required this.level,
    required this.years,
    required this.minYears,
    required this.maxYears,
    required this.label,
    required this.color,
    required this.description,
  });

  bool containsYears(int value) {
    final clamped = value < 0 ? 0 : value;
    final ceiling = maxYears;
    if (ceiling == null) return clamped >= minYears;
    return clamped >= minYears && clamped <= ceiling;
  }

  String localizedLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    switch (level) {
      case ExperienceLevel.zeroYears:
        return l10n.experienceLevelZeroYears;
      case ExperienceLevel.oneToTwoYears:
        return l10n.experienceLevelOneToTwoYears;
      case ExperienceLevel.threeToFiveYears:
        return l10n.experienceLevelThreeToFiveYears;
      case ExperienceLevel.sixToNineYears:
        return l10n.experienceLevelSixToNineYears;
      case ExperienceLevel.tenPlusYears:
        return l10n.experienceLevelTenPlusYears;
    }
  }

  String localizedDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    switch (level) {
      case ExperienceLevel.zeroYears:
        return l10n.experienceLevelZeroYearsDescription;
      case ExperienceLevel.oneToTwoYears:
        return l10n.experienceLevelOneToTwoYearsDescription;
      case ExperienceLevel.threeToFiveYears:
        return l10n.experienceLevelThreeToFiveYearsDescription;
      case ExperienceLevel.sixToNineYears:
        return l10n.experienceLevelSixToNineYearsDescription;
      case ExperienceLevel.tenPlusYears:
        return l10n.experienceLevelTenPlusYearsDescription;
    }
  }
}

class TraineeTrainingExperienceData {
  static const List<TrainingExperienceOption> options = [
    TrainingExperienceOption(
      level: ExperienceLevel.zeroYears,
      years: 0,
      minYears: 0,
      maxYears: 0,
      label: '0 Years',
      color: AppTheme.textSecondary,
      description: 'No consistent structured personal training yet.',
    ),
    TrainingExperienceOption(
      level: ExperienceLevel.oneToTwoYears,
      years: 1,
      minYears: 1,
      maxYears: 2,
      label: '1-2 Years',
      color: AppTheme.cardBlue,
      description:
          'Early foundation with basic exercise familiarity and developing consistency.',
    ),
    TrainingExperienceOption(
      level: ExperienceLevel.threeToFiveYears,
      years: 3,
      minYears: 3,
      maxYears: 5,
      label: '3-5 Years',
      color: AppTheme.cardGreen,
      description:
          'Consistent intermediate training with structured routines and progression.',
    ),
    TrainingExperienceOption(
      level: ExperienceLevel.sixToNineYears,
      years: 6,
      minYears: 6,
      maxYears: 9,
      label: '6-9 Years',
      color: AppTheme.cardYellow,
      description:
          'Advanced recreational training with long-term consistency and body awareness.',
    ),
    TrainingExperienceOption(
      level: ExperienceLevel.tenPlusYears,
      years: 10,
      minYears: 10,
      maxYears: null,
      label: '10+ Years',
      color: AppTheme.cardPurple,
      description:
          'Highly experienced training history across many years or training phases.',
    ),
  ];

  static int normalizeYears(dynamic value) {
    if (value is ExperienceLevel) {
      return optionForLevel(value).years;
    }
    if (value is int) {
      if (value < 0) return 0;
      if (value > 10) return 10;
      return value;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized.contains('+10')) return 10;
      if (normalized.contains('1-2') || normalized.contains('1\u20132')) {
        return 1;
      }
      if (normalized.contains('3-5') || normalized.contains('3\u20135')) {
        return 3;
      }
      if (normalized.contains('6-9') || normalized.contains('6\u20139')) {
        return 6;
      }
      final match = RegExp(r'\d+').firstMatch(normalized);
      if (match != null) {
        return normalizeYears(int.tryParse(match.group(0) ?? '') ?? 0);
      }
    }
    return 0;
  }

  static TrainingExperienceOption optionForLevel(ExperienceLevel level) {
    return options.firstWhere(
      (option) => option.level == level,
      orElse: () => options.first,
    );
  }

  static TrainingExperienceOption optionFor(dynamic value) {
    final years = normalizeYears(value);
    return options.firstWhere(
      (option) => option.containsYears(years),
      orElse: () => options.first,
    );
  }

  static String labelFor(dynamic value) => optionFor(value).label;

  static Future<void> showOptionHelpDialog(
    BuildContext context,
    TrainingExperienceOption option,
  ) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    return AppMotion.showPremiumDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        titlePadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
        ),
        title: _DialogTitle(title: option.localizedLabel(context)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.trainingExperienceDialogIntro,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: AppConstants.kDefaultSubtitleFontSize,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              _ExperienceGuideRow(
                label: option.localizedLabel(context),
                color: option.color,
                text: option.localizedDescription(context),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(ctx);
            },
            child: Text(
              l10n.close,
              style: const TextStyle(
                color: AppTheme.brand,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  static Future<void> showHelpDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    return AppMotion.showPremiumDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        titlePadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
        ),
        title: _DialogTitle(title: l10n.trainingExperienceDialogTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.trainingExperienceDialogIntro,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: AppConstants.kDefaultSubtitleFontSize,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              ...options.map(
                (option) => _ExperienceGuideRow(
                  label: option.localizedLabel(context),
                  color: option.color,
                  text: option.localizedDescription(context),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(ctx);
            },
            child: Text(
              l10n.close,
              style: const TextStyle(
                color: AppTheme.brand,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class TrainingExperienceSelector extends StatefulWidget {
  final String title;
  final int? selectedYears;
  final ValueChanged<int> onSelected;
  final bool showRequiredWarning;
  final String warningText;

  const TrainingExperienceSelector({
    super.key,
    this.title = 'Training Experience',
    required this.selectedYears,
    required this.onSelected,
    this.showRequiredWarning = false,
    this.warningText = 'Please select your training experience.',
  });

  @override
  State<TrainingExperienceSelector> createState() =>
      _TrainingExperienceSelectorState();
}

class _TrainingExperienceSelectorState
    extends State<TrainingExperienceSelector> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final selectedOption = widget.selectedYears == null
        ? null
        : TraineeTrainingExperienceData.optionFor(widget.selectedYears);
    final selectedStorageYears = selectedOption?.years;
    final title = widget.title == 'Physical Training Experience' ||
            widget.title == 'Training Experience'
        ? l10n.physicalTrainingExperience
        : widget.title;
    final warningText = widget.warningText ==
                'Please select your physical training experience.' ||
            widget.warningText == 'Please select your training experience.'
        ? l10n.trainingExperienceRequired
        : widget.warningText;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: AppConstants.kDefaultSubtitleFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(
                  minHeight: 36,
                  minWidth: 36,
                ),
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.help_outline_rounded,
                  color: AppTheme.brand,
                  size: 20,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  TraineeTrainingExperienceData.showHelpDialog(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: AppConstants.kDefaultButtonHeightLarge,
            ),
            child: AnimatedContainer(
              duration: AppMotion.duration(context, AppDurations.standard),
              curve: AppCurves.entrance,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                border: Border.all(
                  color: selectedOption == null
                      ? AppTheme.textSecondary
                      : AppTheme.cardGreen,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(
                        AppConstants.kDefaultBorderRadius),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _expanded = !_expanded);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedOption?.localizedLabel(context) ??
                                  l10n.trainingExperienceRequired,
                              style: TextStyle(
                                color: selectedOption == null
                                    ? AppTheme.textSecondary
                                    : AppTheme.textPrimary,
                                fontSize: AppConstants.kDefaultSubtitleFontSize,
                                fontWeight: selectedOption == null
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (selectedOption != null) ...[
                            const Icon(
                              Icons.check_circle,
                              color: AppTheme.cardGreen,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                          ],
                          AnimatedRotation(
                            turns: _expanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 180),
                            child: const Icon(
                              Icons.arrow_drop_down,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Column(
                      children: [
                        const Divider(color: AppTheme.divider, height: 1),
                        RadioGroup<int>(
                          groupValue: selectedStorageYears,
                          onChanged: (years) {
                            if (years == null) return;
                            HapticFeedback.selectionClick();
                            widget.onSelected(years);
                            setState(() => _expanded = false);
                          },
                          child: Column(
                            children: TraineeTrainingExperienceData.options
                                .map((option) {
                              final selected =
                                  option.years == selectedStorageYears;
                              return RadioListTile<int>(
                                value: option.years,
                                activeColor: option.color,
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 0,
                                ),
                                title: Text(
                                  option.localizedLabel(context),
                                  style: TextStyle(
                                    color: selected
                                        ? option.color
                                        : AppTheme.textSecondary,
                                    fontSize:
                                        AppConstants.kDefaultSubtitleFontSize,
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    crossFadeState: _expanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 180),
                    sizeCurve: Curves.easeOutCubic,
                  ),
                ],
              ),
            ),
          ),
          if (selectedOption == null && widget.showRequiredWarning)
            StandardFormWarningBanner(
              message: warningText,
              isValid: false,
              margin: const EdgeInsets.only(top: 10),
            )
          else if (selectedOption != null)
            StandardFormWarningBanner(
              message: l10n.trainingExperienceSelected,
              isValid: true,
              margin: const EdgeInsets.only(top: 10),
            ),
        ],
      ),
    );
  }
}

class _ExperienceGuideRow extends StatelessWidget {
  final String label;
  final Color color;
  final String text;

  const _ExperienceGuideRow({
    required this.label,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 86,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogTitle extends StatelessWidget {
  final String title;

  const _DialogTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.brand,
              fontWeight: FontWeight.bold,
              fontSize: AppConstants.kDefaultTitleFontSize,
            ),
          ),
        ),
        const Divider(color: AppTheme.divider, height: 1),
      ],
    );
  }
}

class TraineeDietData {
  static const String balancedHealthyEating =
      'Balanced / General healthy eating';

  static const List<GoalCategory> categories = [
    GoalCategory(
      id: 'diet_everyday',
      name: 'Everyday nutrition',
      items: [
        GoalItem(
          id: 'diet_balanced',
          categoryId: 'diet_everyday',
          title: balancedHealthyEating,
          description:
              'A flexible approach built around varied meals, steady portions, and mostly minimally processed foods without strict macro rules. It is useful when you want a sustainable baseline that can support different training goals. Examples: lean protein, whole grains, vegetables.',
        ),
        GoalItem(
          id: 'diet_high_protein',
          categoryId: 'diet_everyday',
          title: 'High-protein diet',
          description:
              'Prioritizes protein intake to support satiety, muscle repair, and training recovery while still balancing carbohydrates, fats, and micronutrients. Examples: eggs, chicken, Greek yogurt.',
        ),
        GoalItem(
          id: 'diet_mediterranean',
          categoryId: 'diet_everyday',
          title: 'Mediterranean diet',
          description:
              'Emphasizes plant-forward meals, olive oil, seafood, legumes, whole grains, and simple minimally processed ingredients. It can be adapted for performance or general health goals without requiring rigid tracking. Examples: grilled fish, lentil soup, Greek salad.',
        ),
        GoalItem(
          id: 'diet_low_fat',
          categoryId: 'diet_everyday',
          title: 'Low-fat diet',
          description:
              'Keeps dietary fat relatively lower while still including essential fats and enough total energy for training. This can suit users who prefer higher carbohydrate meals or lighter cooking methods. Examples: lean meats, rice, low-fat dairy.',
        ),
      ],
    ),
    GoalCategory(
      id: 'diet_macros',
      name: 'Macro-focused approaches',
      items: [
        GoalItem(
          id: 'diet_low_carb',
          categoryId: 'diet_macros',
          title: 'Low-carb diet',
          description:
              'Reduces carbohydrate intake while usually increasing protein, vegetables, and healthy fats. It should still be planned around training demands, energy levels, and food preference. Examples: eggs, chicken, non-starchy vegetables.',
        ),
        GoalItem(
          id: 'diet_ketogenic',
          categoryId: 'diet_macros',
          title: 'Ketogenic diet',
          description:
              'A very-low-carbohydrate, higher-fat pattern that requires consistent carbohydrate restriction and careful food planning. It is a preference, not a universally better approach, and may need extra attention around intense training. Examples: eggs, fish, avocado.',
        ),
        GoalItem(
          id: 'diet_paleo',
          categoryId: 'diet_macros',
          title: 'Paleo-style diet',
          description:
              'Focuses on whole foods inspired by pre-agricultural eating patterns while limiting many processed foods, grains, legumes, and dairy. It can be flexible, but may require planning to cover training fuel and variety. Examples: meat, eggs, fruit.',
        ),
      ],
    ),
    GoalCategory(
      id: 'diet_plant_forward',
      name: 'Plant-forward preferences',
      items: [
        GoalItem(
          id: 'diet_vegetarian',
          categoryId: 'diet_plant_forward',
          title: 'Vegetarian diet',
          description:
              'Excludes meat and fish while often including dairy and eggs depending on preference. Protein, iron-rich foods, and meal variety should be planned intentionally for training support. Examples: eggs, lentils, tofu.',
        ),
        GoalItem(
          id: 'diet_vegan',
          categoryId: 'diet_plant_forward',
          title: 'Vegan diet',
          description:
              'Excludes animal-derived foods and relies fully on plant sources. It can support training well when protein, calories, key micronutrients, and food variety are planned carefully. Examples: tofu, legumes, fortified soy milk.',
        ),
        GoalItem(
          id: 'diet_pescatarian',
          categoryId: 'diet_plant_forward',
          title: 'Pescatarian diet',
          description:
              'Plant-forward eating that includes fish and seafood while usually excluding meat and poultry. It can offer flexible protein options while keeping most meals centered on plants. Examples: salmon, shrimp, legumes.',
        ),
      ],
    ),
    GoalCategory(
      id: 'diet_restrictions',
      name: 'Restrictions and requirements',
      items: [
        GoalItem(
          id: 'diet_gluten_free',
          categoryId: 'diet_restrictions',
          title: 'Gluten-free diet',
          description:
              'Avoids gluten-containing grains such as wheat, barley, and rye. This may be a medical requirement or preference, so food labels and cross-contact risk can matter for some users. Examples: rice, potatoes, quinoa.',
        ),
        GoalItem(
          id: 'diet_dairy_free',
          categoryId: 'diet_restrictions',
          title: 'Dairy-free diet',
          description:
              'Avoids milk-based foods and ingredients while using other foods to cover protein, calcium, and overall energy needs. It can be combined with many other diet styles. Examples: soy yogurt, tofu, dairy-free milk.',
        ),
        GoalItem(
          id: 'diet_halal',
          categoryId: 'diet_restrictions',
          title: 'Halal diet',
          description:
              'Follows Islamic dietary rules by avoiding pork and alcohol and choosing permissible foods and ingredients. Training nutrition can still be balanced within these boundaries. Examples: halal-certified meats, fish, legumes.',
        ),
      ],
    ),
    GoalCategory(
      id: 'diet_timing_custom',
      name: 'Timing and custom',
      items: [
        GoalItem(
          id: 'diet_intermittent_fasting',
          categoryId: 'diet_timing_custom',
          title: 'Intermittent fasting',
          description:
              'Uses planned eating and fasting windows without requiring a specific food list. Meal timing should still support energy, recovery, hydration, and enough total nutrition during the eating window. Examples: 12:12, 14:10, 16:8.',
        ),
        GoalItem(
          id: 'diet_custom',
          categoryId: 'diet_timing_custom',
          title: 'Custom / Other',
          description:
              'Use this when your preference does not fit the listed options or needs personal context. This helps trainers avoid assumptions and ask the right follow-up questions. Examples: food allergies, cultural pattern, custom macros.',
        ),
      ],
    ),
  ];

  static List<String> get allLabels => categories
      .expand((category) => category.items)
      .map((item) => item.title)
      .toList(growable: false);

  static String summary(List<String> diets) {
    if (diets.isEmpty) return 'Flexible / No specific preference';
    if (diets.length <= 2) return diets.join(', ');
    return '${diets.take(2).join(', ')} +${diets.length - 2} more';
  }
}
