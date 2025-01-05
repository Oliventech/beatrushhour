import 'dart:collection';

import 'package:beat_rush_hour/classes/routes/home_page/text_form_field_info.dart';
import 'package:beat_rush_hour/getx/controllers/api_controller.dart';
import 'package:beat_rush_hour/getx/controllers/fcm_controller.dart';
import 'package:beat_rush_hour/getx/controllers/google_api_controller.dart';
import 'package:beat_rush_hour/getx/states/routes/home_page/home_page_text_field_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart' hide Response;
import 'package:beat_rush_hour/general/constants.dart' as constants;

enum HomePageFieldType {
  origin,
  destination,
}

enum ResultState { initial, loading, error, success, resultLoaded }

class HomePageController extends GetxController {
  late GoogleApiController googleApiController;
  late FCMController fcmController;
  late ApiController apiController;

  Duration? thresholdDuration;
  Rx<ResultState> resultState = ResultState.initial.obs;

  Duration? currentDuration;
  Map<HomePageFieldType, TextFormFieldInfo> textFormFieldInfoMap =
      <HomePageFieldType, TextFormFieldInfo>{
    HomePageFieldType.origin: TextFormFieldInfo(
      backgroundText: 'Origin',
      homePageFieldType: HomePageFieldType.origin,
      controller: SearchController(),
    ),
    HomePageFieldType.destination: TextFormFieldInfo(
      backgroundText: 'Destination',
      homePageFieldType: HomePageFieldType.destination,
      controller: SearchController(),
    ),
  };

  @override
  void onInit() {
    googleApiController = Get.find<GoogleApiController>();
    apiController = Get.find<ApiController>();
    fcmController = Get.find<FCMController>();
    fcmController.checkIfAppOpenedFromNotificationAndAct();

    super.onInit();
  }

  Future<void> onChanged({
    required HomePageFieldType type,
  }) async {
    TextFormFieldInfo textField = textFormFieldInfoMap[type]!;
    String text = textField.controller.text;

    if (text.trim().isEmpty) {
      //no need for network call if the query is empty
      setTextFieldState(
        type: type,
        value: HomePageTextFieldState.noSuggestionFound,
      );
      return;
    }

    if (textField.previousText.trim() != text.trim()) {
      setTextFieldState(
        type: type,
        value: HomePageTextFieldState.loading,
      );
      FindAutocompletePredictionsResponse suggestions =
          await googleApiController.getSuggestions(text);
      UnmodifiableListView<AutocompletePrediction> list =
          UnmodifiableListView(suggestions.predictions);

      textField.setSuggestionsList(list);
      textField.setState(HomePageTextFieldState.suggestionsLoaded);
      update([textField.homePageFieldType]);
    } //else do nothing, since only an extra space got inserted

    textField.setPreviousText(text.trim());
  }

  void onSuggestionTap({
    required HomePageFieldType type,
    required AutocompletePrediction selectedValue,
  }) {
    textFormFieldInfoMap[type]?.setAutocompletePrediciton(selectedValue);
    textFormFieldInfoMap[type]?.setState(HomePageTextFieldState.closed);
    textFormFieldInfoMap[type]?.controller.closeView(selectedValue.fullText);
  }

  Future<void> onSubmit() async {
    try {
      //verify
      Iterable<HomePageFieldType> keys = textFormFieldInfoMap.keys;

      bool hasError = false;

      for (HomePageFieldType key in keys) {
        TextFormFieldInfo? info = textFormFieldInfoMap[key];
        if (info?.prediction == null) {
          showToast(
            msg:
                'Please select a valid address for ${info?.homePageFieldType == HomePageFieldType.origin ? 'origin' : 'destination'} from its search dropdown!',
          );
          hasError = true;
          break;
        }
      }

      if (hasError) return;

      if (thresholdDuration == null || thresholdDuration == Duration.zero) {
        showToast(msg: 'Please select a valid duration to reach!');
        return;
      }

      await Future.forEach(keys, (key) async {
        String? placeId = textFormFieldInfoMap[key]?.prediction?.placeId;
        if (placeId != null) {
          FetchPlaceResponse data =
              await googleApiController.getPlaceData(placeId);
          if (data.place != null && data.place?.latLng != null) {
            textFormFieldInfoMap[key]?.latLng = data.place?.latLng;
          } else {
            showToast(msg: 'Some error occurred!');
            hasError = true;
          }
        }
      });

      if (hasError) return;

      await scheduleDurationFetching();
    } catch (e) {
      debugPrint('Error occurred while getting place details: ${e.toString()}');
      showToast(msg: 'Sorry, some unexpected error occurred!');
    }
  }

  Future<void> scheduleDurationFetching() async {
    try {
      setResultState(ResultState.loading);

      try {
        //TODO: Handle token refresh
        String? token = await fcmController.getDeviceToken();

        if (token == null) {
          setResultState(ResultState.error);
          return;
        }

        Response<dynamic>? res = await apiController.post(
          constants.SCHEDULING_ENDPOINT,
          postBodyType: PostBodyType.json,
          body: <String, dynamic>{
            'duration': thresholdDuration?.inSeconds,
            'origin': {
              'lat':
                  textFormFieldInfoMap[HomePageFieldType.origin]?.latLng?.lat,
              'lng':
                  textFormFieldInfoMap[HomePageFieldType.origin]?.latLng?.lng,
            },
            'destination': {
              'lat': textFormFieldInfoMap[HomePageFieldType.destination]
                  ?.latLng
                  ?.lat,
              'lng': textFormFieldInfoMap[HomePageFieldType.destination]
                  ?.latLng
                  ?.lng,
            },
            'token': token,
          },
        );

        if (res?.statusCode == 200) {
          setResultState(ResultState.success);
        } else {
          throw(Exception('Improper response while scheduling duration'));
        }
      } catch (e) {
        debugPrint('Error occurred while scheduling duration $e');
        setResultState(
          ResultState.error,
        );
      }
    } catch (e) {
      debugPrint('Error occurred while getting duration: ${e.toString()}');
    }
  }

  void showDurationDialog() {
    if (currentDuration == null) {
      debugPrint('Duration of notification data is null!!!');
      return;
    }

    setResultState(ResultState.resultLoaded);
  }

  String humanizeDuration(Duration duration) {
    int durationInSec = duration.inSeconds;
    int hours = (durationInSec / 3600).floor();
    int minutes = ((durationInSec % 3600) / 60).floor();

    if (hours > 0) {
      return '$hours hours & $minutes minutes';
    } else {
      return '$minutes minutes';
    }
  }

  void setResultState(ResultState value) {
    resultState.value = value;
  }

  void showToast({required String msg}) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  void setTextFieldState({
    required HomePageTextFieldState value,
    required HomePageFieldType type,
  }) {
    textFormFieldInfoMap[type]?.setState(value);
  }

  void setThresholdDuration({required Duration? value}) {
    thresholdDuration = value;
  }

  void setCurrentDuration({required int? value}) {
    if (value == null) {
      setResultState(ResultState.error);
      return;
    }
    currentDuration = Duration(seconds: value);
  }
}
