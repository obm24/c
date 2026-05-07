import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/b_phone_validation.dart';
import '../core/c_ui_theme.dart';
import '../core/c_constants.dart';
import '../core/c_core_utils.dart';
import '../core/c_custom_controls.dart';
import '../core/c_state.dart';
import '../core/animations/anim_motion.dart';
import '../core/c_phone_validator.dart';
import '../core/c_warnings.dart';
import '../core/c_trainee_profile.dart';
import '../core/c_visual_effects.dart';
import 'package:flutter_svg/flutter_svg.dart';

// =============================================================================
// PASSWORD & SECURITY SCREEN
// =============================================================================
class PasswordSecurityScreen extends StatefulWidget {
  const PasswordSecurityScreen({super.key});
  @override
  State<PasswordSecurityScreen> createState() => _PasswordSecurityScreenState();
}

class _PasswordSecurityScreenState extends State<PasswordSecurityScreen> {
  final TextEditingController _currentPassCtrl = TextEditingController();
  final TextEditingController _newPassCtrl = TextEditingController();
  final TextEditingController _confPassCtrl = TextEditingController();
  final TextEditingController _newEmailCtrl = TextEditingController();

  late TextEditingController _phoneCtrl;
  late String _selectedCountryCode;
  late List<String> _sortedCodes;

  @override
  void initState() {
    super.initState();
    _phoneCtrl = TextEditingController(text: appState.profilePhone);
    _selectedCountryCode = appState.profileCountryCode;
    _sortedCodes = AppConstants.kCountryCodes.toSet().toList()
      ..sort((a, b) {
        int vA = int.parse(a.split('+').last.replaceAll(RegExp(r'[^0-9]'), ''));
        int vB = int.parse(b.split('+').last.replaceAll(RegExp(r'[^0-9]'), ''));
        return vA.compareTo(vB);
      });
    _phoneCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  bool get isPhoneValid => PhoneValidationService.validateDetailed(
        appState.profileCountry,
        _phoneCtrl.text,
        dialCodeSelection: _selectedCountryCode,
      ).isValid;

  void _showPhoneChangeModal() {
    AppMotion.showPremiumBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => BlocProvider(
        create: (_) => PhoneValidationBloc()
          ..add(CountrySelected(
            appState.profileCountry,
            dialCodeSelection: _selectedCountryCode,
          ))
          ..add(PhoneNumberChanged(_phoneCtrl.text)),
        child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24),
          child: BlocBuilder<PhoneValidationBloc, PhoneValidationState>(
            builder: (context, phoneState) {
              return Column(
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
                  const SizedBox(height: 25),
                  Text(context.l10n.phoneNumber,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 25),
                  _buildPhoneField(phoneState),
                  const SizedBox(height: 25),
                  SolidConfirmButton(
                      label: 'Update Phone Number',
                      onPressed: phoneState.isValid &&
                              _phoneCtrl.text.isNotEmpty
                          ? () {
                              HapticFeedback.selectionClick();
                              final resolvedCountryCandidate =
                                  AppCountryMetadata.countryEntryFromSelection(
                                _selectedCountryCode,
                              );
                              final resolvedCountry =
                                  resolvedCountryCandidate.isNotEmpty
                                      ? resolvedCountryCandidate
                                      : appState.profileCountry;
                              appState.saveProfile(
                                first: appState.profileFirstName,
                                last: appState.profileLastName,
                                phone: _phoneCtrl.text,
                                countryCode: _selectedCountryCode,
                                country: resolvedCountry,
                                region: appState.profileRegion,
                                dob: appState.profileDob,
                              );
                              Navigator.pop(context);
                              setState(() {});
                              AppUtils.showToast(context,
                                  'Phone number updated successfully!');
                            }
                          : null),
                  const SizedBox(height: 30),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField(PhoneValidationState phoneState) {
    return StatefulBuilder(builder: (context, setModalState) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextFormField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(15),
            FilteringTextInputFormatter.deny(RegExp(r'\n'))
          ],
          onChanged: (value) {
            context.read<PhoneValidationBloc>().add(PhoneNumberChanged(value));
          },
          style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: AppConstants.kDefaultSubtitleFontSize),
          decoration: InputDecoration(
            labelText: context.l10n.phoneNumber,
            labelStyle: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: AppConstants.kDefaultSubtitleFontSize),
            floatingLabelStyle:
                WidgetStateTextStyle.resolveWith((s) => TextStyle(
                      color: s.contains(WidgetState.focused)
                          ? AppTheme.brand
                          : AppTheme.textPrimary,
                      fontSize: AppConstants.kDefaultFormTitleFontSize,
                    )),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
            prefixIcon: IntrinsicWidth(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(width: 12),
                DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                  value: _selectedCountryCode,
                  dropdownColor: AppTheme.surface,
                  isExpanded: false,
                  isDense: true,
                  itemHeight: null,
                  icon: const Icon(Icons.arrow_drop_down,
                      color: AppTheme.textSecondary, size: 18),
                  selectedItemBuilder: (_) => _sortedCodes.map((c) {
                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 72),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        CountryFlagWidget(textData: c),
                      ]),
                    );
                  }).toList(),
                  items: _sortedCodes.map((c) {
                    final parts = c.split(' ');
                    final svgPath = parts[0];
                    final dialCode = parts.length > 1 ? parts[1] : '';
                    return DropdownMenuItem(
                      value: c,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        SvgPicture.asset(svgPath,
                            width: 22, height: 15, fit: BoxFit.cover),
                        const SizedBox(width: 8),
                        Text(dialCode,
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize:
                                    AppConstants.kDefaultSubtitleFontSize)),
                      ]),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setModalState(() => _selectedCountryCode = v);
                      context.read<PhoneValidationBloc>().add(
                            CountrySelected(
                              AppCountryMetadata.countryEntryFromSelection(v),
                              dialCodeSelection: v,
                            ),
                          );
                    }
                  },
                )),
                const SizedBox(width: 8),
                Container(width: 1, height: 22, color: AppTheme.divider),
                const SizedBox(width: 12),
              ]),
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                borderSide: BorderSide(
                    color: phoneState.shouldShowError
                        ? AppTheme.error
                        : AppTheme.textSecondary,
                    width: 1.5)),
            focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                borderSide: BorderSide(
                    color: phoneState.shouldShowError
                        ? AppTheme.error
                        : AppTheme.brand,
                    width: 2)),
          ),
        ),
        if (phoneState.shouldShowFeedback)
          StandardFormWarningBanner(
            message: PhoneValidationMessageBuilder.buildMessage(
              phoneState.validationResult,
              compact: true,
            ),
            isValid: phoneState.shouldShowValid,
            margin: const EdgeInsets.only(top: 8),
            trailing: phoneState.validationResult.hasLongPrefixList &&
                    !phoneState.validationResult.isValid
                ? IconButton(
                    onPressed: () => _showPhonePrefixDetails(
                      phoneState.validationResult,
                    ),
                    splashRadius: 18,
                    icon: const Icon(
                      Icons.help_outline_rounded,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                  )
                : null,
          ),
      ]);
    });
  }

  void _showPhonePrefixDetails(PhoneValidationResult result) {
    AppMotion.showPremiumBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${result.countryDisplayName} Mobile Prefixes',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              PhoneValidationMessageBuilder.buildPrefixDetails(result),
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmailChangeModal() {
    AppMotion.showPremiumBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24),
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
            const SizedBox(height: 25),
            Text(context.l10n.changeEmail,
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 25),
            TextFormField(
              controller: _newEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: AppConstants.kDefaultSubtitleFontSize),
              decoration: InputDecoration(
                labelText: context.l10n.newEmailAddress,
                labelStyle: const TextStyle(color: AppTheme.textSecondary),
                floatingLabelStyle: const TextStyle(
                    color: AppTheme.brand,
                    fontSize: AppConstants.kDefaultFormTitleFontSize),
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
              ),
            ),
            const SizedBox(height: 25),
            SolidConfirmButton(
                label: context.l10n.sendVerificationLink,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  Navigator.pop(context);
                  AppUtils.showToast(
                      context, 'Verification link sent to new email!');
                }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showPasswordChangeModal() {
    AppMotion.showPremiumBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24),
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
            const SizedBox(height: 25),
            Text(context.l10n.changePassword,
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 25),
            _passField('Current Password', _currentPassCtrl),
            const SizedBox(height: 15),
            _passField('New Password', _newPassCtrl),
            const SizedBox(height: 15),
            _passField('Confirm New Password', _confPassCtrl),
            const SizedBox(height: 25),
            SolidConfirmButton(
                label: context.l10n.updatePassword,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  Navigator.pop(context);
                  AppUtils.showToast(
                      context, context.l10n.passwordUpdatedSuccess);
                }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _passField(String label, TextEditingController ctrl) => TextFormField(
        controller: ctrl,
        obscureText: true,
        style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: AppConstants.kDefaultSubtitleFontSize),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textSecondary),
          floatingLabelStyle: const TextStyle(
              color: AppTheme.brand,
              fontSize: AppConstants.kDefaultFormTitleFontSize),
          enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.kDefaultBorderRadius),
              borderSide:
                  const BorderSide(color: AppTheme.textSecondary, width: 1.5)),
          focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.kDefaultBorderRadius),
              borderSide: const BorderSide(color: AppTheme.brand, width: 2)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
          elevation: 0,
          iconTheme: const IconThemeData(color: AppTheme.textPrimary),
          title: Text(context.l10n.passwordAndSecurity,
              style: TextStyle(color: AppTheme.brand))),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          Text(context.l10n.accountIdentifier,
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _infoTile(CupertinoIcons.at, appState.profileUsername),
          const Divider(color: AppTheme.divider, height: 40),
          Text(context.l10n.emailAddress,
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _infoTile(CupertinoIcons.mail, 'omarbinalmajd@example.com'),
          const SizedBox(height: 15),
          OutlineActionButton(
              label: context.l10n.changeEmail,
              icon: const Icon(Icons.edit, size: 16, color: AppTheme.brand),
              height: AppConstants.kDefaultButtonHeightLarge,
              onPressed: _showEmailChangeModal),
          const Divider(color: AppTheme.divider, height: 40),
          Text(context.l10n.phoneNumber,
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _infoTile(
              CupertinoIcons.phone_fill,
              appState.profilePhone.isNotEmpty
                  ? '${appState.profileCountryCode} ${appState.profilePhone}'
                  : 'Not provided'),
          const SizedBox(height: 15),
          OutlineActionButton(
              label: 'Change Phone Number',
              icon: const Icon(Icons.phone, size: 16, color: AppTheme.brand),
              height: AppConstants.kDefaultButtonHeightLarge,
              onPressed: _showPhoneChangeModal),
          const Divider(color: AppTheme.divider, height: 40),
          Text(context.l10n.password,
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _infoTile(CupertinoIcons.lock_fill, '••••••••••••'),
          const SizedBox(height: 15),
          OutlineActionButton(
              label: context.l10n.changePassword,
              icon: const Icon(Icons.password, size: 16, color: AppTheme.brand),
              height: AppConstants.kDefaultButtonHeightLarge,
              onPressed: _showPasswordChangeModal),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String text) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius:
                BorderRadius.circular(AppConstants.kDefaultBorderRadius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
        child: Row(children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 10),
          Text(text,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: AppConstants.kDefaultSubtitleFontSize))
        ]),
      );
}

// =============================================================================
// MAIN PROFILE INFORMATION SCREEN
// =============================================================================
class ProfileInformationScreen extends StatefulWidget {
  final String role;
  const ProfileInformationScreen({super.key, required this.role});
  @override
  State<ProfileInformationScreen> createState() =>
      _ProfileInformationScreenState();
}

class _ProfileInformationScreenState extends State<ProfileInformationScreen> {
  late TextEditingController _fNameCtrl;
  late TextEditingController _lNameCtrl;
  late String _selectedRegion;

  List<String> _trainerSpecialties = [];
  int _trainingExperienceYears = 0;
  List<String> _preferredDiets = [];
  // credentials: list of {org, cert, certId} — all mandatory
  List<Map<String, dynamic>> _trainerCredentials = [];

  @override
  void initState() {
    super.initState();
    _fNameCtrl = TextEditingController(text: appState.profileFirstName);
    _lNameCtrl = TextEditingController(text: appState.profileLastName);
    _selectedRegion = appState.profileRegion;

    if (widget.role == 'Trainer') {
      _trainerSpecialties =
          List.from(appState.trainerAhmed['specialties'] as List<String>);
      _trainerCredentials = [
        {
          'org': 'National Academy of Sports Medicine (NASM)',
          'cert': 'Certified Personal Trainer (NASM-CPT)',
          'certId': 'NASM001923'
        },
      ];
    } else {
      _trainingExperienceYears = appState.traineeTrainingExperienceYears;
      _preferredDiets = List<String>.from(appState.selectedPreferredDiets);
    }

    _fNameCtrl.addListener(() => setState(() {}));
    _lNameCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _fNameCtrl.dispose();
    _lNameCtrl.dispose();
    super.dispose();
  }

  bool get isFNameValid =>
      RegExp(r'^[\p{L}\s\-]{2,}$', unicode: true).hasMatch(_fNameCtrl.text);
  bool get isLNameValid =>
      RegExp(r'^[\p{L}\s\-]{2,}$', unicode: true).hasMatch(_lNameCtrl.text);
  bool get isAllValid => isFNameValid && isLNameValid;

  void _saveProfile() {
    appState.saveProfile(
      first: _fNameCtrl.text,
      last: _lNameCtrl.text,
      phone: appState.profilePhone,
      countryCode: appState.profileCountryCode,
      country: appState.profileCountry,
      region: _selectedRegion,
      dob: appState.profileDob,
    );
    FocusScope.of(context).unfocus();
    AppUtils.showToast(context, context.l10n.profileSavedSuccess);
    Navigator.pop(context);
  }

  Future<void> _pickProfileImage() async {
    HapticFeedback.lightImpact();
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null && mounted) {
      AppUtils.showToast(context, context.l10n.profileImageUpdated);
    }
  }

  void _openMedicalMultiSelect(
      String title, String type, List<String> options, List<String> current,
      {bool hasDesc = false,
      Map<String, String>? descriptions,
      Color chipColor = AppTheme.brand}) {
    List<String> tmp = List.from(current);
    AppMotion.showPremiumDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
          builder: (ctx, setM) => Dialog(
                backgroundColor: AppTheme.surface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        AppConstants.kDefaultBorderRadius)),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(ctx).size.height * 0.8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(title,
                              style: const TextStyle(
                                  color: AppTheme.brand,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      AppConstants.kDefaultTitleFontSize))),
                      const Divider(color: AppTheme.divider, height: 1),
                      Expanded(
                        child: ListView.builder(
                          itemCount: options.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (_, i) {
                            final item = options[i];
                            final sel = tmp.contains(item);
                            final description = descriptions?[item] ??
                                context.l10n.descriptionNotAvailable;
                            void showDescription() {
                              AppMotion.showPremiumDialog<void>(
                                  context: ctx,
                                  builder: (_) => AlertDialog(
                                        backgroundColor: AppTheme.surface,
                                        titlePadding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                AppConstants
                                                    .kDefaultBorderRadius)),
                                        title: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  child: Text(item,
                                                      style: const TextStyle(
                                                          color: AppTheme.brand,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: AppConstants
                                                              .kDefaultTitleFontSize))),
                                              const Divider(
                                                  color: AppTheme.divider,
                                                  height: 1),
                                            ]),
                                        content: Text(description,
                                            style: const TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontSize: AppConstants
                                                    .kDefaultSubtitleFontSize,
                                                height: 1.5)),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                HapticFeedback.lightImpact();
                                                Navigator.pop(ctx);
                                              },
                                              child: Text(context.l10n.close,
                                                  style: const TextStyle(
                                                      color: AppTheme.brand,
                                                      fontWeight:
                                                          FontWeight.bold)))
                                        ],
                                      ));
                            }

                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                              child: SizedBox(
                                width: double.infinity,
                                child: PremiumSelectionButton(
                                  label: item,
                                  color: chipColor,
                                  selected: sel,
                                  onTap: () {
                                    setM(() {
                                      sel ? tmp.remove(item) : tmp.add(item);
                                    });
                                  },
                                  onHelpTap: hasDesc ? showDescription : null,
                                  helpTooltip: context.l10n.description,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 12),
                                  minHeight: 46,
                                  fontSize: AppConstants
                                      .kDefaultSubtitleFontSize,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SolidConfirmButton(
                                  label: context.l10n.confirm,
                                  height:
                                      AppConstants.kDefaultButtonHeightLarge,
                                  onPressed: () {
                                    if (type == 'trainer_specialties') {
                                      setState(() => _trainerSpecialties = tmp);
                                    } else {
                                      appState.updateMedical(type, tmp);
                                    }
                                    Navigator.pop(ctx);
                                  }),
                              const SizedBox(height: 10),
                              OutlineActionButton(
                                  label: context.l10n.cancel,
                                  height:
                                      AppConstants.kDefaultButtonHeightLarge,
                                  textColor: AppTheme.textPrimary,
                                  borderColor: AppTheme.textSecondary,
                                  onPressed: () => Navigator.pop(ctx)),
                            ]),
                      ),
                    ],
                  ),
                ),
              )),
    );
  }

  void _showCredentialsManager() {
    HapticFeedback.lightImpact();
    AppMotion.showPremiumBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
          builder: (ctx, setM) => DraggableScrollableSheet(
                initialChildSize: 0.85,
                minChildSize: 0.5,
                maxChildSize: 0.95,
                expand: false,
                builder: (ctx, scroll) => ListView(
                  controller: scroll,
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                      left: 24,
                      right: 24,
                      top: 24),
                  children: [
                    Center(
                        child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                                color: AppTheme.divider,
                                borderRadius: BorderRadius.circular(10)))),
                    const SizedBox(height: 25),
                    Text(context.l10n.manageCredentials,
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 25),
                    if (_trainerCredentials.isEmpty)
                      Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(context.l10n.noCredentialsAdded,
                              style: TextStyle(color: AppTheme.textSecondary),
                              textAlign: TextAlign.center))
                    else
                      ..._trainerCredentials.asMap().entries.map((e) {
                        final idx = e.key;
                        final cred = e.value;
                        return ProfileCredentialCard(
                          credential: cred,
                          allCredentials: _trainerCredentials,
                          onSave: (d) {
                            setM(() => _trainerCredentials[idx] = d);
                            setState(() {});
                          },
                          onEdit: () => setM(() =>
                              _trainerCredentials[idx]['_isEditing'] = true),
                          onRemove: () {
                            setM(() => _trainerCredentials.removeAt(idx));
                            setState(() {});
                          },
                          onCancel: () => setM(() {
                            if (_trainerCredentials[idx]['org'] == null) {
                              _trainerCredentials.removeAt(idx);
                            } else {
                              _trainerCredentials[idx]['_isEditing'] = false;
                            }
                          }),
                        );
                      }),
                    const SizedBox(height: 15),
                    OutlineActionButton(
                      label: context.l10n.addCredential,
                      icon: const Icon(Icons.add, color: AppTheme.brand),
                      height: 50,
                      onPressed: () => setM(() => _trainerCredentials.add({
                            'org': null,
                            'cert': null,
                            'certId': '',
                            '_isEditing': true
                          })),
                    ),
                    const SizedBox(height: 30),
                    SolidConfirmButton(
                        label: context.l10n.done,
                        onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
              )),
    );
  }

  Widget _buildProfileField(
    String label, {
    TextEditingController? controller,
    bool isEditable = true,
    bool readOnly = false,
    List<TextInputFormatter>? formatters,
    TextInputType? keyboardType,
    VoidCallback? onTap,
    Widget? prefixIcon,
    bool isValid = true,
    String ruleText = '',
  }) {
    List<TextInputFormatter> merged = [
      FilteringTextInputFormatter.deny(RegExp(r'\n'))
    ];
    if (formatters != null) merged.addAll(formatters);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            absorbing: onTap != null || (!isEditable && !readOnly),
            child: TextFormField(
              controller: controller,
              readOnly: (!isEditable) || readOnly,
              keyboardType: keyboardType,
              inputFormatters: merged,
              textInputAction: TextInputAction.done,
              style: TextStyle(
                  color: isEditable
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                  fontSize: AppConstants.kDefaultSubtitleFontSize),
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: prefixIcon,
                suffixIcon: onTap != null
                    ? const Icon(Icons.arrow_drop_down,
                        color: AppTheme.textSecondary)
                    : null,
                labelStyle: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: AppConstants.kDefaultSubtitleFontSize),
                floatingLabelStyle: WidgetStateTextStyle.resolveWith((s) =>
                    TextStyle(
                        color: s.contains(WidgetState.focused)
                            ? AppTheme.brand
                            : AppTheme.textPrimary,
                        fontSize: AppConstants.kDefaultFormTitleFontSize)),
                filled: !isEditable,
                fillColor: isEditable
                    ? Colors.transparent
                    : Colors.white.withValues(alpha: 0.02),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        AppConstants.kDefaultBorderRadius),
                    borderSide: BorderSide(
                        color: isEditable
                            ? AppTheme.textSecondary
                            : Colors.white.withValues(alpha: 0.08),
                        width: 1.5)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        AppConstants.kDefaultBorderRadius),
                    borderSide: BorderSide(
                        color: isEditable
                            ? AppTheme.brand
                            : Colors.white.withValues(alpha: 0.08),
                        width: 2)),
              ),
            ),
          ),
        ),
        if (!isValid)
          Padding(
              padding: const EdgeInsets.only(top: 6, left: 10),
              child: Text(ruleText,
                  style: const TextStyle(color: AppTheme.error, fontSize: 11))),
      ]),
    );
  }

  Widget _buildCountryField(String label) {
    final adminInfo = CountryAdminInfo.resolve(appState.profileCountry);
    final allCountries = AppConstants.kCountriesOnly.toSet().toList();
    final bool countryChosen = appState.profileCountry.isNotEmpty;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── Country picker ──────────────────────────────────────────────────────
      Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: AppConstants.kDefaultSubtitleFontSize),
            floatingLabelStyle: const TextStyle(
                color: AppTheme.brand,
                fontSize: AppConstants.kDefaultFormTitleFontSize),
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
                const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
          ),
          dropdownColor: AppTheme.surface,
          icon:
              const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
          style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: AppConstants.kDefaultSubtitleFontSize),
          initialValue: countryChosen ? appState.profileCountry : null,
          isExpanded: true, isDense: true, itemHeight: null,
          // FIX #1+2: iterate kCountriesOnly, render each with flag SVG
          items: allCountries
              .map((c) => DropdownMenuItem(
                    value: c,
                    child: CountryFlagWidget(textData: c),
                  ))
              .toList(),
          selectedItemBuilder: (_) => allCountries
              .map((c) => Align(
                    alignment: Alignment.centerLeft,
                    child: CountryFlagWidget(textData: c),
                  ))
              .toList(),
          onChanged: (v) => setState(() {
            appState.profileCountry = v ?? '';
            _selectedRegion = '';
          }),
        ),
      ),

      // FIX #3: Subdivision field ALWAYS shown. Disabled with placeholder when no country selected.
      Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IgnorePointer(
            ignoring: !countryChosen || adminInfo.regions.isEmpty,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: countryChosen && adminInfo.label.isNotEmpty
                    ? adminInfo.label
                    : 'Subdivision',
                labelStyle: TextStyle(
                  color: countryChosen
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                  fontSize: AppConstants.kDefaultSubtitleFontSize,
                ),
                floatingLabelStyle: const TextStyle(
                    color: AppTheme.brand,
                    fontSize: AppConstants.kDefaultFormTitleFontSize),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                  borderSide: BorderSide(
                    color: countryChosen && adminInfo.regions.isNotEmpty
                        ? AppTheme.textSecondary
                        : Colors.white.withValues(alpha: 0.08),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        AppConstants.kDefaultBorderRadius),
                    borderSide:
                        const BorderSide(color: AppTheme.brand, width: 2)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
                // FIX #3: Show placeholder hint when no country chosen
                hintText: countryChosen ? null : 'Select country first',
                hintStyle: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: AppConstants.kDefaultSubtitleFontSize),
                filled: !countryChosen || adminInfo.regions.isEmpty,
                fillColor: Colors.white.withValues(alpha: 0.02),
              ),
              dropdownColor: AppTheme.surface,
              icon: Icon(Icons.arrow_drop_down,
                  color: countryChosen && adminInfo.regions.isNotEmpty
                      ? AppTheme.textSecondary
                      : Colors.transparent),
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: AppConstants.kDefaultSubtitleFontSize),
              initialValue:
                  countryChosen && adminInfo.regions.contains(_selectedRegion)
                      ? _selectedRegion
                      : null,
              isExpanded: true,
              isDense: true,
              itemHeight: null,
              items: countryChosen && adminInfo.regions.isNotEmpty
                  ? adminInfo.regions
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList()
                  : [
                      const DropdownMenuItem(
                          value: '__placeholder__', child: Text(''))
                    ],
              onChanged: countryChosen && adminInfo.regions.isNotEmpty
                  ? (v) => setState(() => _selectedRegion = v ?? '')
                  : null,
            ),
          ),
          if (countryChosen &&
              adminInfo.regions.isNotEmpty &&
              _selectedRegion.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 10),
              child: Text(
                  context.l10n.pleaseSelectField(adminInfo.label.toLowerCase()),
                  style: const TextStyle(color: AppTheme.error, fontSize: 11)),
            ),
        ]),
      ),
    ]);
  }

  Widget _buildMedicalSelector(
      String label, String type, List<String> options, List<String> current,
      {bool hasDesc = false,
      Map<String, String>? descriptions,
      Color chipColor = AppTheme.brand}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: AppConstants.kDefaultSubtitleFontSize)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            HapticFeedback.lightImpact();
            if (type == 'goals' ||
                type == 'trainer_specialties' ||
                type == 'preferred_diets') {
              final categories = type == 'preferred_diets'
                  ? TraineeDietData.categories
                  : MedicalData.getCategorizedGoals(context);
              final results = await AppMotion.showPremiumDialog<List<String>>(
                context: context,
                builder: (ctx) => GroupedMultiSelectDialog(
                  title: label,
                  categories: categories,
                  initialSelections: current,
                  selectionColor: chipColor,
                ),
              );
              if (results != null) {
                if (type == 'trainer_specialties') {
                  setState(() => _trainerSpecialties = results);
                } else if (type == 'preferred_diets') {
                  setState(() => _preferredDiets = results);
                  appState.updatePreferredDiets(results);
                } else {
                  appState.updateMedical(type, results);
                }
              }
            } else {
              _openMedicalMultiSelect(label, type, options, current,
                  hasDesc: hasDesc,
                  descriptions: descriptions,
                  chipColor: chipColor);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(minHeight: 50),
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                border: Border.all(color: AppTheme.textSecondary, width: 1.5)),
            child: Row(children: [
              Expanded(
                  child: current.isEmpty
                      ? Text(context.l10n.none,
                          style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: AppConstants.kDefaultSubtitleFontSize))
                      : Wrap(
                          spacing: 6,
                           runSpacing: 6,
                           children: current
                              .map((item) => PremiumSelectionButton(
                                    label: item,
                                    color: chipColor,
                                    selected: true,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 8),
                                    minHeight: 34,
                                    fontSize: 13,
                                  ))
                              .toList())),
              const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
            ]),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isTrainer = widget.role == 'Trainer';
    final Map<String, String> localDesc = MedicalData.getDescriptions(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AnimatedBuilder(
        animation: appState,
        builder: (context, _) => Scaffold(
          backgroundColor: AppTheme.bg,
          appBar: AppBar(
              elevation: 0,
              iconTheme: const IconThemeData(color: AppTheme.textPrimary),
              title: Text(context.l10n.profileInfoTitle,
                  style: TextStyle(color: AppTheme.brand))),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                  child: Stack(children: [
                const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.surface,
                    child: Icon(Icons.person,
                        size: 50, color: AppTheme.textSecondary)),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickProfileImage,
                      child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                              color: AppTheme.brand, shape: BoxShape.circle),
                          child: const Icon(Icons.edit,
                              size: 20,
                              color: AppTheme.confirmationButtonText)),
                    )),
              ])),
              const SizedBox(height: 30),

              Text(context.l10n.personalInfo,
                  style: const TextStyle(
                      color: AppTheme.brand,
                      fontSize: AppConstants.kDefaultTitleFontSize,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              _buildProfileField(context.l10n.firstName,
                  controller: _fNameCtrl,
                  isValid: isFNameValid,
                  ruleText: context.l10n.invalidNameError),
              _buildProfileField(context.l10n.lastName,
                  controller: _lNameCtrl,
                  isValid: isLNameValid,
                  ruleText: context.l10n.invalidNameError),

              Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.dateOfBirth,
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize:
                                    AppConstants.kDefaultSubtitleFontSize)),
                        const SizedBox(height: 10),
                        DobDropdownWidget(
                            initialDate: appState.profileDob,
                            onChanged: (v) =>
                                setState(() => appState.profileDob = v)),
                      ])),

              Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.gender,
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize:
                                    AppConstants.kDefaultSubtitleFontSize)),
                        const SizedBox(height: 10),
                        GenderToggleSwitch(
                            selectedGender: appState.profileGender,
                            onSelected: (v) =>
                                setState(() => appState.profileGender = v)),
                      ])),

              // Task 5: label differs by role
              _buildCountryField(
                  isTrainer ? 'Country of Employment' : 'Country of Residence'),
              const SizedBox(height: 10),

              if (!isTrainer) ...[
                OutlineActionButton(
                    label: context.l10n.bodyComposition,
                    onPressed: () => Navigator.push(
                        context,
                        AppRoutes.noTransitionRoute(
                            const BodyCompositionScreen()))),
                const SizedBox(height: 15),
                OutlineActionButton(
                    label: context.l10n.circumferences,
                    onPressed: () => Navigator.push(
                        context,
                        AppRoutes.noTransitionRoute(
                            const CircumferencesScreen()))),
                const SizedBox(height: 25),
                Text(context.l10n.goals,
                    style: TextStyle(
                        color: AppTheme.brand,
                        fontSize: AppConstants.kDefaultTitleFontSize,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildMedicalSelector(context.l10n.trainingGoals, 'goals',
                    MedicalData.goals, appState.currentGoals,
                    hasDesc: true, descriptions: localDesc),
                TrainingExperienceSelector(
                  selectedYears: _trainingExperienceYears,
                  onSelected: (years) {
                    setState(() => _trainingExperienceYears = years);
                    appState.updateTrainingExperience(years);
                  },
                ),
                _buildMedicalSelector(
                  context.l10n.preferredDiet,
                  'preferred_diets',
                  const [],
                  _preferredDiets,
                  chipColor: AppTheme.cardGreen,
                ),
                const SizedBox(height: 10),
                Text(context.l10n.medicalStatus,
                    style: const TextStyle(
                        color: AppTheme.brand,
                        fontSize: AppConstants.kDefaultTitleFontSize,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildMedicalSelector(
                    context.l10n.currentInjuries,
                    'current',
                    MedicalData.commonInjuries
                        .where((e) => !appState.pastInjuries.contains(e))
                        .toList(),
                    appState.currentInjuries,
                    hasDesc: true,
                    descriptions: localDesc,
                    chipColor: AppTheme.error),
                _buildMedicalSelector(
                    context.l10n.pastInjuries,
                    'past',
                    MedicalData.commonInjuries
                        .where((e) => !appState.currentInjuries.contains(e))
                        .toList(),
                    appState.pastInjuries,
                    hasDesc: true,
                    descriptions: localDesc,
                    chipColor: AppTheme.cardYellow),
                _buildMedicalSelector(context.l10n.medicalConditions, 'medical',
                    MedicalData.commonConditions, appState.medicalConditions,
                    hasDesc: true,
                    descriptions: localDesc,
                    chipColor: AppTheme.cardBlue),
              ],

              if (isTrainer) ...[
                const SizedBox(height: 15),
                Text(context.l10n.professionalSetup,
                    style: TextStyle(
                        color: AppTheme.brand,
                        fontSize: AppConstants.kDefaultTitleFontSize,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildMedicalSelector(context.l10n.specialities, 'trainer_specialties',
                    MedicalData.trainerSpecialties, _trainerSpecialties,
                    hasDesc: true, descriptions: localDesc),

                // Task 1: renamed to Credentials, new system
                Text(context.l10n.credentials,
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: AppConstants.kDefaultSubtitleFontSize)),
                const SizedBox(height: 10),
                OutlineActionButton(
                    label: context.l10n.manageCredentials,
                    icon: const Icon(Icons.verified_outlined,
                        color: AppTheme.brand),
                    onPressed: _showCredentialsManager),
                const SizedBox(height: 25),

                const Divider(color: AppTheme.divider, height: 1),
                const SizedBox(height: 25),
                OutlineActionButton(
                  label: context.l10n.placesOfEmployment,
                  icon: const Icon(Icons.location_on_outlined,
                      color: AppTheme.brand),
                  onPressed: () => Navigator.push(
                      context,
                      AppRoutes.noTransitionRoute(
                          const PlacesOfEmploymentScreen())),
                ),
                const SizedBox(height: 15),
                OutlineActionButton(
                    label: context.l10n.advertisement,
                    icon: const Icon(Icons.campaign, color: AppTheme.brand),
                    onPressed: () {}),
                const SizedBox(height: 25),
              ],

              const Divider(color: AppTheme.divider, height: 1),
              const SizedBox(height: 25),
              SolidConfirmButton(
                  label: context.l10n.saveChanges,
                  height: AppConstants.kDefaultButtonHeightLarge,
                  onPressed: isAllValid ? _saveProfile : null),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// PROFILE CREDENTIAL CARD — full kTrainerCertifications integration
// Rules: org → certs from map; cert used = removed; org exhausted = removed.
// All fields mandatory. certId required per cert.
// =============================================================================
class ProfileCredentialCard extends StatefulWidget {
  final Map<String, dynamic> credential;
  final List<Map<String, dynamic>> allCredentials;
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback onCancel;

  const ProfileCredentialCard({
    super.key,
    required this.credential,
    required this.allCredentials,
    required this.onSave,
    required this.onEdit,
    required this.onRemove,
    required this.onCancel,
  });

  @override
  State<ProfileCredentialCard> createState() => _ProfileCredentialCardState();
}

class _ProfileCredentialCardState extends State<ProfileCredentialCard> {
  String? _selectedOrg;
  String? _selectedCert;
  final TextEditingController _idCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedOrg = widget.credential['org'];
    _selectedCert = widget.credential['cert'];
    _idCtrl.text = widget.credential['certId'] ?? '';
    _idCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    super.dispose();
  }

  // Orgs that still have at least one available cert
  List<String> get _availableOrgs {
    return MedicalData.kTrainerCertifications.keys.where((org) {
      if (org == _selectedOrg) return true; // always keep current
      return _availableCertsForOrg(org).isNotEmpty;
    }).toList();
  }

  // Certs for an org minus those already claimed by OTHER credentials
  List<String> _availableCertsForOrg(String org) {
    final allCerts = MedicalData.kTrainerCertifications[org] ?? [];
    final usedElsewhere = widget.allCredentials
        .where((c) =>
            c != widget.credential && c['org'] == org && c['cert'] != null)
        .map((c) => c['cert'] as String)
        .toSet();
    return allCerts.where((c) => !usedElsewhere.contains(c)).toList();
  }

  bool get _isValid =>
      _selectedOrg != null &&
      _selectedCert != null &&
      RegExp(r'^[a-zA-Z0-9\-/]{3,}$').hasMatch(_idCtrl.text);

  void _pickOrg() {
    final orgs = _availableOrgs;
    AppMotion.showPremiumDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.kDefaultBorderRadius)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(context.l10n.selectOrganisation,
                        style: TextStyle(
                            color: AppTheme.brand,
                            fontWeight: FontWeight.bold,
                            fontSize: 18))),
                const Divider(color: AppTheme.divider, height: 1),
                Expanded(
                    child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: orgs.length,
                  itemBuilder: (_, i) {
                    final org = orgs[i];
                    final sel = org == _selectedOrg;
                    return Column(children: [
                      InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.pop(context);
                          setState(() {
                            _selectedOrg = org;
                            if (_selectedCert != null &&
                                !_availableCertsForOrg(org)
                                    .contains(_selectedCert)) {
                              _selectedCert = null;
                            }
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          color: sel ? AppTheme.brand : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          child: Text(org,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: sel
                                      ? AppTheme.confirmationButtonText
                                      : AppTheme.textPrimary,
                                  fontSize:
                                      AppConstants.kDefaultSubtitleFontSize,
                                  fontWeight: sel
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                        ),
                      ),
                      const Divider(color: AppTheme.divider, height: 1),
                    ]);
                  },
                )),
                Padding(
                    padding: const EdgeInsets.all(16),
                    child: OutlineActionButton(
                        label: context.l10n.cancel,
                        textColor: AppTheme.textPrimary,
                        borderColor: AppTheme.textSecondary,
                        onPressed: () => Navigator.pop(context))),
              ]),
        ),
      ),
    );
  }

  void _pickCert() {
    if (_selectedOrg == null) return;
    final certs = _availableCertsForOrg(_selectedOrg!);
    AppMotion.showPremiumDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.kDefaultBorderRadius)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(context.l10n.selectCertificate,
                        style: TextStyle(
                            color: AppTheme.brand,
                            fontWeight: FontWeight.bold,
                            fontSize: 18))),
                const Divider(color: AppTheme.divider, height: 1),
                Expanded(
                    child: certs.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                                'All certificates from this organisation are already in use.',
                                style: TextStyle(color: AppTheme.textSecondary),
                                textAlign: TextAlign.center))
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: certs.length,
                            itemBuilder: (_, i) {
                              final cert = certs[i];
                              final sel = cert == _selectedCert;
                              return Column(children: [
                                InkWell(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    Navigator.pop(context);
                                    setState(() => _selectedCert = cert);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    color: sel
                                        ? AppTheme.brand
                                        : Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 15),
                                    child: Text(cert,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: sel
                                                ? AppTheme
                                                    .confirmationButtonText
                                                : AppTheme.textPrimary,
                                            fontSize: AppConstants
                                                .kDefaultSubtitleFontSize,
                                            fontWeight: sel
                                                ? FontWeight.bold
                                                : FontWeight.normal)),
                                  ),
                                ),
                                const Divider(
                                    color: AppTheme.divider, height: 1),
                              ]);
                            },
                          )),
                Padding(
                    padding: const EdgeInsets.all(16),
                    child: OutlineActionButton(
                        label: context.l10n.cancel,
                        textColor: AppTheme.textPrimary,
                        borderColor: AppTheme.textSecondary,
                        onPressed: () => Navigator.pop(context))),
              ]),
        ),
      ),
    );
  }

  String _certLabel() {
    if (_selectedOrg == null) return 'Certificate ID';
    final orgMatch = RegExp(r'\(([^)]+)\)').firstMatch(_selectedOrg ?? '');
    final orgAbbr =
        orgMatch != null ? orgMatch.group(1)! : _selectedOrg!.split(' ').first;
    if (_selectedCert == null) return 'Certificate ID ($orgAbbr)';

    final certMatch = RegExp(r'\(([^)]+)\)').firstMatch(_selectedCert ?? '');
    String certAbbr;
    if (certMatch != null) {
      certAbbr = certMatch.group(1)!;
      if (certAbbr.contains('-')) {
        certAbbr = certAbbr.split('-').last.trim();
      }
    } else {
      certAbbr = _selectedCert!
          .split(' ')
          .map((w) => w[0])
          .take(3)
          .join()
          .toUpperCase();
    }
    return 'Certificate ID ($orgAbbr - $certAbbr)';
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.credential['_isEditing'] == true;
    final Color activeText = AppTheme.textPrimary;
    final bool certificateIdEditable = isEditing;

    InputBorder border(bool active) => OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          borderSide: BorderSide(
              color: active
                  ? AppTheme.textSecondary
                  : Colors.white.withValues(alpha: 0.08),
              width: 1.5),
        );
    InputBorder focusBorder() => OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          borderSide: const BorderSide(color: AppTheme.brand, width: 2),
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isEditing ? AppTheme.brand : AppTheme.divider,
            width: isEditing ? 1.5 : 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // ── Organisation ──
        _FieldLabel('Organisation', isEditing: isEditing),
        const SizedBox(height: 8),
        _TappableField(
          value: _selectedOrg,
          placeholder: 'Select Organisation',
          isEditing: isEditing,
          dimmed: !isEditing,
          onTap: isEditing ? _pickOrg : null,
        ),
        if (isEditing && _selectedOrg == null)
          _errorText(context.l10n.organisationRequired),
        const SizedBox(height: 14),

        // ── Certificate ──
        _FieldLabel('Certificate', isEditing: isEditing),
        const SizedBox(height: 8),
        _TappableField(
          value: _selectedCert,
          placeholder: _selectedOrg == null
              ? 'Select organisation first'
              : 'Select Certificate',
          isEditing: isEditing && _selectedOrg != null,
          dimmed: !isEditing || _selectedOrg == null,
          onTap: (isEditing && _selectedOrg != null) ? _pickCert : null,
        ),
        if (isEditing && _selectedOrg != null && _selectedCert == null)
          _errorText(context.l10n.certificateRequired),
        const SizedBox(height: 14),

        // ── Certificate ID ──
        _FieldLabel(_certLabel(), isEditing: isEditing),
        const SizedBox(height: 8),
        TextFormField(
          controller: _idCtrl,
          readOnly: !certificateIdEditable,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-/]'))
          ],
          style: TextStyle(
              color: certificateIdEditable ? activeText : activeText,
              fontSize: AppConstants.kDefaultSubtitleFontSize),
          decoration: InputDecoration(
            hintText: null,
            hintStyle: const TextStyle(color: AppTheme.textSecondary),
            filled: false,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            enabledBorder: border(certificateIdEditable),
            focusedBorder: focusBorder(),
          ),
        ),
        if (isEditing &&
            !RegExp(r'^[a-zA-Z0-9\-/]{3,}$').hasMatch(_idCtrl.text))
          _errorText(context.l10n.certificateIdRequired),

        const SizedBox(height: 18),

        if (isEditing)
          Row(children: [
            Expanded(
                child: SolidConfirmButton(
                    label: 'Save',
                    height: 40,
                    onPressed: _isValid
                        ? () {
                            widget.onSave({
                              'org': _selectedOrg!,
                              'cert': _selectedCert!,
                              'certId': _idCtrl.text.trim()
                            });
                          }
                        : null)),
            const SizedBox(width: 12),
            Expanded(
                child: OutlineActionButton(
                    label: 'Cancel',
                    textColor: AppTheme.textPrimary,
                    borderColor: AppTheme.textSecondary,
                    height: 40,
                    onPressed: widget.onCancel)),
          ])
        else
          Row(children: [
            Expanded(
                child: OutlineActionButton(
                    label: 'Edit',
                    icon:
                        const Icon(Icons.edit, size: 14, color: AppTheme.brand),
                    height: 40,
                    onPressed: widget.onEdit)),
            const SizedBox(width: 12),
            Expanded(
                child: OutlineActionButton(
                    label: 'Remove',
                    icon: const Icon(Icons.delete_outline,
                        size: 14, color: AppTheme.error),
                    textColor: AppTheme.error,
                    borderColor: AppTheme.error,
                    height: 40,
                    onPressed: widget.onRemove)),
          ]),
      ]),
    );
  }

  Widget _errorText(String msg) => StandardFormWarningBanner(
        message: msg,
        margin: const EdgeInsets.only(top: 6),
      );
}

// ── Small helpers used inside ProfileCredentialCard ──
class _FieldLabel extends StatelessWidget {
  final String text;
  final bool isEditing;
  const _FieldLabel(this.text, {required this.isEditing});
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(
          color: isEditing ? AppTheme.textPrimary : AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4));
}

class _TappableField extends StatelessWidget {
  final String? value;
  final String placeholder;
  final bool isEditing;
  final bool dimmed;
  final VoidCallback? onTap;
  const _TappableField(
      {required this.value,
      required this.placeholder,
      required this.isEditing,
      this.dimmed = false,
      this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          border: Border.all(
              color: isEditing && !dimmed
                  ? AppTheme.textSecondary
                  : Colors.white.withValues(alpha: 0.08),
              width: 1.5),
        ),
        child: Row(children: [
          Expanded(
              child: Text(
            value ?? placeholder,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: value != null
                    ? (isEditing
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary)
                    : (dimmed ? Colors.white24 : AppTheme.textSecondary),
                fontSize: AppConstants.kDefaultSubtitleFontSize),
            overflow: TextOverflow.ellipsis,
          )),
          if (isEditing && !dimmed)
            const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
        ]),
      ),
    );
  }
}

// =============================================================================
// EDIT MODAL FOR GRIDS
// =============================================================================
void _showEditStatModal(
    BuildContext context, Map<String, dynamic> metric, String currentValue) {
  final ctrl = TextEditingController(text: currentValue);
  AppMotion.showPremiumBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24),
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
            const SizedBox(height: 25),
            Text('Update ${metric['label']}',
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 25),
            TextFormField(
              controller: ctrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
              ],
              decoration: InputDecoration(
                suffixText: metric['unit'],
                suffixStyle: const TextStyle(color: AppTheme.textSecondary),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: AppTheme.textSecondary)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: AppTheme.brand, width: 2)),
              ),
            ),
            const SizedBox(height: 30),
            SolidConfirmButton(
                label: 'Save Measurement',
                onPressed: () {
                  HapticFeedback.selectionClick();
                  if (metric['isCircumference'] == true) {
                    appState.updateCircumferences(metric['key'], ctrl.text);
                  } else {
                    appState.updateBodyComp(metric['key'], ctrl.text);
                  }
                  Navigator.pop(ctx);
                }),
            const SizedBox(height: 30),
          ]),
    ),
  );
}

// =============================================================================
// BODY COMPOSITION SCREEN
// =============================================================================
class BodyCompositionScreen extends StatefulWidget {
  const BodyCompositionScreen({super.key});
  @override
  State<BodyCompositionScreen> createState() => _BodyCompositionScreenState();
}

class _BodyCompositionScreenState extends State<BodyCompositionScreen> {
  String _tl = '1M';
  final List<String> _timelines = ['1D', '1W', '1M', '3M', '6M', '1Y', 'All'];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final wU = appState.weightUnit == 'metric' ? 'kg' : 'lbs';
        final mU = appState.measurementUnit == 'metric' ? 'cm' : 'in';
        final metrics = [
          {'label': context.l10n.bodyWeight, 'key': 'Body Weight', 'unit': wU},
          {'label': context.l10n.height, 'key': 'Height', 'unit': mU},
          {'label': 'BMI', 'key': 'BMI', 'unit': '', 'readOnly': true},
          {'label': 'BMR', 'key': 'BMR', 'unit': 'kcal', 'readOnly': true},
          {'label': context.l10n.totalBodyWater, 'key': 'TBW', 'unit': 'L'},
          {'label': context.l10n.intracellularWater, 'key': 'ICW', 'unit': 'L'},
          {'label': context.l10n.extracellularWater, 'key': 'ECW', 'unit': 'L'},
          {'label': context.l10n.skeletalMuscleMass, 'key': 'SMM', 'unit': wU},
          {'label': context.l10n.softLeanMass, 'key': 'SLM', 'unit': wU},
          {'label': context.l10n.fatFreeMass, 'key': 'FFM', 'unit': wU},
          {'label': context.l10n.bodyFatMass, 'key': 'BFM', 'unit': wU},
          {'label': context.l10n.bodyFatPercentage, 'key': 'PBF', 'unit': '%'},
          {
            'label': context.l10n.subcutaneousFatMass,
            'key': 'Subcutaneous Fat Mass',
            'unit': wU
          },
          {'label': context.l10n.rightArm, 'key': 'Right Arm', 'unit': wU},
          {'label': context.l10n.leftArm, 'key': 'Left Arm', 'unit': wU},
          {'label': context.l10n.trunk, 'key': 'Trunk', 'unit': wU},
          {'label': context.l10n.rightLeg, 'key': 'Right Leg', 'unit': wU},
          {'label': context.l10n.leftLeg, 'key': 'Left Leg', 'unit': wU},
        ];
        return Scaffold(
          backgroundColor: AppTheme.bg,
          appBar: AppBar(
              elevation: 0,
              iconTheme: const IconThemeData(color: AppTheme.textPrimary),
              title: Text(context.l10n.bodyComposition,
                  style: const TextStyle(color: AppTheme.brand))),
          body:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _timelines.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (_, i) {
                    final t = _timelines[i];
                    final sel = t == _tl;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _tl = t);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: sel ? AppTheme.brand : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color:
                                    sel ? AppTheme.brand : AppTheme.divider)),
                        child: Text(t,
                            style: TextStyle(
                                color:
                                    sel ? AppTheme.bg : AppTheme.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ),
                    );
                  },
                )),
            const SizedBox(height: 20),
            Expanded(
                child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24)
                  .copyWith(bottom: 24),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.85),
              itemCount: metrics.length,
              itemBuilder: (_, i) {
                final m = metrics[i];
                final key = m['key'] as String;
                final val = appState.bodyComposition[key] ?? '0.0';
                final ro = m['readOnly'] == true;
                final imgKey = key.toLowerCase().replaceAll(' ', '_');
                return GestureDetector(
                  onTap: ro
                      ? () => AppUtils.showToast(
                          context, 'This value is calculated automatically.')
                      : () => _showEditStatModal(context, m, val),
                  child: Container(
                    decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.divider)),
                    child: Stack(children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                                child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Image.asset(
                                        'assets/images/$imgKey.png',
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.accessibility_new,
                                                color: AppTheme.textSecondary,
                                                size: 40)))),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8),
                              decoration: const BoxDecoration(
                                  color: AppTheme.bg,
                                  borderRadius: BorderRadius.vertical(
                                      bottom: Radius.circular(16))),
                              child: Column(children: [
                                Text(m['label'] as String,
                                    style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 13),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text('$val ${m['unit']}',
                                    style: const TextStyle(
                                        color: AppTheme.brand,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ]),
                            ),
                          ]),
                      if (!ro)
                        const Positioned(
                            top: 10,
                            right: 10,
                            child: Icon(Icons.edit,
                                color: AppTheme.textSecondary, size: 16)),
                    ]),
                  ),
                );
              },
            )),
          ]),
        );
      },
    );
  }
}

// =============================================================================
// CIRCUMFERENCES SCREEN
// =============================================================================
class CircumferencesScreen extends StatefulWidget {
  const CircumferencesScreen({super.key});
  @override
  State<CircumferencesScreen> createState() => _CircumferencesScreenState();
}

class _CircumferencesScreenState extends State<CircumferencesScreen> {
  String _tl = '1M';
  final List<String> _timelines = ['1D', '1W', '1M', '3M', '6M', '1Y', 'All'];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final mU = appState.measurementUnit == 'metric' ? 'cm' : 'in';
        final metrics = [
          {
            'label': context.l10n.neck,
            'key': 'Neck',
            'unit': mU,
            'isCircumference': true
          },
          {
            'label': context.l10n.shoulder,
            'key': 'Shoulder',
            'unit': mU,
            'isCircumference': true
          },
          {
            'label': context.l10n.chest,
            'key': 'Chest',
            'unit': mU,
            'isCircumference': true
          },
          {
            'label': context.l10n.arm,
            'key': 'Arm',
            'unit': mU,
            'isCircumference': true
          },
          {
            'label': context.l10n.forearm,
            'key': 'Forearm',
            'unit': mU,
            'isCircumference': true
          },
          {
            'label': 'Wrist',
            'key': 'Wrist',
            'unit': mU,
            'isCircumference': true
          },
          {
            'label': context.l10n.waist,
            'key': 'Waist',
            'unit': mU,
            'isCircumference': true
          },
          {
            'label': context.l10n.thigh,
            'key': 'Thigh',
            'unit': mU,
            'isCircumference': true
          },
          {
            'label': context.l10n.calf,
            'key': 'Calf',
            'unit': mU,
            'isCircumference': true
          },
        ];
        return Scaffold(
          backgroundColor: AppTheme.bg,
          appBar: AppBar(
              elevation: 0,
              iconTheme: const IconThemeData(color: AppTheme.textPrimary),
              title: Text(context.l10n.circumferences,
                  style: const TextStyle(color: AppTheme.brand))),
          body:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _timelines.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (_, i) {
                    final t = _timelines[i];
                    final sel = t == _tl;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _tl = t);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: sel ? AppTheme.brand : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color:
                                    sel ? AppTheme.brand : AppTheme.divider)),
                        child: Text(t,
                            style: TextStyle(
                                color:
                                    sel ? AppTheme.bg : AppTheme.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ),
                    );
                  },
                )),
            const SizedBox(height: 20),
            Expanded(
                child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24)
                  .copyWith(bottom: 24),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.85),
              itemCount: metrics.length,
              itemBuilder: (_, i) {
                final m = metrics[i];
                final key = m['key'] as String;
                final val = appState.circumferences[key] ?? '0.0';
                final imgKey = key.toLowerCase().replaceAll(' ', '_');
                return GestureDetector(
                  onTap: () => _showEditStatModal(context, m, val),
                  child: Container(
                    decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.divider)),
                    child: Stack(children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                                child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Image.asset(
                                        'assets/images/$imgKey.png',
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.accessibility_new,
                                                color: AppTheme.textSecondary,
                                                size: 40)))),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8),
                              decoration: const BoxDecoration(
                                  color: AppTheme.bg,
                                  borderRadius: BorderRadius.vertical(
                                      bottom: Radius.circular(16))),
                              child: Column(children: [
                                Text(m['label'] as String,
                                    style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 13),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text('$val ${m['unit']}',
                                    style: const TextStyle(
                                        color: AppTheme.brand,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ]),
                            ),
                          ]),
                      const Positioned(
                          top: 10,
                          right: 10,
                          child: Icon(Icons.edit,
                              color: AppTheme.textSecondary, size: 16)),
                    ]),
                  ),
                );
              },
            )),
          ]),
        );
      },
    );
  }
}

// =============================================================================
// PLACES OF EMPLOYMENT SCREEN — full CRUD + isOnlineOnly option (fix #3 & #5)
// =============================================================================
class PlacesOfEmploymentScreen extends StatefulWidget {
  const PlacesOfEmploymentScreen({super.key});
  @override
  State<PlacesOfEmploymentScreen> createState() =>
      _PlacesOfEmploymentScreenState();
}

class _PlacesOfEmploymentScreenState extends State<PlacesOfEmploymentScreen> {
  static const List<String> _placeTypes = [
    'Gym',
    'Fitness Club',
    'Studio',
    'Outdoor',
    'Pool',
    'Rehabilitation Center',
    'Sports Complex',
    'Other',
  ];

  void _openSheet({Map<String, dynamic>? existing, int? editIdx}) {
    final nameCtrl = TextEditingController(text: existing?['name'] ?? '');
    final addrCtrl = TextEditingController(text: existing?['address'] ?? '');
    final cityCtrl = TextEditingController(text: existing?['city'] ?? '');
    final countryCtrl = TextEditingController(text: existing?['country'] ?? '');
    String selType = existing?['type'] ?? _placeTypes.first;

    AppMotion.showPremiumBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setM) {
        bool nameOk() => nameCtrl.text.trim().length >= 2;
        bool addrOk() => addrCtrl.text.trim().length >= 5;
        bool cityOk() => cityCtrl.text.trim().length >= 2;
        bool countryOk() => countryCtrl.text.trim().length >= 2;
        bool allOk() => nameOk() && addrOk() && cityOk() && countryOk();

        InputDecoration dec(String label) => InputDecoration(
              labelText: label,
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
                  const SizedBox(height: 25),
                  Text(editIdx != null ? 'Edit Location' : 'Add Location',
                      style: const TextStyle(
                          color: AppTheme.brand,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 25),
                  const Text('Location Type',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: AppConstants.kDefaultSubtitleFontSize)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _placeTypes.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final t = _placeTypes[i];
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
                  TextFormField(
                      controller: nameCtrl,
                      onChanged: (_) => setM(() {}),
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: AppConstants.kDefaultSubtitleFontSize),
                      decoration: dec('Facility / Location Name')),
                  const SizedBox(height: 15),
                  TextFormField(
                      controller: addrCtrl,
                      onChanged: (_) => setM(() {}),
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: AppConstants.kDefaultSubtitleFontSize),
                      decoration: dec('Street Address')),
                  const SizedBox(height: 15),
                  Row(children: [
                    Expanded(
                        child: TextFormField(
                            controller: cityCtrl,
                            onChanged: (_) => setM(() {}),
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize:
                                    AppConstants.kDefaultSubtitleFontSize),
                            decoration: dec('City'))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: TextFormField(
                            controller: countryCtrl,
                            onChanged: (_) => setM(() {}),
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize:
                                    AppConstants.kDefaultSubtitleFontSize),
                            decoration: dec('Country'))),
                  ]),
                  const SizedBox(height: 30),
                  SolidConfirmButton(
                    label: editIdx != null ? 'Save Changes' : 'Add Location',
                    height: AppConstants.kDefaultButtonHeightLarge,
                    onPressed: allOk()
                        ? () {
                            HapticFeedback.selectionClick();
                            final place = {
                              'name': nameCtrl.text.trim(),
                              'address': addrCtrl.text.trim(),
                              'city': cityCtrl.text.trim(),
                              'country': countryCtrl.text.trim(),
                              'type': selType
                            };
                            if (editIdx != null) {
                              appState.updatePlaceOfEmployment(editIdx, place);
                            } else {
                              appState.addPlaceOfEmployment(place);
                            }
                            setState(() {});
                            Navigator.pop(ctx);
                            AppUtils.showToast(
                                context,
                                editIdx != null
                                    ? 'Location updated.'
                                    : 'Location added.');
                          }
                        : null,
                  ),
                  const SizedBox(height: 12),
                  OutlineActionButton(
                      label: 'Cancel',
                      height: AppConstants.kDefaultButtonHeightLarge,
                      textColor: AppTheme.textPrimary,
                      borderColor: AppTheme.textSecondary,
                      onPressed: () => Navigator.pop(ctx)),
                  const SizedBox(height: 30),
                ]),
          ),
        );
      }),
    );
  }

  void _confirmDelete(int idx) {
    HapticFeedback.lightImpact();
    AppMotion.showPremiumDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.kDefaultBorderRadius)),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        actionsPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Remove Location',
                      style: TextStyle(
                          color: AppTheme.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 20))),
              const Divider(color: AppTheme.divider, height: 1),
              const SizedBox(height: 20),
              Text(
                  'Remove "${appState.placesOfEmployment[idx]['name']}" from your profile?',
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: AppConstants.kDefaultSubtitleFontSize,
                      height: 1.5)),
            ]),
        actions: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlineActionButton(
                    label: 'Remove',
                    height: 44,
                    textColor: AppTheme.error,
                    borderColor: AppTheme.error,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      appState.removePlaceOfEmployment(idx);
                      setState(() {});
                      Navigator.pop(ctx);
                      AppUtils.showToast(context, 'Location removed.');
                    }),
                const SizedBox(height: 12),
                SolidConfirmButton(
                    label: 'Cancel',
                    height: 44,
                    onPressed: () => Navigator.pop(ctx)),
              ])
        ],
      ),
    );
  }

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
                style: TextStyle(color: AppTheme.brand))),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            // Explainer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.divider)),
              child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        color: AppTheme.textSecondary, size: 18),
                    SizedBox(width: 12),
                    Expanded(
                        child: Text(
                            'Add the gyms, studios, or outdoor spaces where you train clients in real life. If you operate exclusively online, you can indicate that instead.',
                            style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                                height: 1.5))),
                  ]),
            ),
            const SizedBox(height: 20),

            // ── Radio option 1: Hybrid ──
            _EmploymentRadio(
              mode: 0,
              selected: appState.employmentMode,
              title: context.l10n.hybridTraining,
              description: context.l10n.hybridTrainingDesc,
              onTap: () {
                appState.employmentMode = 0;
                appState.setOnlineOnly(false);
                setState(() {});
              },
            ),
            const SizedBox(height: 10),

            // ── Radio option 2: Online Only ──
            _EmploymentRadio(
              mode: 1,
              selected: appState.employmentMode,
              title: context.l10n.onlineOnlyTraining,
              description: context.l10n.onlineOnlyTrainingDesc,
              onTap: () {
                if (appState.placesOfEmployment.isNotEmpty) {
                  AppMotion.showPremiumDialog<void>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppTheme.surface,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppConstants.kDefaultBorderRadius)),
                      title: const Text('Switch to Online Only?',
                          style: TextStyle(
                              color: AppTheme.brand,
                              fontWeight: FontWeight.bold)),
                      content: const Text(
                          'This will remove all your listed physical locations from your public profile.',
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: AppConstants.kDefaultSubtitleFontSize,
                              height: 1.5)),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel',
                                style:
                                    TextStyle(color: AppTheme.textSecondary))),
                        TextButton(
                            onPressed: () {
                              appState.employmentMode = 1;
                              appState.setOnlineOnly(true);
                              setState(() {});
                              Navigator.pop(ctx);
                              AppUtils.showToast(
                                  context, 'Switched to online-only mode.');
                            },
                            child: const Text('Confirm',
                                style: TextStyle(
                                    color: AppTheme.error,
                                    fontWeight: FontWeight.bold))),
                      ],
                    ),
                  );
                } else {
                  appState.employmentMode = 1;
                  appState.setOnlineOnly(true);
                  setState(() {});
                }
              },
            ),
            const SizedBox(height: 10),

            // ── Radio option 3: In-Person Only ──
            _EmploymentRadio(
              mode: 2,
              selected: appState.employmentMode,
              title: context.l10n.inPersonOnlyTraining,
              description: context.l10n.inPersonOnlyTrainingDesc,
              onTap: () {
                appState.employmentMode = 2;
                appState.setOnlineOnly(false);
                setState(() {});
              },
            ),
            const SizedBox(height: 16),

            // Online-only banner
            if (appState.employmentMode == 1) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.brand.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppTheme.brand.withValues(alpha: 0.25)),
                ),
                child: const Row(children: [
                  Icon(Icons.wifi, color: AppTheme.brand, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                      child: Text(
                          'Your profile shows "Online Training Only". Clients worldwide can find and subscribe to you.',
                          style: TextStyle(
                              color: AppTheme.brand,
                              fontSize: 13,
                              height: 1.4))),
                ]),
              ),
            ] else ...[
              // Physical locations list
              if (appState.placesOfEmployment.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(children: const [
                    Icon(Icons.location_off,
                        color: AppTheme.textSecondary, size: 48),
                    SizedBox(height: 16),
                    Text('No locations added yet.',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 14)),
                    SizedBox(height: 6),
                    Text('Tap the button below to add your first location.',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12),
                        textAlign: TextAlign.center),
                  ]),
                )
              else
                ...appState.placesOfEmployment.asMap().entries.map((e) {
                  final idx = e.key;
                  final p = e.value;
                  final IconData icon;
                  final Color iconColor;
                  switch ((p['type'] as String? ?? '').toLowerCase()) {
                    case 'gym':
                      icon = Icons.fitness_center;
                      iconColor = AppTheme.cardBlue;
                      break;
                    case 'fitness club':
                      icon = Icons.sports_gymnastics;
                      iconColor = AppTheme.cardPurple;
                      break;
                    case 'outdoor':
                      icon = Icons.park;
                      iconColor = AppTheme.cardGreen;
                      break;
                    case 'studio':
                      icon = Icons.self_improvement;
                      iconColor = AppTheme.cardYellow;
                      break;
                    case 'pool':
                      icon = Icons.pool;
                      iconColor = AppTheme.cardIndigo;
                      break;
                    default:
                      icon = Icons.location_on;
                      iconColor = AppTheme.cardPink;
                  }
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.divider)),
                    child: Column(children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        leading: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                                color: iconColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10)),
                            child: Icon(icon, color: iconColor, size: 22)),
                        title: Text(p['name'] as String,
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 3),
                              Text(p['address'] as String,
                                  style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12)),
                              const SizedBox(height: 2),
                              Text('${p['city']}, ${p['country']}',
                                  style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12)),
                            ]),
                        trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: iconColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6)),
                            child: Text(p['type'] as String,
                                style: TextStyle(
                                    color: iconColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold))),
                      ),
                      const Divider(color: AppTheme.divider, height: 1),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton.icon(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  _openSheet(existing: p, editIdx: idx);
                                },
                                icon: const Icon(Icons.edit_outlined,
                                    color: AppTheme.brand, size: 16),
                                label: const Text('Edit',
                                    style: TextStyle(
                                        color: AppTheme.brand,
                                        fontWeight: FontWeight.bold))),
                            Container(
                                width: 1, height: 30, color: AppTheme.divider),
                            TextButton.icon(
                                onPressed: () => _confirmDelete(idx),
                                icon: const Icon(Icons.delete_outline,
                                    color: AppTheme.error, size: 16),
                                label: const Text('Remove',
                                    style: TextStyle(color: AppTheme.error))),
                          ]),
                    ]),
                  );
                }),

              const SizedBox(height: 10),
              OutlineActionButton(
                  label: 'Add New Location',
                  icon: const Icon(Icons.add_location_alt_outlined,
                      color: AppTheme.brand),
                  height: AppConstants.kDefaultButtonHeightLarge,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _openSheet();
                  }),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _EmploymentRadio extends StatelessWidget {
  final int mode;
  final int selected;
  final String title;
  final String description;
  final VoidCallback onTap;
  const _EmploymentRadio({
    required this.mode,
    required this.selected,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool sel = mode == selected;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color:
              sel ? AppTheme.brand.withValues(alpha: 0.08) : AppTheme.surface,
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          border: Border.all(
              color: sel ? AppTheme.brand : AppTheme.divider,
              width: sel ? 1.5 : 1),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
                sel ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: sel ? AppTheme.brand : AppTheme.textSecondary,
                size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: TextStyle(
                        color: sel ? AppTheme.brand : AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text(description,
                    style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        height: 1.4)),
              ])),
        ]),
      ),
    );
  }
}

// =============================================================================
// INJURY PROFILE BLOC & SCREEN
// =============================================================================

// --- BLoC Events ---
abstract class InjuryProfileEvent extends Equatable {
  const InjuryProfileEvent();
  @override
  List<Object?> get props => [];
}

class AddInjury extends InjuryProfileEvent {
  final InjuryModel injury;
  const AddInjury(this.injury);
  @override
  List<Object?> get props => [injury];
}

class UpdateInjury extends InjuryProfileEvent {
  final InjuryModel injury;
  const UpdateInjury(this.injury);
  @override
  List<Object?> get props => [injury];
}

class RemoveInjury extends InjuryProfileEvent {
  final String id;
  const RemoveInjury(this.id);
  @override
  List<Object?> get props => [id];
}

class SubmitProfile extends InjuryProfileEvent {
  const SubmitProfile();
}

// --- BLoC States ---
abstract class InjuryProfileState extends Equatable {
  const InjuryProfileState();
  @override
  List<Object?> get props => [];
}

class InjuryProfileInitial extends InjuryProfileState {}

class InjuryProfileUpdated extends InjuryProfileState {
  final List<InjuryModel> injuries;
  const InjuryProfileUpdated({required this.injuries});
  @override
  List<Object?> get props => [injuries];
}

class InjuryProfileSubmitting extends InjuryProfileState {
  final List<InjuryModel> injuries;
  const InjuryProfileSubmitting({required this.injuries});
  @override
  List<Object?> get props => [injuries];
}

class InjuryProfileSuccess extends InjuryProfileState {}

class InjuryProfileError extends InjuryProfileState {
  final String message;
  final List<InjuryModel> injuries;
  const InjuryProfileError({required this.message, required this.injuries});
  @override
  List<Object?> get props => [message, injuries];
}

// --- BLoC ---
class InjuryProfileBloc extends Bloc<InjuryProfileEvent, InjuryProfileState> {
  List<InjuryModel> _injuries = [];

  InjuryProfileBloc() : super(InjuryProfileInitial()) {
    on<AddInjury>((event, emit) {
      _injuries = List.from(_injuries)..add(event.injury);
      emit(InjuryProfileUpdated(injuries: _injuries));
    });

    on<UpdateInjury>((event, emit) {
      final index = _injuries.indexWhere((i) => i.id == event.injury.id);
      if (index != -1) {
        _injuries[index] = event.injury;
        emit(InjuryProfileUpdated(injuries: List.from(_injuries)));
      }
    });

    on<RemoveInjury>((event, emit) {
      _injuries = List.from(_injuries)..removeWhere((i) => i.id == event.id);
      emit(InjuryProfileUpdated(injuries: _injuries));
    });

    on<SubmitProfile>((event, emit) async {
      emit(InjuryProfileSubmitting(injuries: _injuries));
      try {
        await Future.delayed(const Duration(seconds: 1)); // Simulate API call
        emit(InjuryProfileSuccess());
      } catch (e) {
        emit(InjuryProfileError(
            message: 'Failed to submit profile', injuries: _injuries));
      }
    });
  }
}

// --- SCREEN ---
class InjuryProfileScreen extends StatelessWidget {
  const InjuryProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InjuryProfileBloc(),
      child: const _InjuryProfileView(),
    );
  }
}

class _InjuryProfileView extends StatelessWidget {
  const _InjuryProfileView();

  void _showInjuryForm(BuildContext context, {InjuryModel? injury}) {
    final bloc = context.read<InjuryProfileBloc>();
    AppMotion.showPremiumBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _InjuryFormSheet(
          initialInjury: injury,
          onSave: (newInjury) {
            if (injury == null) {
              bloc.add(AddInjury(newInjury));
            } else {
              bloc.add(UpdateInjury(newInjury));
            }
            Navigator.pop(context);
          },
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
        backgroundColor: AppTheme.bg,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        title: const Text('Injury & Medical Profile',
            style: TextStyle(color: AppTheme.brand)),
      ),
      body: BlocConsumer<InjuryProfileBloc, InjuryProfileState>(
        listener: (context, state) {
          if (state is InjuryProfileSuccess) {
            AppUtils.showToast(context, 'Profile submitted successfully');
            Navigator.pop(context);
          } else if (state is InjuryProfileError) {
            AppUtils.showToast(context, state.message);
          }
        },
        builder: (context, state) {
          List<InjuryModel> injuries = [];
          if (state is InjuryProfileUpdated) {
            injuries = state.injuries;
          } else if (state is InjuryProfileSubmitting) {
            injuries = state.injuries;
          } else if (state is InjuryProfileError) {
            injuries = state.injuries;
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Log your past and current injuries. This information helps us tailor your fitness plan safely.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ...injuries.map((injury) => InjuryCard(
                    injury: injury,
                    onEdit: () => _showInjuryForm(context, injury: injury),
                    onRemove: () => context
                        .read<InjuryProfileBloc>()
                        .add(RemoveInjury(injury.id)),
                  )),
              OutlineActionButton(
                label: 'Add Another Injury',
                icon: const Icon(Icons.add, color: AppTheme.brand, size: 18),
                height: AppConstants.kDefaultButtonHeightLarge,
                onPressed: () => _showInjuryForm(context),
              ),
              const SizedBox(height: 40),
              SolidConfirmButton(
                label: state is InjuryProfileSubmitting
                    ? 'Submitting...'
                    : 'Submit Profile',
                height: AppConstants.kDefaultButtonHeightLarge,
                onPressed: state is InjuryProfileSubmitting
                    ? () {}
                    : () {
                        if (injuries.isEmpty) {
                          AppUtils.showToast(context,
                              'Please add at least one injury or condition, or skip.');
                          return;
                        }
                        context
                            .read<InjuryProfileBloc>()
                            .add(const SubmitProfile());
                      },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InjuryFormSheet extends StatefulWidget {
  final InjuryModel? initialInjury;
  final ValueChanged<InjuryModel> onSave;

  const _InjuryFormSheet({this.initialInjury, required this.onSave});

  @override
  State<_InjuryFormSheet> createState() => _InjuryFormSheetState();
}

class _InjuryFormSheetState extends State<_InjuryFormSheet> {
  final TextEditingController _bodyPartCtrl = TextEditingController();
  InjuryType? _selectedType;
  double _severity = 1.0;
  InjuryRecency? _selectedRecency;

  @override
  void initState() {
    super.initState();
    if (widget.initialInjury != null) {
      _bodyPartCtrl.text = widget.initialInjury!.bodyPart;
      _selectedType = widget.initialInjury!.type;
      _severity = widget.initialInjury!.severity.toDouble();
      _selectedRecency = widget.initialInjury!.recency;
    }
  }

  @override
  void dispose() {
    _bodyPartCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_bodyPartCtrl.text.isEmpty ||
        _selectedType == null ||
        _selectedRecency == null) {
      return;
    }

    final newInjury = InjuryModel(
      id: widget.initialInjury?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      bodyPart: _bodyPartCtrl.text.trim(),
      type: _selectedType!,
      severity: _severity.toInt(),
      recency: _selectedRecency!,
    );

    widget.onSave(newInjury);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Text(
            widget.initialInjury == null ? 'Add Injury' : 'Edit Injury',
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          TextFormField(
            controller: _bodyPartCtrl,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              labelText: 'Body Part (e.g., ACL, Lower Back)',
              labelStyle: const TextStyle(color: AppTheme.textSecondary),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                borderSide:
                    const BorderSide(color: AppTheme.textSecondary, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                borderSide: const BorderSide(color: AppTheme.brand, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Injury Type',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          DropdownButtonFormField<InjuryType>(
            initialValue: _selectedType,
            dropdownColor: AppTheme.surface,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                borderSide:
                    const BorderSide(color: AppTheme.textSecondary, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                borderSide: const BorderSide(color: AppTheme.brand, width: 2),
              ),
            ),
            hint: const Text('Select type...',
                style: TextStyle(color: AppTheme.textSecondary)),
            items: InjuryType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.label,
                    style: const TextStyle(color: AppTheme.textPrimary)),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedType = val),
          ),
          const SizedBox(height: 20),
          const Text('Severity Level (1-10)',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Slider(
            value: _severity,
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: AppTheme.brand,
            inactiveColor: AppTheme.divider,
            label: _severity.round().toString(),
            onChanged: (val) => setState(() => _severity = val),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('1 - Mild',
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              Text('10 - Debilitating',
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Recency',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: InjuryRecency.values.map((recency) {
              final isSelected = _selectedRecency == recency;
              return ChoiceChip(
                label: Text(recency.label),
                selected: isSelected,
                selectedColor: AppTheme.brand.withValues(alpha: 0.2),
                backgroundColor: AppTheme.surface,
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.brand : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                side: BorderSide(
                    color: isSelected ? AppTheme.brand : AppTheme.divider),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        AppConstants.kDefaultBorderRadius)),
                onSelected: (val) {
                  if (val) setState(() => _selectedRecency = recency);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          SolidConfirmButton(
            label: 'Save Injury',
            height: AppConstants.kDefaultButtonHeightLarge,
            onPressed: () {
              if (_bodyPartCtrl.text.isEmpty ||
                  _selectedType == null ||
                  _selectedRecency == null) {
                return;
              }
              _save();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
