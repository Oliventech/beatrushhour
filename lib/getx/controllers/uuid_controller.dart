import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class UuidController extends GetxController {
  late Uuid uuid;

  @override
  void onInit() {
    uuid = Uuid();
    super.onInit();
  }

  String getV4UniqueID() {
    return uuid.v4();
  }
}
