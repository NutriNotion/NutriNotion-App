import 'package:flutter/foundation.dart';
import 'package:nutrinotion_app/backend/models/user_model.dart';
import 'package:nutrinotion_app/backend/services/ai_services.dart';

class AiProvider extends ChangeNotifier {
  
  final AIService _aiService = AIService();

  // Get User Details
  Future<UserModel?> getUserDetails(String userId) async {
    try {
      final userDetails = await _aiService.getUserDetails(userId);
      notifyListeners();
      return userDetails;
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }

  // get Menu Details
  Future<Map<String, dynamic>> getMenuDetails() async {
    try {
      final menuDetails = await _aiService.getMenuDetails();
      notifyListeners();
      return menuDetails;
    } catch (e) {
      print('Error fetching menu details: $e');
      return {};
    }
  }

  // Format Data for AI
  Map<String, dynamic> formatDataForAI(UserModel user, Map<String, dynamic> menu) {
    try {
      final formattedData = _aiService.formatDataForAI(user, menu);
      notifyListeners();
      return formattedData;
    } catch (e) {
      print('Error formatting data for AI: $e');
      return {};
    }
  }

  // Call the API to generate personalized recommendations
  Future<Map<String, dynamic>> generateRecommendations(Map<String, dynamic> data) async {
    try {
      final recommendations = await _aiService.generateRecommendations(data);
      notifyListeners();
      return recommendations;
    } catch (e) {
      print('Error generating recommendations: $e');
      return {};
    }
  }

  // Check if personalized food is available
  
}