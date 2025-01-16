import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:monitoring_kambing/app/modules/Data_Domba/views/data_kambing_view.dart';
import 'package:monitoring_kambing/app/modules/Sensors/views/aht_view.dart';
import 'package:monitoring_kambing/app/modules/Sensors/views/gyro_view.dart';
import 'package:monitoring_kambing/app/modules/Information/views/sensor_view.dart';
import 'package:monitoring_kambing/app/modules/Information/views/team_view.dart';
// import 'package:monitoring_kambing/app/modules/camera/views/camera_view.dart';
import 'package:monitoring_kambing/app/modules/component/drawer.dart';
import 'package:monitoring_kambing/app/modules/Sensors/views/loadcell_view.dart';
import 'package:monitoring_kambing/app/modules/Overview/views/overview_view.dart';
import 'package:monitoring_kambing/app/modules/Sensors/views/Pakan_view.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  @override
  final HomeController controller = Get.put(HomeController());

  HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: <Widget>[
                MyDrawer(),
                Expanded(
                  flex: 2,
                  child: Container(
                    width: Get.width,
                    height: Get.height,
                    color: const Color(0xFFD9D9D9),
                    child: Obx(() {
                      switch (controller.selectedIndex.value) {
                        case 0:
                          return OverviewView();
                        case 1:
                          return LoadcellView();
                        case 2:
                          return WeightFoodView();
                        case 3:
                          return GyroView();
                        case 4:
                          return IndeksLingkunganView();
                        // case 5:
                        //   return CameraView();
                        case 5:
                          return DataKambingView();
                        case 6:
                          return TeamView();
                        case 7:
                          return SensorView();
                        default:
                          return OverviewView();
                      }
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
