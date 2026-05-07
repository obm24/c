import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/c_ui_theme.dart';
import '../core/c_constants.dart';
import '../core/c_core_utils.dart';
import '../core/c_state.dart';
import '../core/c_visual_effects.dart';
import 'trainer_clients_screen.dart';
import 'trainer_forms_screen.dart';
import 'trainer_products_screen.dart';
import 'f_posts_screen.dart';
import 'trainer_analytics_screen.dart';

// greeting() has been moved to c_core_utils.dart (or keep here — but do NOT
// also define it in dashboard_trainee_screen.dart to avoid duplicate symbols).
// =============================================================================
// TRAINER WORKOUT / DASHBOARD PAGE
// =============================================================================
class TrainerWorkoutPage extends StatelessWidget {
  const TrainerWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final name = appState.profileFirstName;

    final cards = [
      _TrainerCardData(
        label: context.l10n.clients,
        badge: context.l10n.activeCount('30'),
        icon: Icons.people_rounded,
        gradient: [const Color(0xFF4776E6), const Color(0xFF8E54E9)],
        onTap: () => Navigator.push(
            context, AppRoutes.noTransitionRoute(const ClientsScreen())),
      ),
      _TrainerCardData(
        label: context.l10n.programmes,
        badge: context.l10n.plansCount('12'),
        icon: Icons.assignment_rounded,
        gradient: [const Color(0xFF11998E), const Color(0xFF38EF7D)],
        onTap: () => context.push('/programmes'),
      ),
      _TrainerCardData(
        label: context.l10n.forms,
        badge: context.l10n.pendingCount('2'),
        icon: Icons.fact_check_rounded,
        gradient: [const Color(0xFFE91E63), const Color(0xFFFF9800)],
        onTap: () => Navigator.push(context,
            AppRoutes.noTransitionRoute(const FormsManagementScreen())),
      ),
      _TrainerCardData(
        label: context.l10n.products,
        badge: context.l10n.itemsCount('8'),
        icon: Icons.shopping_bag_rounded,
        gradient: [const Color(0xFF1FA2FF), const Color(0xFF12D8FA)],
        onTap: () => Navigator.push(
            context, AppRoutes.noTransitionRoute(const ProductsScreen())),
      ),
      _TrainerCardData(
        label: context.l10n.posts,
        badge: context.l10n.postsCount('15'),
        icon: Icons.video_library_rounded,
        gradient: [const Color(0xFF6A3093), const Color(0xFFA044FF)],
        onTap: () => Navigator.push(
            context, AppRoutes.noTransitionRoute(const PostsScreen())),
      ),
      _TrainerCardData(
        label: context.l10n.analytics,
        badge: context.l10n.growthPercent('12'),
        icon: Icons.bar_chart_rounded,
        gradient: [const Color(0xFFFF416C), const Color(0xFFFF4B2B)],
        onTap: () => Navigator.push(
            context, AppRoutes.noTransitionRoute(const AnalyticsScreen())),
      ),
    ];

    return ListView(
      physics: const BouncingScrollPhysics(),
      // Extra top padding so content clears the AppBar; bottom clears nav bar
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 108),
      children: [
        // ── Greeting header ──────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${dashboardGreeting()}, $name 👋',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: AppConstants.kDefaultTitleFontSize,
                      fontWeight: FontWeight.bold,
                      // Explicitly disable decoration that can appear in some
                      // themes/environments as underlines on body text.
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Here's your business at a glance",
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Quick Stats Row ──────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _QuickStatCard(
                title: 'Active Clients',
                value: '30',
                icon: Icons.group_outlined,
                color: const Color(0xFF4776E6),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickStatCard(
                title: 'Revenue',
                value: '\$4.2K',
                icon: Icons.account_balance_wallet_outlined,
                color: const Color(0xFF11998E),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickStatCard(
                title: 'Pending',
                value: '5',
                icon: Icons.assignment_late_outlined,
                color: const Color(0xFFFF416C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // ── Quick Actions Row ────────────────────────────────────────────
        const _QuickActionsRow(),
        const SizedBox(height: 28),

        // ── Section header ───────────────────────────────────────────────
        const Text(
          'Management Hub',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 14),

        // ── Management cards ─────────────────────────────────────────────
        ...cards.asMap().entries.map(
              (entry) => TnTAppear(
                delay: Duration(milliseconds: entry.key * 40),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _TrainerDashCard(data: entry.value),
                ),
              ),
            ),

        // ── Recent Activity Section ──────────────────────────────────────
        const SizedBox(height: 4),
        const _RecentActivitySection(),
      ],
    );
  }
}

// =============================================================================
// QUICK STAT CARD
// =============================================================================
class _QuickStatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;

  const _QuickStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TnTPremiumCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      radius: AppConstants.kDefaultBorderRadius,
      accentColor: color,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10.5,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// QUICK ACTIONS ROW — frequently-used shortcuts
// =============================================================================
class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  static const _actions = [
    _QuickAction('New Client', Icons.person_add_rounded, Color(0xFF4776E6)),
    _QuickAction('Schedule', Icons.calendar_month_rounded, Color(0xFF11998E)),
    _QuickAction('Message', Icons.message_rounded, Color(0xFF6A3093)),
    _QuickAction('Invoice', Icons.receipt_long_rounded, Color(0xFFFF416C)),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _actions.map((a) => _QuickActionButton(action: a)).toList(),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  const _QuickAction(this.label, this.icon, this.color);
}

class _QuickActionButton extends StatelessWidget {
  final _QuickAction action;
  const _QuickActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return TnTPressable(
      onTap: () => AppUtils.showToast(context, '${action.label} — coming soon'),
      pressedScale: 0.93,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: 0.13),
              borderRadius:
                  BorderRadius.circular(AppConstants.kDefaultBorderRadius),
              border: Border.all(
                color: action.color.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Icon(action.icon, color: action.color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            action.label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// RECENT ACTIVITY SECTION
// =============================================================================
class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection();

  static const List<Map<String, dynamic>> _activities = [
    {
      'icon': Icons.person_add_rounded,
      'color': Color(0xFF4776E6),
      'title': 'New client request',
      'subtitle': 'Omar Magdy sent an intake form',
      'time': '2m ago',
    },
    {
      'icon': Icons.payments_rounded,
      'color': Color(0xFF11998E),
      'title': 'Payment received',
      'subtitle': 'Monthly subscription — \$120',
      'time': '1h ago',
    },
    {
      'icon': Icons.assignment_turned_in_rounded,
      'color': Color(0xFFFF9800),
      'title': 'Form submitted',
      'subtitle': 'Weekly check-in by Sara K.',
      'time': '3h ago',
    },
    {
      'icon': Icons.star_rounded,
      'color': Color(0xFFFFD700),
      'title': 'New review',
      'subtitle': 'Ahmed left you a 5-star review',
      'time': 'Yesterday',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
            GestureDetector(
              onTap: () =>
                  AppUtils.showToast(context, 'All activity — coming soon'),
              child: const Text(
                'See All',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TnTPremiumCard(
          padding: EdgeInsets.zero,
          radius: AppConstants.kDefaultBorderRadius,
          child: Column(
            children: _activities.asMap().entries.map((entry) {
              final i = entry.key;
              final a = entry.value;
              final isLast = i == _activities.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                (a['color'] as Color).withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(a['icon'] as IconData,
                              color: a['color'] as Color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a['title'] as String,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.5,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                a['subtitle'] as String,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          a['time'] as String,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    const Divider(
                      color: AppTheme.divider,
                      height: 1,
                      indent: 68,
                      endIndent: 0,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// TRAINER CARD DATA MODEL
// =============================================================================
class _TrainerCardData {
  final String label, badge;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _TrainerCardData({
    required this.label,
    required this.badge,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });
}

// =============================================================================
// TRAINER DASH CARD
// =============================================================================
class _TrainerDashCard extends StatelessWidget {
  final _TrainerCardData data;
  const _TrainerDashCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final d = data;
    return TnTPressable(
      onTap: d.onTap,
      pressedScale: 0.968,
      child: TnTPremiumCard(
        height: 80,
        padding: EdgeInsets.zero,
        radius: AppConstants.kDefaultBorderRadius,
        accentColor: d.gradient.first,
        child: Stack(
          children: [
            // Subtle gradient tint overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                  gradient: LinearGradient(
                    colors: [
                      d.gradient.first.withValues(alpha: 0.20),
                      d.gradient.last.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            // Ghost icon decoration (right side)
            Positioned(
              right: -16,
              top: -16,
              child: Icon(
                d.icon,
                color: Colors.white.withValues(alpha: 0.04),
                size: 110,
              ),
            ),
            // Row content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Icon container with gradient border
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          d.gradient.first.withValues(alpha: 0.35),
                          d.gradient.last.withValues(alpha: 0.20),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(
                          AppConstants.kDefaultBorderRadius),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Icon(d.icon, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          d.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            letterSpacing: 0.2,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            d.badge,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arrow indicator
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
