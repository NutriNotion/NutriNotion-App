import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutrinotion_app/backend/services/auth_services.dart';

class AuthProvider with ChangeNotifier {
  final AuthServices _authServices = AuthServices();
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isEmailVerified => _authServices.isEmailVerified();
  String? get userEmail => _authServices.getUserEmail();
  String? get userDisplayName => _authServices.getUserDisplayName();
  String? get userId => _authServices.getUserId();

  AuthProvider() {
    _initialize();
  }

  // Initialize auth state listener
  void _initialize() {
    try {
      _user = _authServices.currentUser;
      _authServices.authStateChanges.listen((User? user) {
        _user = user;
        notifyListeners();
      });
    } catch (e) {
      print('Auth state listener failed: $e');
      // Handle gracefully when Firebase is not available
    }
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();
      
      final UserCredential result = await _authServices.signInWithEmailAndPassword(email, password);
      _user = result.user;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // Sign up with email and password
  Future<bool> signUp(String email, String password, String name) async {
    try {
      _setLoading(true);
      _clearError();
      
      final UserCredential result = await _authServices.createUserWithEmailAndPassword(email, password);
      
      // Update display name
      if (name.isNotEmpty) {
        await _authServices.updateDisplayName(name);
      }
      
      _user = result.user;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // Sign out
  Future<bool> signOut() async {
    try {
      _setLoading(true);
      _clearError();
      
      await _authServices.signOut();
      _user = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _authServices.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // Send email verification
  Future<bool> sendEmailVerification() async {
    try {
      _setLoading(true);
      _clearError();
      
      await _authServices.sendEmailVerification();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // Reauthenticate user
  Future<bool> reauthenticate(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _authServices.reauthenticateWithCredential(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // get current user
  User? get currentUser => _user;

  // Delete account
  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);
      _clearError();
      
      await _authServices.deleteAccount();
      _user = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // Private helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _clearError();
  }
}
