import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutrinotion_app/backend/models/user_model.dart';

class FirestoreServices {
  // Instance of Firestore,
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add User Details (for new users)
  Future<void> addUserDetails(UserModel user) async {
    try {
      if (user.userId == null) {
        throw Exception('User ID is required');
      }
      await _firestore.collection('users').doc(user.userId).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to add user details: $e');
    }
  }

  // Update User Details (for existing users)
  Future<void> updateUserDetails(UserModel user) async {
    try {
      if (user.userId == null) {
        throw Exception('User ID is required');
      }
      await _firestore.collection('users').doc(user.userId).update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user details: $e');
    }
  }

  // Update User Nutrition Goals
  Future<void> updateUserNutritionGoals(String userId, Map<String, dynamic> nutritionGoals) async {
    try {
      if (userId.isEmpty) {
        throw Exception('User ID is required');
      }
      await _firestore.collection('users').doc(userId).update({
        'nutritionGoals': nutritionGoals,
        'lastNutritionUpdate': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update nutrition goals: $e');
    }
  }

  // Save or Update User Details (handles both new and existing users)
  Future<void> saveUserDetails(UserModel user) async {
    try {
      if (user.userId == null) {
        throw Exception('User ID is required');
      }
      await _firestore.collection('users').doc(user.userId).set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user details: $e');
    }
  }

  // Get User Details
  Future<UserModel?> getUserDetails(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user details: $e');
    }
  }

  // Delete User Details
  Future<void> deleteUserDetails(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user details: $e');
    }
  }

  // Update Personalized menu
  Future<void> updatePersonalizedMenu(String userId, Map<String, dynamic> menuData) async {
    if(menuData.isEmpty) {
      return;
    }
    
    try {
      menuData['lastGeneratedDate'] = DateTime.now();
      await _firestore.collection('users').doc(userId).update({'personalizedMenu': menuData});
    } catch (e) {
      throw Exception('Failed to update personalized menu: $e');
    }
  }

  // Update specific meal items in personalized menu
  Future<void> updatePersonalizedFood({
    required String userId,
    required String day,
    required String mealType,
    required List<Map<String, dynamic>> updatedItems
  }) async {
    try {
      // First get the current menu
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('personalizedMenu')) {
          Map<String, dynamic> personalizedMenu = Map<String, dynamic>.from(data['personalizedMenu']);
          
          // Update the specific meal items
          if (personalizedMenu.containsKey(day)) {
            personalizedMenu[day][mealType] = updatedItems;
          }
          
          // Update the document
          await _firestore.collection('users').doc(userId).update({
            'personalizedMenu': personalizedMenu
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to update personalized food: $e');
    }
  }

  // Check for Personalized Food
  Future<bool> checkForPersonalizedFood(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;

        if(!data.containsKey('personalizedMenu')) {
          return true;
        }

        final personalizedMenu = data['personalizedMenu'];
        print("shouldGenerateMenu" + shouldGenerateMenu(personalizedMenu['lastGeneratedDate']).toString());
        return shouldGenerateMenu(personalizedMenu['lastGeneratedDate']);
      }
      print("Returning false as no personalized menu found");
      return false;
    } catch (e) {
      throw Exception('Failed to check for personalized food: $e');
    }
  }

  bool shouldGenerateMenu(DateTime? lastGeneratedDate) {
    if (lastGeneratedDate == null) return true;

    final now = DateTime.now();

    // Get Monday of current week
    DateTime startOfCurrentWeek = now.subtract(Duration(days: now.weekday - 1));
    startOfCurrentWeek = DateTime(startOfCurrentWeek.year, startOfCurrentWeek.month, startOfCurrentWeek.day);

    // Get Monday of the week when the menu was last generated
    DateTime startOfGeneratedWeek = lastGeneratedDate.subtract(Duration(days: lastGeneratedDate.weekday - 1));
    startOfGeneratedWeek = DateTime(startOfGeneratedWeek.year, startOfGeneratedWeek.month, startOfGeneratedWeek.day);

    // Check if it's a new week
    return startOfGeneratedWeek.isBefore(startOfCurrentWeek);
  }


  // Get Personalized Menu Data
  Future<Map<String, dynamic>?> getPersonalizedMenuData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('personalizedMenu')) {
          return data['personalizedMenu'] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch personalized menu data: $e');
    }
  }
}