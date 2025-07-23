import 'package:cloud_firestore/cloud_firestore.dart';

class MessService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Stream getMenuStream(String dayOfWeek) {
    return _firestore.collection("menu").doc(dayOfWeek).snapshots();
  }
}
