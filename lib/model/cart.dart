import 'package:prabodham/model/product.dart';

class Cart {
  int cartId;
  int customerId;
  int cartTotalQty;
  double cartTotalPrice;
  int cartDiscount;
  double cartFinalPrice;
  int promocodeId;
  String cartDescription;
  List<CartItem> items;

  Cart(
      {this.cartId,
      this.customerId,
      this.cartTotalQty,
      this.cartTotalPrice,
      this.cartDiscount,
      this.cartFinalPrice,
      this.promocodeId,
      this.cartDescription,
      this.items});

  Cart.fromJson(Map<String, dynamic> json) {
    cartId = json['cart_id'];
    customerId = json['customer_id'];
    cartTotalQty = json['cart_total_qty'];
    cartTotalPrice = json['cart_total_price'] != Null
        ? double.tryParse(json['cart_total_price'].toString())
        : 0.00;
    cartDiscount = json['cart_discount'];
    cartFinalPrice = json['cart_final_price'] != Null
        ? double.tryParse(json['cart_final_price'].toString())
        : 0.00;
    promocodeId = json['promocode_id'];
    cartDescription = json['cart_description'];
    if (json['items'] != null) {
      items = new List<CartItem>();
      json['items'].forEach((v) {
        items.add(new CartItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cart_id'] = this.cartId;
    data['customer_id'] = this.customerId;
    data['cart_total_qty'] = this.cartTotalQty;
    data['cart_total_price'] = this.cartTotalPrice;
    data['cart_discount'] = this.cartDiscount;
    data['cart_final_price'] = this.cartFinalPrice;
    data['promocode_id'] = this.promocodeId;
    data['cart_description'] = this.cartDescription;
    if (this.items != null) {
      data['items'] = this.items.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CartItem {
  int cartItemsId;
  int cartId;
  int productId;
  int variantId;
  int cartItemsQty;
  Product product;

  CartItem(
      {this.cartItemsId,
      this.cartId,
      this.productId,
      this.variantId,
      this.cartItemsQty,
      this.product});

  CartItem.fromJson(Map<String, dynamic> json) {
    cartItemsId = json['cart_items_id'];
    cartId = json['cart_id'];
    productId = json['product_id'];
    variantId = json['variant_id'];
    cartItemsQty = json['cart_items_qty'];
    product =
        json['product'] != null ? new Product.fromJson(json['product']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cart_items_id'] = this.cartItemsId;
    data['cart_id'] = this.cartId;
    data['product_id'] = this.productId;
    data['variant_id'] = this.variantId;
    data['cart_items_qty'] = this.cartItemsQty;
    if (this.product != null) {
      data['product'] = this.product.toJson();
    }
    return data;
  }
}
