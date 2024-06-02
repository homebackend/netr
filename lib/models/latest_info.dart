
class LatestInfo {
  final String dest;
  final String time;
  final List<String> cameras;
  final int frequency;
  final List<String> minCameras;
  final int minCameraFrequency;
  final List<String> types;

  LatestInfo.fromJson(Map<String, dynamic> json)
      : dest = json['dest'],
        time = json['time'],
        cameras = List<String>.from(json['cameras']),
        frequency = json['frequency'],
        minCameras = List<String>.from(json['min_cams']),
        minCameraFrequency = json['min_cam_frequency'],
        types = List<String>.from(json['types']);
}
