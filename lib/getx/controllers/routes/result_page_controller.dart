import 'package:beat_rush_hour/classes/routes/home_page/text_form_field_info.dart';
import 'package:beat_rush_hour/getx/controllers/date_controller.dart';
import 'package:beat_rush_hour/getx/controllers/google_api_controller.dart';
import 'package:beat_rush_hour/getx/controllers/routes/home_page_controller.dart';
import 'package:beat_rush_hour/models/routes_response.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

enum ResultPageState {
  loading,
  error,
  success,
}

class ResultPageController extends GetxController {
  Rx<ResultPageState> resultPageState = ResultPageState.loading.obs;

  late HomePageController homePageController;
  late GoogleApiController googleApiController;

  late DateController dateController;

  late Map<HomePageFieldType, TextFormFieldInfo> textFormFieldInfoMap;

  Duration? currentDuration;

  @override
  void onInit() {
    homePageController = Get.find<HomePageController>();
    googleApiController = Get.find<GoogleApiController>();

    textFormFieldInfoMap = homePageController.textFormFieldInfoMap;

    dateController = Get.find<DateController>();
    fetchDuration();
    super.onInit();
  }

  Future<void> fetchDuration() async {
    try {
      setResultPageState(ResultPageState.loading);

      RoutesResponse res = await googleApiController.getETA(
        origin: textFormFieldInfoMap[HomePageFieldType.origin]!.latLng!,
        destination:
            textFormFieldInfoMap[HomePageFieldType.destination]!.latLng!,
      );

      currentDuration =
          dateController.parseRoutesAPIDuration(res.routes[0].duration);
      setResultPageState(ResultPageState.success);
    } catch (e) {
      debugPrint('Error occurred while getting duration: ${e.toString()}');
    }
  }

  void setResultPageState(ResultPageState value) {
    resultPageState.value = value;
  }
}
