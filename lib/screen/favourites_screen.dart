import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/data/services/product_api.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/global/variable/custom_app_theme.dart';
import 'package:prabodham/helper/preference_keys.dart';
import 'package:prabodham/model/customer.dart';
import 'package:prabodham/model/product.dart';
import 'package:prabodham/model/review.dart';
import 'package:prabodham/screen/product_screen.dart';
import 'package:prabodham/widgets/component_widgets/loader.dart';
import 'package:prabodham/widgets/custom_app_bar.dart';
import 'package:prabodham/widgets/custom_image.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({Key key}) : super(key: key);

  @override
  _FavouriteScreenState createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  ProductApi _productApi = ProductApi();
  List<Product> productList = [];
  bool isLoading = true;
  Customer userDetail;

  @override
  void initState() {
    super.initState();
    getProducts(context: context);
  }

  void setLoading(bool value) {
    if (mounted)
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
        });
        setLoading(true);
        try {
          ApiResponseModel apiResponse = await _productApi.getFavouriteProducts(
              context: context, data: data);
          print("Get favourite Products Api response data :- ");

          if (apiResponse.success == true) {
            var list = apiResponse.response as List;
            productList = [];
            productList = list.map((element) {
              return Product.fromJson(element['product']);
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
        }
      }
    });
  }

  Future<void> updateFavourite(
      {@required BuildContext context, Product product}) async {
    Functions.checkConnectivity().then((value) async {
      setLoading(true);
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

          if (apiResponse.success == true) {
            getProducts(context: context);

            // Functions.toast(apiResponse.message);
          } else {
            setLoading(false);
            Functions.toast(apiResponse.message);
          }
        } catch (e) {
          setLoading(false);
          print(e.toString());
          final errorMessage = DioExceptions.fromDioError(e).toString();
          showCustomDialog(context, 'Error', errorMessage);
          setLoading(false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          appBar: CustomAppBar(
              title: Text("My Favourites"),
              centerTitle: true,
              elevation: 5,
              leading: Container()),
          backgroundColor: Theme.of(context).canvasColor,
          body: Stack(
            children: [
              isLoading
                  ? Container()
                  : (productList.length == 0
                      ? Center(child: noFavouriteHolder())
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.all(20),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 10.0,
                                          mainAxisExtent: 280,
                                          mainAxisSpacing: 10),
                                  itemCount: productList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return productCard(productList[index]);
                                  },
                                ),
                              ),
                            ],
                          ),
                        )),
              Container(
                child: isLoading
                    ? Loader(
                        bgColor: CustomAppTheme.white,
                        loaderColor: Theme.of(context).primaryColor,
                      )
                    : Container(),
              ),
            ],
          )),
    );
  }

  Widget noFavouriteHolder() {
    return Container(
      margin: EdgeInsets.only(
        top: 40,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("No Record Found !"),
        ],
      ),
    );
  }

  Widget productCard(Product product) {
    double total_rating = 0;
    for (Review r in product.review) {
      total_rating += r.reviewRatings;
    }
    return GestureDetector(
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
        elevation: 0,
        color: Colors.transparent,
        child: Stack(
          children: [
            Container(
              child: Column(
                children: [
                  Container(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16.0),
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: CustomImage(
                                    imgURL: product.productImages[0]
                                            .productImageName ??
                                        "",
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    updateFavourite(
                                        context: context, product: product);
                                  },
                                  child: Container(
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: FloatingActionButton(
                                        backgroundColor: Colors.white,
                                        elevation: 1.0,
                                        onPressed: () {
                                          updateFavourite(
                                              context: context,
                                              product: product);
                                        },
                                        child: Icon(
                                          Icons.favorite,
                                          size: 20,
                                          color: Theme.of(context).primaryColor,
                                        )),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 8, left: 10),
                            child: FittedBox(
                              child: Row(
                                children: [
                                  SmoothStarRating(
                                    allowHalfRating: true,
                                    starCount: 5,
                                    color: Theme.of(context).primaryColor,
                                    borderColor: Colors.black,
                                    size: 20,
                                    spacing: 1.0,
                                    isReadOnly: true,
                                    //Need to fetch rating
                                    rating:
                                        total_rating / product.review.length,
                                  ),
                                  Container(
                                    child: Text(
                                        //Need to fetch rating
                                        "(${product.review.length ?? ""})",
                                        style:
                                            Theme.of(context).textTheme.body2),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 0, left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 7),
                          child: Text(
                            product.productName ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 5),
                                child: Text(
                                  '\u{20B9} ${product.variant[0].variantPrice.toStringAsFixed(2) ?? ""}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                                  '\u{20B9} ${product.variant[0].variantFinalPrice.toStringAsFixed(2) ?? ""}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .body2
                                      .copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
