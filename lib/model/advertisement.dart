class Advertisement {
  int sliderId;
  String sliderImageName;

  Advertisement({this.sliderId, this.sliderImageName});

  Advertisement.fromJson(Map<String, dynamic> json) {
    sliderId = json['slider_id'];
    sliderImageName = json['slider_image_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['slider_id'] = this.sliderId;
    data['slider_image_name'] = this.sliderImageName;
    return data;
  }
}
