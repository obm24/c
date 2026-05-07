import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

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
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/b_phone_validation.dart';

const int _minimumRegistrationAge = 16;

bool isAtLeastMinimumRegistrationAge(
  DateTime dateOfBirth, {
  DateTime? today,
  int minimumAge = _minimumRegistrationAge,
}) {
  final now = today ?? DateTime.now();
  final currentDate = DateTime(now.year, now.month, now.day);
  final birthDate = DateTime(
    dateOfBirth.year,
    dateOfBirth.month,
    dateOfBirth.day,
  );
  if (birthDate.isAfter(currentDate)) return false;

  var age = currentDate.year - birthDate.year;
  final hasHadBirthdayThisYear = currentDate.month > birthDate.month ||
      (currentDate.month == birthDate.month &&
          currentDate.day >= birthDate.day);
  if (!hasHadBirthdayThisYear) age -= 1;
  return age >= minimumAge;
}

// =============================================================================
// LOGIN SCREEN
// =============================================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idCtrl   = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  String? _idError, _passError;

  @override
  void initState() {
    super.initState();
    _idCtrl.addListener(() => setState(() {}));
    _passCtrl.addListener(() => setState(() {}));
  }

  Future<void> _handleLogin() async {
    setState(() { _idError = null; _passError = null; });
    final id   = _idCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final bool isEmailInput = id.contains('@');
    String role = '';
    await Future.delayed(const Duration(milliseconds: 1200));
    if (id == '1' && pass == '1') {
      role = 'Trainer';
    } else if (id == '2' && pass == '2') {
      role = 'Trainee';
    } else {
      HapticFeedback.lightImpact();
      setState(() {
        _idError   = isEmailInput ? context.l10n.incorrectEmail : context.l10n.incorrectUsername;
        _passError = context.l10n.incorrectPassword;
      });
      return;
    }
    if (mounted) context.go('/dashboard/$role');
  }

  @override
  Widget build(BuildContext context) {
    final ready = _idCtrl.text.isNotEmpty && _passCtrl.text.isNotEmpty;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.bg,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: AppStaggeredList(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              stepDelay: const Duration(milliseconds: 28),
              children: [
                const SizedBox(height: 80),
                Center(
                  child: Hero(
                    tag: 'app_title_hero',
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text(context.l10n.appName,
                          style: const TextStyle(
                              color: AppTheme.brand,
                              fontSize: AppConstants.kDefaultAppTitleFontSize,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2)),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                TextFormField(
                  controller: _idCtrl,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: AppConstants.kDefaultSubtitleFontSize),
                  textInputAction: TextInputAction.next,
                  inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\n'))],
                  decoration: InputDecoration(
                    labelText: context.l10n.id,
                    errorText: _idError,
                    labelStyle: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: AppConstants.kDefaultSubtitleFontSize),
                    floatingLabelStyle: WidgetStateTextStyle.resolveWith((s) => TextStyle(
                        color: s.contains(WidgetState.focused) ? AppTheme.brand : AppTheme.textPrimary,
                        fontSize: AppConstants.kDefaultFormTitleFontSize)),
                    prefixIcon: const Icon(CupertinoIcons.person_solid,
                        size: AppConstants.kDefaultIconSize, color: AppTheme.textSecondary),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                        borderSide: const BorderSide(color: AppTheme.textSecondary, width: 1.5)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                        borderSide: const BorderSide(color: AppTheme.brand, width: 2)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                        borderSide: const BorderSide(color: AppTheme.error, width: 1.5)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                        borderSide: const BorderSide(color: AppTheme.error, width: 2)),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: true,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: AppConstants.kDefaultSubtitleFontSize),
                  textInputAction: TextInputAction.done,
                  inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\n'))],
                  decoration: InputDecoration(
                    labelText: context.l10n.password,
                    errorText: _passError,
                    labelStyle: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: AppConstants.kDefaultSubtitleFontSize),
                    floatingLabelStyle: WidgetStateTextStyle.resolveWith((s) => TextStyle(
                        color: s.contains(WidgetState.focused) ? AppTheme.brand : AppTheme.textPrimary,
                        fontSize: AppConstants.kDefaultFormTitleFontSize)),
                    prefixIcon: const Icon(CupertinoIcons.lock_fill,
                        size: AppConstants.kDefaultIconSize, color: AppTheme.textSecondary),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                        borderSide: const BorderSide(color: AppTheme.textSecondary, width: 1.5)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                        borderSide: const BorderSide(color: AppTheme.brand, width: 2)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                        borderSide: const BorderSide(color: AppTheme.error, width: 1.5)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                        borderSide: const BorderSide(color: AppTheme.error, width: 2)),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(context,
                          AppRoutes.noTransitionRoute(const ForgotPasswordScreen()));
                    },
                    child: Text(context.l10n.forgotPassword,
                        style: const TextStyle(
                            color: AppTheme.brand,
                            fontSize: AppConstants.kDefaultSubtitleFontSize)),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: AnimatedLoginButton(
                      label: context.l10n.login,
                      onPressed: ready ? _handleLogin : () async {}),
                ),
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(context.l10n.dontHaveAccount,
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: AppConstants.kDefaultSubtitleFontSize)),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(context,
                          AppRoutes.noTransitionRoute(const RegistrationScreen()));
                    },
                    child: Text(context.l10n.register,
                        style: const TextStyle(
                            color: AppTheme.brand,
                            fontWeight: FontWeight.bold,
                            fontSize: AppConstants.kDefaultSubtitleFontSize)),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// REGISTRATION SCREEN
// =============================================================================
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool? _isTrainer;
  bool? _isMetric;

  final TextEditingController _usernameCtrl  = TextEditingController();
  final TextEditingController _fNameCtrl     = TextEditingController();
  final TextEditingController _lNameCtrl     = TextEditingController();
  final TextEditingController _emailCtrl     = TextEditingController();
  final TextEditingController _passCtrl      = TextEditingController();
  final TextEditingController _confPassCtrl  = TextEditingController();
  final TextEditingController _phoneCtrl     = TextEditingController();
  final TextEditingController _heightCtrl    = TextEditingController();
  final TextEditingController _weightCtrl    = TextEditingController();
  final TextEditingController _idNumberCtrl  = TextEditingController();
  final GlobalKey _countryFieldKey           = GlobalKey();
  final GlobalKey _subdivisionFieldKey       = GlobalKey();

  bool _idImageUploaded = false;
  List<String> _trainerSpecialties             = [];
  List<String> _traineeGoals                   = [];
  int?         _selectedTrainingExperienceYears;
  List<String> _preferredDiets                 = [];
  final List<Map<String, dynamic>> _trainerCredentials = [];

  // 0 = Hybrid, 1 = Online Only, 2 = In-Person Only
  int? _employmentMode;
  final List<Map<String, dynamic>> _regPlaces = [];

  String? _selectedCountryCode;
  late List<String> _sortedCodes;

  String?   _selectedCountry;
  String?   _selectedRegion;
  DateTime? _dob;
  String?   _gender;

  @override
  void initState() {
    super.initState();
    _sortedCodes = List.from(AppConstants.kCountryCodes)
      ..sort((a, b) {
        int vA = int.parse(a.split('+').last.replaceAll(RegExp(r'[^0-9]'), ''));
        int vB = int.parse(b.split('+').last.replaceAll(RegExp(r'[^0-9]'), ''));
        return vA.compareTo(vB);
      });
    for (final ctrl in [
      _usernameCtrl, _fNameCtrl, _lNameCtrl, _emailCtrl,
      _passCtrl, _confPassCtrl, _phoneCtrl, _idNumberCtrl,
    ]) {
      ctrl.addListener(() => setState(() {}));
    }
    _heightCtrl.addListener(() => setState(() {}));
    _weightCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final ctrl in [
      _usernameCtrl, _fNameCtrl, _lNameCtrl, _emailCtrl,
      _passCtrl, _confPassCtrl, _phoneCtrl, _heightCtrl,
      _weightCtrl, _idNumberCtrl,
    ]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  // ── Validators ────────────────────────────────────────────────────────────
  bool get isUsernameValid =>
      RegExp(r'^[a-zA-Z0-9_]{4,19}$').hasMatch(_usernameCtrl.text);
  bool get isFNameValid =>
      RegExp(r'^[\p{L}\s\-]{2,}$', unicode: true).hasMatch(_fNameCtrl.text);
  bool get isLNameValid =>
      RegExp(r'^[\p{L}\s\-]{2,}$', unicode: true).hasMatch(_lNameCtrl.text);
  bool get isEmailValid =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailCtrl.text);
  bool get isPassValid =>
      RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{8,}$')
          .hasMatch(_passCtrl.text);
  bool get isConfPassValid =>
      _confPassCtrl.text.isNotEmpty && _confPassCtrl.text == _passCtrl.text;
  bool get isPhoneValid => PhoneValidationService.validateDetailed(
        '',
        _phoneCtrl.text,
        dialCodeSelection: _selectedCountryCode,
      ).isValid;

  bool get isDobValid {
    final dob = _dob;
    return dob != null && isAtLeastMinimumRegistrationAge(dob);
  }

  bool get isHeightValid {
    if (_isMetric == null) return false;
    if (_isMetric == true) {
      final h = double.tryParse(_heightCtrl.text.trim());
      return h != null && h >= 100 && h <= 250;
    }
    final inches = _heightInInches();
    return inches != null && inches >= 39 && inches <= 98;
  }

  bool get isWeightValid {
    if (_isMetric == null) return false;
    final w = double.tryParse(_weightCtrl.text.trim());
    if (w == null) return false;
    return _isMetric == true ? w >= 30 && w <= 300 : w >= 66 && w <= 660;
  }

  String get _heightWarningText {
    if (_isMetric == null) return context.l10n.selectMeasurementUnitsBeforeHeight;
    if (_isMetric == true) return context.l10n.heightBoundaryWarning('100', '250', 'cm');
    return context.l10n.heightBoundaryWarning('3 ft 3 in', '8 ft 2 in', '');
  }

  String get _weightWarningText {
    if (_isMetric == null) return context.l10n.selectMeasurementUnitsBeforeWeight;
    if (_isMetric == true) return context.l10n.weightBoundaryWarning('30', '300', 'kg');
    return context.l10n.weightBoundaryWarning('66', '660', 'lb');
  }

  bool get isCredentialsValid {
    if (_trainerCredentials.isEmpty) return false;
    for (final c in _trainerCredentials) {
      if (c['org'] == null || c['_isEditing'] == true) return false;
      final certs = c['certs'] as List?;
      if (certs == null || certs.isEmpty) return false;
      for (final cert in certs) {
        if (cert['cert'] == null || (cert['certId'] as String?)?.isEmpty == true) return false;
      }
    }
    return true;
  }

  bool get isPlacesValid {
    if (_employmentMode == null) return false;
    if (_employmentMode == 1) return true;
    return _regPlaces.isNotEmpty;
  }

  bool get isTrainerValid {
    if (_isTrainer != true) return true;
    return RegExp(r'^[a-zA-Z0-9]{7,18}$').hasMatch(_idNumberCtrl.text) &&
        _idImageUploaded &&
        _trainerSpecialties.isNotEmpty &&
        isCredentialsValid &&
        isPlacesValid;
  }

  bool get isTraineeValid {
    if (_isTrainer != false) return true;
    return _traineeGoals.isNotEmpty &&
        _selectedTrainingExperienceYears != null &&
        _preferredDiets.isNotEmpty;
  }

  bool get isAllValid {
    final adminInfo  = CountryAdminInfo.resolve(_selectedCountry);
    final needsRegion = adminInfo.regions.isNotEmpty;
    return isUsernameValid &&
        isFNameValid &&
        isLNameValid &&
        isEmailValid &&
        isPassValid &&
        isConfPassValid &&
        isPhoneValid &&
        isHeightValid &&
        isWeightValid &&
        isDobValid &&
        _gender != null &&
        _isTrainer != null &&
        _isMetric != null &&
        _selectedCountry != null &&
        _selectedCountryCode != null &&
        (!needsRegion || _selectedRegion != null) &&
        isTrainerValid &&
        isTraineeValid;
  }

  int? _heightInInches() {
    final parts = _imperialHeightParts();
    if (parts == null || parts.$2 < 0 || parts.$2 > 11) return null;
    return (parts.$1 * 12) + parts.$2;
  }

  (int, int)? _imperialHeightParts() {
    final text = _heightCtrl.text.trim();
    if (text.isEmpty) return null;
    final match = RegExp(r"^(\d+)'\s*(\d*)\x22?$").firstMatch(text);
    if (match == null) return null;
    final feet   = int.tryParse(match.group(1) ?? '');
    final inches = int.tryParse(match.group(2) ?? '') ?? 0;
    if (feet == null) return null;
    return (feet, inches);
  }

  Future<void> _scrollToField(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(ctx,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.15);
  }

  void _convertInputs() {
    if (_heightCtrl.text.isNotEmpty) {
      if (_isMetric == true) {
        final m = RegExp(r"^(\d+)'\s*(\d*)\x22?").firstMatch(_heightCtrl.text);
        if (m != null) {
          final feet   = int.tryParse(m.group(1) ?? '');
          final inches = int.tryParse(m.group(2) ?? '') ?? 0;
          if (feet != null) {
            final cm = ((feet * 12) + inches) * 2.54;
            _heightCtrl.text = cm.toStringAsFixed(2);
          } else {
            _heightCtrl.clear();
          }
        } else {
          _heightCtrl.clear();
        }
      } else {
        final cm = double.tryParse(_heightCtrl.text);
        if (cm != null) {
          final ft  = (cm / 2.54) ~/ 12;
          final inc = ((cm / 2.54) % 12).round();
          _heightCtrl.text = "$ft' $inc\"";
        } else {
          _heightCtrl.clear();
        }
      }
    }
    if (_weightCtrl.text.isNotEmpty) {
      final w = double.tryParse(_weightCtrl.text);
      if (w != null) {
        _weightCtrl.text = _isMetric == true
            ? (w / 2.20462).toStringAsFixed(2)
            : (w * 2.20462).toStringAsFixed(2);
      }
    }
  }

  void _openSpecialtiesSelect() async {
    final cats    = MedicalData.getCategorizedGoals(context);
    final results = await AppMotion.showPremiumDialog<List<String>>(
      context: context,
      builder: (ctx) => GroupedMultiSelectDialog(
        title: context.l10n.specialities,
        categories: cats,
        initialSelections: _trainerSpecialties,
      ),
    );
    if (results != null) setState(() => _trainerSpecialties = results);
  }

  void _openTraineeGoalsSelect() async {
    final cats    = MedicalData.getCategorizedGoals(context);
    final results = await AppMotion.showPremiumDialog<List<String>>(
      context: context,
      builder: (ctx) => GroupedMultiSelectDialog(
        title: context.l10n.trainingGoals,
        categories: cats,
        initialSelections: _traineeGoals,
      ),
    );
    if (results != null) setState(() => _traineeGoals = results);
  }

  void _openPreferredDietSelect() async {
    final results = await AppMotion.showPremiumDialog<List<String>>(
      context: context,
      builder: (ctx) => GroupedMultiSelectDialog(
        title: context.l10n.preferredDiet,
        categories: TraineeDietData.categories,
        initialSelections: _preferredDiets,
        selectionColor: AppTheme.cardGreen,
      ),
    );
    if (results != null) setState(() => _preferredDiets = results);
  }

  static const List<String> _placeTypes = [
    'Gym', 'Fitness Club', 'Studio', 'Outdoor',
    'Pool', 'Rehabilitation Center', 'Sports Complex', 'Other',
  ];

  void _openPlaceSheet({Map<String, dynamic>? existing, int? editIdx}) {
    final nameCtrl         = TextEditingController(text: existing?['name']    ?? '');
    final addrCtrl         = TextEditingController(text: existing?['address'] ?? '');
    String  selType        = existing?['type'] ?? _placeTypes.first;
    String? selCity        = existing?['city'];
    final countrySelection = _selectedCountry;
    final adminInfo        = CountryAdminInfo.resolve(_selectedCountry);
    final hasRegions       = adminInfo.regions.isNotEmpty;

    AppMotion.showPremiumBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setM) {
        bool allOk() =>
            nameCtrl.text.trim().length >= 2 &&
            addrCtrl.text.trim().length >= 5 &&
            (!hasRegions || selCity != null);

        InputDecoration dec(String label, {Widget? suffixIcon}) => InputDecoration(
          labelText: label,
          suffixIcon: suffixIcon,
          labelStyle: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: AppConstants.kDefaultSubtitleFontSize),
          floatingLabelStyle: const TextStyle(
              color: AppTheme.brand,
              fontSize: AppConstants.kDefaultFormTitleFontSize),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
              borderSide: const BorderSide(color: AppTheme.textSecondary, width: 1.5)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
              borderSide: const BorderSide(color: AppTheme.brand, width: 2)),
        );

        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 24, right: 24, top: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                          color: AppTheme.divider,
                          borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 20),
                Text(
                  editIdx != null ? context.l10n.editLocation : context.l10n.addLocation,
                  style: const TextStyle(
                      color: AppTheme.brand, fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(context.l10n.locationType,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: AppConstants.kDefaultSubtitleFontSize)),
                const SizedBox(height: 10),

                // ── Place-type chips: Wrap → 2 natural rows ──────────────
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _placeTypes.map((t) {
                    final sel = t == selType;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setM(() => selType = t);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? AppTheme.brand : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: sel ? AppTheme.brand : AppTheme.divider),
                        ),
                        child: Text(t,
                            style: TextStyle(
                                color: sel ? AppTheme.bg : AppTheme.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
                TextFormField(
                    controller: nameCtrl,
                    onChanged: (_) => setM(() {}),
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: AppConstants.kDefaultSubtitleFontSize),
                    decoration: dec(context.l10n.facilityName)),
                const SizedBox(height: 15),
                TextFormField(
                    initialValue: countrySelection?.textWithoutFlag,
                    readOnly: true,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: AppConstants.kDefaultSubtitleFontSize),
                    decoration: dec(context.l10n.countryOfEmployment,
                            suffixIcon: const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(Icons.public,
                                    color: AppTheme.textSecondary, size: 20)))
                        .copyWith(
                      prefixIcon: countrySelection != null &&
                              countrySelection.flagSvgPath.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(14),
                              child: Container(
                                width: 24,
                                height: 16,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black54, width: 0.5)),
                                child: SvgPicture.asset(
                                    countrySelection.flagSvgPath,
                                    fit: BoxFit.cover),
                              ),
                            )
                          : null,
                    )),
                const SizedBox(height: 15),
                if (hasRegions) ...[
                  DropdownButtonFormField<String>(
                    initialValue: selCity,
                    dropdownColor: AppTheme.surface,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: AppConstants.kDefaultSubtitleFontSize),
                    decoration: dec(adminInfo.label.isNotEmpty
                        ? adminInfo.label
                        : 'Subdivision'),
                    items: adminInfo.regions
                        .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(r,
                                style: const TextStyle(
                                    color: AppTheme.textPrimary))))
                        .toList(),
                    onChanged: (v) => setM(() => selCity = v),
                  ),
                  const SizedBox(height: 15),
                ],
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
                      controller: addrCtrl,
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
                  label: editIdx != null ? 'Save Changes' : 'Add Location',
                  height: AppConstants.kDefaultButtonHeightLarge,
                  onPressed: allOk()
                      ? () {
                          HapticFeedback.selectionClick();
                          final place = {
                            'name': nameCtrl.text.trim(),
                            'address': addrCtrl.text.trim(),
                            'type': selType,
                            'country': _selectedCountry,
                            if (selCity != null) 'city': selCity,
                          };
                          setState(() {
                            if (editIdx != null) {
                              _regPlaces[editIdx] = place;
                            } else {
                              _regPlaces.add(place);
                            }
                          });
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
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _field(
    String label, {
    required String ruleText,
    required bool isValid,
    TextEditingController? controller,
    bool obscure = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    String? suffixText,
    bool readOnly = false,
  }) {
    final merged = <TextInputFormatter>[
      FilteringTextInputFormatter.deny(RegExp(r'\n')),
      if (formatters != null) ...formatters,
    ];
    final Color borderColor =
        readOnly ? Colors.white12 : (isValid ? AppTheme.cardGreen : AppTheme.textSecondary);
    final Color focusedBorderColor = isValid ? AppTheme.cardGreen : AppTheme.brand;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          inputFormatters: merged,
          textInputAction: TextInputAction.next,
          readOnly: readOnly,
          style: TextStyle(
              color: readOnly ? AppTheme.textSecondary : AppTheme.textPrimary,
              fontSize: AppConstants.kDefaultSubtitleFontSize),
          decoration: InputDecoration(
            labelText: label,
            suffixText: suffixText,
            suffixIcon: isValid
                ? const Icon(Icons.check_circle, color: AppTheme.cardGreen, size: 18)
                : null,
            labelStyle: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: AppConstants.kDefaultSubtitleFontSize),
            floatingLabelStyle: WidgetStateTextStyle.resolveWith((s) => TextStyle(
                color: s.contains(WidgetState.focused)
                    ? focusedBorderColor
                    : AppTheme.textPrimary,
                fontSize: AppConstants.kDefaultFormTitleFontSize)),
            suffixStyle: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: AppConstants.kDefaultSubtitleFontSize),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                borderSide: BorderSide(color: borderColor, width: 1.5)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                borderSide: BorderSide(color: focusedBorderColor, width: 2)),
          ),
        ),
        _mandatoryWarning(ruleText, isValid: isValid),
      ]),
    );
  }

  Widget _mandatoryWarning(String message, {bool isValid = false}) =>
      StandardFormWarningBanner(
        message: message,
        isValid: isValid,
        margin: const EdgeInsets.only(top: 8),
      );

  // ── Phone feedback banner ─────────────────────────────────────────────────
  Widget _buildPhoneFeedback(PhoneValidationState state) {
    final result = state.validationResult;
    final l10n = context.l10n;

    String message;
    if (result.isUnsupportedCountry || result.countryIsoCode.isEmpty) {
      message = l10n.phoneDialCodeRequiredWarning;
    } else {
      final country = result.countryDisplayName.isNotEmpty
          ? result.countryDisplayName
          : l10n.phoneUnknownCountry;
      final min = result.expectedMinDigits;
      final max = result.expectedMaxDigits;
      final digitPart = (min != null && max != null)
          ? (min == max
              ? l10n.phoneDigitsExact(min.toString())
              : l10n.phoneDigitsRange(min.toString(), max.toString()))
          : l10n.phoneDigitsRequired;
      final after = result.callingCode.isNotEmpty
          ? l10n.phoneAfterCallingCode(result.callingCode)
          : '';
      final prefixes   = result.allowedPrefixes;
      final prefixPart = prefixes.isEmpty
          ? ''
          : l10n.phonePrefixRequirement(_joinPrefixes(prefixes, l10n.listOr));
      final actual = result.normalizedDigits.length;
      final target = (min != null && max != null)
          ? (min == max ? '$max' : '$min-$max')
          : '?';
      final currentDigits =
          l10n.phoneCurrentDigits(actual.toString(), target);
      message = l10n.phoneMobileValidationWarning(
        country,
        digitPart,
        after,
        prefixPart,
        currentDigits,
      );
    }

    return StandardFormWarningBanner(
      message: message,
      isValid: result.isValid,
      margin: const EdgeInsets.only(top: 8),
    );
  }

  bool get _hasRegistrationProgress {
    final ctrls = [
      _usernameCtrl, _fNameCtrl, _lNameCtrl, _emailCtrl, _passCtrl,
      _confPassCtrl, _phoneCtrl, _heightCtrl, _weightCtrl, _idNumberCtrl,
    ];
    if (ctrls.any((c) => c.text.trim().isNotEmpty)) return true;
    return _isTrainer != null ||
        _isMetric != null ||
        _idImageUploaded ||
        _trainerSpecialties.isNotEmpty ||
        _traineeGoals.isNotEmpty ||
        _selectedTrainingExperienceYears != null ||
        _preferredDiets.isNotEmpty ||
        _trainerCredentials.isNotEmpty ||
        _regPlaces.isNotEmpty ||
        _employmentMode != null ||
        _selectedCountry != null ||
        _selectedCountryCode != null ||
        _selectedRegion != null ||
        _dob != null ||
        _gender != null;
  }

  Future<bool> _confirmCancelRegistration() async {
    if (!_hasRegistrationProgress) return true;
    final shouldDiscard = await AppMotion.showPremiumDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        titlePadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(context.l10n.cancelRegistrationTitle,
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
            ),
            const Divider(color: AppTheme.divider, height: 1),
          ],
        ),
        content: Text(context.l10n.cancelRegistrationMessage,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: AppConstants.kDefaultSubtitleFontSize,
                height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.discardProgress,
                style: const TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.keepEditing,
                style: const TextStyle(
                    color: AppTheme.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return shouldDiscard ?? false;
  }

  Future<void> _handleCancelRegistration() async {
    final ok = await _confirmCancelRegistration();
    if (!mounted || !ok) return;
    Navigator.pop(context);
  }

  Widget _employmentRadio({
    required int mode,
    required int? selected,
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
          color: isSelected ? AppTheme.brand.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(
              color: isSelected ? AppTheme.brand : AppTheme.divider,
              width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20, height: 20,
              margin: const EdgeInsets.only(top: 2, right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: isSelected ? AppTheme.brand : AppTheme.textSecondary,
                    width: isSelected ? 6 : 2),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          fontSize: AppConstants.kDefaultSubtitleFontSize)),
                  const SizedBox(height: 4),
                  Text(description,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedSelectionField({
    required String label,
    required List<String> selectedItems,
    required String emptyText,
    required VoidCallback onTap,
    Color chipColor = AppTheme.brand,
    String? warningText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: AppConstants.kDefaultSubtitleFontSize,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            constraints: const BoxConstraints(minHeight: 60),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                border: Border.all(color: AppTheme.textSecondary, width: 1.5)),
            child: Row(children: [
              Expanded(
                  child: selectedItems.isEmpty
                      ? Text(emptyText,
                          style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: AppConstants.kDefaultSubtitleFontSize))
                      : Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: selectedItems
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
        if (selectedItems.isEmpty && warningText != null)
          _mandatoryWarning(warningText)
        else if (selectedItems.isNotEmpty)
          _mandatoryWarning(context.l10n.selectionLooksGood, isValid: true),
      ]),
    );
  }

  // ── Phone prefix widget ───────────────────────────────────────────────────
  Widget _buildPhonePrefix(PhoneValidationBloc bloc) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(width: 15),
      DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCountryCode,
          dropdownColor: AppTheme.surface,
          isExpanded: false,
          isDense: true,
          itemHeight: null,
          hint: const Text('Code',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
          selectedItemBuilder: (_) => _sortedCodes.map((c) {
            final parts    = c.split(' ');
            final svgPath  = parts[0];
            final dialCode = parts.length > 1 ? parts[1] : '';
            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 80),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                SvgPicture.asset(svgPath, width: 22, height: 15, fit: BoxFit.cover),
                const SizedBox(width: 5),
                Text(dialCode,
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontSize: 13)),
              ]),
            );
          }).toList(),
          items: _sortedCodes.map((c) {
            final parts    = c.split(' ');
            final svgPath  = parts[0];
            final dialCode = parts.length > 1 ? parts[1] : '';
            return DropdownMenuItem(
              value: c,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                SvgPicture.asset(svgPath, width: 24, height: 16, fit: BoxFit.cover),
                const SizedBox(width: 10),
                Text(dialCode,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: AppConstants.kDefaultSubtitleFontSize)),
              ]),
            );
          }).toList(),
          onChanged: (v) {
            if (v == null) return;
            setState(() => _selectedCountryCode = v);
            bloc.add(CountrySelected('', dialCodeSelection: v));
          },
        ),
      ),
      const SizedBox(width: 10),
      Container(width: 1, height: 24, color: AppTheme.divider),
      const SizedBox(width: 15),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PhoneValidationBloc()
        ..add(CountrySelected('', dialCodeSelection: _selectedCountryCode)),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          _handleCancelRegistration();
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: AppTheme.bg,
            appBar: AppBar(
                elevation: 0,
                iconTheme: const IconThemeData(color: AppTheme.textPrimary),
                title: Text(context.l10n.register,
                    style: const TextStyle(color: AppTheme.brand))),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Role toggle ───────────────────────────────────────────
                  Center(
                      child: DualToggleSwitch(
                          leftLabel: context.l10n.trainee,
                          rightLabel: context.l10n.trainer,
                          isLeftSelected: _isTrainer != true,
                          selectionMade: _isTrainer != null,
                          onSelected: (isLeft) =>
                              setState(() => _isTrainer = !isLeft))),
                  if (_isTrainer == null)
                    _mandatoryWarning(context.l10n.registrationRoleRequired)
                  else
                    _mandatoryWarning(context.l10n.selectionLooksGood, isValid: true),
                  const SizedBox(height: 30),

                  // ── Account info ──────────────────────────────────────────
                  Text(context.l10n.accountInfo,
                      style: const TextStyle(
                          color: AppTheme.brand,
                          fontSize: AppConstants.kDefaultTitleFontSize,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  _field(context.l10n.username,
                      ruleText: context.l10n.invalidUsernameError,
                      isValid: isUsernameValid,
                      controller: _usernameCtrl,
                      formatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]'))
                      ]),
                  _field(context.l10n.idOrEmail,
                      ruleText: context.l10n.invalidEmailError,
                      isValid: isEmailValid,
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress),
                  _field(context.l10n.password,
                      ruleText: context.l10n.invalidPasswordError,
                      isValid: isPassValid,
                      controller: _passCtrl,
                      obscure: true),
                  _field(context.l10n.confirmPassword,
                      ruleText: context.l10n.passwordMismatchError,
                      isValid: isConfPassValid,
                      controller: _confPassCtrl,
                      obscure: true),

                  const SizedBox(height: 10),

                  // ── Personal info ─────────────────────────────────────────
                  Text(context.l10n.personalInfo,
                      style: const TextStyle(
                          color: AppTheme.brand,
                          fontSize: AppConstants.kDefaultTitleFontSize,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  _field(context.l10n.firstName,
                      ruleText: context.l10n.invalidNameError,
                      isValid: isFNameValid,
                      controller: _fNameCtrl,
                      formatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[\p{L}\s\-]', unicode: true))
                      ]),
                  _field(context.l10n.lastName,
                      ruleText: context.l10n.invalidNameError,
                      isValid: isLNameValid,
                      controller: _lNameCtrl,
                      formatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[\p{L}\s\-]', unicode: true))
                      ]),

                  // ── Country dropdown ──────────────────────────────────────
                  Padding(
                    key: _countryFieldKey,
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Builder(builder: (context) {
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: _isTrainer == true
                                    ? context.l10n.countryOfEmployment
                                    : _isTrainer == false
                                        ? context.l10n.countryOfResidence
                                        : 'Country',
                                labelStyle: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: AppConstants.kDefaultSubtitleFontSize),
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
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 18),
                              ),
                              dropdownColor: AppTheme.surface,
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: AppTheme.textSecondary),
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: AppConstants.kDefaultSubtitleFontSize),
                              initialValue: _selectedCountry,
                              isExpanded: true,
                              isDense: true,
                              itemHeight: null,
                              selectedItemBuilder: (_) => AppConstants.kCountriesOnly
                                  .map((c) => CountryFlagWidget(textData: c))
                                  .toList(),
                              items: AppConstants.kCountriesOnly
                                  .map((c) => DropdownMenuItem(
                                      value: c,
                                      child: CountryFlagWidget(textData: c)))
                                  .toList(),
                              onChanged: (v) {
                                setState(() {
                                  _selectedCountry = v;
                                  _selectedRegion  = null;
                                });
                              },
                            ),
                            if (_selectedCountry == null)
                              _mandatoryWarning(_isTrainer == true
                                  ? context.l10n.selectCountryEmployment
                                  : _isTrainer == false
                                      ? context.l10n.selectCountryResidence
                                      : context.l10n.selectCountry)
                            else
                              _mandatoryWarning(context.l10n.selectionLooksGood,
                                  isValid: true),
                          ]);
                    }),
                  ),

                  // ── Subdivision picker ────────────────────────────────────
                  Builder(builder: (context) {
                    final adminInfo  = CountryAdminInfo.resolve(_selectedCountry);
                    final bool hasCountry = _selectedCountry != null;
                    final bool hasRegions = adminInfo.regions.isNotEmpty;
                    final String subdivLabel =
                        hasCountry && hasRegions ? adminInfo.label : 'Subdivision';
                    return Padding(
                      key: _subdivisionFieldKey,
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IgnorePointer(
                              ignoring: !hasCountry || !hasRegions,
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: subdivLabel,
                                  labelStyle: TextStyle(
                                      color: hasCountry
                                          ? AppTheme.textPrimary
                                          : AppTheme.textSecondary,
                                      fontSize: AppConstants.kDefaultSubtitleFontSize),
                                  floatingLabelStyle: const TextStyle(
                                      color: AppTheme.brand,
                                      fontSize: AppConstants.kDefaultFormTitleFontSize),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppConstants.kDefaultBorderRadius),
                                      borderSide: BorderSide(
                                          color: hasCountry
                                              ? AppTheme.textSecondary
                                              : Colors.white12,
                                          width: 1.5)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppConstants.kDefaultBorderRadius),
                                      borderSide: const BorderSide(
                                          color: AppTheme.brand, width: 2)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 18),
                                ),
                                dropdownColor: AppTheme.surface,
                                icon: Icon(Icons.arrow_drop_down,
                                    color: hasCountry
                                        ? AppTheme.textSecondary
                                        : Colors.white24),
                                style: TextStyle(
                                    color: hasCountry
                                        ? AppTheme.textPrimary
                                        : AppTheme.textSecondary,
                                    fontSize: AppConstants.kDefaultSubtitleFontSize),
                                initialValue: hasRegions ? _selectedRegion : null,
                                hint: Text(
                                  !hasCountry
                                      ? 'Select country first'
                                      : (!hasRegions
                                          ? 'N/A for selected country'
                                          : 'Select ${adminInfo.label}'),
                                  style: TextStyle(
                                      color: hasCountry
                                          ? AppTheme.textSecondary
                                          : Colors.white38,
                                      fontSize: AppConstants.kDefaultSubtitleFontSize),
                                ),
                                isExpanded: true,
                                isDense: true,
                                itemHeight: null,
                                items: hasRegions
                                    ? adminInfo.regions
                                        .map((r) =>
                                            DropdownMenuItem(value: r, child: Text(r)))
                                        .toList()
                                    : [],
                                onChanged: hasCountry && hasRegions
                                    ? (v) => setState(() => _selectedRegion = v)
                                    : null,
                              ),
                            ),
                            if (hasCountry && hasRegions && _selectedRegion == null)
                              _mandatoryWarning(context.l10n
                                  .pleaseSelectField(adminInfo.label.toLowerCase()))
                            else if (hasCountry && hasRegions)
                              _mandatoryWarning(context.l10n.selectionLooksGood,
                                  isValid: true),
                          ]),
                    );
                  }),

                  // ── Phone field ───────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Builder(builder: (context) {
                      final bloc = context.read<PhoneValidationBloc>();
                      return BlocBuilder<PhoneValidationBloc, PhoneValidationState>(
                        builder: (context, state) {
                          final phoneValid = state.validationResult.isValid;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _phoneCtrl,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(
                                      state.maxRegistrationDigits),
                                ],
                                onChanged: (v) => bloc.add(PhoneNumberChanged(v)),
                                style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: AppConstants.kDefaultSubtitleFontSize),
                                decoration: InputDecoration(
                                  labelText: context.l10n.phoneNumber,
                                  labelStyle: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: AppConstants.kDefaultSubtitleFontSize),
                                  floatingLabelStyle: WidgetStateTextStyle.resolveWith(
                                      (s) => TextStyle(
                                          color: s.contains(WidgetState.focused)
                                              ? AppTheme.brand
                                              : AppTheme.textPrimary,
                                          fontSize:
                                              AppConstants.kDefaultFormTitleFontSize)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 18),
                                  prefixIcon: _buildPhonePrefix(bloc),
                                  suffixIcon: phoneValid
                                      ? const Icon(Icons.check_circle,
                                          color: AppTheme.cardGreen, size: 18)
                                      : null,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppConstants.kDefaultBorderRadius),
                                    borderSide: BorderSide(
                                        color: phoneValid
                                            ? AppTheme.cardGreen
                                            : AppTheme.error,
                                        width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppConstants.kDefaultBorderRadius),
                                    borderSide: BorderSide(
                                        color: phoneValid
                                            ? AppTheme.cardGreen
                                            : AppTheme.error,
                                        width: 2),
                                  ),
                                ),
                              ),
                              _buildPhoneFeedback(state),
                            ],
                          );
                        },
                      );
                    }),
                  ),

                  // ── Date of Birth ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.l10n.dateOfBirth,
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: AppConstants.kDefaultSubtitleFontSize)),
                          const SizedBox(height: 10),
                          DobDropdownWidget(
                              initialDate: _dob,
                              onChanged: (v) => setState(() => _dob = v)),
                          if (_dob == null)
                            _mandatoryWarning(context.l10n.dateOfBirthRequired)
                          else if (!isDobValid)
                            _mandatoryWarning(
                                context.l10n.minimumAgeRegistrationWarning)
                          else
                            _mandatoryWarning(context.l10n.dateOfBirthSelected,
                                isValid: true),
                        ]),
                  ),

                  // ── Gender ────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.l10n.gender,
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: AppConstants.kDefaultSubtitleFontSize)),
                          const SizedBox(height: 10),
                          GenderToggleSwitch(
                              selectedGender: _gender ?? '',
                              onSelected: (v) => setState(() => _gender = v)),
                          if (_gender == null)
                            _mandatoryWarning(context.l10n.genderSelectionError)
                          else
                            _mandatoryWarning(context.l10n.genderSelected,
                                isValid: true),
                        ]),
                  ),

                  // ── Height ────────────────────────────────────────────────
                  _field(
                    context.l10n.height,
                    isValid: isHeightValid,
                    controller: _heightCtrl,
                    ruleText: _heightWarningText,
                    readOnly: _isMetric == null,
                    suffixText: _isMetric == true
                        ? ' cm'
                        : _isMetric == false
                            ? ''
                            : null,
                    keyboardType: _isMetric == true
                        ? const TextInputType.numberWithOptions(decimal: true)
                        : TextInputType.text,
                    formatters: _isMetric == true
                        ? [
                            NumberBoundsFormatter(
                                maxWholeDigits: 3,
                                maxDecimalDigits: 2,
                                maxVal: 250.0)
                          ]
                        : [ImperialHeightFormatter()],
                  ),

                  // ── Weight ────────────────────────────────────────────────
                  _field(
                    context.l10n.weight,
                    isValid: isWeightValid,
                    controller: _weightCtrl,
                    ruleText: _weightWarningText,
                    readOnly: _isMetric == null,
                    suffixText: _isMetric == true
                        ? ' kg'
                        : _isMetric == false
                            ? ' lbs'
                            : null,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    formatters: [
                      NumberBoundsFormatter(
                          maxWholeDigits: 3,
                          maxDecimalDigits: 2,
                          maxVal: _isMetric == true ? 300.0 : 660.0)
                    ],
                  ),

                  // ── Metric / Imperial toggle ──────────────────────────────
                  Center(
                      child: DualToggleSwitch(
                          leftLabel: context.l10n.metric,
                          rightLabel: context.l10n.imperial,
                          isLeftSelected: _isMetric == true,
                          selectionMade: _isMetric != null,
                          onSelected: (isLeft) {
                            if (_isMetric == isLeft) return;
                            setState(() {
                              _isMetric = isLeft;
                              _convertInputs();
                            });
                          })),
                  if (_isMetric == null)
                    _mandatoryWarning(context.l10n.measurementUnitsRequired)
                  else
                    _mandatoryWarning(context.l10n.measurementUnitsSelected,
                        isValid: true),
                  const SizedBox(height: 30),

                  // ══════════════════════════════════════════════════════════
                  // TRAINEE SECTION
                  // ══════════════════════════════════════════════════════════
                  if (_isTrainer == false) ...[
                    const Divider(color: AppTheme.divider),
                    const SizedBox(height: 24),
                    Text(context.l10n.traineeProfile,
                        style: const TextStyle(
                            color: AppTheme.brand,
                            fontSize: AppConstants.kDefaultTitleFontSize,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(context.l10n.traineeProfileRegistrationIntro,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12, height: 1.5)),
                    const SizedBox(height: 16),
                    _buildGroupedSelectionField(
                      label: context.l10n.trainingGoals,
                      selectedItems: _traineeGoals,
                      emptyText: context.l10n.chooseTrainingGoals,
                      onTap: _openTraineeGoalsSelect,
                      warningText: context.l10n.trainingGoalRequired,
                    ),
                    // ── Training Experience ───────────────────────────────
                    _TrainingExperienceSelector(
                      selectedYears: _selectedTrainingExperienceYears,
                      onSelected: (years) =>
                          setState(() => _selectedTrainingExperienceYears = years),
                      showRequiredWarning: _selectedTrainingExperienceYears == null,
                    ),
                    _buildGroupedSelectionField(
                      label: context.l10n.preferredDiet,
                      selectedItems: _preferredDiets,
                      emptyText: context.l10n.choosePreferredDiets,
                      onTap: _openPreferredDietSelect,
                      chipColor: AppTheme.cardGreen,
                      warningText: context.l10n.preferredDietRequired,
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: AppTheme.divider),
                    const SizedBox(height: 20),
                  ],

                  // ══════════════════════════════════════════════════════════
                  // TRAINER SECTION
                  // ══════════════════════════════════════════════════════════
                  if (_isTrainer == true) ...[
                    const SizedBox(height: 10),
                    Text(context.l10n.professionalInfo,
                        style: const TextStyle(
                            color: AppTheme.brand,
                            fontSize: AppConstants.kDefaultTitleFontSize,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    // ID Number ─────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _idNumberCtrl,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z0-9]')),
                                LengthLimitingTextInputFormatter(18),
                              ],
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: AppConstants.kDefaultSubtitleFontSize),
                              decoration: InputDecoration(
                                labelText: context.l10n.identificationNumber,
                                labelStyle: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: AppConstants.kDefaultSubtitleFontSize),
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
                                    borderSide: const BorderSide(
                                        color: AppTheme.brand, width: 2)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 15),
                              ),
                            ),
                            if (!RegExp(r'^[a-zA-Z0-9]{7,18}$')
                                .hasMatch(_idNumberCtrl.text))
                              _mandatoryWarning(context.l10n.invalidIdNumberError),
                          ]),
                    ),

                    // ID Image Upload ────────────────────────────────────────
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        AppMotion.showPremiumBottomSheet(
                          context: context,
                          backgroundColor: AppTheme.surface,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24))),
                          builder: (ctx) => Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Center(
                                      child: Container(
                                          width: 40, height: 4,
                                          decoration: BoxDecoration(
                                              color: AppTheme.divider,
                                              borderRadius:
                                                  BorderRadius.circular(10)))),
                                  const SizedBox(height: 25),
                                  Text(context.l10n.uploadId,
                                      style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center),
                                  const SizedBox(height: 25),
                                  SolidConfirmButton(
                                      label: context.l10n.scanViaCamera,
                                      icon: CupertinoIcons.camera,
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        final messenger =
                                            ScaffoldMessenger.of(context);
                                        final msg =
                                            context.l10n.idUploadedSuccessfully;
                                        Navigator.push(
                                                context,
                                                AppRoutes.noTransitionRoute(
                                                    const CustomCameraScreen(
                                                        isIdScan: true)))
                                            .then((v) {
                                          if (!mounted) return;
                                          if (v == true) {
                                            setState(
                                                () => _idImageUploaded = true);
                                            messenger.showSnackBar(
                                                SnackBar(content: Text(msg)));
                                          }
                                        });
                                      }),
                                  const SizedBox(height: 15),
                                  OutlineActionButton(
                                      label: context.l10n.uploadFromDevice,
                                      icon: const Icon(CupertinoIcons.photo,
                                          color: AppTheme.brand, size: 20),
                                      onPressed: () async {
                                        Navigator.pop(ctx);
                                        final f = await ImagePicker().pickImage(
                                            source: ImageSource.gallery);
                                        if (f != null) {
                                          setState(() => _idImageUploaded = true);
                                        }
                                      }),
                                  const SizedBox(height: 30),
                                ]),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 30),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: _idImageUploaded
                                  ? AppTheme.brand
                                  : AppTheme.textSecondary,
                              width: 1.5),
                          borderRadius: BorderRadius.circular(
                              AppConstants.kDefaultBorderRadius),
                          color: Colors.transparent,
                        ),
                        child: Column(children: [
                          Icon(
                              _idImageUploaded
                                  ? CupertinoIcons.check_mark_circled_solid
                                  : CupertinoIcons.cloud_upload,
                              color: _idImageUploaded
                                  ? AppTheme.brand
                                  : AppTheme.textSecondary,
                              size: 30),
                          const SizedBox(height: 10),
                          Text(
                              _idImageUploaded
                                  ? context.l10n.idUploadedSuccessfully
                                  : context.l10n.uploadIdDocument,
                              style: TextStyle(
                                  color: _idImageUploaded
                                      ? AppTheme.brand
                                      : AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          const SizedBox(height: 6),
                          Text(context.l10n.idScanInstructions,
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 12),
                              textAlign: TextAlign.center),
                        ]),
                      ),
                    ),
                    if (!_idImageUploaded)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child:
                            _mandatoryWarning(context.l10n.idDocumentRequiredWarning),
                      ),

                    // Specialties ────────────────────────────────────────────
                    Text(context.l10n.specialities,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: AppConstants.kDefaultSubtitleFontSize,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _openSpecialtiesSelect,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        constraints: const BoxConstraints(minHeight: 60),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                AppConstants.kDefaultBorderRadius),
                            border: Border.all(
                                color: AppTheme.textSecondary, width: 1.5)),
                        child: Row(children: [
                          Expanded(
                              child: _trainerSpecialties.isEmpty
                                  ? Text(context.l10n.addSpecialities,
                                      style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize:
                                              AppConstants.kDefaultSubtitleFontSize))
                                   : Wrap(
                                       spacing: 6,
                                       runSpacing: 6,
                                       children: _trainerSpecialties
                                           .map((s) => PremiumSelectionButton(
                                                 label: s,
                                                 color: AppTheme.brand,
                                                 selected: true,
                                                 padding:
                                                     const EdgeInsets.symmetric(
                                                         horizontal: 18,
                                                         vertical: 8),
                                                 minHeight: 34,
                                                 fontSize: 13,
                                               ))
                                           .toList())),
                          const Icon(Icons.arrow_drop_down,
                              color: AppTheme.textSecondary),
                        ]),
                      ),
                    ),
                    if (_trainerSpecialties.isEmpty)
                      Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child:
                              _mandatoryWarning(context.l10n.specialityRequired)),
                    if (_trainerSpecialties.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _mandatoryWarning(context.l10n.selectionLooksGood,
                            isValid: true),
                      ),

                    // ── CREDENTIALS SECTION ──────────────────────────────────
                    const SizedBox(height: 8),
                    _CredentialsSectionHeader(
                      title: context.l10n.credentials,
                      subtitle: context.l10n.credentialExplanation,
                    ),
                    const SizedBox(height: 20),

                    ..._trainerCredentials.asMap().entries.map((e) {
                      final idx = e.key;
                      return RegistrationCredentialCard(
                        credential: e.value,
                        allCredentials: _trainerCredentials,
                        onSave: (d) =>
                            setState(() => _trainerCredentials[idx] = d),
                        onEdit: () => setState(() =>
                            _trainerCredentials[idx]['_isEditing'] = true),
                        onRemove: () {
                          HapticFeedback.lightImpact();
                          AppMotion.showPremiumDialog<void>(
                              context: context,
                              builder: (_) => AlertDialog(
                                    backgroundColor: AppTheme.surface,
                                    titlePadding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.kDefaultBorderRadius)),
                                    title: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: Text(context.l10n.remove,
                                                  style: const TextStyle(
                                                      color: AppTheme.error,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: AppConstants
                                                          .kDefaultTitleFontSize))),
                                          const Divider(
                                              color: AppTheme.divider, height: 1),
                                        ]),
                                    content: Text(
                                        context
                                            .l10n.removeCredentialConfirmation,
                                        style: const TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontSize: AppConstants
                                                .kDefaultSubtitleFontSize,
                                            height: 1.5)),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(context.l10n.cancel,
                                              style: const TextStyle(
                                                  color: AppTheme.textSecondary,
                                                  fontWeight: FontWeight.bold))),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            setState(() =>
                                                _trainerCredentials.removeAt(idx));
                                          },
                                          child: Text(context.l10n.remove,
                                              style: const TextStyle(
                                                  color: AppTheme.error,
                                                  fontWeight: FontWeight.bold))),
                                    ],
                                  ));
                        },
                        onCancel: () => setState(() {
                          if (_trainerCredentials[idx]['org'] == null) {
                            _trainerCredentials.removeAt(idx);
                          } else {
                            _trainerCredentials[idx]['_isEditing'] = false;
                          }
                        }),
                      );
                    }),

                    // Add credential button
                    _AddCredentialButton(
                      label: context.l10n.addCredential,
                      onTap: () => setState(() => _trainerCredentials.add({
                            'org': null,
                            'cert': null,
                            'certId': '',
                            '_isEditing': true,
                          })),
                    ),
                    const SizedBox(height: 12),
                    if (_trainerCredentials.isEmpty)
                      _mandatoryWarning(context.l10n.credentialRequired)
                    else if (!isCredentialsValid)
                      _mandatoryWarning(context.l10n.saveAllCredentials)
                    else
                      _mandatoryWarning(context.l10n.selectionLooksGood,
                          isValid: true),

                    // ── PLACES OF EMPLOYMENT ─────────────────────────────────
                    // NOTE: The divider that was previously here has been removed
                    // per spec. Section begins directly after credential validation.
                    const SizedBox(height: 30),
                    Text(context.l10n.placesOfEmployment,
                        style: const TextStyle(
                            color: AppTheme.brand,
                            fontSize: AppConstants.kDefaultTitleFontSize,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text(
                        'Select how you deliver your personal training services.',
                        style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            height: 1.5)),
                    const SizedBox(height: 16),

                    _employmentRadio(
                      mode: 0,
                      selected: _employmentMode,
                      title: context.l10n.hybridTraining,
                      description: context.l10n.hybridTrainingDesc,
                      onTap: () => setState(() => _employmentMode = 0),
                    ),
                    const SizedBox(height: 10),
                    _employmentRadio(
                      mode: 1,
                      selected: _employmentMode,
                      title: context.l10n.onlineOnlyTraining,
                      description: context.l10n.onlineOnlyTrainingDesc,
                      onTap: () => setState(() {
                        _employmentMode = 1;
                        _regPlaces.clear();
                      }),
                    ),
                    const SizedBox(height: 10),
                    _employmentRadio(
                      mode: 2,
                      selected: _employmentMode,
                      title: context.l10n.inPersonOnlyTraining,
                      description: context.l10n.inPersonOnlyTrainingDesc,
                      onTap: () => setState(() => _employmentMode = 2),
                    ),
                    const SizedBox(height: 16),
                    if (_employmentMode == null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _mandatoryWarning(
                            'Please select how you deliver your training services.'),
                      ),

                    if (_employmentMode == 0 || _employmentMode == 2) ...[
                      if (_regPlaces.isEmpty)
                        Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child:
                                _mandatoryWarning(context.l10n.locationRequired)),
                      ..._regPlaces.asMap().entries.map((e) {
                        final idx = e.key;
                        final p   = e.value;
                        return _RegPlaceCard(
                          place: p,
                          onEdit: () =>
                              _openPlaceSheet(existing: p, editIdx: idx),
                          onRemove: () {
                            HapticFeedback.lightImpact();
                            AppMotion.showPremiumDialog<void>(
                                context: context,
                                builder: (_) => AlertDialog(
                                      backgroundColor: AppTheme.surface,
                                      titlePadding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              AppConstants.kDefaultBorderRadius)),
                                      title: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                child: Text(context.l10n.remove,
                                                    style: const TextStyle(
                                                        color: AppTheme.error,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: AppConstants
                                                            .kDefaultTitleFontSize))),
                                            const Divider(
                                                color: AppTheme.divider,
                                                height: 1),
                                          ]),
                                      content: const Text(
                                          'Are you sure you want to remove this location?',
                                          style: TextStyle(
                                              color: AppTheme.textPrimary,
                                              fontSize: AppConstants
                                                  .kDefaultSubtitleFontSize,
                                              height: 1.5)),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text(context.l10n.cancel,
                                                style: const TextStyle(
                                                    color:
                                                        AppTheme.textSecondary,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              setState(() =>
                                                  _regPlaces.removeAt(idx));
                                            },
                                            child: Text(context.l10n.remove,
                                                style: const TextStyle(
                                                    color: AppTheme.error,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                      ],
                                    ));
                          },
                        );
                      }),
                      const SizedBox(height: 8),
                      OutlineActionButton(
                          label: context.l10n.addLocation,
                          icon: const Icon(Icons.add_location_alt_outlined,
                              color: AppTheme.brand),
                          height: 50,
                          onPressed: () async {
                            HapticFeedback.lightImpact();
                            if (_selectedCountry == null) {
                              await _scrollToField(_countryFieldKey);
                              return;
                            }
                            final adminInfo =
                                CountryAdminInfo.resolve(_selectedCountry);
                            if (adminInfo.regions.isNotEmpty &&
                                _selectedRegion == null) {
                              await _scrollToField(_subdivisionFieldKey);
                              return;
                            }
                            _openPlaceSheet();
                          }),
                    ],

                    const SizedBox(height: 30),
                    const Divider(color: AppTheme.divider),
                    const SizedBox(height: 30),
                  ],

                  // ── Register button ───────────────────────────────────────
                  BlocBuilder<PhoneValidationBloc, PhoneValidationState>(
                    builder: (context, phoneState) {
                      return SolidConfirmButton(
                        label: context.l10n.registerAction,
                        height: AppConstants.kDefaultButtonHeightLarge,
                        onPressed: () {
                          if (!isAllValid || !phoneState.isValid) {
                            HapticFeedback.lightImpact();
                            return;
                          }
                          final useMetric = _isMetric;
                          final isTrainer = _isTrainer;
                          if (useMetric == null || isTrainer == null) {
                            HapticFeedback.lightImpact();
                            return;
                          }
                          appState.setMeasurementUnit(
                              useMetric ? 'metric' : 'imperial');
                          appState.setWeightUnit(
                              useMetric ? 'metric' : 'imperial');
                          if (isTrainer) {
                            if (_employmentMode == 1) {
                              appState.isOnlineOnly = true;
                              appState.placesOfEmployment.clear();
                            } else {
                              appState.isOnlineOnly = false;
                              appState.placesOfEmployment
                                ..clear()
                                ..addAll(_regPlaces);
                            }
                          } else {
                            final expYears = _selectedTrainingExperienceYears;
                            if (expYears == null) return;
                            appState.saveTraineePreferences(
                              goals: _traineeGoals,
                              trainingExperienceYears: expYears,
                              preferredDiets: _preferredDiets,
                            );
                          }
                          Navigator.pop(context);
                          AppUtils.showToast(
                              context, context.l10n.accountCreatedSuccess);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// CREDENTIALS SECTION HEADER  (premium dark aesthetic)
// =============================================================================
class _CredentialsSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _CredentialsSectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLow,
        borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
        border: Border.all(color: AppTheme.outlineSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.brand.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.brand.withValues(alpha: 0.18)),
            ),
            child: const Icon(Icons.workspace_premium_rounded,
                color: AppTheme.brand, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.brand,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    height: 1.5,
                  ),
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
// ADD CREDENTIAL BUTTON  (premium dashed-style call-to-action)
// =============================================================================
class _AddCredentialButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AddCredentialButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TnTPressable(
      onTap: onTap,
      haptic: TnTHaptic.selection,
      borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppTheme.brand.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          border: Border.all(
            color: AppTheme.brand.withValues(alpha: 0.35),
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppTheme.brand.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppTheme.brand.withValues(alpha: 0.4), width: 1),
              ),
              child: const Icon(Icons.add, color: AppTheme.brand, size: 14),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.brand,
                fontSize: AppConstants.kDefaultButtonTextSizeMedium,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// TRAINING EXPERIENCE SELECTOR  (refactored premium grid)
// =============================================================================
class _ExpOption {
  final int    years;
  final Color  color;
  const _ExpOption({required this.years, required this.color});
}

class _TrainingExperienceSelector extends StatelessWidget {
  final int?           selectedYears;
  final ValueChanged<int> onSelected;
  final bool           showRequiredWarning;

  const _TrainingExperienceSelector({
    required this.selectedYears,
    required this.onSelected,
    required this.showRequiredWarning,
  });

  static const List<_ExpOption> _options = [
    _ExpOption(years: 0, color: AppTheme.textSecondary),
    _ExpOption(years: 1, color: AppTheme.cardBlue),
    _ExpOption(years: 3, color: AppTheme.cardGreen),
    _ExpOption(years: 6, color: AppTheme.cardYellow),
    _ExpOption(years: 10, color: AppTheme.cardPurple),
  ];

  String _labelFor(BuildContext context, int years) {
    return TraineeTrainingExperienceData.optionFor(years)
        .localizedLabel(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.physicalTrainingExperience,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: AppConstants.kDefaultSubtitleFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TnTPressable(
                onTap: () {
                  HapticFeedback.lightImpact();
                  TraineeTrainingExperienceData.showHelpDialog(context);
                },
                haptic: TnTHaptic.light,
                pressedScale: 0.9,
                borderRadius: BorderRadius.circular(99),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppTheme.brand.withValues(alpha: 0.07),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppTheme.brand.withValues(alpha: 0.22), width: 1),
                  ),
                  child: const Icon(Icons.help_outline_rounded,
                      color: AppTheme.brand, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Option grid ─────────────────────────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 8) / 2;
              final selectedOption = selectedYears == null
                  ? null
                  : TraineeTrainingExperienceData.optionFor(selectedYears!);

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _options.map((opt) {
                  final selected = opt.years == selectedOption?.years;
                  final label = _labelFor(context, opt.years);

                  return TnTPressable(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onSelected(opt.years);
                    },
                    haptic: TnTHaptic.none,
                    borderRadius: BorderRadius.circular(
                        AppConstants.kDefaultBorderRadius),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      width: itemWidth,
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: selected
                            ? opt.color.withValues(alpha: 0.11)
                            : AppTheme.surfaceLow,
                        borderRadius: BorderRadius.circular(
                            AppConstants.kDefaultBorderRadius),
                        border: Border.all(
                          color: selected
                              ? opt.color.withValues(alpha: 0.65)
                              : AppTheme.outlineSoft,
                          width: selected ? 1.6 : 1.0,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: opt.color.withValues(alpha: 0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          // Dot indicator
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: selected ? 10 : 8,
                            height: selected ? 10 : 8,
                            decoration: BoxDecoration(
                              color: selected
                                  ? opt.color
                                  : opt.color.withValues(alpha: 0.45),
                              shape: BoxShape.circle,
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: opt.color.withValues(alpha: 0.4),
                                        blurRadius: 6,
                                      )
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Label
                          Expanded(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: selected
                                    ? opt.color
                                    : AppTheme.textSecondary,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 13,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                          // Check icon (animated in/out)
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 160),
                            child: selected
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    key: const ValueKey('check'),
                                    color: opt.color,
                                    size: 16,
                                  )
                                : const SizedBox.shrink(
                                    key: ValueKey('no-check')),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 10),

          // ── Validation banner ────────────────────────────────────────────
          StandardFormWarningBanner(
            message: showRequiredWarning
                ? context.l10n.trainingExperienceRequired
                : context.l10n.selectionLooksGood,
            isValid: !showRequiredWarning,
            margin: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// REGISTRATION PLACE CARD
// =============================================================================
class _RegPlaceCard extends StatelessWidget {
  final Map<String, dynamic> place;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  const _RegPlaceCard(
      {required this.place, required this.onEdit, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color    iconColor;
    switch ((place['type'] as String? ?? '').toLowerCase()) {
      case 'gym':
        icon = Icons.fitness_center;       iconColor = AppTheme.cardBlue;   break;
      case 'fitness club':
        icon = Icons.sports_gymnastics;    iconColor = AppTheme.cardPurple; break;
      case 'outdoor':
        icon = Icons.park;                 iconColor = AppTheme.cardGreen;  break;
      case 'studio':
        icon = Icons.self_improvement;     iconColor = AppTheme.cardYellow; break;
      case 'pool':
        icon = Icons.pool;                 iconColor = AppTheme.cardIndigo; break;
      default:
        icon = Icons.location_on;          iconColor = AppTheme.cardPink;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider)),
      child: Column(children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 20)),
          title: Text(place['name'] as String,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          subtitle: Text(place['address'] as String? ?? '',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 11)),
          trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6)),
              child: Text(place['type'] as String,
                  style: TextStyle(
                      color: iconColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold))),
        ),
        const Divider(color: AppTheme.divider, height: 1),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          TextButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, color: AppTheme.brand, size: 14),
              label: Text(context.l10n.edit,
                  style: const TextStyle(
                      color: AppTheme.brand,
                      fontSize: 12,
                      fontWeight: FontWeight.bold))),
          Container(width: 1, height: 28, color: AppTheme.divider),
          TextButton.icon(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 14),
              label: Text(context.l10n.remove,
                  style: const TextStyle(color: AppTheme.error, fontSize: 12))),
        ]),
      ]),
    );
  }
}

// =============================================================================
// REGISTRATION CREDENTIAL CARD
// =============================================================================
class RegistrationCredentialCard extends StatefulWidget {
  final Map<String, dynamic>       credential;
  final List<Map<String, dynamic>> allCredentials;
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback onCancel;

  const RegistrationCredentialCard({
    super.key,
    required this.credential,
    required this.allCredentials,
    required this.onSave,
    required this.onEdit,
    required this.onRemove,
    required this.onCancel,
  });
  @override
  State<RegistrationCredentialCard> createState() =>
      _RegistrationCredentialCardState();
}

class _RegistrationCredentialCardState
    extends State<RegistrationCredentialCard> {
  String? _org;
  final List<Map<String, dynamic>>  _certs   = [];
  final List<TextEditingController> _idCtrls = [];

  @override
  void initState() {
    super.initState();
    _org = widget.credential['org'];
    if (widget.credential['certs'] != null) {
      for (final c in widget.credential['certs']) {
        _certs.add(Map<String, dynamic>.from(c));
        _idCtrls.add(TextEditingController(text: c['certId'] ?? '')
          ..addListener(() => setState(() {})));
      }
    } else if (widget.credential['cert'] != null) {
      _certs.add({
        'cert': widget.credential['cert'],
        'certId': widget.credential['certId'] ?? '',
      });
      _idCtrls.add(
          TextEditingController(text: widget.credential['certId'] ?? '')
            ..addListener(() => setState(() {})));
    } else {
      _certs.add({'cert': null, 'certId': ''});
      _idCtrls.add(TextEditingController()..addListener(() => setState(() {})));
    }
  }

  @override
  void dispose() {
    for (final c in _idCtrls) c.dispose();
    super.dispose();
  }

  List<String> get _availableOrgs =>
      MedicalData.kTrainerCertifications.keys.where((org) {
        if (org == _org) return true;
        for (final c in widget.allCredentials) {
          if (c != widget.credential && c['org'] == org) return false;
        }
        return (MedicalData.kTrainerCertifications[org] ?? const []).isNotEmpty;
      }).toList();

  List<String> _certsFor(String org, {int? ignoreIndex}) {
    final all  = MedicalData.kTrainerCertifications[org] ?? [];
    final used = <String>{};
    for (final c in widget.allCredentials) {
      if (c != widget.credential && c['org'] == org && c['certs'] != null) {
        for (final cert in c['certs']) {
          if (cert['cert'] != null) used.add(cert['cert'] as String);
        }
      }
    }
    for (int i = 0; i < _certs.length; i++) {
      if (ignoreIndex != null && i == ignoreIndex) continue;
      if (_certs[i]['cert'] != null) used.add(_certs[i]['cert'] as String);
    }
    return all.where((c) => !used.contains(c)).toList();
  }

  int get _maxCertsForOrg =>
      _org == null ? 0 : MedicalData.kTrainerCertifications[_org]?.length ?? 0;

  bool get _isValid {
    if (_org == null || _certs.isEmpty) return false;
    for (int i = 0; i < _certs.length; i++) {
      if (_certs[i]['cert'] == null) return false;
      if (!RegExp(r'^[a-zA-Z0-9\-/]{3,}$').hasMatch(_idCtrls[i].text)) return false;
    }
    return true;
  }

  void _pickOrg() => AppMotion.showPremiumDialog<void>(
        context: context,
        builder: (_) => _PickerDialog(
            title: context.l10n.selectOrganisation,
            items: _availableOrgs,
            selected: _org,
            onSelect: (v) => setState(() {
                  _org = v;
                  _certs.clear();
                  _certs.add({'cert': null});
                  for (final c in _idCtrls) c.dispose();
                  _idCtrls.clear();
                  _idCtrls.add(
                      TextEditingController()..addListener(() => setState(() {})));
                })),
      );

  void _pickCert(int index) {
    final org = _org;
    if (org == null) return;
    final certs = _certsFor(org, ignoreIndex: index);
    AppMotion.showPremiumDialog<void>(
        context: context,
        builder: (_) => _PickerDialog(
            title: context.l10n.selectCertificate,
            items: certs,
            selected: _certs[index]['cert'],
            onSelect: (v) => setState(() => _certs[index]['cert'] = v)));
  }

  String _certLabel(int i) {
    final org = _org;
    if (org == null) return context.l10n.certificateId;
    final orgMatch = RegExp(r'\(([^)]+)\)').firstMatch(org);
    final orgAbbr  = orgMatch?.group(1) ?? org.split(' ').first;
    final certValue = _certs[i]['cert'];
    final cert = certValue is String ? certValue : null;
    if (cert == null) return '${context.l10n.certificateId} ($orgAbbr)';
    final certMatch = RegExp(r'\(([^)]+)\)').firstMatch(cert);
    final certAbbr  = certMatch != null
        ? (certMatch.group(1) ?? '').replaceAll(RegExp(r'^[A-Z]+-'), '')
        : cert.split(' ').take(3).join(' ');
    return '${context.l10n.certificateId} ($orgAbbr - $certAbbr)';
  }

  List<SubmittedCredentialCertificate> get _submittedCertificates {
    final submitted = <SubmittedCredentialCertificate>[];
    for (var i = 0; i < _certs.length; i++) {
      final certValue = _certs[i]['cert'];
      final savedIdValue = _certs[i]['certId'];
      final controllerText =
          i < _idCtrls.length ? _idCtrls[i].text.trim() : '';
      final cert = certValue is String ? certValue : '';
      final savedId = savedIdValue is String ? savedIdValue.trim() : '';
      final certId = controllerText.isNotEmpty ? controllerText : savedId;
      if (cert.isEmpty && certId.isEmpty) continue;
      submitted.add(SubmittedCredentialCertificate(
        certificate: cert,
        certificateId: certId,
        certificateIdLabel: _certLabel(i),
      ));
    }
    return submitted;
  }

  @override
  Widget build(BuildContext context) {
    final bool editing       = widget.credential['_isEditing'] == true;
    final org                = _org;
    final bool certIdEditable = editing && org != null;
    final bool canAddMore    = org != null &&
        _certs.length < _maxCertsForOrg &&
        _certsFor(org).isNotEmpty;

    if (!editing) {
      return SubmittedCredentialCard(
        organisation: org ?? '',
        certificates: _submittedCertificates,
        onEdit: widget.onEdit,
        onRemove: widget.onRemove,
      );
    }

    // ── Editing state: premium dark card ─────────────────────────────────
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLow,
        borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius + 2),
        border: Border.all(
          color: AppTheme.brand.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.brand.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Card header ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.brand.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.kDefaultBorderRadius + 2),
                  topRight: Radius.circular(AppConstants.kDefaultBorderRadius + 2),
                ),
                border: Border(
                  bottom: BorderSide(
                      color: AppTheme.brand.withValues(alpha: 0.15), width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.badge_outlined,
                      color: AppTheme.brand, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    context.l10n.addCredential,
                    style: const TextStyle(
                      color: AppTheme.brand,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            // ── Organisation picker ───────────────────────────────────────
            _CredentialFieldSection(
              label: context.l10n.organisation,
              child: _PickerRow(
                value: _org,
                placeholder: context.l10n.selectOrganisation,
                active: true,
                onTap: _pickOrg,
              ),
            ),

            // ── Certificate rows ──────────────────────────────────────────
            ...List.generate(_certs.length, (i) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 1,
                    color: AppTheme.divider,
                    margin: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  _CredentialFieldSection(
                    label: context.l10n.certificate,
                    trailingAction: _certs.length > 1
                        ? TnTPressable(
                            onTap: () => setState(() {
                              _certs.removeAt(i);
                              _idCtrls[i].dispose();
                              _idCtrls.removeAt(i);
                            }),
                            haptic: TnTHaptic.light,
                            pressedScale: 0.88,
                            borderRadius: BorderRadius.circular(99),
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: AppTheme.error.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppTheme.error.withValues(alpha: 0.3),
                                    width: 1),
                              ),
                              child: const Icon(Icons.close,
                                  color: AppTheme.error, size: 14),
                            ),
                          )
                        : null,
                    child: _PickerRow(
                      value: _certs[i]['cert'],
                      placeholder: _org == null
                          ? context.l10n.selectOrganisation
                          : context.l10n.selectCertificate,
                      active: _org != null,
                      onTap: (_org != null) ? () => _pickCert(i) : null,
                    ),
                  ),
                  if (_org != null && _certs[i]['cert'] == null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                      child: StandardFormWarningBanner(
                          message: context.l10n.certificateRequired,
                          margin: EdgeInsets.zero),
                    ),

                  // Certificate ID field
                  Container(
                    height: 1,
                    color: AppTheme.divider,
                    margin: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  _CredentialFieldSection(
                    label: _certLabel(i),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
                      child: TextFormField(
                        controller: _idCtrls[i],
                        readOnly: !certIdEditable,
                        enabled: certIdEditable,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9\-/]'))
                        ],
                        style: TextStyle(
                          color: certIdEditable
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                          fontSize: AppConstants.kDefaultSubtitleFontSize,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.surfaceRaised
                              .withValues(alpha: certIdEditable ? 0.6 : 0.3),
                          hintText: _org == null
                              ? context.l10n.selectOrganisation
                              : null,
                          hintStyle: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 13),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppConstants.kDefaultBorderRadius),
                            borderSide: BorderSide(
                              color: certIdEditable
                                  ? AppTheme.outlineStrong
                                  : AppTheme.divider,
                              width: 1.2,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppConstants.kDefaultBorderRadius),
                            borderSide: const BorderSide(
                                color: AppTheme.divider, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppConstants.kDefaultBorderRadius),
                            borderSide: const BorderSide(
                                color: AppTheme.brand, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (certIdEditable &&
                      !RegExp(r'^[a-zA-Z0-9\-/]{3,}$')
                          .hasMatch(_idCtrls[i].text))
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                      child: StandardFormWarningBanner(
                          message: context.l10n.certificateIdRequired,
                          margin: EdgeInsets.zero),
                    ),
                ],
              );
            }),

            // ── Add another cert ──────────────────────────────────────────
            if (org != null) ...[
              Container(
                height: 1,
                color: AppTheme.divider,
                margin: const EdgeInsets.symmetric(horizontal: 18),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                child: canAddMore
                    ? TnTPressable(
                        onTap: () => setState(() {
                          _certs.add({'cert': null, 'certId': ''});
                          _idCtrls.add(TextEditingController()
                            ..addListener(() => setState(() {})));
                        }),
                        haptic: TnTHaptic.light,
                        borderRadius: BorderRadius.circular(8),
                        child: Row(children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppTheme.brand.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppTheme.brand.withValues(alpha: 0.3),
                                  width: 1),
                            ),
                            child: const Icon(Icons.add,
                                color: AppTheme.brand, size: 12),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              context.l10n.addAnotherCertificateFromOrganisation,
                              style: const TextStyle(
                                color: AppTheme.brand,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ]),
                      )
                    : StandardFormWarningBanner(
                        message: _certs.length >= _maxCertsForOrg
                            ? context.l10n.credentialLimitReached(
                                org, _maxCertsForOrg.toString())
                            : context.l10n.allCertificatesInUse,
                        margin: EdgeInsets.zero,
                      ),
              ),
            ],

            // ── Action row ────────────────────────────────────────────────
            Container(
              height: 1,
              color: AppTheme.divider,
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Expanded(
                  child: SolidConfirmButton(
                    label: context.l10n.save,
                    height: 42,
                    onPressed: _isValid
                        ? () {
                            final resCerts = List.generate(
                                _certs.length,
                                (i) => {
                                      'cert': _certs[i]['cert'],
                                      'certId': _idCtrls[i].text.trim(),
                                    });
                            widget.onSave({
                              'org': org,
                              'certs': resCerts,
                              '_isEditing': false,
                            });
                          }
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlineActionButton(
                    label: context.l10n.cancel,
                    textColor: AppTheme.textSecondary,
                    borderColor: AppTheme.divider,
                    height: 42,
                    onPressed: widget.onCancel,
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// CREDENTIAL FIELD SECTION  — labelled section inside the editing card
// =============================================================================
class _CredentialFieldSection extends StatelessWidget {
  final String label;
  final Widget child;
  final Widget? trailingAction;

  const _CredentialFieldSection({
    required this.label,
    required this.child,
    this.trailingAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: AppTheme.textSecondary.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              if (trailingAction != null) trailingAction!,
            ],
          ),
        ),
        child,
      ],
    );
  }
}

// =============================================================================
// SUBMITTED CREDENTIAL CARD  (read-only premium display)
// =============================================================================
class SubmittedCredentialCertificate {
  final String certificate;
  final String certificateId;
  final String certificateIdLabel;

  const SubmittedCredentialCertificate({
    required this.certificate,
    required this.certificateId,
    required this.certificateIdLabel,
  });
}

class SubmittedCredentialCard extends StatelessWidget {
  final String organisation;
  final List<SubmittedCredentialCertificate> certificates;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const SubmittedCredentialCard({
    super.key,
    required this.organisation,
    required this.certificates,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLow,
        borderRadius:
            BorderRadius.circular(AppConstants.kDefaultBorderRadius + 2),
        border: Border.all(color: AppTheme.outlineSoft),
        boxShadow: AppTheme.softShadow,
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Card header strip ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              decoration: BoxDecoration(
                color: AppTheme.surfaceRaised.withValues(alpha: 0.6),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.kDefaultBorderRadius + 2),
                  topRight:
                      Radius.circular(AppConstants.kDefaultBorderRadius + 2),
                ),
                border: Border(
                  bottom:
                      BorderSide(color: AppTheme.divider.withValues(alpha: 0.8)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.cardGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppTheme.cardGreen.withValues(alpha: 0.3),
                          width: 1),
                    ),
                    child: const Icon(Icons.verified_outlined,
                        color: AppTheme.cardGreen, size: 15),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'VERIFIED CREDENTIAL',
                    style: TextStyle(
                      color: AppTheme.cardGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            // ── Fields ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SubmittedCredentialValue(
                    label: context.l10n.organisation,
                    value: organisation,
                  ),
                  for (final credential in certificates) ...[
                    const SizedBox(height: 14),
                    _SubmittedCredentialValue(
                      label: context.l10n.certificate,
                      value: credential.certificate,
                    ),
                    const SizedBox(height: 14),
                    _SubmittedCredentialValue(
                      label: credential.certificateIdLabel,
                      value: credential.certificateId,
                    ),
                  ],
                ],
              ),
            ),

            // ── Action row ────────────────────────────────────────────────
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 18),
              color: AppTheme.divider,
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: _SubmittedCredentialActionButton(
                      label: context.l10n.edit,
                      icon: Icons.edit_outlined,
                      color: AppTheme.textSecondary,
                      borderColor: AppTheme.divider,
                      onPressed: onEdit,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SubmittedCredentialActionButton(
                      label: context.l10n.remove,
                      icon: Icons.delete_outline,
                      color: AppTheme.error,
                      borderColor: AppTheme.error,
                      onPressed: onRemove,
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

class _SubmittedCredentialValue extends StatelessWidget {
  final String label;
  final String value;

  const _SubmittedCredentialValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: AppTheme.textSecondary.withValues(alpha: 0.65),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 46),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceRaised.withValues(alpha: 0.5),
            borderRadius:
                BorderRadius.circular(AppConstants.kDefaultBorderRadius),
            border: Border.all(color: AppTheme.divider),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            softWrap: true,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: AppConstants.kDefaultSubtitleFontSize,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _SubmittedCredentialActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color borderColor;
  final VoidCallback onPressed;

  const _SubmittedCredentialActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.borderColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TnTPressable(
      onTap: onPressed,
      haptic: TnTHaptic.light,
      borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: borderColor.withValues(alpha: 0.055),
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          border: Border.all(
            color: borderColor.withValues(alpha: 0.45),
            width: 1.2,
          ),
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 15),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: AppConstants.kDefaultButtonTextSizeMedium,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// PICKER ROW  — tappable row inside the credential editing card
// =============================================================================
class _PickerRow extends StatelessWidget {
  final String?      value;
  final String       placeholder;
  final bool         active;
  final VoidCallback? onTap;

  const _PickerRow({
    required this.value,
    required this.placeholder,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = value == null;
    final isEnabled     = onTap != null;
    final textColor     = isEnabled
        ? (isPlaceholder ? AppTheme.textSecondary : AppTheme.textPrimary)
        : (isPlaceholder ? Colors.white24 : AppTheme.textSecondary);

    return TnTPressable(
      onTap: isEnabled ? onTap : null,
      enabled: isEnabled,
      haptic: TnTHaptic.light,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? placeholder,
                style: TextStyle(
                  color: textColor,
                  fontSize: AppConstants.kDefaultSubtitleFontSize,
                  fontWeight:
                      isEnabled && !isPlaceholder ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (active)
              Icon(
                Icons.chevron_right,
                color: isEnabled
                    ? AppTheme.textSecondary
                    : AppTheme.textSecondary.withValues(alpha: 0.3),
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// PICKER DIALOG  (full-bleed dividers, left-aligned text)
// =============================================================================
class _PickerDialog extends StatelessWidget {
  final String           title;
  final List<String>     items;
  final String?          selected;
  final ValueChanged<String> onSelect;

  const _PickerDialog({
    required this.title,
    required this.items,
    this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surface,
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Text(title,
                style: const TextStyle(
                    color: AppTheme.brand,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ),
          const Divider(color: AppTheme.divider, height: 1, thickness: 1),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: items.length,
          separatorBuilder: (_, __) =>
              const Divider(color: AppTheme.divider, height: 1, thickness: 1),
          itemBuilder: (ctx, i) {
            final item = items[i];
            final sel  = item == selected;
            return InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.pop(context);
                onSelect(item);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 16),
                color: sel
                    ? AppTheme.brand.withValues(alpha: 0.1)
                    : Colors.transparent,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: sel ? AppTheme.brand : AppTheme.textPrimary,
                            fontWeight:
                                sel ? FontWeight.bold : FontWeight.normal,
                            fontSize: AppConstants.kDefaultSubtitleFontSize),
                      ),
                    ),
                    if (sel)
                      const Icon(Icons.check, color: AppTheme.brand, size: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// =============================================================================
// FORGOT PASSWORD SCREEN
// =============================================================================
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.lock_reset, size: 80, color: AppTheme.brand),
            const SizedBox(height: 30),
            Text(context.l10n.forgotPassword,
                style: const TextStyle(
                    color: AppTheme.brand,
                    fontSize: AppConstants.kDefaultTitleFontSize,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Text(context.l10n.resetPasswordInstructions,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: AppConstants.kDefaultSubtitleFontSize,
                    height: 1.5)),
            const SizedBox(height: 40),
            TextField(
              cursorColor: AppTheme.brand,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: AppConstants.kDefaultSubtitleFontSize),
              decoration: InputDecoration(
                labelText: context.l10n.idOrEmail,
                labelStyle: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: AppConstants.kDefaultSubtitleFontSize),
                floatingLabelStyle: WidgetStateTextStyle.resolveWith((s) =>
                    TextStyle(
                        color: s.contains(WidgetState.focused)
                            ? AppTheme.brand
                            : AppTheme.textPrimary,
                        fontSize: AppConstants.kDefaultFormTitleFontSize)),
                prefixIcon: const Icon(CupertinoIcons.mail_solid,
                    size: AppConstants.kDefaultIconSize,
                    color: AppTheme.textSecondary),
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
              ),
            ),
            const SizedBox(height: 40),
            SolidConfirmButton(
                label: context.l10n.sendResetLink,
                height: AppConstants.kDefaultButtonHeightLarge,
                onPressed: () {
                  Navigator.pop(context);
                  AppUtils.showToast(context, context.l10n.resetLinkSent);
                }),
          ]),
        ),
      ),
    );
  }
}

// =============================================================================
// PRIVATE HELPER
// =============================================================================
String _joinPrefixes(List<String> prefixes, String or) {
  if (prefixes.isEmpty) return '';
  if (prefixes.length == 1) return prefixes.first;
  if (prefixes.length == 2) return '${prefixes[0]} $or ${prefixes[1]}';
  return '${prefixes.sublist(0, prefixes.length - 1).join(', ')}, $or ${prefixes.last}';
}