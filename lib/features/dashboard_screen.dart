import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../core/c_ui_theme.dart';
import '../core/c_state.dart';
import 'dashboard_explore_screen.dart';
import 'dashboard_feed_screen.dart';
import 'dashboard_messages_screen.dart';
import 'dashboard_trainee_screen.dart';
import 'dashboard_trainer_screen.dart';

// =============================================================================
// DASHBOARD SHELL — wires the bottom nav bar to all tab pages.
// Supports both Trainer and Trainee roles, switching the "Home" tab content.
// =============================================================================

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  // Keep pages alive across tab switches via AutomaticKeepAliveClientMixin
  late final List<Widget> _pages;

  // Tab transition controller
  late final AnimationController _tabSwitchCtrl;
  late final Animation<double> _tabFadeAnim;

  // Unread message count — in production wire this to your MessagesBloc
  final int _unreadMessages = 3;

  @override
  void initState() {
    super.initState();

    _tabSwitchCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _tabFadeAnim = CurvedAnimation(
      parent: _tabSwitchCtrl,
      curve: Curves.easeInOut,
    );
    _tabSwitchCtrl.value = 1.0;

    final isTrainer = appState.isTrainer;

    _pages = [
      // Tab 0 — Home (role-aware)
      _KeepAlive(child: isTrainer ? const TrainerWorkoutPage() : const TraineeWorkoutPage()),
      // Tab 1 — Explore
      _KeepAlive(child: const ExplorePage()),
      // Tab 2 — Feed
      _KeepAlive(child: const HomeFeedPage()),
      // Tab 3 — Messages
      _KeepAlive(child: const MessagesDashboardScreen()),
    ];
  }

  @override
  void dispose() {
    _tabSwitchCtrl.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    if (index == _currentIndex) {
      // Scroll-to-top behaviour — pages should expose a scroll controller
      // for this; for now just a haptic pulse.
      HapticFeedback.selectionClick();
      return;
    }
    HapticFeedback.selectionClick();
    _tabSwitchCtrl.reverse().then((_) {
      if (!mounted) return;
      setState(() => _currentIndex = index);
      _tabSwitchCtrl.forward();
    });
  }

  // ── Tab metadata ──────────────────────────────────────────────────────────
  static const List<_TabItem> _trainerTabs = [
    _TabItem(
      label: 'Dashboard',
      icon: CupertinoIcons.house,
      activeIcon: CupertinoIcons.house_fill,
    ),
    _TabItem(
      label: 'Explore',
      icon: CupertinoIcons.compass,
      activeIcon: CupertinoIcons.compass_fill,
    ),
    _TabItem(
      label: 'Feed',
      icon: CupertinoIcons.square_grid_2x2,
      activeIcon: CupertinoIcons.square_grid_2x2_fill,
    ),
    _TabItem(
      label: 'Messages',
      icon: CupertinoIcons.chat_bubble_2,
      activeIcon: CupertinoIcons.chat_bubble_2_fill,
    ),
  ];

  static const List<_TabItem> _traineeTabs = [
    _TabItem(
      label: 'Home',
      icon: CupertinoIcons.house,
      activeIcon: CupertinoIcons.house_fill,
    ),
    _TabItem(
      label: 'Explore',
      icon: CupertinoIcons.compass,
      activeIcon: CupertinoIcons.compass_fill,
    ),
    _TabItem(
      label: 'Feed',
      icon: CupertinoIcons.square_grid_2x2,
      activeIcon: CupertinoIcons.square_grid_2x2_fill,
    ),
    _TabItem(
      label: 'Messages',
      icon: CupertinoIcons.chat_bubble_2,
      activeIcon: CupertinoIcons.chat_bubble_2_fill,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tabs = appState.isTrainer ? _trainerTabs : _traineeTabs;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      extendBody: true, // lets content bleed under the nav bar
      // ── Custom top bar ──────────────────────────────────────────────────
      appBar: _DashboardAppBar(
        currentIndex: _currentIndex,
        topPadding: topPadding,
      ),
      // ── Body ────────────────────────────────────────────────────────────
      body: FadeTransition(
        opacity: _tabFadeAnim,
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      // ── Bottom navigation bar ───────────────────────────────────────────
      bottomNavigationBar: _FloatingNavBar(
        tabs: tabs,
        currentIndex: _currentIndex,
        unreadMessages: _unreadMessages,
        onTap: _onTabTap,
      ),
    );
  }
}

// =============================================================================
// KEEP ALIVE WRAPPER
// =============================================================================
class _KeepAlive extends StatefulWidget {
  final Widget child;
  const _KeepAlive({required this.child});

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

// =============================================================================
// DASHBOARD APP BAR — context-aware title + notification + profile avatar
// =============================================================================
class _DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final double topPadding;

  const _DashboardAppBar({
    required this.currentIndex,
    required this.topPadding,
  });

  static const _titles = ['Dashboard', 'Explore', 'Feed', 'Messages'];
  static const _traineeTitles = ['Home', 'Explore', 'Feed', 'Messages'];

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isTrainer = appState.isTrainer;
    final titles = isTrainer ? _titles : _traineeTitles;
    final title = titles[currentIndex.clamp(0, titles.length - 1)];
    final initials =
        '${appState.profileFirstName.isNotEmpty ? appState.profileFirstName[0] : ''}'
        '${appState.profileLastName.isNotEmpty ? appState.profileLastName[0] : ''}'
            .toUpperCase();

    // Hide the app bar title on Home/Dashboard since those pages have their
    // own greeting header baked in.
    final hideTitle = currentIndex == 0;

    return AppBar(
      elevation: 0,
      backgroundColor: AppTheme.bg,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: hideTitle
          ? null
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: Text(
                title,
                key: ValueKey(title),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
            ),
      actions: [
        // Notification bell
        _NotificationBell(
          onTap: () =>
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications — coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              ),
        ),
        const SizedBox(width: 8),
        // Profile avatar
        GestureDetector(
          onTap: () =>
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile — coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              ),
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.brand.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.brand.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: AppTheme.brand,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// NOTIFICATION BELL with optional dot indicator
// =============================================================================
class _NotificationBell extends StatelessWidget {
  final VoidCallback onTap;
  const _NotificationBell({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const bool hasNotifications = true; // wire to real state

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              CupertinoIcons.bell,
              color: AppTheme.textPrimary,
              size: 22,
            ),
            if (hasNotifications)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// FLOATING NAV BAR — glassmorphic pill with animated indicator
// =============================================================================
class _FloatingNavBar extends StatelessWidget {
  final List<_TabItem> tabs;
  final int currentIndex;
  final int unreadMessages;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({
    required this.tabs,
    required this.currentIndex,
    required this.unreadMessages,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding + 16),
      height: 68,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppTheme.brand.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final tab = tabs[i];
          final isActive = i == currentIndex;
          final showBadge = i == 3 && unreadMessages > 0; // Messages tab

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.brand.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, anim) => ScaleTransition(
                            scale: anim,
                            child: child,
                          ),
                          child: Icon(
                            isActive ? tab.activeIcon : tab.icon,
                            key: ValueKey('${i}_$isActive'),
                            color: isActive
                                ? AppTheme.brand
                                : AppTheme.textSecondary,
                            size: 22,
                          ),
                        ),
                        // Unread badge on Messages icon
                        if (showBadge)
                          Positioned(
                            top: -4,
                            right: -6,
                            child: Container(
                              constraints: const BoxConstraints(
                                  minWidth: 16, minHeight: 16),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.error,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppTheme.surface, width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  unreadMessages > 99
                                      ? '99+'
                                      : '$unreadMessages',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color:
                            isActive ? AppTheme.brand : AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                      child: Text(tab.label),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// =============================================================================
// TAB ITEM DATA
// =============================================================================
class _TabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}