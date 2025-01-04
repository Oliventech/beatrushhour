import 'package:beat_rush_hour/getx/controllers/api_controller.dart';
import 'package:beat_rush_hour/models/routes_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:get/get.dart' hide Response;
import 'package:beat_rush_hour/general/constants.dart' as constants;

class GoogleApiController extends GetxController {
  late ApiController apiController;

  late FlutterGooglePlacesSdk places;

  @override
  void onInit() {
    apiController = Get.find<ApiController>();

    places = FlutterGooglePlacesSdk(dotenv.get('API_KEY'));
    super.onInit();
  }

  Future<FindAutocompletePredictionsResponse> getSuggestions(
      String query) async {
    final FindAutocompletePredictionsResponse predictions =
        await places.findAutocompletePredictions(query, newSessionToken: false);
    return predictions;
  }

  Future<FetchPlaceResponse> getPlaceData(String placeId) async {
    final FetchPlaceResponse placeData =
        await places.fetchPlace(placeId, fields: <PlaceField>[
      PlaceField.Location,
    ]);
    return placeData;
  }

  Future<RoutesResponse> getETA({
    required LatLng origin,
    required LatLng destination,
  }) async {
    Map<String, dynamic> headers = {
      "X-Goog-FieldMask": "routes.duration",
      "Content-Type": "application/json",
      "X-Goog-Api-Key": dotenv.get('API_KEY'),
    };

    Map<String, dynamic> body = {
      "origin": {
        "location": {
          "latLng": {"latitude": origin.lat, "longitude": origin.lng}
        }
      },
      "destination": {
        "location": {
          "latLng": {"latitude": destination.lat, "longitude": destination.lng}
        }
      },
      "travelMode": "DRIVE",
      "routingPreference": "TRAFFIC_AWARE",
      "computeAlternativeRoutes": false,
      "routeModifiers": {
        "avoidTolls": false,
        "avoidHighways": false,
        "avoidFerries": false
      },
      "languageCode": "en-US",
      "units": "IMPERIAL"
    };

    Response? res = await apiController.post(
      constants.ROUTES_ETA_URL,
      postBodyType: PostBodyType.json,
      shouldParse: true,
      headers: headers,
      body: body,
    );
    Map<String, dynamic> dataInMap = res?.data as Map<String, dynamic>;
    return RoutesResponse.fromJson(dataInMap);
  }
}
