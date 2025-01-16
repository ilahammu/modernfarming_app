import 'package:get/get.dart';

import '../controllers/loadcell_controller.dart';

class LoadcellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoadcellController>(
      () => LoadcellController(),
    );
  }
}
