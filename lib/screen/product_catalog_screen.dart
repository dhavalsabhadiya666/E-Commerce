import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/data/services/product_api.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/helper/preference_keys.dart';
import 'package:prabodham/model/category.dart';
import 'package:prabodham/model/customer.dart';
import 'package:prabodham/model/product.dart';
import 'package:prabodham/model/review.dart';
import 'package:prabodham/screen/product_screen.dart';
import 'package:prabodham/screen/search_screen.dart';
import 'package:prabodham/widgets/component_widgets/smal_loader.dart';
import 'package:prabodham/widgets/custom_app_bar.dart';
import 'package:prabodham/widgets/custom_image.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class ProductCatalogScreen extends StatefulWidget {
  Category category;

  ProductCatalogScreen({this.category});

  @override
  _ProductCatalogScreenState createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  ProductApi _productApi = ProductApi();
  List<Product> poductList = [];
  bool isLoading = false;
  bool isListType = false;
  Customer userDetail;
  List<String> sortOn = [
    "Popular",
    "Newest",
    "Price: Low to High",
    "Price: High to Low",
  ];
  int selectedSort = 0;

  @override
  void initState() {
    super.initState();
    print("Product Catalog Screen");
    getProducts(context: context);
  }

  void setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  Future<void> getProducts({@required BuildContext context}) async {
    Functions.checkConnectivity().then((value) async {
      if (value != null && value == true) {
        String userjson = await PreferenceKeys.getUserDetail();
        userDetail = Customer.fromJson(jsonDecode(userjson));
        FormData data = new FormData.fromMap({
          'customer_id': userDetail.customerId,
          'category_id': widget.category.categoryId,
        });
        setLoading(true);
        try {
          ApiResponseModel apiResponse = await _productApi.getProductByCategory(
              context: context, data: data);
          print("Get Products Api response data :- ");

          if (apiResponse.success == true && apiResponse.response != null) {
            var list = apiResponse.response as List;
            poductList = list.map((element) {
              return Product.fromJson(element);
            }).toList();
            setLoading(false);
          } else {
            setLoading(false);
            Functions.toast(apiResponse.message);
          }
        } catch (e) {
          print(e.toString());
          setLoading(false);
          final errorMessage = DioExceptions.fromDioError(e).toString();
          showCustomDialog(context, 'Error', errorMessage);
        }
      }
    });
  }

  Future<void> updateFavourite(
      {@required BuildContext context, Product product}) async {
    Functions.checkConnectivity().then((value) async {
      if (value != null && value == true) {
        String userjson = await PreferenceKeys.getUserDetail();
        userDetail = Customer.fromJson(jsonDecode(userjson));
        FormData data = new FormData.fromMap({
          'customer_id': userDetail.customerId,
          'product_id': product.productId,
        });

        try {
          ApiResponseModel apiResponse = await _productApi
              .updateProductFavourite(context: context, data: data);
          print("Update Favourite Api response data :- ");

          if (apiResponse.success == true && apiResponse.response != null) {
            Functions.toast(apiResponse.message);
          } else {
            Functions.toast(apiResponse.message);
          }
        } catch (e) {
          print(e.toString());
          final errorMessage = DioExceptions.fromDioError(e).toString();
          showCustomDialog(context, 'Error', errorMessage);
        }
      }
    });
  }

  void sortProducts(int sortBy) {
    List<Product> sortingProductList = [];
    sortingProductList = poductList;
    switch (sortBy) {
      case 0:
        {
          print("Sorting Case : " + sortBy.toString());
          sortingProductList.sort((a, b) {
            return averageProductRating(a.review)
                .compareTo(averageProductRating(b.review));
          });
        }
        break;
      case 1:
        {
          print("Sorting Case : " + sortBy.toString());
          sortingProductList.sort((a, b) {
            return -(DateTime.parse(a.productCreatedAt)
                .difference(DateTime.parse(b.productCreatedAt))
                .inDays);
          });
        }
        break;
      case 2:
        {
          print("Sorting Case : " + sortBy.toString());
          sortingProductList.sort((a, b) {
            return a.variant[0].variantFinalPrice
                .compareTo(b.variant[0].variantFinalPrice);
          });
        }
        break;
      case 3:
        {
          print("Sorting Case : " + sortBy.toString());
          sortingProductList.sort((a, b) {
            return -(a.variant[0].variantFinalPrice
                .compareTo(b.variant[0].variantFinalPrice));
          });
        }
        break;
    }
    setState(() {
      poductList = sortingProductList;
    });
  }

  double averageProductRating(List<Review> reviewList) {
    double total_rating = 0;
    for (Review r in reviewList) {
      total_rating += r.reviewRatings;
    }
    return reviewList.length != 0 ? (total_rating / reviewList.length) : 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: CustomAppBar(
            title: Text(widget.category.categoryName),
            centerTitle: true,
            elevation: 5,
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                }),
            actions: [
              GestureDetector(
                onTap: () {
                  print("Search");
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SearchScreen()));
                },
                child: Container(
                  height: 40,
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  margin: EdgeInsets.only(top: 10, right: 15, bottom: 10),
                  alignment: Alignment.center,
                  child: Icon(Icons.search),
                ),
              ),
            ]),
        backgroundColor: Theme.of(context).canvasColor,
        body: isLoading
            ? smallLoader(context: context, height: 70)
            : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 20,
                        bottom: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: GestureDetector(
                              onTap: () {
                                print("Sort By");
                                filterPopUp();
                              },
                              child: Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.swap_vert,
                                      size: 30,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 10),
                                      child: Text(
                                        sortOn[selectedSort],
                                        style: Theme.of(context)
                                            .textTheme
                                            .body2
                                            .copyWith(
                                                color: Colors.grey,
                                                fontSize: 16),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () {
                                print("List View Change");
                                setState(() {
                                  isListType = !isListType;
                                });
                              },
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: isListType
                                    ? Icon(Icons.view_list)
                                    : Icon(Icons.grid_view),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          top: 10, left: 20, right: 20, bottom: 20),
                      child: isListType
                          ? GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 15.0,
                                mainAxisSpacing: 20,
                                mainAxisExtent: 280,
                              ),
                              itemCount: poductList.length,
                              itemBuilder: (BuildContext context, int index) {
                                return productCard(poductList[index]);
                              },
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              separatorBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                );
                              },
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: poductList.length,
                              itemBuilder: (context, index) {
                                return productCard(poductList[index]);
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget productCard(Product product) {
    double averageRating = averageProductRating(product.review);
    return isListType
        ? GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductScreen(
                    product: product,
                  ),
                ),
              ).then((value) {
                print("Is Updated: " + value.toString());
                if (value) {
                  getProducts(context: context);
                }
              });
            },
            child: Card(
              elevation: 5,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Stack(
                children: [
                  Container(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Column(
                        children: [
                          Container(
                            child: Stack(
                              children: [
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        child: AspectRatio(
                                          aspectRatio: 1.0,
                                          child: CustomImage(
                                            imgURL: product.productImages[0]
                                                .productImageName,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin:
                                            EdgeInsets.only(top: 8, left: 10),
                                        child: FittedBox(
                                          child: Row(
                                            children: [
                                              SmoothStarRating(
                                                allowHalfRating: true,
                                                starCount: 5,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                borderColor: Colors.grey,
                                                size: 20,
                                                spacing: 1.0,
                                                isReadOnly: true,
                                                //Need to fetch rating
                                                rating: averageRating,
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Container(
                                                child: Text(
                                                  "${product.review.length}",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .body1
                                                      .copyWith(),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: -4,
                                  child: Container(
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: FloatingActionButton(
                                      backgroundColor: Colors.white,
                                      elevation: 1.0,
                                      onPressed: () {
                                        setState(() {
                                          product.favourite =
                                              !product.favourite;
                                          updateFavourite(
                                              context: context,
                                              product: product);
                                        });
                                      },
                                      child: product.favourite
                                          ? Icon(
                                              Icons.favorite,
                                              size: 20,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            )
                                          : Icon(
                                              Icons.favorite_border,
                                              size: 20,
                                              color: Colors.grey,
                                            ),
                                    ),
                                  ),
                                ),
                                // Positioned(
                                //   top: 4,
                                //   left: 0,
                                //   child: Container(
                                //     padding: EdgeInsets.all(5),
                                //     margin: EdgeInsets.only(
                                //       left: 5,
                                //       top: 5,
                                //     ),
                                //     decoration: BoxDecoration(
                                //       borderRadius:
                                //           BorderRadius.all(Radius.circular(20)),
                                //       color: Colors.black,
                                //     ),
                                //     child: Text(
                                //       product.productDiscount.toString() + "%",
                                //       style: Theme.of(context)
                                //           .textTheme
                                //           .body2
                                //           .copyWith(color: Colors.white),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.only(top: 10, left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Text(
                                    product.productName,
                                    style: Theme.of(context).textTheme.caption,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    widget.category.categoryName,
                                    style: Theme.of(context).textTheme.body1,
                                    maxLines: 1,
                                  ),
                                ),
                                Container(
                                    margin: EdgeInsets.only(top: 5),
                                    child: FittedBox(
                                      child: Row(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(right: 5),
                                            child: Text(
                                              '\u{20B9}${product.variant[0].variantPrice.toStringAsFixed(2)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .body2
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.grey,
                                                      decoration: TextDecoration
                                                          .lineThrough),
                                            ),
                                          ),
                                          Container(
                                            child: Text(
                                              '\u{20B9}${product.variant[0].variantFinalPrice.toStringAsFixed(2)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .body1
                                                  .copyWith(
                                                    fontWeight: FontWeight.w400,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductScreen(
                    product: product,
                  ),
                ),
              ).then((value) {
                print("Is Updated: " + value.toString());
                if (value) {
                  getProducts(context: context);
                }
              });
            },
            child: Container(
              padding: EdgeInsets.all(0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                borderOnForeground: true,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            child: CustomImage(
                              imgURL: product.productImages[0].productImageName,
                              height: 135,
                              width: 130,
                            ),
                          ),
                          // Positioned(
                          //   top: 4,
                          //   left: 0,
                          //   child: Container(
                          //     padding: EdgeInsets.all(5),
                          //     margin: EdgeInsets.only(
                          //       left: 5,
                          //       top: 5,
                          //     ),
                          //     decoration: BoxDecoration(
                          //       borderRadius:
                          //           BorderRadius.all(Radius.circular(20)),
                          //       color: Colors.black,
                          //     ),
                          //     child: Text(
                          //       product.productDiscount.toString() + "%",
                          //       style: Theme.of(context)
                          //           .textTheme
                          //           .body2
                          //           .copyWith(color: Colors.white),
                          //     ),
                          //   ),
                          //),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.only(
                          right: 6,
                          left: 12,
                          top: 10,
                          bottom: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      product.productName,
                                      style: Theme.of(context).textTheme.body2,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: FloatingActionButton(
                                      backgroundColor: Colors.white,
                                      elevation: 1.0,
                                      onPressed: () {
                                        setState(() {
                                          product.favourite =
                                              !product.favourite;
                                          updateFavourite(
                                              context: context,
                                              product: product);
                                        });
                                      },
                                      child: product.favourite
                                          ? Icon(
                                              Icons.favorite,
                                              size: 20,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            )
                                          : Icon(
                                              Icons.favorite_border,
                                              size: 20,
                                              color: Colors.grey,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 5),
                              child: Text(
                                widget.category.categoryName,
                                style:
                                    Theme.of(context).textTheme.body2.copyWith(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                top: 8,
                              ),
                              child: Row(
                                children: [
                                  SmoothStarRating(
                                    allowHalfRating: true,
                                    starCount: 5,
                                    color: Theme.of(context).primaryColor,
                                    borderColor: Colors.grey,
                                    size: 20,
                                    spacing: 1.0,
                                    isReadOnly: true,
                                    //Need to fetch rating
                                    rating: averageRating,
                                  ),
                                  Container(
                                    child: Text(
                                        //Need to fetch rating
                                        " ${product.review.length}",
                                        style:
                                            Theme.of(context).textTheme.body2),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10, right: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 8),
                                    child: Text(
                                      '\u{20B9}${(product.variant != null && product.variant.length > 0) ? product.variant[0].variantPrice.toStringAsFixed(2) : 0}',
                                      textAlign: TextAlign.left,
                                      style: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .copyWith(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey,
                                              decoration:
                                                  TextDecoration.lineThrough),
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      '\u{20B9}${(product.variant != null && product.variant.length > 0) ? product.variant[0].variantFinalPrice.toStringAsFixed(2) : 0}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .body1
                                          .copyWith(
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Future<dynamic> filterPopUp() {
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 0),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 40),
                child: Text(
                  "Sort by",
                  style: Theme.of(context).textTheme.subtitle,
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: 30,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: sortOn.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedSort = index;
                        });
                        sortProducts(selectedSort);
                        print("Selected Sort : " + sortOn[selectedSort]);
                        Navigator.pop(context);
                      },
                      child: Container(
                        color: selectedSort == index
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        padding: EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Text(
                            sortOn[index],
                            style: TextStyle(
                                color: selectedSort == index
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
