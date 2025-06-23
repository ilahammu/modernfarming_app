import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class CameraController extends GetxController {
  static const String _videoUrl =
      'https://gn99lq68-5000.asse.devtunnels.ms/video';

  late VideoPlayerController videoPlayerController;
  ChewieController? chewieController;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(_videoUrl));
      await videoPlayerController.initialize();
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: true,
        isLive: true,
      );
      isLoading.value = false;
    } catch (error) {
      // Snackbar removed as requested
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    videoPlayerController.dispose();
    chewieController?.dispose();
    super.onClose();
  }
}
