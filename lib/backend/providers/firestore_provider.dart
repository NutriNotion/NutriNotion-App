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
}