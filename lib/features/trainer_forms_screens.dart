// ignore_for_file: unused_import
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/c_ui_theme.dart';
import '../core/c_constants.dart';
import '../core/c_core_utils.dart';
import '../core/c_custom_controls.dart';
import '../core/c_visual_effects.dart';

// =============================================================================
// DATA SCHEMA
// Represents the submitted data for the Physical & Postural Assessment form.
// =============================================================================

/// Lateral side for movement screen compensations.
enum CompensationSide { left, right, symmetrical, none }

/// A compensation flag from dynamic movement screens.
class MovementCompensation {
  final String label;
  bool flagged;
  CompensationSide side;
  String correctiveStrategy; // auto-populated, editable
  MovementCompensation({
    required this.label,
    this.flagged = false,
    this.side = CompensationSide.none,
    this.correctiveStrategy = '',
  });
}

/// A single kinetic-chain posture checkpoint that can be toggled on the body map.
class PostureCheckpoint {
  final String id;
  final String label;
  bool flagged;
  String? detail;
  PostureCheckpoint({
    required this.id,
    required this.label,
    this.flagged = false,
    this.detail,
  });
}

/// Full data schema for the Physical & Postural Assessment.
class PhysicalAssessmentData {
  // ── Biometrics
  String heightCm = '';
  String weightKg = '';
  String waistCm = '';
  String hipCm = '';
  String neckCm = '';
  String chestCm = '';
  String armsCm = '';
  String thighsCm = '';
  String calvesCm = '';
  // Auto-calculated
  double? bmi;
  double? waistToHipRatio;

  // ── Cardio
  String restingHR = '';
  String cardioAssessmentUsed = '';
  String endingHR = '';
  String recoveryHR = '';

  // ── Body Fat
  String bodyFatPercent = '';
  String bodyFatMethod = '';

  // ── Postural checkpoints per view
  List<PostureCheckpoint> anteriorCheckpoints = [];
  List<PostureCheckpoint> lateralCheckpoints = [];
  List<PostureCheckpoint> posteriorCheckpoints = [];

  // ── Dynamic Movement – OHSA
  List<MovementCompensation> ohsaCompensations = [];
  // ── Dynamic Movement – Single-Leg
  List<MovementCompensation> singleLegCompensations = [];

  // ── Media
  List<String> mediaFiles = []; // file paths / URIs

  // ── Trainer Notes (may include auto-corrective suggestions)
  String trainerNotes = '';

  // ── Metadata
  DateTime submittedAt = DateTime.now();
  String traineeId = '';
  String trainerName = '';

  Map<String, dynamic> toJson() => {
        'submittedAt': submittedAt.toIso8601String(),
        'traineeId': traineeId,
        'trainerName': trainerName,
        'biometrics': {
          'heightCm': heightCm,
          'weightKg': weightKg,
          'waistCm': waistCm,
          'hipCm': hipCm,
          'neckCm': neckCm,
          'chestCm': chestCm,
          'armsCm': armsCm,
          'thighsCm': thighsCm,
          'calvesCm': calvesCm,
          'bmi': bmi,
          'waistToHipRatio': waistToHipRatio,
          'bodyFatPercent': bodyFatPercent,
          'bodyFatMethod': bodyFatMethod,
        },
        'cardio': {
          'restingHR': restingHR,
          'assessmentUsed': cardioAssessmentUsed,
          'endingHR': endingHR,
          'recoveryHR': recoveryHR,
        },
        'posture': {
          'anterior': anteriorCheckpoints
              .map(
                  (c) => {'id': c.id, 'flagged': c.flagged, 'detail': c.detail})
              .toList(),
          'lateral': lateralCheckpoints
              .map(
                  (c) => {'id': c.id, 'flagged': c.flagged, 'detail': c.detail})
              .toList(),
          'posterior': posteriorCheckpoints
              .map(
                  (c) => {'id': c.id, 'flagged': c.flagged, 'detail': c.detail})
              .toList(),
        },
        'dynamicMovement': {
          'ohsa': ohsaCompensations
              .map((c) => {
                    'label': c.label,
                    'flagged': c.flagged,
                    'side': c.side.name,
                    'corrective': c.correctiveStrategy,
                  })
              .toList(),
          'singleLeg': singleLegCompensations
              .map((c) => {
                    'label': c.label,
                    'flagged': c.flagged,
                    'side': c.side.name,
                    'corrective': c.correctiveStrategy,
                  })
              .toList(),
        },
        'media': mediaFiles,
        'trainerNotes': trainerNotes,
      };
}

// =============================================================================
// CORRECTIVE STRATEGY LOGIC
// Maps known compensation labels to NASM-based corrective recommendations.
// =============================================================================
class CorrectiveStrategyEngine {
  static const Map<String, String> _strategies = {
    'Knees cave in (Valgus)':
        'Inhibit: Adductors, TFL\nActivate: Glute Medius, VMO\nIntegrate: Single-leg squat progressions',
    'Feet turn out':
        'Inhibit: Soleus, Lateral Gastrocnemius\nActivate: Medial Gastrocnemius, Hip IR\nIntegrate: Wall squat with knees neutral',
    'Excessive forward lean':
        'Inhibit: Hip Flexors, Gastrocnemius\nActivate: Anterior Tibialis, Glutes\nIntegrate: Box squat with upright torso',
    'Arms fall forward':
        'Inhibit: Pectoralis Minor, Latissimus Dorsi\nActivate: Mid/Lower Trapezius, Rotator Cuff\nIntegrate: Overhead reach progressions',
    'Low back arches':
        'Inhibit: Hip Flexors, Erector Spinae\nActivate: Glutes, Intrinsic Core\nIntegrate: Dead-bug, RDL progressions',
    'Hip shift (lateral)':
        'Inhibit: Contralateral Adductors, TFL\nActivate: Ipsilateral Glute Med\nIntegrate: Lateral band walks, SL RDL',
    'Trunk rotation':
        'Inhibit: Obliques (dominant side)\nActivate: Contralateral obliques\nIntegrate: Pallof press, chop/lift patterns',
    'Knee dominance':
        'Inhibit: Quadriceps\nActivate: Glutes, Hamstrings\nIntegrate: Hip-hinge patterns, RDL',
    'Forward head':
        'Inhibit: Upper Trapezius, SCM\nActivate: Deep Cervical Flexors\nIntegrate: Chin tucks, Wall angels',
    'Rounded shoulders':
        'Inhibit: Pectoralis Minor, Upper Trapezius\nActivate: Mid/Lower Trapezius, Rhomboids\nIntegrate: Face pulls, Band pull-aparts',
    'Asymmetric weight shift':
        'Inhibit: Overactive side hip flexors\nActivate: Underactive Glute Medius\nIntegrate: Single-leg balance progressions',
    'Flat feet / pronation':
        'Inhibit: Peroneals, Lateral Gastrocnemius\nActivate: Anterior Tibialis, Posterior Tibialis\nIntegrate: Towel scrunches, SL calf raises',
    'Knee varus (bow legs)':
        'Inhibit: TFL, Biceps Femoris\nActivate: Adductors, VMO\nIntegrate: Squat with band around thighs',
    'Lateral trunk flexion':
        'Inhibit: QL (short side)\nActivate: QL & Glute Med (long side)\nIntegrate: Side plank, Farmer carry',
    'Excessive pronation':
        'Inhibit: Peroneals\nActivate: Posterior Tibialis, Intrinsic Foot\nIntegrate: Arch exercises, SL balance',
  };

  static String getSuggestion(String compensationLabel) {
    return _strategies[compensationLabel] ?? '';
  }
}

// =============================================================================
// MOCK DATA — Submitted assessments (for the Analytics Dashboard)
// Replace with real persistence layer (Isar / Drift).
// =============================================================================
final List<PhysicalAssessmentData> _mockSubmissions = List.generate(6, (i) {
  final d = PhysicalAssessmentData()
    ..traineeId = 'TRN-10${i + 1}'
    ..trainerName = 'Trainer A'
    ..submittedAt = DateTime.now().subtract(Duration(days: i * 5))
    ..heightCm = '${170 + i}'
    ..weightKg = '${75 + i * 2}'
    ..waistCm = '${82 + i}'
    ..hipCm = '${96 + i}'
    ..bmi = double.parse(
        ((75 + i * 2) / pow((170 + i) / 100, 2)).toStringAsFixed(1))
    ..waistToHipRatio = double.parse(((82 + i) / (96 + i)).toStringAsFixed(2))
    ..restingHR = '${62 + i}'
    ..cardioAssessmentUsed = i.isEven ? '3-Min Step Test' : 'Rockport Walk Test'
    ..bodyFatPercent = '${18 + i}'
    ..bodyFatMethod = 'Skinfold Caliper'
    ..trainerNotes = 'Client shows moderate valgus. Corrective plan initiated.';
  return d;
});

// =============================================================================
// FORMS MANAGEMENT SCREEN
// The main entry screen for the "Forms" section.
// Presents two pinned/locked form cards + an Analytics tab.
// =============================================================================

class FormsManagementScreen extends StatefulWidget {
  const FormsManagementScreen({super.key});

  @override
  State<FormsManagementScreen> createState() => _FormsManagementScreenState();
}

class _FormsManagementScreenState extends State<FormsManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Forms',
            style: TextStyle(
                color: AppTheme.brand,
                fontSize: 17,
                fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.brand,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.brand,
          indicatorWeight: 2,
          labelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'MY FORMS'),
            Tab(text: 'ASSESSMENT'),
            Tab(text: 'ANALYTICS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _MyFormsTab(),
          _PhysicalAssessmentForm(),
          _AnalyticsDashboard(),
        ],
      ),
    );
  }
}

// =============================================================================
// TAB 1 — MY FORMS (pinned form cards)
// =============================================================================

class _MyFormsTab extends StatelessWidget {
  const _MyFormsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        _FormCardTile(
          icon: Icons.assignment_ind_rounded,
          iconColor: AppTheme.cardBlue,
          title: 'Fitness Assessment Profile',
          subtitle:
              'Standard intake questionnaire covering medical history, goals, and lifestyle.',
          tags: const ['Default', 'Pinned'],
          onOpen: () => Navigator.push(
              context,
              AppRoutes.noTransitionRoute(
                  const _FitnessAssessmentProfileForm())),
        ),
        const SizedBox(height: 16),
        _FormCardTile(
          icon: Icons.accessibility_new_rounded,
          iconColor: AppTheme.cardGreen,
          title: 'Physical & Postural Assessment',
          subtitle:
              'Interactive posture analysis, movement screens, biometrics, and cardio evaluation.',
          tags: const ['Default', 'Pinned'],
          onOpen: () => Navigator.push(context,
              AppRoutes.noTransitionRoute(const _PhysicalAssessmentForm())),
        ),
        const SizedBox(height: 28),
        _sectionLabel('PERMISSION NOTE'),
        const SizedBox(height: 8),
        TnTPremiumCard(
          padding: const EdgeInsets.all(14),
          accentColor: AppTheme.textSecondary,
          child: Row(
            children: const [
              Icon(Icons.lock_outline_rounded,
                  color: AppTheme.textSecondary, size: 18),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Default forms are permanent, read-only templates. They cannot be deleted or modified by standard users. Only system administrators may edit template structure.',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String label) => Text(label,
      style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2));
}

class _FormCardTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final List<String> tags;
  final VoidCallback onOpen;

  const _FormCardTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.tags,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return TnTPremiumCard(
      padding: EdgeInsets.zero,
      accentColor: iconColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(subtitle,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                ...tags.map((t) => _tag(t)),
                const Spacer(),
                Material(
                  color: AppTheme.brand,
                  borderRadius:
                      BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                        AppConstants.kDefaultBorderRadius),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onOpen();
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                      child: Text('Open',
                          style: TextStyle(
                              color: AppTheme.buttonText,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String label) {
    final bool isPinned = label == 'Pinned';
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: TnTChip(
        label: label,
        icon: isPinned ? Icons.push_pin_rounded : null,
        color: isPinned ? AppTheme.cardYellow : AppTheme.brand,
        compact: true,
      ),
    );
  }
}

// =============================================================================
// TAB 2 / STANDALONE — PHYSICAL & POSTURAL ASSESSMENT FORM
// The full interactive assessment form.
// =============================================================================

class _PhysicalAssessmentForm extends StatefulWidget {
  const _PhysicalAssessmentForm();

  @override
  State<_PhysicalAssessmentForm> createState() =>
      _PhysicalAssessmentFormState();
}

class _PhysicalAssessmentFormState extends State<_PhysicalAssessmentForm>
    with SingleTickerProviderStateMixin {
  final _data = PhysicalAssessmentData();
  final _scrollController = ScrollController();
  late final TabController _viewTabController;

  // ── Biometric controllers
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  final _hipCtrl = TextEditingController();
  final _neckCtrl = TextEditingController();
  final _chestCtrl = TextEditingController();
  final _armsCtrl = TextEditingController();
  final _thighsCtrl = TextEditingController();
  final _calvesCtrl = TextEditingController();
  final _bodyFatCtrl = TextEditingController();
  final _restingHRCtrl = TextEditingController();
  final _endingHRCtrl = TextEditingController();
  final _recoveryHRCtrl = TextEditingController();
  final _trainerNotesCtrl = TextEditingController();
  final _traineeIdCtrl = TextEditingController();
  final _trainerNameCtrl = TextEditingController();

  String _cardioAssessmentUsed = '';
  String _bodyFatMethod = '';
  int _mediaCount = 0;

  // ── Postural checkpoints
  late List<PostureCheckpoint> _anteriorPoints;
  late List<PostureCheckpoint> _lateralPoints;
  late List<PostureCheckpoint> _posteriorPoints;

  // ── OHSA compensations
  late List<MovementCompensation> _ohsaComps;
  // ── Single-leg compensations
  late List<MovementCompensation> _singleLegComps;

  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _viewTabController = TabController(length: 3, vsync: this);
    // Rebuild when the body-map tab changes so _buildCheckpointList reflects
    // the correct view's flagged checkpoints.
    _viewTabController.addListener(() {
      setState(() {}); // Rebuild whenever tab index or animation changes
    });

    _anteriorPoints = [
      PostureCheckpoint(id: 'ant_feet', label: 'Feet / Ankles'),
      PostureCheckpoint(id: 'ant_knees', label: 'Knees'),
      PostureCheckpoint(id: 'ant_lphc', label: 'LPHC'),
      PostureCheckpoint(id: 'ant_shoulders', label: 'Shoulders'),
      PostureCheckpoint(id: 'ant_cervical', label: 'Cervical Spine'),
    ];
    _lateralPoints = [
      PostureCheckpoint(id: 'lat_feet', label: 'Feet / Ankles'),
      PostureCheckpoint(id: 'lat_knees', label: 'Knees'),
      PostureCheckpoint(id: 'lat_lphc', label: 'LPHC'),
      PostureCheckpoint(id: 'lat_shoulders', label: 'Shoulders'),
      PostureCheckpoint(id: 'lat_cervical', label: 'Cervical Spine'),
    ];
    _posteriorPoints = [
      PostureCheckpoint(id: 'post_feet', label: 'Feet / Ankles'),
      PostureCheckpoint(id: 'post_knees', label: 'Knees'),
      PostureCheckpoint(id: 'post_lphc', label: 'LPHC'),
      PostureCheckpoint(id: 'post_shoulders', label: 'Shoulders'),
      PostureCheckpoint(id: 'post_cervical', label: 'Cervical Spine'),
    ];

    _ohsaComps = [
      MovementCompensation(label: 'Knees cave in (Valgus)'),
      MovementCompensation(label: 'Feet turn out'),
      MovementCompensation(label: 'Excessive forward lean'),
      MovementCompensation(label: 'Arms fall forward'),
      MovementCompensation(label: 'Low back arches'),
      MovementCompensation(label: 'Hip shift (lateral)'),
      MovementCompensation(label: 'Trunk rotation'),
      MovementCompensation(label: 'Knee dominance'),
    ];

    _singleLegComps = [
      MovementCompensation(label: 'Asymmetric weight shift'),
      MovementCompensation(label: 'Hip shift (lateral)'),
      MovementCompensation(label: 'Flat feet / pronation'),
      MovementCompensation(label: 'Knee varus (bow legs)'),
      MovementCompensation(label: 'Knees cave in (Valgus)'),
      MovementCompensation(label: 'Lateral trunk flexion'),
      MovementCompensation(label: 'Excessive pronation'),
      MovementCompensation(label: 'Forward head'),
    ];

    // Listen for biometric changes to auto-calculate
    for (final c in [_heightCtrl, _weightCtrl, _waistCtrl, _hipCtrl]) {
      c.addListener(_recalculate);
    }
    // Rebuild cardio zone display when HR values change
    for (final c in [_restingHRCtrl, _endingHRCtrl]) {
      c.addListener(() => setState(() {}));
    }
  }

  void _recalculate() {
    final h = double.tryParse(_heightCtrl.text);
    final w = double.tryParse(_weightCtrl.text);
    final wa = double.tryParse(_waistCtrl.text);
    final hip = double.tryParse(_hipCtrl.text);

    setState(() {
      if (h != null && h > 0 && w != null) {
        _data.bmi = double.parse((w / pow(h / 100, 2)).toStringAsFixed(1));
      } else {
        _data.bmi = null;
      }
      if (wa != null && hip != null && hip > 0) {
        _data.waistToHipRatio = double.parse((wa / hip).toStringAsFixed(2));
      } else {
        _data.waistToHipRatio = null;
      }
    });
  }

  void _onCompensationToggled(MovementCompensation comp) {
    if (comp.flagged) {
      final suggestion = CorrectiveStrategyEngine.getSuggestion(comp.label);
      if (suggestion.isNotEmpty) {
        comp.correctiveStrategy = suggestion;
        // Append to trainer notes if not already present
        if (!_trainerNotesCtrl.text.contains(comp.label)) {
          final existing = _trainerNotesCtrl.text;
          _trainerNotesCtrl.text =
              '${existing.isEmpty ? '' : '$existing\n\n'}[AUTO] ${comp.label}:\n$suggestion';
        }
      }
    }
    setState(() {});
  }

  void _handleSubmit() {
    // Basic completeness guard — trainee ID is the minimum required field.
    if (_traineeIdCtrl.text.trim().isEmpty) {
      HapticFeedback.lightImpact();
      AppUtils.showToast(context, 'Please enter a Trainee ID before saving.');
      return;
    }
    HapticFeedback.mediumImpact();
    _data
      ..heightCm = _heightCtrl.text
      ..weightKg = _weightCtrl.text
      ..waistCm = _waistCtrl.text
      ..hipCm = _hipCtrl.text
      ..neckCm = _neckCtrl.text
      ..chestCm = _chestCtrl.text
      ..armsCm = _armsCtrl.text
      ..thighsCm = _thighsCtrl.text
      ..calvesCm = _calvesCtrl.text
      ..bodyFatPercent = _bodyFatCtrl.text
      ..bodyFatMethod = _bodyFatMethod
      ..restingHR = _restingHRCtrl.text
      ..cardioAssessmentUsed = _cardioAssessmentUsed
      ..endingHR = _endingHRCtrl.text
      ..recoveryHR = _recoveryHRCtrl.text
      ..trainerNotes = _trainerNotesCtrl.text
      ..traineeId = _traineeIdCtrl.text
      ..trainerName = _trainerNameCtrl.text
      ..anteriorCheckpoints = _anteriorPoints
      ..lateralCheckpoints = _lateralPoints
      ..posteriorCheckpoints = _posteriorPoints
      ..ohsaCompensations = _ohsaComps
      ..singleLegCompensations = _singleLegComps
      ..submittedAt = DateTime.now();

    _mockSubmissions.insert(0, _data);
    setState(() => _submitted = true);
  }

  @override
  void dispose() {
    _viewTabController.dispose();
    _scrollController.dispose();
    for (final c in [
      _heightCtrl,
      _weightCtrl,
      _waistCtrl,
      _hipCtrl,
      _neckCtrl,
      _chestCtrl,
      _armsCtrl,
      _thighsCtrl,
      _calvesCtrl,
      _bodyFatCtrl,
      _restingHRCtrl,
      _endingHRCtrl,
      _recoveryHRCtrl,
      _trainerNotesCtrl,
      _traineeIdCtrl,
      _trainerNameCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _buildSuccess();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        title: const Text('Physical & Postural Assessment',
            style: TextStyle(
                color: AppTheme.brand,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: _buildFormProgressBar(),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          // Recompute progress on scroll so the bar animates.
          if (n is ScrollUpdateNotification) setState(() {});
          return false;
        },
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 60),
          physics: const BouncingScrollPhysics(),
          children: [
            _headerBanner(),
            const SizedBox(height: 20),
            _buildTraineeRow(),
            const SizedBox(height: 28),
            // ── Section A: Postural Analysis
            _sectionHeader('A', 'Static Posture Analysis',
                Icons.person_outline_rounded, AppTheme.cardBlue),
            const SizedBox(height: 14),
            _buildBodyMapSection(),
            const SizedBox(height: 28),
            // ── Section B: Dynamic Movement Screens
            _sectionHeader('B', 'Dynamic Movement Screens',
                Icons.directions_run_rounded, AppTheme.cardPurple),
            const SizedBox(height: 14),
            _buildMovementScreenSection(),
            const SizedBox(height: 28),
            // ── Section C: Biometrics & Calculations
            _sectionHeader('C', 'Biometrics & Smart Calculations',
                Icons.monitor_heart_rounded, AppTheme.cardGreen),
            const SizedBox(height: 14),
            _buildBiometricsSection(),
            const SizedBox(height: 28),
            // ── Section D: Cardio Evaluation
            _sectionHeader('D', 'Cardio & Fitness Evaluation',
                Icons.favorite_border_rounded, AppTheme.cardRed),
            const SizedBox(height: 14),
            _buildCardioSection(),
            const SizedBox(height: 28),
            // ── Section E: Body Composition
            _sectionHeader('E', 'Body Composition', Icons.science_outlined,
                AppTheme.cardYellow),
            const SizedBox(height: 14),
            _buildBodyCompositionSection(),
            const SizedBox(height: 28),
            // ── Section F: Trainer Notes & Corrective Summary
            _sectionHeader('F', 'Trainer Notes & Corrective Plan',
                Icons.edit_note_rounded, AppTheme.cardIndigo),
            const SizedBox(height: 14),
            _buildTrainerNotesSection(),
            const SizedBox(height: 36),
            SolidConfirmButton(
              label: 'Submit Assessment',
              icon: Icons.check_circle_outline_rounded,
              height: AppConstants.kDefaultButtonHeightLarge,
              onPressed: _handleSubmit,
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                  'Assessment data is stored securely and is trainer-only.',
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  /// Thin animated progress bar based on scroll position.
  Widget _buildFormProgressBar() {
    final sc = _scrollController;
    double progress = 0;
    if (sc.hasClients && sc.position.maxScrollExtent > 0) {
      progress = (sc.offset / sc.position.maxScrollExtent).clamp(0.0, 1.0);
    }
    return LayoutBuilder(
      builder: (_, constraints) => Stack(
        children: [
          Container(height: 3, color: AppTheme.divider),
          AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            height: 3,
            width: constraints.maxWidth * progress,
            color: AppTheme.cardGreen,
          ),
        ],
      ),
    );
  }

  // ─── Header Banner ────────────────────────────────────────────────────────

  Widget _headerBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.cardGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.lock_rounded,
                color: AppTheme.cardGreen, size: 20),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pinned · Read-only Template',
                    style: TextStyle(
                        color: AppTheme.brand,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text(
                    'This form template is locked. Trainers may fill it out per client, but cannot alter the template structure.',
                    style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Trainee Row ──────────────────────────────────────────────────────────

  Widget _buildTraineeRow() {
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _inputField(
                controller: _traineeIdCtrl,
                label: 'Trainee ID / Name *',
                icon: Icons.badge_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius:
                      BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: AppTheme.textSecondary, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      dateStr,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _inputField(
          controller: _trainerNameCtrl,
          label: 'Trainer Name',
          icon: Icons.person_outline_rounded,
        ),
      ],
    );
  }

  // ─── SECTION A: Interactive Body Map ─────────────────────────────────────

  Widget _buildBodyMapSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tap on a checkpoint to flag a compensation. Select the view to inspect.',
            style: TextStyle(
                color: AppTheme.textSecondary, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 14),
          TabBar(
            controller: _viewTabController,
            labelColor: AppTheme.brand,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.brand,
            indicatorWeight: 2,
            labelStyle:
                const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'ANTERIOR'),
              Tab(text: 'LATERAL'),
              Tab(text: 'POSTERIOR'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 340,
            child: TabBarView(
              controller: _viewTabController,
              children: [
                _BodyMapWidget(
                    checkpoints: _anteriorPoints,
                    view: BodyView.anterior,
                    onToggle: (cp) => setState(() => cp.flagged = !cp.flagged)),
                _BodyMapWidget(
                    checkpoints: _lateralPoints,
                    view: BodyView.lateral,
                    onToggle: (cp) => setState(() => cp.flagged = !cp.flagged)),
                _BodyMapWidget(
                    checkpoints: _posteriorPoints,
                    view: BodyView.posterior,
                    onToggle: (cp) => setState(() => cp.flagged = !cp.flagged)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildCheckpointList(_viewTabController.index == 0
              ? _anteriorPoints
              : _viewTabController.index == 1
                  ? _lateralPoints
                  : _posteriorPoints),
        ],
      ),
    );
  }

  Widget _buildCheckpointList(List<PostureCheckpoint> points) {
    final flagged = points.where((p) => p.flagged).toList();
    if (flagged.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline_rounded,
                color: AppTheme.cardGreen, size: 14),
            SizedBox(width: 6),
            Text('No compensations flagged for this view.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppTheme.cardYellow, size: 14),
            const SizedBox(width: 6),
            Text(
                '${flagged.length} compensation${flagged.length == 1 ? '' : 's'} flagged:',
                style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ...flagged.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: AppTheme.cardYellow, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(p.label,
                      style: const TextStyle(
                          color: AppTheme.cardYellow,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            )),
      ],
    );
  }

  // ─── SECTION B: Dynamic Movement Screens ─────────────────────────────────

  Widget _buildMovementScreenSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // OHSA
        _subSectionLabel('Overhead Squat Assessment (OHSA)'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: _buildCompensationGrid(_ohsaComps),
        ),
        const SizedBox(height: 16),

        // Single-leg
        _subSectionLabel('Single-Leg Squat Assessment'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: _buildCompensationGrid(_singleLegComps),
        ),
        const SizedBox(height: 16),

        // Media upload zone
        _subSectionLabel('Upload Assessment Media'),
        const SizedBox(height: 10),
        _buildMediaDropZone(),
      ],
    );
  }

  Widget _buildCompensationGrid(List<MovementCompensation> comps) {
    return Column(
      children: comps.map((comp) => _buildCompensationRow(comp)).toList(),
    );
  }

  Widget _buildCompensationRow(MovementCompensation comp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Toggle
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                comp.flagged = !comp.flagged;
                _onCompensationToggled(comp);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: comp.flagged ? AppTheme.error : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: comp.flagged ? AppTheme.error : AppTheme.divider,
                    width: 1.5,
                  ),
                ),
                child: comp.flagged
                    ? const Icon(Icons.warning_rounded,
                        color: Colors.white, size: 14)
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(comp.label,
                  style: TextStyle(
                    color: comp.flagged
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight:
                        comp.flagged ? FontWeight.bold : FontWeight.normal,
                  )),
            ),
            // L / R / Sym toggle (only when flagged)
            if (comp.flagged) _buildSideToggle(comp),
          ],
        ),
        // Corrective strategy (auto-populated, editable)
        if (comp.flagged && comp.correctiveStrategy.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.only(left: 32),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.cardIndigo.withValues(alpha: 0.08),
              borderRadius:
                  BorderRadius.circular(AppConstants.kDefaultBorderRadius - 2),
              border: Border.all(
                  color: AppTheme.cardIndigo.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.auto_fix_high_rounded,
                        color: AppTheme.cardIndigo, size: 13),
                    SizedBox(width: 6),
                    Text('Suggested Corrective Strategy',
                        style: TextStyle(
                            color: AppTheme.cardIndigo,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(comp.correctiveStrategy,
                    style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        height: 1.5)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 10),
        const Divider(color: AppTheme.divider, height: 1),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSideToggle(MovementCompensation comp) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _sideChip('L', CompensationSide.left, comp),
        const SizedBox(width: 4),
        _sideChip('R', CompensationSide.right, comp),
        const SizedBox(width: 4),
        _sideChip('Sym', CompensationSide.symmetrical, comp),
      ],
    );
  }

  Widget _sideChip(
      String label, CompensationSide side, MovementCompensation comp) {
    final selected = comp.side == side;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => comp.side = selected ? CompensationSide.none : side);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppTheme.brand : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: selected ? AppTheme.brand : AppTheme.divider, width: 1.2),
        ),
        child: Text(label,
            style: TextStyle(
              color: selected ? AppTheme.buttonText : AppTheme.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }

  Widget _buildMediaDropZone() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // In production: integrate image_picker here.
        setState(() => _mediaCount++);
        AppUtils.showToast(
            context, 'Image picker integration: use image_picker package');
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          border: Border.all(
            color: _mediaCount > 0
                ? AppTheme.cardGreen.withValues(alpha: 0.5)
                : AppTheme.divider,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.topRight,
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        _mediaCount > 0
                            ? Icons.photo_library_rounded
                            : Icons.cloud_upload_outlined,
                        color: _mediaCount > 0
                            ? AppTheme.cardGreen
                            : AppTheme.textSecondary.withValues(alpha: 0.6),
                        size: 32,
                      ),
                      if (_mediaCount > 0)
                        Positioned(
                          top: -6,
                          right: -8,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: AppTheme.cardGreen,
                              shape: BoxShape.circle,
                            ),
                            child: Text('$_mediaCount',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _mediaCount > 0
                        ? '$_mediaCount file${_mediaCount == 1 ? '' : 's'} added — tap to add more'
                        : 'Tap to upload photos or video clips',
                    style: TextStyle(
                        color: _mediaCount > 0
                            ? AppTheme.cardGreen
                            : AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                      'Front & side profile · squat assessment · MP4, MOV, JPG',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 10)),
                ],
              ),
            ),
            if (_mediaCount > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(color: AppTheme.divider, width: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppTheme.textSecondary, size: 13),
                    const SizedBox(width: 6),
                    Text(
                      '$_mediaCount file${_mediaCount == 1 ? '' : 's'} queued for upload',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── SECTION C: Biometrics ────────────────────────────────────────────────

  Widget _buildBiometricsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Height + Weight (auto-calc row)
          Row(
            children: [
              Expanded(
                  child: _inputField(
                      controller: _heightCtrl,
                      label: 'Height (cm)',
                      icon: Icons.height_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                    NumberBoundsFormatter(
                        maxWholeDigits: 3, maxDecimalDigits: 1, maxVal: 250),
                  ])),
              const SizedBox(width: 12),
              Expanded(
                  child: _inputField(
                      controller: _weightCtrl,
                      label: 'Weight (kg)',
                      icon: Icons.monitor_weight_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                    NumberBoundsFormatter(
                        maxWholeDigits: 3, maxDecimalDigits: 1, maxVal: 500),
                  ])),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _inputField(
                      controller: _waistCtrl,
                      label: 'Waist (cm)',
                      icon: Icons.straighten_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                    NumberBoundsFormatter(
                        maxWholeDigits: 3, maxDecimalDigits: 1, maxVal: 200),
                  ])),
              const SizedBox(width: 12),
              Expanded(
                  child: _inputField(
                      controller: _hipCtrl,
                      label: 'Hip (cm)',
                      icon: Icons.straighten_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                    NumberBoundsFormatter(
                        maxWholeDigits: 3, maxDecimalDigits: 1, maxVal: 200),
                  ])),
            ],
          ),
          const SizedBox(height: 14),

          // Auto-calculated cards
          if (_data.bmi != null || _data.waistToHipRatio != null) ...[
            Row(
              children: [
                if (_data.bmi != null)
                  Expanded(
                      child: _calcCard(
                    label: 'BMI',
                    value: _data.bmi!.toString(),
                    sub: _bmiCategory(_data.bmi!),
                    color: _bmiColor(_data.bmi!),
                  )),
                if (_data.bmi != null && _data.waistToHipRatio != null)
                  const SizedBox(width: 12),
                if (_data.waistToHipRatio != null)
                  Expanded(
                      child: _calcCard(
                    label: 'Waist-to-Hip Ratio',
                    value: _data.waistToHipRatio!.toString(),
                    sub: _whrCategory(_data.waistToHipRatio!),
                    color: _whrColor(_data.waistToHipRatio!),
                  )),
              ],
            ),
            const SizedBox(height: 14),
          ],

          _subSectionLabel('Additional Circumferences'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _inputField(
                      controller: _neckCtrl,
                      label: 'Neck (cm)',
                      keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(
                  child: _inputField(
                      controller: _chestCtrl,
                      label: 'Chest (cm)',
                      keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _inputField(
                      controller: _armsCtrl,
                      label: 'Arms (cm)',
                      keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(
                  child: _inputField(
                      controller: _thighsCtrl,
                      label: 'Thighs (cm)',
                      keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 12),
          _inputField(
              controller: _calvesCtrl,
              label: 'Calves (cm)',
              keyboardType: TextInputType.number),
        ],
      ),
    );
  }

  Widget _calcCard({
    required String label,
    required String value,
    required String sub,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(sub,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }

  String _bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _bmiColor(double bmi) {
    if (bmi < 18.5) return AppTheme.cardBlue;
    if (bmi < 25) return AppTheme.cardGreen;
    if (bmi < 30) return AppTheme.cardYellow;
    return AppTheme.cardRed;
  }

  // WHR risk classification (WHO thresholds, combined male/female middle ground)
  String _whrCategory(double whr) {
    if (whr < 0.80) return 'Low risk';
    if (whr < 0.90) return 'Moderate risk';
    if (whr < 1.00) return 'High risk';
    return 'Very high risk';
  }

  Color _whrColor(double whr) {
    if (whr < 0.80) return AppTheme.cardGreen;
    if (whr < 0.90) return AppTheme.cardYellow;
    if (whr < 1.00) return AppTheme.cardPink;
    return AppTheme.cardRed;
  }

  // ─── SECTION D: Cardio ────────────────────────────────────────────────────

  Widget _buildCardioSection() {
    // Max HR estimate: 220 - age (Tanaka formula would need birthdate; use
    // simple 220-age if the trainee row has a numeric age embedded in the ID
    // — for a real app wire a dedicated age controller).
    final int? restHR = int.tryParse(_restingHRCtrl.text);
    final int? endHR = int.tryParse(_endingHRCtrl.text);
    // Karvonen zones (estimated max 180 bpm default when age unknown)
    final int estMax = 180;
    final int? hrr = (restHR != null) ? (estMax - restHR) : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: _inputField(
                      controller: _restingHRCtrl,
                      label: 'Resting HR (bpm)',
                      icon: Icons.favorite_rounded,
                      keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(
                  child: _inputField(
                      controller: _endingHRCtrl,
                      label: 'Ending HR (bpm)',
                      icon: Icons.monitor_heart_outlined,
                      keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _inputField(
                      controller: _recoveryHRCtrl,
                      label: 'Recovery HR (bpm)',
                      keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  value: _cardioAssessmentUsed.isEmpty
                      ? null
                      : _cardioAssessmentUsed,
                  hint: 'Assessment Used',
                  items: const [
                    '3-Min Step Test',
                    'Rockport Walk Test',
                    'Cooper 12-Min Run',
                    'Beep / Yo-Yo Test',
                    'VO2 Max Test',
                    'Submaximal Bike Test',
                    'YMCA Protocol',
                  ],
                  onChanged: (v) =>
                      setState(() => _cardioAssessmentUsed = v ?? ''),
                ),
              ),
            ],
          ),
          // Auto-derived HR zones when resting HR is entered
          if (restHR != null && hrr != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cardRed.withValues(alpha: 0.07),
                borderRadius:
                    BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                border:
                    Border.all(color: AppTheme.cardRed.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.auto_awesome_rounded,
                          color: AppTheme.cardRed, size: 13),
                      SizedBox(width: 6),
                      Text('Karvonen HR Zones (est. max 180 bpm)',
                          style: TextStyle(
                              color: AppTheme.cardRed,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _hrZoneRow('Zone 1 — Recovery', restHR + (hrr * 0.50).round(),
                      restHR + (hrr * 0.60).round(), AppTheme.cardBlue),
                  _hrZoneRow(
                      'Zone 2 — Aerobic Base',
                      restHR + (hrr * 0.60).round(),
                      restHR + (hrr * 0.70).round(),
                      AppTheme.cardGreen),
                  _hrZoneRow(
                      'Zone 3 — Aerobic Power',
                      restHR + (hrr * 0.70).round(),
                      restHR + (hrr * 0.80).round(),
                      AppTheme.cardYellow),
                  _hrZoneRow(
                      'Zone 4 — Threshold',
                      restHR + (hrr * 0.80).round(),
                      restHR + (hrr * 0.90).round(),
                      AppTheme.cardPink),
                  _hrZoneRow('Zone 5 — Max / VO₂',
                      restHR + (hrr * 0.90).round(), estMax, AppTheme.cardRed,
                      isLast: true),
                  if (endHR != null) ...[
                    const Divider(
                        color: AppTheme.divider, height: 16, thickness: 0.5),
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: AppTheme.textSecondary, size: 12),
                        const SizedBox(width: 6),
                        Text(
                          // ignore: unnecessary_brace_in_string_interps
                          'Ending HR ${endHR} bpm — '
                          '${_hrZoneLabel(endHR, restHR, hrr)}',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _hrZoneRow(String label, int low, int high, Color color,
      {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 6),
      child: Row(
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: TextStyle(color: color, fontSize: 11)),
          ),
          Text('$low–$high bpm',
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _hrZoneLabel(int hr, int restHR, int hrr) {
    final pct = (hr - restHR) / hrr;
    if (pct < 0.50) return 'Below Zone 1';
    if (pct < 0.60) return 'Zone 1 — Recovery';
    if (pct < 0.70) return 'Zone 2 — Aerobic Base';
    if (pct < 0.80) return 'Zone 3 — Aerobic Power';
    if (pct < 0.90) return 'Zone 4 — Threshold';
    return 'Zone 5 — Max / VO₂';
  }

  // ─── SECTION E: Body Composition ─────────────────────────────────────────

  Widget _buildBodyCompositionSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
              child: _inputField(
                  controller: _bodyFatCtrl,
                  label: 'Body Fat %',
                  icon: Icons.percent_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                NumberBoundsFormatter(
                    maxWholeDigits: 2, maxDecimalDigits: 1, maxVal: 70),
              ])),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDropdown(
              value: _bodyFatMethod.isEmpty ? null : _bodyFatMethod,
              hint: 'Testing Method',
              items: const [
                'Skinfold Caliper',
                'DEXA Scan',
                'Bioelectrical Impedance',
                'Hydrostatic Weighing',
                'Air Displacement',
                '3-Site Skinfold',
                '7-Site Skinfold',
                'US Navy Formula',
              ],
              onChanged: (v) => setState(() => _bodyFatMethod = v ?? ''),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SECTION F: Trainer Notes ─────────────────────────────────────────────

  Widget _buildTrainerNotesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _trainerNotesCtrl,
            builder: (_, val, __) {
              final hasAutoNotes = val.text.contains('[AUTO]');
              if (!hasAutoNotes) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: const [
                    Icon(Icons.auto_awesome_rounded,
                        color: AppTheme.cardIndigo, size: 15),
                    SizedBox(width: 6),
                    Text('Corrective strategies were auto-populated below.',
                        style: TextStyle(
                            color: AppTheme.cardIndigo,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          ),
          TextFormField(
            controller: _trainerNotesCtrl,
            maxLines: 8,
            style: const TextStyle(
                color: AppTheme.textPrimary, fontSize: 13, height: 1.6),
            decoration: InputDecoration(
              hintText:
                  'Add trainer observations, corrective notes, or override auto-populated strategies here…',
              hintStyle:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.02),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                borderSide: const BorderSide(color: AppTheme.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                borderSide: const BorderSide(color: AppTheme.brand, width: 2),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Icon(Icons.lock_outline_rounded,
                  color: AppTheme.textSecondary, size: 12),
              SizedBox(width: 6),
              Text('Visible to trainer only — not shared with client.',
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Shared Helpers ───────────────────────────────────────────────────────

  Widget _sectionHeader(
      String letter, String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(letter,
              style: TextStyle(
                  color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(title,
            style: TextStyle(
                color: color, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _subSectionLabel(String label) => Text(label,
      style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8));

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
        border: Border.all(color: AppTheme.divider),
      );

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        prefixIcon: icon != null
            ? Icon(icon, color: AppTheme.textSecondary, size: 16)
            : null,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.02),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          borderSide: const BorderSide(color: AppTheme.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          borderSide: const BorderSide(color: AppTheme.brand, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: AppTheme.surface,
      icon: const Icon(Icons.arrow_drop_down_rounded,
          color: AppTheme.textSecondary),
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.02),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          borderSide: const BorderSide(color: AppTheme.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          borderSide: const BorderSide(color: AppTheme.brand, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
      items: items
          .map((i) => DropdownMenuItem(
              value: i,
              child: Text(i,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 13))))
          .toList(),
      onChanged: onChanged,
    );
  }

  // ─── Success Screen ───────────────────────────────────────────────────────

  Widget _buildSuccess() {
    return _SharedSuccessScreen(
      title: 'Assessment Saved',
      description:
          'The Physical & Postural Assessment has been recorded. You can review and compare results in the Analytics tab.',
      onBack: () => Navigator.of(context).pop(),
    );
  }
}

// =============================================================================
// SHARED SUCCESS SCREEN
// Reused by both assessment forms after successful submission.
// =============================================================================
class _SharedSuccessScreen extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onBack;

  const _SharedSuccessScreen({
    required this.title,
    required this.description,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                builder: (_, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppTheme.cardGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppTheme.cardGreen.withValues(alpha: 0.3),
                        width: 2),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: AppTheme.cardGreen, size: 44),
                ),
              ),
              const SizedBox(height: 24),
              Text(title,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13, height: 1.6),
              ),
              const SizedBox(height: 32),
              OutlineActionButton(
                label: 'Back to Forms',
                icon: const Icon(Icons.arrow_back_rounded,
                    color: AppTheme.brand, size: 18),
                height: 50,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onBack();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// INTERACTIVE BODY MAP WIDGET
// Renders a 2D SVG-style wireframe of the human body using CustomPaint.
// Trainer taps a kinetic-chain zone to flag a compensation.
// =============================================================================

enum BodyView { anterior, lateral, posterior }

class _BodyMapWidget extends StatelessWidget {
  final List<PostureCheckpoint> checkpoints;
  final BodyView view;
  final void Function(PostureCheckpoint) onToggle;

  const _BodyMapWidget({
    required this.checkpoints,
    required this.view,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;

      // Normalized hit zones per view [cx%, cy%, radius%]
      final zones = _zonesFor(view, w, h);

      return Stack(
        children: [
          // Body silhouette
          CustomPaint(
            size: Size(w, h),
            painter: _BodyPainter(view: view),
          ),
          // Interactive checkpoint overlays
          ...List.generate(checkpoints.length, (i) {
            if (i >= zones.length) return const SizedBox.shrink();
            final z = zones[i];
            final cp = checkpoints[i];
            return Positioned(
              left: z[0] - z[2],
              top: z[1] - z[2],
              width: z[2] * 2,
              height: z[2] * 2,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onToggle(cp);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cp.flagged
                        ? AppTheme.error.withValues(alpha: 0.85)
                        : AppTheme.brand.withValues(alpha: 0.15),
                    border: Border.all(
                      color: cp.flagged ? AppTheme.error : AppTheme.brand,
                      width: 2,
                    ),
                    boxShadow: cp.flagged
                        ? [
                            BoxShadow(
                                color: AppTheme.error.withValues(alpha: 0.4),
                                blurRadius: 8)
                          ]
                        : [],
                  ),
                  child: Center(
                    child: cp.flagged
                        ? const Icon(Icons.close_rounded,
                            color: Colors.white, size: 14)
                        : const Icon(Icons.add_rounded,
                            color: AppTheme.brand, size: 14),
                  ),
                ),
              ),
            );
          }),
          // Labels
          ...List.generate(checkpoints.length, (i) {
            if (i >= zones.length) return const SizedBox.shrink();
            final z = zones[i];
            final cp = checkpoints[i];
            final labelLeft = z[0] + z[2] + 6;
            final isRightOverflow = labelLeft + 90 > w;
            return Positioned(
              left: isRightOverflow ? z[0] - z[2] - 90 : labelLeft,
              top: z[1] - 8,
              child: IgnorePointer(
                child: Text(
                  cp.label,
                  style: TextStyle(
                    color: cp.flagged ? AppTheme.error : AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight:
                        cp.flagged ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ],
      );
    });
  }

  /// Returns [cx, cy, radius] for each checkpoint in the given view.
  List<List<double>> _zonesFor(BodyView view, double w, double h) {
    switch (view) {
      case BodyView.anterior:
        return [
          [w * 0.5, h * 0.88, 14], // Feet/Ankles
          [w * 0.5, h * 0.72, 14], // Knees
          [w * 0.5, h * 0.52, 14], // LPHC
          [w * 0.5, h * 0.30, 14], // Shoulders
          [w * 0.5, h * 0.12, 14], // Cervical
        ];
      case BodyView.lateral:
        return [
          [w * 0.45, h * 0.88, 14],
          [w * 0.42, h * 0.72, 14],
          [w * 0.50, h * 0.52, 14],
          [w * 0.48, h * 0.30, 14],
          [w * 0.50, h * 0.12, 14],
        ];
      case BodyView.posterior:
        return [
          [w * 0.5, h * 0.88, 14],
          [w * 0.5, h * 0.72, 14],
          [w * 0.5, h * 0.52, 14],
          [w * 0.5, h * 0.30, 14],
          [w * 0.5, h * 0.12, 14],
        ];
    }
  }
}

/// Paints a minimal but clear human body silhouette for the given view.
class _BodyPainter extends CustomPainter {
  final BodyView view;
  _BodyPainter({required this.view});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.textSecondary.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = AppTheme.surface.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    // All views share similar proportions — adjust for lateral offset
    final xOffset = view == BodyView.lateral ? cx * 0.05 : 0.0;

    final path = Path();

    // Head
    final headR = w * 0.10;
    canvas.drawCircle(Offset(cx + xOffset, h * 0.09), headR, fillPaint);
    canvas.drawCircle(Offset(cx + xOffset, h * 0.09), headR, paint);

    // Neck
    path.moveTo(cx + xOffset - w * 0.04, h * 0.17);
    path.lineTo(cx + xOffset - w * 0.04, h * 0.22);
    path.moveTo(cx + xOffset + w * 0.04, h * 0.17);
    path.lineTo(cx + xOffset + w * 0.04, h * 0.22);

    // Shoulders
    path.moveTo(cx + xOffset - w * 0.18, h * 0.25);
    path.quadraticBezierTo(
        cx + xOffset, h * 0.22, cx + xOffset + w * 0.18, h * 0.25);

    // Torso outline
    path.moveTo(cx + xOffset - w * 0.18, h * 0.25);
    path.lineTo(cx + xOffset - w * 0.14, h * 0.52);
    path.lineTo(cx + xOffset + w * 0.14, h * 0.52);
    path.lineTo(cx + xOffset + w * 0.18, h * 0.25);

    // Hips
    path.moveTo(cx + xOffset - w * 0.14, h * 0.52);
    path.lineTo(cx + xOffset - w * 0.16, h * 0.58);
    path.lineTo(cx + xOffset + w * 0.16, h * 0.58);
    path.lineTo(cx + xOffset + w * 0.14, h * 0.52);

    // Arms
    path.moveTo(cx + xOffset - w * 0.18, h * 0.25);
    path.lineTo(cx + xOffset - w * 0.24, h * 0.50);
    path.moveTo(cx + xOffset + w * 0.18, h * 0.25);
    path.lineTo(cx + xOffset + w * 0.24, h * 0.50);

    // Forearms
    path.moveTo(cx + xOffset - w * 0.24, h * 0.50);
    path.lineTo(cx + xOffset - w * 0.22, h * 0.68);
    path.moveTo(cx + xOffset + w * 0.24, h * 0.50);
    path.lineTo(cx + xOffset + w * 0.22, h * 0.68);

    // Thighs
    path.moveTo(cx + xOffset - w * 0.10, h * 0.58);
    path.lineTo(cx + xOffset - w * 0.10, h * 0.74);
    path.moveTo(cx + xOffset + w * 0.10, h * 0.58);
    path.lineTo(cx + xOffset + w * 0.10, h * 0.74);

    // Lower legs
    path.moveTo(cx + xOffset - w * 0.10, h * 0.74);
    path.lineTo(cx + xOffset - w * 0.10, h * 0.90);
    path.moveTo(cx + xOffset + w * 0.10, h * 0.74);
    path.lineTo(cx + xOffset + w * 0.10, h * 0.90);

    // Feet
    path.moveTo(cx + xOffset - w * 0.10, h * 0.90);
    path.lineTo(cx + xOffset - w * 0.16, h * 0.93);
    path.moveTo(cx + xOffset + w * 0.10, h * 0.90);
    path.lineTo(cx + xOffset + w * 0.16, h * 0.93);

    // Knee joints
    canvas.drawCircle(Offset(cx + xOffset - w * 0.10, h * 0.74), 4, paint);
    canvas.drawCircle(Offset(cx + xOffset + w * 0.10, h * 0.74), 4, paint);

    canvas.drawPath(path, paint);

    // Spine line for posterior/anterior
    if (view != BodyView.lateral) {
      final spinePaint = Paint()
        ..color = AppTheme.brand.withValues(alpha: 0.10)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx, h * 0.18), Offset(cx, h * 0.56), spinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BodyPainter old) => old.view != view;
}

// =============================================================================
// ORIGINAL FORM — Fitness Assessment Profile (preserved from original file)
// Stays in the My Forms list as the existing intake questionnaire.
// Trainers navigate here from the card.
// =============================================================================

class _FitnessAssessmentProfileForm extends StatefulWidget {
  const _FitnessAssessmentProfileForm();

  @override
  State<_FitnessAssessmentProfileForm> createState() =>
      _FitnessAssessmentProfileFormState();
}

class _FitnessAssessmentProfileFormState
    extends State<_FitnessAssessmentProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final Map<String, bool> _conditions = {
    'Heart disease or chest pain': false,
    'High blood pressure (hypertension)': false,
    'Diabetes (Type 1 or Type 2)': false,
    'Asthma or respiratory condition': false,
    'Epilepsy or seizure disorder': false,
    'Osteoporosis or bone/joint disease': false,
    'Thyroid disorder': false,
    'Cancer (current or in remission)': false,
    'None of the above': false,
  };
  final _conditionsOtherCtrl = TextEditingController();
  String _doctorClearance = '';
  String _currentInjuries = '';
  final _injuryDetailsCtrl = TextEditingController();
  List<String> _currentInjurySelections = [];
  String _pastInjuries = '';
  final _pastInjuryDetailsCtrl = TextEditingController();
  List<String> _pastInjurySelections = [];
  final _medicationsCtrl = TextEditingController();
  final _emergencyNameCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();
  String _emergencyRelationship = '';

  final Set<String> _primaryGoals = {};
  final _primaryGoalOtherCtrl = TextEditingController();
  final Set<String> _secondaryGoals = {};
  String _timeline = '';
  final _specificEventCtrl = TextEditingController();
  final _whyMotivationCtrl = TextEditingController();
  String _previousSuccessLevel = '';

  String _activityLevel = '';
  int _currentDaysPerWeek = 0;
  final _currentActivitiesCtrl = TextEditingController();
  String _trainingYears = '';
  final _workedWellCtrl = TextEditingController();
  final _didntWorkCtrl = TextEditingController();
  final Set<String> _enjoyedExercises = {};
  final _enjoyedOtherCtrl = TextEditingController();
  final Set<String> _dislikedExercises = {};
  final _dislikedOtherCtrl = TextEditingController();

  String _occupationType = '';
  final _occupationTitleCtrl = TextEditingController();
  String _workdayActivity = '';
  int _sleepHours = 7;
  String _sleepQuality = '';
  String _stressLevel = '';
  String _mealsPerDay = '';
  final Set<String> _dietaryRestrictions = {};
  final _dietaryOtherCtrl = TextEditingController();
  final _waterIntakeCtrl = TextEditingController();
  String _alcoholFrequency = '';
  String _smokingStatus = '';

  int _trainingDaysPerWeek = 3;
  String _preferredSessionLength = '';
  String _trainingTime = '';
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  String _heightUnit = 'cm';
  String _weightUnit = 'kg';
  final _restingHRCtrl = TextEditingController();
  String _gymAccess = '';
  final Set<String> _availableEquipment = {};
  final _additionalNotesCtrl = TextEditingController();

  bool _submitted = false;
  bool _attemptedSubmit = false;

  static const _sectionHeaders = [
    '1. Medical History & Safety',
    '2. Goals & Motivations',
    '3. Fitness Background',
    '4. Lifestyle & Habits',
    '5. Logistics & Biometrics',
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    for (final c in [
      _conditionsOtherCtrl,
      _injuryDetailsCtrl,
      _pastInjuryDetailsCtrl,
      _medicationsCtrl,
      _emergencyNameCtrl,
      _emergencyPhoneCtrl,
      _primaryGoalOtherCtrl,
      _specificEventCtrl,
      _whyMotivationCtrl,
      _currentActivitiesCtrl,
      _workedWellCtrl,
      _didntWorkCtrl,
      _enjoyedOtherCtrl,
      _dislikedOtherCtrl,
      _occupationTitleCtrl,
      _dietaryOtherCtrl,
      _waterIntakeCtrl,
      _ageCtrl,
      _heightCtrl,
      _weightCtrl,
      _restingHRCtrl,
      _additionalNotesCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _buildSuccessScreen();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        title: const Text(
          'New Client Questionnaire',
          style: TextStyle(
              color: AppTheme.brand, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: _buildSectionProgress(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            _welcomeBanner(),
            const SizedBox(height: 24),
            _section1Medical(),
            const SizedBox(height: 32),
            _section2Goals(),
            const SizedBox(height: 32),
            _section3Fitness(),
            const SizedBox(height: 32),
            _section4Lifestyle(),
            const SizedBox(height: 32),
            _section5Logistics(),
            const SizedBox(height: 36),
            SolidConfirmButton(
              label: 'Submit Questionnaire',
              icon: Icons.check_circle_outline_rounded,
              height: AppConstants.kDefaultButtonHeightLarge,
              onPressed: _handleSubmit,
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Your information is kept strictly confidential.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    setState(() => _attemptedSubmit = true);
    if (!_isMandatoryComplete()) {
      AppUtils.showToast(
          context, 'Please complete all required fields before submitting.');
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _submitted = true);
  }

  bool _isMandatoryComplete() {
    // 1.2 — must answer yes or no
    if (_currentInjuries.isEmpty) return false;
    // 1.3 — must answer yes or no
    if (_pastInjuries.isEmpty) return false;
    // 1.5 — doctor clearance
    if (_doctorClearance.isEmpty) return false;
    // 1.6 — emergency contact
    if (_emergencyNameCtrl.text.trim().isEmpty) return false;
    if (_emergencyPhoneCtrl.text.trim().isEmpty) return false;
    if (_emergencyRelationship.isEmpty) return false;
    // 2.1 — at least one primary goal
    if (_primaryGoals.isEmpty && _primaryGoalOtherCtrl.text.trim().isEmpty) {
      return false;
    }
    // 2.3 — timeline
    if (_timeline.isEmpty) return false;
    // 3.1 — activity level
    if (_activityLevel.isEmpty) return false;
    // 3.4 — training years
    if (_trainingYears.isEmpty) return false;
    // 4.1 — occupation type
    if (_occupationType.isEmpty) return false;
    // 4.2 — workday activity
    if (_workdayActivity.isEmpty) return false;
    // 4.4 — sleep quality
    if (_sleepQuality.isEmpty) return false;
    // 4.5 — stress level
    if (_stressLevel.isEmpty) return false;
    // 4.9 — alcohol
    if (_alcoholFrequency.isEmpty) return false;
    // 4.10 — smoking
    if (_smokingStatus.isEmpty) return false;
    // 5.2 — session length
    if (_preferredSessionLength.isEmpty) return false;
    // 5.3 — training time
    if (_trainingTime.isEmpty) return false;
    // 5.4 — age, height, weight
    if (_ageCtrl.text.trim().isEmpty) return false;
    if (_heightCtrl.text.trim().isEmpty) return false;
    if (_weightCtrl.text.trim().isEmpty) return false;
    // 5.5 — gym access
    if (_gymAccess.isEmpty) return false;
    return true;
  }

  /// Returns how many of the 5 sections have at least one mandatory field
  /// answered — used to drive the progress indicator.
  int get _completedSections {
    int count = 0;
    // Section 1 — medical
    if (_currentInjuries.isNotEmpty &&
        _pastInjuries.isNotEmpty &&
        _doctorClearance.isNotEmpty &&
        _emergencyNameCtrl.text.trim().isNotEmpty &&
        _emergencyPhoneCtrl.text.trim().isNotEmpty &&
        _emergencyRelationship.isNotEmpty) {
      count++;
    }
    // Section 2 — goals
    if (_primaryGoals.isNotEmpty || _primaryGoalOtherCtrl.text.isNotEmpty) {
      count++;
    }
    // Section 3 — fitness
    if (_activityLevel.isNotEmpty && _trainingYears.isNotEmpty) {
      count++;
    }
    // Section 4 — lifestyle
    if (_occupationType.isNotEmpty &&
        _sleepQuality.isNotEmpty &&
        _stressLevel.isNotEmpty &&
        _alcoholFrequency.isNotEmpty &&
        _smokingStatus.isNotEmpty) {
      count++;
    }
    // Section 5 — logistics
    if (_preferredSessionLength.isNotEmpty &&
        _trainingTime.isNotEmpty &&
        _ageCtrl.text.trim().isNotEmpty &&
        _heightCtrl.text.trim().isNotEmpty &&
        _weightCtrl.text.trim().isNotEmpty &&
        _gymAccess.isNotEmpty) {
      count++;
    }
    return count;
  }

  Widget _buildSectionProgress() {
    final completed = _completedSections;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: List.generate(5, (i) {
          final done = i < completed;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 4,
              decoration: BoxDecoration(
                color: done ? AppTheme.cardGreen : AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return _SharedSuccessScreen(
      title: 'Questionnaire Submitted!',
      description:
          'Your responses have been recorded. Your trainer will review them before your first session.',
      onBack: () => Navigator.of(context).pop(),
    );
  }

  // ── Welcome Banner ────────────────────────────────────────────────────────

  Widget _welcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Welcome aboard!',
              style: TextStyle(
                  color: AppTheme.brand,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(
            'This questionnaire helps us build a training programme that is safe, effective, and perfectly tailored to you. Please answer as honestly and completely as possible — there are no wrong answers. The whole thing takes about 5–8 minutes.',
            style: TextStyle(
                color: AppTheme.textSecondary, fontSize: 13, height: 1.6),
          ),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: AppTheme.brand, size: 14),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Questions marked with * are mandatory and must be completed before submitting.',
                  style: TextStyle(
                      color: AppTheme.brand, fontSize: 12, height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Section Helpers ───────────────────────────────────────────────────────

  Widget _sectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Text(title,
          style: const TextStyle(
              color: AppTheme.brand,
              fontSize: 14,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _sectionSubtitle(String text) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(text,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 12, height: 1.5)),
      );

  Widget _questionLabel(String num, String text) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
            text: '$num  ',
            style: const TextStyle(
                color: AppTheme.brand,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        TextSpan(
            text: text,
            style: const TextStyle(
                color: AppTheme.textPrimary, fontSize: 13, height: 1.4)),
      ]),
    );
  }

  Widget _textField(TextEditingController ctrl, String hint,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: AppConstants.kDefaultSubtitleFontSize),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.02),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          borderSide: const BorderSide(color: AppTheme.divider, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          borderSide: const BorderSide(color: AppTheme.brand, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
    );
  }

  Widget _yesNoRadio(
      {required String value, required Function(String) onChanged}) {
    return _radioGroup(
      value: value,
      options: const ['yes', 'no'],
      labels: const ['Yes', 'No'],
      onChanged: onChanged,
    );
  }

  Widget _radioGroup({
    required String value,
    required List<String> options,
    required List<String> labels,
    required Function(String) onChanged,
  }) {
    return Column(
      children: List.generate(options.length, (i) {
        final selected = value == options[i];
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onChanged(options[i]);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? AppTheme.brand.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.02),
              borderRadius:
                  BorderRadius.circular(AppConstants.kDefaultBorderRadius),
              border: Border.all(
                color: selected ? AppTheme.brand : AppTheme.divider,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppTheme.brand : Colors.transparent,
                    border: Border.all(
                      color: selected ? AppTheme.brand : AppTheme.textSecondary,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.circle, color: AppTheme.bg, size: 8)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(labels[i],
                      style: TextStyle(
                        color: selected
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                        fontSize: 13,
                      )),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _checkboxGroup({
    required List<String> options,
    required Map<String, bool> selected,
    required Function(String, bool) onChanged,
  }) {
    return Column(
      children: options.map((opt) {
        final bool isChecked = selected[opt] ?? false;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onChanged(opt, !isChecked);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isChecked
                  ? AppTheme.brand.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.02),
              borderRadius:
                  BorderRadius.circular(AppConstants.kDefaultBorderRadius),
              border: Border.all(
                color: isChecked ? AppTheme.brand : AppTheme.divider,
                width: isChecked ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isChecked ? AppTheme.brand : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color:
                          isChecked ? AppTheme.brand : AppTheme.textSecondary,
                      width: 1.5,
                    ),
                  ),
                  child: isChecked
                      ? const Icon(Icons.check_rounded,
                          color: AppTheme.bg, size: 12)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(opt,
                      style: TextStyle(
                        color: isChecked
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                        fontSize: 13,
                      )),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _chipGroup({
    required List<String> options,
    required Set<String> selected,
    required Function(String) onChanged,
    int? maxSelections,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final bool isSelected = selected.contains(opt);
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              if (isSelected) {
                selected.remove(opt);
              } else {
                if (maxSelections != null && selected.length >= maxSelections) {
                  AppUtils.showToast(
                      context, 'Select up to $maxSelections options.');
                  return;
                }
                selected.add(opt);
              }
            });
            onChanged(opt);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.brand
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: isSelected ? AppTheme.brand : AppTheme.divider,
              ),
            ),
            child: Text(
              opt,
              style: TextStyle(
                color:
                    isSelected ? AppTheme.buttonText : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _dropdownField({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: AppTheme.surface,
      icon: const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
      style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: AppConstants.kDefaultSubtitleFontSize),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.02),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          borderSide: const BorderSide(color: AppTheme.divider, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          borderSide: const BorderSide(color: AppTheme.brand, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
      items: items
          .map((i) => DropdownMenuItem(
              value: i,
              child: Text(i,
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 13))))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _stepperField({
    required int value,
    required int min,
    required int max,
    required String suffix,
    required Function(int) onChanged,
  }) {
    return Row(
      children: [
        _stepperButton(
          icon: Icons.remove,
          onTap: value > min
              ? () {
                  HapticFeedback.selectionClick();
                  onChanged(value - 1);
                }
              : null,
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius:
                  BorderRadius.circular(AppConstants.kDefaultBorderRadius),
              border: Border.all(color: AppTheme.brand, width: 1.5),
            ),
            child: Text(
              '$value $suffix',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppTheme.brand,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        _stepperButton(
          icon: Icons.add,
          onTap: value < max
              ? () {
                  HapticFeedback.selectionClick();
                  onChanged(value + 1);
                }
              : null,
        ),
      ],
    );
  }

  Widget _stepperButton({required IconData icon, VoidCallback? onTap}) {
    final bool enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          border: Border.all(
              color: enabled ? AppTheme.brand : AppTheme.divider, width: 1.5),
          color: enabled
              ? AppTheme.brand.withValues(alpha: 0.08)
              : Colors.transparent,
        ),
        child: Icon(icon,
            color: enabled ? AppTheme.brand : AppTheme.divider, size: 20),
      ),
    );
  }

  Widget _unitToggle({
    required String leftLabel,
    required String rightLabel,
    required bool isLeft,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _unitOption(leftLabel, isLeft, () => onChanged(true)),
          _unitOption(rightLabel, !isLeft, () => onChanged(false)),
        ],
      ),
    );
  }

  Widget _unitOption(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.brand : Colors.transparent,
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius - 2),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.buttonText : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ── Mandatory field warning ────────────────────────────────────────────────

  Widget _mandatoryWarning(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.07),
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          border: Border.all(
              color: AppTheme.error.withValues(alpha: 0.35), width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppTheme.error, size: 15),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                    color: AppTheme.error, fontSize: 12, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Multi-select dialog (mirrors profile_screens.dart pattern) ────────────

  void _openInjuryMultiSelect({
    required String title,
    required List<String> options,
    required List<String> current,
    required Function(List<String>) onConfirm,
  }) {
    List<String> tmp = List.from(current);
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => Dialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.kDefaultBorderRadius)),
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.8),
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
                            fontSize: AppConstants.kDefaultTitleFontSize))),
                const Divider(color: AppTheme.divider, height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: options.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (_, i) {
                      final item = options[i];
                      final sel = tmp.contains(item);
                      return Column(children: [
                        InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setM(() {
                              sel ? tmp.remove(item) : tmp.add(item);
                            });
                          },
                          child: Container(
                            color: sel ? AppTheme.brand : Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            child: Row(children: [
                              Expanded(
                                  child: Text(item,
                                      style: TextStyle(
                                          color: sel
                                              ? AppTheme.confirmationButtonText
                                              : AppTheme.textPrimary,
                                          fontSize: AppConstants
                                              .kDefaultSubtitleFontSize,
                                          fontWeight: sel
                                              ? FontWeight.bold
                                              : FontWeight.normal))),
                              if (sel)
                                const Icon(Icons.check_rounded,
                                    color: AppTheme.confirmationButtonText,
                                    size: 18),
                            ]),
                          ),
                        ),
                        const Divider(color: AppTheme.divider, height: 1),
                      ]);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (tmp.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              '${tmp.length} selected',
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        SolidConfirmButton(
                            label: 'Confirm',
                            height: AppConstants.kDefaultButtonHeightLarge,
                            onPressed: () {
                              onConfirm(tmp);
                              Navigator.pop(ctx);
                            }),
                        const SizedBox(height: 10),
                        OutlineActionButton(
                            label: 'Cancel',
                            height: AppConstants.kDefaultButtonHeightLarge,
                            textColor: AppTheme.textPrimary,
                            borderColor: AppTheme.textSecondary,
                            onPressed: () => Navigator.pop(ctx)),
                      ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _multiSelectField({
    required String placeholder,
    required List<String> selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
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
              child: selected.isEmpty
                  ? Text(placeholder,
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: AppConstants.kDefaultSubtitleFontSize))
                  : Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: selected
                          .map((item) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                    color: AppTheme.brand,
                                    borderRadius: BorderRadius.circular(
                                        AppConstants.kDefaultBorderRadius)),
                                child: Text(item,
                                    style: const TextStyle(
                                        color: AppTheme.bg,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ))
                          .toList())),
          const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
        ]),
      ),
    );
  }

  // ── Section 1 ─────────────────────────────────────────────────────────────

  Widget _section1Medical() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(_sectionHeaders[0]),
        const SizedBox(height: 4),
        _sectionSubtitle(
            'Your safety is our top priority. Please answer every question honestly.'),
        const SizedBox(height: 20),
        _questionLabel('1.1',
            'Do you have, or have you ever been diagnosed with, any of the following?'),
        const SizedBox(height: 10),
        _checkboxGroup(
          options: _conditions.keys.toList(),
          selected: _conditions,
          onChanged: (key, val) => setState(() {
            if (key == 'None of the above' && val) {
              _conditions.updateAll((k, _) => k == 'None of the above');
            } else {
              _conditions[key] = val;
              if (val) _conditions['None of the above'] = false;
            }
          }),
        ),
        const SizedBox(height: 10),
        _textField(_conditionsOtherCtrl,
            'Other condition not listed above (optional)'),
        const SizedBox(height: 20),

        // 1.2 — Current injuries
        _questionLabel('1.2 *',
            'Do you currently have any injuries, pain, or physical discomfort?'),
        const SizedBox(height: 8),
        _yesNoRadio(
            value: _currentInjuries,
            onChanged: (v) => setState(() => _currentInjuries = v)),
        if (_attemptedSubmit && _currentInjuries.isEmpty)
          _mandatoryWarning('This field is required. Please select Yes or No.'),
        if (_currentInjuries == 'yes') ...[
          const SizedBox(height: 12),
          const Text(
            'Select all current injuries that apply:',
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: AppConstants.kDefaultSubtitleFontSize),
          ),
          const SizedBox(height: 8),
          _multiSelectField(
            placeholder: 'Tap to select injuries / conditions…',
            selected: _currentInjurySelections,
            onTap: () => _openInjuryMultiSelect(
              title: 'Current Injuries',
              options: MedicalData.commonInjuries,
              current: _currentInjurySelections,
              onConfirm: (v) => setState(() => _currentInjurySelections = v),
            ),
          ),
          const SizedBox(height: 10),
          _textField(_injuryDetailsCtrl,
              'Additional details — describe the injury/pain and how long you have had it',
              maxLines: 3),
        ],
        const SizedBox(height: 20),

        // 1.3 — Past injuries
        _questionLabel('1.3 *',
            'Have you had any significant injuries or surgeries in the past?'),
        const SizedBox(height: 8),
        _yesNoRadio(
            value: _pastInjuries,
            onChanged: (v) => setState(() => _pastInjuries = v)),
        if (_attemptedSubmit && _pastInjuries.isEmpty)
          _mandatoryWarning('This field is required. Please select Yes or No.'),
        if (_pastInjuries == 'yes') ...[
          const SizedBox(height: 12),
          const Text(
            'Select all past injuries or surgeries that apply:',
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: AppConstants.kDefaultSubtitleFontSize),
          ),
          const SizedBox(height: 8),
          _multiSelectField(
            placeholder: 'Tap to select past injuries / surgeries…',
            selected: _pastInjurySelections,
            onTap: () => _openInjuryMultiSelect(
              title: 'Past Injuries & Surgeries',
              options: MedicalData.commonInjuries,
              current: _pastInjurySelections,
              onConfirm: (v) => setState(() => _pastInjurySelections = v),
            ),
          ),
          const SizedBox(height: 10),
          _textField(_pastInjuryDetailsCtrl,
              'Additional details — approximate dates and any surgeries performed',
              maxLines: 3),
        ],
        const SizedBox(height: 20),

        _questionLabel('1.4',
            'Are you currently taking any medications, supplements, or drugs?'),
        const SizedBox(height: 8),
        _textField(
            _medicationsCtrl, 'List name(s) and purpose, or write "None"',
            maxLines: 2),
        const SizedBox(height: 20),

        _questionLabel(
            '1.5 *', 'Has a doctor ever advised you NOT to exercise?'),
        const SizedBox(height: 8),
        _radioGroup(
          value: _doctorClearance,
          options: const ['yes', 'no', 'unsure'],
          labels: const [
            'Yes, I have been advised not to',
            'No, I have no restrictions',
            'I am unsure / I should check'
          ],
          onChanged: (v) => setState(() => _doctorClearance = v),
        ),
        if (_attemptedSubmit && _doctorClearance.isEmpty)
          _mandatoryWarning('This field is required. Please select an option.'),
        const SizedBox(height: 20),

        _questionLabel('1.6 *', 'Emergency contact details'),
        const SizedBox(height: 10),
        _textField(_emergencyNameCtrl, 'Full name'),
        if (_attemptedSubmit && _emergencyNameCtrl.text.trim().isEmpty)
          _mandatoryWarning('Emergency contact name is required.'),
        const SizedBox(height: 10),
        _textField(_emergencyPhoneCtrl, 'Phone number',
            keyboardType: TextInputType.phone),
        if (_attemptedSubmit && _emergencyPhoneCtrl.text.trim().isEmpty)
          _mandatoryWarning('Emergency contact phone number is required.'),
        const SizedBox(height: 10),
        _dropdownField(
          value: _emergencyRelationship.isEmpty ? null : _emergencyRelationship,
          hint: 'Relationship to you',
          items: const [
            'Spouse / Partner',
            'Parent',
            'Sibling',
            'Friend',
            'Other family member',
            'Other'
          ],
          onChanged: (v) => setState(() => _emergencyRelationship = v ?? ''),
        ),
        if (_attemptedSubmit && _emergencyRelationship.isEmpty)
          _mandatoryWarning(
              'Please select your relationship to the emergency contact.'),
      ],
    );
  }

  // ── Section 2 ─────────────────────────────────────────────────────────────

  Widget _section2Goals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(_sectionHeaders[1]),
        const SizedBox(height: 4),
        _sectionSubtitle(
            'Understanding what you want to achieve allows us to keep you motivated and on track.'),
        const SizedBox(height: 20),
        _questionLabel(
            '2.1 *', 'What is your primary fitness goal? (Select up to 2)'),
        const SizedBox(height: 10),
        _chipGroup(
          options: const [
            'Fat loss',
            'Muscle gain',
            'Body recomposition',
            'Build strength',
            'Improve endurance',
            'Improve flexibility',
            'Sport performance',
            'General health & fitness',
            'Post-injury rehabilitation',
            'Pre/post natal fitness'
          ],
          selected: _primaryGoals,
          maxSelections: 2,
          onChanged: (v) => setState(() {}),
        ),
        const SizedBox(height: 10),
        _textField(_primaryGoalOtherCtrl, 'Other primary goal (optional)'),
        if (_attemptedSubmit &&
            _primaryGoals.isEmpty &&
            _primaryGoalOtherCtrl.text.trim().isEmpty)
          _mandatoryWarning(
              'Please select at least one primary goal or describe your goal below.'),
        const SizedBox(height: 20),
        _questionLabel(
            '2.2', 'Do you have any secondary goals? (Select all that apply)'),
        const SizedBox(height: 10),
        _chipGroup(
          options: const [
            'Better sleep',
            'Reduce stress',
            'Improve posture',
            'Increase energy levels',
            'Build healthy habits',
            'Mental wellbeing',
            'Improve mobility',
            'Lose weight for an event',
            'No secondary goals'
          ],
          selected: _secondaryGoals,
          onChanged: (v) => setState(() {}),
        ),
        const SizedBox(height: 20),
        _questionLabel('2.3 *',
            'In what timeframe would you ideally like to see significant results?'),
        const SizedBox(height: 8),
        _radioGroup(
          value: _timeline,
          options: const [
            '4_weeks',
            '3_months',
            '6_months',
            '12_months',
            'ongoing'
          ],
          labels: const [
            '4 weeks',
            '3 months',
            '6 months',
            '12 months',
            'Ongoing — no fixed deadline'
          ],
          onChanged: (v) => setState(() => _timeline = v),
        ),
        if (_attemptedSubmit && _timeline.isEmpty)
          _mandatoryWarning(
              'This field is required. Please select a timeframe.'),
        const SizedBox(height: 20),
        _questionLabel('2.4',
            'Are you training for a specific event, occasion, or deadline?'),
        const SizedBox(height: 8),
        _textField(_specificEventCtrl,
            'Describe the event and its date (or leave blank)'),
        const SizedBox(height: 20),
        _questionLabel('2.5',
            'In your own words, what is the deeper reason behind wanting to reach this goal?'),
        const SizedBox(height: 8),
        _textField(_whyMotivationCtrl,
            'e.g. "I want to feel confident in my body again"',
            maxLines: 4),
        const SizedBox(height: 20),
        _questionLabel('2.6',
            'How successful have your previous attempts at achieving this goal been?'),
        const SizedBox(height: 8),
        _radioGroup(
          value: _previousSuccessLevel,
          options: const ['1', '2', '3', '4', '5'],
          labels: const [
            '1 — I never got started',
            '2 — Started but stopped quickly',
            '3 — Made some progress but stalled',
            '4 — Made good progress but did not finish',
            '5 — First time attempting this'
          ],
          onChanged: (v) => setState(() => _previousSuccessLevel = v),
        ),
      ],
    );
  }

  // ── Section 3 ─────────────────────────────────────────────────────────────

  Widget _section3Fitness() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(_sectionHeaders[2]),
        const SizedBox(height: 4),
        _sectionSubtitle(
            'Your current fitness level sets the baseline for your programme.'),
        const SizedBox(height: 20),
        _questionLabel(
            '3.1 *', 'How would you describe your current activity level?'),
        const SizedBox(height: 8),
        _radioGroup(
          value: _activityLevel,
          options: const [
            'sedentary',
            'lightly_active',
            'moderately_active',
            'very_active',
            'extremely_active'
          ],
          labels: const [
            'Sedentary — little to no exercise',
            'Lightly active — 1–2 days/week',
            'Moderately active — 3–4 days/week',
            'Very active — 5–6 days/week',
            'Extremely active — twice/day or intense daily training'
          ],
          onChanged: (v) => setState(() => _activityLevel = v),
        ),
        if (_attemptedSubmit && _activityLevel.isEmpty)
          _mandatoryWarning(
              'This field is required. Please describe your activity level.'),
        const SizedBox(height: 20),
        _questionLabel(
            '3.2', 'How many days per week do you currently exercise?'),
        const SizedBox(height: 12),
        _stepperField(
            value: _currentDaysPerWeek,
            min: 0,
            max: 7,
            suffix: 'days/week',
            onChanged: (v) => setState(() => _currentDaysPerWeek = v)),
        const SizedBox(height: 20),
        _questionLabel('3.3', 'What activities are you currently doing?'),
        const SizedBox(height: 8),
        _textField(_currentActivitiesCtrl,
            'e.g. "Running 3x/week, gym once" or "Nothing currently"',
            maxLines: 2),
        const SizedBox(height: 20),
        _questionLabel(
            '3.4 *', 'How many years have you been training consistently?'),
        const SizedBox(height: 8),
        _radioGroup(
          value: _trainingYears,
          options: const ['beginner', '1_2', '3_5', '5_plus'],
          labels: const [
            'Beginner — less than 6 months',
            '1–2 years',
            '3–5 years',
            '5+ years'
          ],
          onChanged: (v) => setState(() => _trainingYears = v),
        ),
        if (_attemptedSubmit && _trainingYears.isEmpty)
          _mandatoryWarning(
              'This field is required. Please select your experience level.'),
        const SizedBox(height: 20),
        _questionLabel('3.5',
            'What has worked well in your previous training programmes?'),
        const SizedBox(height: 8),
        _textField(_workedWellCtrl,
            'e.g. "I respond well to 3-day splits" or "Not sure"',
            maxLines: 3),
        const SizedBox(height: 20),
        _questionLabel('3.6', "What hasn't worked or caused you to stop?"),
        const SizedBox(height: 8),
        _textField(_didntWorkCtrl, 'e.g. "I always quit cardio after 2 weeks"',
            maxLines: 3),
        const SizedBox(height: 20),
        _questionLabel('3.7',
            'Which exercise types do you enjoy? (Select all that apply)'),
        const SizedBox(height: 10),
        _chipGroup(
          options: const [
            'Barbell / powerlifting',
            'Dumbbell training',
            'Machine-based training',
            'Bodyweight / calisthenics',
            'HIIT',
            'Steady-state cardio',
            'Cycling / spin',
            'Swimming',
            'Sports / team games',
            'Yoga / Pilates',
            'Kettlebells',
            'CrossFit-style'
          ],
          selected: _enjoyedExercises,
          onChanged: (v) => setState(() {}),
        ),
        const SizedBox(height: 10),
        _textField(_enjoyedOtherCtrl, 'Other exercises you enjoy (optional)'),
        const SizedBox(height: 20),
        _questionLabel('3.8',
            'Which exercise types do you dislike or strongly prefer to avoid?'),
        const SizedBox(height: 10),
        _chipGroup(
          options: const [
            'Long-distance running',
            'Heavy barbell work',
            'Treadmill / stationary bike',
            'Group fitness classes',
            'Swimming',
            'Plyometrics / jumping',
            'Yoga / stretching',
            'High-intensity intervals'
          ],
          selected: _dislikedExercises,
          onChanged: (v) => setState(() {}),
        ),
        const SizedBox(height: 10),
        _textField(
            _dislikedOtherCtrl, 'Other exercises you dislike (optional)'),
      ],
    );
  }

  // ── Section 4 ─────────────────────────────────────────────────────────────

  Widget _section4Lifestyle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(_sectionHeaders[3]),
        const SizedBox(height: 4),
        _sectionSubtitle(
            'Sleep, nutrition, stress, and daily movement all profoundly affect your results.'),
        const SizedBox(height: 20),
        _questionLabel('4.1 *', 'What best describes your occupation type?'),
        const SizedBox(height: 8),
        _radioGroup(
          value: _occupationType,
          options: const [
            'desk',
            'standing',
            'physical',
            'mixed',
            'student',
            'not_working'
          ],
          labels: const [
            'Desk-based / sedentary',
            'Mostly standing',
            'Physically demanding',
            'Mixed — varies day to day',
            'Student',
            'Not currently working'
          ],
          onChanged: (v) => setState(() => _occupationType = v),
        ),
        if (_attemptedSubmit && _occupationType.isEmpty)
          _mandatoryWarning(
              'This field is required. Please select your occupation type.'),
        const SizedBox(height: 10),
        _textField(_occupationTitleCtrl, 'Job title (optional, for context)'),
        const SizedBox(height: 20),
        _questionLabel('4.2 *',
            'Outside of structured exercise, how active are you during a typical workday?'),
        const SizedBox(height: 8),
        _radioGroup(
          value: _workdayActivity,
          options: const ['very_low', 'low', 'moderate', 'high'],
          labels: const [
            'Very low — sitting almost all day',
            'Low — some movement but mostly stationary',
            'Moderate — on my feet regularly',
            'High — consistently moving throughout'
          ],
          onChanged: (v) => setState(() => _workdayActivity = v),
        ),
        if (_attemptedSubmit && _workdayActivity.isEmpty)
          _mandatoryWarning(
              'This field is required. Please select your workday activity level.'),
        const SizedBox(height: 20),
        _questionLabel(
            '4.3', 'How many hours of sleep do you typically get per night?'),
        const SizedBox(height: 12),
        _stepperField(
            value: _sleepHours,
            min: 3,
            max: 12,
            suffix: 'hrs/night',
            onChanged: (v) => setState(() => _sleepHours = v)),
        const SizedBox(height: 20),
        _questionLabel(
            '4.4 *', 'How would you rate the quality of your sleep overall?'),
        const SizedBox(height: 8),
        _radioGroup(
          value: _sleepQuality,
          options: const ['poor', 'fair', 'good', 'excellent'],
          labels: const [
            'Poor — I rarely wake up feeling rested',
            'Fair — occasionally rested but often groggy',
            'Good — I generally sleep well',
            'Excellent — I wake up refreshed consistently'
          ],
          onChanged: (v) => setState(() => _sleepQuality = v),
        ),
        if (_attemptedSubmit && _sleepQuality.isEmpty)
          _mandatoryWarning(
              'This field is required. Please rate your sleep quality.'),
        const SizedBox(height: 20),
        _questionLabel(
            '4.5 *', 'How would you describe your current stress levels?'),
        const SizedBox(height: 8),
        _radioGroup(
          value: _stressLevel,
          options: const ['low', 'moderate', 'high', 'very_high'],
          labels: const [
            'Low — generally calm',
            'Moderate — some stress but manageable',
            'High — frequently stressed',
            'Very high — under significant pressure'
          ],
          onChanged: (v) => setState(() => _stressLevel = v),
        ),
        if (_attemptedSubmit && _stressLevel.isEmpty)
          _mandatoryWarning(
              'This field is required. Please describe your stress level.'),
        const SizedBox(height: 20),
        _questionLabel('4.6',
            'On a typical day, how many meals or eating occasions do you have?'),
        const SizedBox(height: 8),
        _radioGroup(
          value: _mealsPerDay,
          options: const ['1_2', '3', '4_5', '6_plus', 'irregular'],
          labels: const [
            '1–2 meals per day',
            '3 meals per day',
            '4–5 meals or snacks',
            '6+ meals / grazing',
            'Irregular — no consistent pattern'
          ],
          onChanged: (v) => setState(() => _mealsPerDay = v),
        ),
        const SizedBox(height: 20),
        _questionLabel('4.7',
            'Do you follow any specific diet or have any dietary restrictions?'),
        const SizedBox(height: 10),
        _chipGroup(
          options: const [
            'No restrictions',
            'Vegetarian',
            'Vegan',
            'Halal',
            'Kosher',
            'Gluten-free',
            'Dairy-free',
            'Lactose intolerant',
            'Nut allergy',
            'Low FODMAP',
            'Intermittent fasting',
            'Keto / low-carb'
          ],
          selected: _dietaryRestrictions,
          onChanged: (v) => setState(() {}),
        ),
        const SizedBox(height: 10),
        _textField(_dietaryOtherCtrl,
            'Other dietary preference or allergy (optional)'),
        const SizedBox(height: 20),
        _questionLabel(
            '4.8', 'Approximately how much water do you drink per day?'),
        const SizedBox(height: 8),
        _textField(
            _waterIntakeCtrl, 'e.g. "1.5 litres", "2 bottles", "4–5 glasses"'),
        const SizedBox(height: 20),
        _questionLabel('4.9 *', 'How often do you consume alcohol?'),
        const SizedBox(height: 8),
        _radioGroup(
          value: _alcoholFrequency,
          options: const ['never', 'rarely', 'weekly', 'several_week', 'daily'],
          labels: const [
            'Never',
            'Rarely (a few times a year)',
            '1–2 times per week',
            'Several times per week',
            'Daily'
          ],
          onChanged: (v) => setState(() => _alcoholFrequency = v),
        ),
        if (_attemptedSubmit && _alcoholFrequency.isEmpty)
          _mandatoryWarning(
              'This field is required. Please select your alcohol consumption frequency.'),
        const SizedBox(height: 20),
        _questionLabel('4.10 *', 'What is your current smoking status?'),
        const SizedBox(height: 8),
        _radioGroup(
          value: _smokingStatus,
          options: const ['never', 'former', 'occasional', 'regular'],
          labels: const [
            'Never smoked',
            'Former smoker (quit)',
            'Occasional smoker',
            'Regular smoker'
          ],
          onChanged: (v) => setState(() => _smokingStatus = v),
        ),
        if (_attemptedSubmit && _smokingStatus.isEmpty)
          _mandatoryWarning(
              'This field is required. Please select your smoking status.'),
      ],
    );
  }

  // ── Section 5 ─────────────────────────────────────────────────────────────

  Widget _section5Logistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(_sectionHeaders[4]),
        const SizedBox(height: 4),
        _sectionSubtitle(
            'The final details help us plan your schedule and set your fitness baseline.'),
        const SizedBox(height: 20),
        _questionLabel(
            '5.1', 'How many days per week can you commit to training?'),
        const SizedBox(height: 12),
        _stepperField(
            value: _trainingDaysPerWeek,
            min: 1,
            max: 7,
            suffix: 'days/week',
            onChanged: (v) => setState(() => _trainingDaysPerWeek = v)),
        const SizedBox(height: 20),
        _questionLabel('5.2 *', 'What is your preferred session length?'),
        const SizedBox(height: 8),
        _radioGroup(
          value: _preferredSessionLength,
          options: const ['30', '45', '60', '75', '90_plus'],
          labels: const [
            '30 minutes',
            '45 minutes',
            '60 minutes',
            '75 minutes',
            '90+ minutes'
          ],
          onChanged: (v) => setState(() => _preferredSessionLength = v),
        ),
        if (_attemptedSubmit && _preferredSessionLength.isEmpty)
          _mandatoryWarning(
              'This field is required. Please select a preferred session length.'),
        const SizedBox(height: 20),
        _questionLabel('5.3 *', 'What time of day do you prefer to train?'),
        const SizedBox(height: 8),
        _radioGroup(
          value: _trainingTime,
          options: const [
            'early_morning',
            'morning',
            'midday',
            'afternoon',
            'evening',
            'late_night',
            'flexible'
          ],
          labels: const [
            'Early morning (before 7 AM)',
            'Morning (7–10 AM)',
            'Midday (10 AM–1 PM)',
            'Afternoon (1–5 PM)',
            'Evening (5–8 PM)',
            'Late night (after 8 PM)',
            'Flexible / no preference'
          ],
          onChanged: (v) => setState(() => _trainingTime = v),
        ),
        if (_attemptedSubmit && _trainingTime.isEmpty)
          _mandatoryWarning(
              'This field is required. Please select your preferred training time.'),
        const SizedBox(height: 20),
        _questionLabel(
            '5.4 *', 'Your current biometrics (for baseline tracking)'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _textField(_ageCtrl, 'Age *',
                  keyboardType: TextInputType.number),
            ),
          ],
        ),
        if (_attemptedSubmit && _ageCtrl.text.trim().isEmpty)
          _mandatoryWarning('Age is required for baseline tracking.'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _textField(_heightCtrl, 'Height *',
                    keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            _unitToggle(
              leftLabel: 'cm',
              rightLabel: 'ft/in',
              isLeft: _heightUnit == 'cm',
              onChanged: (v) =>
                  setState(() => _heightUnit = v ? 'cm' : 'imperial'),
            ),
          ],
        ),
        if (_attemptedSubmit && _heightCtrl.text.trim().isEmpty)
          _mandatoryWarning('Height is required for baseline tracking.'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _textField(_weightCtrl, 'Weight *',
                    keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            _unitToggle(
              leftLabel: 'kg',
              rightLabel: 'lbs',
              isLeft: _weightUnit == 'kg',
              onChanged: (v) => setState(() => _weightUnit = v ? 'kg' : 'lbs'),
            ),
          ],
        ),
        if (_attemptedSubmit && _weightCtrl.text.trim().isEmpty)
          _mandatoryWarning('Weight is required for baseline tracking.'),
        const SizedBox(height: 12),
        _textField(_restingHRCtrl, 'Resting heart rate (bpm) — optional',
            keyboardType: TextInputType.number),
        const SizedBox(height: 20),
        _questionLabel(
            '5.5 *', 'Do you have access to a gym or fitness facility?'),
        const SizedBox(height: 8),
        _radioGroup(
          value: _gymAccess,
          options: const ['full_gym', 'home_gym', 'outdoor', 'limited', 'none'],
          labels: const [
            'Yes — full commercial gym',
            'Yes — home gym (well-equipped)',
            'Primarily outdoors / parks',
            'Limited — basic home equipment only',
            'No equipment access'
          ],
          onChanged: (v) => setState(() => _gymAccess = v),
        ),
        if (_attemptedSubmit && _gymAccess.isEmpty)
          _mandatoryWarning(
              'This field is required. Please indicate your gym access.'),
        const SizedBox(height: 20),
        _questionLabel('5.6',
            'Which equipment do you have access to? (Select all that apply)'),
        const SizedBox(height: 10),
        _chipGroup(
          options: const [
            'Barbell & plates',
            'Dumbbells',
            'Resistance bands',
            'Pull-up bar',
            'Kettlebells',
            'Cable machine',
            'Cardio machines',
            'Bench',
            'Squat rack',
            'TRX / suspension',
            'Medicine ball',
            'Foam roller'
          ],
          selected: _availableEquipment,
          onChanged: (v) => setState(() {}),
        ),
        const SizedBox(height: 20),
        _questionLabel('5.7',
            'Is there anything else you would like your trainer to know?'),
        const SizedBox(height: 8),
        _textField(
            _additionalNotesCtrl, 'Additional notes, preferences, or concerns…',
            maxLines: 5),
      ],
    );
  }
}

// =============================================================================
// TAB 3 — ANALYTICS DASHBOARD
// Trainer-only view showing aggregate metrics + sortable data grid.
// =============================================================================

class _AnalyticsDashboard extends StatefulWidget {
  const _AnalyticsDashboard();

  @override
  State<_AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<_AnalyticsDashboard> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  List<PhysicalAssessmentData> get _sorted {
    final list = List<PhysicalAssessmentData>.from(_mockSubmissions);
    list.sort((a, b) {
      int cmp;
      switch (_sortColumnIndex) {
        case 0:
          cmp = a.traineeId.compareTo(b.traineeId);
          break;
        case 1:
          cmp = a.submittedAt.compareTo(b.submittedAt);
          break;
        case 2:
          cmp = (a.bmi ?? 0).compareTo(b.bmi ?? 0);
          break;
        case 3:
          cmp = (double.tryParse(a.weightKg) ?? 0)
              .compareTo(double.tryParse(b.weightKg) ?? 0);
          break;
        case 4:
          cmp = (int.tryParse(a.restingHR) ?? 0)
              .compareTo(int.tryParse(b.restingHR) ?? 0);
          break;
        default:
          cmp = 0;
      }
      return _sortAscending ? cmp : -cmp;
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final data = _mockSubmissions;

    if (data.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.divider),
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    color: AppTheme.textSecondary, size: 36),
              ),
              const SizedBox(height: 20),
              const Text('No assessments yet',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Submit a Physical & Postural Assessment to see analytics here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    final avgBmi =
        data.where((d) => d.bmi != null).fold(0.0, (sum, d) => sum + d.bmi!) /
            (data.where((d) => d.bmi != null).length.clamp(1, 999));
    final avgWhr = data
            .where((d) => d.waistToHipRatio != null)
            .fold(0.0, (sum, d) => sum + d.waistToHipRatio!) /
        (data.where((d) => d.waistToHipRatio != null).length.clamp(1, 999));
    final avgHR = data
            .where((d) => d.restingHR.isNotEmpty)
            .fold(0.0, (sum, d) => sum + (int.tryParse(d.restingHR) ?? 0)) /
        (data.where((d) => d.restingHR.isNotEmpty).length.clamp(1, 999));

    final latest = data.isNotEmpty
        ? data.reduce((a, b) => a.submittedAt.isAfter(b.submittedAt) ? a : b)
        : null;

    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        // ── Top-level metric cards
        const Text('OVERVIEW',
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _metricCard(
              label: 'Total Assessments',
              value: '${data.length}',
              icon: Icons.people_outline_rounded,
              color: AppTheme.cardBlue,
            )),
            const SizedBox(width: 12),
            Expanded(
                child: _metricCard(
              label: 'Avg BMI',
              value: avgBmi.toStringAsFixed(1),
              icon: Icons.monitor_weight_outlined,
              color: AppTheme.cardGreen,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _metricCard(
              label: 'Avg Waist/Hip',
              value: avgWhr.toStringAsFixed(2),
              icon: Icons.straighten_rounded,
              color: AppTheme.cardPurple,
            )),
            const SizedBox(width: 12),
            Expanded(
                child: _metricCard(
              label: 'Avg Resting HR',
              value: '${avgHR.toStringAsFixed(0)} bpm',
              icon: Icons.favorite_border_rounded,
              color: AppTheme.cardRed,
            )),
          ],
        ),
        if (latest != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius:
                  BorderRadius.circular(AppConstants.kDefaultBorderRadius),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    color: AppTheme.textSecondary, size: 14),
                const SizedBox(width: 8),
                Text(
                  'Latest assessment: ${latest.traineeId.isEmpty ? 'Unknown' : latest.traineeId}  ·  '
                  '${latest.submittedAt.day.toString().padLeft(2, '0')}/'
                  '${latest.submittedAt.month.toString().padLeft(2, '0')}/'
                  '${latest.submittedAt.year}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 28),

        // ── Top compensations summary
        const Text('MOST FLAGGED COMPENSATIONS',
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2)),
        const SizedBox(height: 12),
        _buildCompensationSummary(),

        const SizedBox(height: 28),

        // ── Sortable data grid
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('CLIENT RECORDS',
                style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                AppUtils.showToast(
                    context, 'Export: integrate CSV/PDF export here.');
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius:
                      BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.download_rounded,
                        color: AppTheme.textSecondary, size: 14),
                    SizedBox(width: 6),
                    Text('Export',
                        style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius:
                BorderRadius.circular(AppConstants.kDefaultBorderRadius),
            border: Border.all(color: AppTheme.divider),
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(AppConstants.kDefaultBorderRadius),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildDataTable(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCompensationSummary() {
    // Count all flagged OHSA compensations across submissions
    final Map<String, int> counts = {};
    for (final d in _mockSubmissions) {
      for (final c in d.ohsaCompensations) {
        if (c.flagged) {
          counts[c.label] = (counts[c.label] ?? 0) + 1;
        }
      }
    }
    if (counts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius:
                BorderRadius.circular(AppConstants.kDefaultBorderRadius),
            border: Border.all(color: AppTheme.divider)),
        child: const Text('No compensation data recorded yet.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
      );
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = _mockSubmissions.length.clamp(1, 999);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          border: Border.all(color: AppTheme.divider)),
      child: Column(
        children: sorted.take(5).map((e) {
          final pct = (e.value / total).clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(e.key,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                    Text('${e.value} clients',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppTheme.divider,
                    color: AppTheme.cardRed,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDataTable() {
    final rows = _sorted;

    return DataTable(
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      headingRowColor: WidgetStateProperty.all(AppTheme.bg),
      dataRowColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTheme.brand.withValues(alpha: 0.05);
        }
        return AppTheme.surface;
      }),
      headingTextStyle: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.bold),
      dataTextStyle: const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
      dividerThickness: 0.5,
      columnSpacing: 24,
      columns: [
        _sortableCol('Trainee', 0),
        _sortableCol('Date', 1),
        _sortableCol('BMI', 2),
        _sortableCol('Weight (kg)', 3),
        _sortableCol('Resting HR', 4),
        const DataColumn(label: Text('WHR')),
        const DataColumn(label: Text('Body Fat %')),
        const DataColumn(label: Text('Cardio Test')),
        const DataColumn(label: Text('Notes')),
      ],
      rows: rows.map((d) {
        return DataRow(cells: [
          DataCell(Text(d.traineeId.isEmpty ? '—' : d.traineeId)),
          DataCell(Text(
              '${d.submittedAt.day}/${d.submittedAt.month}/${d.submittedAt.year}')),
          DataCell(_bmiCell(d.bmi)),
          DataCell(Text(d.weightKg.isEmpty ? '—' : '${d.weightKg} kg')),
          DataCell(Text(d.restingHR.isEmpty ? '—' : '${d.restingHR} bpm')),
          DataCell(Text(d.waistToHipRatio?.toString() ?? '—')),
          DataCell(
              Text(d.bodyFatPercent.isEmpty ? '—' : '${d.bodyFatPercent}%')),
          DataCell(Text(
              d.cardioAssessmentUsed.isEmpty ? '—' : d.cardioAssessmentUsed,
              overflow: TextOverflow.ellipsis)),
          DataCell(
            SizedBox(
              width: 160,
              child: Text(
                d.trainerNotes.isEmpty ? '—' : d.trainerNotes,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11),
              ),
            ),
          ),
        ]);
      }).toList(),
    );
  }

  DataColumn _sortableCol(String label, int index) {
    return DataColumn(
      label: Text(label),
      onSort: (colIndex, ascending) {
        setState(() {
          _sortColumnIndex = colIndex;
          _sortAscending = ascending;
        });
      },
    );
  }

  Widget _bmiCell(double? bmi) {
    if (bmi == null) return const Text('—');
    Color color;
    if (bmi < 18.5) {
      color = AppTheme.cardBlue;
    } else if (bmi < 25) {
      color = AppTheme.cardGreen;
    } else if (bmi < 30) {
      color = AppTheme.cardYellow;
    } else {
      color = AppTheme.cardRed;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(bmi.toString(),
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
