class PromoCode {
  int promocodeId;
  String promocodeName;
  int promocodeDiscount;
  String promocodeTitle;
  String promocodeImage;
  String promocodeExpiryDate;

  PromoCode(
      {this.promocodeId,
      this.promocodeName,
      this.promocodeDiscount,
      this.promocodeTitle,
      this.promocodeImage,
      this.promocodeExpiryDate});

  PromoCode.fromJson(Map<String, dynamic> json) {
    if (json != null) {
      promocodeId = json['promocode_id'];
      promocodeName = json['promocode_name'];
      promocodeDiscount = json['promocode_discount'];
      promocodeTitle = json['promocode_title'];
      promocodeImage = json['promocode_image'];
      promocodeExpiryDate = json['promocode_expiry_date'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['promocode_id'] = this.promocodeId;
    data['promocode_name'] = this.promocodeName;
    data['promocode_discount'] = this.promocodeDiscount;
    data['promocode_title'] = this.promocodeTitle;
    data['promocode_image'] = this.promocodeImage;
    data['promocode_expiry_date'] = this.promocodeExpiryDate;
    return data;
  }
}
