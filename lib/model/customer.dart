import 'package:prabodham/model/address.dart';

class Customer {
  int customerId;
  String customerEmail;
  String customerName;
  String customerMobileNumber;
  String customerType;
  DateTime customerDateOfBirth;
  String customerProfileImage;
  List<Address> address = [];
  String customerDeviceToken;
  String customerReferrerCode;
  String customerReferralCode;

  Customer(
      {this.customerId,
      this.customerEmail,
      this.customerName,
      this.customerMobileNumber,
      this.customerType,
      this.customerDateOfBirth,
      this.customerProfileImage,
      this.customerDeviceToken,
      this.address});

  Customer.fromJson(Map<String, dynamic> json) {
    customerId = json['customer_id'];
    customerEmail = json['customer_email'];
    customerName = json['customer_name'];
    customerMobileNumber = json['customer_mobile_number'];
    customerType = json['customer_type'];
    customerDateOfBirth =
        DateTime.tryParse(json['customer_date_of_birth'].toString());
    print(customerDateOfBirth);
    customerProfileImage = json['customer_profile_image'];
    customerDeviceToken = json['customer_device_token'];
    customerReferrerCode = json['customer_referrer_code'];
    customerReferralCode = json['customer_referral_code'];
    if (json['address'] != null) {
      address = new List<Address>();
      json['address'].forEach((v) {
        address.add(new Address.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['customer_id'] = this.customerId;
    data['customer_email'] = this.customerEmail;
    data['customer_name'] = this.customerName;
    data['customer_mobile_number'] = this.customerMobileNumber;
    data['customer_type'] = this.customerType;
    data['customer_date_of_birth'] = this.customerDateOfBirth;
    data['customer_profile_image'] = this.customerProfileImage;
    data['customer_device_token'] = this.customerDeviceToken;
    data['customer_referral_code'] = this.customerReferralCode;
    data['customer_referrer_code'] = this.customerReferrerCode;
    if (this.address != null) {
      data['address'] = this.address.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
