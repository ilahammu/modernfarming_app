import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:get/get.dart';
import '../controllers/camera_controller.dart' as cam;

class CameraView extends StatelessWidget {
  CameraView({Key? key}) : super(key: key);

  final cam.CameraController controller = Get.put(cam.CameraController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Camera",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 78, 79, 79),
      ),
      body: Center(
        child: Container(
          width: 1080,
          height: 720,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.blueAccent, width: 3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.isInitialized.value) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: VlcPlayer(
                  controller: controller.vlcController,
                  aspectRatio: 4 / 3,
                  placeholder: const Center(child: CircularProgressIndicator()),
                ),
              );
            } else {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48),
                    SizedBox(height: 8),
                    Text("Gagal memuat video stream.",
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              );
            }
          }),
        ),
      ),
    );
  }
}
