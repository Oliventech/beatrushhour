import 'dart:collection';

import 'package:beat_rush_hour/getx/controllers/routes/home_page_controller.dart';
import 'package:beat_rush_hour/getx/states/routes/home_page/home_page_text_field_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:get/get.dart';

class TextFormFieldInfo {
  final String backgroundText;
  final HomePageFieldType homePageFieldType;
  final SearchController controller;

  Rx<HomePageTextFieldState> state = HomePageTextFieldState.closed.obs;
  bool isCompleted = false;
  String previousText = '';

  AutocompletePrediction? prediction;
  LatLng? latLng;
  UnmodifiableListView<AutocompletePrediction> suggestionsList = UnmodifiableListView(<AutocompletePrediction>[]);

  TextFormFieldInfo({
    required this.backgroundText,
    required this.homePageFieldType,
    required this.controller,
  });

  void setCompleted(bool value) {
    isCompleted = value;
  }

  //Observable
  void setState(HomePageTextFieldState value) {
    state.value = value;
  }

  void setPreviousText(String value) {
    previousText = value;
  }

  void setSuggestionsList(UnmodifiableListView<AutocompletePrediction> value) {
    suggestionsList = value;
  }

  void setAutocompletePrediciton(AutocompletePrediction value) {
    prediction = value;
  }

  void setLatLng(LatLng value) {
    latLng = value;
  }
}
