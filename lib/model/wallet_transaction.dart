class WalletTransaction {
  int orderId;
  int orderTotalQty;
  double orderTotalPrice;
  double orderDiscount;
  double orderFinalPrice;
  int orderTrack;
  int orderStatusId;
  String orderDescription;
  String orderPaymentMethod;
  String orderDeliveryMethod;
  int customerAddressId;
  int promocodeId;
  int customerId;
  String orderCreatedAt;
  String orderDeliveredAt;
  String razorpayPaymentId;
  String razorpayOrderId;
  String razorpaySignature;
  double walletPay;
  String orderStatusDescription;

  WalletTransaction(
      {this.orderId,
      this.orderTotalQty,
      this.orderTotalPrice,
      this.orderDiscount,
      this.orderFinalPrice,
      this.orderTrack,
      this.orderStatusId,
      this.orderDescription,
      this.orderPaymentMethod,
      this.orderDeliveryMethod,
      this.customerAddressId,
      this.promocodeId,
      this.customerId,
      this.orderCreatedAt,
      this.orderDeliveredAt,
      this.razorpayPaymentId,
      this.razorpayOrderId,
      this.razorpaySignature,
      this.walletPay,
      this.orderStatusDescription});

  WalletTransaction.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    orderTotalQty = json['order_total_qty'];
    orderTotalPrice = json['order_total_price'] != Null
        ? double.tryParse(json['order_item_price'].toString())
        : 0.00;
    orderDiscount = json['order_discount'] != Null
        ? double.tryParse(json['order_discount'].toString())
        : 0.00;
    orderFinalPrice = json['order_final_price'] != Null
        ? double.tryParse(json['order_final_price'].toString())
        : 0.00;
    orderTrack = json['order_track'];
    orderStatusId = json['order_status_id'];
    orderDescription = json['order_description'];
    orderPaymentMethod = json['order_payment_method'];
    orderDeliveryMethod = json['order_delivery_method'];
    customerAddressId = json['customer_address_id'];
    promocodeId = json['promocode_id'];
    customerId = json['customer_id'];
    print("TEst1");
    orderCreatedAt = json['order_created_at'];
    orderDeliveredAt = json['order_delivered_at'];
    print("TEst2");
    razorpayPaymentId = json['razorpay_payment_id'];
    razorpayOrderId = json['razorpay_order_id'];
    razorpaySignature = json['razorpay_signature'];
    walletPay = json['wallet_pay'] != Null
        ? double.tryParse(json['wallet_pay'].toString())
        : 0.00;
    orderStatusDescription = json['order_status_description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_id'] = this.orderId;
    data['order_total_qty'] = this.orderTotalQty;
    data['order_total_price'] = this.orderTotalPrice;
    data['order_discount'] = this.orderDiscount;
    data['order_final_price'] = this.orderFinalPrice;
    data['order_track'] = this.orderTrack;
    data['order_status_id'] = this.orderStatusId;
    data['order_description'] = this.orderDescription;
    data['order_payment_method'] = this.orderPaymentMethod;
    data['order_delivery_method'] = this.orderDeliveryMethod;
    data['customer_address_id'] = this.customerAddressId;
    data['promocode_id'] = this.promocodeId;
    data['customer_id'] = this.customerId;
    data['order_created_at'] = this.orderCreatedAt;
    data['order_delivered_at'] = this.orderDeliveredAt;
    data['razorpay_payment_id'] = this.razorpayPaymentId;
    data['razorpay_order_id'] = this.razorpayOrderId;
    data['razorpay_signature'] = this.razorpaySignature;
    data['wallet_pay'] = this.walletPay;
    data['order_status_description'] = this.orderStatusDescription;
    return data;
  }
}
