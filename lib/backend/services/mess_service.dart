import 'package:cloud_firestore/cloud_firestore.dart';

class MessService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Stream getMenuStream(String dayOfWeek) {
    return _firestore.collection("menu").doc(dayOfWeek).snapshots();
  }

  // Get menu for entire week
  Future<Map<String, dynamic>> getWeeklyMenu() async {
    try {
      DocumentSnapshot mondayDoc = await _firestore.collection("menu").doc("monday").get();
      DocumentSnapshot tuesdayDoc = await _firestore.collection("menu").doc("tuesday").get();
      DocumentSnapshot wednesdayDoc = await _firestore.collection("menu").doc("wednesday").get();
      DocumentSnapshot thursdayDoc = await _firestore.collection("menu").doc("thursday").get();
      DocumentSnapshot fridayDoc = await _firestore.collection("menu").doc("friday").get();
      DocumentSnapshot saturdayDoc = await _firestore.collection("menu").doc("saturday").get();
      DocumentSnapshot sundayDoc = await _firestore.collection("menu").doc("sunday").get();

      Map<String, dynamic> processMenuData(DocumentSnapshot doc) {
        if (doc.data() == null) {
          return {"items": []};
        }
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data;
      }

      return {
        "monday": processMenuData(mondayDoc),
        "tuesday": processMenuData(tuesdayDoc),
        "wednesday": processMenuData(wednesdayDoc),
        "thursday": processMenuData(thursdayDoc),
        "friday": processMenuData(fridayDoc),
        "saturday": processMenuData(saturdayDoc),
        "sunday": processMenuData(sundayDoc),
      };
    } catch (e) {
      throw Exception('Failed to fetch weekly menu: $e');
    }
  }
}
