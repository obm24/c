import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/m_programmes_food_nutrition_model.dart';

/// Offline nutrition database that parses the FNDDS survey JSON file.
///
/// Usage:
/// ```dart
/// final db = NutritionDatabase();
/// await db.load();
/// final results = db.search('chicken');
/// ```
class NutritionDatabase {
  List<FoodNutritionData> _foods = [];

  /// Whether the database has been loaded.
  bool get isLoaded => _foods.isNotEmpty;

  /// All parsed foods — available after [load] completes.
  List<FoodNutritionData> get allFoods => _foods;

  /// Loads and parses the JSON from the bundled asset.
  Future<void> load() async {
    if (_foods.isNotEmpty) return; // Already loaded
    final String jsonString =
        await rootBundle.loadString('assets/food-data/generic-food.json');
    _foods = parseFromJson(jsonString);
  }

  /// Core parser — takes the raw JSON string and returns the filtered
  /// list of [FoodNutritionData] with only the 32 whitelisted nutrients.
  List<FoodNutritionData> parseFromJson(String jsonString) {
    final Map<String, dynamic> jsonRoot = json.decode(jsonString);
    final List<dynamic> surveyFoods = jsonRoot['SurveyFoods'] as List<dynamic>;

    final List<FoodNutritionData> result = [];

    for (final dynamic item in surveyFoods) {
      final Map<String, dynamic> food = item as Map<String, dynamic>;
      final String description = food['description'] as String? ?? '';
      final int fdcId = food['fdcId'] as int? ?? 0;
      final List<dynamic> nutrients =
          food['foodNutrients'] as List<dynamic>? ?? [];

      // Helper: find nutrient amount by checking multiple valid names.
      double getNutrient(List<String> validNames) {
        for (final dynamic n in nutrients) {
          final Map<String, dynamic> nutrientData = n as Map<String, dynamic>;
          final Map<String, dynamic>? nutrientInfo =
              nutrientData['nutrient'] as Map<String, dynamic>?;
          if (nutrientInfo == null) continue;
          final String name = nutrientInfo['name'] as String? ?? '';
          if (validNames
              .any((valid) => name.toLowerCase() == valid.toLowerCase())) {
            return (nutrientData['amount'] as num?)?.toDouble() ?? 0.0;
          }
        }
        return 0.0; // Failsafe default
      }

      result.add(FoodNutritionData(
        fdcId: fdcId,
        description: description,

        // Macronutrients
        carbohydrates: getNutrient([
          'Carbohydrate, by difference',
          'Total Carbohydrate',
          'Carbohydrates',
        ]),
        proteins: getNutrient([
          'Protein',
          'Total Protein',
        ]),
        fats: getNutrient([
          'Total lipid (fat)',
          'Total Fat',
        ]),

        // Vitamins
        vitaminA: getNutrient([
          'Vitamin A, RAE',
          'Vitamin A',
          'Retinol',
        ]),
        vitaminB1: getNutrient([
          'Thiamin',
          'Vitamin B1',
          'Thiamine',
        ]),
        vitaminB2: getNutrient([
          'Riboflavin',
          'Vitamin B2',
        ]),
        vitaminB3: getNutrient([
          'Niacin',
          'Vitamin B3',
        ]),
        vitaminB5: getNutrient([
          'Pantothenic acid',
          'Vitamin B5',
        ]),
        vitaminB6: getNutrient([
          'Vitamin B-6',
          'Vitamin B6',
          'Pyridoxine',
        ]),
        vitaminB7: getNutrient([
          'Biotin',
          'Vitamin B7',
        ]),
        vitaminB9: getNutrient([
          'Folate, total',
          'Folate, DFE',
          'Folate',
          'Vitamin B9',
        ]),
        vitaminB12: getNutrient([
          'Vitamin B-12',
          'Vitamin B12',
          'Cobalamin',
        ]),
        vitaminC: getNutrient([
          'Vitamin C, total ascorbic acid',
          'Vitamin C',
        ]),
        vitaminD: getNutrient([
          'Vitamin D (D2 + D3)',
          'Vitamin D',
        ]),
        vitaminE: getNutrient([
          'Vitamin E (alpha-tocopherol)',
          'Vitamin E',
        ]),
        vitaminK: getNutrient([
          'Vitamin K (phylloquinone)',
          'Vitamin K',
        ]),

        // Minerals
        calcium: getNutrient([
          'Calcium, Ca',
          'Calcium',
        ]),
        phosphorus: getNutrient([
          'Phosphorus, P',
          'Phosphorus',
        ]),
        magnesium: getNutrient([
          'Magnesium, Mg',
          'Magnesium',
        ]),
        sodium: getNutrient([
          'Sodium, Na',
          'Sodium',
        ]),
        potassium: getNutrient([
          'Potassium, K',
          'Potassium',
        ]),
        chloride: getNutrient([
          'Chloride, Cl',
          'Chloride',
        ]),
        sulfur: getNutrient([
          'Sulfur, S',
          'Sulfur',
        ]),
        iron: getNutrient([
          'Iron, Fe',
          'Iron',
        ]),
        zinc: getNutrient([
          'Zinc, Zn',
          'Zinc',
        ]),
        copper: getNutrient([
          'Copper, Cu',
          'Copper',
        ]),
        manganese: getNutrient([
          'Manganese, Mn',
          'Manganese',
        ]),
        iodine: getNutrient([
          'Iodine, I',
          'Iodine',
        ]),
        selenium: getNutrient([
          'Selenium, Se',
          'Selenium',
        ]),
        fluoride: getNutrient([
          'Fluoride, F',
          'Fluoride',
        ]),
        chromium: getNutrient([
          'Chromium, Cr',
          'Chromium',
        ]),
        molybdenum: getNutrient([
          'Molybdenum, Mo',
          'Molybdenum',
        ]),
      ));
    }

    return result;
  }

  /// Search foods by description. Case-insensitive partial matching.
  /// Each keyword must appear in the description for a match.
  List<FoodNutritionData> search(String query) {
    if (query.trim().isEmpty) return [];
    final keywords =
        query.toLowerCase().split(RegExp(r'\s+')).where((k) => k.isNotEmpty);
    return _foods.where((food) {
      final desc = food.description.toLowerCase();
      return keywords.every((kw) => desc.contains(kw));
    }).toList();
  }
}
