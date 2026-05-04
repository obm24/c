import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';

import '../core/c_ui_theme.dart';
import '../core/c_core_utils.dart';

// =============================================================================
// ANALYTICS SCREEN — POLISHED TOP-TIER
// =============================================================================
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedPeriod = 1; // 0:1D 1:1W 2:1M 3:6M 4:1Y
  late TabController _tabController;
  int? _hoveredBarIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // DATA
  // ---------------------------------------------------------------------------
  List<FlSpot> get _revenueSpots {
    switch (_selectedPeriod) {
      case 0:
        return List.generate(
            24,
            (i) => FlSpot(i.toDouble(),
                50 + 8 * (i % 6).toDouble() + (i % 3).toDouble()));
      case 1:
        return [
          FlSpot(0, 112),
          FlSpot(1, 115),
          FlSpot(2, 118),
          FlSpot(3, 114),
          FlSpot(4, 115),
          FlSpot(5, 116),
          FlSpot(6, 119)
        ];
      case 2:
        return [FlSpot(0, 105), FlSpot(1, 110), FlSpot(2, 108), FlSpot(3, 115)];
      case 3:
        return [
          FlSpot(0, 98),
          FlSpot(1, 102),
          FlSpot(2, 110),
          FlSpot(3, 108),
          FlSpot(4, 112),
          FlSpot(5, 115)
        ];
      default:
        return List.generate(
            12,
            (i) => FlSpot(
                i.toDouble(), 80 + 8 * i.toDouble() + (i % 3).toDouble()));
    }
  }

  // Goal distribution data
  static const _goalLabels = [
    'Weight Loss',
    'Muscle Gain',
    'Endurance',
    'Strength'
  ];
  static const _goalCounts = [24, 32, 18, 26];
  static const _goalColors = [
    Color(0xFF6C63FF),
    Color(0xFF43E97B),
    Color(0xFFFBBF24),
    Color(0xFFFF6B9D),
  ];

  // Session heatmap data (7 cols = days, 4 rows = weeks)
  static final _heatmapData =
      List.generate(28, (i) => (math.Random(i * 7).nextDouble() * 4).floor());

  double get _current => _revenueSpots.last.y;
  double get _previous => _revenueSpots.length < 2
      ? _current
      : _revenueSpots[_revenueSpots.length - 2].y;
  double get _pnl =>
      _previous != 0 ? ((_current - _previous) / _previous) * 100 : 0;

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.bg,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        title: Text(context.l10n.analytics,
            style: const TextStyle(
                color: AppTheme.brand,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_outlined,
                color: AppTheme.textSecondary, size: 20),
            onPressed: () => AppUtils.showToast(context, 'Report exported'),
            tooltip: 'Export Report',
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.brand,
          indicatorWeight: 2,
          labelColor: AppTheme.brand,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Clients'),
            Tab(text: 'Revenue'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_overviewTab(), _clientsTab(), _revenueTab()],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // OVERVIEW TAB
  // ---------------------------------------------------------------------------
  Widget _overviewTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        // ── KPI row ──
        Row(children: [
          _kpiCard('Total Clients', '48', Icons.group_outlined,
              AppTheme.cardBlue, '+12%', true),
          const SizedBox(width: 12),
          _kpiCard('Active Subs', '32', Icons.repeat_outlined,
              AppTheme.cardGreen, '+5%', true),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _kpiCard(
              'Revenue MTD',
              '\$2,450',
              Icons.account_balance_wallet_outlined,
              AppTheme.cardPurple,
              '+18%',
              true),
          const SizedBox(width: 12),
          _kpiCard('Avg Session', '45 min', Icons.timer_outlined,
              AppTheme.cardYellow, '-2%', false),
        ]),
        const SizedBox(height: 20),

        // ── Summary value card ──
        _card(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(context.l10n.estTotalValue,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 6),
                  Text('\$${_current.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5)),
                ]),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (_pnl >= 0 ? Colors.greenAccent : AppTheme.error)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: (_pnl >= 0 ? Colors.greenAccent : AppTheme.error)
                            .withValues(alpha: 0.4)),
                  ),
                  child: Row(children: [
                    Icon(
                        _pnl >= 0
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        color: _pnl >= 0 ? Colors.greenAccent : AppTheme.error,
                        size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${_pnl >= 0 ? '+' : ''}${_pnl.toStringAsFixed(1)}%',
                      style: TextStyle(
                          color:
                              _pnl >= 0 ? Colors.greenAccent : AppTheme.error,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text('vs last period',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Revenue trend chart ──
        _card(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(context.l10n.revenueTrend,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                // Period selector
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppTheme.bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _periodBtn('1D', 0),
                      _periodBtn('1W', 1),
                      _periodBtn('1M', 2),
                      _periodBtn('6M', 3),
                      _periodBtn('1Y', 4),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: LineChart(LineChartData(
                gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 10,
                    getDrawingHorizontalLine: (_) => FlLine(
                        color: AppTheme.divider.withValues(alpha: 0.6),
                        strokeWidth: 1)),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: _bottomTitle,
                          reservedSize: 26)),
                  leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 42,
                          getTitlesWidget: (v, _) => Text('\$${v.toInt()}',
                              style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 9)))),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) =>
                        const Color(0xFF0D0F11).withValues(alpha: 0.97),
                    tooltipBorder:
                        const BorderSide(color: AppTheme.divider, width: 1),
                    tooltipPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    getTooltipItems: (spots) => spots
                        .map((s) => LineTooltipItem(
                              '\$${s.y.toStringAsFixed(0)}',
                              const TextStyle(
                                  color: AppTheme.brand,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ))
                        .toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: _revenueSpots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: AppTheme.brand,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.brand.withValues(alpha: 0.15),
                            Colors.transparent,
                          ],
                        )),
                  )
                ],
                minY: _revenueSpots.map((e) => e.y).reduce(math.min) - 8,
                maxY: _revenueSpots.map((e) => e.y).reduce(math.max) + 8,
              )),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Goal distribution — Donut + legend ──
        _card(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Goal Distribution',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Donut chart
                SizedBox(
                  width: 130,
                  height: 130,
                  child: PieChart(PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 38,
                    sections: List.generate(_goalLabels.length, (i) {
                      final total = _goalCounts.reduce((a, b) => a + b);
                      return PieChartSectionData(
                        color: _goalColors[i],
                        value: _goalCounts[i].toDouble(),
                        title:
                            '${(_goalCounts[i] / total * 100).toStringAsFixed(0)}%',
                        radius: 28,
                        titleStyle: const TextStyle(
                            color: Colors.black87,
                            fontSize: 9,
                            fontWeight: FontWeight.bold),
                      );
                    }),
                  )),
                ),
                const SizedBox(width: 20),
                // Legend
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(_goalLabels.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                color: _goalColors[i],
                                borderRadius: BorderRadius.circular(2)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_goalLabels[i],
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12),
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 4),
                          Text('${_goalCounts[i]}',
                              style: TextStyle(
                                  color: _goalColors[i],
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                        ]),
                      );
                    }),
                  ),
                )
              ],
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Session activity heatmap ──
        _card(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Session Activity',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppTheme.cardGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppTheme.cardGreen.withValues(alpha: 0.3))),
                  child: const Text('Last 28 days',
                      style: TextStyle(
                          color: AppTheme.cardGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Day labels
            Row(
              children: [
                const SizedBox(width: 2),
                ...['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) => Expanded(
                      child: Center(
                        child: Text(d,
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w500)),
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 6),
            // Heatmap grid
            ...List.generate(4, (row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  children: List.generate(7, (col) {
                    final val = _heatmapData[row * 7 + col];
                    final opacity = val == 0
                        ? 0.06
                        : val == 1
                            ? 0.25
                            : val == 2
                                ? 0.50
                                : val == 3
                                    ? 0.78
                                    : 1.0;
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppTheme.cardGreen.withValues(alpha: opacity),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
            const SizedBox(height: 10),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Less',
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                const SizedBox(width: 6),
                ...List.generate(5, (i) {
                  final opacity = [0.06, 0.25, 0.50, 0.78, 1.0][i];
                  return Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.cardGreen.withValues(alpha: opacity),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
                const SizedBox(width: 6),
                const Text('More',
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
              ],
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Retention + Rating row ──
        Row(children: [
          Expanded(
            child: _card(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: AppTheme.cardIndigo.withValues(alpha: 0.15),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.loop_rounded,
                            color: AppTheme.cardIndigo, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                          child: Text('Retention',
                              style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12))),
                    ]),
                    const SizedBox(height: 12),
                    const Text('78%',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.78,
                        minHeight: 4,
                        backgroundColor: AppTheme.divider,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.cardIndigo),
                      ),
                    ),
                  ]),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _card(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: AppTheme.cardYellow.withValues(alpha: 0.15),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.star_rounded,
                            color: AppTheme.cardYellow, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                          child: Text('Avg Rating',
                              style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12))),
                    ]),
                    const SizedBox(height: 12),
                    const Text('4.8',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                            i < 4
                                ? Icons.star_rounded
                                : Icons.star_half_rounded,
                            color: AppTheme.cardYellow,
                            size: 14);
                      }),
                    ),
                  ]),
            ),
          ),
        ]),
        const SizedBox(height: 16),

        // ── Upcoming sessions ──
        _card(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Upcoming Sessions',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () => AppUtils.showToast(context, 'View all sessions'),
                  child: const Text('View all',
                      style: TextStyle(
                          color: AppTheme.brand,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._upcomingSessions.map((s) => _sessionRow(s)),
          ]),
        ),
      ],
    );
  }

  // Upcoming sessions mock data
  static const _upcomingSessions = [
    {
      'client': 'Omar Magdy',
      'time': 'Today, 4:00 PM',
      'type': 'Strength',
      'color': 0xFF6C63FF,
    },
    {
      'client': 'Sarah Hassan',
      'time': 'Tomorrow, 7:30 AM',
      'type': 'Endurance',
      'color': 0xFF43E97B,
    },
    {
      'client': 'Ahmed Ali',
      'time': 'Thu, 6:00 PM',
      'type': 'Weight Loss',
      'color': 0xFFFA8231,
    },
  ];

  Widget _sessionRow(Map<String, dynamic> s) {
    final color = Color(s['color'] as int);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.fitness_center, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s['client'] as String,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
            const SizedBox(height: 2),
            Text(s['time'] as String,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.3))),
          child: Text(s['type'] as String,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }

  // ---------------------------------------------------------------------------
  // CLIENTS TAB
  // ---------------------------------------------------------------------------
  Widget _clientsTab() {
    const clients = [
      {
        'name': 'Omar Magdy',
        'goal': 'Muscle Gain',
        'progress': 0.75,
        'sessions': 12,
        'streak': 5,
        'color': 0xFF6C63FF,
      },
      {
        'name': 'Ahmed Ali',
        'goal': 'Weight Loss',
        'progress': 0.60,
        'sessions': 8,
        'streak': 3,
        'color': 0xFF43E97B,
      },
      {
        'name': 'Sarah Hassan',
        'goal': 'Endurance',
        'progress': 0.85,
        'sessions': 15,
        'streak': 8,
        'color': 0xFFFBBF24,
      },
      {
        'name': 'Mohamed Salah',
        'goal': 'Strength',
        'progress': 0.50,
        'sessions': 6,
        'streak': 2,
        'color': 0xFFFF6B9D,
      },
    ];

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        // ── Summary row ──
        Row(children: [
          _kpiCard('Total Clients', '${clients.length}', Icons.group_outlined,
              AppTheme.cardBlue, '', true),
          const SizedBox(width: 12),
          _kpiCard('Avg Progress', '67%', Icons.trending_up_outlined,
              AppTheme.cardGreen, '+4%', true),
        ]),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.l10n.clientProgress,
                style: const TextStyle(
                    color: AppTheme.brand,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => AppUtils.showToast(context, 'Add new client'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: AppTheme.brand.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppTheme.brand.withValues(alpha: 0.3))),
                child: const Row(children: [
                  Icon(Icons.add, color: AppTheme.brand, size: 14),
                  SizedBox(width: 4),
                  Text('Add Client',
                      style: TextStyle(
                          color: AppTheme.brand,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        ...clients.map((c) {
          final color = Color(c['color'] as int);
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.divider)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  // Avatar placeholder with color
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: color.withValues(alpha: 0.4))),
                    child: Center(
                      child: Text(
                          (c['name'] as String)
                              .split(' ')
                              .map((w) => w[0])
                              .take(2)
                              .join(),
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c['name'] as String,
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Row(children: [
                            Icon(Icons.local_fire_department_rounded,
                                color: AppTheme.cardYellow, size: 12),
                            const SizedBox(width: 3),
                            Text('${c['streak']} day streak',
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11)),
                          ]),
                        ]),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: color.withValues(alpha: 0.3))),
                    child: Text(c['goal'] as String,
                        style: TextStyle(color: color, fontSize: 11)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  const Icon(Icons.fitness_center,
                      size: 13, color: AppTheme.textSecondary),
                  const SizedBox(width: 5),
                  Text('${c['sessions']} sessions',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ]),
                Text('${((c['progress'] as double) * 100).toInt()}% complete',
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: c['progress'] as double,
                  minHeight: 7,
                  backgroundColor: AppTheme.divider,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ]),
          );
        }),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // REVENUE TAB
  // ---------------------------------------------------------------------------
  Widget _revenueTab() {
    const transactions = [
      {
        'client': 'Omar Magdy',
        'amount': 250.0,
        'date': 'Mar 15, 2024',
        'type': 'Subscription',
        'color': 0xFF6C63FF,
        'icon': 0xe047, // Icons.repeat
      },
      {
        'client': 'Ahmed Ali',
        'amount': 180.0,
        'date': 'Mar 14, 2024',
        'type': 'Session Pack',
        'color': 0xFF43E97B,
        'icon': 0xe3e9, // Icons.sports
      },
      {
        'client': 'Sarah Hassan',
        'amount': 300.0,
        'date': 'Mar 13, 2024',
        'type': 'Program',
        'color': 0xFFFBBF24,
        'icon': 0xe8ef, // Icons.school
      },
      {
        'client': 'Mohamed Salah',
        'amount': 120.0,
        'date': 'Mar 12, 2024',
        'type': 'Single Session',
        'color': 0xFFFF6B9D,
        'icon': 0xe3a5, // Icons.fitness_center
      },
    ];

    final totalRevenue =
        transactions.map((t) => t['amount'] as double).reduce((a, b) => a + b);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        // ── Revenue summary header card ──
        _card(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(context.l10n.totalRevenue,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text('\$${totalRevenue.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5)),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.greenAccent.withValues(alpha: 0.3)),
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.trending_up_rounded,
                          color: Colors.greenAccent, size: 13),
                      SizedBox(width: 4),
                      Text('+18% this month',
                          style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ]),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: AppTheme.brand.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppTheme.brand.withValues(alpha: 0.2))),
                  child: const Icon(Icons.account_balance_wallet_outlined,
                      color: AppTheme.brand, size: 26),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // ── Revenue breakdown mini bar chart ──
            SizedBox(
              height: 100,
              child: BarChart(BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchCallback: (event, resp) {
                    setState(() {
                      _hoveredBarIndex = resp?.spot?.touchedBarGroupIndex;
                    });
                  },
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) =>
                        const Color(0xFF0D0F11).withValues(alpha: 0.97),
                    tooltipBorder:
                        const BorderSide(color: AppTheme.divider, width: 1),
                    getTooltipItem: (group, gIdx, rod, rIdx) => BarTooltipItem(
                      '\$${rod.toY.toInt()}',
                      TextStyle(
                          color: _goalColors[gIdx % _goalColors.length],
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                ),
                barGroups: List.generate(4, (i) {
                  final color = _goalColors[i];
                  final isHovered = _hoveredBarIndex == i;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                          toY: [250, 180, 300, 120][i].toDouble(),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              color.withValues(alpha: 0.5),
                              color,
                            ],
                          ),
                          width: isHovered ? 24 : 20,
                          borderRadius: BorderRadius.circular(6))
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            const labels = ['Sub', 'Pack', 'Prog', 'Single'];
                            final i = v.toInt();
                            return Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(i < labels.length ? labels[i] : '',
                                  style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 9)),
                            );
                          },
                          reservedSize: 22)),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
              )),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        // ── Pending payout card ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.brand.withValues(alpha: 0.12),
                    AppTheme.cardPurple.withValues(alpha: 0.08),
                  ]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.brand.withValues(alpha: 0.2))),
          child: Row(children: [
            const Icon(CupertinoIcons.arrow_down_circle_fill,
                color: AppTheme.brand, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pending Payout',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 2),
                    const Text('\$1,200.00',
                        style: TextStyle(
                            color: AppTheme.brand,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ]),
            ),
            GestureDetector(
              onTap: () => AppUtils.showToast(context, 'Payout requested'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                    color: AppTheme.brand,
                    borderRadius: BorderRadius.circular(10)),
                child: const Text('Withdraw',
                    style: TextStyle(
                        color: AppTheme.bg,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.l10n.recentTransactions,
                style: const TextStyle(
                    color: AppTheme.brand,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => AppUtils.showToast(context, 'View all transactions'),
              child: const Text('See all',
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        const SizedBox(height: 14),

        ...transactions.map((t) {
          final color = Color(t['color'] as int);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.divider)),
            child: Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.25))),
                child: Icon(Icons.attach_money, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(t['client'] as String,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(5)),
                        child: Text(t['type'] as String,
                            style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ),
                    ]),
                  ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('\$${(t['amount'] as double).toStringAsFixed(2)}',
                    style: TextStyle(
                        color: color,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(t['date'] as String,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 10)),
              ]),
            ]),
          );
        }),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------
  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider)),
      child: child,
    );
  }

  /// KPI card with sparkline mini-progress and icon
  Widget _kpiCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String change,
    bool positive,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.divider)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 15),
              ),
              if (change.isNotEmpty)
                Text(change,
                    style: TextStyle(
                        color: positive ? Colors.greenAccent : AppTheme.error,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          Text(title,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        ]),
      ),
    );
  }

  Widget _periodBtn(String label, int index) {
    final sel = _selectedPeriod == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedPeriod = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: sel ? AppTheme.brand : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(label,
            style: TextStyle(
                color: sel ? AppTheme.bg : AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _bottomTitle(double value, TitleMeta meta) {
    const style = TextStyle(color: AppTheme.textSecondary, fontSize: 9);
    switch (_selectedPeriod) {
      case 0:
        return Text('${value.toInt()}h', style: style);
      case 1:
        final idx = value.toInt();
        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
        return Text(idx < days.length ? days[idx] : '', style: style);
      case 2:
        return Text('W${value.toInt() + 1}', style: style);
      case 3:
        return Text('M${value.toInt() + 1}', style: style);
      default:
        return Text('M${value.toInt() + 1}', style: style);
    }
  }
}
