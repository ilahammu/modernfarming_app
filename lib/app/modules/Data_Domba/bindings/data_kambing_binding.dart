import 'package:get/get.dart';

import '../controllers/data_kambing_controller.dart';

class DataKambingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DataKambingController>(
      () => DataKambingController(),
    );
  }
}
