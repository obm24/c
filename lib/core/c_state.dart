import 'dart:math';
import 'package:flutter/material.dart';

import 'c_trainee_profile.dart';

// ===========================================================================
// TEMPLATE MODELS
// ===========================================================================
class TrainingTemplate {
  final String id;
  String name;
  List<String> exercises;
  String duration;
  String difficulty;
  int assignedCount;

  TrainingTemplate({
    required this.id,
    required this.name,
    required this.exercises,
    required this.duration,
    required this.difficulty,
    this.assignedCount = 0,
  });
}

class DietTemplate {
  final String id;
  String name;
  List<String> meals;
  String calories;
  String type;
  int assignedCount;

  DietTemplate({
    required this.id,
    required this.name,
    required this.meals,
    required this.calories,
    required this.type,
    this.assignedCount = 0,
  });
}

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  String weightUnit = 'metric';
  String distanceUnit = 'metric';
  String measurementUnit = 'metric';
  bool isDevicePaired = false;
  String currentRole = 'Trainer';

  bool get isTrainer => currentRole.toLowerCase() == 'trainer';
  bool get isTrainee => currentRole.toLowerCase() == 'trainee';

  void setRole(String role) {
    final normalized = role.trim().toLowerCase();
    final nextRole = normalized == 'trainee' ? 'Trainee' : 'Trainer';
    if (currentRole == nextRole) return;
    currentRole = nextRole;
    notifyListeners();
  }

  bool isHolidayMode = false;
  bool isUnavailableMode = false;
  DateTimeRange? holidayDateRange;

  // Trainer online-only flag (fix #3)
  bool isOnlineOnly = false;
  int employmentMode = 0;

  String profileUsername = 'omarbinalmajd';
  String profilePhone = '1001234567';
  String profileCountryCode = 'assets/images/flags/eg.svg +20';
  String profileCountry = 'assets/images/flags/eg.svg Egypt';
  String profileRegion = 'Cairo';
  String profileGender = 'Male';
  DateTime profileDob = DateTime(1998, 5, 15);
  String profileFirstName = 'Omar';
  String profileLastName = 'bin al-Majd';

  List<String> currentInjuries = ['Rotator Cuff Tear'];
  List<String> pastInjuries = ['Inversion Ankle Sprain'];
  List<String> medicalConditions = ['Asthma'];
  List<String> currentGoals = [
    'Bodybuilding',
    'Endurance Training',
    'Mobility Training'
  ];
  int traineeTrainingExperienceYears = 3;
  List<String> selectedPreferredDiets = [
    'High-protein diet',
    'Mediterranean diet'
  ];

  Map<String, String> bodyComposition = {
    'Body Weight': '82.00',
    'Height': '180.00',
    'BMI': '25.3',
    'BMR': '1802',
    'TBW': '45.2',
    'ICW': '29.1',
    'ECW': '16.1',
    'SMM': '38.4',
    'SLM': '61.5',
    'FFM': '65.2',
    'BFM': '16.8',
    'PBF': '20.5',
    'Subcutaneous Fat Mass': '14.2',
    'Right Arm': '4.2',
    'Left Arm': '4.1',
    'Trunk': '28.5',
    'Right Leg': '10.5',
    'Left Leg': '10.4',
  };

  Map<String, String> circumferences = {
    'Neck': '40.0',
    'Shoulder': '120.5',
    'Chest': '105.0',
    'Arm': '36.5',
    'Forearm': '30.0',
    'Waist': '86.0',
    'Hips': '96.0',
    'Thigh': '62.0',
    'Calf': '41.0'
  };

  // ===========================================================================
  // MOCK USERS
  // ===========================================================================
  final Map<String, dynamic> trainerAhmed = {
    'username': 'ahmed1',
    'firstName': 'Ahmed',
    'lastName': 'al-Demerdash',
    'dob': DateTime(1990, 4, 10),
    'gender': 'Male',
    'countryOfEmployment': 'assets/images/flags/eg.svg Egypt',
    'role': 'Trainer',
    'rating': '4.9',
    'bio':
        'Elite NASM-certified personal trainer with 8+ years of experience transforming lives through science-based programming and precision nutrition. Specialising in body recomposition, sports conditioning, and corrective exercise for high-performance athletes and everyday clients alike.',
    'followers': '12.4K',
    'following': '150',
    'yearsExperience': '8',
    'credentials': [
      'NASM Certified Personal Trainer (NASM-CPT)',
      'NASM Corrective Exercise Specialist (NASM-CES)',
      'NASM Performance Enhancement Specialist (NASM-PES)',
      'NASM Fitness Nutrition Specialist (NASM-FNS)',
    ],
    'specialties': [
      'Strength & Hypertrophy',
      'Body Recomposition',
      'Weight Loss',
      'Sports Performance',
      'Corrective Exercise',
      'Nutrition Coaching',
      'Injury Rehabilitation',
      'HIIT & Conditioning',
      'Powerlifting',
      'Functional Fitness',
    ],
    'isOnlineOnly': false,
    'places': [
      {
        'name': "Gold's Gym Elite",
        'address': '12 Sheikh Zayed Rd',
        'city': 'Cairo',
        'country': 'Egypt',
        'type': 'Gym',
        'lat': 30.0626,
        'lng': 31.2497
      },
      {
        'name': 'Platinum Fitness Club',
        'address': '4 Al Thawra St, Heliopolis',
        'city': 'Cairo',
        'country': 'Egypt',
        'type': 'Fitness Club',
        'lat': 30.0923,
        'lng': 31.3366
      },
      {
        'name': 'Gezira Sporting Club',
        'address': 'Zamalek Island',
        'city': 'Cairo',
        'country': 'Egypt',
        'type': 'Sports Complex',
        'lat': 30.0561,
        'lng': 31.2243
      },
    ],
  };

  final Map<String, dynamic> traineeOmar = {
    'username': 'obm24',
    'firstName': 'Omar',
    'lastName': 'Magdy',
    'dob': DateTime(1998, 8, 22),
    'gender': 'Male',
    'countryOfResidence': 'assets/images/flags/eg.svg Egypt',
    'role': 'Trainee',
    'posts': '18',
    'followers': '1.6K',
    'following': '342',
    'bio':
        'Dedicated to building a stronger, healthier version of myself every day. Currently in the middle of a body recomposition phase — leaning out while preserving every gram of muscle I can. Lover of deadlifts, nutrition science, and morning runs along the Nile.',
    'goals': [
      'Bodybuilding',
      'Endurance Training',
      'Mobility Training',
      'Rehabilitation'
    ],
    'trainingExperienceYears': 3,
    'trainingExperienceLabel': '3-5 Years',
    'preferredDiets': ['High-protein diet', 'Mediterranean diet'],
    'diet': 'High Protein / Moderate Carb — approx. 2,800 kcal/day',
    'currentInjuries': [
      'Rotator Cuff Tear',
      'Shoulder Impingement',
    ],
    'pastInjuries': [
      'Inversion Ankle Sprain',
      'Muscle Strains (Pulled Muscles)',
      'Runner\'s Knee (Patellofemoral Pain Syndrome)',
    ],
    'medicalConditions': [
      'Asthma',
      'Anemia',
      'Osteopenia',
    ],
    'bodyComp': {
      'Body Weight': '80.5',
      'Height': '182.0',
      'BMI': '24.3',
      'TBW': '44.0',
      'ICW': '28.5',
      'ECW': '15.5',
      'BFM': '14.2',
      'PBF': '17.6',
      'SMM': '37.8',
      'FFM': '66.3',
    },
    'circumferences': {
      'Neck': '39.0',
      'Shoulder': '118.0',
      'Chest': '102.0',
      'Arm': '35.0',
      'Forearm': '29.0',
      'Waist': '84.0',
      'Thigh': '60.0',
      'Calf': '40.0',
    },
  };

  // ---------------------------------------------------------------------------
  // TEMPLATES STATE
  // ---------------------------------------------------------------------------
  final List<TrainingTemplate> _trainingTemplates = [
    TrainingTemplate(
      id: '1',
      name: 'Upper Body Push',
      exercises: ['Bench Press', 'Overhead Press', 'Tricep Dips'],
      duration: '45–60 min',
      difficulty: 'Intermediate',
      assignedCount: 6,
    ),
    TrainingTemplate(
      id: '2',
      name: 'Full Body Strength',
      exercises: ['Squat', 'Deadlift', 'Pull-ups', 'Push-ups'],
      duration: '60–75 min',
      difficulty: 'Advanced',
      assignedCount: 4,
    ),
  ];

  final List<DietTemplate> _dietTemplates = [
    DietTemplate(
      id: '1',
      name: 'Lean Bulking Macros',
      meals: ['High Carb Breakfast', 'Post-Workout Shake', 'Protein Dinner'],
      calories: '3,200 kcal',
      type: 'Bulking',
      assignedCount: 3,
    ),
    DietTemplate(
      id: '2',
      name: 'Cut Phase Protocol',
      meals: ['Low-Carb Breakfast', 'Green Salad Lunch', 'Lean Protein Dinner'],
      calories: '2,000 kcal',
      type: 'Cutting',
      assignedCount: 5,
    ),
  ];

  List<TrainingTemplate> get trainingTemplates =>
      List.unmodifiable(_trainingTemplates);
  List<DietTemplate> get dietTemplates => List.unmodifiable(_dietTemplates);

  void addTrainingTemplate(TrainingTemplate template) {
    _trainingTemplates.add(template);
    notifyListeners();
  }

  void updateTrainingTemplate(int index, TrainingTemplate updated) {
    if (index >= 0 && index < _trainingTemplates.length) {
      _trainingTemplates[index] = updated;
      notifyListeners();
    }
  }

  void deleteTrainingTemplate(String id) {
    _trainingTemplates.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void duplicateTrainingTemplate(String id) {
    final idx = _trainingTemplates.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final original = _trainingTemplates[idx];
    final dup = TrainingTemplate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${original.name} (Copy)',
      exercises: List.from(original.exercises),
      duration: original.duration,
      difficulty: original.difficulty,
      assignedCount: 0,
    );
    _trainingTemplates.insert(idx + 1, dup);
    notifyListeners();
  }

  void addDietTemplate(DietTemplate template) {
    _dietTemplates.add(template);
    notifyListeners();
  }

  void updateDietTemplate(int index, DietTemplate updated) {
    if (index >= 0 && index < _dietTemplates.length) {
      _dietTemplates[index] = updated;
      notifyListeners();
    }
  }

  void deleteDietTemplate(String id) {
    _dietTemplates.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void duplicateDietTemplate(String id) {
    final idx = _dietTemplates.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final original = _dietTemplates[idx];
    final dup = DietTemplate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${original.name} (Copy)',
      meals: List.from(original.meals),
      calories: original.calories,
      type: original.type,
      assignedCount: 0,
    );
    _dietTemplates.insert(idx + 1, dup);
    notifyListeners();
  }

  // end of template state

  void updateBMI() {
    double? w = double.tryParse(bodyComposition['Body Weight'] ?? '');
    double? h = double.tryParse(bodyComposition['Height'] ?? '');
    if (w != null && h != null && h > 0) {
      if (weightUnit == 'metric') {
        double hm = h / 100.0;
        bodyComposition['BMI'] = (1.3 * w / pow(hm, 2.5)).toStringAsFixed(1);
      } else {
        bodyComposition['BMI'] = (5734 * w / pow(h, 2.5)).toStringAsFixed(1);
      }
    } else {
      bodyComposition['BMI'] = '0.0';
    }
  }

  void updateBMR() {
    double? w = double.tryParse(bodyComposition['Body Weight'] ?? '');
    double? h = double.tryParse(bodyComposition['Height'] ?? '');
    int age = DateTime.now().year - profileDob.year;
    if (DateTime.now().month < profileDob.month ||
        (DateTime.now().month == profileDob.month &&
            DateTime.now().day < profileDob.day)) {
      age--;
    }
    if (w != null && h != null && h > 0) {
      double weightKg = weightUnit == 'metric' ? w : w / 2.20462;
      double heightCm = measurementUnit == 'metric' ? h : h * 2.54;
      double bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
      if (profileGender.toLowerCase() == 'male') {
        bmr += 5;
      } else {
        bmr -= 161;
      }
      bodyComposition['BMR'] = bmr.toStringAsFixed(0);
    } else {
      bodyComposition['BMR'] = '0';
    }
  }

  void updateBodyComp(String key, String value) {
    bodyComposition[key] = value;
    if (key == 'Body Weight' || key == 'Height') {
      updateBMI();
      updateBMR();
    }
    notifyListeners();
  }

  void updateCircumferences(String key, String value) {
    circumferences[key] = value;
    notifyListeners();
  }

  void setWeightUnit(String val) {
    if (weightUnit == val) return;
    bool toMetric = val == 'metric';
    List<String> wKeys = [
      'Body Weight',
      'SMM',
      'SLM',
      'FFM',
      'BFM',
      'Subcutaneous Fat Mass',
      'Right Arm',
      'Left Arm',
      'Trunk',
      'Right Leg',
      'Left Leg'
    ];
    bodyComposition.updateAll((key, value) {
      if (wKeys.contains(key)) {
        double? v = double.tryParse(value);
        if (v != null) {
          return toMetric
              ? (v / 2.20462).toStringAsFixed(2)
              : (v * 2.20462).toStringAsFixed(2);
        }
      }
      return value;
    });
    weightUnit = val;
    updateBMI();
    updateBMR();
    notifyListeners();
  }

  void setDistanceUnit(String val) {
    distanceUnit = val;
    notifyListeners();
  }

  void setMeasurementUnit(String val) {
    if (measurementUnit == val) return;
    bool toMetric = val == 'metric';
    circumferences.updateAll((key, value) {
      double? v = double.tryParse(value);
      if (v != null) {
        return toMetric
            ? (v * 2.54).toStringAsFixed(2)
            : (v / 2.54).toStringAsFixed(2);
      }
      return value;
    });
    double? h = double.tryParse(bodyComposition['Height']!);
    if (h != null) {
      bodyComposition['Height'] = toMetric
          ? (h * 2.54).toStringAsFixed(2)
          : (h / 2.54).toStringAsFixed(2);
    }
    measurementUnit = val;
    updateBMI();
    updateBMR();
    notifyListeners();
  }

  void setPaired(bool val) {
    isDevicePaired = val;
    notifyListeners();
  }

  void setHolidayMode(bool val) {
    isHolidayMode = val;
    notifyListeners();
  }

  void setUnavailableMode(bool val) {
    isUnavailableMode = val;
    notifyListeners();
  }

  void setHolidayDateRange(DateTimeRange? range) {
    holidayDateRange = range;
    notifyListeners();
  }

  void saveProfile({
    required String first,
    required String last,
    required String phone,
    required String countryCode,
    required String country,
    required String region,
    required DateTime dob,
  }) {
    profileFirstName = first;
    profileLastName = last;
    profilePhone = phone;
    profileCountryCode = countryCode;
    profileCountry = country;
    profileRegion = region;
    profileDob = dob;
    updateBMR();
    notifyListeners();
  }

  void updateMedical(String type, List<String> items) {
    if (type == 'current') {
      currentInjuries = items;
      pastInjuries.removeWhere((i) => items.contains(i));
    } else if (type == 'past') {
      pastInjuries = items;
      currentInjuries.removeWhere((i) => items.contains(i));
    } else if (type == 'medical') {
      medicalConditions = items;
    } else if (type == 'goals') {
      currentGoals = items;
      traineeOmar['goals'] = List<String>.from(items);
    }
    notifyListeners();
  }

  void updateTrainingExperience(int years) {
    final option = TraineeTrainingExperienceData.optionFor(years);
    traineeTrainingExperienceYears = option.years;
    traineeOmar['trainingExperienceYears'] = option.years;
    traineeOmar['trainingExperienceLabel'] = option.label;
    notifyListeners();
  }

  void updatePreferredDiets(List<String> diets) {
    selectedPreferredDiets = List<String>.from(diets);
    traineeOmar['preferredDiets'] = List<String>.from(diets);
    traineeOmar['diet'] = TraineeDietData.summary(selectedPreferredDiets);
    notifyListeners();
  }

  void saveTraineePreferences({
    required List<String> goals,
    required int trainingExperienceYears,
    required List<String> preferredDiets,
  }) {
    currentGoals = List<String>.from(goals);
    final option =
        TraineeTrainingExperienceData.optionFor(trainingExperienceYears);
    traineeTrainingExperienceYears = option.years;
    selectedPreferredDiets = List<String>.from(preferredDiets);
    traineeOmar['goals'] = List<String>.from(currentGoals);
    traineeOmar['trainingExperienceYears'] = option.years;
    traineeOmar['trainingExperienceLabel'] = option.label;
    traineeOmar['preferredDiets'] = List<String>.from(selectedPreferredDiets);
    traineeOmar['diet'] = TraineeDietData.summary(selectedPreferredDiets);
    notifyListeners();
  }

  // Places of employment — each entry: {name, address, city, country, lat, lng, type}
  List<Map<String, dynamic>> placesOfEmployment = [
    {
      'name': 'Gold\'s Gym Elite',
      'address': '12 Sheikh Zayed Rd',
      'city': 'Cairo',
      'country': 'Egypt',
      'type': 'Gym',
      'lat': 30.0626,
      'lng': 31.2497
    },
  ];

  void addPlaceOfEmployment(Map<String, dynamic> place) {
    placesOfEmployment.add(place);
    notifyListeners();
  }

  void updatePlaceOfEmployment(int idx, Map<String, dynamic> place) {
    if (idx >= 0 && idx < placesOfEmployment.length) {
      placesOfEmployment[idx] = place;
      notifyListeners();
    }
  }

  void removePlaceOfEmployment(int idx) {
    if (idx >= 0 && idx < placesOfEmployment.length) {
      placesOfEmployment.removeAt(idx);
      notifyListeners();
    }
  }

  // Save online-only flag
  void setOnlineOnly(bool val) {
    isOnlineOnly = val;
    if (val) placesOfEmployment.clear();
    notifyListeners();
  }

  void setEmploymentMode(int mode) {
    employmentMode = mode;
    isOnlineOnly = mode == 1;
    if (isOnlineOnly) placesOfEmployment.clear();
    notifyListeners();
  }

  String payoutMethod = 'Bank';
  String paypalEmail = '';
  Map<String, String> bankAccount = {
    'bank': 'Commercial International Bank (CIB)',
    'iban': 'EG120003000000000000000000000',
    'account': '100023456789',
    'swift': 'CIBGEGCX'
  };

  void saveFinancials(
      String method, String email, Map<String, String> account) {
    payoutMethod = method;
    paypalEmail = email;
    bankAccount = Map<String, String>.from(account);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // MEMBERSHIP / SUBSCRIPTION STATE
  // ---------------------------------------------------------------------------
  /// Active plan ID for the trainer role.
  /// Values: 'trainer_free' | 'trainer_pro' | 'trainer_elite'
  String trainerPlanId = 'trainer_free';

  /// Active plan ID for the trainee role.
  /// Values: 'trainee_free' | 'trainee_plus' | 'trainee_peak'
  String traineePlanId = 'trainee_free';

  /// Billing cycle for the trainer's current plan.
  /// Values: 'monthly' | 'quarterly' | 'annual'
  String trainerBillingCycle = 'annual';

  /// Billing cycle for the trainee's current plan.
  String traineeBillingCycle = 'annual';

  /// Date the trainer's plan was last changed.
  DateTime? trainerPlanActivatedAt;

  /// Date the trainee's plan was last changed.
  DateTime? traineePlanActivatedAt;

  void setTrainerPlan(String planId, {String cycle = 'annual'}) {
    trainerPlanId = planId;
    trainerBillingCycle = cycle;
    trainerPlanActivatedAt = DateTime.now();
    notifyListeners();
  }

  void setTraineePlan(String planId, {String cycle = 'annual'}) {
    traineePlanId = planId;
    traineeBillingCycle = cycle;
    traineePlanActivatedAt = DateTime.now();
    notifyListeners();
  }

  /// Returns a human-readable label for the active trainer plan.
  String get trainerPlanLabel {
    switch (trainerPlanId) {
      case 'trainer_pro':
        return 'Pro';
      case 'trainer_elite':
        return 'Elite';
      default:
        return 'Starter (Free)';
    }
  }

  /// Returns a human-readable label for the active trainee plan.
  String get traineePlanLabel {
    switch (traineePlanId) {
      case 'trainee_plus':
        return 'Plus';
      case 'trainee_peak':
        return 'Peak';
      default:
        return 'Free';
    }
  }

  bool get trainerIsPremium =>
      trainerPlanId == 'trainer_pro' || trainerPlanId == 'trainer_elite';

  bool get traineeIsPremium =>
      traineePlanId == 'trainee_plus' || traineePlanId == 'trainee_peak';

  void resetSession() {
    isHolidayMode = false;
    isUnavailableMode = false;
    holidayDateRange = null;
    notifyListeners();
  }
}

final appState = AppState();
