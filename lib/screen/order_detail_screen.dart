import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/data/services/order_api.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/global/variable/custom_app_theme.dart';
import 'package:prabodham/model/address.dart';
import 'package:prabodham/model/order.dart';
import 'package:prabodham/widgets/component_widgets/loader.dart';
import 'package:prabodham/widgets/custom_app_bar.dart';
import 'package:prabodham/widgets/custom_image.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';

class OrderDetailScreen extends StatefulWidget {
  Order order;
  OrderDetailScreen({Key key, this.order}) : super(key: key);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  OrderApi _orderApi = OrderApi();

  bool isLoading = false;
  Order myOrder;

  @override
  void initState() {
    super.initState();
    getOrderData();
  }

  void setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  void getOrderData() {
    setLoading(true);
    Functions.checkConnectivity().then((value) async {
      if (value != null && value == true) {
        FormData data = new FormData.fromMap({
          'order_id': widget.order.orderId,
        });

        try {
          ApiResponseModel apiResponse =
              await _orderApi.getOrderById(context: context, data: data);
          print("Order Detail Api response data :- ");
          print(apiResponse.response);

          if (apiResponse.success == true && apiResponse.response != null) {
            myOrder = Order.fromJson(apiResponse.response);
          } else {
            Functions.toast(apiResponse.message);
          }
        } catch (e) {
          print(e.toString());
          setLoading(false);
          final errorMessage = DioExceptions.fromDioError(e).toString();
          showCustomDialog(context, 'Error', errorMessage);
        }

        setLoading(false);
      } else {
        setLoading(false);
      }
    });
  }

  void cancelOrder() {
    setLoading(true);
    Functions.checkConnectivity().then((value) async {
      if (value != null && value == true) {
        FormData data = new FormData.fromMap({
          'order_id': widget.order.orderId,
        });
        try {
          ApiResponseModel apiResponse =
              await _orderApi.cancelOrderById(context: context, data: data);
          print("Order Cancel Api response data :- ");
          print(apiResponse.response);

          if (apiResponse.success == true && apiResponse.response != null) {
            Navigator.pop(context, true);
          } else {
            Functions.toast(apiResponse.message);
          }
        } catch (e) {
          print(e.toString());
          setLoading(false);
          final errorMessage = DioExceptions.fromDioError(e).toString();
          showCustomDialog(context, 'Error', errorMessage);
        }
        setLoading(false);
      } else {
        setLoading(false);
      }
    });
  }

  String getAddress(Address address) {
    String address = myOrder.address[0].customerAddressDetails +
        ", " +
        myOrder.address[0].customerAddressCity +
        ", " +
        myOrder.address[0].customerAddressState +
        ", " +
        myOrder.address[0].countryName +
        " " +
        myOrder.address[0].customerAddressZipcode;
    return address;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: CustomAppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back_ios)),
          title: Text("Order Details"),
          centerTitle: true,
          elevation: 2,
        ),
        backgroundColor: Theme.of(context).canvasColor,
        body: Container(
          child: isLoading
              ? Loader(
                  bgColor: CustomAppTheme.white,
                  loaderColor: Theme.of(context).primaryColor,
                )
              : SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 15),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Order Id - " +
                                          myOrder.orderId.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        myOrder.orderTotalQty.toString() +
                                            " items",
                                        style: Theme.of(context)
                                            .textTheme
                                            .body2
                                            .copyWith(
                                              fontWeight: FontWeight.w400,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: getStatus(myOrder.orderStatusId),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      child: Text(
                                        DateFormat("dd MMM, yyyy HH:mm a")
                                            .format(DateTime.parse(
                                                myOrder.orderCreatedAt))
                                            .toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .body2
                                            .copyWith(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w400,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),

                        Container(
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: myOrder.orderItems.length,
                            itemBuilder: (context, index) {
                              return itemCard(
                                  orderItem: myOrder.orderItems[index]);
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Order Information",
                            style: Theme.of(context)
                                .textTheme
                                .body2
                                .copyWith(fontSize: 18),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Shipping Address :",
                                        style: Theme.of(context)
                                            .textTheme
                                            .body2
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        getAddress(
                                            myOrder.address[0] ?? "None"),
                                        style: Theme.of(context)
                                            .textTheme
                                            .body2
                                            .copyWith(
                                              fontWeight: FontWeight.w400,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 15),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Payment Method :",
                                        style: Theme.of(context)
                                            .textTheme
                                            .body2
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        myOrder.orderPaymentMethod ?? "N/A",
                                        style: Theme.of(context)
                                            .textTheme
                                            .body2
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 15),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Discount :",
                                        style: Theme.of(context)
                                            .textTheme
                                            .body2
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        '\u{20B9} ${myOrder.orderDiscount.toStringAsFixed(2)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .body2
                                            .copyWith(
                                              fontWeight: FontWeight.w400,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 15),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Total Amount :",
                                        style: Theme.of(context)
                                            .textTheme
                                            .body2
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        '\u{20B9} ${myOrder.orderFinalPrice.toStringAsFixed(2) ?? ""}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .body2
                                            .copyWith(
                                              fontWeight: FontWeight.w400,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        myOrder.orderStatusId == 5 || myOrder.orderStatusId == 6
                            ? Container()
                            : GestureDetector(
                                onTap: () {
                                  print("Cancel Order");
                                  cancelOrder();
                                },
                                child: Container(
                                  height: 40,
                                  margin: EdgeInsets.only(left: 0, top: 20),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    //borderRadius: BorderRadius.circular(25),
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                  child: Center(
                                    child: Text(
                                      "Cancel",
                                      style: Theme.of(context).textTheme.button,
                                    ),
                                  ),
                                ),
                              ),
                        // Container(
                        //   margin: EdgeInsets.only(top: 20),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                        //     children: [
                        //       Expanded(
                        //         flex: 1,
                        //         child: GestureDetector(
                        //           onTap: () {
                        //             print("Requesting Order Detail");
                        //           },
                        //           child: Container(
                        //             height: 40,
                        //             padding: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                        //             margin: EdgeInsets.only(right: 10),
                        //             alignment: Alignment.center,
                        //             decoration: BoxDecoration(
                        //                 borderRadius: BorderRadius.circular(25),
                        //                 border: Border.all(color: Colors.black)),
                        //             child:
                        //                 Text("Reorder", style: Theme.of(context).textTheme.body2),
                        //           ),
                        //         ),
                        //       ),
                        //       Expanded(
                        //         flex: 1,
                        //         child: GestureDetector(
                        //           onTap: () {
                        //             print("Cancel Order");
                        //           },
                        //           child: Container(
                        //             height: 40,
                        //             margin: EdgeInsets.only(left: 10),
                        //             decoration: BoxDecoration(
                        //               color: Colors.red,
                        //               borderRadius: BorderRadius.circular(25),
                        //             ),
                        //             width: MediaQuery.of(context).size.width,
                        //             child: Center(
                        //               child: Text(
                        //                 "Cancel",
                        //                 style: Theme.of(context).textTheme.button,
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget getStatus(int status) {
    switch (status) {
      case 1:
        {
          return Text(
            "Order Placed",
            style: Theme.of(context).textTheme.body1.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          );
        }
        break;
      case 2:
        {
          return Text(
            "Accepted",
            style: Theme.of(context).textTheme.body1.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          );
        }
        break;
      case 3:
        {
          return Text(
            "Dispatched",
            style: Theme.of(context).textTheme.body1.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          );
        }
        break;
      case 4:
        {
          return Text(
            "On the way",
            style: Theme.of(context).textTheme.body1.copyWith(
                  color: Colors.lightGreen,
                ),
          );
        }
        break;
      case 5:
        {
          return Text(
            "Cancelled",
            style: Theme.of(context).textTheme.body1.copyWith(
                  color: Colors.red,
                ),
          );
        }
        break;
      case 6:
        {
          return Text(
            "Delivered",
            style: Theme.of(context).textTheme.body1.copyWith(
                  color: Colors.green,
                ),
          );
        }
        break;
      default:
        {
          return Text(
            "Processing",
            style: Theme.of(context).textTheme.body1.copyWith(
                  color: Colors.black,
                ),
          );
        }
    }
  }

  Widget itemCard({OrderItems orderItem}) {
    print("Product : " + orderItem.product.productName);
    return Container(
      padding: EdgeInsets.all(0),
      margin: EdgeInsets.only(bottom: 20),
      child: Card(
        elevation: 2,
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        borderOnForeground: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: CustomImage(
                  imgURL: orderItem.product.productImages[0].productImageName,
                  height: 130,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orderItem.product.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.body1,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: Text(
                        "${orderItem.orderItemSize} ${orderItem.orderItemType} ",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.body2.copyWith(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 40),
                      child: Row(
                        children: [
                          Text(
                            "Quantity: ",
                            style: Theme.of(context).textTheme.body2.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                          Text(
                            orderItem.orderItemsQty.toString(),
                            style: Theme.of(context).textTheme.body2.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '\u{20B9} ${orderItem.orderItemsPrice.toStringAsFixed(2) ?? ""}',
                                style: Theme.of(context)
                                    .textTheme
                                    .body1
                                    .copyWith(
                                        color: Theme.of(context).primaryColor),
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
    );
  }
}
