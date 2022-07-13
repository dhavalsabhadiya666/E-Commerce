import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/data/services/cart_api.dart';
import 'package:prabodham/data/services/product_api.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/global/variable/custom_app_theme.dart';
import 'package:prabodham/helper/preference_keys.dart';
import 'package:prabodham/model/address.dart';
import 'package:prabodham/model/cart.dart';
import 'package:prabodham/model/customer.dart';
import 'package:prabodham/model/promocode.dart';
import 'package:prabodham/provider/promocode_provider.dart';
import 'package:prabodham/screen/payment_screen.dart';
import 'package:prabodham/screen/shipping_addresses_screen.dart';
import 'package:prabodham/widgets/component_widgets/loader.dart';
import 'package:prabodham/widgets/custom_app_bar.dart';
import 'package:prabodham/widgets/custom_image.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  final bool showBackButton;
  CartScreen({@required this.showBackButton});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  CartApi _cartApi = CartApi();
  ProductApi _productApi = ProductApi();

  TextEditingController searchController = TextEditingController();
  TextEditingController promoCodeController = TextEditingController();

  bool isLoading = false;
  Cart myCart;
  List<PromoCode> promocodeList = [];
  List<CartItem> cartProductList;
  Customer userDetail;
  PromoCode _selectedPromocode;
  Address customerAddress;

  @override
  void initState() {
    super.initState();
    promocodeList =
        Provider.of<PromoCodeProvider>(context, listen: false).promocodes;
    getCartScreenData();
  }

  void setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  void getCartScreenData() {
    setLoading(true);
    Functions.checkConnectivity().then((value) async {
      String userjson = await PreferenceKeys.getUserDetail();
      userDetail = Customer.fromJson(jsonDecode(userjson));
      await getAddress();
      if (value != null && value == true) {
        FormData data = new FormData.fromMap({
          'customer_id': userDetail.customerId,
        });

        try {
          ApiResponseModel apiResponse =
              await _cartApi.getCart(context: context, data: data);
          print("Cart Data Api response data :- ");

          if (apiResponse.success == true && apiResponse.response != null) {
            myCart = Cart.fromJson(apiResponse.response);
          } else {
            Functions.toast(apiResponse.message);
          }
          setState(() {
            cartProductList = myCart.items;
          });
        } catch (e) {
          print(e.toString());
          if (mounted) {
            setLoading(false);
          }
          final errorMessage = DioExceptions.fromDioError(e).toString();
          showCustomDialog(context, 'Error', errorMessage);
        }

        setLoading(false);
      } else {
        setLoading(false);
      }
    });
  }

  Future<void> getAddress() async {
    String addressjson = await PreferenceKeys.getDefaultAddress();
    String userjson = await PreferenceKeys.getUserDetail();
    userDetail = Customer.fromJson(jsonDecode(userjson));
    setState(() {
      if (addressjson != null) {
        customerAddress = Address.fromJson(jsonDecode(addressjson));
      } else if (userDetail.address.length != 0) {
        customerAddress = userDetail.address[0];
      }
    });
  }

  Future<void> updateCart(
      {@required BuildContext context, CartItem cartItem}) async {
    Functions.checkConnectivity().then((value) async {
      if (value != null && value == true) {
        String userjson = await PreferenceKeys.getUserDetail();
        userDetail = Customer.fromJson(jsonDecode(userjson));
        FormData data = new FormData.fromMap({
          'customer_id': userDetail.customerId,
          'product_id': cartItem.productId,
          'qty': cartItem.cartItemsQty,
          'variant_id': cartItem.product.variant[0].variantId,
          'promocode_id': (_selectedPromocode != null)
              ? _selectedPromocode.promocodeId
              : null,
        });
        try {
          ApiResponseModel apiResponse =
              await _cartApi.updateCart(context: context, data: data);
          print("Update Cart Api response data :- ");

          if (apiResponse.success == true && apiResponse.response != null) {
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

  Future<void> updateFavourite(
      {@required BuildContext context, CartItem cartItem}) async {
    Functions.checkConnectivity().then((value) async {
      if (value != null && value == true) {
        String userjson = await PreferenceKeys.getUserDetail();
        userDetail = Customer.fromJson(jsonDecode(userjson));
        FormData data = new FormData.fromMap({
          'customer_id': userDetail.customerId,
          'product_id': cartItem.productId,
        });

        try {
          ApiResponseModel apiResponse = await _productApi
              .updateProductFavourite(context: context, data: data);
          print("Update Favourite Api response data :- ");

          if (apiResponse.success == true && apiResponse.response != null) {
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

  double getDiscountAmount(double cartTotal) {
    return (_selectedPromocode != null
        ? (cartTotal * (_selectedPromocode.promocodeDiscount / 100))
            .roundToDouble()
        : 0.0);
  }

  double getNetAmount(double cartTotal) {
    return (_selectedPromocode != null
        ? (cartTotal * (1 - (_selectedPromocode.promocodeDiscount / 100)))
            .roundToDouble()
        : cartTotal);
  }

  @override
  Widget build(BuildContext context) {
    double cartTotal = 0;
    if (cartProductList != null) {
      for (CartItem p in cartProductList) {
        cartTotal += p.product.variant[0].variantFinalPrice * p.cartItemsQty;
      }
    }
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        appBar: CustomAppBar(
            title: Text("My Cart"),
            centerTitle: true,
            elevation: 2,
            leading: widget.showBackButton
                ? IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back_ios))
                : Container()),
        body: Stack(
          children: [
            isLoading
                ? Container()
                : cartProductList == null
                    ? Container(
                        color: Colors.white,
                        child: Center(
                          child: Text(
                            "Cart Is Empty !",
                            style: Theme.of(context).textTheme.body1,
                          ),
                        ),
                      )
                    : cartProductList.length != 0
                        ? SingleChildScrollView(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  SizedBox(height: 16),
                                  cartProductList != null
                                      ? Container(
                                          child: ListView.separated(
                                            //padding: EdgeInsets.all(0),
                                            shrinkWrap: true,
                                            separatorBuilder: (context, index) {
                                              return Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 5),
                                              );
                                            },
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: cartProductList.length,
                                            itemBuilder: (context, index) {
                                              return itemCard(
                                                  item: cartProductList[index]);
                                            },
                                          ),
                                        )
                                      : Container(),
                                  Container(
                                    margin: EdgeInsets.only(top: 20, bottom: 5),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Shipping Address',
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 5),
                                    child: customerAddress != null
                                        ? addressCard(
                                            address: customerAddress,
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ShippingAddressScreen()))
                                                  .then((value) {
                                                if (value) {
                                                  getAddress();
                                                }
                                              });
                                            },
                                            child: Card(
                                              margin: EdgeInsets.all(0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 20,
                                                            horizontal: 20),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey,
                                                                    width: 2),
                                                                color: Colors
                                                                    .white,
                                                                shape: BoxShape
                                                                    .circle),
                                                            child: Icon(
                                                                Icons.add)),
                                                        SizedBox(
                                                          width: 12,
                                                        ),
                                                        Text(
                                                            "Add shipping address"),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 20),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Promo Code',
                                    ),
                                  ),
                                  Container(
                                    child: CustomPromoInputField(
                                      controller: promoCodeController,
                                      label: "Select promo code",
                                      enablePopUp: true,
                                    ),
                                  ),
                                  // _selectedPromocode != null
                                  //     ? GestureDetector(
                                  //         onTap: () {
                                  //           promoCodeController.clear();
                                  //           setState(() {
                                  //             _selectedPromocode = null;
                                  //           });
                                  //         },
                                  //         child: Container(
                                  //           alignment: Alignment.centerLeft,
                                  //           child: Text(
                                  //             "Remove Promocode",
                                  //             style: Theme.of(context)
                                  //                 .textTheme
                                  //                 .body2
                                  //                 .copyWith(color: Colors.red),
                                  //           ),
                                  //         ),
                                  //       )
                                  //     : Container(),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  DottedLine(
                                    direction: Axis.horizontal,
                                    lineLength: double.infinity,
                                    lineThickness: 1.0,
                                    dashLength: 12.0,
                                    dashColor: Colors.grey,
                                    dashRadius: 0.0,
                                    dashGapLength: 4.0,
                                    dashGapColor: Colors.transparent,
                                    dashGapRadius: 0.0,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 20),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Order Summary',
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 15),
                                    child: Row(
                                      children: [
                                        Container(
                                          child: Text("Order Amount",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .body2),
                                        ),
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              '\u{20B9} ${cartTotal.toStringAsFixed(2)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .body2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    child: Row(
                                      children: [
                                        Container(
                                          child: Text("Discount",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .body2),
                                        ),
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              '\u{20B9} ${getDiscountAmount(cartTotal).toStringAsFixed(2)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .body2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    child: Row(
                                      children: [
                                        Container(
                                          child: Text("Net Amount",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .body2),
                                        ),
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              '\u{20B9} ${getNetAmount(cartTotal).toStringAsFixed(2)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .body2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  DottedLine(
                                    direction: Axis.horizontal,
                                    lineLength: double.infinity,
                                    lineThickness: 1.0,
                                    dashLength: 12.0,
                                    dashColor: Colors.grey,
                                    dashRadius: 0.0,
                                    dashGapLength: 4.0,
                                    dashGapColor: Colors.transparent,
                                    dashGapRadius: 0.0,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  cartProductList == null
                                      ? Container()
                                      : Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    child: Text("Total"),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Container(
                                                    child: Text(
                                                      '\u{20B9} ${getNetAmount(cartTotal).toStringAsFixed(2)}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .body2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    print("Checking Out");
                                                    if (customerAddress ==
                                                        null) {
                                                      showOptionCustomDialog(
                                                        context,
                                                        'No address available.\n Please , Add at least one !',
                                                      );
                                                    } else {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              PaymentScreen(
                                                            cartTotalAmount:
                                                                cartTotal,
                                                            cartDiscountAmount:
                                                                getDiscountAmount(
                                                                    cartTotal),
                                                            cartNetAmount:
                                                                getNetAmount(
                                                                    cartTotal),
                                                            cartId:
                                                                myCart.cartId,
                                                            customerAddressId:
                                                                customerAddress
                                                                    .customerAddressId,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 35,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            3,
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                    child: Center(
                                                        child: Text(
                                                      "CHECK OUT",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .body2
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                    )),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.white,
                            child: Center(
                              child: Text(
                                "Cart Is Empty !",
                                style: Theme.of(context).textTheme.body1,
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
      ),
    );
  }

  Widget addressCard({Address address}) {
    return Card(
      margin: EdgeInsets.all(0),
      elevation: 5,
      child: Container(
        margin: EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Container(
                // margin: EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Text(
                        address.customerAddressName,
                        style: Theme.of(context).textTheme.body1,
                      ),
                    ),
                    Container(
                      child: Text(
                        address.customerAddressDetails +
                            " ," +
                            address.customerAddressCity +
                            " ," +
                            address.customerAddressState +
                            " " +
                            address.customerAddressZipcode,
                        style: Theme.of(context).textTheme.body2.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ShippingAddressScreen()))
                      .then((value) {
                    if (value) {
                      getAddress();
                    }
                  });
                },
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Change",
                    style: Theme.of(context).textTheme.body2.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemCard({CartItem item}) {
    return Container(
      child: Card(
        margin: EdgeInsets.all(0),
        elevation: 5,
        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        borderOnForeground: true,
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: CustomImage(
                    imgURL: item.product.productImages[0].productImageName,
                    fit: BoxFit.fill,
                    height: 130,
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: Container(
                  padding:
                      EdgeInsets.only(right: 6, left: 12, top: 10, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.product.productName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.body1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Container(
                        child: Text(
                          " ${item.product.variant[0].variantSize.toString()} ${item.product.variant[0].variantType}" ??
                              "Category",
                          style: Theme.of(context)
                              .textTheme
                              .body2
                              .copyWith(fontSize: 12, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Container(
                        child: Text(
                          '\u{20B9} ${(item.product.variant[0].variantFinalPrice).toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.body2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              // backgroundColor: Colors.green,
                              // elevation: 1.0,
                              onTap: () {
                                setState(() {
                                  if (item.cartItemsQty != 0) {
                                    item.cartItemsQty = item.cartItemsQty - 1;
                                    if (item.cartItemsQty == 0) {
                                      setState(() {
                                        cartProductList.remove(item);
                                      });
                                    }
                                  }
                                  myCart.cartTotalPrice -=
                                      item.product.productPrice;
                                  updateCart(context: context, cartItem: item);
                                });
                                //updateCart(context: context);
                              },
                              child: Container(
                                height: 22,
                                width: 22,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.grey, width: 2),
                                    color: Colors.white),
                                child: Center(
                                    child: Icon(
                                  Icons.remove,
                                  size: 16,
                                )),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                (item.cartItemsQty).toString(),
                                style: Theme.of(context).textTheme.body1,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  item.cartItemsQty = item.cartItemsQty + 1;
                                  myCart.cartTotalPrice +=
                                      item.product.productPrice;
                                  updateCart(context: context, cartItem: item);
                                });
                              },
                              child: Container(
                                  height: 22,
                                  width: 22,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.grey, width: 2),
                                      color: Colors.white),
                                  child: Center(
                                      child: Icon(
                                    Icons.add,
                                    size: 16,
                                  ))),
                            ),
                            Spacer(),
                            GestureDetector(
                                onTap: () {
                                  item.cartItemsQty = item.cartItemsQty - 1;
                                  setState(() {
                                    cartProductList.remove(item);
                                  });
                                  myCart.cartTotalPrice -=
                                      item.product.productPrice;
                                  updateCart(context: context, cartItem: item);
                                },
                                child: Icon(Icons.delete_outline))
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

  Widget promoCodeCard({PromoCode promoCodeItem}) {
    Duration duration = DateTime.parse(promoCodeItem.promocodeExpiryDate)
        .difference(DateTime.now());
    return Container(
      padding: EdgeInsets.all(0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        borderOnForeground: true,
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6),
                    bottomLeft: Radius.circular(6),
                  ),
                  child: CustomImage(
                    imgURL: promoCodeItem.promocodeImage ?? "",
                    height: 110,
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  margin: EdgeInsets.only(top: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 5),
                              child: Text(
                                promoCodeItem.promocodeTitle ?? "",
                                style: Theme.of(context).textTheme.body2,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              child: Text(
                                promoCodeItem.promocodeName ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    .copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 5),
                              child: Text(
                                duration.inDays.toString() + " days remaining",
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),
                            Container(
                              child: GestureDetector(
                                onTap: () {
                                  print("Applying Promo Code");
                                  setState(() {
                                    _selectedPromocode = promoCodeItem;
                                    promoCodeController.text =
                                        _selectedPromocode.promocodeName;
                                  });
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 30,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    //borderRadius: BorderRadius.circular(15),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  child: Text(
                                    "Apply",
                                    style: Theme.of(context)
                                        .textTheme
                                        .body2
                                        .copyWith(color: Colors.white),
                                  ),
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

  Widget CustomSearchInputField({
    TextEditingController controller,
    ValueChanged<String> validator,
    String label,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      color: Colors.white,
      elevation: 5,
      child: TextFormField(
        style: Theme.of(context).textTheme.body2,
        controller: controller,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
        enabled: true,
        validator: validator,
        onTap: () {},
        onChanged: (value) {},
        decoration: InputDecoration(
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
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget CustomPromoInputField(
      {TextEditingController controller,
      ValueChanged<String> validator,
      PromoCode promoCodeItem,
      String label,
      bool enablePopUp}) {
    return Container(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: TextFormField(
              style: Theme.of(context).textTheme.body2,
              controller: controller,
              keyboardType: TextInputType.text,
              focusNode: enablePopUp ? AlwaysDisabledFocusNode() : null,
              textInputAction: TextInputAction.next,

              // enabled: false,
              validator: validator,
              // onTap: () {
              //   print("Select");
              //   enablePopUp ? promoCodePopUp() : null;
              // },
              onChanged: (value) {},
              decoration: InputDecoration(
                hintText: "Select promo code",
                suffixIcon: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: GestureDetector(
                          onTap: () {
                            print("Select");
                            enablePopUp ? promoCodePopUp() : null;
                            setState(() {});
                          },
                          child: Text(
                            "Select",
                            style: Theme.of(context).textTheme.body2.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                          )),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _selectedPromocode != null
                        ? GestureDetector(
                            onTap: () {
                              promoCodeController.clear();
                              setState(() {
                                _selectedPromocode = null;
                              });
                            },
                            child: Container(
                                margin: EdgeInsets.only(left: 10),
                                //alignment: Alignment.centerLeft,
                                child: Icon(Icons.delete_outline)),
                          )
                        : Container(
                            width: 5,
                          ),
                  ],
                ),
                labelText: label ?? "",
                labelStyle: Theme.of(context)
                    .textTheme
                    .body1
                    .copyWith(color: CustomAppTheme.grey),
                contentPadding: EdgeInsets.only(
                  top: 15,
                  bottom: 10,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> promoCodePopUp() {
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.only(top: 20, left: 20, right: 20),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(top: 10, bottom: 20),
                child: Text(
                  "Select promo code",
                  style:
                      Theme.of(context).textTheme.body1.copyWith(fontSize: 18),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  separatorBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                    );
                  },
                  physics: BouncingScrollPhysics(),
                  itemCount: promocodeList.length,
                  itemBuilder: (context, index) {
                    return promoCodeCard(promoCodeItem: promocodeList[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showOptionCustomDialog(BuildContext ctx, String title) {
    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        content: Text(
          title,
          style: TextStyle(height: 1.5),
          textAlign: TextAlign.center,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                    color: Theme.of(context).primaryColor,
                    child: Center(
                        child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    )),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ShippingAddressScreen()))
                        .then((value) {
                      getAddress();
                      Navigator.pop(context);
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                    color: Theme.of(context).primaryColor,
                    child: Center(
                        child: Text(
                      "Add",
                      style: TextStyle(color: Colors.white),
                    )),
                  ),
                )
              ],
            ),
          )
          // FlatButton(
          //   child: Text('Not Now'),
          //   onPressed: () => Navigator.of(context).pop(),
          // ),
          // FlatButton(
          //   child: Text('Add'),
          //   onPressed: () {
          //     Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //                 builder: (context) => ShippingAddressScreen()))
          //         .then((value) {
          //       getAddress();
          //       Navigator.pop(context);
          //     });
          //   },
          // ),
        ],
      ),
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
