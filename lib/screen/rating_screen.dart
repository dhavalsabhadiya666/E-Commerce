import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart' as intl;
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/data/services/review_api.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/global/variable/custom_app_theme.dart';
import 'package:prabodham/helper/preference_keys.dart';
import 'package:prabodham/model/customer.dart';
import 'package:prabodham/model/review.dart';
import 'package:prabodham/widgets/custom_app_bar.dart';
import 'package:prabodham/widgets/custom_image.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class RatingScreen extends StatefulWidget {
  List<Review> reviewList;
  int productId;
  RatingScreen({Key key, this.reviewList, this.productId}) : super(key: key);

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  ReviewApi _reviewApi = ReviewApi();

  TextEditingController reviewController = TextEditingController();

  double postedRating = 0;
  bool isLoading = false;
  Customer userDetail;
  List<Review> productReview;

  @override
  void initState() {
    getReviews();
    super.initState();
    productReview = widget.reviewList;
  }

  void setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  Future<void> postReview(
      {@required BuildContext context, @required String text}) async {
    Functions.checkConnectivity().then((value) async {
      if (value != null && value == true) {
        String userjson = await PreferenceKeys.getUserDetail();
        userDetail = Customer.fromJson(jsonDecode(userjson));
        print("Test123");
        print(reviewController.text);
        FormData data = new FormData.fromMap({
          'customer_id': userDetail.customerId,
          'product_id': widget.productId,
          'review_details': text,
          'review_ratings': postedRating,
        });
        print(data.fields);

        setLoading(true);
        try {
          //print(data);
          ApiResponseModel apiResponse =
              await _reviewApi.postReview(context: context, data: data);
          print("Post Review Api response data :- ");
          print(apiResponse.response);

          if (apiResponse.success == true) {
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

  Future<void> getReviews() async {
    Functions.checkConnectivity().then((value) async {
      if (value != null && value == true) {
        String userjson = await PreferenceKeys.getUserDetail();
        userDetail = Customer.fromJson(jsonDecode(userjson));
        FormData data = new FormData.fromMap({
          'customer_id': userDetail.customerId,
          'product_id': widget.productId,
        });
        print(userDetail.customerId);
        print(widget.productId);

        setLoading(true);
        try {
          print(data);
          ApiResponseModel apiResponse =
              await _reviewApi.getReviewByProduct(context: context, data: data);
          var list = apiResponse.response as List;
          List<Review> updatedReviewList = list.map((element) {
            return Review.fromJson(element);
          }).toList();

          setState(() {
            productReview = updatedReviewList;
          });
          print("Get Reviews Api response data :- ");
          print(apiResponse.response);

          if (apiResponse.success == true) {
            setLoading(false);
          } else {
            setLoading(false);
            Functions.toast(apiResponse.message);
          }
        } catch (e) {
          print(e.toString());
          setLoading(false);
          final errorMessage = DioExceptions.fromDioError(e).toString();
          // showCustomDialog(context, 'Error', errorMessage);
        }
      }
    });
  }

  double getAverageRatings(List<Review> reviewList) {
    if (reviewList != null) {
      if (reviewList.length != 0) {
        double ratingTotal = 0;
        reviewList.forEach((element) {
          ratingTotal += element.reviewRatings;
        });
        return ratingTotal / reviewList.length;
      } else {
        return 0;
      }
    } else {
      return 0;
    }
  }

  int countReviews(List<Review> reviewList) {
    int count = 0;
    reviewList.forEach((element) {
      if (element.reviewDetails != null) {
        count++;
      }
    });
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: CustomAppBar(
          title: Text("Rating and Reviews"),
          centerTitle: true,
          elevation: 5,
        ),
        backgroundColor: Theme.of(context).canvasColor,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(top: 10, left: 16, right: 16),
                child: Column(
                  children: [
                    // Container(
                    //   child: Row(
                    //     children: [
                    //       Expanded(
                    //         flex: 1,
                    //         child: Column(
                    //           children: [
                    //             Container(
                    //               child: Text(
                    //                 getAverageRatings(widget.reviewList).toStringAsFixed(2),
                    //                 style: Theme.of(context).textTheme.display3.copyWith(
                    //                       fontWeight: FontWeight.w500,
                    //                     ),
                    //               ),
                    //             ),
                    //             Container(
                    //               child: Text(
                    //                 widget.reviewList.length.toString() + " ratings",
                    //                 style: Theme.of(context)
                    //                     .textTheme
                    //                     .body2
                    //                     .copyWith(fontWeight: FontWeight.w400, color: Colors.grey),
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //       Expanded(
                    //         flex: 1,
                    //         child: ListView.builder(
                    //           shrinkWrap: true,
                    //           itemCount: 5,
                    //           physics: NeverScrollableScrollPhysics(),
                    //           itemBuilder: (context, index) {
                    //             return Directionality(
                    //               textDirection: TextDirection.rtl,
                    //               child: SmoothStarRating(
                    //                 allowHalfRating: true,
                    //                 starCount: 5,
                    //                 color: Color.fromRGBO(255, 186, 73, 1.0),
                    //                 borderColor: Colors.transparent,
                    //                 size: 13,
                    //                 spacing: 1.0,
                    //                 isReadOnly: true,
                    //                 rating: double.parse((5 - index).toString()),
                    //               ),
                    //             );
                    //           },
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    Container(
                      margin: EdgeInsets.only(
                        top: 10,
                        bottom: 20,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Text(
                              countReviews(productReview).toString() +
                                  " Reviews",
                              style: Theme.of(context).textTheme.subtitle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 40),
                      child: ListView.separated(
                        itemCount: productReview.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, index) => SizedBox(
                          height: 5,
                        ),
                        itemBuilder: (context, index) {
                          return reviewCard(review: productReview[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () {
                  print("Add Review");
                  ratingPopUp(context);
                },
                child: Container(
                  height: 50,
                  width: 170,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  margin: EdgeInsets.only(bottom: 10, right: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        child: Text(
                          "Write Review",
                          style: Theme.of(context).textTheme.body2.copyWith(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget reviewCard({Review review}) {
    return Stack(
      children: [
        Container(
          child: Card(
            elevation: 2,
            child: Container(
              constraints: BoxConstraints.loose(Size.fromHeight(350)),
              padding: EdgeInsets.only(
                left: 15,
                top: 15,
                right: 10,
                bottom: 15,
              ),
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
                      Container(
                        child: Text(
                          review.customerName,
                          style: Theme.of(context).textTheme.body1,
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
                            intl.DateFormat("dd MMM , yyyy")
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
                  // _showPhotos
                  //     ? (review.reviewImages.length == 0
                  //         ? Container()
                  //         : Container(
                  //             margin: EdgeInsets.only(top: 10),
                  //             height: 110,
                  //             child: ListView.separated(
                  //               itemCount: review.reviewImages.length,
                  //               scrollDirection: Axis.horizontal,
                  //               separatorBuilder: (context, index) => SizedBox(
                  //                 width: 20,
                  //               ),
                  //               itemBuilder: (BuildContext context, int index) {
                  //                 return ClipRRect(
                  //                   borderRadius: BorderRadius.circular(16.0),
                  //                   child: AspectRatio(
                  //                     aspectRatio: 1.0,
                  //                     child: CustomImage(
                  //                       imgURL: review.reviewImages[index].reviewImage,
                  //                     ),
                  //                   ),
                  //                 );
                  //               },
                  //             ),
                  //           ))
                  //     : Container(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<dynamic> ratingPopUp(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            child: Wrap(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 15),
                        child: Text(
                          "Rate this product",
                          style: Theme.of(context).textTheme.body1,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: SmoothStarRating(
                          allowHalfRating: false,
                          onRated: (value) {
                            print("Ratings: " + value.toString() + "/5");
                            setState(() {
                              postedRating = value;
                            });
                          },
                          starCount: 5,
                          color: Color.fromRGBO(255, 186, 73, 1.0),
                          borderColor: Colors.grey,
                          size: 35,
                          spacing: 15.0,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 40),
                        child: Text(
                          "Please share your opinion about the product",
                          style: Theme.of(context).textTheme.body1,
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                        margin: EdgeInsets.only(top: 20),
                        color: Colors.white,
                        child: Container(
                          child: TextFormField(
                            autofocus: true,
                            style: Theme.of(context).textTheme.body2,
                            controller: reviewController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            maxLines: 2,
                            enabled: true,
                            onTap: () {},
                            onChanged: (value) {},
                            decoration: InputDecoration(
                              hintText: "Your review",
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .body1
                                  .copyWith(color: CustomAppTheme.grey),
                              contentPadding: EdgeInsets.all(15),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      // Container(
                      //   margin: EdgeInsets.only(top: 40),
                      //   height: ((MediaQuery.of(context).size.width) / 3) - 20,
                      //   child: ListView.separated(
                      //     itemCount: myReviewImages.length + 1,
                      //     scrollDirection: Axis.horizontal,
                      //     separatorBuilder: (context, index) => SizedBox(
                      //       width: 10,
                      //     ),
                      //     itemBuilder: (BuildContext context, int index) {
                      //       return (index == myReviewImages.length)
                      //           ? Container(
                      //               child: ImagePlaceHolder(),
                      //             )
                      //           : Container(
                      //               width: ((MediaQuery.of(context).size.width) / 3) - 20,
                      //               child: ClipRRect(
                      //                 borderRadius: BorderRadius.circular(16.0),
                      //                 child: AspectRatio(
                      //                   aspectRatio: 1.0,
                      //                   child: Image.file(
                      //                     File(myReviewImages[index].path),
                      //                     fit: BoxFit.cover,
                      //                   ),
                      //                 ),
                      //               ),
                      //             );
                      //     },
                      //   ),
                      // ),
                      Container(
                        padding: EdgeInsets.only(
                            top: 0, bottom: 10, left: 0, right: 0),
                        margin: EdgeInsets.only(top: 30),
                        child: GestureDetector(
                          onTap: () {
                            if (postedRating == 0) {
                              Functions.toast("Please rate this product!");
                            } else if (reviewController.text == "") {
                              Functions.toast(
                                  "Please write review of this product!");
                            } else {
                              print(reviewController.text);
                              print("Submit review");
                              postReview(
                                      context: context,
                                      text: reviewController.text)
                                  .whenComplete(() => getReviews());
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(25)),
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                                child: Text(
                              "SUBMIT REVIEW",
                              style: Theme.of(context).textTheme.button,
                            )),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      reviewController.clear();
    });
  }
}
