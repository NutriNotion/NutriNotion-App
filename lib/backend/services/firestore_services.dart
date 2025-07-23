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
}