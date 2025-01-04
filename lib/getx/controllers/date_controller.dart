import 'package:get/get.dart';

class DateController extends GetxController {
  Duration? parseRoutesAPIDuration(String time) {
    if (time.isNotEmpty) {
      String parsedTimeString = time.trim().substring(0, time.length - 1);
      int? parsedTimeInInt = int.tryParse(parsedTimeString);
      if (parsedTimeInInt != null) {
        return Duration(seconds: parsedTimeInInt);
      }
    }

    return null;
  }
}
