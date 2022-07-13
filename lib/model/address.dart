class Address {
  int customerAddressId;
  int customerId;
  String customerAddressName;
  String customerAddressDetails;
  String customerAddressCity;
  String customerAddressState;
  String customerAddressZipcode;
  int customerAddressDefault;
  int countriesId;
  String countryName;

  Address(
      {this.customerAddressId,
        this.customerId,
        this.customerAddressName,
        this.customerAddressDetails,
        this.customerAddressCity,
        this.customerAddressState,
        this.customerAddressZipcode,
        this.customerAddressDefault,
        this.countriesId,
        this.countryName});

  Address.fromJson(Map<String, dynamic> json) {
    customerAddressId = json['customer_address_id'];
    customerId = json['customer_id'];
    customerAddressName = json['customer_address_name'];
    customerAddressDetails = json['customer_address_details'];
    customerAddressCity = json['customer_address_city'];
    customerAddressState = json['customer_address_state'];
    customerAddressZipcode = json['customer_address_zipcode'];
    customerAddressDefault = json['customer_address_default'];
    countriesId = json['countries_id'];
    countryName = json['country_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['customer_address_id'] = this.customerAddressId;
    data['customer_id'] = this.customerId;
    data['customer_address_name'] = this.customerAddressName;
    data['customer_address_details'] = this.customerAddressDetails;
    data['customer_address_city'] = this.customerAddressCity;
    data['customer_address_state'] = this.customerAddressState;
    data['customer_address_zipcode'] = this.customerAddressZipcode;
    data['customer_address_default'] = this.customerAddressDefault;
    data['countries_id'] = this.countriesId;
    data['country_name'] = this.countryName;
    return data;
  }
}