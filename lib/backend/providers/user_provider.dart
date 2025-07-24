import 'package:flutter/material.dart';
import 'package:nutrinotion_app/backend/models/user_model.dart';
import 'package:nutrinotion_app/backend/services/firestore_services.dart';

class UserProvider extends ChangeNotifier {
  UserModel _user = UserModel();
  bool _isLoading = false;
  final FirestoreServices _firestoreServices = FirestoreServices();

  // Getters
  UserModel get user => _user;
  bool get isLoading => _isLoading;
  bool get isProfileComplete => _user.profileCompleted;

  // Basic user info getters
  String? get name => _user.name;
  String? get email => _user.email;
  int? get age => _user.age;
  double? get height => _user.height;
  int? get weight => _user.weight;
  String? get gender => _user.gender;
  String? get activityLevel => _user.activityLevel;
  String? get fitnessGoal => _user.fitnessGoal;
  String? get dietType => _user.dietType;
  List<String>? get allergies => _user.allergies;
  List<String>? get dislikedFoods => _user.dislikedFoods;
  double? get bmi => _user.bmi;

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Initialize user with basic info (registration)
  void initializeUser({
    String? userId,
    String? name,
    String? email,
  }) {
    _user = UserModel(
      userId: userId,
      name: name,
      email: email,
      profileCompleted: false,
    );
    notifyListeners();
  }

  // Update basic profile fields
  void updateBasicInfo({
    String? name,
    String? email,
    int? age,
    String? gender,
  }) {
    if (name != null) _user.name = name;
    if (email != null) _user.email = email;
    if (age != null) _user.age = age;
    if (gender != null) _user.gender = gender;
    notifyListeners();
  }

  // Update physical measurements
  void updatePhysicalInfo({
    double? height,
    int? weight,
  }) {
    if (height != null) _user.height = height;
    if (weight != null) _user.weight = weight;
    
    // Calculate and update BMI if both height and weight are available
    if (_user.height != null && _user.weight != null) {
      _user.bmi = calculateBMI();
    }
    
    notifyListeners();
  }

  // Update Calorie target
  void updateCalorieTarget(int calorieTarget) {
    _user.calorieTargetPerDay = calorieTarget;
    notifyListeners();
  }

  // Update lifestyle and goals
  void updateLifestyleInfo({
    String? activityLevel,
    String? fitnessGoal,
  }) {
    if (activityLevel != null) _user.activityLevel = activityLevel;
    if (fitnessGoal != null) _user.fitnessGoal = fitnessGoal;
    notifyListeners();
  }

  // Update diet preferences
  void updateDietInfo({
    String? dietType,
    List<String>? allergies,
    List<String>? dislikedFoods,
  }) {
    if (dietType != null) _user.dietType = dietType;
    if (allergies != null) _user.allergies = allergies;
    if (dislikedFoods != null) _user.dislikedFoods = dislikedFoods;
    notifyListeners();
  }

  // Generic profile field update (for backward compatibility)
  void updateProfileField(String key, dynamic value) {
    switch (key.toLowerCase()) {
      case 'name':
        _user.name = value;
        break;
      case 'email':
        _user.email = value;
        break;
      case 'age':
        _user.age = value is int ? value : int.tryParse(value.toString());
        break;
      case 'gender':
        _user.gender = value;
        break;
      case 'height':
        _user.height = value is double ? value : double.tryParse(value.toString());
        // Recalculate BMI if both height and weight are available
        if (_user.height != null && _user.weight != null) {
          _user.bmi = calculateBMI();
        }
        break;
      case 'weight':
        _user.weight = value is int ? value : int.tryParse(value.toString());
        // Recalculate BMI if both height and weight are available
        if (_user.height != null && _user.weight != null) {
          _user.bmi = calculateBMI();
        }
        break;
      case 'bmi':
        _user.bmi = value is double ? value : double.tryParse(value.toString());
        break;
      case 'activity_level':
        _user.activityLevel = value;
        break;
      case 'fitness_goal':
        _user.fitnessGoal = value;
        break;
      case 'diet_type':
        _user.dietType = value;
        break;
      case 'allergies':
        _user.allergies = value is List<String> ? value : [value.toString()];
        break;
      case 'disliked_foods':
        _user.dislikedFoods = value is List<String> ? value : [value.toString()];
        break;
    }
    notifyListeners();
  }

  // Mark profile as complete
  void markProfileComplete() {
    _user.profileCompleted = true;
    notifyListeners();
  }

  // Check if basic profile is complete
  bool isBasicProfileComplete() {
    return _user.name != null && 
           _user.age != null && 
           _user.gender != null;
  }

  // Check if physical info is complete
  bool isPhysicalInfoComplete() {
    return _user.height != null && _user.weight != null;
  }

  // Check if lifestyle info is complete
  bool isLifestyleInfoComplete() {
    return _user.activityLevel != null && _user.fitnessGoal != null;
  }

  // Check if diet info is complete
  bool isDietInfoComplete() {
    return _user.dietType != null;
  }

  // Calculate BMI
  double? calculateBMI() {
    if (_user.height != null && _user.weight != null) {
      double heightInMeters = _user.height! / 100; // Convert cm to meters
      return _user.weight! / (heightInMeters * heightInMeters);
    }
    return null;
  }

  // Get BMI category
  String getBMICategory() {
    double? bmi = calculateBMI();
    if (bmi == null) return 'Unknown';
    
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  // Load user data from JSON (e.g., from database or local storage)
  void loadUserFromJson(Map<String, dynamic> json) {
    _user = UserModel.fromJson(json);
    notifyListeners();
  }

  // Convert user data to JSON for saving
  Map<String, dynamic> getUserAsJson() {
    return _user.toMap();
  }

  // Clear user data (logout)
  void clearUser() {
    _user = UserModel();
    notifyListeners();
  }

  // Update user ID (useful for linking with authentication)
  void updateUserId(String userId) {
    _user.userId = userId;
    notifyListeners();
  }

  // Get completion percentage for profile setup
  double getProfileCompletionPercentage() {
    int completedSections = 0;
    int totalSections = 4;

    if (isBasicProfileComplete()) completedSections++;
    if (isPhysicalInfoComplete()) completedSections++;
    if (isLifestyleInfoComplete()) completedSections++;
    if (isDietInfoComplete()) completedSections++;

    return completedSections / totalSections;
  }

  // Get next incomplete section for onboarding flow
  String? getNextIncompleteSection() {
    if (!isBasicProfileComplete()) return 'basic_info';
    if (!isPhysicalInfoComplete()) return 'physical_info';
    if (!isLifestyleInfoComplete()) return 'lifestyle_info';
    if (!isDietInfoComplete()) return 'diet_info';
    return null; // All sections complete
  }

  // Save user data to Firestore
  Future<bool> saveToFirestore() async {
    try {
      if (_user.userId == null) {
        throw Exception('User ID is required to save data');
      }
      setLoading(true);
      await _firestoreServices.saveUserDetails(_user);
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      print('Error saving to Firestore: $e');
      return false;
    }
  }

  // Load user data from Firestore
  Future<bool> loadFromFirestore(String userId) async {
    try {
      setLoading(true);
      final userData = await _firestoreServices.getUserDetails(userId);
      if (userData != null) {
        _user = userData;
        notifyListeners();
      }
      setLoading(false);
      return userData != null;
    } catch (e) {
      setLoading(false);
      print('Error loading from Firestore: $e');
      return false;
    }
  }

  // Save and mark profile as complete
  Future<bool> completeProfile() async {
    markProfileComplete();
    return await saveToFirestore();
  }
}