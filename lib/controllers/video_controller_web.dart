import 'package:netr/controllers/video_player_controller_interface.dart';
import 'package:netr/controllers/dummy_vlc_controller.dart';

void initializeController() {}

VideoPlayerControllerInterface createController(
    String dataSource, bool autoPlay) {
  return DummyVlcController();
}
