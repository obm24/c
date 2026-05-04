import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../core/c_ui_theme.dart';
import '../core/c_constants.dart';
import '../core/c_state.dart';
import '../core/c_core_utils.dart';
import '../core/c_custom_controls.dart';
import '../core/animations/motion.dart';
import '../core/c_visual_effects.dart';
import 'profile_screens.dart';
import 'membership_screen.dart';

// =============================================================================
// SETTINGS SCREEN
// =============================================================================
class SettingsScreen extends StatefulWidget {
  final String role;
  const SettingsScreen({super.key, required this.role});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;
  String _language = 'English';
  String _currency = 'USD';

  bool get _isTrainer => widget.role == 'Trainer';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) => Scaffold(
        backgroundColor: AppTheme.bg,
        appBar: AppBar(
          elevation: 0,
          iconTheme: const IconThemeData(color: AppTheme.textPrimary),
          title: Text(context.l10n.settings,
              style: const TextStyle(color: AppTheme.brand)),
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).padding.bottom + 32,
          ),
          children: [
            // -- Account --------------------------------------------------
            _sectionHeader(context.l10n.account),
            _profileTile(context),
            _tile(
              icon: Icons.lock_outline,
              title: context.l10n.passwordAndSecurity,
              subtitle: context.l10n.manageYourCredentials,
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                    context,
                    AppRoutes.noTransitionRoute(
                        const PasswordSecurityScreen()));
              },
            ),
            _tile(
              icon: Icons.workspace_premium_outlined,
              title: _isTrainer ? 'Membership' : 'Subscription',
              subtitle: _isTrainer
                  ? appState.trainerPlanLabel
                  : appState.traineePlanLabel,
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                    context,
                    AppRoutes.noTransitionRoute(
                        MembershipScreen(role: widget.role)));
              },
            ),
            const SizedBox(height: 30),

            // -- Trainer-only: Employment & Availability -------------------
            if (_isTrainer) ...[
              _sectionHeader(context.l10n.availability),
              _tile(
                icon: Icons.work_outline,
                title: 'Employment Mode',
                subtitle: _employmentModeLabel(appState.employmentMode),
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showEmploymentModeDialog();
                },
              ),
              if (!appState.isOnlineOnly) ...[
                _tile(
                  icon: Icons.location_on_outlined,
                  title: 'Places of Employment',
                  subtitle: appState.placesOfEmployment.isEmpty
                      ? 'No locations added'
                      : '${appState.placesOfEmployment.length} location${appState.placesOfEmployment.length == 1 ? '' : 's'}',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                        context,
                        AppRoutes.noTransitionRoute(
                            const PlacesOfEmploymentScreen()));
                  },
                ),
              ],
              _tile(
                icon: Icons.beach_access_outlined,
                title: 'Holiday Mode',
                subtitle: appState.isHolidayMode
                    ? (appState.holidayDateRange != null
                        ? '${_formatDate(appState.holidayDateRange!.start)} - ${_formatDate(appState.holidayDateRange!.end)}'
                        : 'Active')
                    : 'Set a holiday period for vacational purposes',
                maxLines: null,
                trailing: Switch(
                  value: appState.isHolidayMode,
                  activeThumbColor: AppTheme.brand,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    if (v) {
                      _showHolidayDatePicker();
                    } else {
                      appState.setHolidayMode(false);
                      appState.setHolidayDateRange(null);
                    }
                  },
                ),
              ),
              _tile(
                icon: Icons.do_not_disturb_on_outlined,
                title: context.l10n.unavailableModeSettingsTitle,
                subtitle: context.l10n.unavailableModeSettingsSubtitle,
                maxLines: null,
                trailing: Switch(
                  value: appState.isUnavailableMode,
                  activeThumbColor: AppTheme.brand,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    appState.setUnavailableMode(v);
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],

            // -- Notifications ---------------------------------------------
            _sectionHeader(context.l10n.notificationsSection),
            _tile(
              icon: Icons.notifications_outlined,
              title: context.l10n.enableNotifications,
              subtitle: context.l10n.masterNotificationToggle,
              trailing: Switch(
                value: _notificationsEnabled,
                activeThumbColor: AppTheme.brand,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  setState(() => _notificationsEnabled = v);
                },
              ),
            ),
            if (_notificationsEnabled) ...[
              _tile(
                icon: Icons.email_outlined,
                title: context.l10n.emailNotifications,
                subtitle: context.l10n.emailNotificationsDesc,
                trailing: Switch(
                  value: _emailNotifications,
                  activeThumbColor: AppTheme.brand,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    setState(() => _emailNotifications = v);
                  },
                ),
              ),
              _tile(
                icon: Icons.phone_android,
                title: context.l10n.pushNotifications,
                subtitle: context.l10n.pushNotificationsDesc,
                trailing: Switch(
                  value: _pushNotifications,
                  activeThumbColor: AppTheme.brand,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    setState(() => _pushNotifications = v);
                  },
                ),
              ),
              _tile(
                icon: Icons.sms_outlined,
                title: context.l10n.smsNotifications,
                subtitle: context.l10n.smsNotificationsDesc,
                trailing: Switch(
                  value: _smsNotifications,
                  activeThumbColor: AppTheme.brand,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    setState(() => _smsNotifications = v);
                  },
                ),
              ),
            ],
            const SizedBox(height: 30),

            // -- Preferences -----------------------------------------------
            _sectionHeader(context.l10n.preferences),
            _tile(
              icon: Icons.language_outlined,
              title: context.l10n.language,
              subtitle: _language,
              onTap: () {
                HapticFeedback.lightImpact();
                _showLanguageDialog();
              },
            ),
            _tile(
              icon: Icons.attach_money,
              title: context.l10n.currency,
              subtitle: _currency,
              onTap: () {
                HapticFeedback.lightImpact();
                _showCurrencyDialog();
              },
            ),
            _tile(
              icon: Icons.straighten_outlined,
              title: context.l10n.measurementUnits,
              subtitle: context.l10n.measurementUnitsSubtitle,
              onTap: () {
                HapticFeedback.lightImpact();
                _showUnitsDialog();
              },
            ),
            const SizedBox(height: 30),

            // -- Support ---------------------------------------------------
            _sectionHeader(context.l10n.support),
            _tile(
              icon: Icons.help_outline,
              title: context.l10n.helpCentre,
              subtitle: context.l10n.helpCentreDesc,
              onTap: () => HapticFeedback.lightImpact(),
            ),
            _tile(
              icon: Icons.contact_support_outlined,
              title: context.l10n.contactUs,
              subtitle: context.l10n.contactUsDesc,
              onTap: () => HapticFeedback.lightImpact(),
            ),
            _tile(
              icon: Icons.info_outline,
              title: context.l10n.about,
              subtitle: context.l10n.aboutSubtitle,
              onTap: () {
                HapticFeedback.lightImpact();
                _showAboutDialog();
              },
            ),
            const SizedBox(height: 30),

            // -- Danger zone -----------------------------------------------
            _sectionHeader('Account Actions'),
            _tile(
              icon: Icons.logout,
              title: context.l10n.logout,
              titleColor: Colors.orange,
              showChevron: true,
              onTap: () {
                HapticFeedback.lightImpact();
                _showLogoutDialog();
              },
            ),
            _tile(
              icon: Icons.delete_forever,
              title: context.l10n.deleteAccount,
              titleColor: AppTheme.error,
              showChevron: true,
              onTap: () {
                HapticFeedback.lightImpact();
                _showDeleteAccountDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  // -- Helpers ----------------------------------------------------------------

  String _employmentModeLabel(int mode) {
    switch (mode) {
      case 0:
        return 'In-person & online';
      case 1:
        return 'In-person only';
      case 2:
        return 'Online only';
      default:
        return 'In-person & online';
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  // -- Widgets ----------------------------------------------------------------

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 4),
        child: Text(
          title,
          style: const TextStyle(
            color: AppTheme.brand,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  /// Dedicated profile tile that shows the user's name and role prominently.
  Widget _profileTile(BuildContext context) {
    final handle = '@${appState.profileUsername}';
    return TnTPremiumCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      radius: 14,
      accentColor: AppTheme.brand,
      onTap: () {
        Navigator.push(
            context,
            AppRoutes.noTransitionRoute(
                ProfileInformationScreen(role: widget.role)));
      },
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.brand.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            appState.profileFirstName.isNotEmpty
                ? appState.profileFirstName[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: AppTheme.brand,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: const Text(
          'Personal Information',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          handle,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing:
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
    bool showChevron = false,
    int? maxLines = 1,
  }) {
    // Suppress the default chevron when a Switch (or custom trailing) is shown,
    // unless showChevron is explicitly requested.
    final Widget effectiveTrailing = trailing ??
        (showChevron || onTap != null
            ? const Icon(Icons.chevron_right, color: AppTheme.textSecondary)
            : const SizedBox.shrink());

    return TnTPremiumCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      radius: 14,
      accentColor: titleColor ?? AppTheme.brand,
      elevated: onTap != null,
      onTap: onTap,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.brand.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.brand, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor ?? AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null && subtitle.isNotEmpty
            ? Text(
                subtitle,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12),
                maxLines: maxLines,
                overflow: maxLines == null || maxLines > 1
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
              )
            : null,
        trailing: effectiveTrailing,
      ),
    );
  }

  // -- Dialogs ----------------------------------------------------------------

  Widget _employmentRadio({
    required int mode,
    required int selected,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final bool isSelected = mode == selected;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.brand.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppTheme.brand : AppTheme.divider,
            width: isSelected ? 2 : 1,
          ),
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 2, right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.brand : AppTheme.textSecondary,
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: AppConstants.kDefaultSubtitleFontSize,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      height: 1.4,
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

  void _showEmploymentModeDialog() {
    AppMotion.showPremiumDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setModal) {
        return Dialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.kDefaultBorderRadius)),
          insetPadding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 15),
                  child: Text('Employment Mode',
                      style: const TextStyle(
                          color: AppTheme.brand,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                ),
                const Divider(color: AppTheme.divider, height: 1),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _employmentRadio(
                        mode: 0,
                        selected: appState.employmentMode,
                        title: context.l10n.hybridTraining,
                        description: context.l10n.hybridTrainingDesc,
                        onTap: () {
                          appState.setEmploymentMode(0);
                          setModal(() {});
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 12),
                      _employmentRadio(
                        mode: 1,
                        selected: appState.employmentMode,
                        title: context.l10n.onlineOnlyTraining,
                        description: context.l10n.onlineOnlyTrainingDesc,
                        onTap: () {
                          appState.setEmploymentMode(1);
                          setModal(() {});
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 12),
                      _employmentRadio(
                        mode: 2,
                        selected: appState.employmentMode,
                        title: context.l10n.inPersonOnlyTraining,
                        description: context.l10n.inPersonOnlyTrainingDesc,
                        onTap: () {
                          appState.setEmploymentMode(2);
                          setModal(() {});
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SolidConfirmButton(
                    label: 'Done',
                    height: AppConstants.kDefaultButtonHeightLarge,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> _showHolidayDatePicker() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.brand,
            onPrimary: AppTheme.bg,
            surface: AppTheme.surface,
          ),
          dialogTheme: const DialogThemeData(backgroundColor: AppTheme.bg),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      appState.setHolidayDateRange(picked);
      appState.setHolidayMode(true);
    }
  }

  void _showLanguageDialog() {
    final langs = [
      {'name': 'English', 'flag': 'assets/images/flags/gb.svg'},
      {'name': 'العربية', 'flag': 'assets/images/flags/sa.svg'},
      {'name': 'Español', 'flag': 'assets/images/flags/es.svg'},
      {'name': 'Français', 'flag': 'assets/images/flags/fr.svg'},
      {'name': 'Deutsch', 'flag': 'assets/images/flags/de.svg'},
    ];
    AppMotion.showPremiumDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.kDefaultBorderRadius)),
        insetPadding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 15),
              child: Text(context.l10n.selectLanguage,
                  style: const TextStyle(
                      color: AppTheme.brand,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
            ),
            const Divider(color: AppTheme.divider, height: 1),
            ...langs.map((l) {
              final isSelected = _language == l['name'];
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _language = l['name']!);
                      Navigator.pop(ctx);
                      AppUtils.showToast(
                          context, context.l10n.languageChangedTo(l['name']!));
                    },
                    child: Container(
                      color: isSelected ? AppTheme.brand : Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 15),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.black54, width: 0.5)),
                            child: SvgPicture.asset(l['flag']!,
                                width: 24, height: 16, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(l['name']!,
                                style: TextStyle(
                                    color: isSelected
                                        ? AppTheme.confirmationButtonText
                                        : AppTheme.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize:
                                        AppConstants.kDefaultSubtitleFontSize)),
                          ),
                          if (isSelected)
                            Icon(Icons.check,
                                color: AppTheme.confirmationButtonText,
                                size: 18),
                        ],
                      ),
                    ),
                  ),
                  const Divider(color: AppTheme.divider, height: 1),
                ],
              );
            }),
            Padding(
              padding: const EdgeInsets.all(20),
              child: OutlineActionButton(
                label: context.l10n.cancel,
                height: AppConstants.kDefaultButtonHeightLarge,
                textColor: AppTheme.textPrimary,
                borderColor: AppTheme.textSecondary,
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog() {
    final currencies = [
      {'name': 'USD', 'sym': '\$', 'icon': null},
      {'name': 'EUR', 'sym': '€', 'icon': null},
      {'name': 'GBP', 'sym': '£', 'icon': null},
      {'name': 'EGP', 'sym': 'EGP', 'icon': null},
      {
        'name': 'SAR',
        'sym': 'SAR',
        'icon': 'assets/images/currencies/ksa_riyal.svg'
      },
      {
        'name': 'AED',
        'sym': 'AED',
        'icon': 'assets/images/currencies/uae_dirham.svg'
      },
    ];
    AppMotion.showPremiumDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.kDefaultBorderRadius)),
        insetPadding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 15),
              child: Text(context.l10n.selectCurrency,
                  style: const TextStyle(
                      color: AppTheme.brand,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
            ),
            const Divider(color: AppTheme.divider, height: 1),
            ...currencies.map((c) {
              final isSelected = _currency == c['name'];
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _currency = c['name'] as String);
                      Navigator.pop(ctx);
                      AppUtils.showToast(context,
                          context.l10n.currencyChangedTo(c['name'] as String));
                    },
                    child: Container(
                      color: isSelected ? AppTheme.brand : Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 15),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 36,
                            child: c['icon'] != null
                                ? SvgPicture.asset(c['icon'] as String,
                                    height: 18,
                                    colorFilter: ColorFilter.mode(
                                      isSelected
                                          ? AppTheme.confirmationButtonText
                                          : AppTheme.textPrimary,
                                      BlendMode.srcIn,
                                    ))
                                : Text(c['sym'] as String,
                                    style: TextStyle(
                                        color: isSelected
                                            ? AppTheme.confirmationButtonText
                                            : AppTheme.textPrimary,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(c['name'] as String,
                                style: TextStyle(
                                    color: isSelected
                                        ? AppTheme.confirmationButtonText
                                        : AppTheme.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize:
                                        AppConstants.kDefaultSubtitleFontSize)),
                          ),
                          if (isSelected)
                            Icon(Icons.check,
                                color: AppTheme.confirmationButtonText,
                                size: 18),
                        ],
                      ),
                    ),
                  ),
                  const Divider(color: AppTheme.divider, height: 1),
                ],
              );
            }),
            Padding(
              padding: const EdgeInsets.all(20),
              child: OutlineActionButton(
                label: context.l10n.cancel,
                height: AppConstants.kDefaultButtonHeightLarge,
                textColor: AppTheme.textPrimary,
                borderColor: AppTheme.textSecondary,
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnitsDialog() {
    AppMotion.showPremiumDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.kDefaultBorderRadius)),
        titlePadding:
            const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 15),
        contentPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 0),
        actionsPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.measurementUnits,
                style: const TextStyle(
                    color: AppTheme.brand,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            const SizedBox(height: 15),
            const Divider(color: AppTheme.divider, height: 1),
          ],
        ),
        content: StatefulBuilder(
          builder: (_, setM) => SizedBox(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Text(context.l10n.weight,
                      style: const TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 10),
                  DualToggleSwitch(
                    leftLabel: context.l10n.metricKg,
                    rightLabel: context.l10n.imperialLbs,
                    isLeftSelected: appState.weightUnit == 'metric',
                    onSelected: (m) {
                      appState.setWeightUnit(m ? 'metric' : 'imperial');
                      setM(() {});
                    },
                  ),
                  const SizedBox(height: 6),
                  Text(context.l10n.weightLiftingHint,
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 11)),
                  const SizedBox(height: 24),
                  Text(context.l10n.distanceLabel,
                      style: const TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 10),
                  DualToggleSwitch(
                    leftLabel: context.l10n.metricKm,
                    rightLabel: context.l10n.imperialMi,
                    isLeftSelected: appState.distanceUnit == 'metric',
                    onSelected: (m) {
                      appState.setDistanceUnit(m ? 'metric' : 'imperial');
                      setM(() {});
                    },
                  ),
                  const SizedBox(height: 6),
                  Text(context.l10n.distanceTrackingHint,
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 11)),
                  const SizedBox(height: 24),
                  Text(context.l10n.bodyMeasurements,
                      style: const TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 10),
                  DualToggleSwitch(
                    leftLabel: context.l10n.metricCm,
                    rightLabel: context.l10n.imperialIn,
                    isLeftSelected: appState.measurementUnit == 'metric',
                    onSelected: (m) {
                      appState.setMeasurementUnit(m ? 'metric' : 'imperial');
                      setM(() {});
                    },
                  ),
                  const SizedBox(height: 6),
                  Text(context.l10n.bodyMeasurementsHint,
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 11)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
        actions: [
          SolidConfirmButton(
            label: context.l10n.done,
            height: AppConstants.kDefaultButtonHeightLarge,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    AppMotion.showPremiumDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.kDefaultBorderRadius)),
        titlePadding:
            const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 15),
        contentPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 0),
        actionsPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.aboutApp,
                style: const TextStyle(
                    color: AppTheme.brand,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            const SizedBox(height: 15),
            const Divider(color: AppTheme.divider, height: 1),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(context.l10n.version,
                style: const TextStyle(color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            const Text('1.0.0 (Build 1)',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),
            Text(context.l10n.aboutDescription,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13, height: 1.5)),
            const SizedBox(height: 15),
            Text(context.l10n.copyright,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 20),
          ],
        ),
        actions: [
          SolidConfirmButton(
            label: 'Close',
            height: AppConstants.kDefaultButtonHeightLarge,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    AppMotion.showPremiumDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.kDefaultBorderRadius)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 15),
              child: Text(context.l10n.logout,
                  style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
            ),
            const Divider(color: AppTheme.divider, height: 1),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                context.l10n.logoutConfirmation,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlineActionButton(
                    label: context.l10n.logout,
                    height: AppConstants.kDefaultButtonHeightLarge,
                    textColor: Colors.orange,
                    borderColor: Colors.orange,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      appState.resetSession();
                      context.go('/');
                    },
                  ),
                  const SizedBox(height: 12),
                  SolidConfirmButton(
                    label: context.l10n.cancel,
                    height: AppConstants.kDefaultButtonHeightLarge,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final ctrl = TextEditingController();
    AppMotion.showPremiumDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setModal) {
        final confirmed = ctrl.text.trim().toLowerCase() == 'delete';
        return Dialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.kDefaultBorderRadius)),
          insetPadding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 15),
                child: Text(context.l10n.deleteAccount,
                    style: const TextStyle(
                        color: AppTheme.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
              ),
              const Divider(color: AppTheme.divider, height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.l10n.deleteAccountWarning,
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Type DELETE to confirm',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: ctrl,
                      onChanged: (_) => setModal(() {}),
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: AppConstants.kDefaultSubtitleFontSize),
                      decoration: InputDecoration(
                        hintText: 'DELETE',
                        hintStyle:
                            const TextStyle(color: AppTheme.textSecondary),
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
                            borderSide: const BorderSide(
                                color: AppTheme.error, width: 2)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SolidConfirmButton(
                      label: context.l10n.deleteAccount,
                      height: AppConstants.kDefaultButtonHeightLarge,
                      bgColor: confirmed ? AppTheme.error : null,
                      textColor: confirmed ? Colors.white : null,
                      onPressed: confirmed
                          ? () {
                              HapticFeedback.heavyImpact();
                              appState.resetSession();
                              context.go('/');
                            }
                          : null,
                    ),
                    const SizedBox(height: 12),
                    OutlineActionButton(
                      label: context.l10n.cancel,
                      height: AppConstants.kDefaultButtonHeightLarge,
                      textColor: AppTheme.textPrimary,
                      borderColor: AppTheme.textSecondary,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// =============================================================================
// PLACES OF EMPLOYMENT SCREEN
// Surfaced from Settings â†’ Employment Mode (trainer only)
// =============================================================================
class PlacesOfEmploymentScreen extends StatelessWidget {
  const PlacesOfEmploymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) => Scaffold(
        backgroundColor: AppTheme.bg,
        appBar: AppBar(
          elevation: 0,
          iconTheme: const IconThemeData(color: AppTheme.textPrimary),
          title: const Text('Places of Employment',
              style: TextStyle(color: AppTheme.brand)),
          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: AppTheme.brand),
              onPressed: () => _showAddPlaceDialog(context, null, null),
            ),
          ],
        ),
        body: appState.placesOfEmployment.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_off_outlined,
                        color: AppTheme.textSecondary, size: 48),
                    const SizedBox(height: 16),
                    const Text('No locations added',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 15)),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 180,
                      child: SolidConfirmButton(
                        label: 'Add Location',
                        height: AppConstants.kDefaultButtonHeightLarge,
                        icon: Icons.add,
                        onPressed: () =>
                            _showAddPlaceDialog(context, null, null),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: appState.placesOfEmployment.length,
                itemBuilder: (ctx, i) {
                  final p = appState.placesOfEmployment[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.brand.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.location_on_outlined,
                            color: AppTheme.brand, size: 20),
                      ),
                      title: Text(p['name'] ?? '',
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15)),
                      subtitle: Text(
                          '${p['city'] ?? ''}, ${p['country'] ?? ''} · ${p['type'] ?? ''}',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      trailing: PopupMenuButton<String>(
                        color: AppTheme.surface,
                        icon: const Icon(Icons.more_vert,
                            color: AppTheme.textSecondary),
                        onSelected: (v) {
                          if (v == 'edit') {
                            _showAddPlaceDialog(context, i, p);
                          } else if (v == 'delete') {
                            HapticFeedback.mediumImpact();
                            appState.removePlaceOfEmployment(i);
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit',
                                  style:
                                      TextStyle(color: AppTheme.textPrimary))),
                          const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete',
                                  style: TextStyle(color: AppTheme.error))),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _showAddPlaceDialog(
      BuildContext context, int? idx, Map<String, dynamic>? existing) {
    final nameCtr = TextEditingController(text: existing?['name'] ?? '');
    final addrCtr = TextEditingController(text: existing?['address'] ?? '');
    String selType = existing?['type'] ?? 'Gym';
    String? selCity = existing?['city'];
    String country = existing?['country'] ?? 'Egypt';

    final types = [
      'Gym',
      'Fitness Club',
      'Studio',
      'Outdoor',
      'Pool',
      'Rehabilitation Center',
      'Sports Complex',
      'Other'
    ];

    AppMotion.showPremiumBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setM) {
        bool allOk() =>
            nameCtr.text.trim().length >= 2 && addrCtr.text.trim().length >= 5;

        InputDecoration dec(String label, {Widget? suffixIcon}) =>
            InputDecoration(
              labelText: label,
              suffixIcon: suffixIcon,
              labelStyle: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: AppConstants.kDefaultSubtitleFontSize),
              floatingLabelStyle: const TextStyle(
                  color: AppTheme.brand,
                  fontSize: AppConstants.kDefaultFormTitleFontSize),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
              enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                  borderSide: const BorderSide(
                      color: AppTheme.textSecondary, width: 1.5)),
              focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                  borderSide:
                      const BorderSide(color: AppTheme.brand, width: 2)),
            );

        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24),
          child: SingleChildScrollView(
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
                              borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 20),
                  Text(
                      idx != null
                          ? context.l10n.editLocation
                          : context.l10n.addLocation,
                      style: const TextStyle(
                          color: AppTheme.brand,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  // Location Type chips
                  Text(context.l10n.locationType,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: AppConstants.kDefaultSubtitleFontSize)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: types.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final t = types[i];
                        final sel = t == selType;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setM(() => selType = t);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color:
                                    sel ? AppTheme.brand : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: sel
                                        ? AppTheme.brand
                                        : AppTheme.divider)),
                            child: Text(t,
                                style: TextStyle(
                                    color: sel
                                        ? AppTheme.bg
                                        : AppTheme.textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Facility Name
                  TextFormField(
                      controller: nameCtr,
                      onChanged: (_) => setM(() {}),
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: AppConstants.kDefaultSubtitleFontSize),
                      decoration: dec(context.l10n.facilityName)),
                  const SizedBox(height: 15),
                  // Street Address
                  GestureDetector(
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      try {
                        await AppUtils.launchLink(
                            ctx, 'https://maps.google.com/?q=my+location',
                            fromChat: false);
                      } catch (_) {}
                    },
                    child: TextFormField(
                        controller: addrCtr,
                        onChanged: (_) => setM(() {}),
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: AppConstants.kDefaultSubtitleFontSize),
                        decoration: dec(
                          'Employment Address',
                          suffixIcon: const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(Icons.map_outlined,
                                color: AppTheme.brand, size: 20),
                          ),
                        )),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(context.l10n.mapDetectionInstructions,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 11)),
                  ),
                  const SizedBox(height: 24),
                  SolidConfirmButton(
                    label: idx != null ? 'Save Changes' : 'Add Location',
                    height: AppConstants.kDefaultButtonHeightLarge,
                    onPressed: allOk()
                        ? () {
                            HapticFeedback.selectionClick();
                            final place = {
                              'name': nameCtr.text.trim(),
                              'address': addrCtr.text.trim(),
                              'city': selCity ?? 'Cairo',
                              'country': country,
                              'type': selType,
                              'lat': existing?['lat'] ?? 0.0,
                              'lng': existing?['lng'] ?? 0.0,
                            };
                            if (idx == null) {
                              appState.addPlaceOfEmployment(place);
                            } else {
                              appState.updatePlaceOfEmployment(idx, place);
                            }
                            Navigator.pop(ctx);
                          }
                        : null,
                  ),
                  const SizedBox(height: 12),
                  OutlineActionButton(
                      label: context.l10n.cancel,
                      height: AppConstants.kDefaultButtonHeightLarge,
                      textColor: AppTheme.textPrimary,
                      borderColor: AppTheme.textSecondary,
                      onPressed: () => Navigator.pop(ctx)),
                  const SizedBox(height: 24),
                ]),
          ),
        );
      }),
    );
  }
}

// =============================================================================
// PAYOUT SETTINGS SCREEN
// Surfaced from Settings â†’ Financial (trainer only)
// =============================================================================
class PayoutSettingsScreen extends StatefulWidget {
  const PayoutSettingsScreen({super.key});
  @override
  State<PayoutSettingsScreen> createState() => _PayoutSettingsScreenState();
}

class _PayoutSettingsScreenState extends State<PayoutSettingsScreen> {
  late String _method;
  late String _paypalEmail;
  late Map<String, String> _bank;

  final _paypalCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _ibanCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();
  final _swiftCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _method = appState.payoutMethod;
    _paypalEmail = appState.paypalEmail;
    _bank = Map<String, String>.from(appState.bankAccount);
    _paypalCtrl.text = _paypalEmail;
    _bankCtrl.text = _bank['bank'] ?? '';
    _ibanCtrl.text = _bank['iban'] ?? '';
    _accountCtrl.text = _bank['account'] ?? '';
    _swiftCtrl.text = _bank['swift'] ?? '';
  }

  @override
  void dispose() {
    _paypalCtrl.dispose();
    _bankCtrl.dispose();
    _ibanCtrl.dispose();
    _accountCtrl.dispose();
    _swiftCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        title: const Text('Payout Method',
            style: TextStyle(color: AppTheme.brand)),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).padding.bottom + 32,
        ),
        children: [
          const Text('Payment Method',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: 12),
          DualToggleSwitch(
            leftLabel: 'Bank Transfer',
            rightLabel: 'PayPal',
            isLeftSelected: _method == 'Bank',
            onSelected: (left) =>
                setState(() => _method = left ? 'Bank' : 'PayPal'),
          ),
          const SizedBox(height: 30),
          if (_method == 'Bank') ...[
            _fieldLabel('Bank Name'),
            _textField(_bankCtrl, 'e.g. Commercial International Bank'),
            const SizedBox(height: 15),
            _fieldLabel('IBAN'),
            _textField(_ibanCtrl, 'e.g. EG12000300...'),
            const SizedBox(height: 15),
            _fieldLabel('Account Number'),
            _textField(_accountCtrl, 'e.g. 100023456789'),
            const SizedBox(height: 15),
            _fieldLabel('SWIFT / BIC Code'),
            _textField(_swiftCtrl, 'e.g. CIBGEGCX'),
          ] else ...[
            _fieldLabel('PayPal Email'),
            _textField(_paypalCtrl, 'your@email.com',
                keyboard: TextInputType.emailAddress),
          ],
          const SizedBox(height: 32),
          SolidConfirmButton(
            label: 'Save Payout Method',
            height: AppConstants.kDefaultButtonHeightLarge,
            onPressed: () {
              HapticFeedback.selectionClick();
              appState.saveFinancials(
                _method,
                _paypalCtrl.text.trim(),
                {
                  'bank': _bankCtrl.text.trim(),
                  'iban': _ibanCtrl.text.trim(),
                  'account': _accountCtrl.text.trim(),
                  'swift': _swiftCtrl.text.trim(),
                },
              );
              AppUtils.showToast(context, 'Payout method saved');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: AppConstants.kDefaultSubtitleFontSize)),
      );

  Widget _textField(TextEditingController ctrl, String hint,
      {TextInputType keyboard = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
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
            borderSide:
                const BorderSide(color: AppTheme.textSecondary, width: 1.5)),
        focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.kDefaultBorderRadius),
            borderSide: const BorderSide(color: AppTheme.brand, width: 2)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }
}
