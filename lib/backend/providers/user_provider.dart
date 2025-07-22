import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  String? _userId;
  String? _userName;
  String? _userEmail;
  String? _userPhotoUrl;
  Map<String, dynamic> _userProfile = {};
  bool _isLoading = false;

  // Getters
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userPhotoUrl => _userPhotoUrl;
  Map<String, dynamic> get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  // Set user data
  void setUser({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
  }) {
    _userId = id;
    _userName = name;
    _userEmail = email;
    _userPhotoUrl = photoUrl;
    notifyListeners();
  }

  // Update user profile
  void updateUserProfile(Map<String, dynamic> profile) {
    _userProfile = profile;
    notifyListeners();
  }

  // Update specific profile field
  void updateProfileField(String key, dynamic value) {
    _userProfile[key] = value;
    notifyListeners();
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear user data
  void clearUser() {
    _userId = null;
    _userName = null;
    _userEmail = null;
    _userPhotoUrl = null;
    _userProfile = {};
    notifyListeners();
  }

  // Get user initials for avatar
  String getUserInitials() {
    if (_userName != null && _userName!.isNotEmpty) {
      List<String> names = _userName!.split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      } else {
        return _userName![0].toUpperCase();
      }
    }
    return 'U';
  }

  // Check if user profile is complete
  bool isProfileComplete() {
    return _userName != null &&
           _userEmail != null &&
           _userProfile.containsKey('age') &&
           _userProfile.containsKey('weight') &&
           _userProfile.containsKey('height') &&
           _userProfile.containsKey('goal');
  }

  // Get user BMI if height and weight are available
  double? getUserBMI() {
    if (_userProfile.containsKey('height') && _userProfile.containsKey('weight')) {
      double height = _userProfile['height'].toDouble() / 100; // Convert cm to m
      double weight = _userProfile['weight'].toDouble();
      return weight / (height * height);
    }
    return null;
  }
}
