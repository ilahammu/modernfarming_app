import 'package:get/get.dart';

import '../controllers/gyro_controller.dart';

class GyroBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GyroController>(
      () => GyroController(),
    );
  }
}
