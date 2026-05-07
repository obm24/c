import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../core/c_ui_theme.dart';
import '../core/c_constants.dart';
import '../core/c_state.dart';
import '../core/c_core_utils.dart';
import 'dashboard_explore_screen.dart';
import 'dashboard_feed_screen.dart';
import 'dashboard_messages_screen.dart';
import 'dashboard_trainee_screen.dart';
import 'dashboard_trainer_screen.dart';
import 'f_payments_screen.dart';
import 'f_profile_screen.dart';
import 'f_settings_screen.dart';

// =============================================================================
// DASHBOARD SHELL — wires the bottom nav bar to all tab pages.
// Supports both Trainer and Trainee roles, switching the "Home" tab content.
// =============================================================================

class DashboardScreen extends StatefulWidget {
  final String role;

  const DashboardScreen({
    super.key,
    required this.role,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  late List<Widget> _pages;

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

    _pages = _buildPages();
  }

  bool get _isTrainer => widget.role.trim().toLowerCase() == 'trainer';

  List<Widget> _buildPages() {
    return [
      _KeepAlive(
        key: ValueKey('home-${widget.role}'),
        child: _isTrainer
            ? const TrainerWorkoutPage()
            : const TraineeWorkoutPage(),
      ),
      const _KeepAlive(child: ExplorePage()),
      const _KeepAlive(child: HomeFeedPage()),
      const _KeepAlive(child: MessagesDashboardScreen()),
    ];
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.role != widget.role) {
      _pages = _buildPages();
      if (_currentIndex >= _pages.length) {
        _currentIndex = 0;
      }
    }
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
    final tabs = _isTrainer ? _trainerTabs : _traineeTabs;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      extendBody: true, // lets content bleed under the nav bar
      // ── Custom top bar ──────────────────────────────────────────────────
      appBar: _DashboardAppBar(
        currentIndex: _currentIndex,
        isTrainer: _isTrainer,
      ),
      endDrawer: _DashboardSidePanel(role: widget.role),
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
  const _KeepAlive({super.key, required this.child});

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
  final bool isTrainer;

  const _DashboardAppBar({
    required this.currentIndex,
    required this.isTrainer,
  });

  static const _titles = ['Dashboard', 'Explore', 'Feed', 'Messages'];
  static const _traineeTitles = ['Home', 'Explore', 'Feed', 'Messages'];

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final titles = isTrainer ? _titles : _traineeTitles;
    final title = titles[currentIndex.clamp(0, titles.length - 1).toInt()];
    final firstInitial = appState.profileFirstName.isNotEmpty
        ? appState.profileFirstName[0]
        : '';
    final lastInitial =
        appState.profileLastName.isNotEmpty ? appState.profileLastName[0] : '';
    final initials = '$firstInitial$lastInitial'.toUpperCase();

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
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
      actions: [
        // Notification bell
        _NotificationBell(
          onTap: () => Navigator.push(
            context,
            AppRoutes.noTransitionRoute(const _NotificationsScreen()),
          ),
        ),
        const SizedBox(width: 8),
        // Profile avatar
        Builder(
          builder: (ctx) => GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Scaffold.of(ctx).openEndDrawer();
            },
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
        ),
      ],
    );
  }
}

class _DashboardSidePanel extends StatelessWidget {
  final String role;

  const _DashboardSidePanel({required this.role});

  void _open(BuildContext context, Widget screen) {
    HapticFeedback.selectionClick();
    Navigator.pop(context);
    Navigator.push(context, AppRoutes.noTransitionRoute(screen));
  }

  @override
  Widget build(BuildContext context) {
    final roleLabel =
        role.trim().toLowerCase() == 'trainee' ? 'Trainee' : 'Trainer';
    final firstInitial = appState.profileFirstName.isNotEmpty
        ? appState.profileFirstName[0]
        : '';
    final lastInitial =
        appState.profileLastName.isNotEmpty ? appState.profileLastName[0] : '';
    final initials = '$firstInitial$lastInitial'.toUpperCase();
    final fullName =
        '${appState.profileFirstName} ${appState.profileLastName}'.trim();

    return Drawer(
      backgroundColor: AppTheme.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(18)),
      ),
      child: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.brand.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.outlineStrong),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: AppTheme.brand,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName.isEmpty ? 'Account' : fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        roleLabel,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Divider(color: AppTheme.divider, height: 1),
            const SizedBox(height: 10),
            _SidePanelTile(
              icon: CupertinoIcons.person_crop_circle,
              title: 'Profile',
              onTap: () =>
                  _open(context, ProfileInformationScreen(role: roleLabel)),
            ),
            _SidePanelTile(
              icon: CupertinoIcons.bell,
              title: 'Notifications',
              badge: '3',
              onTap: () => _open(context, const _NotificationsScreen()),
            ),
            _SidePanelTile(
              icon: CupertinoIcons.creditcard,
              title: 'Payments',
              onTap: () => _open(context, PaymentsScreen(role: roleLabel)),
            ),
            _SidePanelTile(
              icon: CupertinoIcons.gear_alt,
              title: 'Settings',
              onTap: () => _open(context, SettingsScreen(role: roleLabel)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidePanelTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? badge;
  final VoidCallback onTap;

  const _SidePanelTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(AppConstants.kDefaultBorderRadius),
              border: Border.all(color: AppTheme.outlineSoft),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.textPrimary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    constraints:
                        const BoxConstraints(minWidth: 20, minHeight: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.error,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationsScreen extends StatelessWidget {
  const _NotificationsScreen();

  static const _items = [
    (
      icon: CupertinoIcons.person_add,
      title: 'New client request',
      subtitle: 'Omar Magdy sent an intake form',
      time: '2m'
    ),
    (
      icon: CupertinoIcons.creditcard,
      title: 'Payment received',
      subtitle: 'Monthly subscription payment was completed',
      time: '1h'
    ),
    (
      icon: CupertinoIcons.calendar,
      title: 'Session reminder',
      subtitle: 'Upper body session starts at 6:00 PM',
      time: 'Today'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.bg,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final item = _items[i];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceRaised,
              borderRadius:
                  BorderRadius.circular(AppConstants.kDefaultBorderRadius),
              border: Border.all(color: AppTheme.outlineSoft),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.brand.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(
                        AppConstants.kDefaultBorderRadius),
                  ),
                  child: Icon(item.icon, color: AppTheme.brand, size: 19),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item.time,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
      margin: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding + 12),
      height: 64,
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
        border: Border.all(
          color: AppTheme.outlineSoft,
          width: 1,
        ),
        boxShadow: AppTheme.softShadow,
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
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.brand.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(AppConstants.kDefaultBorderRadius),
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
