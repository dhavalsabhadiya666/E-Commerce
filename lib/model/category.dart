class Category {
  int categoryId;
  String categoryName;
  String categoryDescription;
  String categoryImage;

  Category(
      {this.categoryId,
        this.categoryName,
        this.categoryDescription,
        this.categoryImage});

  Category.fromJson(Map<String, dynamic> json) {
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    categoryDescription = json['category_description'];
    categoryImage = json['category_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category_id'] = this.categoryId;
    data['category_name'] = this.categoryName;
    data['category_description'] = this.categoryDescription;
    data['category_image'] = this.categoryImage;
    return data;
  }
}
