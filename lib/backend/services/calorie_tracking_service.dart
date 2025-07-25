import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class CalorieTrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Update food item checked status in personalizedMenu
  Future<void> updateCalorieIntake({
    required String userId,
    required String date,
    required int calories,
    required bool isIncrement,
    required String itemKey,
    required String itemName,
    required String mealType
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final calorieTrackingRef = userRef.collection('calorie_tracking');
      
      // Convert date to day name for menu lookup
      final DateTime dateTime = DateTime.parse(date);
      final String dayName = _getDayName(dateTime.weekday);
      
      // First, update the menu item's checked status
      await _updateMenuItemStatus(userRef, dayName, mealType, itemName, isIncrement);
      
      // Then, update the calorie tracking collection with just the total calories
      final dateDoc = await calorieTrackingRef.doc(date).get();
      if (dateDoc.exists) {
        // Update existing entry
        Map<String, dynamic> currentData = dateDoc.data() as Map<String, dynamic>;
        int currentTotal = currentData['calories'] ?? 0;
        
        await calorieTrackingRef.doc(date).update({
          'calories': isIncrement ? currentTotal + calories : currentTotal - calories,
          'lastUpdated': DateTime.now().toIso8601String()
        });
      } else {
        // Create new entry for the date with initial calories
        await calorieTrackingRef.doc(date).set({
          'calories': isIncrement ? calories : 0,
          'date': date,
          'lastUpdated': DateTime.now().toIso8601String()
        });
      }
    } catch (e) {
      print('Error updating calorie intake: $e');
      throw e;
    }
  }
  
  // Helper method to convert weekday number to day name
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Monday';
    }
  }
  
  // Helper method to update the menu item's checked status
  Future<void> _updateMenuItemStatus(
    DocumentReference userRef,
    String dayName,
    String mealType,
    String itemName,
    bool isChecked
  ) async {
    print('Updating menu item status: $itemName in $mealType for $dayName to $isChecked');
    final userDoc = await userRef.get();
    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;
      Map<String, dynamic> personalizedMenu = Map<String, dynamic>.from(data['personalizedMenu'] ?? {});
      Map<String, dynamic> dayMenu = Map<String, dynamic>.from(personalizedMenu[dayName] ?? {});
      List<Map<String, dynamic>> mealItems = List<Map<String, dynamic>>.from(dayMenu[mealType] ?? []);
      
      bool itemFound = false;
      for (int i = 0; i < mealItems.length; i++) {
        if (mealItems[i]['item'] == itemName) {
          Map<String, dynamic> updatedItem = Map<String, dynamic>.from(mealItems[i]);
          updatedItem['isChecked'] = isChecked;
          updatedItem['lastCheckedAt'] = DateTime.now().toIso8601String();
          mealItems[i] = updatedItem;
          itemFound = true;
          print('Item found and updated: ${updatedItem}');
          break;
        }
      }
      
      if (!itemFound) {
        print('Warning: Item $itemName not found in $mealType for $dayName');
        print('Available items: ${mealItems.map((item) => item['item']).toList()}');
      }
      
      dayMenu[mealType] = mealItems;
      personalizedMenu[dayName] = dayMenu;
      await userRef.update({'personalizedMenu': personalizedMenu});
      print('Database updated successfully');
    } else {
      print('Error: User document does not exist');
    }
  }

  // Get checked status and calorie intake for items on a specific date
  Future<Map<String, dynamic>> getMenuStatus(String userId, String date) async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final personalizedMenu = userDoc.data()?['personalizedMenu'];
        if (personalizedMenu != null && personalizedMenu[date] != null) {
          return Map<String, dynamic>.from(personalizedMenu[date]);
        }
      }
      return {};
    } catch (e) {
      print('Error getting menu status: $e');
      return {};
    }
  }

  // Get total calories for a specific date from calorie_tracking collection
  Future<int> getCheckedCalories(String userId, String date) async {
    try {
      final calorieDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('calorie_tracking')
          .doc(date)
          .get();

      if (calorieDoc.exists) {
        final data = calorieDoc.data();
        return data?['calories'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error calculating checked calories: $e');
      return 0;
    }
  }

  // Get calorie intake for a date range
  Future<Map<String, int>> getCalorieIntakeRange(
    String userId, 
    DateTime startDate,
    DateTime endDate
  ) async {
    try {
      final Map<String, int> calorieData = {};
      
      // Format dates for query
      final start = UserModel.formatDate(startDate);
      final end = UserModel.formatDate(endDate);

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('calorie_tracking')
          .where('date', isGreaterThanOrEqualTo: start)
          .where('date', isLessThanOrEqualTo: end)
          .get();

      for (var doc in querySnapshot.docs) {
        calorieData[doc.id] = doc.data()['calories'] ?? 0;
      }

      return calorieData;
    } catch (e) {
      print('Error getting calorie intake range: $e');
      return {};
    }
  }
}
