import 'package:equatable/equatable.dart';

/// Represents a single food item with its full nutritional profile.
///
/// Contains exactly 32 whitelisted nutrients extracted from the FNDDS
/// survey JSON, organised into macros, vitamins, and minerals.
class FoodNutritionData extends Equatable {
  final int fdcId;
  final String description;

  // --- Macronutrients (g) ---
  final double carbohydrates;
  final double proteins;
  final double fats;

  // --- Vitamins ---
  final double vitaminA; // µg – retinoids, carotenoids
  final double vitaminB1; // mg – thiamine
  final double vitaminB2; // mg – riboflavin
  final double vitaminB3; // mg – niacin
  final double vitaminB5; // mg – pantothenic acid
  final double vitaminB6; // mg – pyridoxine
  final double vitaminB7; // µg – biotin
  final double vitaminB9; // µg – folate
  final double vitaminB12; // µg – cobalamin
  final double vitaminC; // mg – ascorbic acid
  final double vitaminD; // µg – D2 + D3
  final double vitaminE; // mg – tocopherols, tocotrienols
  final double vitaminK; // µg – phylloquinone, menaquinones

  // --- Minerals ---
  final double calcium; // mg
  final double phosphorus; // mg
  final double magnesium; // mg
  final double sodium; // mg
  final double potassium; // mg
  final double chloride; // mg
  final double sulfur; // mg
  final double iron; // mg
  final double zinc; // mg
  final double copper; // mg
  final double manganese; // mg
  final double iodine; // µg
  final double selenium; // µg
  final double fluoride; // µg
  final double chromium; // µg
  final double molybdenum; // µg

  const FoodNutritionData({
    required this.fdcId,
    required this.description,
    this.carbohydrates = 0.0,
    this.proteins = 0.0,
    this.fats = 0.0,
    this.vitaminA = 0.0,
    this.vitaminB1 = 0.0,
    this.vitaminB2 = 0.0,
    this.vitaminB3 = 0.0,
    this.vitaminB5 = 0.0,
    this.vitaminB6 = 0.0,
    this.vitaminB7 = 0.0,
    this.vitaminB9 = 0.0,
    this.vitaminB12 = 0.0,
    this.vitaminC = 0.0,
    this.vitaminD = 0.0,
    this.vitaminE = 0.0,
    this.vitaminK = 0.0,
    this.calcium = 0.0,
    this.phosphorus = 0.0,
    this.magnesium = 0.0,
    this.sodium = 0.0,
    this.potassium = 0.0,
    this.chloride = 0.0,
    this.sulfur = 0.0,
    this.iron = 0.0,
    this.zinc = 0.0,
    this.copper = 0.0,
    this.manganese = 0.0,
    this.iodine = 0.0,
    this.selenium = 0.0,
    this.fluoride = 0.0,
    this.chromium = 0.0,
    this.molybdenum = 0.0,
  });

  @override
  List<Object?> get props => [
        fdcId,
        description,
        carbohydrates,
        proteins,
        fats,
        vitaminA,
        vitaminB1,
        vitaminB2,
        vitaminB3,
        vitaminB5,
        vitaminB6,
        vitaminB7,
        vitaminB9,
        vitaminB12,
        vitaminC,
        vitaminD,
        vitaminE,
        vitaminK,
        calcium,
        phosphorus,
        magnesium,
        sodium,
        potassium,
        chloride,
        sulfur,
        iron,
        zinc,
        copper,
        manganese,
        iodine,
        selenium,
        fluoride,
        chromium,
        molybdenum,
      ];
}

/// Defines a displayable nutrient column with its name, unit, and
/// corresponding value extractor from a [FoodNutritionData] instance.
class NutrientColumn {
  final String displayName;
  final String unit;
  final double Function(FoodNutritionData) valueExtractor;

  const NutrientColumn({
    required this.displayName,
    required this.unit,
    required this.valueExtractor,
  });

  /// The full header label used in the DataTable, e.g. "Vitamin A (retinoids) µg"
  /// If [displayName] contains parentheses, the UI splits them into two lines.
  String get headerLabel => '$displayName [$unit]';
}

/// Ordered list of all 32 nutrient columns for display.
const List<NutrientColumn> kNutrientColumns = [
  // Macros
  NutrientColumn(
    displayName: 'Carbohydrates',
    unit: 'g',
    valueExtractor: _carbs,
  ),
  NutrientColumn(
    displayName: 'Proteins',
    unit: 'g',
    valueExtractor: _protein,
  ),
  NutrientColumn(
    displayName: 'Fats',
    unit: 'g',
    valueExtractor: _fats,
  ),
  // Vitamins
  NutrientColumn(
    displayName: 'Vitamin A (retinoids, carotenoids)',
    unit: 'µg',
    valueExtractor: _vitA,
  ),
  NutrientColumn(
    displayName: 'Vitamin B1 (thiamine)',
    unit: 'mg',
    valueExtractor: _vitB1,
  ),
  NutrientColumn(
    displayName: 'Vitamin B2 (riboflavin)',
    unit: 'mg',
    valueExtractor: _vitB2,
  ),
  NutrientColumn(
    displayName: 'Vitamin B3 (niacin)',
    unit: 'mg',
    valueExtractor: _vitB3,
  ),
  NutrientColumn(
    displayName: 'Vitamin B5 (pantothenic acid)',
    unit: 'mg',
    valueExtractor: _vitB5,
  ),
  NutrientColumn(
    displayName: 'Vitamin B6 (pyridoxine)',
    unit: 'mg',
    valueExtractor: _vitB6,
  ),
  NutrientColumn(
    displayName: 'Vitamin B7 (biotin)',
    unit: 'µg',
    valueExtractor: _vitB7,
  ),
  NutrientColumn(
    displayName: 'Vitamin B9 (folate)',
    unit: 'µg',
    valueExtractor: _vitB9,
  ),
  NutrientColumn(
    displayName: 'Vitamin B12 (cobalamin)',
    unit: 'µg',
    valueExtractor: _vitB12,
  ),
  NutrientColumn(
    displayName: 'Vitamin C (ascorbic acid)',
    unit: 'mg',
    valueExtractor: _vitC,
  ),
  NutrientColumn(
    displayName: 'Vitamin D (D2 + D3)',
    unit: 'µg',
    valueExtractor: _vitD,
  ),
  NutrientColumn(
    displayName: 'Vitamin E (tocopherols)',
    unit: 'mg',
    valueExtractor: _vitE,
  ),
  NutrientColumn(
    displayName: 'Vitamin K (phylloquinone)',
    unit: 'µg',
    valueExtractor: _vitK,
  ),
  // Minerals
  NutrientColumn(
    displayName: 'Calcium',
    unit: 'mg',
    valueExtractor: _calcium,
  ),
  NutrientColumn(
    displayName: 'Phosphorus',
    unit: 'mg',
    valueExtractor: _phosphorus,
  ),
  NutrientColumn(
    displayName: 'Magnesium',
    unit: 'mg',
    valueExtractor: _magnesium,
  ),
  NutrientColumn(
    displayName: 'Sodium',
    unit: 'mg',
    valueExtractor: _sodium,
  ),
  NutrientColumn(
    displayName: 'Potassium',
    unit: 'mg',
    valueExtractor: _potassium,
  ),
  NutrientColumn(
    displayName: 'Chloride',
    unit: 'mg',
    valueExtractor: _chloride,
  ),
  NutrientColumn(
    displayName: 'Sulfur',
    unit: 'mg',
    valueExtractor: _sulfur,
  ),
  NutrientColumn(
    displayName: 'Iron',
    unit: 'mg',
    valueExtractor: _iron,
  ),
  NutrientColumn(
    displayName: 'Zinc',
    unit: 'mg',
    valueExtractor: _zinc,
  ),
  NutrientColumn(
    displayName: 'Copper',
    unit: 'mg',
    valueExtractor: _copper,
  ),
  NutrientColumn(
    displayName: 'Manganese',
    unit: 'mg',
    valueExtractor: _manganese,
  ),
  NutrientColumn(
    displayName: 'Iodine',
    unit: 'µg',
    valueExtractor: _iodine,
  ),
  NutrientColumn(
    displayName: 'Selenium',
    unit: 'µg',
    valueExtractor: _selenium,
  ),
  NutrientColumn(
    displayName: 'Fluoride',
    unit: 'µg',
    valueExtractor: _fluoride,
  ),
  NutrientColumn(
    displayName: 'Chromium',
    unit: 'µg',
    valueExtractor: _chromium,
  ),
  NutrientColumn(
    displayName: 'Molybdenum',
    unit: 'µg',
    valueExtractor: _molybdenum,
  ),
];

// --- Value extractor functions (required by const constructor) ---
double _carbs(FoodNutritionData d) => d.carbohydrates;
double _protein(FoodNutritionData d) => d.proteins;
double _fats(FoodNutritionData d) => d.fats;
double _vitA(FoodNutritionData d) => d.vitaminA;
double _vitB1(FoodNutritionData d) => d.vitaminB1;
double _vitB2(FoodNutritionData d) => d.vitaminB2;
double _vitB3(FoodNutritionData d) => d.vitaminB3;
double _vitB5(FoodNutritionData d) => d.vitaminB5;
double _vitB6(FoodNutritionData d) => d.vitaminB6;
double _vitB7(FoodNutritionData d) => d.vitaminB7;
double _vitB9(FoodNutritionData d) => d.vitaminB9;
double _vitB12(FoodNutritionData d) => d.vitaminB12;
double _vitC(FoodNutritionData d) => d.vitaminC;
double _vitD(FoodNutritionData d) => d.vitaminD;
double _vitE(FoodNutritionData d) => d.vitaminE;
double _vitK(FoodNutritionData d) => d.vitaminK;
double _calcium(FoodNutritionData d) => d.calcium;
double _phosphorus(FoodNutritionData d) => d.phosphorus;
double _magnesium(FoodNutritionData d) => d.magnesium;
double _sodium(FoodNutritionData d) => d.sodium;
double _potassium(FoodNutritionData d) => d.potassium;
double _chloride(FoodNutritionData d) => d.chloride;
double _sulfur(FoodNutritionData d) => d.sulfur;
double _iron(FoodNutritionData d) => d.iron;
double _zinc(FoodNutritionData d) => d.zinc;
double _copper(FoodNutritionData d) => d.copper;
double _manganese(FoodNutritionData d) => d.manganese;
double _iodine(FoodNutritionData d) => d.iodine;
double _selenium(FoodNutritionData d) => d.selenium;
double _fluoride(FoodNutritionData d) => d.fluoride;
double _chromium(FoodNutritionData d) => d.chromium;
double _molybdenum(FoodNutritionData d) => d.molybdenum;
