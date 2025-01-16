import 'package:get/get.dart';

import '../controllers/aht_controller.dart';

class IndeksLingkunganBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IndeksLingkunganController>(
      () => IndeksLingkunganController(),
    );
  }
}
