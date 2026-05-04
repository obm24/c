import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/c_ui_theme.dart';
import '../core/c_constants.dart';
import '../core/c_core_utils.dart';
import '../core/c_custom_controls.dart';

// =============================================================================
// MOCK CLIENT DATA
// =============================================================================
const List<Map<String, dynamic>> _kMockClients = [
  {
    'name': 'Omar K.',
    'username': '@omar_k',
    'age': 26,
    'goal': 'Muscle Gain',
    'status': 'active',
    'daysLeft': 18,
    'since': 'Jan 2024',
    'sessionsCompleted': 14,
    'totalSessions': 20,
    'lastActive': 'Today',
  },
  {
    'name': 'Layla N.',
    'username': '@layla_n',
    'age': 24,
    'goal': 'Weight Loss',
    'status': 'active',
    'daysLeft': 5,
    'since': 'Feb 2024',
    'sessionsCompleted': 18,
    'totalSessions': 20,
    'lastActive': 'Yesterday',
  },
  {
    'name': 'Ahmed Ali',
    'username': '@ahmed_fit',
    'age': 31,
    'goal': 'Strength',
    'status': 'active',
    'daysLeft': 62,
    'since': 'Mar 2024',
    'sessionsCompleted': 6,
    'totalSessions': 24,
    'lastActive': '2 days ago',
  },
  {
    'name': 'Hana S.',
    'username': '@hana_s',
    'age': 28,
    'goal': 'Endurance',
    'status': 'inactive',
    'daysLeft': null,
    'since': 'Oct 2023',
    'sessionsCompleted': 12,
    'totalSessions': 12,
    'lastActive': '3 weeks ago',
  },
  {
    'name': 'Khalid R.',
    'username': '@khalid_r',
    'age': 33,
    'goal': 'Flexibility',
    'status': 'inactive',
    'daysLeft': null,
    'since': 'Sep 2023',
    'sessionsCompleted': 8,
    'totalSessions': 8,
    'lastActive': '1 month ago',
  },
];

// =============================================================================
// GOAL → COLOUR MAPPING  (consistent brand palette)
// =============================================================================
Color _goalColor(String goal) {
  switch (goal) {
    case 'Muscle Gain':
      return AppTheme.cardBlue;
    case 'Weight Loss':
      return AppTheme.cardPink;
    case 'Strength':
      return AppTheme.cardPurple;
    case 'Endurance':
      return AppTheme.cardYellow;
    case 'Flexibility':
      return AppTheme.cardGreen;
    default:
      return AppTheme.cardIndigo;
  }
}

// =============================================================================
// CLIENTS SCREEN
// =============================================================================
class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  // ── Summary stats ──────────────────────────────────────────────────────────
  int get _activeCount =>
      _kMockClients.where((c) => c['status'] == 'active').length;
  int get _inactiveCount =>
      _kMockClients.where((c) => c['status'] == 'inactive').length;
  int get _expiringCount => _kMockClients
      .where((c) =>
          c['status'] == 'active' &&
          (c['daysLeft'] as int?) != null &&
          (c['daysLeft'] as int) <= 7)
      .length;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filtered(String status) {
    return _kMockClients.where((c) {
      if (c['status'] != status) return false;
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return c['name'].toString().toLowerCase().contains(q) ||
          c['username'].toString().toLowerCase().contains(q) ||
          c['goal'].toString().toLowerCase().contains(q);
    }).toList();
  }

  // ── Invite-link bottom sheet ───────────────────────────────────────────────
  void _showInviteSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // drag handle
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppTheme.divider,
                      borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 22),
            const Text('Invite Trainee',
                style: TextStyle(
                    color: AppTheme.brand,
                    fontSize: AppConstants.kDefaultTitleFontSize,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text(
                'Share your unique invite link or copy it to send manually.',
                style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: AppConstants.kDefaultSubtitleFontSize,
                    height: 1.5)),
            const SizedBox(height: 22),
            // Link preview box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.bg,
                borderRadius:
                    BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, color: AppTheme.brand, size: 18),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('TnT.app/join/omarbinalmajd',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontFamily: 'OCR-A')),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Clipboard.setData(const ClipboardData(
                          text: 'https://TnT.app/join/omarbinalmajd'));
                      AppUtils.showToast(context, 'Link copied!');
                    },
                    child: const Icon(Icons.copy_rounded,
                        color: AppTheme.textSecondary, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SolidConfirmButton(
              label: 'Share Link',
              icon: Icons.share_rounded,
              height: AppConstants.kDefaultButtonHeightLarge,
              onPressed: () {
                HapticFeedback.selectionClick();
                Navigator.pop(context);
                AppUtils.showToast(
                    context, context.l10n.clientDetailComingSoon);
              },
            ),
            const SizedBox(height: 10),
            OutlineActionButton(
              label: 'Cancel',
              height: AppConstants.kDefaultButtonHeightLarge,
              textColor: AppTheme.textPrimary,
              borderColor: AppTheme.divider,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // ── Add-trainee bottom sheet ───────────────────────────────────────────────
  void _showAddTraineeSheet() {
    HapticFeedback.lightImpact();
    final usernameCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppTheme.divider,
                      borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 22),
            const Text('Add Trainee',
                style: TextStyle(
                    color: AppTheme.brand,
                    fontSize: AppConstants.kDefaultTitleFontSize,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text(
                'Enter the trainee\'s username to send them a coaching request.',
                style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: AppConstants.kDefaultSubtitleFontSize,
                    height: 1.5)),
            const SizedBox(height: 22),
            TextField(
              controller: usernameCtrl,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: AppConstants.kDefaultSubtitleFontSize),
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: AppConstants.kDefaultSubtitleFontSize),
                floatingLabelStyle: const TextStyle(
                    color: AppTheme.brand,
                    fontSize: AppConstants.kDefaultFormTitleFontSize),
                prefixIcon: const Icon(Icons.alternate_email,
                    color: AppTheme.textSecondary, size: 18),
                filled: true,
                fillColor: AppTheme.bg,
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        AppConstants.kDefaultBorderRadius),
                    borderSide:
                        const BorderSide(color: AppTheme.divider, width: 1.5)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        AppConstants.kDefaultBorderRadius),
                    borderSide:
                        const BorderSide(color: AppTheme.brand, width: 2)),
              ),
            ),
            const SizedBox(height: 16),
            SolidConfirmButton(
              label: 'Send Request',
              icon: Icons.person_add_outlined,
              height: AppConstants.kDefaultButtonHeightLarge,
              onPressed: () {
                HapticFeedback.selectionClick();
                Navigator.pop(context);
                AppUtils.showToast(
                    context, context.l10n.clientDetailComingSoon);
              },
            ),
            const SizedBox(height: 10),
            OutlineActionButton(
              label: 'Cancel',
              height: AppConstants.kDefaultButtonHeightLarge,
              textColor: AppTheme.textPrimary,
              borderColor: AppTheme.divider,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        title: Text(context.l10n.clients,
            style: const TextStyle(
                color: AppTheme.brand,
                fontSize: AppConstants.kDefaultTitleFontSize,
                fontWeight: FontWeight.bold)),
        actions: [
          // Sort / filter placeholder
          IconButton(
            icon: const Icon(Icons.tune_rounded,
                color: AppTheme.textSecondary, size: 22),
            onPressed: () => AppUtils.showToast(
                context, context.l10n.clientDetailComingSoon),
            tooltip: 'Filter',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.brand,
            indicatorWeight: 2,
            labelColor: AppTheme.brand,
            unselectedLabelColor: AppTheme.textSecondary,
            labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppConstants.kDefaultSubtitleFontSize),
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Active'),
                    const SizedBox(width: 6),
                    _TabBadge(count: _activeCount, color: AppTheme.cardGreen),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Inactive'),
                    const SizedBox(width: 6),
                    _TabBadge(
                        count: _inactiveCount, color: AppTheme.textSecondary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Action buttons + search ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              children: [
                // Action buttons row
                Row(
                  children: [
                    Expanded(
                      child: OutlineActionButton(
                        label: context.l10n.inviteTrainee,
                        height: AppConstants.kDefaultButtonHeightLarge,
                        icon: const Icon(Icons.insert_link_rounded,
                            color: AppTheme.brand, size: 18),
                        onPressed: _showInviteSheet,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SolidConfirmButton(
                        label: context.l10n.addTrainee,
                        height: AppConstants.kDefaultButtonHeightLarge,
                        icon: Icons.person_add_outlined,
                        onPressed: _showAddTraineeSheet,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Search field
                TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: AppConstants.kDefaultSubtitleFontSize),
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: context.l10n.searchClients,
                    hintStyle: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: AppConstants.kDefaultSubtitleFontSize),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppTheme.textSecondary, size: 20),
                    suffixIcon: _query.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                            child: const Icon(Icons.close_rounded,
                                color: AppTheme.textSecondary, size: 18),
                          )
                        : null,
                    filled: true,
                    fillColor: AppTheme.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            AppConstants.kDefaultBorderRadius),
                        borderSide: BorderSide.none),
                  ),
                ),

                const SizedBox(height: 14),

                // ── Summary stat chips ─────────────────────────────────────
                _SummaryRow(
                  activeCount: _activeCount,
                  inactiveCount: _inactiveCount,
                  expiringCount: _expiringCount,
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // ── Tab views ────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ClientList(
                  clients: _filtered('active'),
                  emptyLabel:
                      'No active clients yet.\nInvite trainees to get started.',
                  emptyIcon: Icons.people_outline_rounded,
                ),
                _ClientList(
                  clients: _filtered('inactive'),
                  emptyLabel: context.l10n.noInactiveClients,
                  emptyIcon: Icons.person_off_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TAB BADGE
// =============================================================================
class _TabBadge extends StatelessWidget {
  final int count;
  final Color color;
  const _TabBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count',
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// =============================================================================
// SUMMARY ROW
// =============================================================================
class _SummaryRow extends StatelessWidget {
  final int activeCount;
  final int inactiveCount;
  final int expiringCount;

  const _SummaryRow({
    required this.activeCount,
    required this.inactiveCount,
    required this.expiringCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SummaryChip(
            label: 'Total',
            value: '${activeCount + inactiveCount}',
            color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        _SummaryChip(
            label: 'Active', value: '$activeCount', color: AppTheme.cardGreen),
        if (expiringCount > 0) ...[
          const SizedBox(width: 8),
          _SummaryChip(
              label: 'Expiring',
              value: '$expiringCount',
              color: AppTheme.cardRed),
        ],
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(width: 5),
          Text(label,
              style:
                  TextStyle(color: color.withValues(alpha: 0.7), fontSize: 12)),
        ],
      ),
    );
  }
}

// =============================================================================
// CLIENT LIST
// =============================================================================
class _ClientList extends StatelessWidget {
  final List<Map<String, dynamic>> clients;
  final String emptyLabel;
  final IconData emptyIcon;

  const _ClientList({
    required this.clients,
    required this.emptyLabel,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (clients.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                    color: AppTheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.divider)),
                child: Icon(emptyIcon, color: AppTheme.textSecondary, size: 32),
              ),
              const SizedBox(height: 20),
              Text(emptyLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: AppConstants.kDefaultSubtitleFontSize,
                      height: 1.6)),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      itemCount: clients.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) => _ClientCard(client: clients[i]),
    );
  }
}

// =============================================================================
// CLIENT CARD
// =============================================================================
class _ClientCard extends StatelessWidget {
  final Map<String, dynamic> client;
  const _ClientCard({required this.client});

  // ── Urgency helpers ────────────────────────────────────────────────────────
  bool get _isActive => client['status'] == 'active';
  int? get _daysLeft => client['daysLeft'] as int?;

  Color get _daysLeftColor {
    final d = _daysLeft;
    if (d == null) return AppTheme.textSecondary;
    if (d <= 5) return AppTheme.cardRed;
    if (d <= 14) return AppTheme.cardYellow;
    return AppTheme.cardGreen;
  }

  String get _daysLeftLabel {
    final d = _daysLeft;
    if (d == null) return '';
    if (d == 1) return '1 day left';
    if (d < 30) return '$d days left';
    final months = (d / 30).floor();
    return '$months ${months == 1 ? 'month' : 'months'} left';
  }

  // ── Progress ───────────────────────────────────────────────────────────────
  int get _completed => client['sessionsCompleted'] as int? ?? 0;
  int get _total => client['totalSessions'] as int? ?? 1;
  double get _progress => _completed / _total.clamp(1, _total);

  @override
  Widget build(BuildContext context) {
    final goalColor = _goalColor(client['goal'] as String);
    final bool isExpiringSoon = _isActive && (_daysLeft ?? 999) <= 7;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        AppUtils.showToast(context, context.l10n.clientDetailComingSoon);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          border: Border.all(
            color: isExpiringSoon
                ? AppTheme.cardRed.withValues(alpha: 0.4)
                : AppTheme.divider,
          ),
          boxShadow: isExpiringSoon
              ? [
                  BoxShadow(
                    color: AppTheme.cardRed.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Main row ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar + online dot
                  Stack(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: goalColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: goalColor.withValues(alpha: 0.3),
                              width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            _initials(client['name'] as String),
                            style: TextStyle(
                                color: goalColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 1,
                        right: 1,
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: _isActive
                                ? Colors.greenAccent
                                : AppTheme.textSecondary,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppTheme.surface, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Name, username, tags
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + last active
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(client['name'],
                                  style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppConstants
                                          .kDefaultSubtitleFontSize)),
                            ),
                            const SizedBox(width: 4),
                            Text(client['lastActive'] as String,
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${client['username']} · Age ${client['age']} · Since ${client['since']}',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 11),
                        ),
                        const SizedBox(height: 8),

                        // Tags row
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _Tag(
                              label: client['goal'] as String,
                              color: goalColor,
                              icon: Icons.fitness_center_rounded,
                            ),
                            if (_isActive && _daysLeft != null)
                              _Tag(
                                label: _daysLeftLabel,
                                color: _daysLeftColor,
                                icon: Icons.schedule_rounded,
                              ),
                            if (!_isActive)
                              _Tag(
                                label: 'Plan ended',
                                color: AppTheme.textSecondary,
                                icon: Icons.do_not_disturb_on_rounded,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Arrow
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.arrow_forward_ios_rounded,
                        color: AppTheme.textSecondary, size: 13),
                  ),
                ],
              ),
            ),

            // ── Progress bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sessions progress',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 11)),
                      Text('$_completed / $_total',
                          style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 4,
                      backgroundColor: AppTheme.divider,
                      valueColor: AlwaysStoppedAnimation<Color>(goalColor),
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

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

// =============================================================================
// TAG CHIP
// =============================================================================
class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _Tag({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
