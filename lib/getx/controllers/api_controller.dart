import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData;
import 'package:beat_rush_hour/general/constants.dart' as constants;

enum PostBodyType {
  formData,
  json,
}

class ApiController extends GetxController {
  late Dio dio;

  @override
  void onInit() {
    dio = Dio();
    // ..options = BaseOptions(
    //   baseUrl: '$constants.ROOT_URL',
    // );
    super.onInit();
  }

  Future<Response<dynamic>?> get(String relativeUrl,
      {Map<String, dynamic>? headers,
      Map<String, dynamic>? queryParams}) async {
    try {
      Response<dynamic> res = await dio.get(relativeUrl,
          options: Options(headers: headers), queryParameters: queryParams);

      res.data = await _convertResponseDataIntoMap(res);

      return res;
    } on DioException catch (e) {
      print('Error occurred while get request $e while fetching $relativeUrl');
      return e.response;
    } catch (e) {
      print('Error occurred while get request $e while fetching $relativeUrl');
      return null;
    }
  }

  Future<Response<dynamic>?> post(String relativeUrl,
      {Map<String, dynamic>? headers,
      Map<String, dynamic>? body,
      PostBodyType postBodyType = PostBodyType.formData,
      bool shouldParse = true}) async {
    try {
      Object? _body;

      if (body != null) {
        if (postBodyType == PostBodyType.formData) {
          _body = FormData.fromMap(body);
        } else if (postBodyType == PostBodyType.json) {
          _body = jsonEncode(body);
        } else {
          print('What kind of postBodyType is this $postBodyType');
          return null;
        }
      }

      Response<dynamic> res = await dio.post(
        relativeUrl,
        options: Options(
          headers: headers,
        ),
        data: _body,
      );

      if (shouldParse) {
        res.data = await _convertResponseDataIntoMap(res);
      }

      return res;
    } on DioException catch (e) {
      print('Error occurred while post request $e');
      return e.response;
    } catch (e) {
      print('Error occurred while post request $e');
      return null;
    }
  }

  put() {
    //TODO: add put request code
    throw UnimplementedError();
  }

  delete() {
    //TODO: add delete request code
    throw UnimplementedError();
  }

  //this is because the API always returns 200 status with real status like 401 etc, in the response
  int? _extractActualStatusCode(Response res) {
    var data = res.data;

    int? statusCode;
    if (data != null) statusCode = data['status'] ?? int.tryParse(data['stat']);

    return statusCode ?? res.statusCode;
  }

  Future<dynamic> _convertResponseDataIntoMap(Response res) async {
    var data = res.data;

    if (res.data != null && res.data is String) {
      data = await jsonDecode(res.data);
    }

    return data;
  }
}
