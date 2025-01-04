import 'package:beat_rush_hour/getx/controllers/api_controller.dart';
import 'package:beat_rush_hour/getx/controllers/date_controller.dart';
import 'package:beat_rush_hour/getx/controllers/google_api_controller.dart';
import 'package:beat_rush_hour/getx/controllers/routes/home_page_controller.dart';
import 'package:beat_rush_hour/getx/controllers/uuid_controller.dart';
import 'package:get/get.dart';

class AppInitialBindings implements Bindings {
  @override
  void dependencies() {
    Get.put(DateController());
    Get.put(UuidController());
    Get.put(ApiController());
    Get.put(GoogleApiController());
    Get.put(HomePageController());
  }
}
