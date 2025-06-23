import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chewie/chewie.dart';
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
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.chewieController != null &&
              controller.chewieController!.videoPlayerController.value
                  .isInitialized) {
            return AspectRatio(
              aspectRatio: controller.videoPlayerController.value.aspectRatio,
              child: Chewie(
                controller: controller.chewieController!,
              ),
            );
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 8),
                  Text("Gagal memuat video stream."),
                ],
              ),
            );
          }
        }),
      ),
    );
  }
}
