import 'package:flutter/foundation.dart';

void logPrint(String message) {
  if (kDebugMode) {
    print(message);
  }
}