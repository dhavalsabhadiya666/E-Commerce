import 'package:prabodham/model/address.dart';
import 'package:prabodham/model/product.dart';
import 'package:prabodham/model/promocode.dart';

class Order {
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
  String orderStatusDescription;
  List<OrderItems> orderItems;
  List<Address> address;
  PromoCode promocode;

  Order({
    this.orderId,
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
    this.orderStatusDescription,
    this.orderItems,
    this.address,
    this.promocode,
  });

  Order.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    orderTotalQty = json['order_total_qty'];
    orderTotalPrice = json['order_total_price'] != Null
        ? double.tryParse(json['order_total_price'].toString())
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
    orderCreatedAt = json['order_created_at'];
    orderDeliveredAt = json['order_delivered_at'];
    razorpayPaymentId = json['razorpay_payment_id'];
    razorpayOrderId = json['razorpay_order_id'];
    razorpaySignature = json['razorpay_signature'];

    orderStatusDescription = json['order_status_description'];
    if (json['order_items'] != null) {
      orderItems = new List<OrderItems>();
      json['order_items'].forEach((v) {
        orderItems.add(new OrderItems.fromJson(v));
      });
    }
    if (json['address'] != null) {
      address = new List<Address>();
      json['address'].forEach((v) {
        address.add(new Address.fromJson(v));
      });
    }
    promocode = PromoCode.fromJson(json['promocode']);
    //print("T15");
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
    data['order_status_description'] = this.orderStatusDescription;
    if (this.orderItems != null) {
      data['order_items'] = this.orderItems.map((v) => v.toJson()).toList();
    }
    if (this.address != null) {
      data['address'] = this.address.map((v) => v.toJson()).toList();
    }
    data['promocode'] = this.promocode;
    return data;
  }
}

class OrderItems {
  int orderItemsId;
  int orderId;
  int productId;
  int orderItemsQty;
  double orderItemsPrice;
  Product product;
  String orderItemType;
  double orderItemSize;

  OrderItems(
      {this.orderItemsId,
      this.orderId,
      this.productId,
      this.orderItemsQty,
      this.orderItemsPrice,
      this.product,
      this.orderItemSize,
      this.orderItemType});

  OrderItems.fromJson(Map<String, dynamic> json) {
    orderItemsId = json['order_items_id'];
    orderId = json['order_id'];
    productId = json['product_id'];
    print("T10");
    orderItemsQty = json['order_items_qty'];
    print("T12");
    orderItemsPrice = json['order_items_price'] != Null
        ? double.tryParse(json['order_items_price'].toString())
        : 0.00;
    print("T13");
    product =
        json['product'] != null ? new Product.fromJson(json['product']) : null;
    orderItemType = json['order_item_type'];
    orderItemSize = json['order_item_size'] != Null
        ? double.tryParse(json['order_item_size'].toString())
        : 0.00;
    print("T14");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_items_id'] = this.orderItemsId;
    data['order_id'] = this.orderId;
    data['product_id'] = this.productId;
    data['order_items_qty'] = this.orderItemsQty;
    data['order_items_price'] = this.orderItemsPrice;
    data['order_items_size'] = this.orderItemSize;
    data['order_items_type'] = this.orderItemType;
    if (this.product != null) {
      data['product'] = this.product.toJson();
    }
    return data;
  }
}
