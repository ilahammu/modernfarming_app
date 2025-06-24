// lib/controllers/camera_controller.dart

import 'dart:async'; // <-- Tambahkan import ini
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:get/get.dart';

class CameraController extends GetxController {
  static const String _videoUrl =
      'https://gn99lq68-8080.asse.devtunnels.ms/video';

  late VlcPlayerController vlcController;
  final isInitialized = false.obs;
  final isLoading = true.obs;
  bool _isDisposed = false;

  @override
  void onInit() {
    super.onInit();
    _initializePlayer();
  }

  void _initializePlayer() {
    vlcController = VlcPlayerController.network(
      _videoUrl,
      options: VlcPlayerOptions(
        http: VlcHttpOptions([VlcHttpOptions.httpReconnect(true)]),
        advanced: VlcAdvancedOptions([VlcAdvancedOptions.networkCaching(6000)]),
      ),
    );

    vlcController.addListener(() {
      if (_isDisposed) return;

      final playerValue = vlcController.value;

      // ================== LOGGING DETAIL ==================
      // Cetak status setiap kali ada perubahan
      print(
          "VLC State changed: playingState=${playerValue.playingState}, isInitialized=${playerValue.isInitialized}, hasError=${playerValue.hasError}, isBuffering=${playerValue.isBuffering}");
      // ====================================================

      if (playerValue.isInitialized && !isInitialized.value) {
        isInitialized.value = true;
        isLoading.value = false;
      } else if (playerValue.hasError ||
          playerValue.playingState == PlayingState.error) {
        if (isLoading.value) {
          isLoading.value = false;
        }
      }
    });

    // ================== TIMEOUT MANUAL ==================
    // Setelah 15 detik, jika masih loading, anggap saja gagal.
    Future.delayed(const Duration(seconds: 30), () {
      if (isLoading.value && !_isDisposed) {
        print(
            ">>> TIMEOUT: Video tidak dimulai setelah 2 detik. Membatalkan loading.");
        isLoading.value = false;
      }
    });
    // ====================================================
  }

  @override
  void onClose() {
    _isDisposed = true;
    vlcController.dispose();
    super.onClose();
  }
}
