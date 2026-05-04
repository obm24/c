import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:equatable/equatable.dart';
import '../models/goal_model.dart';

import 'animations/app_motion.dart';
import 'c_ui_theme.dart';
import 'c_constants.dart';
import 'c_core_utils.dart';
import 'c_visual_effects.dart';

// --- Animated Login Button for specific micro-interaction ---
class AnimatedLoginButton extends StatefulWidget {
  final String label;
  final Future<void> Function() onPressed;

  const AnimatedLoginButton(
      {super.key, required this.label, required this.onPressed});

  @override
  State<AnimatedLoginButton> createState() => _AnimatedLoginButtonState();
}

class _AnimatedLoginButtonState extends State<AnimatedLoginButton> {
  bool _isLoading = false;

  void _handlePress() async {
    HapticFeedback.selectionClick();
    setState(() => _isLoading = true);
    await widget.onPressed();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppButtonMotion(
      onTap: _isLoading ? null : _handlePress,
      enabled: !_isLoading,
      haptic: AppMotionHaptic.none,
      pressedScale: 0.985,
      borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
      child: AnimatedContainer(
        duration: AppMotion.duration(context, AppDurations.standard),
        curve: AppCurves.standard,
        height: AppConstants.kDefaultButtonHeightLarge,
        width: _isLoading
            ? AppConstants.kDefaultButtonHeightLarge
            : MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: AppTheme.brand,
            borderRadius: BorderRadius.circular(_isLoading
                ? AppConstants.kDefaultButtonHeightLarge / 2
                : AppConstants.kDefaultBorderRadius),
            boxShadow: [
              if (!_isLoading)
                BoxShadow(
                    color: AppTheme.brand.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
            ]),
        alignment: Alignment.center,
        child: AppAnimatedSwitcher(
          duration: AppDurations.fast,
          child: _isLoading
              ? const SizedBox(
                  key: ValueKey('login-loading'),
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: AppTheme.bg, strokeWidth: 2.5),
                )
              : Row(
                  key: const ValueKey('login-label'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.label,
                      style: const TextStyle(
                          color: AppTheme.bg,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1.2),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded,
                        color: AppTheme.bg, size: 18)
                  ],
                ),
        ),
      ),
    );
  }
}

class DobDropdownWidget extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime) onChanged;

  const DobDropdownWidget(
      {super.key, this.initialDate, required this.onChanged});

  @override
  State<DobDropdownWidget> createState() => _DobDropdownWidgetState();
}

class _DobDropdownWidgetState extends State<DobDropdownWidget> {
  int? _day;
  int? _month;
  int? _year;

  late int _maxYear;
  late int _minYear;

  @override
  void initState() {
    super.initState();
    _maxYear = DateTime.now().year - 16;
    _minYear = DateTime.now().year - 100;

    if (widget.initialDate != null) {
      _day = widget.initialDate!.day;
      _month = widget.initialDate!.month;
      _year = widget.initialDate!.year;
    }
  }

  void _updateDate() {
    if (_month != null && _year != null) {
      int maxDaysInMonth = DateTime(_year!, _month! + 1, 0).day;
      if (_day != null && _day! > maxDaysInMonth) {
        _day = maxDaysInMonth;
      }
    }
    setState(() {});
    if (_day != null && _month != null && _year != null) {
      widget.onChanged(DateTime(_year!, _month!, _day!));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<int> years =
        List.generate(_maxYear - _minYear + 1, (index) => _maxYear - index);
    List<int> months = List.generate(12, (index) => index + 1);

    int maxDays = 31;
    if (_month != null && _year != null) {
      maxDays = DateTime(_year!, _month! + 1, 0).day;
    }
    List<int> days = List.generate(maxDays, (index) => index + 1);

    return Row(
      children: [
        Expanded(
            child: _buildDropdown<int>('Day', _day, days, (val) {
          _day = val;
          _updateDate();
        })),
        const SizedBox(width: 10),
        Expanded(
            child: _buildDropdown<int>('Month', _month, months, (val) {
          _month = val;
          _updateDate();
        })),
        const SizedBox(width: 10),
        Expanded(
            child: _buildDropdown<int>('Year', _year, years, (val) {
          _year = val;
          _updateDate();
        })),
      ],
    );
  }

  Widget _buildDropdown<T>(
      String label, T? value, List<T> items, Function(T?) onChanged) {
    return DropdownButtonFormField<T>(
      alignment: Alignment.center,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: AppConstants.kDefaultSubtitleFontSize),
        floatingLabelStyle: const TextStyle(
            color: AppTheme.brand,
            fontSize: AppConstants.kDefaultFormTitleFontSize),
        floatingLabelAlignment: FloatingLabelAlignment.center,
        floatingLabelBehavior: FloatingLabelBehavior.always,
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
            const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      ),
      dropdownColor: AppTheme.surface,
      icon: const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
      style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: AppConstants.kDefaultSubtitleFontSize),
      initialValue: value,
      hint: Center(
        child: Text(
          label == 'Day'
              ? 'DD'
              : label == 'Month'
                  ? 'MM'
                  : 'YYYY',
          style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: AppConstants.kDefaultSubtitleFontSize),
          textAlign: TextAlign.center,
        ),
      ),
      isExpanded: true,
      isDense: true,
      itemHeight: null,
      items: items
          .map((i) => DropdownMenuItem<T>(
              value: i,
              alignment: Alignment.center,
              child: Text(i.toString().padLeft(label == 'Year' ? 4 : 2, '0'),
                  textAlign: TextAlign.center)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class SolidConfirmButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final Color? bgColor;
  final Color? textColor;

  const SolidConfirmButton(
      {super.key,
      required this.label,
      this.onPressed,
      this.icon,
      this.height = AppConstants.kDefaultButtonHeightMedium,
      this.bgColor,
      this.textColor});

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: TnTPressable(
        enabled: !disabled,
        onTap: onPressed,
        haptic: TnTHaptic.selection,
        borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
        child: AnimatedContainer(
          duration: AppMotion.duration(context, AppDurations.fast),
          curve: AppCurves.entrance,
          height: height,
          decoration: BoxDecoration(
            color:
                disabled ? const Color(0xFF33363B) : bgColor ?? AppTheme.brand,
            borderRadius:
                BorderRadius.circular(AppConstants.kDefaultBorderRadius),
            border: Border.all(
              color: disabled
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.white.withValues(alpha: 0.22),
            ),
            boxShadow: disabled
                ? null
                : [
                    BoxShadow(
                      color:
                          (bgColor ?? AppTheme.brand).withValues(alpha: 0.16),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(icon,
                        size: 20,
                        color: disabled
                            ? const Color(0xFF888888)
                            : (textColor ?? AppTheme.confirmationButtonText))),
              Flexible(
                child: AutoSizeText(
                  label,
                  maxLines: 1,
                  minFontSize: 8,
                  style: TextStyle(
                    color: disabled
                        ? const Color(0xFF888888)
                        : (textColor ?? AppTheme.confirmationButtonText),
                    fontSize: height >= AppConstants.kDefaultButtonHeightLarge
                        ? AppConstants.kDefaultButtonTextSizeLarge
                        : AppConstants.kDefaultButtonTextSizeMedium,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OutlineActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final double height;
  final Color? borderColor;
  final Color? textColor;

  const OutlineActionButton(
      {super.key,
      required this.label,
      this.onPressed,
      this.icon,
      this.height = AppConstants.kDefaultButtonHeightMedium,
      this.borderColor,
      this.textColor});

  @override
  Widget build(BuildContext context) {
    Color bColor = borderColor ?? AppTheme.brand;
    Color tColor = textColor ?? AppTheme.brand;

    return TnTPressable(
      enabled: onPressed != null,
      onTap: onPressed,
      haptic: TnTHaptic.light,
      borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
      child: AnimatedContainer(
        duration: AppMotion.duration(context, AppDurations.fast),
        curve: AppCurves.entrance,
        height: height,
        decoration: BoxDecoration(
          color: onPressed == null
              ? AppTheme.surfaceLow.withValues(alpha: 0.55)
              : bColor.withValues(alpha: 0.045),
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          border: Border.all(
            color: onPressed == null
                ? AppTheme.outlineSoft
                : bColor.withValues(alpha: 0.72),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Padding(padding: const EdgeInsets.only(right: 8.0), child: icon!),
            Flexible(
                child: AutoSizeText(label,
                    maxLines: 1,
                    minFontSize: 8,
                    style: TextStyle(
                        color:
                            onPressed == null ? AppTheme.textSecondary : tColor,
                        fontSize: AppConstants.kDefaultButtonTextSizeMedium,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2))),
          ],
        ),
      ),
    );
  }
}

class DualToggleSwitch extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final bool isLeftSelected;
  final bool selectionMade;
  final Function(bool) onSelected;

  const DualToggleSwitch(
      {super.key,
      required this.leftLabel,
      required this.rightLabel,
      required this.isLeftSelected,
      this.selectionMade = true,
      required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final bool leftSelected = selectionMade && isLeftSelected;
    final bool rightSelected = selectionMade && !isLeftSelected;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: AppTheme.surfaceLow,
            borderRadius:
                BorderRadius.circular(AppConstants.kDefaultBorderRadius),
            border: Border.all(color: AppTheme.outlineSoft)),
        child: Row(
          children: [
            Expanded(
              child: TnTPressable(
                onTap: () {
                  onSelected(true);
                },
                borderRadius:
                    BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                child: AppSelectionMotion(
                  selected: leftSelected,
                  child: AnimatedContainer(
                    duration: AppMotion.duration(context, AppDurations.fast),
                    curve: AppCurves.entrance,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                        color:
                            leftSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(
                            AppConstants.kDefaultBorderRadius),
                        border: Border.all(
                            color: leftSelected
                                ? AppTheme.brand
                                : Colors.transparent)),
                    alignment: Alignment.center,
                    child: Text(leftLabel,
                        style: TextStyle(
                            color: leftSelected
                                ? AppTheme.buttonText
                                : AppTheme.textSecondary,
                            fontWeight: leftSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: TnTPressable(
                onTap: () {
                  onSelected(false);
                },
                borderRadius:
                    BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                child: AppSelectionMotion(
                  selected: rightSelected,
                  child: AnimatedContainer(
                    duration: AppMotion.duration(context, AppDurations.fast),
                    curve: AppCurves.entrance,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                        color:
                            rightSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(
                            AppConstants.kDefaultBorderRadius),
                        border: Border.all(
                            color: rightSelected
                                ? AppTheme.brand
                                : Colors.transparent)),
                    alignment: Alignment.center,
                    child: Text(rightLabel,
                        style: TextStyle(
                            color: rightSelected
                                ? AppTheme.buttonText
                                : AppTheme.textSecondary,
                            fontWeight: rightSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GenderToggleSwitch extends StatelessWidget {
  final String selectedGender;
  final Function(String) onSelected;

  const GenderToggleSwitch(
      {super.key, required this.selectedGender, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    bool isMale = selectedGender == 'Male';
    bool isFemale = selectedGender == 'Female';

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: AppTheme.surfaceLow,
            borderRadius:
                BorderRadius.circular(AppConstants.kDefaultBorderRadius),
            border: Border.all(color: AppTheme.outlineSoft)),
        child: Row(
          children: [
            Expanded(
              child: TnTPressable(
                onTap: () {
                  onSelected('Male');
                },
                borderRadius:
                    BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                child: AppSelectionMotion(
                  selected: isMale,
                  child: AnimatedContainer(
                    duration: AppMotion.duration(context, AppDurations.fast),
                    curve: AppCurves.entrance,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 12),
                    decoration: BoxDecoration(
                        color: isMale ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(
                            AppConstants.kDefaultBorderRadius)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(context.l10n.male,
                            style: TextStyle(
                                color: isMale
                                    ? AppTheme.buttonText
                                    : AppTheme.textSecondary,
                                fontWeight: isMale
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize:
                                    AppConstants.kDefaultSubtitleFontSize)),
                        const SizedBox(width: 8),
                        Icon(Icons.male,
                            size: 20,
                            color: isMale
                                ? AppTheme.buttonText
                                : AppTheme.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: TnTPressable(
                onTap: () {
                  onSelected('Female');
                },
                borderRadius:
                    BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                child: AppSelectionMotion(
                  selected: isFemale,
                  child: AnimatedContainer(
                    duration: AppMotion.duration(context, AppDurations.fast),
                    curve: AppCurves.entrance,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 12),
                    decoration: BoxDecoration(
                        color: isFemale ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(
                            AppConstants.kDefaultBorderRadius)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(context.l10n.female,
                            style: TextStyle(
                                color: isFemale
                                    ? AppTheme.buttonText
                                    : AppTheme.textSecondary,
                                fontWeight: isFemale
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize:
                                    AppConstants.kDefaultSubtitleFontSize)),
                        const SizedBox(width: 8),
                        Icon(Icons.female,
                            size: 20,
                            color: isFemale
                                ? AppTheme.buttonText
                                : AppTheme.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MedicalData {
  static final List<String> commonInjuries = [
    'Achilles Tendinopathy',
    'ACL Sprain/Tear',
    'Acromioclavicular (AC) Joint Sprain',
    'Bone-Tendon Avulsions',
    'Bunions',
    'Calcified Ligaments',
    'Calf Strain',
    'Carpal Tunnel Syndrome',
    'Cervical Radiculopathy (Pinched Nerve)',
    'Cervical Spondylosis',
    'Delayed Onset Muscle Soreness (DOMS)',
    'Femoroacetabular Impingement (FAI)',
    'Groin Strain',
    'Herniated Disc (Slipped Disc)',
    'High Ankle Sprain',
    'Hip Labral Tear',
    'Hip Pointer',
    'Inversion Ankle Sprain',
    'IT Band Syndrome',
    'Lateral Epicondylopathy (Tennis Elbow)',
    'LCL Sprain/Tear',
    'Ligament Sprains',
    'MCL Sprain/Tear',
    'Medial Epicondylopathy (Golfer\'s Elbow)',
    'Meniscus Tear',
    'Midfoot Arthritis (Degeneration)',
    'Muscle Strains (Pulled Muscles)',
    'Olecranon Bursitis',
    'Patellar Tendinopathy (Jumper\'s Knee)',
    'PCL Sprain/Tear',
    'Pelvic Floor Dysfunction',
    'Plantar Fasciitis (Degeneration)',
    'Rotator Cuff Tear',
    'Runner\'s Knee (Patellofemoral Pain Syndrome)',
    'Sacroiliac (SI) Joint Pain',
    'Scaphoid Fracture',
    'Scoliosis',
    'Shin Splints',
    'Shoulder Dislocation',
    'Shoulder Impingement',
    'Skier\'s Thumb (UCL Sprain of the Thumb)',
    'SLAP Tears (Labral Tears)',
    'Tendon Rupture',
    'Total Hip Replacement (Arthroplasty)',
    'Total Knee Replacement (Arthroplasty)',
    'Turf Toe (Sprain)',
    'Ulnar Collateral Ligament (UCL) Sprain',
    'Vertebral Fractures',
    'Work-Related Overuse Injuries',
    'Wrist Sprain'
  ];
  static final List<String> commonConditions = [
    'Active Endocarditis',
    'Acute Aortic Dissection',
    'Acute Myocardial Infarction (within 2 days)',
    'Acute Myocarditis',
    'Acute Pericarditis',
    'Alzheimer\'s Disease',
    'Anemia',
    'Angina',
    'Anxiety Disorders',
    'Aortic Stenosis',
    'Asthma',
    'Cardiac Arrhythmias',
    'Celiac Disease',
    'Chronic Kidney Disease (CKD)',
    'Chronic Obstructive Pulmonary Disease (COPD)',
    'Coronary Artery Disease (CAD)',
    'Decompensated Heart Failure',
    'Deep Vein Thrombosis (DVT)',
    'Depression (Major Depressive Disorder)',
    'Diabetes Mellitus',
    'Diastasis Recti Abdominis',
    'Endometriosis',
    'Epilepsy and Seizure Disorders',
    'GERD (Gastroesophageal Reflux Disease)',
    'Gout',
    'Growth Hormone Deficiency',
    'Hernia',
    'Hypertension (High Blood Pressure)',
    'Hyperthyroidism',
    'Hypertrophic Obstructive Cardiomyopathy',
    'Hypopituitarism',
    'Hypothyroidism',
    'Kidney Stones',
    'Migraine',
    'Multiple Sclerosis (MS)',
    'Obesity',
    'Obstructive Left Main Coronary Artery Stenosis',
    'Osteoarthritis',
    'Osteopenia',
    'Osteoporosis',
    'Parasympathetic Overtraining Syndrome',
    'Parkinson\'s Disease',
    'Pelvic Organ Prolapse',
    'Peripheral Artery Disease (PAD)',
    'Peripheral Neuropathy',
    'Primary Adrenal Insufficiency (Addison\'s Disease)',
    'Raynaud\'s Disease',
    'Relative Energy Deficiency in Sport (RED-S)',
    'Rheumatoid Arthritis (RA)',
    'Shingles (Herpes Zoster)',
    'Sleep Apnea',
    'Spinal Stenosis',
    'Spondylolisthesis',
    'Spondylolysis',
    'Stroke',
    'Sympathetic Overtraining Syndrome',
    'Urinary Incontinence (Stress Incontinence)'
  ];
  static final List<String> goals = [
    'Weight Loss',
    'Fat Loss',
    'Muscle Gain',
    'Endurance',
    'Flexibility',
    'Strength Training',
    'General Health & Fitness'
  ];

  static List<GoalCategory> getCategorizedGoals(BuildContext context) {
    final l = context.l10n;
    return [
      GoalCategory(
        id: 'cat_strength',
        name: l.catStrength,
        items: [
          GoalItem(
              id: 'goal_bodybuilding',
              categoryId: 'cat_strength',
              title: l.goalBodybuildingTitle,
              description: l.goalBodybuildingDesc),
          GoalItem(
              id: 'goal_powerlifting',
              categoryId: 'cat_strength',
              title: l.goalPowerliftingTitle,
              description: l.goalPowerliftingDesc),
          GoalItem(
              id: 'goal_olympic',
              categoryId: 'cat_strength',
              title: l.goalOlympicTitle,
              description: l.goalOlympicDesc),
          GoalItem(
              id: 'goal_strongman',
              categoryId: 'cat_strength',
              title: l.goalStrongmanTitle,
              description: l.goalStrongmanDesc),
        ],
      ),
      GoalCategory(
        id: 'cat_athletic',
        name: l.catAthletic,
        items: [
          GoalItem(
              id: 'goal_sports',
              categoryId: 'cat_athletic',
              title: l.goalSportsTitle,
              description: l.goalSportsDesc),
          GoalItem(
              id: 'goal_functional',
              categoryId: 'cat_athletic',
              title: l.goalFunctionalTitle,
              description: l.goalFunctionalDesc),
          GoalItem(
              id: 'goal_callisthenics',
              categoryId: 'cat_athletic',
              title: l.goalCallisthenicsTitle,
              description: l.goalCallisthenicsDesc),
          GoalItem(
              id: 'goal_combat',
              categoryId: 'cat_athletic',
              title: l.goalCombatTitle,
              description: l.goalCombatDesc),
        ],
      ),
      GoalCategory(
        id: 'cat_recovery',
        name: l.catRecovery,
        items: [
          GoalItem(
              id: 'goal_corrective',
              categoryId: 'cat_recovery',
              title: l.goalCorrectiveTitle,
              description: l.goalCorrectiveDesc),
          GoalItem(
              id: 'goal_rehabilitation',
              categoryId: 'cat_recovery',
              title: l.goalRehabilitationTitle,
              description: l.goalRehabilitationDesc),
          GoalItem(
              id: 'goal_mobility',
              categoryId: 'cat_recovery',
              title: l.goalMobilityTitle,
              description: l.goalMobilityDesc),
        ],
      ),
      GoalCategory(
        id: 'cat_cardio',
        name: l.catCardio,
        items: [
          GoalItem(
              id: 'goal_hiit',
              categoryId: 'cat_cardio',
              title: l.goalHiitTitle,
              description: l.goalHiitDesc),
          GoalItem(
              id: 'goal_endurance',
              categoryId: 'cat_cardio',
              title: l.goalEnduranceTitle,
              description: l.goalEnduranceDesc),
        ],
      ),
      GoalCategory(
        id: 'cat_mindbody',
        name: l.catMindbody,
        items: [
          GoalItem(
              id: 'goal_yoga',
              categoryId: 'cat_mindbody',
              title: l.goalYogaTitle,
              description: l.goalYogaDesc),
          GoalItem(
              id: 'goal_pilates',
              categoryId: 'cat_mindbody',
              title: l.goalPilatesTitle,
              description: l.goalPilatesDesc),
        ],
      ),
      GoalCategory(
        id: 'cat_specialised',
        name: l.catSpecialised,
        items: [
          GoalItem(
              id: 'goal_prenatal',
              categoryId: 'cat_specialised',
              title: l.goalPrenatalTitle,
              description: l.goalPrenatalDesc),
          GoalItem(
              id: 'goal_senior',
              categoryId: 'cat_specialised',
              title: l.goalSeniorTitle,
              description: l.goalSeniorDesc),
          GoalItem(
              id: 'goal_youth',
              categoryId: 'cat_specialised',
              title: l.goalYouthTitle,
              description: l.goalYouthDesc),
        ],
      ),
    ];
  }

  static final List<String> trainerSpecialties = [
    'Muscle Gain',
    'Weight Loss',
    'Flexibility',
    'Cross-Training',
    'Fat Loss',
    'Endurance',
    'Rehabilitation',
    'Pre/Post Natal',
    'Performance'
  ];

  static Map<String, String> getDescriptions(BuildContext context) {
    final l = context.l10n;

    final Map<String, String> extraDesc = {
      'Weight Loss':
          'A structured approach to reducing overall body mass through a calculated caloric deficit. Combines metabolic conditioning, steady-state cardio, and resistance training to preserve lean tissue while safely and consistently shedding pounds.',
      'Fat Loss':
          'An evidence-based, scientifically-backed approach strictly focused on lipolysis and reducing body fat percentage. Emphasizes metabolic rate optimization, advanced nutrient partitioning, and high-intensity energy system development to target stubborn adiposity.',
      'Muscle Gain':
          'A comprehensive program aimed at maximizing muscle hypertrophy and absolute strength. Focuses heavily on progressive overload principles, optimal recovery windows, and precise macronutrient timing to ensure sustained anabolism and muscle fiber recruitment.',
      'Endurance':
          'Specialized programming to dramatically enhance cardiovascular efficiency, VO2 max, and muscular stamina. Ideal for distance runners, cyclists, and triathletes seeking to delay the onset of fatigue and improve prolonged performance.',
      'Flexibility':
          'Targeted protocols designed to increase joint range of motion, enhance tissue elasticity, and correct postural imbalances. Utilizes dynamic stretching, PNF techniques, and myofascial release to improve daily mobility and prevent athletic injuries.',
      'Strength Training':
          'Focuses strictly on maximizing raw physical force and power output via compound, multi-joint lifts like squats, deadlifts, and presses. Involves low-rep, high-load neurological adaptations for serious athletes.',
      'General Health & Fitness':
          'A balanced, highly sustainable approach aimed at maintaining an active lifestyle. Perfect for individuals looking to boost overall mood, improve immune function, and stay functionally fit for daily activities.',
      'Cross-Training':
          'A versatile training modality that blends elements from diverse disciplines—such as weightlifting, gymnastics, and high-intensity interval training (HIIT). Designed to build a well-rounded athlete capable of handling unpredictable physical demands.',
      'Rehabilitation':
          'A careful, phased recovery protocol designed for post-injury recuperation. Works alongside physical therapy guidelines to safely restore fundamental movement patterns, rebuild baseline strength, and overcome muscular compensations.',
      'Pre/Post Natal':
          'Expertly crafted, low-impact exercise routines tailored for the physiological changes during and after pregnancy. Focuses on core stabilization, pelvic floor health, and postural support to maintain maternal fitness without risking fetal development.',
      'Performance':
          'Focused on improving athletic capabilities, power output, speed, and agility for sports-specific or functional goals.',

      // Thorough FNDDS Medical Injury Descriptions
      // Thorough FNDDS Medical Injury Descriptions
      'Rotator Cuff Tear':
          'A tear in the tissues connecting muscle to bone around the shoulder joint. Often caused by repetitive overhead motions or acute trauma. Recovery focuses on reducing inflammation, restoring range of motion, and progressively strengthening the supraspinatus, infraspinatus, teres minor, and subscapularis.',
      'Acromioclavicular (AC) Joint Sprain':
          'An injury to the ligament that holds the collarbone to the shoulder blade. Typical mechanisms include direct falls on the tip of the shoulder. Rehabilitation involves immobilization followed by gradual mobility and scapular stabilization exercises.',
      'Shoulder Dislocation':
          'Occurs when the head of the humerus is forced out of the shoulder socket, causing profound ligamentous laxity. Requires immediate reduction and subsequent intensive strengthening of the surrounding musculature to prevent chronic instability.',
      'Shoulder Impingement':
          'A condition where the rotator cuff tendons are intermittently trapped and compressed during shoulder movements. Causes significant pain. Focuses on postural correction, posterior chain strengthening, and improving subacromial space dynamics.',
      'Ulnar Collateral Ligament (UCL) Sprain':
          'An injury to the primary stabilizing ligament on the inner side of the elbow, highly common in throwing athletes. Recovery necessitates strict rest periods, progressive load management, and kinetic chain sequencing.',
      'Lateral Epicondylopathy (Tennis Elbow)':
          'Commonly known as tennis elbow. It is an overuse injury causing micro-tears in the forearm tendons at the elbow. Managed via eccentric loading protocols, tissue friction therapies, and grip modification.',
      'Medial Epicondylopathy (Golfer\'s Elbow)':
          'Commonly known as golfer\'s elbow. It is an overuse injury causing micro-tears in the forearm tendons at the elbow. Managed via eccentric loading protocols, tissue friction therapies, and grip modification.',
      'Olecranon Bursitis':
          'Inflammation of the fluid-filled sac at the tip of the elbow, often resulting from direct trauma or prolonged pressure. Treatment prioritizes compression, joint protection, and maintaining pain-free range of motion.',
      'Wrist Sprain':
          'Damage to the ligaments connecting the carpal bones, resulting from forced hyperextension (like breaking a fall). Recovery protocols dictate structured splinting followed by proprioceptive and isometric stability exercises.',
      'Carpal Tunnel Syndrome':
          'A painful neuropathy caused by the compression of the median nerve as it travels through the wrist. Training adaptations require neutral-wrist loading patterns, avoiding extreme extension, and targeted nerve gliding.',
      'Groin Strain':
          'A muscular tear or profound stretch of the adductor muscles in the inner thigh. Recovery involves strict avoidance of explosive lateral movements, utilizing isometric adductor holds, and careful return-to-play timelines.',
      'Hip Labral Tear':
          'Damage to the ring of cartilage that follows the outside rim of the hip joint socket. Often causes catching or clicking sensations. Requires deep core engagement, pelvic floor training, and avoidance of deep hip flexion.',
      'ACL Sprain/Tear':
          'Tearing the main stabilizing ligament in the center of the knee, often marked by a loud "pop." Post-surgical or conservative management revolves around restoring quadriceps/hamstring ratios, closed-kinetic chain exercises, and plyometric progressions.',
      'PCL Sprain/Tear':
          'Severe trauma to the major stabilizing ligaments inside the knee joint. Post-surgical or conservative management revolves around restoring quadriceps/hamstring ratios, closed-kinetic chain exercises, and plyometric progressions.',
      'Meniscus Tear':
          'Fraying and tearing of the shock-absorbing cartilage in the knee due to aging and wear, or an acute twisting motion. Non-surgical recovery focuses on joint un-loading, hamstring flexibility, and strictly controlled knee flexion parameters.',
      'Patellar Tendinopathy (Jumper\'s Knee)':
          'Chronic inflammation and micro-tearing of the tendon connecting the kneecap to the shinbone. Effectively managed using heavy, slow resistance (HSR) training and decline eccentric squatting protocols.',
      'Calf Strain':
          'A tear in the gastrocnemius or soleus muscles at the back of the lower leg. Recovery requires gradual eccentric heel drops, fascial release, and progressive return to explosive concentric loading.',
      'Achilles Tendinopathy':
          'A chronic, degenerative condition or acute inflammation affecting the Achilles tendon. Treatment strictly utilizes the Alfredson protocol (heavy eccentric loading) and addresses ankle dorsiflexion deficits.',
      'Shin Splints':
          'Medial tibial stress syndrome causing pain along the inner edge of the shinbone. Directly related to sudden spikes in training volume. Recovery necessitates load reduction, orthotic evaluation, and tibialis anterior strengthening.',
      'Inversion Ankle Sprain':
          'Damage to the lateral ligaments of the ankle caused by rolling the foot inward. Rehabilitation focuses intensely on proprioceptive balance training (BOSU/wobble boards) and peroneal muscle strengthening.',
      'High Ankle Sprain':
          'A complex sprain of the syndesmotic ligaments connecting the tibia and fibula. Requires significantly longer healing timelines than standard sprains, utilizing rigid immobilization and carefully phased weight-bearing.',
      'Plantar Fasciitis (Degeneration)':
          'Degenerative irritation of the thick band of tissue spanning the bottom of the foot. Best managed through aggressive calf stretching, deep tissue massage of the foot arch, and correcting over-pronation.',
      'Bone-Tendon Avulsions':
          'A severe injury where a tearing tendon rips a small chunk of bone away with it.',
      'Bunions':
          'A painful bony bump that forms on the joint at the base of the big toe.',
      'Calcified Ligaments':
          'A condition where calcium builds up inside a ligament, making it stiff and prone to pinching.',
      'Cervical Radiculopathy (Pinched Nerve)':
          'A squeezed nerve in the neck, often made worse by slouching. It causes sharp pain, numbness, or weakness that shoots down the arm.',
      'Cervical Spondylosis':
          'General wear-and-tear or aging of the bones in the neck.',
      'Delayed Onset Muscle Soreness (DOMS)':
          'The deep muscle ache and stiffness you feel a day or two after a tough workout.',
      'Femoroacetabular Impingement (FAI)':
          'Extra bone growth in the hip joint that causes the bones to pinch or rub together abnormally.',
      'IT Band Syndrome':
          'Painful friction on the outside of the knee caused by tightness in the thick band of tissue running down the outer thigh.',
      'Ligament Sprains':
          'Stretching or tearing the tissue that connects bones to each other. This ranges from a mild stretch to a complete tear that makes the joint feel unstable.',
      'Herniated Disc (Slipped Disc)':
          'When the jelly-like center of a spinal disc pushes out through a crack in its outer shell, pressing on a nerve and causing intense lower back and leg pain.',
      'Muscle Strains (Pulled Muscles)':
          'Stretching or tearing a muscle or the tendon connecting it to the bone.',
      'Osteoarthritis':
          'General "wear-and-tear" arthritis where the protective cartilage on the ends of bones wears down over time.',
      'Osteopenia':
          'A condition where bones lose density, becoming brittle and prone to breaking. A precursor to osteoporosis.',
      'Osteoporosis':
          'A condition where bones lose density, becoming highly brittle and prone to breaking (especially in the spine when bending forward).',
      'Pelvic Floor Dysfunction':
          'Weakness or strain on the hammock-like muscles at the bottom of the pelvis, causing pain or bladder leakage (often triggered by heavy lifting).',
      'Rheumatoid Arthritis (RA)':
          'An autoimmune disease where the body mistakenly attacks its own joint linings, causing severe swelling and pain.',
      'Runner\'s Knee (Patellofemoral Pain Syndrome)':
          'Pain at the front of the knee caused by the kneecap not gliding smoothly in its groove.',
      'Sacroiliac (SI) Joint Pain':
          'Pain in the joints connecting the base of the spine to the pelvis, felt in the lower back or glutes.',
      'Scoliosis':
          'A sideways curve and twisting of the spine that creates tight, imbalanced back muscles.',
      'SLAP Tears (Labral Tears)':
          'A tear in the ring of cartilage that suctions the shoulder joint into place.',
      'Spondylolysis':
          'A stress fracture in a lower back bone that can cause structural instability.',
      'Spondylolisthesis':
          'The anterior slippage of one vertebra over the adjacent inferior vertebra, causing structural instability and nerve compression. It is strictly exacerbated by spinal extension.',
      'Tendon Rupture':
          'A severe, complete tear or snap of the thick cords that attach muscle to bone.',
      'Total Hip Replacement (Arthroplasty)':
          'Having an artificial hip joint, which permanently requires avoiding certain extreme leg movements to prevent the joint from popping out.',
      'Total Knee Replacement (Arthroplasty)':
          'Having an artificial knee, requiring the permanent avoidance of high-impact activities (like running or jumping) to keep the parts from breaking.',
      'Vertebral Fractures': 'Broken bones in the spine.',
      'Work-Related Overuse Injuries':
          'Conditions like Carpal Tunnel Syndrome or tendonitis caused by repeating the same motions over and over.',
      'Active Endocarditis':
          'Infections or inflammations of the heart\'s inner lining.',
      'Acute Myocarditis': 'Inflammation of the heart muscle.',
      'Acute Pericarditis': 'Inflammation of the heart\'s surrounding sac.',
      'Acute Aortic Dissection':
          'A tear in the inner layer of the large blood vessel branching off the heart (aorta).',
      'Acute Myocardial Infarction (within 2 days)':
          'A heart attack; an absolute contraindication to exercise.',
      'Aortic Stenosis':
          'Narrowing of the heart\'s aortic valve. Severe, symptomatic cases are an absolute contraindication, while moderate-to-severe cases are a relative contraindication.',
      'Cardiac Arrhythmias':
          'Irregular heartbeats. If uncontrolled and causing hemodynamic compromise, they are an absolute contraindication. Tachyarrhythmias with uncontrolled ventricular rates are a relative contraindication.',
      'Decompensated Heart Failure':
          'A sudden worsening of heart failure symptoms.',
      'Diastasis Recti Abdominis':
          'The separation of the rectus abdominis muscles along the connective tissue of the midline (linea alba) following pregnancy.',
      'Epilepsy and Seizure Disorders':
          'Neurological conditions causing uncontrolled seizures, necessitating strict environmental safety protocols (e.g., avoiding motorised treadmills or heavy free weights without a spotter).',
      'Hypertrophic Obstructive Cardiomyopathy':
          'A congenital structural anomaly where the heart muscle is thickened, severely restricting blood flow.',
      'Hypopituitarism':
          'A condition where the pituitary gland fails to synthesise adequate hormones.',
      'Growth Hormone Deficiency':
          'A hormonal deficiency impairing muscle recovery, altering body composition, reducing bone density, and causing excessive thirst.',
      'Multiple Sclerosis (MS)':
          'A chronic, inflammatory, neurodegenerative autoimmune disease that destroys neural myelin sheaths. It causes severe fatigue, spasticity, profound numbness, intense vertigo, and extreme heat intolerance.',
      'Obstructive Left Main Coronary Artery Stenosis':
          'Narrowing of the primary artery supplying blood to the heart.',
      'Parasympathetic Overtraining Syndrome':
          'The late stage of overtraining, clinically marked by profound exhaustion, clinical depression, a loss of motivation, and an abnormally low resting heart rate (bradycardia).',
      'Parkinson\'s Disease':
          'A disease that fundamentally alters motor control pathways, presenting with resting tremors, bradykinesia (slowed movement), muscular rigidity, and severe postural instability.',
      'Pelvic Organ Prolapse':
          'The descent of the bladder, uterus, or rectum into the vaginal canal due to ligamentous laxity, presenting as pelvic heaviness or pressure.',
      'Primary Adrenal Insufficiency (Addison\'s Disease)':
          'The destruction of the adrenal cortex, rendering the body unable to naturally produce cortisol and aldosterone to mount a defence against physiological stress. Exercise can trigger a lethal "adrenal crisis."',
      'Relative Energy Deficiency in Sport (RED-S)':
          'A multi-system physiological impairment stemming from a severe mismatch between dietary energy intake and exercise energy expenditure, leading to diminished reproductive health, decreased bone strength, and cardiovascular abnormalities.',
      'Spinal Stenosis':
          'The progressive narrowing of the spinal canal, leading to nerve compression and neurogenic claudication (radiating leg pain/weakness during walking). It is exacerbated by spinal extension.',
      'Sympathetic Overtraining Syndrome':
          'The early stage of overtraining, marked by an overactive "fight or flight" system, tachycardia, hypertension, insomnia, and heavy soreness.',
      'Urinary Incontinence (Stress Incontinence)':
          'The leaking of urine during sneezing, jumping, or lifting, indicating a failure of the pelvic floor musculature to withstand intra-abdominal pressure.',
    };

    final Map<String, String> existingMap = {
      'Skier\'s Thumb (UCL Sprain of the Thumb)': l.descSkiersThumb,
      'Scaphoid Fracture': l.descScaphoidFracture,
      'Hip Pointer': l.descHipPointer,
      'MCL Sprain/Tear': l.descCollateralLigament,
      'LCL Sprain/Tear': l.descCollateralLigament,
      'Turf Toe (Sprain)': l.descTurfToe,
      'Midfoot Arthritis (Degeneration)': l.descMidfootArthritis,
      'Alzheimer\'s Disease': l.descAlzheimers,
      'Anemia': l.descAnemia,
      'Angina': l.descAngina,
      'Anxiety Disorders': l.descAnxietyDisorders,
      'Asthma': l.descAsthma,
      'Celiac Disease': l.descCeliacDisease,
      'Chronic Kidney Disease (CKD)': l.descChronicKidneyDisease,
      'Chronic Obstructive Pulmonary Disease (COPD)': l.descCOPD,
      'Coronary Artery Disease (CAD)': l.descCoronaryArteryDisease,
      'Deep Vein Thrombosis (DVT)': l.descDVT,
      'Depression (Major Depressive Disorder)': l.descDepression,
      'Diabetes Mellitus': l.descDiabetesMellitus,
      'Endometriosis': l.descEndometriosis,
      'GERD (Gastroesophageal Reflux Disease)': l.descGERD,
      'Gout': l.descGout,
      'Hernia': l.descHernia,
      'Hypertension (High Blood Pressure)': l.descHypertension,
      'Hyperthyroidism': l.descHyperthyroidism,
      'Hypothyroidism': l.descHypothyroidism,
      'Kidney Stones': l.descKidneyStones,
      'Migraine': l.descMigraine,
      'Obesity': l.descObesity,
      'Osteoarthritis': l.descOsteoarthritis,
      'Osteoporosis': l.descOsteoporosis,
      'Peripheral Artery Disease (PAD)': l.descPAD,
      'Peripheral Neuropathy': l.descPeripheralNeuropathy,
      'Raynaud\'s Disease': l.descRaynaudsDisease,
      'Rheumatoid Arthritis (RA)': l.descRheumatoidArthritis,
      'Shingles (Herpes Zoster)': l.descShingles,
      'Sleep Apnea': l.descSleepApnea,
      'Stroke': l.descStroke,
    };

    return {...existingMap, ...extraDesc};
  }

  // --- TRAINER CERTIFICATION DATA (Alphabetically Sorted Keys & Values) ---
  static const Map<String, List<String>> kTrainerCertifications = {
    'Academy of Applied Personal Training Education (AAPTE)': [
      'Academy of Applied Personal Training Education Certified Personal Trainer (AAPTE-CPT)',
    ],
    'ACTION Certification': [
      'ACTION Certified Group Fitness Instructor (ACTION-CGFI)',
      'ACTION Certified Nutrition Specialist (ACTION-CNS)',
      'ACTION Certified Personal Trainer (ACTION-CPT)',
    ],
    'American College of Sports Medicine (ACSM)': [
      'ACSM Certified Professional Trainer (ACSM-CPT)',
      'ACSM Certified Group Exercise Instructor (ACSM-GEI)',
      'ACSM Certified Exercise Physiologist (ACSM-EP)',
      'ACSM Certified Clinical Exercise Physiologist (ACSM-CEP)',
      'ARP/ACSM Certified Ringside Physician (ACSM-CRP)',
      'ACSM/NCHPAD Certified Inclusive Fitness Trainer (ACSM-CIFT)',
      'ACSM/ACS Certified Cancer Exercise Trainer (ACSM-CET)',
      'Physical Activity in Public Health Specialist (ACSM-PAPHS)',
      'Exercise is Medicine Credential (ACSM-EIM)',
      'Registered Clinical Exercise Physiologist (ACSM-RCEP)',
      'Autism Exercise Specialist Certificate (ACSM-AES)',
    ],
    'American Council on Exercise (ACE)': [
      'ACE Personal Trainer (ACE-CPT)',
      'ACE Group Fitness Instructor (ACE-GFI)',
      'ACE Health Coach (ACE-HC)',
      'ACE Medical Exercise Specialist (ACE-CMES)',
      'ACE Fitness Nutrition Specialist (ACE-FNS)',
      'ACE Senior Fitness Specialist (ACE-SFS)',
      'ACE Corrective Exercise Specialist (ACE-CES)',
      'ACE Weight Management Specialist (ACE-WMS)',
      'ACE Functional Training Specialist (ACE-FTS)',
      'ACE Behavior Change Specialist (ACE-BCS)',
      'ACE Sports Performance Specialist (ACE-SPS)',
      'ACE Youth Fitness Specialist (ACE-YFS)',
    ],
    'Collegiate Strength & Conditioning Coaches association (CSCCa)': [
      'Strength and Conditioning Coach Certified (SCCC)',
      'Master Strength & Conditioning Coach (MSCC)',
    ],
    'Fitness Mentors': [
      'Certified Personal Trainer (FM-CPT)',
    ],
    'International Fitness Professionals Association (IFPA)': [
      'Personal Fitness Trainer (IFPA-PFT)',
      'Sports Nutrition Specialist (IFPA-SNS)',
      'Sports Medicine Specialist (IFPA-SMS)',
      'Sports Conditioning Specialist (IFPA-SCS)',
      'Kettlebell Training Specialist (IFPA-KTS)',
      'Kinesiology Specialist (IFPA-KS)',
      'Group Fitness Certification - Advanced (IFPA-GFCA)',
    ],
    'International Personal Trainer Academy (IPTA)': [
      'Certified Personal Trainer (IPTA-CPT)',
      'Certified Nutrition Specialist (IPTA-CNS)',
      'Certified Bodybuilding Specialist (IPTA-CBS)',
    ],
    'International Sports Sciences Association (ISSA)': [
      'Certified Personal Trainer (ISSA-CPT)',
      'Fitness Coach (ISSA-FC)',
      'Elite Trainer (ISSA-ET)',
      'Master Trainer (ISSA-MT)',
      'Bodybuilding Specialist (ISSA-CBS)',
      'Certified Nutrition Coach (ISSA-CNC)',
    ],
    'National Academy of Sports Medicine (NASM)': [
      'Certified Personal Trainer (NASM-CPT)',
      'Performance Enhancement Specialist (NASM-PES)',
      'Corrective Exercise Specialist (NASM-CES)',
      'Certified Nutrition Coach (NASM-CNC)',
      'Weight Loss Specialist (NASM-WLS)',
      'Youth Exercise Specialist (NASM-YES)',
      'Women\'s Fitness Specialist (NASM-WFS)',
      'Mixed Martial Arts Specialist (NASM-MMAS)',
      'Golf Fitness Specialist (NASM-GFS)',
      'Senior Fitness Specialist (NASM-SFS)',
      'AFAA Certified Group Fitness Instructor (AFAA-CGFI)',
    ],
    'National Council for Certified Personal Trainers (NCCPT)': [
      'Certified Personal Trainer (NCCPT-CPT)',
      'Certified Group Exercise Instructor (NCCPT-CGxI)',
      'Certified Indoor Cycling Instructor (NCCPT-CICI)',
      'Certified Yoga Instructor (NCCPT-CYI)',
      'Certified Strength Training Specialist (NCCPT-CSTS)',
    ],
    'National Council on Strength and Fitness (NCSF)': [
      'Certified Personal Trainer (NCSF-CPT)',
      'Certified Strength Coach (NCSF-CSC)',
      'Sport Nutrition Specialist (NCSF-SNS)',
      'Master Trainer (NCSF-MT)',
    ],
    'National Exercise and Sports Trainers Association (NESTA)': [
      'Personal Fitness Trainer (NESTA-PFT)',
      'Master Personal Trainer (NESTA-MPT)',
      'Fitness Nutrition Coach (NESTA-FNC)',
      'Biomechanics Specialist (NESTA-BMS)',
      'Core Conditioning Specialist (NESTA-CCS)',
      'Functional Training Specialist (NESTA-FTS)',
      'MMA Conditioning Coach (NESTA-MMACA)',
      'Triathlon Coach Certification (NESTA-TCC)',
      'Heart Rate Performance Specialist (NESTA-HRPS)',
    ],
    'National Exercise Trainers Association (NETA)': [
      'Certified Personal Trainer (NETA-CPT)',
      'Group Exercise Instructor (NETA-GEI)',
    ],
    'National Federation of Professional Trainers (NFPT)': [
      'Certified Personal Trainer (NFPT-CPT)',
      'Master Trainer (NFPT-MT)',
    ],
    'National Strength and Conditioning Association (NSCA)': [
      'Certified Strength and Conditioning Specialist (NSCA-CSCS)',
      'NSCA-Certified Personal Trainer (NSCA-CPT)',
      'Certified Special Population Specialist (NSCA-CSPS)',
      'Tactical Strength and Conditioning Facilitator (NSCA-TSAC-F)',
      'Certified Performance and Sport Scientist (NSCA-CPSS)',
      'Registered Strength and Conditioning Coach (NSCA-RSCC)',
      'Registered Strength and Conditioning Coach with Distinction (NSCA-RSCC*D)',
      'Registered Strength and Conditioning Coach Emeritus (NSCA-RSCC*E)',
    ],
    'World Instructor Training Schools (W.I.T.S.)': [
      'Certified Personal Trainer (WITS-CPT)',
      'Medical Fitness Specialist Certification (WITS-MFS)',
      'Group Fitness Instructor Certification (WITS-GFI)',
      'Senior Fitness Specialist Certification (WITS-SFS)',
      'Health Coach Specialist Certification (WITS-HCS)',
      'Fitness Management Certification (WITS-FMC)',
      'Youth Fitness Specialist Certification (WITS-YFS)',
    ],
  };
}

// =============================================================================
// TRAINER CREDENTIAL DIALOG & SELECTORS
// =============================================================================
class TrainerCredentialDialog extends StatefulWidget {
  final Map<String, String>? initialData;
  final List<String>
      usedCertificates; // Passed list of certificates already assigned

  const TrainerCredentialDialog(
      {super.key, this.initialData, this.usedCertificates = const []});

  @override
  State<TrainerCredentialDialog> createState() =>
      _TrainerCredentialDialogState();
}

class _TrainerCredentialDialogState extends State<TrainerCredentialDialog> {
  String? _selectedOrg;
  bool _isEditing = true; // State managing "read-only" vs "editable"

  List<String> _selectedCerts = [];
  final Map<String, TextEditingController> _idCtrls = {};
  final Map<String, bool> _scannedCerts = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _isEditing =
          false; // Opens greyed out / read-only by default when viewing
      _selectedOrg = widget.initialData!['organisation'];
      String initialCert = widget.initialData!['certificate']!;
      _selectedCerts = [initialCert];
      _idCtrls[initialCert] =
          TextEditingController(text: widget.initialData!['id']);
      _scannedCerts[initialCert] = widget.initialData!['scanned'] == 'true';
    }
  }

  @override
  void dispose() {
    for (var ctrl in _idCtrls.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  bool get _isValid {
    if (_selectedOrg == null || _selectedCerts.isEmpty) return false;
    for (String cert in _selectedCerts) {
      if (_idCtrls[cert] == null ||
          !RegExp(r'^[a-zA-Z0-9]+$').hasMatch(_idCtrls[cert]!.text) ||
          _scannedCerts[cert] != true) {
        return false;
      }
    }
    return true;
  }

  void _openSelectionDialog(String title, List<String> options,
      String? currentValue, Function(String) onSelect) {
    AppMotion.showPremiumDialog<void>(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: AppTheme.surface,
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.kDefaultBorderRadius)),
            child: Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8),
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
                            fontSize: AppConstants.kDefaultTitleFontSize)),
                  ),
                  const Divider(color: AppTheme.divider, height: 1),
                  Flexible(
                    child: ListView.builder(
                      itemCount: options.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final option = options[index];
                        final isSelected = currentValue == option;
                        return Column(
                          children: [
                            InkWell(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                onSelect(option);
                                Navigator.pop(context);
                              },
                              child: Container(
                                color: isSelected
                                    ? AppTheme.brand
                                    : Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(option,
                                          style: TextStyle(
                                              color: isSelected
                                                  ? AppTheme
                                                      .confirmationButtonText
                                                  : AppTheme.textPrimary,
                                              fontSize: AppConstants
                                                  .kDefaultSubtitleFontSize,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(color: AppTheme.divider, height: 1),
                          ],
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: OutlineActionButton(
                      label: 'Cancel',
                      height: AppConstants.kDefaultButtonHeightLarge,
                      textColor: AppTheme.textPrimary,
                      borderColor: AppTheme.textSecondary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  void _openMultiSelectDialog(String title, List<String> options,
      List<String> currentSelections, Function(List<String>) onConfirm) {
    List<String> tempSelections = List.from(currentSelections);
    AppMotion.showPremiumDialog<void>(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setModalState) {
            return Dialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.kDefaultBorderRadius)),
              child: Container(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8),
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
                              fontSize: AppConstants.kDefaultTitleFontSize)),
                    ),
                    const Divider(color: AppTheme.divider, height: 1),
                    Expanded(
                      child: ListView.builder(
                        itemCount: options.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final option = options[index];
                          final isSelected = tempSelections.contains(option);
                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setModalState(() {
                                    if (isSelected) {
                                      tempSelections.remove(option);
                                    } else {
                                      tempSelections.add(option);
                                    }
                                  });
                                },
                                child: Container(
                                  color: isSelected
                                      ? AppTheme.brand
                                      : Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(option,
                                            style: TextStyle(
                                                color: isSelected
                                                    ? AppTheme
                                                        .confirmationButtonText
                                                    : AppTheme.textPrimary,
                                                fontSize: AppConstants
                                                    .kDefaultSubtitleFontSize,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(color: AppTheme.divider, height: 1),
                            ],
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SolidConfirmButton(
                              label: 'Confirm',
                              height: AppConstants.kDefaultButtonHeightLarge,
                              onPressed: () {
                                onConfirm(tempSelections);
                                Navigator.pop(context);
                              }),
                          const SizedBox(height: 10),
                          OutlineActionButton(
                            label: 'Cancel',
                            height: AppConstants.kDefaultButtonHeightLarge,
                            textColor: AppTheme.textPrimary,
                            borderColor: AppTheme.textSecondary,
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    Color dynamicBorderColor =
        _isEditing ? AppTheme.textSecondary : Colors.transparent;
    Color dynamicTextColor =
        _isEditing ? AppTheme.textPrimary : AppTheme.textSecondary;

    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(24).copyWith(bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      widget.initialData != null
                          ? 'Credential Details'
                          : 'Add Credential(s)',
                      style: const TextStyle(
                          color: AppTheme.brand,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  if (widget.initialData != null && !_isEditing)
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppTheme.brand),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() => _isEditing = true);
                      },
                    )
                ],
              ),
            ),
            const Divider(color: AppTheme.divider, height: 1),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Select Organisation
                    const Text('Organisation',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: AppConstants.kDefaultSubtitleFontSize)),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: !_isEditing
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              _openSelectionDialog(
                                  'Select Organisation',
                                  MedicalData.kTrainerCertifications.keys
                                      .toList(),
                                  _selectedOrg, (val) {
                                if (_selectedOrg != val) {
                                  setState(() {
                                    _selectedOrg = val;
                                    _selectedCerts.clear();
                                    _idCtrls.clear();
                                    _scannedCerts.clear();
                                  });
                                }
                              });
                            },
                      child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          constraints: const BoxConstraints(minHeight: 60),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.02),
                            borderRadius: BorderRadius.circular(
                                AppConstants.kDefaultBorderRadius),
                            border: Border.all(
                                color: dynamicBorderColor, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _selectedOrg == null
                                    ? const Text('Select Organisation',
                                        style: TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: AppConstants
                                                .kDefaultSubtitleFontSize))
                                    : Text(_selectedOrg!,
                                        style: TextStyle(
                                            color: dynamicTextColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                              ),
                              if (_isEditing)
                                const Icon(Icons.arrow_drop_down,
                                    color: AppTheme.textSecondary),
                            ],
                          )),
                    ),

                    const SizedBox(height: 15),

                    // Multi-Select Certificates
                    const Text('Certificates',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: AppConstants.kDefaultSubtitleFontSize)),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: (_selectedOrg == null || !_isEditing)
                          ? null
                          : () {
                              HapticFeedback.lightImpact();

                              // Filter out certificates that the user has already registered
                              List<String> availableCerts = MedicalData
                                  .kTrainerCertifications[_selectedOrg]!
                                  .where((cert) =>
                                      !widget.usedCertificates.contains(cert) ||
                                      _selectedCerts.contains(cert))
                                  .toList();

                              _openMultiSelectDialog('Select Certificates',
                                  availableCerts, _selectedCerts, (selections) {
                                setState(() {
                                  _selectedCerts = selections;
                                  _idCtrls.removeWhere(
                                      (key, _) => !selections.contains(key));
                                  _scannedCerts.removeWhere(
                                      (key, _) => !selections.contains(key));
                                  for (String cert in selections) {
                                    _idCtrls.putIfAbsent(
                                        cert,
                                        () => TextEditingController()
                                          ..addListener(() => setState(() {})));
                                    _scannedCerts.putIfAbsent(
                                        cert, () => false);
                                  }
                                });
                              });
                            },
                      child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          constraints: const BoxConstraints(minHeight: 60),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.02),
                            borderRadius: BorderRadius.circular(
                                AppConstants.kDefaultBorderRadius),
                            border: Border.all(
                                color: _selectedOrg == null
                                    ? Colors.transparent
                                    : dynamicBorderColor,
                                width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                  child: _selectedCerts.isEmpty
                                      ? Text('Select Certificate(s)',
                                          style: TextStyle(
                                              color: _selectedOrg == null
                                                  ? Colors.white24
                                                  : AppTheme.textSecondary,
                                              fontSize: AppConstants
                                                  .kDefaultSubtitleFontSize))
                                      : Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: _selectedCerts
                                              .map((c) => Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 6),
                                                    decoration: BoxDecoration(
                                                        color: _isEditing
                                                            ? AppTheme.brand
                                                            : Colors.white24,
                                                        borderRadius: BorderRadius
                                                            .circular(AppConstants
                                                                .kDefaultBorderRadius)),
                                                    child: Text(c,
                                                        style: TextStyle(
                                                            color: _isEditing
                                                                ? AppTheme.bg
                                                                : Colors.white,
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ))
                                              .toList(),
                                        )),
                              if (_isEditing)
                                Icon(Icons.arrow_drop_down,
                                    color: _selectedOrg == null
                                        ? Colors.white24
                                        : AppTheme.textSecondary),
                            ],
                          )),
                    ),
                    const SizedBox(height: 15),

                    // Dynamic Certificate ID Fields and Scans
                    if (_selectedCerts.isNotEmpty) ...[
                      const Divider(color: AppTheme.divider),
                      const SizedBox(height: 15),
                      ..._selectedCerts.map((cert) {
                        bool isScanned = _scannedCerts[cert] == true;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cert,
                                  style: TextStyle(
                                      color: _isEditing
                                          ? AppTheme.brand
                                          : AppTheme.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _idCtrls[cert],
                                readOnly: !_isEditing,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9]'))
                                ],
                                style: TextStyle(
                                    color: dynamicTextColor,
                                    fontSize:
                                        AppConstants.kDefaultSubtitleFontSize),
                                decoration: InputDecoration(
                                  labelText: 'Certificate ID',
                                  labelStyle: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: AppConstants
                                          .kDefaultSubtitleFontSize),
                                  floatingLabelStyle: TextStyle(
                                      color: _isEditing
                                          ? AppTheme.brand
                                          : AppTheme.textSecondary,
                                      fontSize: AppConstants
                                          .kDefaultFormTitleFontSize),
                                  filled: true,
                                  fillColor:
                                      Colors.white.withValues(alpha: 0.02),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppConstants.kDefaultBorderRadius),
                                      borderSide: BorderSide(
                                          color: dynamicBorderColor,
                                          width: 1.5)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppConstants.kDefaultBorderRadius),
                                      borderSide: const BorderSide(
                                          color: AppTheme.brand, width: 2)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 15),
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (_isEditing)
                                OutlineActionButton(
                                  label: isScanned
                                      ? 'Certificate Scanned'
                                      : 'Upload / Scan Certificate',
                                  icon: Icon(
                                      isScanned
                                          ? CupertinoIcons
                                              .check_mark_circled_solid
                                          : CupertinoIcons.doc_text_viewfinder,
                                      color: AppTheme.brand),
                                  height: 50,
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    AppMotion.showPremiumBottomSheet(
                                        context: context,
                                        backgroundColor: AppTheme.surface,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(24))),
                                        builder: (ctx) => Padding(
                                            padding: const EdgeInsets.all(24.0),
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
                                                              color: AppTheme
                                                                  .divider,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)))),
                                                  const SizedBox(height: 25),
                                                  const Text(
                                                      'Upload Certificate',
                                                      style: TextStyle(
                                                          color: AppTheme
                                                              .textPrimary,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      textAlign:
                                                          TextAlign.center),
                                                  const SizedBox(height: 25),
                                                  SolidConfirmButton(
                                                      label: 'Scan via Camera',
                                                      icon:
                                                          CupertinoIcons.camera,
                                                      onPressed: () {
                                                        Navigator.pop(ctx);
                                                        Navigator.push(
                                                                context,
                                                                AppRoutes.noTransitionRoute(
                                                                    const CustomCameraScreen(
                                                                        isIdScan:
                                                                            false)))
                                                            .then((scanned) {
                                                          if (scanned == true) {
                                                            setState(() =>
                                                                _scannedCerts[
                                                                        cert] =
                                                                    true);
                                                          }
                                                        });
                                                      }),
                                                  const SizedBox(height: 15),
                                                  OutlineActionButton(
                                                      label:
                                                          'Upload from Device',
                                                      icon: const Icon(
                                                          CupertinoIcons.photo,
                                                          color: AppTheme.brand,
                                                          size: 20),
                                                      onPressed: () async {
                                                        Navigator.pop(ctx);
                                                        final picker =
                                                            ImagePicker();
                                                        final file = await picker
                                                            .pickImage(
                                                                source:
                                                                    ImageSource
                                                                        .gallery);
                                                        if (file != null) {
                                                          setState(() =>
                                                              _scannedCerts[
                                                                  cert] = true);
                                                        }
                                                      }),
                                                  const SizedBox(height: 30),
                                                ])));
                                  },
                                )
                              else
                                Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.transparent),
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.kDefaultBorderRadius),
                                        color: Colors.white
                                            .withValues(alpha: 0.02)),
                                    child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                              CupertinoIcons
                                                  .checkmark_seal_fill,
                                              color: AppTheme.textSecondary,
                                              size: 20),
                                          SizedBox(width: 10),
                                          Text('Verified Credential',
                                              style: TextStyle(
                                                  color: AppTheme.textSecondary,
                                                  fontWeight: FontWeight.bold)),
                                        ]))
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24).copyWith(top: 10),
              child: Row(
                children: [
                  Expanded(
                    child: OutlineActionButton(
                      label: _isEditing && widget.initialData != null
                          ? 'Cancel Edit'
                          : 'Cancel',
                      textColor: AppTheme.textPrimary,
                      borderColor: AppTheme.divider,
                      onPressed: () {
                        if (_isEditing && widget.initialData != null) {
                          setState(() => _isEditing = false);
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                  if (_isEditing) const SizedBox(width: 15),
                  if (_isEditing)
                    Expanded(
                      child: SolidConfirmButton(
                        label: 'Save',
                        onPressed: _isValid
                            ? () {
                                List<Map<String, String>> results =
                                    _selectedCerts
                                        .map((c) => {
                                              'organisation': _selectedOrg!,
                                              'certificate': c,
                                              'id': _idCtrls[c]!.text,
                                              'scanned': 'true'
                                            })
                                        .toList();
                                Navigator.pop(context, results);
                              }
                            : null,
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// CUSTOM CAMERA UI (Real Camera Implementation)
// =============================================================================
class CustomCameraScreen extends StatefulWidget {
  final bool isIdScan;
  const CustomCameraScreen({super.key, this.isIdScan = false});

  @override
  State<CustomCameraScreen> createState() => _CustomCameraScreenState();
}

class _CustomCameraScreenState extends State<CustomCameraScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isFlashing = false;
  bool _flashOn = false;
  int _selectedCameraIdx = 0;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _setCamera(_cameras[0]);
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _setCamera(CameraDescription cameraDescription) async {
    _controller?.dispose();
    _controller = CameraController(cameraDescription, ResolutionPreset.high,
        enableAudio: false);
    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      debugPrint('Error setting camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _switchCamera() {
    if (_cameras.length > 1) {
      HapticFeedback.selectionClick();
      _selectedCameraIdx = (_selectedCameraIdx + 1) % _cameras.length;
      _setCamera(_cameras[_selectedCameraIdx]);
    }
  }

  void _toggleFlash() {
    if (_controller != null && _controller!.value.isInitialized) {
      HapticFeedback.selectionClick();
      _flashOn = !_flashOn;
      _controller!.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
      setState(() {});
    }
  }

  void _capture() async {
    if (_controller != null && _controller!.value.isInitialized) {
      setState(() => _isFlashing = true);
      HapticFeedback.heavyImpact();
      await _controller!.takePicture();
      setState(() => _isFlashing = false);
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() => _step++);
    }
  }

  void _retake() {
    HapticFeedback.lightImpact();
    setState(() => _step--);
  }

  void _confirm() {
    HapticFeedback.selectionClick();
    if (widget.isIdScan && _step == 1) {
      setState(() => _step++);
    } else {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isConfirming = _step == 1 || _step == 3;

    double frameWidth = MediaQuery.of(context).size.width * 0.90;
    double frameHeight = widget.isIdScan
        ? MediaQuery.of(context).size.width * 0.55
        : MediaQuery.of(context).size.width * 0.65;

    String instructionText = '';
    if (widget.isIdScan) {
      instructionText = _step <= 1
          ? 'Align the FRONT of your ID within the frame'
          : 'Align the BACK of your ID within the frame';
    } else {
      instructionText = 'Align certificate within the horizontal frame';
    }

    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children: [
          if (_controller != null && _controller!.value.isInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: ClipRect(
                    child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller!.value.previewSize!.height,
                          height: _controller!.value.previewSize!.width,
                          child: CameraPreview(_controller!),
                        ))),
              ),
            ),
          Positioned.fill(
              child: Container(
            color: Colors.black.withValues(alpha: 0.5),
          )),
          if (!isConfirming)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: frameWidth,
                    height: frameHeight,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(instructionText,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center),
                  )
                ],
              ),
            ),
          if (isConfirming)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: frameWidth,
                    height: frameHeight,
                    decoration: BoxDecoration(
                        color: AppTheme.surface.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16)),
                    child: const Center(
                        child:
                            Icon(Icons.image, color: Colors.white24, size: 60)),
                  ),
                  const SizedBox(height: 30),
                  const Text('Does the image look clear and readable?',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        child: OutlineActionButton(
                          label: 'No',
                          textColor: Colors.white,
                          borderColor: Colors.white54,
                          height: AppConstants.kDefaultButtonHeightLarge,
                          onPressed: _retake,
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 140,
                        child: SolidConfirmButton(
                          label: 'Yes',
                          height: AppConstants.kDefaultButtonHeightLarge,
                          onPressed: _confirm,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          if (!isConfirming)
            SafeArea(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(CupertinoIcons.clear,
                                  color: Colors.white, size: 28),
                              onPressed: () => Navigator.pop(context),
                            ),
                            IconButton(
                                icon: Icon(
                                    _flashOn ? Icons.flash_on : Icons.flash_off,
                                    color: Colors.white,
                                    size: 28),
                                onPressed: _toggleFlash)
                          ])),
                  Padding(
                      padding: const EdgeInsets.all(40),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: 48),
                            GestureDetector(
                                onTap: _capture,
                                child: Container(
                                  width: 75,
                                  height: 75,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 4),
                                      color: Colors.white38),
                                )),
                            IconButton(
                                icon: const Icon(CupertinoIcons.switch_camera,
                                    color: Colors.white, size: 30),
                                onPressed: _switchCamera)
                          ]))
                ])),
          if (_isFlashing)
            Positioned.fill(child: Container(color: Colors.white)),
        ]));
  }
}

// --- INJURY & MEDICAL CONDITION MODELS AND ENUMS ---

enum InjuryType {
  tear,
  sprain,
  strain,
  fracture,
  degeneration,
  inflammation,
  postSurgical,
  other
}

extension InjuryTypeExtension on InjuryType {
  String get label {
    switch (this) {
      case InjuryType.tear:
        return 'Tear';
      case InjuryType.sprain:
        return 'Sprain';
      case InjuryType.strain:
        return 'Strain';
      case InjuryType.fracture:
        return 'Fracture';
      case InjuryType.degeneration:
        return 'Degeneration';
      case InjuryType.inflammation:
        return 'Inflammation';
      case InjuryType.postSurgical:
        return 'Post-Surgical';
      case InjuryType.other:
        return 'Other';
    }
  }
}

enum InjuryRecency { pastMonth, past6Months, overAYear, chronic }

extension InjuryRecencyExtension on InjuryRecency {
  String get label {
    switch (this) {
      case InjuryRecency.pastMonth:
        return 'Past Month';
      case InjuryRecency.past6Months:
        return 'Past 6 Months';
      case InjuryRecency.overAYear:
        return 'Over a Year';
      case InjuryRecency.chronic:
        return 'Chronic/Ongoing';
    }
  }
}

class InjuryModel extends Equatable {
  final String id;
  final String bodyPart;
  final InjuryType type;
  final int severity;
  final InjuryRecency recency;

  const InjuryModel({
    required this.id,
    required this.bodyPart,
    required this.type,
    required this.severity,
    required this.recency,
  });

  InjuryModel copyWith({
    String? id,
    String? bodyPart,
    InjuryType? type,
    int? severity,
    InjuryRecency? recency,
  }) {
    return InjuryModel(
      id: id ?? this.id,
      bodyPart: bodyPart ?? this.bodyPart,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      recency: recency ?? this.recency,
    );
  }

  @override
  List<Object?> get props => [id, bodyPart, type, severity, recency];
}

enum MedicalConditionType {
  cardiovascular,
  respiratory,
  metabolic,
  neurological,
  musculoskeletal,
  autoimmune,
  other
}

extension MedicalConditionTypeExt on MedicalConditionType {
  String get label {
    switch (this) {
      case MedicalConditionType.cardiovascular:
        return 'Cardiovascular';
      case MedicalConditionType.respiratory:
        return 'Respiratory';
      case MedicalConditionType.metabolic:
        return 'Metabolic/Endocrine';
      case MedicalConditionType.neurological:
        return 'Neurological';
      case MedicalConditionType.musculoskeletal:
        return 'Musculoskeletal';
      case MedicalConditionType.autoimmune:
        return 'Autoimmune';
      case MedicalConditionType.other:
        return 'Other';
    }
  }
}

class MedicalConditionModel extends Equatable {
  final String id;
  final String name;
  final MedicalConditionType type;
  final bool requiresClearance;
  final String notes;

  const MedicalConditionModel({
    required this.id,
    required this.name,
    required this.type,
    this.requiresClearance = false,
    this.notes = '',
  });

  MedicalConditionModel copyWith({
    String? id,
    String? name,
    MedicalConditionType? type,
    bool? requiresClearance,
    String? notes,
  }) {
    return MedicalConditionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      requiresClearance: requiresClearance ?? this.requiresClearance,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [id, name, type, requiresClearance, notes];
}

// --- REUSABLE INJURY CARD WIDGET ---

class InjuryCard extends StatelessWidget {
  final InjuryModel injury;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const InjuryCard({
    super.key,
    required this.injury,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return TnTPremiumCard(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      accentColor: _getSeverityColor(injury.severity),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  injury.bodyPart.isNotEmpty
                      ? injury.bodyPart
                      : 'Unknown Body Part',
                  style: const TextStyle(
                    color: AppTheme.brand,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: AppTheme.textSecondary, size: 20),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppTheme.error, size: 20),
                    onPressed: onRemove,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TnTChip(
                label: injury.type.label,
                color: AppTheme.brand,
                compact: true,
              ),
              const SizedBox(width: 8),
              TnTChip(
                label: injury.recency.label,
                color: AppTheme.textSecondary,
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Severity: ${injury.severity}/10',
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: injury.severity / 10,
            backgroundColor: AppTheme.divider,
            color: _getSeverityColor(injury.severity),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(int severity) {
    if (severity <= 3) return Colors.green;
    if (severity <= 6) return Colors.orange;
    return AppTheme.error;
  }
}

// =============================================================================
// CATEGORIZED MULTI-SELECT DIALOG (FOR GOALS & SPECIALITIES)
// =============================================================================
class GroupedMultiSelectDialog extends StatefulWidget {
  final String title;
  final List<GoalCategory> categories;
  final List<String> initialSelections;

  const GroupedMultiSelectDialog({
    super.key,
    required this.title,
    required this.categories,
    required this.initialSelections,
  });

  @override
  State<GroupedMultiSelectDialog> createState() =>
      _GroupedMultiSelectDialogState();
}

class _GroupedMultiSelectDialogState extends State<GroupedMultiSelectDialog> {
  late List<String> _selections;

  @override
  void initState() {
    super.initState();
    _selections = List.from(widget.initialSelections);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius)),
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(widget.title,
                  style: const TextStyle(
                      color: AppTheme.brand,
                      fontWeight: FontWeight.bold,
                      fontSize: AppConstants.kDefaultTitleFontSize)),
            ),
            const Divider(color: AppTheme.divider, height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: widget.categories.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, catIndex) {
                  final category = widget.categories[catIndex];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        color: Colors.white.withValues(alpha: 0.05),
                        child: Text(category.name,
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ),
                      ...category.items.map((item) {
                        final isSelected = _selections.contains(item.title);
                        return Column(
                          children: [
                            InkWell(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  if (isSelected) {
                                    _selections.remove(item.title);
                                  } else {
                                    _selections.add(item.title);
                                  }
                                });
                              },
                              child: Container(
                                color: isSelected
                                    ? AppTheme.brand
                                    : Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(item.title,
                                          style: TextStyle(
                                              color: isSelected
                                                  ? AppTheme
                                                      .confirmationButtonText
                                                  : AppTheme.textPrimary,
                                              fontSize: AppConstants
                                                  .kDefaultSubtitleFontSize,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal)),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        AppMotion.showPremiumDialog<void>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            backgroundColor: AppTheme.surface,
                                            titlePadding: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius
                                                    .circular(AppConstants
                                                        .kDefaultBorderRadius)),
                                            title: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  child: Text(item.title,
                                                      style: const TextStyle(
                                                          color: AppTheme.brand,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: AppConstants
                                                              .kDefaultTitleFontSize)),
                                                ),
                                                const Divider(
                                                    color: AppTheme.divider,
                                                    height: 1),
                                              ],
                                            ),
                                            content: Text(item.description,
                                                style: const TextStyle(
                                                    color: AppTheme.textPrimary,
                                                    fontSize: AppConstants
                                                        .kDefaultSubtitleFontSize,
                                                    height: 1.5)),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text(
                                                      context.l10n.close,
                                                      style: const TextStyle(
                                                          color: AppTheme.brand,
                                                          fontWeight:
                                                              FontWeight.bold)))
                                            ],
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 15),
                                        child: Icon(
                                          Icons.help_outline_rounded,
                                          color: isSelected
                                              ? AppTheme.confirmationButtonText
                                              : AppTheme.brand,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(color: AppTheme.divider, height: 1),
                          ],
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SolidConfirmButton(
                      label: context.l10n.confirm,
                      height: AppConstants.kDefaultButtonHeightLarge,
                      onPressed: () {
                        Navigator.pop(context, _selections);
                      }),
                  const SizedBox(height: 10),
                  OutlineActionButton(
                    label: context.l10n.cancel,
                    height: AppConstants.kDefaultButtonHeightLarge,
                    textColor: AppTheme.textPrimary,
                    borderColor: AppTheme.textSecondary,
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
