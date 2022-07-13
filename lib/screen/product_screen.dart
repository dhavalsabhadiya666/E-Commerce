import 'dart:convert';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:intl/intl.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/data/services/cart_api.dart';
import 'package:prabodham/data/services/product_api.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/global/variable/custom_app_theme.dart';
import 'package:prabodham/helper/preference_keys.dart';
import 'package:prabodham/model/cart.dart';
import 'package:prabodham/model/customer.dart';
import 'package:prabodham/model/product.dart';
import 'package:prabodham/model/review.dart';
import 'package:prabodham/screen/cart_screen.dart';
import 'package:prabodham/screen/rating_screen.dart';
import 'package:prabodham/widgets/component_widgets/loader.dart';
import 'package:prabodham/widgets/component_widgets/smal_loader.dart';
import 'package:prabodham/widgets/custom_app_bar.dart';
import 'package:prabodham/widgets/custom_image.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class ProductScreen extends StatefulWidget {
  Product product;
  ProductScreen({Key key, @required this.product}) : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  ProductApi _productApi = ProductApi();
  CartApi _cartApi = CartApi();
  CarouselController _carouselController = CarouselController();

  List<Review> reviewList;
  Customer userDetail;

  Product productItem;

  List<String> optionList = ["How to use product"];
  double _currentSliderValue = 0;

  Variant _chosenSize;
  String _chosenQty = "1";
  double averageRating = 0;
  bool isLoading = false;
  bool isUpdated = false;
  bool cartIsUpdating = true;
  bool _showUse = false;
  double _productPrice;
  double _productOldPrice;
  int cartCount = 0;

  @override
  void initState() {
    super.initState();
    getProductById();
    // getRecommendedProducts();
  }

  void setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
    print("Setting " + isLoading.toString());
  }

  Future<void> updateFavourite({@required BuildContext context}) async {
    Functions.checkConnectivity().then((value) async {
      if (value != null && value == true) {
        String userjson = await PreferenceKeys.getUserDetail();
        userDetail = Customer.fromJson(jsonDecode(userjson));
        FormData data = new FormData.fromMap({
          'customer_id': userDetail.customerId,
          'product_id': widget.product.productId,
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

  void getProductById() {
    setLoading(true);
    Functions.checkConnectivity().then((value) async {
      String userjson = await PreferenceKeys.getUserDetail();
      userDetail = Customer.fromJson(jsonDecode(userjson));
      if (value != null && value == true) {
        FormData data = new FormData.fromMap({
          'customer_id': userDetail.customerId,
          'product_id': widget.product.productId,
        });

        try {
          ApiResponseModel apiResponse =
              await _productApi.getProductById(context: context, data: data);
          print("Get Product By ID Api response data :- ");

          if (apiResponse.success == true && apiResponse.response != null) {
            productItem = Product.fromJson(apiResponse.response);
            reviewList = productItem.review;
            getCartDetail(context: context);
          } else {
            setLoading(false);
            Functions.toast(apiResponse.message);
          }
        } catch (e) {
          print(e.toString() + "Error");
          if (mounted) {
            setLoading(false);
          }
          final errorMessage = DioExceptions.fromDioError(e).toString();
          showCustomDialog(context, 'Error', errorMessage);
        }
        getAverageRatings();
        _chosenSize = productItem.variant[0];
        _productPrice = productItem.variant[0].variantFinalPrice;
        _productOldPrice = productItem.variant[0].variantPrice;
      }
      setLoading(false);
    });
  }

  void getRecommendedProducts() {
    Functions.checkConnectivity().then((value) async {
      String userjson = await PreferenceKeys.getUserDetail();
      userDetail = Customer.fromJson(jsonDecode(userjson));
      if (value != null && value == true) {
        FormData data = new FormData.fromMap({
          //POST DATA TO GET RECOMMENDED PRODUCTS
        });
        // _productApi.getRecommendedProducts(context: context,data: data);
      }
    });
  }

  Future<void> updateCart({@required BuildContext context}) async {
    setState(() {
      cartIsUpdating = true;
    });
    Functions.checkConnectivity().then((value) async {
      if (value != null && value == true) {
        String userjson = await PreferenceKeys.getUserDetail();
        userDetail = Customer.fromJson(jsonDecode(userjson));
        FormData data = new FormData.fromMap({
          'customer_id': userDetail.customerId,
          'product_id': widget.product.productId,
          'qty': _chosenQty,
          'variant_id': _chosenSize.variantId,
        });
        try {
          ApiResponseModel apiResponse =
              await _cartApi.updateCart(context: context, data: data);
          print("Update Cart Api response data :- ");

          if (apiResponse.success == true && apiResponse.response != null) {
            getCartDetail(context: context);
            setState(() {
              cartIsUpdating = false;
            });
            Functions.toast(apiResponse.message);
          } else {
            Functions.toast(apiResponse.message);
          }
        } catch (e) {
          setState(() {
            cartIsUpdating = false;
          });
          print(e.toString());
          final errorMessage = DioExceptions.fromDioError(e).toString();
          showCustomDialog(context, 'Error', errorMessage);
        }
      }
    });
  }

  Future<void> getCartDetail({@required BuildContext context}) async {
    setState(() {
      cartIsUpdating = true;
    });
    Functions.checkConnectivity().then((value) async {
      if (value != null && value == true) {
        String userjson = await PreferenceKeys.getUserDetail();
        userDetail = Customer.fromJson(jsonDecode(userjson));
        FormData data = new FormData.fromMap({
          'customer_id': userDetail.customerId,
        });
        try {
          ApiResponseModel apiResponse =
              await _cartApi.getCartDetail(context: context, data: data);
          print("Cart Details Api response data :- ");

          if (apiResponse.success == true && apiResponse.response != null) {
            Cart cart = Cart.fromJson(apiResponse.response);

            setState(() {
              cartIsUpdating = false;
              cartCount = cart.items.length;
            });
          } else {
            setState(() {
              cartIsUpdating = false;
            });
            Functions.toast(apiResponse.message);
          }
        } catch (e) {
          setState(() {
            cartIsUpdating = false;
          });
          print(e.toString());
          final errorMessage = DioExceptions.fromDioError(e).toString();
          showCustomDialog(context, 'Error', errorMessage);
        }
      }
    });
  }

  void getAverageRatings() {
    double ratingTotal = 0;
    productItem.review.forEach((element) {
      ratingTotal += element.reviewRatings;
    });
    setState(() {
      averageRating = ratingTotal / productItem.review.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    // print(productItem.productImages.length);
    print("Avg Rating  : " + averageRating.toString());
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        child: Scaffold(
          appBar: CustomAppBar(
            title: Text("Beauty"),
            centerTitle: true,
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context, isUpdated);
                }),
            actions: [
              cartIsUpdating
                  ? smallLoader(context: context, height: 30)
                  : Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: IconButton(
                              icon: Icon(
                                Icons.shopping_cart_outlined,
                                size: 28,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CartScreen(
                                              showBackButton: true,
                                            ))).then((value) {
                                  setState(() {
                                    getProductById();
                                  });
                                });
                              }),
                        ),
                        Positioned(
                          top: 6,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(6),
                            margin: EdgeInsets.only(
                              right: 4,
                              top: 0,
                            ),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor,
                            ),
                            child: Text(
                              cartCount.toString(),
                              style:
                                  Theme.of(context).textTheme.caption.copyWith(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                            ),
                          ),
                        ),
                      ],
                    ),
              SizedBox(
                width: 10,
              )
            ],
          ),
          backgroundColor: Theme.of(context).canvasColor,
          body: Stack(
            children: [
              isLoading
                  ? Container()
                  : SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.only(bottom: 30),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              child: CarouselSlider(
                                carouselController: _carouselController,
                                options: CarouselOptions(
                                  autoPlay: true,
                                  enlargeCenterPage: false,
                                  height:
                                      MediaQuery.of(context).size.height / 2.3,
                                  viewportFraction: 1.0,
                                ),
                                items: productItem.productImages
                                    .map((image_url) => CarouselItem(
                                          url: image_url.productImageName,
                                        ))
                                    .toList(),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 15),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 50,
                                    margin: EdgeInsets.only(top: 20),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Container(
                                            margin: EdgeInsets.only(right: 15),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            child: DropdownButtonFormField<
                                                Variant>(
                                              value: _chosenSize,
                                              hint: Text(
                                                "Size",
                                              ),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .body2,
                                              items: productItem.variant.map<
                                                  DropdownMenuItem<
                                                      Variant>>((value) {
                                                return DropdownMenuItem(
                                                  value: value,
                                                  child: Container(
                                                    child: Text(
                                                      value.variantSize
                                                              .toString() +
                                                          " " +
                                                          value.variantType,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                border: InputBorder.none,
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  _chosenSize = value;
                                                  _productPrice =
                                                      value.variantFinalPrice;
                                                  _productOldPrice =
                                                      value.variantPrice;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Container(
                                            margin: EdgeInsets.only(right: 15),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            child:
                                                DropdownButtonFormField<String>(
                                              value: _chosenQty,
                                              hint: Text("Qty"),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .body2,
                                              items: List<int>.generate(
                                                  10, (i) => i + 1).map<
                                                      DropdownMenuItem<String>>(
                                                  (value) {
                                                return DropdownMenuItem(
                                                  value: value.toString(),
                                                  child: Container(
                                                    child: Text(
                                                      value.toString(),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                border: InputBorder.none,
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  _chosenQty = value;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                            ),
                                            child: FloatingActionButton(
                                              backgroundColor: Colors.white,
                                              elevation: 1.0,
                                              onPressed: () {
                                                setState(() {
                                                  productItem.favourite =
                                                      !productItem.favourite;
                                                  isUpdated = true;
                                                  updateFavourite(
                                                      context: context);
                                                });
                                              },
                                              child: productItem.favourite !=
                                                          null &&
                                                      productItem.favourite ==
                                                          true
                                                  ? Icon(
                                                      Icons.favorite,
                                                      size: 24,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    )
                                                  : Icon(
                                                      Icons.favorite_border,
                                                      size: 24,
                                                      color: Colors.grey,
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 25),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            productItem.productName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .body1,
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(right: 5),
                                          child: Text(
                                            '\u{20B9} ${_productOldPrice.toStringAsFixed(2)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .body2
                                                .copyWith(
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.grey,
                                                    decoration: TextDecoration
                                                        .lineThrough),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Container(
                                          child: Text(
                                            '\u{20B9} ${_productPrice.toStringAsFixed(2)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .body1
                                                .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 5),
                                    child: Text(
                                      productItem.categoryName ?? "",
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 5),
                                    child: Row(
                                      children: [
                                        SmoothStarRating(
                                          allowHalfRating: true,
                                          starCount: 5,
                                          color: Theme.of(context).primaryColor,
                                          borderColor: Colors.black,
                                          size: 25,
                                          spacing: 1.0,
                                          isReadOnly: true,
                                          rating: averageRating.isNaN
                                              ? 0
                                              : averageRating,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Container(
                                          child: Text(
                                            "${productItem.review.length} ",
                                            style: Theme.of(context)
                                                .textTheme
                                                .body1
                                                .copyWith(
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 20),
                                    child: Text(
                                      "Description",
                                      style: Theme.of(context)
                                          .textTheme
                                          .body1
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  productItem.productDescription == ""
                                      ? Container(
                                          padding: EdgeInsets.only(top: 10),
                                          child: Text(
                                            "Nothing",
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ))
                                      : Container(),
                                  Container(
                                    height: productItem.productDescription == ""
                                        ? 0
                                        : 100,
                                    child: Markdown(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      data: html2md.convert(
                                          productItem.productDescription),
                                    ),
                                  ),
                                  Divider(),
                                  Container(
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      itemCount: optionList.length,
                                      physics: NeverScrollableScrollPhysics(),
                                      separatorBuilder: (context, index) =>
                                          Divider(
                                        thickness: 0.4,
                                        color: Colors.grey,
                                      ),
                                      itemBuilder: (context, index) {
                                        return _showUse
                                            ? Column(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      print(optionList[index]);
                                                    },
                                                    child: ListTile(
                                                      title: Text(
                                                        optionList[index],
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .body1
                                                            .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                      ),
                                                      contentPadding:
                                                          EdgeInsets.all(0),
                                                      trailing: IconButton(
                                                        icon: Icon(Icons.close),
                                                        onPressed: () {
                                                          setState(() {
                                                            _showUse =
                                                                !_showUse;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Text(
                                                      productItem
                                                          .productHowToUse,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .body2
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : GestureDetector(
                                                onTap: () {
                                                  print(optionList[index]);
                                                },
                                                child: ListTile(
                                                  title: Text(
                                                    optionList[index],
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .body1
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                  contentPadding:
                                                      EdgeInsets.all(0),
                                                  trailing: IconButton(
                                                    icon: Icon(Icons.add),
                                                    onPressed: () {
                                                      setState(() {
                                                        _showUse = true;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              );
                                      },
                                    ),
                                  ),
                                  Divider(),
                                  Container(
                                    margin:
                                        EdgeInsets.only(top: 20, bottom: 20),
                                    child: Text(
                                      "Reviews",
                                      style: Theme.of(context)
                                          .textTheme
                                          .body1
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    child: ListView.separated(
                                      itemCount: (reviewList.length > 2)
                                          ? 2
                                          : reviewList.length,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      separatorBuilder: (context, index) =>
                                          SizedBox(
                                        height: 10,
                                      ),
                                      itemBuilder: (context, index) {
                                        return reviewCard(
                                            review: reviewList[index]);
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      RatingScreen(
                                                        reviewList: reviewList,
                                                        productId: productItem
                                                            .productId,
                                                      )))
                                          .then((value) => getProductById());
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        children: [
                                          Container(
                                            child: Text(
                                              "Load More Reviews",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .body2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 80,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              Container(
                child: isLoading
                    ? Loader(
                        bgColor: CustomAppTheme.white,
                        loaderColor: Theme.of(context).primaryColor,
                      )
                    : Container(),
              ),
            ],
          ),
          bottomSheet: Container(
            color: Colors.transparent,
            child: Container(
              margin: EdgeInsets.only(top: 5, bottom: 10, left: 16, right: 16),
              child: GestureDetector(
                onTap: () {
                  print("Add to Cart");
                  updateCart(context: context);
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(25)),
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                      child: Text(
                    "ADD TO CART",
                    style: Theme.of(context).textTheme.button,
                  )),
                ),
              ),
            ),
          ),
        ),
        onWillPop: () {
          Navigator.pop(context, isUpdated);
        },
      ),
    );
  }

  Widget CarouselItem({String url}) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 0,
      ),
      child: Center(
        child: ClipRRect(
          child: Image.network(
            url,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  Widget reviewCard({Review review}) {
    return Card(
      elevation: 2,
      child: Container(
        constraints: BoxConstraints.loose(Size.fromHeight(350)),
        padding: EdgeInsets.only(left: 15, top: 15, right: 10, bottom: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: CustomImage(
                      height: 40,
                      width: 40,
                      imgURL: review.customerProfileImage,
                    ),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: Text(
                    review.customerName,
                    style: Theme.of(context).textTheme.body2,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Row(
                children: [
                  Expanded(
                    child: SmoothStarRating(
                      allowHalfRating: true,
                      starCount: 5,
                      color: Color.fromRGBO(255, 186, 73, 1.0),
                      borderColor: Colors.grey,
                      size: 20,
                      spacing: 1.0,
                      isReadOnly: true,
                      rating: review.reviewRatings.toDouble(),
                    ),
                  ),
                  Container(
                    child: Text(
                      DateFormat("dd MMMM , yyyy")
                          .format(DateTime.parse(review.reviewCreatedAt))
                          .toString(),
                      style: Theme.of(context).textTheme.caption.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Text(
                review.reviewDetails,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.body2.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ),
            review.reviewImages == null
                ? Container()
                : Container(
                    margin: EdgeInsets.only(top: 10),
                    height: 110,
                    child: ListView.separated(
                      itemCount: review.reviewImages.length,
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (context, index) => SizedBox(
                        width: 20,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: CustomImage(
                              imgURL: review.reviewImages[index].reviewImage,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
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
          margin: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 40),
                child: Text(
                  "Filters",
                  style: Theme.of(context).textTheme.subtitle,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                alignment: Alignment.centerLeft,
                child: Text(
                  "Categories",
                  style: Theme.of(context).textTheme.body1.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 15),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.only(right: 20),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.black,
                          ),
                        ),
                        child: Text(
                          "Beauty",
                          style: Theme.of(context).textTheme.body2.copyWith(
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.black,
                          ),
                        ),
                        child: Text(
                          "Hair",
                          style: Theme.of(context).textTheme.body2.copyWith(
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 25),
                alignment: Alignment.centerLeft,
                child: Text(
                  "Price",
                  style: Theme.of(context).textTheme.body1.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 40),
                child: Slider(
                  value: _currentSliderValue,
                  min: 0,
                  max: 100,
                  divisions: 5,
                  label: _currentSliderValue.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _currentSliderValue = value;
                      print("Price :" + value.toString());
                    });
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 0, bottom: 40, left: 0, right: 0),
                margin: EdgeInsets.only(top: 30),
                child: GestureDetector(
                  onTap: () {
                    print("Adding to Cart");
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(25)),
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                        child: Text(
                      "ADD TO CART",
                      style: Theme.of(context).textTheme.button,
                    )),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

//RECOMMENDED ProductScreen "#DO NOT DELETE"

// Container(
//   margin: EdgeInsets.only(top: 25),
//   child: Row(
//     children: [
//       Expanded(
//         child: Text(
//           "You can also like this",
//           style: Theme.of(context).textTheme.body1.copyWith(
//               fontWeight: FontWeight.w400
//           ),
//         ),
//       ),
//       Text(
//         demo_productItem.recommendedProducts.length.toString() + " items",
//         style: Theme.of(context).textTheme.caption,
//       ),
//     ],
//   ),
// ),
// Container(
//   margin: EdgeInsets.only(top: 10),
//   height: 300,
//   child: ListView.builder(
//     itemCount: demo_productItem.recommendedProducts.length,
//     scrollDirection: Axis.horizontal,
//     semanticChildCount: 2,
//     itemBuilder: (BuildContext context, int index) {
//       return Container(
//         width: ((MediaQuery.of(context).size.width) / 2) - 10,
//         child: ProductCard(
//           product: demo_productItem.recommendedProducts[index],
//         ),
//       );
//     },
//   ),
// ),
