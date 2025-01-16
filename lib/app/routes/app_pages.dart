import 'package:get/get.dart';
// HomeView
import '../modules/Home/bindings/home_binding.dart';
import '../modules/Home/views/home_view.dart';
// Overview
import '../modules/Overview/bindings/overview_binding.dart';
import '../modules/Overview/views/overview_view.dart';
// Loadcell Badan
import '../modules/Sensors/bindings/loadcell_binding.dart';
import '../modules/Sensors/views/loadcell_view.dart';
// Berat Pakan
import '../modules/Sensors/bindings/Pakan_binding.dart';
import '../modules/Sensors/views/Pakan_view.dart';
// Gyro
import 'package:monitoring_kambing/app/modules/Sensors/bindings/gyro_binding.dart';
import 'package:monitoring_kambing/app/modules/Sensors/views/gyro_view.dart';
// Suhu
import '../modules/Sensors/bindings/aht_binding.dart';
import '../modules/Sensors/views/aht_view.dart';
// Camera
// import '../modules/camera/bindings/camera_binding.dart';
// import '../modules/camera/views/camera_view.dart';
// Data Kambing
import 'package:monitoring_kambing/app/modules/Data_Domba/bindings/data_kambing_binding.dart';
import 'package:monitoring_kambing/app/modules/Data_Domba/views/data_kambing_view.dart';
// Info Tim
import 'package:monitoring_kambing/app/modules/Information/bindings/team_binding.dart';
import 'package:monitoring_kambing/app/modules/Information/views/team_view.dart';
// Info Sensor
import 'package:monitoring_kambing/app/modules/Information/bindings/sensor_binding.dart';
import 'package:monitoring_kambing/app/modules/Information/views/sensor_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.home;

  static final routes = [
    GetPage(
      name: _Paths.home,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.overview,
      page: () => OverviewView(),
      binding: OverviewBinding(),
    ),
    GetPage(
      name: _Paths.loadcell,
      page: () => LoadcellView(),
      binding: LoadcellBinding(),
    ),
    GetPage(
      name: _Paths.weightFood,
      page: () => WeightFoodView(),
      binding: WeightFoodBinding(),
    ),
    GetPage(
      name: _Paths.gyro,
      page: () => GyroView(),
      binding: GyroBinding(),
    ),
    GetPage(
      name: _Paths.temparature,
      page: () => IndeksLingkunganView(),
      binding: IndeksLingkunganBinding(),
    ),
    // GetPage(
    //   name: _Paths.CAMERA,
    //   page: () => CameraView(),
    //   binding: CameraBinding(),
    // ),
    GetPage(
      name: _Paths.DATA_KAMBING,
      page: () => DataKambingView(),
      binding: DataKambingBinding(),
    ),
    GetPage(
      name: _Paths.infoTim,
      page: () => TeamView(),
      binding: TeamBinding(),
    ),
    GetPage(
      name: _Paths.infoSensor,
      page: () => SensorView(),
      binding: SensorBinding(),
    ),
  ];
}
