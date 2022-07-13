class AppVersion {
  int versionId;
  String android;
  String ios;
  int isForceUpdate;

  AppVersion({this.versionId, this.android, this.ios, this.isForceUpdate});

  AppVersion.fromJson(Map<String, dynamic> json) {
    versionId = json['version_id'];
    android = json['android'];
    ios = json['ios'];
    isForceUpdate = json['is_force_update'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['version_id'] = this.versionId;
    data['android'] = this.android;
    data['ios'] = this.ios;
    data['is_force_update'] = this.isForceUpdate;
    return data;
  }
}
