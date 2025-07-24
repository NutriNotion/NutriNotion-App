import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import 'firestore_services.dart';
import 'mess_service.dart';

class AIService {
  // Firestore Services
  final FirestoreServices _firestoreServices = FirestoreServices();

  // Mess Service
  final MessService _messService = MessService();

  // Get User Details
  Future<UserModel?> getUserDetails(String userId) async {
    final res = await _firestoreServices.getUserDetails(userId);
    return res;
  }

  // Get Menu Details
  Future<Map<String, dynamic>> getMenuDetails() async {
    final weeklyMenu = await _messService.getWeeklyMenu();
    return weeklyMenu;
  }

  // Format Data for AI
  Map<String, dynamic> formatDataForAI(UserModel user, Map<String, dynamic> menu) {
    return {
      "user_profile": user.toJson(),
      "mess_menu": menu,
    };
  }

  // Call the api to generate personalized recommendations
  Future<Map<String, dynamic>> generateRecommendations(Map<String, dynamic> data) async {
    try {
      // final url = 'https://ai-model-jvog.onrender.com/api/recommend_weekly_meal';
      final url = 'http://192.168.44.73:5000/api/recommend_weekly_meal';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        final errorData = jsonDecode(response.body);
        print("Error from AI API: $errorData");
        throw Exception('Failed to generate recommendations: ${response.statusCode}');
      }
    } catch (e) {
      print("Error generating recommendations: $e");
      return {};
    }
  }
}
