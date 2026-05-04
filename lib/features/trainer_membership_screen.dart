import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/c_ui_theme.dart';
import '../core/c_constants.dart';
import '../core/c_state.dart';
import '../core/c_core_utils.dart';
import '../core/c_custom_controls.dart';

// =============================================================================
// MEMBERSHIP SCREEN  (entry point from Settings)
// • Trainer  → "Membership" — unlocks client slots, analytics, branding tools
// • Trainee  → "Subscription" — unlocks advanced tracking, custom macros, AI coach
// =============================================================================

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------
enum _BillingCycle { monthly, quarterly, annual }

class _PlanTier {
  final String id;
  final String name;
  final String tagline;
  final Color accentColor;
  final Map<_BillingCycle, double> prices; // USD per cycle
  final List<String> features;
  final bool isCurrent;
  final bool isPopular;

  const _PlanTier({
    required this.id,
    required this.name,
    required this.tagline,
    required this.accentColor,
    required this.prices,
    required this.features,
    this.isCurrent = false,
    this.isPopular = false,
  });
}

// ---------------------------------------------------------------------------
// Trainer plans
// ---------------------------------------------------------------------------
final _trainerPlans = <_PlanTier>[
  _PlanTier(
    id: 'trainer_free',
    name: 'Starter',
    tagline: 'Build your foundation',
    accentColor: AppTheme.textSecondary,
    prices: {
      _BillingCycle.monthly: 0,
      _BillingCycle.quarterly: 0,
      _BillingCycle.annual: 0,
    },
    features: [
      'Up to 5 active clients',
      'Basic progress tracking',
      'Pre-built template library',
      'In-app messaging',
      'Standard profile listing',
    ],
    isCurrent: true,
  ),
  _PlanTier(
    id: 'trainer_pro',
    name: 'Pro',
    tagline: 'Engineered for results',
    accentColor: AppTheme.cardBlue,
    prices: {
      _BillingCycle.monthly: 19.99,
      _BillingCycle.quarterly: 54.99,
      _BillingCycle.annual: 179.99,
    },
    features: [
      'Up to 30 active clients',
      'Advanced body-comp analytics',
      'Custom macro & diet protocols',
      'Branded PDF reports & meal plans',
      'Priority profile placement',
      'Video call scheduling',
      'Client retention insights',
    ],
    isPopular: true,
  ),
  _PlanTier(
    id: 'trainer_elite',
    name: 'Elite',
    tagline: 'Run a training business',
    accentColor: AppTheme.cardYellow,
    prices: {
      _BillingCycle.monthly: 39.99,
      _BillingCycle.quarterly: 109.99,
      _BillingCycle.annual: 359.99,
    },
    features: [
      'Unlimited active clients',
      'Full white-label branding',
      'Revenue & earnings dashboard',
      'Team sub-trainer management',
      'API integrations (wearables)',
      'Dedicated account manager',
      'Early access to new features',
    ],
  ),
];

// ---------------------------------------------------------------------------
// Trainee plans
// ---------------------------------------------------------------------------
final _traineePlans = <_PlanTier>[
  _PlanTier(
    id: 'trainee_free',
    name: 'Free',
    tagline: 'Track the basics',
    accentColor: AppTheme.textSecondary,
    prices: {
      _BillingCycle.monthly: 0,
      _BillingCycle.quarterly: 0,
      _BillingCycle.annual: 0,
    },
    features: [
      'Log workouts & body weight',
      'Basic calorie counter',
      'Connect with one trainer',
      'Community feed access',
      'Standard progress charts',
    ],
    isCurrent: true,
  ),
  _PlanTier(
    id: 'trainee_plus',
    name: 'Plus',
    tagline: 'Hit your target — precisely',
    accentColor: AppTheme.cardGreen,
    prices: {
      _BillingCycle.monthly: 9.99,
      _BillingCycle.quarterly: 26.99,
      _BillingCycle.annual: 89.99,
    },
    features: [
      'Custom macro & micro tracking',
      'Body-comp trend analysis',
      'AI nutrition recommendations',
      'Unlimited trainer connections',
      'Ad-free experience',
      'Wearable device sync',
    ],
    isPopular: true,
  ),
  _PlanTier(
    id: 'trainee_peak',
    name: 'Peak',
    tagline: 'Perform like a professional',
    accentColor: AppTheme.cardPurple,
    prices: {
      _BillingCycle.monthly: 19.99,
      _BillingCycle.quarterly: 54.99,
      _BillingCycle.annual: 179.99,
    },
    features: [
      'Everything in Plus',
      'AI coach with adaptive planning',
      'Sports-specific performance metrics',
      'Injury recovery protocols',
      'Priority trainer matching',
      'Monthly 1-on-1 review call',
      'Exclusive challenge leaderboards',
    ],
  ),
];

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
extension on _BillingCycle {
  String get label {
    switch (this) {
      case _BillingCycle.monthly:
        return 'Monthly';
      case _BillingCycle.quarterly:
        return 'Quarterly';
      case _BillingCycle.annual:
        return 'Annual';
    }
  }

  int get months {
    switch (this) {
      case _BillingCycle.monthly:
        return 1;
      case _BillingCycle.quarterly:
        return 3;
      case _BillingCycle.annual:
        return 12;
    }
  }
}

String _formatPrice(double price, _BillingCycle cycle) {
  if (price == 0) return 'Free';
  return '\$${price.toStringAsFixed(2)}';
}

String _perCycleLabel(_BillingCycle cycle) {
  switch (cycle) {
    case _BillingCycle.monthly:
      return '/ month';
    case _BillingCycle.quarterly:
      return '/ 3 months';
    case _BillingCycle.annual:
      return '/ year';
  }
}

/// Returns how much the user saves (%) vs paying monthly for the same duration.
int _savingsPercent(_PlanTier plan, _BillingCycle cycle) {
  if (cycle == _BillingCycle.monthly) return 0;
  final monthly = plan.prices[_BillingCycle.monthly]!;
  if (monthly == 0) return 0;
  final paid = plan.prices[cycle]!;
  final wouldPay = monthly * cycle.months;
  if (wouldPay == 0) return 0;
  return (((wouldPay - paid) / wouldPay) * 100).round();
}

// =============================================================================
// MAIN SCREEN
// =============================================================================
class MembershipScreen extends StatefulWidget {
  final String role; // 'Trainer' | 'Trainee'
  const MembershipScreen({super.key, required this.role});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen>
    with SingleTickerProviderStateMixin {
  _BillingCycle _cycle = _BillingCycle.annual;
  late AnimationController _shimmerController;

  bool get _isTrainer => widget.role == 'Trainer';
  List<_PlanTier> get _plans => _isTrainer ? _trainerPlans : _traineePlans;

  String get _currentPlanId =>
      _isTrainer ? appState.trainerPlanId : appState.traineePlanId;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        title: Text(
          _isTrainer ? 'Membership' : 'Subscription',
          style: const TextStyle(color: AppTheme.brand),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 8,
          bottom: MediaQuery.of(context).padding.bottom + 40,
        ),
        children: [
          // ── Hero banner ─────────────────────────────────────────────────
          _HeroBanner(isTrainer: _isTrainer),
          const SizedBox(height: 28),

          // ── Billing cycle toggle ─────────────────────────────────────────
          _BillingCycleToggle(
            selected: _cycle,
            onChanged: (c) {
              HapticFeedback.selectionClick();
              setState(() => _cycle = c);
            },
          ),
          const SizedBox(height: 8),

          // ── Free trial notice ─────────────────────────────────────────────
          _TrialBanner(isTrainer: _isTrainer),
          const SizedBox(height: 20),

          // ── Plan cards ───────────────────────────────────────────────────
          ..._plans.map((plan) => _PlanCard(
                plan: plan,
                cycle: _cycle,
                isCurrentPlan: plan.id == _currentPlanId,
                onSelect: () => _onSelectPlan(plan),
              )),

          const SizedBox(height: 24),

          // ── Feature comparison matrix ────────────────────────────────────
          _FeatureMatrix(plans: _plans, cycle: _cycle),

          const SizedBox(height: 24),

          // ── FAQ / trust signals ──────────────────────────────────────────
          _TrustSection(isTrainer: _isTrainer),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _onSelectPlan(_PlanTier plan) {
    HapticFeedback.mediumImpact();
    final price = plan.prices[_cycle]!;
    if (price == 0) {
      // Downgrade confirmation
      showDialog(
        context: context,
        builder: (_) => _DowngradeDialog(
          plan: plan,
          isTrainer: _isTrainer,
          onConfirm: () {
            if (_isTrainer) {
              appState.setTrainerPlan(plan.id);
            } else {
              appState.setTraineePlan(plan.id);
            }
            Navigator.pop(context);
            AppUtils.showToast(context, 'Downgraded to ${plan.name}');
          },
        ),
      );
      return;
    }
    // Navigate to checkout
    Navigator.push(
      context,
      AppRoutes.noTransitionRoute(
        _CheckoutScreen(
          plan: plan,
          cycle: _cycle,
          isTrainer: _isTrainer,
          onSuccess: () {
            if (_isTrainer) {
              appState.setTrainerPlan(plan.id);
            } else {
              appState.setTraineePlan(plan.id);
            }
            // Pop checkout, then show confirmation on top of membership screen
            Navigator.pop(context);
            Navigator.push(
              context,
              AppRoutes.noTransitionRoute(
                _ConfirmationScreen(plan: plan, cycle: _cycle),
              ),
            );
          },
        ),
      ),
    );
  }
}

// =============================================================================
// HERO BANNER
// =============================================================================
class _HeroBanner extends StatelessWidget {
  final bool isTrainer;
  const _HeroBanner({required this.isTrainer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isTrainer
              ? [
                  AppTheme.cardBlue.withValues(alpha: 0.15),
                  AppTheme.cardPurple.withValues(alpha: 0.08)
                ]
              : [
                  AppTheme.cardGreen.withValues(alpha: 0.15),
                  AppTheme.cardBlue.withValues(alpha: 0.08)
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTrainer
              ? AppTheme.cardBlue.withValues(alpha: 0.3)
              : AppTheme.cardGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (isTrainer ? AppTheme.cardBlue : AppTheme.cardGreen)
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isTrainer ? 'TRAINER MEMBERSHIP' : 'TRAINEE SUBSCRIPTION',
              style: TextStyle(
                color: isTrainer ? AppTheme.cardBlue : AppTheme.cardGreen,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isTrainer
                ? 'Scale your coaching.\nGrow your impact.'
                : 'Every rep tracked.\nEvery gram accounted for.',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isTrainer
                ? 'Unlock the tools elite trainers use to manage more clients, deliver branded experiences, and build a sustainable fitness business.'
                : 'Whether you\'re chasing 88 kg on the scale or conditioning for your next MMA bout — upgrade to get the precision tools your goal demands.',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// BILLING CYCLE TOGGLE
// =============================================================================
class _BillingCycleToggle extends StatelessWidget {
  final _BillingCycle selected;
  final ValueChanged<_BillingCycle> onChanged;

  const _BillingCycleToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: _BillingCycle.values.map((cycle) {
          final isSelected = cycle == selected;
          final savings = cycle != _BillingCycle.monthly
              ? _savingsPercent(_trainerPlans[1], cycle)
              : 0;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(cycle),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.brand : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Column(
                  children: [
                    Text(
                      cycle.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? AppTheme.buttonText
                            : AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (savings > 0)
                      Text(
                        'Save $savings%',
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.buttonText.withValues(alpha: 0.7)
                              : AppTheme.cardGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// =============================================================================
// TRIAL BANNER
// =============================================================================
class _TrialBanner extends StatelessWidget {
  final bool isTrainer;
  const _TrialBanner({required this.isTrainer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardYellow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.cardYellow.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt, color: AppTheme.cardYellow, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isTrainer
                  ? '14-day free trial on Pro & Elite — no card required to start.'
                  : '7-day free trial on Plus & Peak — cancel anytime before billing.',
              style: const TextStyle(
                  color: AppTheme.cardYellow, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PLAN CARD
// =============================================================================
class _PlanCard extends StatefulWidget {
  final _PlanTier plan;
  final _BillingCycle cycle;
  final bool isCurrentPlan;
  final VoidCallback onSelect;

  const _PlanCard({
    required this.plan,
    required this.cycle,
    required this.isCurrentPlan,
    required this.onSelect,
  });

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _expandController;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Auto-expand popular plan
    if (widget.plan.isPopular) {
      _expanded = true;
      _expandController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.plan.prices[widget.cycle]!;
    final savings = _savingsPercent(widget.plan, widget.cycle);
    final isFree = price == 0;
    final accent = widget.plan.accentColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isCurrentPlan
              ? AppTheme.brand
              : widget.plan.isPopular
                  ? accent.withValues(alpha: 0.5)
                  : AppTheme.divider,
          width: widget.isCurrentPlan || widget.plan.isPopular ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // ── Card header ─────────────────────────────────────────────────
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _expanded = !_expanded;
                _expanded
                    ? _expandController.forward()
                    : _expandController.reverse();
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  // Accent dot
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.plan.name,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (widget.isCurrentPlan)
                              _badge('CURRENT', AppTheme.brand,
                                  AppTheme.buttonText),
                            if (widget.plan.isPopular && !widget.isCurrentPlan)
                              _badge('POPULAR', accent, AppTheme.bg),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.plan.tagline,
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Price column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isFree ? 'Free' : _formatPrice(price, widget.cycle),
                        style: TextStyle(
                          color: isFree ? AppTheme.textSecondary : accent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isFree)
                        Text(
                          _perCycleLabel(widget.cycle),
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 10),
                        ),
                      if (savings > 0 && !isFree)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.cardGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '-$savings%',
                            style: const TextStyle(
                                color: AppTheme.cardGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.keyboard_arrow_down,
                        color: AppTheme.textSecondary, size: 20),
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable features ─────────────────────────────────────────
          SizeTransition(
            sizeFactor: CurvedAnimation(
                parent: _expandController, curve: Curves.easeInOut),
            child: Column(
              children: [
                const Divider(color: AppTheme.divider, height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  child: Column(
                    children: [
                      ...widget.plan.features.map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle, color: accent, size: 16),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(f,
                                    style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 13,
                                        height: 1.4)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!widget.isCurrentPlan)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: SolidConfirmButton(
                      label: isFree
                          ? 'Downgrade to ${widget.plan.name}'
                          : 'Start ${isFree ? '' : '7-day trial · '}${widget.plan.name}',
                      height: AppConstants.kDefaultButtonHeightLarge,
                      onPressed: widget.onSelect,
                    ),
                  ),
                if (widget.isCurrentPlan)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: Row(
                      children: [
                        const Icon(Icons.verified,
                            color: AppTheme.brand, size: 16),
                        const SizedBox(width: 8),
                        const Text('This is your active plan',
                            style: TextStyle(
                                color: AppTheme.brand,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
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

  Widget _badge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style:
              TextStyle(color: fg, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}

// =============================================================================
// FEATURE COMPARISON MATRIX
// =============================================================================
class _FeatureMatrix extends StatelessWidget {
  final List<_PlanTier> plans;
  final _BillingCycle cycle;

  const _FeatureMatrix({required this.plans, required this.cycle});

  @override
  Widget build(BuildContext context) {
    // Build union of all features in tier order (free → top)
    final allFeatures = plans.expand((p) => p.features).toSet().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Plan Comparison',
          style: TextStyle(
            color: AppTheme.brand,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Column(
            children: [
              // ── Header row ──────────────────────────────────────────────
              _MatrixRow(
                label: '',
                cells: plans
                    .map((p) => _MatrixCell.header(p.name, p.accentColor))
                    .toList(),
                isHeader: true,
              ),
              const Divider(color: AppTheme.divider, height: 1),
              // ── Feature rows ─────────────────────────────────────────────
              ...allFeatures.asMap().entries.map((entry) {
                final feature = entry.value;
                final isLast = entry.key == allFeatures.length - 1;
                return Column(
                  children: [
                    _MatrixRow(
                      label: feature,
                      cells: plans.map((p) {
                        final hasIt = p.features.contains(feature);
                        return hasIt
                            ? _MatrixCell.check(p.accentColor)
                            : const _MatrixCell.cross();
                      }).toList(),
                    ),
                    if (!isLast)
                      const Divider(color: AppTheme.divider, height: 1),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _MatrixCell {
  final bool isHeader;
  final bool isCheck;
  final String? headerText;
  final Color color;

  const _MatrixCell.header(String text, Color c)
      : isHeader = true,
        isCheck = false,
        headerText = text,
        color = c;

  const _MatrixCell.check(Color c)
      : isHeader = false,
        isCheck = true,
        headerText = null,
        color = c;

  const _MatrixCell.cross()
      : isHeader = false,
        isCheck = false,
        headerText = null,
        color = AppTheme.textSecondary;
}

class _MatrixRow extends StatelessWidget {
  final String label;
  final List<_MatrixCell> cells;
  final bool isHeader;

  const _MatrixRow(
      {required this.label, required this.cells, this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                color: isHeader ? AppTheme.textSecondary : AppTheme.textPrimary,
                fontSize: 12,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          ...cells.map((cell) => Expanded(
                child: Center(
                  child: cell.isHeader
                      ? Text(
                          cell.headerText!,
                          style: TextStyle(
                            color: cell.color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Icon(
                          cell.isCheck ? Icons.check_circle : Icons.remove,
                          color: cell.isCheck
                              ? cell.color
                              : AppTheme.textSecondary.withValues(alpha: 0.4),
                          size: 16,
                        ),
                ),
              )),
        ],
      ),
    );
  }
}

// =============================================================================
// TRUST SECTION
// =============================================================================
class _TrustSection extends StatelessWidget {
  final bool isTrainer;
  const _TrustSection({required this.isTrainer});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Our Commitment',
          style: TextStyle(
            color: AppTheme.brand,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _trustItem(
                Icons.lock_outline, 'Secure\nPayment', AppTheme.cardBlue),
            _trustItem(
                Icons.cancel_outlined, 'Cancel\nAnytime', AppTheme.cardGreen),
            _trustItem(
                Icons.replay_outlined, '30-Day\nRefund', AppTheme.cardYellow),
          ],
        ),
        const SizedBox(height: 20),
        const _FaqItem(
          question: 'Can I switch plans mid-cycle?',
          answer:
              'Yes. You can upgrade or downgrade at any time. Upgrades are prorated immediately; downgrades take effect at the end of your billing period.',
        ),
        const _FaqItem(
          question: 'What happens if my payment fails?',
          answer:
              'We\'ll retry your payment over 3 days and notify you via push and email. Your plan remains active during this grace period.',
        ),
        const _FaqItem(
          question: 'Is my billing information secure?',
          answer:
              'All payment data is processed through PCI-DSS compliant gateways. We never store your full card details on our servers.',
        ),
      ],
    );
  }

  Widget _trustItem(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _open = !_open);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: const Icon(Icons.keyboard_arrow_down,
                      color: AppTheme.textSecondary, size: 18),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  widget.answer,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
              crossFadeState:
                  _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// DOWNGRADE DIALOG
// =============================================================================
class _DowngradeDialog extends StatelessWidget {
  final _PlanTier plan;
  final bool isTrainer;
  final VoidCallback onConfirm;

  const _DowngradeDialog(
      {required this.plan, required this.isTrainer, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius)),
      titlePadding: EdgeInsets.zero,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text('Downgrade to ${plan.name}?',
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: AppConstants.kDefaultTitleFontSize,
                    fontWeight: FontWeight.bold)),
          ),
          const Divider(color: AppTheme.divider, height: 1),
        ],
      ),
      content: Text(
        isTrainer
            ? 'Your premium features will remain active until the end of your billing period. After that, client slots above the Starter limit will become read-only.'
            : 'Your premium features remain active until the end of your billing period. Advanced analytics and AI recommendations will be disabled upon expiry.',
        style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: AppConstants.kDefaultSubtitleFontSize,
            height: 1.5),
      ),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: const Text('Keep Plan',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlineActionButton(
                    label: 'Downgrade',
                    height: AppConstants.kDefaultButtonHeightLarge,
                    textColor: AppTheme.error,
                    borderColor: AppTheme.error,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      onConfirm();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ],
    );
  }
}

// =============================================================================
// CHECKOUT SCREEN
// =============================================================================
class _CheckoutScreen extends StatefulWidget {
  final _PlanTier plan;
  final _BillingCycle cycle;
  final bool isTrainer;
  final VoidCallback onSuccess;

  const _CheckoutScreen({
    required this.plan,
    required this.cycle,
    required this.isTrainer,
    required this.onSuccess,
  });

  @override
  State<_CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<_CheckoutScreen> {
  int _step = 0; // 0 = phone verification, 1 = payment, 2 = processing

  // Phone verification state
  String _selectedCode = 'assets/images/flags/eg.svg +20';
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _otpSent = false;
  bool _otpVerified = false;

  // Payment state
  final _cardCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedCode = appState.profileCountryCode;
    _phoneCtrl.text = appState.profilePhone;
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _cardCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  String get _dialCode {
    final parts = _selectedCode.split(' ');
    return parts.length > 1 ? parts.last : '';
  }

  int get _expectedPhoneLength {
    // Simplified length rules per dial code
    const Map<String, int> lengths = {
      '+20': 10,
      '+1': 10,
      '+44': 10,
      '+971': 9,
      '+966': 9,
      '+91': 10,
      '+49': 11,
      '+33': 9,
    };
    return lengths[_dialCode] ?? 9;
  }

  bool get _phoneValid => _phoneCtrl.text.length >= _expectedPhoneLength;

  @override
  Widget build(BuildContext context) {
    final price = widget.plan.prices[widget.cycle]!;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        title: Text(
          'Checkout — ${widget.plan.name}',
          style: const TextStyle(color: AppTheme.brand),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).padding.bottom + 40,
        ),
        children: [
          // ── Order summary ─────────────────────────────────────────────────
          _OrderSummary(plan: widget.plan, cycle: widget.cycle),
          const SizedBox(height: 24),

          // ── Step indicator ────────────────────────────────────────────────
          _StepIndicator(currentStep: _step),
          const SizedBox(height: 24),

          // ── Error banner ──────────────────────────────────────────────────
          if (_error != null) ...[
            _ErrorBanner(message: _error!),
            const SizedBox(height: 16),
          ],

          // ── Step 0: Phone verification ────────────────────────────────────
          if (_step == 0) ...[
            const Text(
              'Verify your number',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'We\'ll send a one-time code to confirm your identity before processing payment.',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 20),
            _PhoneField(
              selectedCode: _selectedCode,
              phoneCtrl: _phoneCtrl,
              onCodeChanged: (code) => setState(() => _selectedCode = code),
              expectedLength: _expectedPhoneLength,
            ),
            if (_otpSent && !_otpVerified) ...[
              const SizedBox(height: 16),
              _OtpField(
                ctrl: _otpCtrl,
                onResend: _sendOtp,
                onChanged: (_) => setState(() {}),
              ),
            ],
            const SizedBox(height: 24),
            if (!_otpVerified)
              AnimatedLoginButton(
                label: _otpSent ? 'Verify Code' : 'Send Verification Code',
                onPressed: _otpSent ? _verifyOtp : _sendOtp,
              ),
            if (_otpVerified)
              SolidConfirmButton(
                label: 'Continue to Payment',
                icon: Icons.arrow_forward_rounded,
                height: AppConstants.kDefaultButtonHeightLarge,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() => _step = 1);
                },
              ),
          ],

          // ── Step 1: Payment ───────────────────────────────────────────────
          if (_step == 1) ...[
            const Text(
              'Payment details',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _cardField(
              ctrl: _nameCtrl,
              label: 'Cardholder Name',
              hint: 'Name as on card',
              keyboard: TextInputType.name,
            ),
            const SizedBox(height: 14),
            _cardField(
              ctrl: _cardCtrl,
              label: 'Card Number',
              hint: '•••• •••• •••• ••••',
              keyboard: TextInputType.number,
              maxLength: 19,
              formatters: [_CardNumberFormatter()],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _cardField(
                    ctrl: _expiryCtrl,
                    label: 'Expiry',
                    hint: 'MM / YY',
                    keyboard: TextInputType.number,
                    maxLength: 7,
                    formatters: [_ExpiryFormatter()],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _cardField(
                    ctrl: _cvvCtrl,
                    label: 'CVV',
                    hint: '•••',
                    keyboard: TextInputType.number,
                    maxLength: 4,
                    obscure: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.lock, color: AppTheme.textSecondary, size: 13),
                SizedBox(width: 6),
                Text('256-bit SSL encrypted · PCI-DSS compliant',
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 28),
            AnimatedLoginButton(
              label:
                  'Pay ${_formatPrice(price, widget.cycle)} · Start ${widget.plan.name}',
              onPressed: _processPayment,
            ),
            const SizedBox(height: 12),
            OutlineActionButton(
              label: 'Back',
              height: AppConstants.kDefaultButtonHeightLarge,
              textColor: AppTheme.textPrimary,
              borderColor: AppTheme.textSecondary,
              onPressed: () => setState(() => _step = 0),
            ),
          ],
        ],
      ),
    );
  }

  Widget _cardField({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    TextInputType keyboard = TextInputType.text,
    int? maxLength,
    List<TextInputFormatter>? formatters,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: AppConstants.kDefaultSubtitleFontSize)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboard,
          obscureText: obscure,
          maxLength: maxLength,
          inputFormatters: formatters,
          buildCounter: (_,
                  {required currentLength, required isFocused, maxLength}) =>
              null,
          style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: AppConstants.kDefaultSubtitleFontSize),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.textSecondary),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.02),
            enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                borderSide: const BorderSide(
                    color: AppTheme.textSecondary, width: 1.5)),
            focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                borderSide: const BorderSide(color: AppTheme.brand, width: 2)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
          onChanged: (_) => setState(() => _error = null),
        ),
      ],
    );
  }

  Future<void> _sendOtp() async {
    if (!_phoneValid) {
      setState(() => _error =
          'Please enter a valid $_dialCode phone number ($_expectedPhoneLength digits).');
      return;
    }
    setState(() {
      _error = null;
    });
    // Simulate OTP API call
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _otpSent = true;
    });
    AppUtils.showToast(context, 'OTP sent to $_dialCode ${_phoneCtrl.text}');
  }

  Future<void> _verifyOtp() async {
    if (_otpCtrl.text.length < 4) {
      setState(
          () => _error = 'Please enter the 6-digit code sent to your phone.');
      return;
    }
    setState(() => _error = null);
    // Simulate verification — in production replace with API call
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    // Mock: any code passes
    setState(() => _otpVerified = true);
    HapticFeedback.heavyImpact();
    AppUtils.showToast(context, 'Phone verified!');
  }

  Future<void> _processPayment() async {
    // Basic validation
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter the cardholder name.');
      return;
    }
    if (_cardCtrl.text.replaceAll(' ', '').length < 16) {
      setState(() => _error = 'Please enter a valid 16-digit card number.');
      return;
    }
    if (_expiryCtrl.text.length < 5) {
      setState(() => _error = 'Please enter a valid expiry date (MM / YY).');
      return;
    }
    if (_cvvCtrl.text.length < 3) {
      setState(() => _error = 'Please enter your CVV security code.');
      return;
    }
    setState(() {
      _error = null;
    });
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    widget.onSuccess();
  }
}

// ---------------------------------------------------------------------------
// Phone field with country code selector
// ---------------------------------------------------------------------------
class _PhoneField extends StatelessWidget {
  final String selectedCode;
  final TextEditingController phoneCtrl;
  final ValueChanged<String> onCodeChanged;
  final int expectedLength;

  const _PhoneField({
    required this.selectedCode,
    required this.phoneCtrl,
    required this.onCodeChanged,
    required this.expectedLength,
  });

  String get _flagPath => selectedCode.split(' ').first;
  String get _dialCode {
    final parts = selectedCode.split(' ');
    return parts.length > 1 ? parts.last : '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mobile Number',
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: AppConstants.kDefaultSubtitleFontSize)),
        const SizedBox(height: 8),
        Row(
          children: [
            // Country code selector
            GestureDetector(
              onTap: () => _showCodePicker(context),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius:
                      BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                  border: const BorderSide(
                          color: AppTheme.textSecondary, width: 1.5)
                      .asBorderSide(),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 16,
                      child: Image.asset(_flagPath, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 6),
                    Text(_dialCode,
                        style: const TextStyle(
                            color: AppTheme.textPrimary, fontSize: 14)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down,
                        color: AppTheme.textSecondary, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                maxLength: expectedLength,
                buildCounter: (_,
                        {required currentLength,
                        required isFocused,
                        maxLength}) =>
                    null,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: AppConstants.kDefaultSubtitleFontSize),
                decoration: InputDecoration(
                  hintText: '${'•' * expectedLength} ($expectedLength digits)',
                  hintStyle: const TextStyle(color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.02),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          AppConstants.kDefaultBorderRadius),
                      borderSide: const BorderSide(
                          color: AppTheme.textSecondary, width: 1.5)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          AppConstants.kDefaultBorderRadius),
                      borderSide:
                          const BorderSide(color: AppTheme.brand, width: 2)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCodePicker(BuildContext context) {
    HapticFeedback.lightImpact();
    final codes = AppConstants.kCountryCodes;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (_) => _CodePickerSheet(
        codes: codes,
        selected: selectedCode,
        onSelected: onCodeChanged,
      ),
    );
  }
}

class _CodePickerSheet extends StatefulWidget {
  final List<String> codes;
  final String selected;
  final ValueChanged<String> onSelected;

  const _CodePickerSheet(
      {required this.codes, required this.selected, required this.onSelected});

  @override
  State<_CodePickerSheet> createState() => _CodePickerSheetState();
}

class _CodePickerSheetState extends State<_CodePickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.codes
        .where((c) => c.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextFormField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search country code...',
                hintStyle: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 14),
                prefixIcon: const Icon(Icons.search,
                    color: AppTheme.textSecondary, size: 20),
                filled: true,
                fillColor: AppTheme.bg,
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        AppConstants.kDefaultBorderRadius),
                    borderSide:
                        const BorderSide(color: AppTheme.divider, width: 1)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        AppConstants.kDefaultBorderRadius),
                    borderSide:
                        const BorderSide(color: AppTheme.brand, width: 2)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              ),
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final entry = filtered[i];
                final flagPath = entry.split(' ').first;
                final code = entry.split(' ').last;
                final isSelected = entry == widget.selected;
                return ListTile(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onSelected(entry);
                    Navigator.pop(context);
                  },
                  leading: SizedBox(
                    width: 28,
                    height: 20,
                    child: Image.asset(flagPath, fit: BoxFit.cover),
                  ),
                  title: Text(code,
                      style: TextStyle(
                          color: isSelected
                              ? AppTheme.brand
                              : AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal)),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppTheme.brand, size: 16)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// OTP field
// ---------------------------------------------------------------------------
class _OtpField extends StatelessWidget {
  final TextEditingController ctrl;
  final VoidCallback onResend;
  final ValueChanged<String>? onChanged;

  const _OtpField({required this.ctrl, required this.onResend, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Verification Code',
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: AppConstants.kDefaultSubtitleFontSize)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                buildCounter: (_,
                        {required currentLength,
                        required isFocused,
                        maxLength}) =>
                    null,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    letterSpacing: 6,
                    fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: '— — — — — —',
                  hintStyle: const TextStyle(
                      color: AppTheme.textSecondary, letterSpacing: 2),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.02),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          AppConstants.kDefaultBorderRadius),
                      borderSide: const BorderSide(
                          color: AppTheme.textSecondary, width: 1.5)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          AppConstants.kDefaultBorderRadius),
                      borderSide:
                          const BorderSide(color: AppTheme.brand, width: 2)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                ),
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: onResend,
              child: const Text('Resend',
                  style: TextStyle(
                      color: AppTheme.brand,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Order summary
// ---------------------------------------------------------------------------
class _OrderSummary extends StatelessWidget {
  final _PlanTier plan;
  final _BillingCycle cycle;

  const _OrderSummary({required this.plan, required this.cycle});

  @override
  Widget build(BuildContext context) {
    final price = plan.prices[cycle]!;
    final savings = _savingsPercent(plan, cycle);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: plan.accentColor.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: plan.accentColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  plan.name,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                _formatPrice(price, cycle),
                style: TextStyle(
                    color: plan.accentColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${cycle.label} billing ${_perCycleLabel(cycle)}',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12),
              ),
              if (savings > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.cardGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('You save $savings%',
                      style: const TextStyle(
                          color: AppTheme.cardGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: AppTheme.divider),
          const SizedBox(height: 6),
          Row(
            children: const [
              Icon(Icons.bolt, color: AppTheme.cardYellow, size: 14),
              SizedBox(width: 6),
              Text('Includes 7-day free trial — billed after trial ends',
                  style: TextStyle(color: AppTheme.cardYellow, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step indicator
// ---------------------------------------------------------------------------
class _StepIndicator extends StatelessWidget {
  final int currentStep;

  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const labels = ['Verify', 'Payment'];
    return Row(
      children: labels.asMap().entries.map((entry) {
        final idx = entry.key;
        final label = entry.value;
        final isDone = idx < currentStep;
        final isActive = idx == currentStep;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppTheme.cardGreen
                            : isActive
                                ? AppTheme.brand
                                : AppTheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDone
                              ? AppTheme.cardGreen
                              : isActive
                                  ? AppTheme.brand
                                  : AppTheme.divider,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: isDone
                          ? const Icon(Icons.check,
                              color: AppTheme.bg, size: 14)
                          : Text(
                              '${idx + 1}',
                              style: TextStyle(
                                color: isActive
                                    ? AppTheme.buttonText
                                    : AppTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 4),
                    Text(label,
                        style: TextStyle(
                          color: isActive || isDone
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                          fontSize: 11,
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.normal,
                        )),
                  ],
                ),
              ),
              if (idx < labels.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 20),
                    color: isDone ? AppTheme.cardGreen : AppTheme.divider,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Error banner
// ---------------------------------------------------------------------------
class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    color: AppTheme.error, fontSize: 13, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CONFIRMATION SCREEN
// =============================================================================
class _ConfirmationScreen extends StatelessWidget {
  final _PlanTier plan;
  final _BillingCycle cycle;

  const _ConfirmationScreen({required this.plan, required this.cycle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Animated success icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (_, v, __) => Transform.scale(
                  scale: v,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.cardGreen.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppTheme.cardGreen.withValues(alpha: 0.4),
                          width: 2),
                    ),
                    child: const Icon(Icons.check_circle_outline_rounded,
                        color: AppTheme.cardGreen, size: 50),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: plan.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(plan.name.toUpperCase(),
                    style: TextStyle(
                        color: plan.accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2)),
              ),
              const SizedBox(height: 16),
              const Text(
                'You\'re all set!',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your ${plan.name} plan is now active. Every feature has been unlocked — time to make progress that actually shows.',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 14, height: 1.6),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
              SolidConfirmButton(
                label: 'Back to Settings',
                icon: Icons.settings_outlined,
                height: AppConstants.kDefaultButtonHeightLarge,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  // Pop back to settings (2 screens back)
                  Navigator.of(context)
                    ..pop()
                    ..pop();
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// TEXT INPUT FORMATTERS  (card number & expiry)
// =============================================================================
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');
    String formatted = digits;
    if (digits.length >= 3) {
      formatted = '${digits.substring(0, 2)} / ${digits.substring(2)}';
    } else if (digits.length == 2) {
      formatted = '$digits / ';
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// =============================================================================
// BORDER SIDE EXTENSION (convenience)
// =============================================================================
extension on BorderSide {
  BoxBorder asBorderSide() => Border(
        top: this,
        bottom: this,
        left: this,
        right: this,
      );
}
