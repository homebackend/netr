class AppInfo {
  final String version;

  AppInfo.fromJson(Map<String, dynamic> json) : version = json['version'];
}
