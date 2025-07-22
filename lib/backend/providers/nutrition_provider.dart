import 'package:flutter/foundation.dart';

class NutritionProvider with ChangeNotifier {
  List<Map<String, dynamic>> _meals = [];
  Map<String, dynamic> _dailyNutrition = {};
  Map<String, dynamic> _nutritionGoals = {};
  List<Map<String, dynamic>> _foodHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Map<String, dynamic>> get meals => _meals;
  Map<String, dynamic> get dailyNutrition => _dailyNutrition;
  Map<String, dynamic> get nutritionGoals => _nutritionGoals;
  List<Map<String, dynamic>> get foodHistory => _foodHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Add a meal
  void addMeal(Map<String, dynamic> meal) {
    _meals.add(meal);
    _updateDailyNutrition();
    notifyListeners();
  }

  // Remove a meal
  void removeMeal(int index) {
    if (index >= 0 && index < _meals.length) {
      _meals.removeAt(index);
      _updateDailyNutrition();
      notifyListeners();
    }
  }

  // Update a meal
  void updateMeal(int index, Map<String, dynamic> updatedMeal) {
    if (index >= 0 && index < _meals.length) {
      _meals[index] = updatedMeal;
      _updateDailyNutrition();
      notifyListeners();
    }
  }

  // Set nutrition goals
  void setNutritionGoals(Map<String, dynamic> goals) {
    _nutritionGoals = goals;
    notifyListeners();
  }

  // Update specific nutrition goal
  void updateNutritionGoal(String nutrient, dynamic value) {
    _nutritionGoals[nutrient] = value;
    notifyListeners();
  }

  // Add food to history
  void addToFoodHistory(Map<String, dynamic> food) {
    _foodHistory.insert(0, food); // Add to beginning of list
    // Keep only last 50 items
    if (_foodHistory.length > 50) {
      _foodHistory = _foodHistory.take(50).toList();
    }
    notifyListeners();
  }

  // Clear all meals
  void clearMeals() {
    _meals.clear();
    _dailyNutrition.clear();
    notifyListeners();
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Private method to update daily nutrition totals
  void _updateDailyNutrition() {
    Map<String, dynamic> totals = {
      'calories': 0.0,
      'protein': 0.0,
      'carbs': 0.0,
      'fat': 0.0,
      'fiber': 0.0,
      'sugar': 0.0,
      'sodium': 0.0,
    };

    for (var meal in _meals) {
      totals['calories'] = (totals['calories'] ?? 0.0) + (meal['calories'] ?? 0.0);
      totals['protein'] = (totals['protein'] ?? 0.0) + (meal['protein'] ?? 0.0);
      totals['carbs'] = (totals['carbs'] ?? 0.0) + (meal['carbs'] ?? 0.0);
      totals['fat'] = (totals['fat'] ?? 0.0) + (meal['fat'] ?? 0.0);
      totals['fiber'] = (totals['fiber'] ?? 0.0) + (meal['fiber'] ?? 0.0);
      totals['sugar'] = (totals['sugar'] ?? 0.0) + (meal['sugar'] ?? 0.0);
      totals['sodium'] = (totals['sodium'] ?? 0.0) + (meal['sodium'] ?? 0.0);
    }

    _dailyNutrition = totals;
  }

  // Get progress percentage for a specific nutrient
  double getNutrientProgress(String nutrient) {
    if (!_dailyNutrition.containsKey(nutrient) || !_nutritionGoals.containsKey(nutrient)) {
      return 0.0;
    }
    
    double current = _dailyNutrition[nutrient]?.toDouble() ?? 0.0;
    double goal = _nutritionGoals[nutrient]?.toDouble() ?? 1.0;
    
    return goal > 0 ? (current / goal) * 100 : 0.0;
  }

  // Get remaining amount for a specific nutrient
  double getRemainingNutrient(String nutrient) {
    if (!_dailyNutrition.containsKey(nutrient) || !_nutritionGoals.containsKey(nutrient)) {
      return 0.0;
    }
    
    double current = _dailyNutrition[nutrient]?.toDouble() ?? 0.0;
    double goal = _nutritionGoals[nutrient]?.toDouble() ?? 0.0;
    
    return goal - current;
  }

  // Check if daily goals are met
  bool areGoalsMet() {
    for (String nutrient in _nutritionGoals.keys) {
      if (getNutrientProgress(nutrient) < 100) {
        return false;
      }
    }
    return true;
  }

  // Get meal by type (breakfast, lunch, dinner, snacks)
  List<Map<String, dynamic>> getMealsByType(String mealType) {
    return _meals.where((meal) => meal['type'] == mealType).toList();
  }

  // Get total calories for specific meal type
  double getCaloriesForMealType(String mealType) {
    var meals = getMealsByType(mealType);
    return meals.fold(0.0, (total, meal) => total + (meal['calories'] ?? 0.0));
  }
}
