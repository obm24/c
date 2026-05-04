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
import '../core/animations/app_motion.dart';
import '../core/c_phone_validator.dart';
import '../core/c_warnings.dart';
import '../core/c_trainee_profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc_phone_validation.dart';

// =============================================================================
// LOGIN SCREEN
// =============================================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  String? _idError, _passError;

  @override
  void initState() {
    super.initState();
    _idCtrl.addListener(() => setState(() {}));
    _passCtrl.addListener(() => setState(() {}));
  }

  Future<void> _handleLogin() async {
    setState(() {
      _idError = null;
      _passError = null;
    });
    final id = _idCtrl.text.trim();
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
        _idError = isEmailInput
            ? context.l10n.incorrectEmail
            : context.l10n.incorrectUsername;
        _passError = context.l10n.incorrectPassword;
      });
      return;
    }
    if (mounted) {
      context.go('/dashboard/$role');
    }
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
                                      fontSize:
                                          AppConstants.kDefaultAppTitleFontSize,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2))))),
                  const SizedBox(height: 60),
                  TextFormField(
                    controller: _idCtrl,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: AppConstants.kDefaultSubtitleFontSize),
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\n'))
                    ],
                    decoration: InputDecoration(
                      labelText: context.l10n.id,
                      errorText: _idError,
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
                      prefixIcon: const Icon(CupertinoIcons.person_solid,
                          size: AppConstants.kDefaultIconSize,
                          color: AppTheme.textSecondary),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 18),
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
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppConstants.kDefaultBorderRadius),
                          borderSide: const BorderSide(
                              color: AppTheme.error, width: 1.5)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppConstants.kDefaultBorderRadius),
                          borderSide: const BorderSide(
                              color: AppTheme.error, width: 2)),
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
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\n'))
                    ],
                    decoration: InputDecoration(
                      labelText: context.l10n.password,
                      errorText: _passError,
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
                      prefixIcon: const Icon(CupertinoIcons.lock_fill,
                          size: AppConstants.kDefaultIconSize,
                          color: AppTheme.textSecondary),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 18),
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
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppConstants.kDefaultBorderRadius),
                          borderSide: const BorderSide(
                              color: AppTheme.error, width: 1.5)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppConstants.kDefaultBorderRadius),
                          borderSide: const BorderSide(
                              color: AppTheme.error, width: 2)),
                    ),
                  ),
                  Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                              context,
                              AppRoutes.noTransitionRoute(
                                  const ForgotPasswordScreen()));
                        },
                        child: Text(context.l10n.forgotPassword,
                            style: const TextStyle(
                                color: AppTheme.brand,
                                fontSize:
                                    AppConstants.kDefaultSubtitleFontSize)),
                      )),
                  const SizedBox(height: 20),
                  Align(
                      alignment: Alignment.center,
                      child: AnimatedLoginButton(
                          label: context.l10n.login,
                          onPressed: ready ? _handleLogin : () async {})),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(context.l10n.dontHaveAccount,
                        style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: AppConstants.kDefaultSubtitleFontSize)),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                            context,
                            AppRoutes.noTransitionRoute(
                                const RegistrationScreen()));
                      },
                      child: Text(context.l10n.register,
                          style: const TextStyle(
                              color: AppTheme.brand,
                              fontWeight: FontWeight.bold,
                              fontSize: AppConstants.kDefaultSubtitleFontSize)),
                    ),
                  ]),
                ]),
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

  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _fNameCtrl = TextEditingController();
  final TextEditingController _lNameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confPassCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController();
  final TextEditingController _weightCtrl = TextEditingController();
  final TextEditingController _idNumberCtrl = TextEditingController();
  final GlobalKey _countryFieldKey = GlobalKey();
  final GlobalKey _subdivisionFieldKey = GlobalKey();

  bool _idImageUploaded = false;
  List<String> _trainerSpecialties = [];
  List<String> _traineeGoals = [];
  int? _selectedTrainingExperienceYears;
  List<String> _preferredDiets = [];
  final List<Map<String, dynamic>> _trainerCredentials = [];

  // 0 = Hybrid, 1 = Online Only, 2 = In-Person Only
  int? _employmentMode;
  final List<Map<String, dynamic>> _regPlaces = [];

  String? _selectedCountryCode;
  late List<String> _sortedCodes;

  String? _selectedCountry;
  String? _selectedRegion;
  DateTime? _dob;
  String? _gender;

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
      _usernameCtrl,
      _fNameCtrl,
      _lNameCtrl,
      _emailCtrl,
      _passCtrl,
      _confPassCtrl,
      _phoneCtrl,
      _idNumberCtrl,
    ]) {
      ctrl.addListener(() => setState(() {}));
    }
    _heightCtrl.addListener(() => setState(() {}));
    _weightCtrl.addListener(() => setState(() {}));
  }

  /// Returns the dial-code entry from [_sortedCodes] whose ISO code matches
  /// the ISO code of [selection], or null if no match is found.
  String? _countryCodeForSelection(String? selection) {
    final isoCode = PhoneCountryMetadata.isoCodeFromSelection(selection);
    if (isoCode == null) return null;
    for (final code in _sortedCodes) {
      if (PhoneCountryMetadata.isoCodeFromSelection(code) == isoCode) {
        return code;
      }
    }
    return null;
  }

  @override
  void dispose() {
    for (final ctrl in [
      _usernameCtrl,
      _fNameCtrl,
      _lNameCtrl,
      _emailCtrl,
      _passCtrl,
      _confPassCtrl,
      _phoneCtrl,
      _heightCtrl,
      _weightCtrl,
      _idNumberCtrl,
    ]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  // ── Validators ──────────────────────────────────────────────────────────────
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
        _selectedCountry ?? '',
        _phoneCtrl.text,
        dialCodeSelection: _selectedCountryCode,
      ).isValid;

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
    if (_isMetric == null) {
      return 'Select measurement units before entering your height.';
    }
    final text = _heightCtrl.text.trim();
    if (_isMetric == true) {
      if (text.isEmpty) return 'Height is required. Enter your height in centimeters.';
      final h = double.tryParse(text);
      if (h == null) return 'Height must be a number in centimeters.';
      if (h < 100 || h > 250) return 'Height must be between 100 and 250 cm.';
      return 'Height looks realistic for metric registration.';
    }
    if (text.isEmpty) return 'Height is required. Enter feet and inches.';
    final parts = _imperialHeightParts();
    if (parts == null) return 'Enter height as feet and inches, for example 5\' 9".';
    if (parts.$2 < 0 || parts.$2 > 11) return 'Inches must be between 0 and 11.';
    final total = (parts.$1 * 12) + parts.$2;
    if (total < 39 || total > 98) return 'Height must be between 3 ft 3 in and 8 ft 2 in.';
    return 'Height looks realistic for imperial registration.';
  }

  String get _weightWarningText {
    if (_isMetric == null) {
      return 'Select measurement units before entering your weight.';
    }
    final text = _weightCtrl.text.trim();
    if (_isMetric == true) {
      if (text.isEmpty) return 'Weight is required. Enter your weight in kilograms.';
      final w = double.tryParse(text);
      if (w == null) return 'Weight must be a number in kilograms.';
      if (w < 30 || w > 300) return 'Weight must be between 30 and 300 kg.';
      return 'Weight looks realistic for metric registration.';
    }
    if (text.isEmpty) return 'Weight is required. Enter your weight in pounds.';
    final w = double.tryParse(text);
    if (w == null) return 'Weight must be a number in pounds.';
    if (w < 66 || w > 660) return 'Weight must be between 66 and 660 lb.';
    return 'Weight looks realistic for imperial registration.';
  }

  bool get isCredentialsValid {
    if (_trainerCredentials.isEmpty) return false;
    for (final c in _trainerCredentials) {
      if (c['org'] == null || c['_isEditing'] == true) return false;
      final certs = c['certs'] as List?;
      if (certs == null || certs.isEmpty) return false;
      for (final cert in certs) {
        if (cert['cert'] == null ||
            (cert['certId'] as String?)?.isEmpty == true) return false;
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
    final adminInfo = CountryAdminInfo.resolve(_selectedCountry);
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
        _dob != null &&
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
    final feet = int.tryParse(match.group(1) ?? '');
    final inches = int.tryParse(match.group(2) ?? '') ?? 0;
    if (feet == null) return null;
    return (feet, inches);
  }

  Future<void> _scrollToField(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.15,
    );
  }

  void _convertInputs() {
    if (_heightCtrl.text.isNotEmpty) {
      if (_isMetric == true) {
        final m = RegExp(r"^(\d+)'\s*(\d*)\x22?").firstMatch(_heightCtrl.text);
        if (m != null) {
          final feet = int.tryParse(m.group(1) ?? '');
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
          final ft = (cm / 2.54) ~/ 12;
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
    final cats = MedicalData.getCategorizedGoals(context);
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
    final cats = MedicalData.getCategorizedGoals(context);
    final results = await AppMotion.showPremiumDialog<List<String>>(
      context: context,
      builder: (ctx) => GroupedMultiSelectDialog(
        title: 'Training Goals',
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
        title: 'Preferred Diet',
        categories: TraineeDietData.categories,
        initialSelections: _preferredDiets,
      ),
    );
    if (results != null) setState(() => _preferredDiets = results);
  }

  static const List<String> _placeTypes = [
    'Gym', 'Fitness Club', 'Studio', 'Outdoor',
    'Pool', 'Rehabilitation Center', 'Sports Complex', 'Other',
  ];

  void _openPlaceSheet({Map<String, dynamic>? existing, int? editIdx}) {
    final nameCtrl = TextEditingController(text: existing?['name'] ?? '');
    final addrCtrl = TextEditingController(text: existing?['address'] ?? '');
    String selType = existing?['type'] ?? _placeTypes.first;
    String? selCity = existing?['city'];
    final adminInfo = CountryAdminInfo.resolve(_selectedCountry);
    final hasRegions = adminInfo.regions.isNotEmpty;

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
                  borderRadius: BorderRadius.circular(
                      AppConstants.kDefaultBorderRadius),
                  borderSide: const BorderSide(
                      color: AppTheme.textSecondary, width: 1.5)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      AppConstants.kDefaultBorderRadius),
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
                      editIdx != null
                          ? context.l10n.editLocation
                          : context.l10n.addLocation,
                      style: const TextStyle(
                          color: AppTheme.brand,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  Text(context.l10n.locationType,
                      style: const TextStyle(
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14),
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
                      decoration: dec(context.l10n.facilityName)),
                  const SizedBox(height: 15),
                  TextFormField(
                      initialValue: _selectedCountry?.textWithoutFlag,
                      readOnly: true,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: AppConstants.kDefaultSubtitleFontSize),
                      decoration: dec('Country of Employment',
                              suffixIcon: const Padding(
                                  padding: EdgeInsets.only(right: 12),
                                  child: Icon(Icons.public,
                                      color: AppTheme.textSecondary,
                                      size: 20)))
                          .copyWith(
                        prefixIcon: _selectedCountry != null &&
                                _selectedCountry!.flagSvgPath.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(14),
                                child: Container(
                                  width: 24,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black54, width: 0.5),
                                  ),
                                  child: SvgPicture.asset(
                                    _selectedCountry!.flagSvgPath,
                                    fit: BoxFit.cover,
                                  ),
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
                ]),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          inputFormatters: merged,
          textInputAction: TextInputAction.next,
          readOnly: readOnly,
          style: TextStyle(
              color:
                  readOnly ? AppTheme.textSecondary : AppTheme.textPrimary,
              fontSize: AppConstants.kDefaultSubtitleFontSize),
          decoration: InputDecoration(
            labelText: label,
            suffixText: suffixText,
            labelStyle: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: AppConstants.kDefaultSubtitleFontSize),
            floatingLabelStyle: WidgetStateTextStyle.resolveWith((s) =>
                TextStyle(
                    color: s.contains(WidgetState.focused)
                        ? AppTheme.brand
                        : AppTheme.textPrimary,
                    fontSize: AppConstants.kDefaultFormTitleFontSize)),
            suffixStyle: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: AppConstants.kDefaultSubtitleFontSize),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
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
        _mandatoryWarning(ruleText, isValid: isValid),
      ]),
    );
  }

  Widget _mandatoryWarning(String message, {bool isValid = false}) {
    return StandardFormWarningBanner(
      message: message,
      isValid: isValid,
      margin: const EdgeInsets.only(top: 8),
    );
  }

  /// Builds the inline feedback banner beneath the phone field.
  Widget _buildPhoneFeedback(PhoneValidationState state) {
    final result = state.validationResult;
    return StandardFormWarningBanner(
      message:
          PhoneValidationMessageBuilder.buildMessage(result, compact: true),
      isValid: result.isValid,
      margin: const EdgeInsets.only(top: 8),
      trailing: result.hasLongPrefixList && !result.isValid
          ? IconButton(
              onPressed: () => _showPhonePrefixDetails(result),
              splashRadius: 18,
              icon: const Icon(
                Icons.help_outline_rounded,
                size: 16,
                color: AppTheme.textSecondary,
              ),
            )
          : null,
    );
  }

  bool get _hasRegistrationProgress {
    final ctrls = [
      _usernameCtrl, _fNameCtrl, _lNameCtrl, _emailCtrl,
      _passCtrl, _confPassCtrl, _phoneCtrl, _heightCtrl,
      _weightCtrl, _idNumberCtrl,
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
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                context.l10n.cancelRegistrationTitle,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(color: AppTheme.divider, height: 1),
          ],
        ),
        content: Text(
          context.l10n.cancelRegistrationMessage,
          style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: AppConstants.kDefaultSubtitleFontSize,
              height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.discardProgress,
                style:
                    const TextStyle(color: AppTheme.textSecondary)),
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
                      borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 20),
            Text(
              '${result.countryDisplayName} Mobile Prefixes',
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              PhoneValidationMessageBuilder.buildPrefixDetails(result),
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.5),
            ),
          ],
        ),
      ),
    );
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
                  color: isSelected
                      ? AppTheme.brand
                      : AppTheme.textSecondary,
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                          fontSize:
                              AppConstants.kDefaultSubtitleFontSize)),
                  const SizedBox(height: 4),
                  Text(description,
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          height: 1.4)),
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
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                borderRadius: BorderRadius.circular(
                    AppConstants.kDefaultBorderRadius),
                border: Border.all(
                    color: AppTheme.textSecondary, width: 1.5)),
            child: Row(children: [
              Expanded(
                  child: selectedItems.isEmpty
                      ? Text(emptyText,
                          style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: AppConstants
                                  .kDefaultSubtitleFontSize))
                      : Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: selectedItems
                              .map((item) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                        color: chipColor,
                                        borderRadius: BorderRadius.circular(
                                            AppConstants
                                                .kDefaultBorderRadius)),
                                    child: Text(item,
                                        style: const TextStyle(
                                            color: AppTheme.bg,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                                  ))
                              .toList())),
              const Icon(Icons.arrow_drop_down,
                  color: AppTheme.textSecondary),
            ]),
          ),
        ),
        if (selectedItems.isEmpty && warningText != null)
          _mandatoryWarning(warningText),
      ]),
    );
  }

  // ── Phone prefix widget: flag SVG + dial code, no acronym ─────────────────
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
          hint: const Text(
            'Code',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          icon: const Icon(Icons.arrow_drop_down,
              color: AppTheme.textSecondary),
          selectedItemBuilder: (_) => _sortedCodes.map((c) {
            final parts = c.split(' ');
            final svgPath = parts[0];
            final dialCode = parts.length > 1 ? parts[1] : '';
            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 80),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                SvgPicture.asset(svgPath,
                    width: 22, height: 15, fit: BoxFit.cover),
                const SizedBox(width: 5),
                Text(dialCode,
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontSize: 13)),
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
                    width: 24, height: 16, fit: BoxFit.cover),
                const SizedBox(width: 10),
                Text(dialCode,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize:
                            AppConstants.kDefaultSubtitleFontSize)),
              ]),
            );
          }).toList(),
          // ✅ FIX: pass both dial code and current country so the BLoC
          //         resolves the correct rule immediately.
          onChanged: (v) {
            if (v == null) return;
            setState(() => _selectedCountryCode = v);
            bloc.add(CountrySelected(
              _selectedCountry ?? '',
              dialCodeSelection: v,
            ));
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
      // ✅ FIX: seed with both selections so the initial state is correct.
      create: (_) => PhoneValidationBloc()
        ..add(CountrySelected(
          _selectedCountry ?? '',
          dialCodeSelection: _selectedCountryCode,
        )),
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
                iconTheme:
                    const IconThemeData(color: AppTheme.textPrimary),
                title: Text(context.l10n.register,
                    style:
                        const TextStyle(color: AppTheme.brand))),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(32),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                        child: DualToggleSwitch(
                            leftLabel: context.l10n.trainee,
                            rightLabel: context.l10n.trainer,
                            isLeftSelected: _isTrainer != true,
                            selectionMade: _isTrainer != null,
                            onSelected: (isLeft) =>
                                setState(() => _isTrainer = !isLeft))),
                    if (_isTrainer == null)
                      _mandatoryWarning(
                          'Please select whether you are registering as a trainee or trainer.'),
                    const SizedBox(height: 30),

                    Text(context.l10n.accountInfo,
                        style: const TextStyle(
                            color: AppTheme.brand,
                            fontSize:
                                AppConstants.kDefaultTitleFontSize,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    _field(context.l10n.username,
                        ruleText:
                            context.l10n.invalidUsernameError,
                        isValid: isUsernameValid,
                        controller: _usernameCtrl,
                        formatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9_]'))
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
                        ruleText:
                            context.l10n.passwordMismatchError,
                        isValid: isConfPassValid,
                        controller: _confPassCtrl,
                        obscure: true),

                    const SizedBox(height: 10),
                    Text(context.l10n.personalInfo,
                        style: const TextStyle(
                            color: AppTheme.brand,
                            fontSize:
                                AppConstants.kDefaultTitleFontSize,
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

                    // ── Country dropdown ────────────────────────────────────
                    Padding(
                      key: _countryFieldKey,
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Builder(builder: (context) {
                        final bloc =
                            context.read<PhoneValidationBloc>();
                        return Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: _isTrainer == true
                                      ? 'Country of Employment'
                                      : _isTrainer == false
                                          ? 'Country of Residence'
                                          : 'Country',
                                  labelStyle: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: AppConstants
                                          .kDefaultSubtitleFontSize),
                                  floatingLabelStyle:
                                      const TextStyle(
                                          color: AppTheme.brand,
                                          fontSize: AppConstants
                                              .kDefaultFormTitleFontSize),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                              AppConstants
                                                  .kDefaultBorderRadius),
                                      borderSide: const BorderSide(
                                          color: AppTheme.textSecondary,
                                          width: 1.5)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                              AppConstants
                                                  .kDefaultBorderRadius),
                                      borderSide: const BorderSide(
                                          color: AppTheme.brand,
                                          width: 2)),
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 18),
                                ),
                                dropdownColor: AppTheme.surface,
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: AppTheme.textSecondary),
                                style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: AppConstants
                                        .kDefaultSubtitleFontSize),
                                initialValue: _selectedCountry,
                                isExpanded: true,
                                isDense: true,
                                itemHeight: null,
                                selectedItemBuilder: (_) =>
                                    AppConstants.kCountriesOnly
                                        .map((c) => CountryFlagWidget(
                                            textData: c))
                                        .toList(),
                                items: AppConstants.kCountriesOnly
                                    .map((c) => DropdownMenuItem(
                                        value: c,
                                        child: CountryFlagWidget(
                                            textData: c)))
                                    .toList(),
                                // ✅ FIX: pass the resolved dial code
                                //         together with the country so
                                //         both arrive in one BLoC event.
                                onChanged: (v) {
                                  final matchingCode =
                                      _countryCodeForSelection(v);
                                  setState(() {
                                    _selectedCountry = v;
                                    _selectedRegion = null;
                                    if (matchingCode != null) {
                                      _selectedCountryCode =
                                          matchingCode;
                                    }
                                  });
                                  bloc.add(CountrySelected(
                                    v ?? '',
                                    dialCodeSelection: matchingCode ??
                                        _selectedCountryCode,
                                  ));
                                },
                              ),
                              if (_selectedCountry == null)
                                _mandatoryWarning(_isTrainer == true
                                    ? context.l10n.selectCountryEmployment
                                    : _isTrainer == false
                                        ? context
                                            .l10n.selectCountryResidence
                                        : 'Please select your country.'),
                            ]);
                      }),
                    ),

                    // ── Subdivision picker ──────────────────────────────────
                    Builder(builder: (context) {
                      final adminInfo =
                          CountryAdminInfo.resolve(_selectedCountry);
                      final bool hasCountry =
                          _selectedCountry != null;
                      final bool hasRegions =
                          adminInfo.regions.isNotEmpty;
                      final String subdivLabel =
                          hasCountry && hasRegions
                              ? adminInfo.label
                              : 'Subdivision';
                      return Padding(
                          key: _subdivisionFieldKey,
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                IgnorePointer(
                                  ignoring:
                                      !hasCountry || !hasRegions,
                                  child:
                                      DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: subdivLabel,
                                      labelStyle: TextStyle(
                                          color: hasCountry
                                              ? AppTheme.textPrimary
                                              : AppTheme.textSecondary,
                                          fontSize: AppConstants
                                              .kDefaultSubtitleFontSize),
                                      floatingLabelStyle:
                                          const TextStyle(
                                              color: AppTheme.brand,
                                              fontSize: AppConstants
                                                  .kDefaultFormTitleFontSize),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(
                                                  AppConstants
                                                      .kDefaultBorderRadius),
                                          borderSide: BorderSide(
                                              color: hasCountry
                                                  ? AppTheme
                                                      .textSecondary
                                                  : Colors.white12,
                                              width: 1.5)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(
                                                  AppConstants
                                                      .kDefaultBorderRadius),
                                          borderSide: const BorderSide(
                                              color: AppTheme.brand,
                                              width: 2)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 18),
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
                                        fontSize: AppConstants
                                            .kDefaultSubtitleFontSize),
                                    initialValue: hasRegions
                                        ? _selectedRegion
                                        : null,
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
                                          fontSize: AppConstants
                                              .kDefaultSubtitleFontSize),
                                    ),
                                    isExpanded: true,
                                    isDense: true,
                                    itemHeight: null,
                                    items: hasRegions
                                        ? adminInfo.regions
                                            .map((r) =>
                                                DropdownMenuItem(
                                                    value: r,
                                                    child: Text(r)))
                                            .toList()
                                        : [],
                                    onChanged:
                                        hasCountry && hasRegions
                                            ? (v) => setState(
                                                () => _selectedRegion =
                                                    v)
                                            : null,
                                  ),
                                ),
                                if (hasCountry &&
                                    hasRegions &&
                                    _selectedRegion == null)
                                  _mandatoryWarning(context.l10n
                                      .pleaseSelectField(adminInfo.label
                                          .toLowerCase())),
                              ]));
                    }),

                    // ── Phone field ─────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Builder(builder: (context) {
                        final bloc =
                            context.read<PhoneValidationBloc>();
                        return BlocBuilder<PhoneValidationBloc,
                            PhoneValidationState>(
                          builder: (context, state) {
                            return Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _phoneCtrl,
                                  keyboardType: TextInputType.number,
                                  textInputAction:
                                      TextInputAction.next,
                                  inputFormatters: [
                                    FilteringTextInputFormatter
                                        .digitsOnly,
                                    // ✅ FIX: max length is derived live
                                    //         from the BLoC's resolved rule.
                                    LengthLimitingTextInputFormatter(
                                      state.maxRegistrationDigits,
                                    ),
                                  ],
                                  // ✅ FIX: notify BLoC on every keystroke.
                                  onChanged: (v) => bloc
                                      .add(PhoneNumberChanged(v)),
                                  style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: AppConstants
                                          .kDefaultSubtitleFontSize),
                                  decoration: InputDecoration(
                                    labelText:
                                        context.l10n.phoneNumber,
                                    labelStyle: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: AppConstants
                                            .kDefaultSubtitleFontSize),
                                    floatingLabelStyle:
                                        WidgetStateTextStyle
                                            .resolveWith((s) => TextStyle(
                                                color: s.contains(
                                                        WidgetState
                                                            .focused)
                                                    ? AppTheme.brand
                                                    : AppTheme
                                                        .textPrimary,
                                                fontSize: AppConstants
                                                    .kDefaultFormTitleFontSize)),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 15,
                                            vertical: 18),
                                    // ✅ FIX: pass the bloc reference so the
                                    //         dial-code dropdown fires the
                                    //         correct event.
                                    prefixIcon:
                                        _buildPhonePrefix(bloc),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                              AppConstants
                                                  .kDefaultBorderRadius),
                                      borderSide: BorderSide(
                                        color: !state.validationResult.isValid
                                            ? AppTheme.error
                                            : AppTheme.textSecondary,
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                              AppConstants
                                                  .kDefaultBorderRadius),
                                      borderSide: BorderSide(
                                        color: !state.validationResult.isValid
                                            ? AppTheme.error
                                            : AppTheme.brand,
                                        width: 2,
                                      ),
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

                    // ── Date of Birth ───────────────────────────────────────
                    Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(context.l10n.dateOfBirth,
                                  style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: AppConstants
                                          .kDefaultSubtitleFontSize)),
                              const SizedBox(height: 10),
                              DobDropdownWidget(
                                  initialDate: _dob,
                                  onChanged: (v) =>
                                      setState(() => _dob = v)),
                              if (_dob == null)
                                _mandatoryWarning(
                                    context.l10n.ageError),
                            ])),

                    // ── Gender ──────────────────────────────────────────────
                    Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(context.l10n.gender,
                                  style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: AppConstants
                                          .kDefaultSubtitleFontSize)),
                              const SizedBox(height: 10),
                              GenderToggleSwitch(
                                  selectedGender: _gender ?? '',
                                  onSelected: (v) =>
                                      setState(() => _gender = v)),
                              if (_gender == null)
                                _mandatoryWarning(
                                    context.l10n.genderSelectionError),
                            ])),

                    // ── Height ──────────────────────────────────────────────
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
                          ? const TextInputType.numberWithOptions(
                              decimal: true)
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

                    // ── Weight ──────────────────────────────────────────────
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
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      formatters: [
                        NumberBoundsFormatter(
                            maxWholeDigits: 3,
                            maxDecimalDigits: 2,
                            maxVal:
                                _isMetric == true ? 300.0 : 660.0)
                      ],
                    ),

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
                      _mandatoryWarning(
                          'Please select metric or imperial units.'),
                    const SizedBox(height: 30),

                    // ── Trainee section ─────────────────────────────────────
                    if (_isTrainer == false) ...[
                      const Divider(color: AppTheme.divider),
                      const SizedBox(height: 24),
                      const Text('Trainee Profile',
                          style: TextStyle(
                              color: AppTheme.brand,
                              fontSize:
                                  AppConstants.kDefaultTitleFontSize,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text(
                          'Help trainers understand your goals, training background, and nutrition preferences.',
                          style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              height: 1.5)),
                      const SizedBox(height: 16),
                      _buildGroupedSelectionField(
                        label: 'Training Goals',
                        selectedItems: _traineeGoals,
                        emptyText: 'Choose your training goals',
                        onTap: _openTraineeGoalsSelect,
                        warningText:
                            'Please select at least one training goal.',
                      ),
                      TrainingExperienceSelector(
                        selectedYears: _selectedTrainingExperienceYears,
                        onSelected: (years) => setState(() =>
                            _selectedTrainingExperienceYears = years),
                        showRequiredWarning:
                            _selectedTrainingExperienceYears == null,
                      ),
                      _buildGroupedSelectionField(
                        label: 'Preferred Diet',
                        selectedItems: _preferredDiets,
                        emptyText: 'Choose preferred diets',
                        onTap: _openPreferredDietSelect,
                        chipColor: AppTheme.cardGreen,
                        warningText:
                            'Please select at least one preferred diet.',
                      ),
                      const SizedBox(height: 10),
                      const Divider(color: AppTheme.divider),
                      const SizedBox(height: 20),
                    ],

                    // ── Trainer section ─────────────────────────────────────
                    if (_isTrainer == true) ...[
                      const SizedBox(height: 10),
                      Text(context.l10n.professionalInfo,
                          style: const TextStyle(
                              color: AppTheme.brand,
                              fontSize:
                                  AppConstants.kDefaultTitleFontSize,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),

                      // ID Number
                      Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
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
                                      fontSize: AppConstants
                                          .kDefaultSubtitleFontSize),
                                  decoration: InputDecoration(
                                    labelText: context
                                        .l10n.identificationNumber,
                                    labelStyle: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: AppConstants
                                            .kDefaultSubtitleFontSize),
                                    floatingLabelStyle:
                                        const TextStyle(
                                            color: AppTheme.brand,
                                            fontSize: AppConstants
                                                .kDefaultFormTitleFontSize),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                                AppConstants
                                                    .kDefaultBorderRadius),
                                        borderSide: const BorderSide(
                                            color: AppTheme.textSecondary,
                                            width: 1.5)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                                AppConstants
                                                    .kDefaultBorderRadius),
                                        borderSide: const BorderSide(
                                            color: AppTheme.brand,
                                            width: 2)),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 15,
                                            vertical: 15),
                                  ),
                                ),
                                if (!RegExp(r'^[a-zA-Z0-9]{7,18}$')
                                    .hasMatch(_idNumberCtrl.text))
                                  _mandatoryWarning(
                                      context.l10n.invalidIdNumberError),
                              ])),

                      // ID Image Upload
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Center(
                                        child: Container(
                                            width: 40,
                                            height: 4,
                                            decoration: BoxDecoration(
                                                color: AppTheme.divider,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10)))),
                                    const SizedBox(height: 25),
                                    Text(context.l10n.uploadId,
                                        style: const TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontSize: 20,
                                            fontWeight:
                                                FontWeight.bold),
                                        textAlign: TextAlign.center),
                                    const SizedBox(height: 25),
                                    SolidConfirmButton(
                                        label:
                                            context.l10n.scanViaCamera,
                                        icon: CupertinoIcons.camera,
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          final messenger =
                                              ScaffoldMessenger.of(
                                                  context);
                                          final msg = context.l10n
                                              .idUploadedSuccessfully;
                                          Navigator.push(
                                                  context,
                                                  AppRoutes
                                                      .noTransitionRoute(
                                                          const CustomCameraScreen(
                                                              isIdScan:
                                                                  true)))
                                              .then((v) {
                                            if (!mounted) return;
                                            if (v == true) {
                                              setState(() =>
                                                  _idImageUploaded =
                                                      true);
                                              messenger.showSnackBar(
                                                  SnackBar(
                                                      content:
                                                          Text(msg)));
                                            }
                                          });
                                        }),
                                    const SizedBox(height: 15),
                                    OutlineActionButton(
                                        label: context
                                            .l10n.uploadFromDevice,
                                        icon: const Icon(
                                            CupertinoIcons.photo,
                                            color: AppTheme.brand,
                                            size: 20),
                                        onPressed: () async {
                                          Navigator.pop(ctx);
                                          final f =
                                              await ImagePicker()
                                                  .pickImage(
                                                      source: ImageSource
                                                          .gallery);
                                          if (f != null) {
                                            setState(() =>
                                                _idImageUploaded = true);
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
                                    ? CupertinoIcons
                                        .check_mark_circled_solid
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
                                    color: AppTheme.textSecondary,
                                    fontSize: 12),
                                textAlign: TextAlign.center),
                          ]),
                        ),
                      ),
                      if (!_idImageUploaded)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _mandatoryWarning(
                              context.l10n.idDocumentRequiredWarning),
                        ),

                      // Specialties
                      Text(context.l10n.specialities,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: AppConstants
                                  .kDefaultSubtitleFontSize,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _openSpecialtiesSelect,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          constraints:
                              const BoxConstraints(minHeight: 60),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.kDefaultBorderRadius),
                              border: Border.all(
                                  color: AppTheme.textSecondary,
                                  width: 1.5)),
                          child: Row(children: [
                            Expanded(
                                child: _trainerSpecialties.isEmpty
                                    ? Text(
                                        context.l10n.addSpecialities,
                                        style: const TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: AppConstants
                                                .kDefaultSubtitleFontSize))
                                    : Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: _trainerSpecialties
                                            .map((s) => Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 8),
                                                  decoration: BoxDecoration(
                                                      color: AppTheme.brand,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              AppConstants
                                                                  .kDefaultBorderRadius)),
                                                  child: Text(s,
                                                      style: const TextStyle(
                                                          color: AppTheme.bg,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 13)),
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
                            child: _mandatoryWarning(
                                context.l10n.specialityRequired)),
                      if (_trainerSpecialties.isNotEmpty)
                        const SizedBox(height: 20),

                      // Credentials
                      Text(context.l10n.credentials,
                          style: const TextStyle(
                              color: AppTheme.brand,
                              fontSize:
                                  AppConstants.kDefaultTitleFontSize,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(context.l10n.credentialExplanation,
                          style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              height: 1.5)),
                      const SizedBox(height: 16),

                      ..._trainerCredentials.asMap().entries.map((e) {
                        final idx = e.key;
                        return RegistrationCredentialCard(
                          credential: e.value,
                          allCredentials: _trainerCredentials,
                          onSave: (d) => setState(
                              () => _trainerCredentials[idx] = d),
                          onEdit: () => setState(() =>
                              _trainerCredentials[idx]['_isEditing'] =
                                  true),
                          onRemove: () {
                            HapticFeedback.lightImpact();
                            AppMotion.showPremiumDialog<void>(
                                context: context,
                                builder: (_) => AlertDialog(
                                      backgroundColor: AppTheme.surface,
                                      titlePadding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(
                                                  AppConstants
                                                      .kDefaultBorderRadius)),
                                      title: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                child: Text(
                                                    context.l10n.remove,
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
                                          'Are you sure you want to remove this credential?',
                                          style: TextStyle(
                                              color: AppTheme.textPrimary,
                                              fontSize: AppConstants
                                                  .kDefaultSubtitleFontSize,
                                              height: 1.5)),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text(
                                                context.l10n.cancel,
                                                style: const TextStyle(
                                                    color: AppTheme
                                                        .textSecondary,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              setState(() =>
                                                  _trainerCredentials
                                                      .removeAt(idx));
                                            },
                                            child: Text(
                                                context.l10n.remove,
                                                style: const TextStyle(
                                                    color: AppTheme.error,
                                                    fontWeight:
                                                        FontWeight.bold)))
                                      ],
                                    ));
                          },
                          onCancel: () => setState(() {
                            if (_trainerCredentials[idx]['org'] ==
                                null) {
                              _trainerCredentials.removeAt(idx);
                            } else {
                              _trainerCredentials[idx]['_isEditing'] =
                                  false;
                            }
                          }),
                        );
                      }),

                      OutlineActionButton(
                          label: context.l10n.addCredential,
                          icon: const Icon(Icons.add,
                              color: AppTheme.brand),
                          height: 55,
                          onPressed: () => setState(() =>
                              _trainerCredentials.add({
                                'org': null,
                                'cert': null,
                                'certId': '',
                                '_isEditing': true,
                              }))),
                      if (_trainerCredentials.isEmpty)
                        Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _mandatoryWarning(
                                context.l10n.credentialRequired)),
                      if (!isCredentialsValid &&
                          _trainerCredentials.isNotEmpty)
                        Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _mandatoryWarning(
                                context.l10n.saveAllCredentials)),

                      // Places of Employment
                      const SizedBox(height: 30),
                      const Divider(color: AppTheme.divider),
                      const SizedBox(height: 20),
                      Text(context.l10n.placesOfEmployment,
                          style: const TextStyle(
                              color: AppTheme.brand,
                              fontSize:
                                  AppConstants.kDefaultTitleFontSize,
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
                        onTap: () =>
                            setState(() => _employmentMode = 0),
                      ),
                      const SizedBox(height: 10),
                      _employmentRadio(
                        mode: 1,
                        selected: _employmentMode,
                        title: context.l10n.onlineOnlyTraining,
                        description:
                            context.l10n.onlineOnlyTrainingDesc,
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
                        description:
                            context.l10n.inPersonOnlyTrainingDesc,
                        onTap: () =>
                            setState(() => _employmentMode = 2),
                      ),
                      const SizedBox(height: 16),
                      if (_employmentMode == null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _mandatoryWarning(
                              'Please select how you deliver your training services.'),
                        ),

                      if (_employmentMode == 0 ||
                          _employmentMode == 2) ...[
                        if (_regPlaces.isEmpty)
                          Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 8),
                              child: _mandatoryWarning(
                                  context.l10n.locationRequired)),
                        ..._regPlaces.asMap().entries.map((e) {
                          final idx = e.key;
                          final p = e.value;
                          return _RegPlaceCard(
                            place: p,
                            onEdit: () => _openPlaceSheet(
                                existing: p, editIdx: idx),
                            onRemove: () {
                              HapticFeedback.lightImpact();
                              AppMotion.showPremiumDialog<void>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                        backgroundColor:
                                            AppTheme.surface,
                                        titlePadding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    AppConstants
                                                        .kDefaultBorderRadius)),
                                        title: Column(
                                            mainAxisSize:
                                                MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Padding(
                                                  padding:
                                                      const EdgeInsets
                                                          .all(20),
                                                  child: Text(
                                                      context.l10n
                                                          .remove,
                                                      style: const TextStyle(
                                                          color: AppTheme
                                                              .error,
                                                          fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                          fontSize: AppConstants
                                                              .kDefaultTitleFontSize))),
                                              const Divider(
                                                  color: AppTheme
                                                      .divider,
                                                  height: 1),
                                            ]),
                                        content: const Text(
                                            'Are you sure you want to remove this location?',
                                            style: TextStyle(
                                                color:
                                                    AppTheme.textPrimary,
                                                fontSize: AppConstants
                                                    .kDefaultSubtitleFontSize,
                                                height: 1.5)),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(
                                                      context),
                                              child: Text(
                                                  context.l10n.cancel,
                                                  style: const TextStyle(
                                                      color: AppTheme
                                                          .textSecondary,
                                                      fontWeight:
                                                          FontWeight
                                                              .bold))),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                setState(() =>
                                                    _regPlaces
                                                        .removeAt(idx));
                                              },
                                              child: Text(
                                                  context.l10n.remove,
                                                  style: const TextStyle(
                                                      color:
                                                          AppTheme.error,
                                                      fontWeight:
                                                          FontWeight
                                                              .bold)))
                                        ],
                                      ));
                            },
                          );
                        }),
                        const SizedBox(height: 8),
                        OutlineActionButton(
                            label: context.l10n.addLocation,
                            icon: const Icon(
                                Icons.add_location_alt_outlined,
                                color: AppTheme.brand),
                            height: 50,
                            onPressed: () async {
                              HapticFeedback.lightImpact();
                              if (_selectedCountry == null) {
                                await _scrollToField(_countryFieldKey);
                                return;
                              }
                              final adminInfo = CountryAdminInfo.resolve(
                                  _selectedCountry);
                              if (adminInfo.regions.isNotEmpty &&
                                  _selectedRegion == null) {
                                await _scrollToField(
                                    _subdivisionFieldKey);
                                return;
                              }
                              _openPlaceSheet();
                            }),
                      ],

                      const SizedBox(height: 30),
                      const Divider(color: AppTheme.divider),
                      const SizedBox(height: 30),
                    ],

                    // ── Register button ─────────────────────────────────────
                    BlocBuilder<PhoneValidationBloc,
                        PhoneValidationState>(
                      builder: (context, phoneState) {
                        return SolidConfirmButton(
                          label: context.l10n.registerAction,
                          height:
                              AppConstants.kDefaultButtonHeightLarge,
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
                              final expYears =
                                  _selectedTrainingExperienceYears;
                              if (expYears == null) return;
                              appState.saveTraineePreferences(
                                goals: _traineeGoals,
                                trainingExperienceYears: expYears,
                                preferredDiets: _preferredDiets,
                              );
                            }
                            Navigator.pop(context);
                            AppUtils.showToast(context,
                                context.l10n.accountCreatedSuccess);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                  ]),
            ),
          ),
        ),
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
      {required this.place,
      required this.onEdit,
      required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color iconColor;
    switch ((place['type'] as String? ?? '').toLowerCase()) {
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
              width: 42,
              height: 42,
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              icon: const Icon(Icons.edit_outlined,
                  color: AppTheme.brand, size: 14),
              label: Text(context.l10n.edit,
                  style: const TextStyle(
                      color: AppTheme.brand,
                      fontSize: 12,
                      fontWeight: FontWeight.bold))),
          Container(width: 1, height: 28, color: AppTheme.divider),
          TextButton.icon(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline,
                  color: AppTheme.error, size: 14),
              label: Text(context.l10n.remove,
                  style: const TextStyle(
                      color: AppTheme.error, fontSize: 12))),
        ]),
      ]),
    );
  }
}

// =============================================================================
// REGISTRATION CREDENTIAL CARD
// =============================================================================
class RegistrationCredentialCard extends StatefulWidget {
  final Map<String, dynamic> credential;
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
  final List<Map<String, dynamic>> _certs = [];
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
      _idCtrls.add(TextEditingController()
        ..addListener(() => setState(() {})));
    }
  }

  @override
  void dispose() {
    for (final c in _idCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> get _availableOrgs =>
      MedicalData.kTrainerCertifications.keys.where((org) {
        if (org == _org) return true;
        for (final c in widget.allCredentials) {
          if (c != widget.credential && c['org'] == org) return false;
        }
        return (MedicalData.kTrainerCertifications[org] ?? const [])
            .isNotEmpty;
      }).toList();

  List<String> _certsFor(String org, {int? ignoreIndex}) {
    final all = MedicalData.kTrainerCertifications[org] ?? [];
    final used = <String>{};
    for (final c in widget.allCredentials) {
      if (c != widget.credential &&
          c['org'] == org &&
          c['certs'] != null) {
        for (final cert in c['certs']) {
          if (cert['cert'] != null) used.add(cert['cert'] as String);
        }
      }
    }
    for (int i = 0; i < _certs.length; i++) {
      if (ignoreIndex != null && i == ignoreIndex) continue;
      if (_certs[i]['cert'] != null) {
        used.add(_certs[i]['cert'] as String);
      }
    }
    return all.where((c) => !used.contains(c)).toList();
  }

  int get _maxCertsForOrg {
    if (_org == null) return 0;
    return MedicalData.kTrainerCertifications[_org]?.length ?? 0;
  }

  bool get _isValid {
    if (_org == null || _certs.isEmpty) return false;
    for (int i = 0; i < _certs.length; i++) {
      if (_certs[i]['cert'] == null) return false;
      if (!RegExp(r'^[a-zA-Z0-9\-/]{3,}$').hasMatch(_idCtrls[i].text)) {
        return false;
      }
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
                  for (final c in _idCtrls) {
                    c.dispose();
                  }
                  _idCtrls.clear();
                  _idCtrls.add(TextEditingController()
                    ..addListener(() => setState(() {})));
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
            onSelect: (v) =>
                setState(() => _certs[index]['cert'] = v)));
  }

  String _certLabel(int i) {
    final org = _org;
    if (org == null) return 'Certificate ID';
    final orgMatch = RegExp(r'\(([^)]+)\)').firstMatch(org);
    final orgAbbr =
        orgMatch?.group(1) ?? org.split(' ').first;
    final cert = _certs[i]['cert'];
    if (cert == null) return 'Certificate ID ($orgAbbr)';
    final certMatch =
        RegExp(r'\(([^)]+)\)').firstMatch(cert);
    final certAbbr = certMatch != null
        ? (certMatch.group(1) ?? '')
            .replaceAll(RegExp(r'^[A-Z]+-'), '')
        : cert.split(' ').take(3).join(' ');
    return 'Certificate ID ($orgAbbr - $certAbbr)';
  }

  @override
  Widget build(BuildContext context) {
    final bool editing = widget.credential['_isEditing'] == true;
    final org = _org;
    final bool certIdEditable = editing && org != null;
    final bool canAddMore = org != null &&
        _certs.length < _maxCertsForOrg &&
        _certsFor(org).isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          border: Border.all(
              color:
                  editing ? AppTheme.brand : AppTheme.textSecondary,
              width: 1.5)),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Label('Organisation', editing: editing),
            const SizedBox(height: 8),
            _Tappable(
                value: _org,
                placeholder: 'Select Organisation',
                active: editing,
                dimmed: !editing,
                onTap: editing ? _pickOrg : null),
            if (editing && _org == null)
              _err(context.l10n.organisationRequired),
            const SizedBox(height: 14),
            ...List.generate(
                _certs.length,
                (i) => Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
                          if (i > 0)
                            const Column(children: [
                              SizedBox(height: 10),
                              Divider(
                                  color: AppTheme.divider, height: 1),
                              SizedBox(height: 10),
                            ]),
                          Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                _Label('Certificate',
                                    editing: editing),
                                if (editing && _certs.length > 1)
                                  GestureDetector(
                                      onTap: () => setState(() {
                                            _certs.removeAt(i);
                                            _idCtrls[i].dispose();
                                            _idCtrls.removeAt(i);
                                          }),
                                      child: const Icon(Icons.close,
                                          color: AppTheme.error,
                                          size: 18))
                              ]),
                          const SizedBox(height: 8),
                          _Tappable(
                              value: _certs[i]['cert'],
                              placeholder: _org == null
                                  ? 'Select organisation first'
                                  : 'Select Certificate',
                              active: editing && _org != null,
                              dimmed: !editing || _org == null,
                              onTap: (editing && _org != null)
                                  ? () => _pickCert(i)
                                  : null),
                          if (editing &&
                              _org != null &&
                              _certs[i]['cert'] == null)
                            _err(context.l10n.certificateRequired),
                          const SizedBox(height: 14),
                          _Label(_certLabel(i), editing: editing),
                          const SizedBox(height: 8),
                          TextFormField(
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
                                fontSize: AppConstants
                                    .kDefaultSubtitleFontSize),
                            decoration: InputDecoration(
                              hintText: _org == null
                                  ? 'Select organisation first'
                                  : null,
                              hintStyle: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14),
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 15),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppConstants
                                          .kDefaultBorderRadius),
                                  borderSide: BorderSide(
                                      color: certIdEditable
                                          ? AppTheme.textSecondary
                                          : AppTheme.divider,
                                      width: 1.5)),
                              disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppConstants
                                          .kDefaultBorderRadius),
                                  borderSide: const BorderSide(
                                      color: AppTheme.divider,
                                      width: 1.5)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppConstants
                                          .kDefaultBorderRadius),
                                  borderSide: const BorderSide(
                                      color: AppTheme.brand,
                                      width: 2)),
                            ),
                          ),
                          if (certIdEditable &&
                              !RegExp(r'^[a-zA-Z0-9\-/]{3,}$')
                                  .hasMatch(_idCtrls[i].text))
                            _err(context.l10n.certificateIdRequired),
                          const SizedBox(height: 14),
                        ])),
            if (editing && org != null)
              Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: canAddMore
                      ? GestureDetector(
                          onTap: () => setState(() {
                                _certs.add(
                                    {'cert': null, 'certId': ''});
                                _idCtrls.add(TextEditingController()
                                  ..addListener(
                                      () => setState(() {})));
                              }),
                          child: const Row(children: [
                            Icon(Icons.add_circle_outline,
                                color: AppTheme.brand, size: 16),
                            SizedBox(width: 6),
                            Text(
                                'Add another certificate from this organisation',
                                style: TextStyle(
                                    color: AppTheme.brand,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold))
                          ]))
                      : _err(_certs.length >= _maxCertsForOrg
                          ? context.l10n.credentialLimitReached(
                              org,
                              _maxCertsForOrg.toString(),
                            )
                          : context.l10n.allCertificatesInUse)),
            if (editing)
              Row(children: [
                Expanded(
                    child: SolidConfirmButton(
                        label: context.l10n.save
                            .toLowerCase()
                            .replaceFirst(
                                context.l10n.save.toLowerCase()[0],
                                context.l10n.save[0]),
                        height: 40,
                        onPressed: _isValid
                            ? () {
                                final resCerts = List.generate(
                                    _certs.length,
                                    (i) => {
                                          'cert': _certs[i]['cert'],
                                          'certId':
                                              _idCtrls[i].text.trim(),
                                        });
                                widget.onSave({
                                  'org': org,
                                  'certs': resCerts,
                                  '_isEditing': false,
                                });
                              }
                            : null)),
                const SizedBox(width: 12),
                Expanded(
                    child: OutlineActionButton(
                        label: context.l10n.cancel,
                        textColor: AppTheme.textPrimary,
                        borderColor: AppTheme.textSecondary,
                        height: 40,
                        onPressed: widget.onCancel)),
              ])
            else
              Row(children: [
                Expanded(
                    child: OutlineActionButton(
                        label: context.l10n.edit,
                        icon: const Icon(Icons.edit,
                            size: 14, color: AppTheme.brand),
                        height: 40,
                        onPressed: widget.onEdit)),
                const SizedBox(width: 12),
                Expanded(
                    child: OutlineActionButton(
                        label: context.l10n.remove,
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

  Widget _err(String msg) => StandardFormWarningBanner(
        message: msg,
        margin: const EdgeInsets.only(top: 6),
      );
}

// =============================================================================
// SHARED PICKER DIALOG
// =============================================================================
class _PickerDialog extends StatelessWidget {
  final String title;
  final List<String> items;
  final String? selected;
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
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(title,
                style: const TextStyle(
                    color: AppTheme.brand,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ),
          const Divider(color: AppTheme.divider, height: 1),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: items.length,
          separatorBuilder: (_, __) =>
              const Divider(color: AppTheme.divider, height: 1),
          itemBuilder: (ctx, i) {
            final item = items[i];
            final sel = item == selected;
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
                      child: Text(item,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: sel
                                  ? AppTheme.brand
                                  : AppTheme.textPrimary,
                              fontWeight: sel
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: AppConstants
                                  .kDefaultSubtitleFontSize)),
                    ),
                    if (sel)
                      const Icon(Icons.check,
                          color: AppTheme.brand, size: 20),
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
// SHARED LABEL & TAPPABLE WIDGETS
// =============================================================================
class _Label extends StatelessWidget {
  final String text;
  final bool editing;
  const _Label(this.text, {this.editing = true});
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(text,
            style: TextStyle(
                color: editing
                    ? AppTheme.textSecondary
                    : AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold)));
  }
}

class _Tappable extends StatelessWidget {
  final String? value;
  final String placeholder;
  final bool active;
  final bool dimmed;
  final VoidCallback? onTap;

  const _Tappable({
    required this.value,
    required this.placeholder,
    required this.active,
    this.dimmed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = value == null;
    final isEnabled = onTap != null;
    final textColor = isEnabled
        ? (isPlaceholder
            ? AppTheme.textSecondary
            : AppTheme.textPrimary)
        : (isPlaceholder ? Colors.white38 : AppTheme.textSecondary);
    return GestureDetector(
      onTap: isEnabled
          ? () {
              HapticFeedback.lightImpact();
              onTap?.call();
            }
          : null,
      child: Container(
        constraints: const BoxConstraints(
            minHeight: AppConstants.kDefaultButtonHeightLarge),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isEnabled
              ? Colors.transparent
              : Colors.white.withValues(alpha: 0.02),
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          border: Border.all(
            color: active ? AppTheme.brand : Colors.white12,
            width: active ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? placeholder,
                style: TextStyle(
                  color: dimmed ? AppTheme.textSecondary : textColor,
                  fontSize: AppConstants.kDefaultSubtitleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (active)
              const Icon(Icons.arrow_drop_down,
                  color: AppTheme.textSecondary),
          ],
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
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_reset,
                    size: 80, color: AppTheme.brand),
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
                        fontSize:
                            AppConstants.kDefaultSubtitleFontSize,
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
                        fontSize:
                            AppConstants.kDefaultSubtitleFontSize),
                    floatingLabelStyle:
                        WidgetStateTextStyle.resolveWith((s) => TextStyle(
                            color: s.contains(WidgetState.focused)
                                ? AppTheme.brand
                                : AppTheme.textPrimary,
                            fontSize:
                                AppConstants.kDefaultFormTitleFontSize)),
                    prefixIcon: const Icon(CupertinoIcons.mail_solid,
                        size: AppConstants.kDefaultIconSize,
                        color: AppTheme.textSecondary),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 18),
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
                  ),
                ),
                const SizedBox(height: 40),
                SolidConfirmButton(
                    label: context.l10n.sendResetLink,
                    height: AppConstants.kDefaultButtonHeightLarge,
                    onPressed: () {
                      Navigator.pop(context);
                      AppUtils.showToast(
                          context, context.l10n.resetLinkSent);
                    }),
              ]),
        ),
      ),
    );
  }
}
