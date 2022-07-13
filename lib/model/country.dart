class Country {
  int countriesId;
  int phoneCode;
  String countryCode;
  String countryName;

  Country(
      {this.countriesId, this.phoneCode, this.countryCode, this.countryName});

  Country.fromJson(Map<String, dynamic> json) {
    countriesId = json['countries_id'];
    phoneCode = json['phone_code'];
    countryCode = json['country_code'];
    print("Test1");
    countryName = json['country_name'];
    print("Test2");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['countries_id'] = this.countriesId;
    data['phone_code'] = this.phoneCode;
    data['country_code'] = this.countryCode;

    data['country_name'] = this.countryName;
    return data;
  }
}
