import 'package:flutter/foundation.dart';
import 'package:nutrinotion_app/backend/services/firestore_services.dart';
import 'package:nutrinotion_app/backend/services/calorie_tracking_service.dart';

class PersonalizedFoodProvider with ChangeNotifier {

  final firestoreServices = FirestoreServices();
  final calorieTrackingService = CalorieTrackingService();

  // Getters
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _personalizedMenu;
  int _totalCalories = 0;
  bool _isCaloriesFetching = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get personalizedMenu => _personalizedMenu;
  int get totalCalories => _totalCalories;
  bool get isCaloriesFetching => _isCaloriesFetching;

  Future<int> getTotalCaloriesForDate(String userId, String date) async {
    try {
      final totalCalories = await calorieTrackingService.getCheckedCalories(userId, date);
      _totalCalories = totalCalories;
      notifyListeners();
      return totalCalories;
    } catch (e) {
      print('Error fetching calories: $e');
      return 0;
    }
  }

  Future<void> getPersonalizedFood(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      print("Loading....");
      _personalizedMenu = await firestoreServices.getPersonalizedMenuData(userId);
      print("Personalized Menu: $_personalizedMenu");
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePersonalizedFood({
    required String userId,
    required String day,
    required String mealType,
    required List<Map<String, dynamic>> updatedItems
  }) async {
    try {
      await firestoreServices.updatePersonalizedFood(
        userId: userId,
        day: day,
        mealType: mealType,
        updatedItems: updatedItems
      );
      
      // Update local state
      if (_personalizedMenu != null) {
        _personalizedMenu![day][mealType] = updatedItems;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      throw Exception('Failed to update personalized food: $e');
    }
  }

  // Add a new item to personalized menu
  Future<void> addToPersonalizedMenu({
    required String userId,
    required String day,
    required String mealType,
    required Map<String, dynamic> newItem,
  }) async {
    try {
      // Ensure we have the latest data
      await getPersonalizedFood(userId);

      // Initialize the menu structure if needed
      _personalizedMenu ??= {};
      _personalizedMenu![day] ??= {};
      _personalizedMenu![day][mealType] ??= [];

      // Get current items for this meal
      List<Map<String, dynamic>> mealItems = List<Map<String, dynamic>>.from(_personalizedMenu![day][mealType]);
      
      // Keep the original structure but add required fields
      newItem['isChecked'] = true;
      newItem['lastCheckedAt'] = DateTime.now().toIso8601String();
      if (!newItem.containsKey('quantity')) {
        newItem['quantity'] = '1 serving';
      }
      
      // Check if item already exists
      bool itemExists = mealItems.any((item) => item['item'] == newItem['item']);
      if (!itemExists) {
        // Add the new item
        mealItems.add(newItem);
        
        // Update the menu
        await firestoreServices.updatePersonalizedFood(
          userId: userId,
          day: day,
          mealType: mealType,
          updatedItems: mealItems
        );
        
        // Update local state
        _personalizedMenu![day][mealType] = mealItems;
        notifyListeners();

        // Update calorie tracking
        await calorieTrackingService.updateCalorieIntake(
          userId: userId,
          date: day,
          calories: int.parse(newItem['calories'].toString()),
          isIncrement: true,
          itemKey: '${mealType.toLowerCase()}_${newItem['item']}',
          itemName: newItem['item'],
          mealType: mealType
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      throw Exception('Failed to add item to personalized menu: $e');
    }
  }
}
