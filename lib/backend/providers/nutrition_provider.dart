import 'package:flutter/foundation.dart';
import 'package:nutrinotion_app/backend/models/user_model.dart';
import 'package:nutrinotion_app/backend/services/firestore_services.dart';

class NutritionProvider with ChangeNotifier {
  List<Map<String, dynamic>> _meals = [];
  Map<String, dynamic> _dailyNutrition = {};
  Map<String, dynamic> _nutritionGoals = {};
  List<Map<String, dynamic>> _foodHistory = [];
  bool _isLoading = false;
  String? _errorMessage;
  final FirestoreServices _firestoreServices = FirestoreServices();

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

  // Calculate BMR using Mifflin-St Jeor Equation
  double _calculateBMR(UserModel user) {
    if (user.weight == null || user.height == null || user.age == null) {
      return 0.0;
    }

    double bmr;
    if (user.gender == 'Male') {
      bmr = (10 * user.weight!) + (6.25 * user.height!) - (5 * user.age!) + 5;
    } else {
      bmr = (10 * user.weight!) + (6.25 * user.height!) - (5 * user.age!) - 161;
    }
    return bmr;
  }

  // Calculate daily calorie needs based on activity level and fitness goal
  int _calculateDailyCalories(UserModel user) {
    double bmr = _calculateBMR(user);
    if (bmr == 0) return 0;

    double activityMultiplier;
    switch (user.activityLevel) {
      case 'Sedentary':
        activityMultiplier = 1.2;
        break;
      case 'Moderate':
        activityMultiplier = 1.55;
        break;
      case 'Active':
        activityMultiplier = 1.725;
        break;
      default:
        activityMultiplier = 1.55;
    }

    // Calculate maintenance calories
    double maintenanceCalories = bmr * activityMultiplier;

    // Adjust calories based on fitness goal
    int goalAdjustment = 0;
    switch (user.fitnessGoal) {
      case 'Gain Weight':
        goalAdjustment = 250; // Add 250 calories for weight gain
        break;
      case 'Lose Weight':
        goalAdjustment = -250; // Subtract 250 calories for weight loss
        break;
      case 'Maintain Fitness':
        goalAdjustment = 100; // Add 100 calories for maintenance
        break;
      default:
        goalAdjustment = 0; // No adjustment if goal is not specified
    }

    return (maintenanceCalories + goalAdjustment).round();
  }

  // Calculate nutrition goals based on calorie target
  Map<String, dynamic> _calculateNutritionGoals(int calorieTarget) {
    return {
      'calories': calorieTarget,
      'protein':
          (calorieTarget * 0.25 / 4).round(), // 25% of calories from protein
      'carbs': (calorieTarget * 0.45 / 4).round(), // 45% of calories from carbs
      'fat': (calorieTarget * 0.30 / 9).round(), // 30% of calories from fat
      'fiber': 25, // Recommended daily fiber intake
      'sugar': (calorieTarget * 0.10 / 4).round(), // 10% of calories from sugar
      'sodium': 2300, // Recommended daily sodium intake in mg
    };
  }

  // Recalculate and save user nutrition data after profile changes
  Future<void> recalculateAndSaveUserNutrition(UserModel user) async {
    try {
      setLoading(true);
      clearError();

      // Calculate new calorie target
      int newCalorieTarget = _calculateDailyCalories(user);

      // Calculate new nutrition goals
      Map<String, dynamic> newNutritionGoals =
          _calculateNutritionGoals(newCalorieTarget);

      // Update user's calorie target
      user.calorieTargetPerDay = newCalorieTarget;

      // Update nutrition goals
      _nutritionGoals = newNutritionGoals;

      // Save updated user data to Firestore
      await _firestoreServices.saveUserDetails(user);

      // Save nutrition goals to user document
      await _firestoreServices.updateUserNutritionGoals(
          user.userId!, newNutritionGoals);

      notifyListeners();
    } catch (e) {
      setError('Failed to recalculate nutrition: $e');
      print('Error recalculating nutrition: $e');
    } finally {
      setLoading(false);
    }
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
      totals['calories'] =
          (totals['calories'] ?? 0.0) + (meal['calories'] ?? 0.0);
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
    if (!_dailyNutrition.containsKey(nutrient) ||
        !_nutritionGoals.containsKey(nutrient)) {
      return 0.0;
    }

    double current = _dailyNutrition[nutrient]?.toDouble() ?? 0.0;
    double goal = _nutritionGoals[nutrient]?.toDouble() ?? 1.0;

    return goal > 0 ? (current / goal) * 100 : 0.0;
  }

  // Get remaining amount for a specific nutrient
  double getRemainingNutrient(String nutrient) {
    if (!_dailyNutrition.containsKey(nutrient) ||
        !_nutritionGoals.containsKey(nutrient)) {
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
