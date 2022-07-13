import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/data/services/order_api.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/global/variable/custom_app_theme.dart';
import 'package:prabodham/helper/preference_keys.dart';
import 'package:prabodham/model/customer.dart';
import 'package:prabodham/model/order.dart';
import 'package:prabodham/screen/order_detail_screen.dart';
import 'package:prabodham/widgets/component_widgets/loader.dart';
import 'package:prabodham/widgets/component_widgets/smal_loader.dart';
import 'package:prabodham/widgets/custom_app_bar.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key key}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  OrderApi _orderApi = OrderApi();

  List<Order> orderList;
  List<Order> selectedOrderList = [];
  int selectedListIndex = 0;
  bool isLoading = false;
  Customer userDetail;

  @override
  void initState() {
    super.initState();
    getOrders(context: context);
  }

  void setLoading(bool value) {
    print("Loading " + value.toString());
    setState(() {
      isLoading = value;
    });
  }

  Future<void> getOrders({@required BuildContext context}) async {
    setLoading(true);
    Functions.checkConnectivity().then((value) async {
      if (value != null && value == true) {
        String userjson = await PreferenceKeys.getUserDetail();
        userDetail = Customer.fromJson(jsonDecode(userjson));
        FormData data = new FormData.fromMap({
          'customer_id': userDetail.customerId,
        });
        try {
          ApiResponseModel apiResponse =
              await _orderApi.getAllOrders(context: context, data: data);
          print("Get Orders Api response data :- ");
          print(apiResponse.response);

          if (apiResponse.success == true && apiResponse.response != null) {
            var list = apiResponse.response as List;
            orderList = list.map((element) {
              return Order.fromJson(element);
            }).toList();
            getOrderList(selectedListIndex);
            setLoading(false);
          } else {
            Functions.toast(apiResponse.message);
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        appBar: CustomAppBar(
          title: Text("My Orders"),
          elevation: 2,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              }),
          // actions: [IconButton(icon: Icon(Icons.search), onPressed: () {})],
        ),
        body: isLoading
            ? smallLoader(context: context)
            : Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 30,
                          child: DefaultTabController(
                            length: 3,
                            initialIndex: selectedListIndex,
                            child: TabBar(
                              onTap: (index) {
                                print("Index : " + index.toString());
                                setState(() {
                                  selectedListIndex = index;
                                  getOrderList(selectedListIndex);
                                });
                              },
                              tabs: [
                                Tab(
                                  child: Text(
                                    "Delivered",
                                  ),
                                ),
                                Tab(
                                  child: Text("Processing"),
                                ),
                                Tab(
                                  child: Text("Cancelled"),
                                ),
                              ],
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.black,
                              unselectedLabelStyle: Theme.of(context)
                                  .textTheme
                                  .body1
                                  .copyWith(fontWeight: FontWeight.bold),
                              labelStyle: Theme.of(context)
                                  .textTheme
                                  .body1
                                  .copyWith(fontWeight: FontWeight.bold),
                              indicator: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(16),
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        orderList != null
                            ? Expanded(
                                child: ListView.builder(
                                  padding: EdgeInsets.all(0),
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: selectedOrderList.length,
                                  itemBuilder: (context, index) {
                                    return orderCard(
                                        order: selectedOrderList[index]);
                                  },
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: selectedOrderList.length == 0
                        ? noOrderHolder()
                        : Container(),
                  ),
                  Container(
                    child: isLoading
                        ? Loader(
                            bgColor: CustomAppTheme.white,
                            loaderColor: CustomAppTheme.black,
                          )
                        : Container(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget orderCard({Order order}) {
    return GestureDetector(
      onTap: () {
        print(order.orderId);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 5,
        ),
        child: Card(
          elevation: 5,
          color: Theme.of(context).cardColor,
          child: Container(
            padding: EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Order Id - " + order.orderId.toString(),
                          style: Theme.of(context).textTheme.body1.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      Container(
                        child: Text(
                          DateFormat("dd MMM, yyyy")
                              .format(DateTime.parse(order.orderCreatedAt))
                              .toString(),
                          style: Theme.of(context).textTheme.body2.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Container(
                //   margin: EdgeInsets.only(bottom: 15),
                //   child: Row(
                //     children: [
                //       Text(
                //         "Tracking Number: ",
                //         style: Theme.of(context).textTheme.body2.copyWith(
                //               fontWeight: FontWeight.w400,
                //               color: Colors.grey,
                //             ),
                //       ),
                //       Text(
                //         order.orderTrack.toString(),
                //         style: Theme.of(context).textTheme.body2.copyWith(
                //               fontWeight: FontWeight.w400,
                //             ),
                //       ),
                //     ],
                //   ),
                // ),
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: Row(
                    children: [
                      Text(
                        "Quantity: ",
                        style: Theme.of(context).textTheme.body2.copyWith(
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                            ),
                      ),
                      Text(
                        order.orderTotalQty.toString(),
                        style: Theme.of(context).textTheme.body1.copyWith(),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          print("Requesting Order Detail");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailScreen(
                                order: order,
                              ),
                            ),
                          ).then((value) {
                            if (value != null) {
                              getOrders(context: context);
                            }
                          });
                        },
                        child: Container(
                          height: 26,
                          padding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                          ),
                          child: Text("Details",
                              style: Theme.of(context).textTheme.body2.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: getStatus(order.orderStatusId),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget noOrderHolder() {
    return Container(
      margin: EdgeInsets.only(
        top: 40,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image.asset(
          //   Images.NO_ORDERS,
          //   width: MediaQuery.of(context).size.width / 1.6,
          // ),
          Text("No Orders Found !"),
        ],
      ),
    );
  }

  Widget getStatus(int status) {
    switch (status) {
      case 1:
        {
          return Text(
            "Order Placed",
            style: Theme.of(context).textTheme.body2.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          );
        }
        break;
      case 2:
        {
          return Text(
            "Order Accepted",
            style: Theme.of(context).textTheme.body2.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          );
        }
        break;
      case 3:
        {
          return Text(
            "Order dispatched",
            style: Theme.of(context).textTheme.body2.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          );
        }
        break;
      case 4:
        {
          return Text(
            "Order on the way",
            style: Theme.of(context).textTheme.body2.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          );
        }
        break;
      case 5:
        {
          return Text(
            "Cancelled",
            style: Theme.of(context).textTheme.body2.copyWith(
                  color: Colors.red,
                ),
          );
        }
        break;
      case 6:
        {
          return Text(
            "Delivered",
            style: Theme.of(context).textTheme.body2.copyWith(
                  color: Colors.green,
                ),
          );
        }
        break;
      default:
        {
          return Text(
            "Processing",
            style: Theme.of(context).textTheme.body2.copyWith(
                  color: Colors.black,
                ),
          );
        }
    }
  }

  void getOrderList(int status) {
    setState(() {
      selectedOrderList.clear();
      if (orderList != null) {
        orderList.forEach((order) {
          int orderStatusKey;
          if (order.orderStatusId == 1 ||
              order.orderStatusId == 2 ||
              order.orderStatusId == 3 ||
              order.orderStatusId == 4) {
            orderStatusKey = 1;
          } else if (order.orderStatusId == 5) {
            orderStatusKey = 2;
          } else if (order.orderStatusId == 6) {
            orderStatusKey = 0;
          }
          if (orderStatusKey == status) {
            selectedOrderList.add(order);
            print("Order Status : " + order.orderStatusId.toString());
          }
        });
      }
    });
  }
}
