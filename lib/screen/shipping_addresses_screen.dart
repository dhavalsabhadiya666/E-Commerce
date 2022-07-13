import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/data/services/address_api.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/helper/preference_keys.dart';
import 'package:prabodham/model/address.dart';
import 'package:prabodham/model/customer.dart';
import 'package:prabodham/screen/add_address_screen.dart';
import 'package:prabodham/widgets/component_widgets/loader.dart';
import 'package:prabodham/widgets/component_widgets/smal_loader.dart';
import 'package:prabodham/widgets/custom_app_bar.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';

class ShippingAddressScreen extends StatefulWidget {
  @override
  _ShippingAddressScreenState createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  AddressApi _addressApi = AddressApi();

  List<Address> addressList = [];
  bool isLoading = false;
  bool addressPlaceHolder = false;
  bool isUpdated = false;

  @override
  void initState() {
    super.initState();
    getCustomerAddress();
  }

  void setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  void getCustomerAddress() {
    Functions.checkConnectivity().then((value) async {
      String userjson = await PreferenceKeys.getUserDetail();
      Customer userDetail = Customer.fromJson(jsonDecode(userjson));

      if (value != null && value == true) {
        FormData data = new FormData.fromMap({
          'customer_id': userDetail.customerId,
        });
        requestAddress(data: data, context: context);
      }
    });
  }

  Future<void> requestAddress(
      {@required FormData data, @required BuildContext context}) async {
    setLoading(true);
    try {
      ApiResponseModel apiResponse =
          await _addressApi.getAddress(data: data, context: context);
      print("Get Address Api response data :- ");
      print(apiResponse.response);

      if (apiResponse.success == true && apiResponse.response != null) {
        setLoading(false);
        isUpdated = true;
        //GET ADDRESS DATA HERE
        setState(() {
          addressList.clear();
          addressList = (apiResponse.response as List).map((address) {
            return Address.fromJson(address);
          }).toList();
          if (addressList.indexWhere(
                      (element) => element.customerAddressDefault == 1) ==
                  -1 &&
              addressList.length != 0) {
            changeDefaultAddress(addressList[0].customerAddressId);
            addressList[0].customerAddressDefault = 1;
            setState(() {
              addressList = addressList;
            });
          }
          print("Setting Address IN PREF : ");
          PreferenceKeys.setDefaultAddress(jsonEncode(addressList
              .firstWhere((element) => element.customerAddressDefault == 1)));
        });
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

  Future<void> setDefaultAddress(
      {@required FormData data, @required BuildContext context}) async {
    try {
      ApiResponseModel apiResponse =
          await _addressApi.changeDefaultAddress(data: data, context: context);
      print("Set Default Address Api response data :- ");
      print(apiResponse.response);

      if (apiResponse.success == true && apiResponse.response != null) {
        isUpdated = true;
        //Functions.toast(apiResponse.message);
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

  void changeDefaultAddress(int addressId) {
    Functions.checkConnectivity().then((value) async {
      String userjson = await PreferenceKeys.getUserDetail();
      Customer userDetail = Customer.fromJson(jsonDecode(userjson));

      if (value != null && value == true) {
        FormData data = new FormData.fromMap({
          'customer_id': userDetail.customerId,
          'customer_address_id': addressId,
        });
        setDefaultAddress(data: data, context: context);
      }
    });
  }

  void deleteAddress(Address address) {
    Functions.checkConnectivity().then((value) async {
      String userjson = await PreferenceKeys.getUserDetail();
      Customer userDetail = Customer.fromJson(jsonDecode(userjson));

      if (value != null && value == true) {
        FormData data = new FormData.fromMap({
          'customer_id': userDetail.customerId,
          'customer_address_id': address.customerAddressId,
        });
        if (address.customerAddressDefault != 1) {
          try {
            ApiResponseModel apiResponse =
                await _addressApi.deleteAddress(data: data, context: context);
            print("Delete Address Address Api response data :- ");
            print(apiResponse.response);

            if (apiResponse.success == true && apiResponse.response != null) {
              isUpdated = true;
              setState(() {
                addressList.remove(address);
              });
              //Functions.toast(apiResponse.message);
            } else {
              Functions.toast(apiResponse.message);
            }
          } catch (e) {
            print(e.toString());
            final errorMessage = DioExceptions.fromDioError(e).toString();
            showCustomDialog(context, 'Error', errorMessage);
          }
        } else {
          showCustomDialog(
              context, 'Invalid', "Default Address Cannot be deleted");
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
            title: Text("Shipping Address"),
            centerTitle: true,
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context, isUpdated);
                })),
        body: isLoading
            ? smallLoader(context: context)
            : Stack(
                children: [
                  addressList.length != 0
                      ? Container(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(height: 10),
                                Container(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: addressList.length,
                                    itemBuilder: (context, index) {
                                      return addressCard(addressList[index]);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          child: Center(child: Text("No Address Found !")),
                        ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      height: 40,
                      width: 40,
                      margin:
                          EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      child: FloatingActionButton(
                        backgroundColor: Colors.black,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddAddressScreen(),
                            ),
                          ).then((value) {
                            if (value) {
                              getCustomerAddress();
                            }
                          });
                        },
                        child: Icon(
                          Icons.add,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: isLoading
                        ? Loader(
                            bgColor: Colors.black,
                            loaderColor: Theme.of(context).primaryColor,
                          )
                        : Container(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget addressCard(Address address) {
    String addressDetail = address.customerAddressDetails +
        ", " +
        address.customerAddressCity +
        ", " +
        address.customerAddressState +
        ", " +
        address.countryName +
        " " +
        address.customerAddressZipcode;

    return GestureDetector(
      onTap: () {
        print(address.countryName);
      },
      child: Card(
        color: Theme.of(context).cardColor,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 10,
                      ),
                      child: Text(address.customerAddressName,
                          style: Theme.of(context).textTheme.body2),
                      margin: EdgeInsets.only(bottom: 10),
                    ),
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddAddressScreen(
                              address: address,
                            ),
                          ),
                        ).then((value) {
                          if (value) {
                            getCustomerAddress();
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                          right: 10,
                        ),
                        child: Text("Edit",
                            style: Theme.of(context).textTheme.body2.copyWith(
                                color: Theme.of(context).primaryColor)),
                      )),
                ],
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 60,
                ),
                child: Text(addressDetail,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .body2
                        .copyWith(fontSize: 13, fontWeight: FontWeight.w400)),
              ),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: Text("Use as the shipping address",
                          style: Theme.of(context)
                              .textTheme
                              .body2
                              .copyWith(fontWeight: FontWeight.w400)),
                      contentPadding: EdgeInsets.all(0),
                      value: address.customerAddressDefault == 1 ? true : false,
                      onChanged: (value) {
                        setState(() {
                          if (value) {
                            updateDefaultShippingAddress();
                            address.customerAddressDefault = value ? 1 : 0;
                            PreferenceKeys.setDefaultAddress(
                                jsonEncode(address));
                            changeDefaultAddress(address.customerAddressId);
                          }
                        });
                        print("Is Shipping Address : ${value}");
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          // title: Text(title),
                          content: Text(
                            "Sure Want to delete Address",
                            style: Theme.of(context)
                                .textTheme
                                .subtitle
                                .copyWith(fontSize: 18),
                          ),
                          actions: [
                            FlatButton(
                              child: Text('Cancel'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            FlatButton(
                              child: Text('Confirm'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                deleteAddress(address);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                        right: 10,
                      ),
                      child: Text("Remove",
                          style: Theme.of(context)
                              .textTheme
                              .body2
                              .copyWith(color: Theme.of(context).primaryColor)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  updateDefaultShippingAddress() {
    int oldDefaultAddressIndex = addressList
        .indexWhere((element) => element.customerAddressDefault == 1);
    setState(() {
      if (oldDefaultAddressIndex != -1) {
        addressList[oldDefaultAddressIndex].customerAddressDefault = 0;
      }
    });
  }
}
