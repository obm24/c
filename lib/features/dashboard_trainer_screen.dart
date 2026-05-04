import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/c_ui_theme.dart';
import '../core/c_constants.dart';
import '../core/c_core_utils.dart';
import '../core/c_state.dart';
import '../core/c_visual_effects.dart';
import 'trainer_clients_screen.dart';

import 'trainer_forms_screens.dart';
import 'trainer_products_screen.dart';
import 'posts_screen.dart';
import 'trainer_analytics_screen.dart';

// TIME-OF-DAY GREETING
String greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${greeting()}, $name 👋',
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: AppConstants.kDefaultTitleFontSize,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Here's your business at a glance",
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        // Quick Stats Row
        Row(
          children: [
            Expanded(
                child: _QuickStatCard(
                    title: 'Active Clients',
                    value: '30',
                    icon: Icons.group_outlined,
                    color: const Color(0xFF4776E6))),
            const SizedBox(width: 12),
            Expanded(
                child: _QuickStatCard(
                    title: 'Revenue',
                    value: '\$4.2K',
                    icon: Icons.account_balance_wallet_outlined,
                    color: const Color(0xFF11998E))),
            const SizedBox(width: 12),
            Expanded(
                child: _QuickStatCard(
                    title: 'Pending',
                    value: '5',
                    icon: Icons.assignment_late_outlined,
                    color: const Color(0xFFFF416C))),
          ],
        ),
        const SizedBox(height: 30),
        const Text('Management Hub',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...cards.asMap().entries.map((entry) => TnTAppear(
              delay: Duration(milliseconds: entry.key * 35),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _TrainerDashCard(data: entry.value),
              ),
            )),
      ],
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _QuickStatCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return TnTPremiumCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        radius: 18,
        accentColor: color,
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        ]));
  }
}

class _TrainerCardData {
  final String label, badge;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;
  const _TrainerCardData(
      {required this.label,
      required this.badge,
      required this.icon,
      required this.gradient,
      required this.onTap});
}

class _TrainerDashCard extends StatelessWidget {
  final _TrainerCardData data;
  const _TrainerDashCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final d = data;
    return TnTPressable(
      onTap: d.onTap,
      pressedScale: 0.965,
      child: TnTPremiumCard(
        height: 86,
        padding: EdgeInsets.zero,
        radius: 22,
        accentColor: d.gradient.first,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      d.gradient.first.withValues(alpha: 0.22),
                      d.gradient.last.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned(
              right: -20,
              top: -20,
              child: Icon(d.icon,
                  color: Colors.white.withValues(alpha: 0.05), size: 120),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16)),
                  child: Icon(d.icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 18),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Text(d.label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 0.3)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(d.badge,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.95),
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                    ])),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white, size: 14),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
