import 'package:prabodham/model/review.dart';

class Product {
  int productId;
  int categoryId;
  String productName = "";
  double productPrice;
  double productDiscount;
  double productSpecialPrice;
  String productSpecialPriceType;
  DateTime productSpecialPriceStart;
  DateTime productSpecialPriceEnd;
  double productFinalPrice;
  String productDescription = "";
  int productQuantity = 0;
  int productStockAvailability;
  int productIsActive;
  String productHowToUse;
  String productCreatedAt;
  List<Review> review = [];
  bool favourite = false;
  List<ProductImages> productImages = [];
  String categoryName;
  List<Variant> variant = [];

  Product(
      {this.productId,
      this.categoryId,
      this.productName,
      this.productPrice,
      this.productDiscount,
      this.productSpecialPrice,
      this.productSpecialPriceType,
      this.productSpecialPriceStart,
      this.productSpecialPriceEnd,
      this.productFinalPrice,
      this.productDescription,
      this.productQuantity,
      this.productStockAvailability,
      this.productIsActive,
      this.productHowToUse,
      this.productCreatedAt,
      this.review,
      this.favourite,
      this.productImages,
      this.categoryName,
      this.variant});

  Product.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    categoryId = json['category_id'];
    productName = json['product_name'];

    productPrice = json['product_price'] != Null
        ? double.tryParse(json['product_price'].toString())
        : 0.00;
    productDiscount = json['product_discount'] != Null
        ? double.tryParse(json['product_discount'].toString())
        : 0.00;
    print(productDiscount.toStringAsFixed(2));

    productSpecialPrice = json['product_special_price'] != Null
        ? double.tryParse(json['product_special_price'].toString())
        : 0.00;

    productSpecialPriceType = json['product_special_price_type'];

    productSpecialPriceStart =
        DateTime.tryParse(json['product_special_price_start'] ?? "") ??
            DateTime.now();

    productSpecialPriceEnd =
        DateTime.tryParse(json['product_special_price_end'] ?? "") ??
            DateTime.now();

    productFinalPrice = json['product_final_price'] != Null
        ? double.tryParse(json['product_final_price'].toString())
        : 0.00;

    productDescription = json['product_description'];
    print("T1");
    productQuantity = json['product_quantity'];
    print("T2");
    productStockAvailability = json['product_stock_availability'];
    print("T3");
    productIsActive = json['product_is_active'];
    print("T4");
    productHowToUse = json['product_how_to_use'];
    print("T5");
    productCreatedAt = json['product_created_at'];
    print("T6");

    if (json['review'] != null) {
      review = new List<Review>();
      json['review'].forEach((v) {
        review.add(new Review.fromJson(v));
      });
    }
    favourite = json['favourite'];
    if (json['product_images'] != null) {
      productImages = new List<ProductImages>();
      json['product_images'].forEach((v) {
        productImages.add(new ProductImages.fromJson(v));
      });
    }
    categoryName = json['category_name'];
    if (json['variant'] != null) {
      variant = new List<Variant>();
      json['variant'].forEach((v) {
        variant.add(new Variant.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_id'] = this.productId;
    data['category_id'] = this.categoryId;
    data['product_name'] = this.productName;
    data['product_price'] = this.productPrice;
    data['product_discount'] = this.productDiscount;
    data['product_special_price'] = this.productSpecialPrice;
    data['product_special_price_type'] = this.productSpecialPriceType;
    data['product_special_price_start'] =
        this.productSpecialPriceStart.toString();
    data['product_special_price_end'] = this.productSpecialPriceEnd.toString();
    data['product_final_price'] = this.productFinalPrice;
    data['product_description'] = this.productDescription;
    data['product_quantity'] = this.productQuantity;
    data['product_stock_availability'] = this.productStockAvailability;
    data['product_is_active'] = this.productIsActive;
    data['product_how_to_use'] = this.productHowToUse;
    data['product_created_at'] = this.productCreatedAt;
    if (this.review != null) {
      data['review'] = this.review.map((v) => v.toJson()).toList();
    }
    data['favourite'] = this.favourite;
    if (this.productImages != null) {
      data['product_images'] =
          this.productImages.map((v) => v.toJson()).toList();
    }
    data['category_name'] = this.categoryName;
    if (this.variant != null) {
      data['variant'] = this.variant.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProductImages {
  int productImagesId;
  int productId;
  String productImageName;

  ProductImages({this.productImagesId, this.productId, this.productImageName});

  ProductImages.fromJson(Map<String, dynamic> json) {
    productImagesId = json['product_images_id'];
    productId = json['product_id'];
    productImageName = json['product_image_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_images_id'] = this.productImagesId;
    data['product_id'] = this.productId;
    data['product_image_name'] = this.productImageName;
    return data;
  }
}

class Variant {
  int variantId;
  String variantType;
  double variantSize;
  int productId;
  double variantPrice;
  double variantDiscount;
  double variantSpecialPrice;
  String variantSpecialPriceType;
  DateTime variantSpecialPriceStart;
  DateTime variantSpecialPriceEnd;
  double variantFinalPrice;
  int variantQty;
  int variantStockAvailability;

  Variant(
      {this.variantId,
      this.variantType,
      this.variantSize,
      this.productId,
      this.variantPrice,
      this.variantDiscount,
      this.variantSpecialPrice,
      this.variantSpecialPriceType,
      this.variantSpecialPriceStart,
      this.variantSpecialPriceEnd,
      this.variantFinalPrice,
      this.variantQty,
      this.variantStockAvailability});

  Variant.fromJson(Map<String, dynamic> json) {
    variantId = json['variant_id'];
    variantType = json['variant_type'];

    variantSize = json['variant_size'] != Null
        ? double.tryParse(json['variant_size'].toString())
        : 0.00;
    productId = json['product_id'];

    variantPrice = json['variant_price'] != Null
        ? double.tryParse(json['variant_price'].toString())
        : 0.00;

    variantDiscount = json['variant_discount'] != Null
        ? double.tryParse(json['variant_discount'].toString())
        : 0.00;
    print("Test9");
    variantSpecialPrice = json['variant_special_price'] != Null
        ? double.tryParse(json['variant_special_price'].toString())
        : 0.00;
    variantSpecialPriceType = json['variant_special_price_type'];
    variantSpecialPriceStart =
        DateTime.tryParse(json['variant_special_price_start'] ?? "");
    variantSpecialPriceEnd =
        DateTime.tryParse(json['variant_special_price_end'] ?? "");
    variantFinalPrice = json['variant_final_price'] != Null
        ? double.tryParse(json['variant_final_price'].toString())
        : 0.00;
    variantQty = json['variant_qty'];
    variantStockAvailability = json['variant_stock_availability'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['variant_id'] = this.variantId;
    data['variant_type'] = this.variantType;
    data['variant_size'] = this.variantSize;
    data['product_id'] = this.productId;
    data['variant_price'] = this.variantPrice;
    data['variant_discount'] = this.variantDiscount;
    data['variant_special_price'] = this.variantSpecialPrice;
    data['variant_special_price_type'] = this.variantSpecialPriceType;
    data['variant_special_price_start'] =
        this.variantSpecialPriceStart.toString();
    data['variant_special_price_end'] = this.variantSpecialPriceEnd.toString();
    data['variant_final_price'] = this.variantFinalPrice;
    data['variant_qty'] = this.variantQty;
    data['variant_stock_availability'] = this.variantStockAvailability;
    return data;
  }
}
