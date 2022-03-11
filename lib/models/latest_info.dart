
class LatestInfo {
  final String dest;
  final String time;
  final List<String> cameras;
  final List<String> types;

  LatestInfo.fromJson(Map<String, dynamic> json)
      : dest = json['dest'],
        time = json['time'],
        cameras = List<String>.from(json['cameras']),
        types = List<String>.from(json['types']);
}
