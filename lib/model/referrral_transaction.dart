class ReferralTransaction {
  int referralTransactionId;
  int walletId;
  int customerId;
  int referredCustomerId;
  double referralTransactionAmount;
  String referralTransactionCreatedAt;
  ReferredCustomer referredCustomer;

  ReferralTransaction(
      {this.referralTransactionId,
      this.walletId,
      this.customerId,
      this.referredCustomerId,
      this.referralTransactionAmount,
      this.referralTransactionCreatedAt,
      this.referredCustomer});

  ReferralTransaction.fromJson(Map<String, dynamic> json) {
    referralTransactionId = json['referral_transaction_id'];
    walletId = json['wallet_id'];
    customerId = json['customer_id'];
    referredCustomerId = json['referred_customer_id'];
    referralTransactionAmount = json['referral_transaction_amount'];
    referralTransactionCreatedAt = json['referral_transaction_created_at'];
    referredCustomer = json['referred_customer'] != null
        ? new ReferredCustomer.fromJson(json['referred_customer'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['referral_transaction_id'] = this.referralTransactionId;
    data['wallet_id'] = this.walletId;
    data['customer_id'] = this.customerId;
    data['referred_customer_id'] = this.referredCustomerId;
    data['referral_transaction_amount'] = this.referralTransactionAmount;
    data['referral_transaction_created_at'] = this.referralTransactionCreatedAt;
    if (this.referredCustomer != null) {
      data['referred_customer'] = this.referredCustomer.toJson();
    }
    return data;
  }
}

class ReferredCustomer {
  int customerId;
  String customerEmail;
  String customerName;
  String customerMobileNumber;
  String customerType;
  String customerDateOfBirth;
  String customerProfileImage;
  int status;
  String customerReferralCode;
  String customerReferrerCode;
  String customerDeviceToken;

  ReferredCustomer(
      {this.customerId,
      this.customerEmail,
      this.customerName,
      this.customerMobileNumber,
      this.customerType,
      this.customerDateOfBirth,
      this.customerProfileImage,
      this.status,
      this.customerReferralCode,
      this.customerReferrerCode,
      this.customerDeviceToken});

  ReferredCustomer.fromJson(Map<String, dynamic> json) {
    customerId = json['customer_id'];
    customerEmail = json['customer_email'];
    customerName = json['customer_name'];
    customerMobileNumber = json['customer_mobile_number'];
    customerType = json['customer_type'];
    customerDateOfBirth = json['customer_date_of_birth'];
    customerProfileImage = json['customer_profile_image'];
    status = json['status'];
    customerReferralCode = json['customer_referral_code'];
    customerReferrerCode = json['customer_referrer_code'];
    customerDeviceToken = json['customer_device_token'];
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
    data['status'] = this.status;
    data['customer_referral_code'] = this.customerReferralCode;
    data['customer_referrer_code'] = this.customerReferrerCode;
    data['customer_device_token'] = this.customerDeviceToken;
    return data;
  }
}
