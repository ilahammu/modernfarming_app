import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:monitoring_kambing/app/global_component/custom_expansiontile.dart';
import 'package:monitoring_kambing/app/global_component/custom_listtile.dart';
import 'package:monitoring_kambing/app/modules/Home/controllers/home_controller.dart';

class MyDrawer extends GetView<HomeController> {
  @override
  final HomeController controller = Get.put(HomeController());

  MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final double drawerWidth = Get.width * 0.15;

    return Material(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        width: drawerWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFC0C0C0), // Silver color
              Color.fromARGB(255, 155, 148, 148), // Lighter silver color
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: const Border(
            right: BorderSide(
              color: Color.fromARGB(255, 202, 201, 201),
              width: 3.5,
            ),
          ),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(5),
              height: Get.height * 0.08,
              width: Get.width,
              child: Center(
                child: Image.asset(
                  'assets/images/logo_keren.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),
            CustomListTile(
              onClick: () {
                controller.changeIndex(0);
              },
              title: 'Overview',
              iconLeading: MdiIcons.viewDashboard,
              isSelected: controller.selectedIndex.value == 0,
            ),
            CustomExpansionTile(
              title: 'Analytics',
              leading: Icon(
                MdiIcons.googleAnalytics,
                color: Colors.black,
                size: 15,
              ),
              children: <Widget>[
                CustomListTile(
                  title: 'Berat Badan',
                  iconLeading: MdiIcons.scale,
                  onClick: () {
                    controller.changeIndex(1);
                  },
                  isSelected: controller.selectedIndex.value == 1,
                ),
                CustomListTile(
                  title: 'Berat Pakan',
                  iconLeading: MdiIcons.food,
                  onClick: () {
                    controller.changeIndex(2);
                  },
                  isSelected: controller.selectedIndex.value == 2,
                ),
                CustomListTile(
                  title: 'Gerakan',
                  iconLeading: MdiIcons.snowflakeThermometer,
                  onClick: () {
                    controller.changeIndex(3);
                  },
                  isSelected: controller.selectedIndex.value == 3,
                ),
                CustomListTile(
                  title: 'Indeks Lingkungan',
                  iconLeading: MdiIcons.rotateOrbit,
                  onClick: () {
                    controller.changeIndex(4);
                  },
                  isSelected: controller.selectedIndex.value == 4,
                ),
                CustomListTile(
                  title: 'Camera',
                  iconLeading: MdiIcons.rotateOrbit,
                  onClick: () {
                    controller.changeIndex(5);
                  },
                  isSelected: controller.selectedIndex.value == 5,
                ),
              ],
            ),
            CustomListTile(
              title: 'Tambah Data Domba',
              iconLeading: MdiIcons.sheep,
              onClick: () {
                controller.changeIndex(6);
              },
              isSelected: controller.selectedIndex.value == 6,
            ),
            CustomExpansionTile(
              title: 'Information',
              leading: Icon(
                MdiIcons.information,
                color: Colors.black,
                size: 15,
              ),
              children: <Widget>[
                CustomListTile(
                  title: 'Team',
                  iconLeading: MdiIcons.accountGroup,
                  onClick: () {
                    controller.changeIndex(7);
                  },
                  isSelected: controller.selectedIndex.value == 7,
                ),
                CustomListTile(
                  title: 'Sensor',
                  iconLeading: MdiIcons.sack,
                  onClick: () {
                    controller.changeIndex(8);
                  },
                  isSelected: controller.selectedIndex.value == 8,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
