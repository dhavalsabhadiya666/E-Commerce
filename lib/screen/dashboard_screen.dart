import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/data/services/category_api.dart';
import 'package:prabodham/data/services/dashboard_api.dart';
import 'package:prabodham/data/services/product_api.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/global/variable/custom_app_theme.dart';
import 'package:prabodham/global/variable/images.dart';
import 'package:prabodham/helper/NotificationUtils.dart';
import 'package:prabodham/helper/preference_keys.dart';
import 'package:prabodham/model/advertisement.dart';
import 'package:prabodham/model/category.dart';
import 'package:prabodham/model/customer.dart';
import 'package:prabodham/model/product.dart';
import 'package:prabodham/screen/product_catalog_screen.dart';
import 'package:prabodham/screen/product_screen.dart';
import 'package:prabodham/screen/profile_screen.dart';
import 'package:prabodham/screen/search_screen.dart';
import 'package:prabodham/widgets/component_widgets/loader.dart';
import 'package:prabodham/widgets/custom_app_bar.dart';
import 'package:prabodham/widgets/custom_image.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ProductApi _productApi = ProductApi();
  CategoryApi _categoryApi = CategoryApi();
  DashboardApi _dashboardApi = DashboardApi();
  CarouselController _carouselController = CarouselController();
  NotificationUtils _notificationUtils = NotificationUtils();

  //DEMO VARIABLES
  List<String> demo_bannerUrlList = [];
  List<List<String>> demo_categories = [];

  //REAL VARIABLES
  List<Advertisement> bannerUrlList = [];
  List<Product> bestSellerList = [];
  List<Product> newArrivalList = [];
  List<Category> categoryList = [];

  static bool _orangeColor = true;
  bool isLoading = true;
  Customer userDetail;
  int _current = 0;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    _notificationUtils.notificationPermission();

    _notificationUtils.inItNotification();
    _notificationUtils.listNotification();

    getDashboardData();
    super.initState();
  }

  void setLoading(bool value) {
    print("Loading " + value.toString());
    if (mounted)
      setState(() {
        isLoading = value;
      });
  }

  void getDashboardData() async {
    setLoading(true);
    String deviceToken = await firebaseMessaging.getToken();
    print(deviceToken);
    Functions.checkConnectivity().then((value) async {
      String userjson = await PreferenceKeys.getUserDetail();
      userDetail = Customer.fromJson(jsonDecode(userjson));

      if (value != null && value == true) {
        await getBannerData(context: context);
        await getProductData(context: context);
        await getCategories(context: context);
      }
    });
  }

  Future<void> getBannerData({@required BuildContext context}) async {
    Functions.checkConnectivity().then((value) async {
      if (value != null && value == true) {
        FormData data = new FormData.fromMap({});
        try {
          setLoading(true);
          ApiResponseModel apiResponse =
              await _dashboardApi.getBanner(context: context, data: data);
          print("Get Banner Api response data :- ");
          print(apiResponse.response);

          if (apiResponse.success == true && apiResponse.response != null) {
            var list = apiResponse.response as List;
            bannerUrlList = list.map((element) {
              return Advertisement.fromJson(element);
            }).toList();
            setLoading(false);
          } else {
            Functions.toast(apiResponse.message);
            setLoading(false);
          }
        } catch (e) {
          print(e.toString());
          if (mounted) setLoading(false);
          final errorMessage = DioExceptions.fromDioError(e).toString();
          Functions.toast(errorMessage);
        }
      }
    });
  }

  Future<void> getProductData({@required BuildContext context}) async {
    Functions.checkConnectivity().then((value) async {
      if (value != null && value == true) {
        FormData data = new FormData.fromMap({});

        try {
          setLoading(true);
          ApiResponseModel newArrivalApiResponse = await _productApi
              .getNewArrivalProducts(context: context, data: data);
          print("Get New Arrival Api response data :- ");
          print(newArrivalApiResponse.response);

          if (newArrivalApiResponse.success == true &&
              newArrivalApiResponse.response != null) {
            var list = newArrivalApiResponse.response as List;
            newArrivalList = list.map((element) {
              return Product.fromJson(element);
            }).toList();
            setLoading(false);
          } else {
            Functions.toast(newArrivalApiResponse.message);
            setLoading(false);
          }
        } catch (e) {
          setLoading(false);
          print(e.toString());
          final errorMessage = DioExceptions.fromDioError(e).toString();
          showCustomDialog(context, 'Error', errorMessage);
        }
      }
    });

    Functions.checkConnectivity().then((value) async {
      if (value != null && value == true) {
        FormData data = new FormData.fromMap({});

        try {
          setLoading(true);
          ApiResponseModel bestSellingApiResponse = await _productApi
              .getBestSellerProducts(context: context, data: data);
          print("Get Best Selling Api response data :- ");
          print(bestSellingApiResponse.response);

          if (bestSellingApiResponse.success == true &&
              bestSellingApiResponse.response != null) {
            var list = bestSellingApiResponse.response as List;
            bestSellerList = list.map((element) {
              return Product.fromJson(element);
            }).toList();
            setLoading(false);
          } else {
            Functions.toast(bestSellingApiResponse.message);
            setLoading(false);
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

  Future<void> getCategories({@required BuildContext context}) async {
    Functions.checkConnectivity().then((value) async {
      if (value != null && value == true) {
        FormData data = new FormData.fromMap({});
        try {
          ApiResponseModel apiResponse =
              await _categoryApi.getCategory(context: context, data: data);
          print("Get Categories Api response data :- ");
          print(apiResponse.response);

          if (apiResponse.success == true && apiResponse.response != null) {
            var list = apiResponse.response as List;
            categoryList = list.map((element) {
              return Category.fromJson(element);
            }).toList();
            setLoading(false);
          } else {
            Functions.toast(apiResponse.message);
            setLoading(false);
          }
        } catch (e) {
          setLoading(false);
          final errorMessage = DioExceptions.fromDioError(e).toString();
          showCustomDialog(context, 'Error', errorMessage);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.width);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          appBar: CustomAppBar(
              elevation: 2,
              title: Column(
                children: [
                  Text(
                    "PRABODHAM",
                    style: TextStyle(
                        color: Colors.green,
                        letterSpacing: 6,
                        fontSize: 16,
                        fontWeight: FontWeight.w800),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 30,
                        height: 1,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "DIVINE TOUCH",
                        style: TextStyle(
                            letterSpacing: 1.2,
                            fontSize: 9,
                            fontWeight: FontWeight.w800),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        width: 30,
                        height: 1,
                        color: Colors.black,
                      ),
                    ],
                  )
                ],
              ),
              leading: GestureDetector(
                onTap: () async {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => ProfileScreen()))
                      .then((value) async {
                    String userjson = await PreferenceKeys.getUserDetail();
                    setState(() {
                      userDetail = Customer.fromJson(jsonDecode(userjson));
                    });
                  });
                },
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6.0, vertical: 8),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey,
                          backgroundImage: (userDetail == null)
                              ? AssetImage(Images.USER_PLACEHOLDER)
                              : userDetail.customerProfileImage == null
                                  ? AssetImage(Images.USER_PLACEHOLDER)
                                  : NetworkImage(
                                      userDetail.customerProfileImage),
                        ),
                      ),
                    )),
              ),
              centerTitle: true,
              actions: [
                GestureDetector(
                  onTap: () {
                    print("Search");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SearchScreen()));
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
          backgroundColor: Color(0xffF8F8F8),
          // backgroundColor: Theme.of(context).canvasColor,
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
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  CarouselSlider(
                                    carouselController: _carouselController,
                                    options: CarouselOptions(
                                      autoPlay: true,
                                      enlargeCenterPage: false,
                                      viewportFraction: 1.0,
                                      height: 200,
                                      onPageChanged: (index, reason) {
                                        setState(() {
                                          _current = index;
                                        });
                                      },
                                    ),
                                    items: bannerUrlList
                                        .map((image_url) => CarouselItem(
                                              url: image_url.sliderImageName,
                                            ))
                                        .toList(),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: bannerUrlList.map((url) {
                                      int index = bannerUrlList.indexOf(url);
                                      return Container(
                                        width: 8.0,
                                        height: 8.0,
                                        margin: EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 2.0),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _current == index
                                              ? Color.fromRGBO(0, 0, 0, 0.9)
                                              : Color.fromRGBO(0, 0, 0, 0.4),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Container(
                                height: 150,
                                // width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.only(top: 10, bottom: 0),
                                padding: EdgeInsets.only(top: 10),
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: categoryList.length,
                                    itemBuilder: (context, int index) {
                                      return categoryCard(
                                          category: categoryList[index]);
                                    })),
                            Container(
                              margin: EdgeInsets.only(left: 10, top: 0),
                              child: Column(
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Best Selling Items",
                                      style: Theme.of(context)
                                          .textTheme
                                          .subhead
                                          .copyWith(
                                              fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.only(top: 10, bottom: 30),
                                    height: 190,
                                    // color: Colors.blue,
                                    child: ListView.builder(
                                      itemCount: bestSellerList.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Container(
                                          width: 120,
                                          child: productCard(
                                            product: bestSellerList[index],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "New Arrivals",
                                      style: Theme.of(context)
                                          .textTheme
                                          .subhead
                                          .copyWith(
                                              fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  Container(
                                    height: 190,
                                    margin:
                                        EdgeInsets.only(top: 10, bottom: 30),
                                    child: ListView.builder(
                                      itemCount: newArrivalList.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Container(
                                          width: 120,
                                          child: productCard(
                                            product: newArrivalList[index],
                                          ),
                                        );
                                      },
                                    ),
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
          )),
    );
  }

  Widget productCard({Product product}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductScreen(
              product: product,
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.only(right: 15),
        elevation: 0,
        color: CustomAppTheme.canvasColor,
        child: Stack(
          children: [
            Container(
              color: Color(0xffF8F8F8),
              child: Column(
                children: [
                  Stack(
                    children: [
                      // ClipPath(
                      //     clipper: AppClipper(
                      //         cornerSize: 9,
                      //         diagonalHeight: 65,
                      //         roundedBottom: true),
                      //     child: Container(
                      //       //color: Colors.transparent,
                      //       //color: Colors.green.shade100,
                      //       color:
                      //           Theme.of(context).primaryColor.withAlpha(1090),
                      //       child: Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           Container(
                      //             height: 100,
                      //             width: 100,
                      //           )
                      //         ],
                      //       ),
                      //     )),
                      Card(
                        elevation: 0.5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            //border: Border.all(color: Color(0xffffd085))
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: AspectRatio(
                              aspectRatio: 0.70,
                              child: CustomImage(
                                imgURL:
                                    product.productImages[0].productImageName,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    // color: Colors.grey[100],
                    margin: EdgeInsets.only(top: 8, left: 10),
                    child: Text(
                      product.productName,
                      //"dghasghda ghashgdha aghhda da",
                      style: Theme.of(context).textTheme.body2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      maxLines: 2,
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

  Widget newArrivalCard({Product product}) {
    return GestureDetector(
      onTap: () {
        print("Product: " + product.productName);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductScreen(product: product)));
      },
      child: Container(
        margin: EdgeInsets.all(5),
        child: AspectRatio(
          aspectRatio: 2.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              color: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    padding: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _orangeColor
                          ? Color.fromRGBO(255, 156, 0, 1)
                          : Colors.green,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: CustomImage(
                        height: 30,
                        width: 30,
                        imgURL: product.productImages[0].productImageName,
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      product.productName,
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget categoryCard({Category category}) {
    return GestureDetector(
      onTap: () {
        print(category.categoryName);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductCatalogScreen(
                      category: category,
                    )));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        color: Colors.transparent,
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).primaryColor, width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    height: 75,
                    width: 75,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 3),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      height: 70,
                      width: 70,
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // color: _orangeColor ? Color.fromRGBO(255, 156, 0, 1) : Colors.green,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: CustomImage(
                            imgURL: category.categoryImage,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              margin: EdgeInsets.only(top: 5),
              child: Text(
                category.categoryName,
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(fontSize: 15, color: Colors.black),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            )
          ],
        ),
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
            height: 200,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
