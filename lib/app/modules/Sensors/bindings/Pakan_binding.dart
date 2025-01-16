import 'package:get/get.dart';

import '../controllers/Fakan_controller.dart';

class WeightFoodBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WeightFoodController>(
      () => WeightFoodController(),
    );
  }
}
