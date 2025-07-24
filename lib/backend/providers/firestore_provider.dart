import 'package:flutter/material.dart';
import 'package:nutrinotion_app/backend/models/user_model.dart';

import '../services/firestore_services.dart';

class FirestoreProvider extends ChangeNotifier {
  final FirestoreServices _firestoreServices = FirestoreServices();

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Map<String, dynamic>? _personalizedMenu;
  Map<String, dynamic>? get personalizedMenu => _personalizedMenu;

  Future<void> addUserDetails(UserModel user) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreServices.addUserDetails(user);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check for personalized food availability
  Future<bool> checkForPersonalizedFood(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      return await _firestoreServices.checkForPersonalizedFood(userId);
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update Personalized Menu
  Future<void> updatePersonalizedMenu(String userId, Map<String, dynamic> personalizedMenu) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreServices.updatePersonalizedMenu(userId, personalizedMenu);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get Personalized Menu
  Future<void> getPersonalizedMenu(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _personalizedMenu = await _firestoreServices.getPersonalizedMenuData(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}