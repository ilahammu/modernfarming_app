import 'package:get/get.dart';

class HomeController extends GetxController {
  var selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    selectedIndex.value = 0;
  }

  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}
