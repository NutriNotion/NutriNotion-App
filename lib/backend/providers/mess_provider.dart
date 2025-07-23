import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:nutrinotion_app/backend/services/mess_service.dart';

class MessProvider extends ChangeNotifier {
  final MessService _messService = MessService();

  Stream getMenuStream(String dayOfWeek) {
    return _messService.getMenuStream(dayOfWeek);
  }
}
