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

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();

  ProductApi _productApi = ProductApi();
  List<Product> poductList = [];
  bool isLoading = false;
  Customer userDetail;

  @override
  void initState() {
    super.initState();
    print("Search Screen");
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
          'product_name': searchController.text,
        });
        setLoading(true);
        try {
          ApiResponseModel apiResponse = await _productApi.getProductBySearch(
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
            title: Text("Search Product"),
            centerTitle: true,
            elevation: 5,
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ),
          backgroundColor: Theme.of(context).canvasColor,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Container(
                    child: Column(
                      children: [
                        Container(
                          child: CustomSearchInputField(
                            controller: searchController,
                          ),
                        ),
                        GridView.builder(
                          padding:
                              EdgeInsets.only(top: 20, left: 16, right: 16),
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 20.0,
                            mainAxisExtent: 270,
                          ),
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: poductList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return productCard(poductList[index]);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                child: isLoading
                    ? Loader(
                        bgColor: Colors.transparent,
                        loaderColor: Theme.of(context).primaryColor,
                      )
                    : Container(),
              ),
            ],
          )),
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
        margin: EdgeInsets.only(right: 0),
        elevation: 0,
        color: Colors.transparent,
        child: Stack(
          children: [
            Container(
              child: Column(
                children: [
                  Container(
                    child: Stack(
                      children: [
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16.0),
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: CustomImage(
                                    imgURL: product
                                        .productImages[0].productImageName,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 8, left: 10),
                                child: Row(
                                  children: [
                                    SmoothStarRating(
                                      allowHalfRating: true,
                                      starCount: 5,
                                      color: Colors.yellow,
                                      borderColor: Colors.black,
                                      size: 13,
                                      spacing: 1.0,
                                      isReadOnly: true,
                                      rating: product.review.length != 0
                                          ? total_rating / product.review.length
                                          : 0,
                                    ),
                                    Container(
                                      child: Text(
                                        //Need to fetch rating
                                        "(${product.review.length})",
                                        style: Theme.of(context)
                                            .textTheme
                                            .overline
                                            .copyWith(
                                              color: Colors.grey,
                                            ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 0,
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
                                  product.favourite = !product.favourite;
                                  updateFavourite(
                                      context: context, product: product);
                                });
                              },
                              child: product.favourite
                                  ? Icon(
                                      Icons.favorite,
                                      size: 20,
                                      color: Theme.of(context).primaryColor,
                                    )
                                  : Icon(
                                      Icons.favorite_border,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                            ),
                          ),
                        ),
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
                          margin: EdgeInsets.only(top: 0),
                          child: Text(
                            product.productName,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ),
                        Container(
                          child: Text(
                            product.categoryName ?? "",
                            maxLines: 1,
                            style: Theme.of(context).textTheme.body1,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 0),
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 5),
                                child: Text(
                                  '\u{20B9}${(product.variant != null && product.variant.length > 0) ? product.variant[0].variantPrice : 0}',
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
                                  '\u{20B9}${(product.variant != null && product.variant.length > 0) ? product.variant[0].variantFinalPrice : 0}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .body2
                                      .copyWith(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.red,
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

  Widget CustomSearchInputField({
    TextEditingController controller,
    ValueChanged<String> validator,
    String label,
  }) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: TextFormField(
          style: Theme.of(context).textTheme.body2,
          controller: controller,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          enabled: true,
          validator: validator,
          onTap: () {},
          onChanged: (value) {
            poductList.clear();
            getProducts(context: context);
          },
          decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              suffixIcon: Icon(
                Icons.search,
                color: Colors.black,
              ),
              hintText: label ?? "",
              labelStyle: Theme.of(context)
                  .textTheme
                  .body1
                  .copyWith(color: CustomAppTheme.grey),
              contentPadding: EdgeInsets.all(15),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  borderSide: BorderSide.none))),
    );
  }
}
