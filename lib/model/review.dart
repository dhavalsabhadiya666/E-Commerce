class Review {
  int reviewId;
  int customerId;
  int productId;
  String reviewDetails;
  int reviewRatings;
  String reviewCreatedAt;
  String customerName;
  String customerProfileImage;
  List<ReviewImages> reviewImages;

  Review(
      {this.reviewId,
      this.customerId,
      this.productId,
      this.reviewDetails,
      this.reviewRatings,
      this.reviewCreatedAt,
      this.customerName,
      this.customerProfileImage,
      this.reviewImages});

  Review.fromJson(Map<String, dynamic> json) {
    reviewId = json['review_id'];
    customerId = json['customer_id'];
    productId = json['product_id'];
    reviewDetails = json['review_details'];
    reviewRatings = json['review_ratings'].round();
    reviewCreatedAt = json['review_created_at'];
    customerName = json['customer_name'];
    customerProfileImage = json['customer_profile_image'];
    if (json['review_images'] != null) {
      reviewImages = new List<ReviewImages>();
      json['review_images'].forEach((v) {
        reviewImages.add(new ReviewImages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['review_id'] = this.reviewId;
    data['customer_id'] = this.customerId;
    data['product_id'] = this.productId;
    data['review_details'] = this.reviewDetails;
    data['review_ratings'] = this.reviewRatings;
    data['review_created_at'] = this.reviewCreatedAt;
    data['customer_name'] = this.customerName;
    data['customer_profile_image'] = this.customerProfileImage;
    if (this.reviewImages != null) {
      data['review_images'] = this.reviewImages.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ReviewImages {
  int reviewImagesId;
  int reviewId;
  String reviewImage;

  ReviewImages({this.reviewImagesId, this.reviewId, this.reviewImage});

  ReviewImages.fromJson(Map<String, dynamic> json) {
    reviewImagesId = json['review_images_id'];
    reviewId = json['review_id'];
    reviewImage = json['review_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['review_images_id'] = this.reviewImagesId;
    data['review_id'] = this.reviewId;
    data['review_image'] = this.reviewImage;
    return data;
  }
}
