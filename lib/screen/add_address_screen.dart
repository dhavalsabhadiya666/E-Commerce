import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/data/services/address_api.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/global/variable/custom_app_theme.dart';
import 'package:prabodham/helper/preference_keys.dart';
import 'package:prabodham/model/address.dart';
import 'package:prabodham/model/country.dart';
import 'package:prabodham/model/customer.dart';
import 'package:prabodham/provider/country_provider.dart';
import 'package:prabodham/widgets/component_widgets/loader.dart';
import 'package:prabodham/widgets/custom_app_bar.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';
import 'package:provider/provider.dart';

class AddAddressScreen extends StatefulWidget {
  Address address;
  AddAddressScreen({Key key, this.address}) : super(key: key);
  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  AddressApi _addressApi = AddressApi();

  final _addressForm = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  TextEditingController countryController = TextEditingController();

  List<Country> countries = [];

  Country _chosenCountry;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    countries = Provider.of<CountryProvider>(context, listen: false).countries;
    if (widget.address != null) {
      setState(() {
        nameController.text = widget.address.customerAddressName;
        addressController.text = widget.address.customerAddressDetails;
        cityController.text = widget.address.customerAddressCity;
        stateController.text = widget.address.customerAddressState;
        zipCodeController.text = widget.address.customerAddressZipcode;
        // _chosenCountry = countries.firstWhere(
        //     (element) => element.countriesId == widget.address.countriesId);
      });
    }
  }

  void setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    _chosenCountry =
        countries.firstWhere((element) => element.countriesId == 103);
    countryController.text = _chosenCountry.countryName;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        appBar: CustomAppBar(
            title: Text("Add Shipping Address"),
            centerTitle: true,
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back_ios))),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                child: Column(
                  children: [
                    Container(
                      child: Form(
                        key: _addressForm,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: CustomInputField(
                                controller: nameController,
                                validator: nameValidator,
                                label: "Name",
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: CustomInputField(
                                controller: addressController,
                                validator: addressValidator,
                                label: "Address",
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: CustomInputField(
                                controller: cityController,
                                validator: cityValidator,
                                label: "City",
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: CustomInputField(
                                controller: stateController,
                                validator: stateValidator,
                                label: "State/Province/Region",
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: CustomInputField(
                                controller: zipCodeController,
                                validator: zipCodeValidator,
                                label: "Zip Code(Postal Code)",
                                inputType: TextInputType.number,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: CustomInputField(
                                enabled: false,
                                controller: countryController,
                                //validator: zipCodeValidator,
                                label: "Country",
                                inputType: TextInputType.number,
                              ),
                            ),
                            // Container(
                            //   padding: EdgeInsets.symmetric(
                            //       vertical: 0, horizontal: 0),
                            //   margin: EdgeInsets.symmetric(
                            //       vertical: 10, horizontal: 0),
                            //   color: Colors.white.withOpacity(0.8),
                            //   child: DropdownButtonFormField<Country>(
                            //     value: _chosenCountry,
                            //     items: countries
                            //         .map<DropdownMenuItem<Country>>((value) {
                            //       return DropdownMenuItem(
                            //         value: value,
                            //         child: Container(
                            //           child: Text(
                            //             value.countryName,
                            //             style: TextStyle(
                            //               fontSize: 13,
                            //               color: Colors.black,
                            //             ),
                            //           ),
                            //         ),
                            //       );
                            //     }).toList(),
                            //     decoration: InputDecoration(
                            //       labelText: "Country",
                            //       labelStyle: Theme.of(context)
                            //           .textTheme
                            //           .body1
                            //           .copyWith(color: CustomAppTheme.grey),
                            //       contentPadding: EdgeInsets.only(
                            //           right: 10, top: 15, bottom: 15, left: 15),
                            //       border: InputBorder.none,
                            //     ),
                            //     onChanged: (value) {
                            //       setState(() {
                            //         _chosenCountry = value;
                            //       });
                            //     },
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    GestureDetector(
                      onTap: () {
                        if (_addressForm.currentState.validate()) {
                          Functions.checkConnectivity().then((value) async {
                            String userjson =
                                await PreferenceKeys.getUserDetail();
                            Customer userDetail =
                                Customer.fromJson(jsonDecode(userjson));

                            if (value != null && value == true) {
                              if (widget.address != null) {
                                FormData data = new FormData.fromMap({
                                  'customer_address_id':
                                      widget.address.customerAddressId,
                                  'customer_address_name': nameController.text,
                                  'customer_address_details':
                                      addressController.text,
                                  'customer_address_city': cityController.text,
                                  'customer_address_state':
                                      stateController.text,
                                  'customer_address_zipcode':
                                      zipCodeController.text,
                                  'countries_id': _chosenCountry.countriesId,
                                });
                                updateAddress(data: data, context: context)
                                    .whenComplete(() => isLoading
                                        ? {}
                                        : Navigator.pop(context, true));
                              } else {
                                FormData data = new FormData.fromMap({
                                  'customer_id': userDetail.customerId,
                                  'customer_address_name': nameController.text,
                                  'customer_address_details':
                                      addressController.text,
                                  'customer_address_city': cityController.text,
                                  'customer_address_state':
                                      stateController.text,
                                  'customer_address_zipcode':
                                      zipCodeController.text,
                                  'countries_id': _chosenCountry.countriesId,
                                });
                                addAddress(data: data, context: context)
                                    .whenComplete(() => isLoading
                                        ? {}
                                        : Navigator.pop(context, true));
                              }
                            }
                          });
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
                          "SAVE ADDRESS",
                          style: Theme.of(context).textTheme.button,
                        )),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    )
                  ],
                ),
              ),
            ),
            Container(
              child: isLoading
                  ? Loader(
                      bgColor: Colors.black,
                      loaderColor: Colors.white,
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }

  Widget CustomInputField(
      {TextEditingController controller,
      ValueChanged<String> validator,
      String label,
      bool enabled,
      TextInputType inputType}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
      color: Colors.white.withOpacity(0.8),
      child: Container(
        child: TextFormField(
          style: TextStyle(
            fontSize: 13,
            color: Colors.black,
          ),
          controller: controller,
          keyboardType: inputType ?? TextInputType.text,
          textInputAction: TextInputAction.next,
          enabled: enabled ?? true,
          validator: validator,
          onTap: () {},
          onChanged: (value) {},
          decoration: InputDecoration(
            labelText: label,
            labelStyle: Theme.of(context)
                .textTheme
                .body1
                .copyWith(color: CustomAppTheme.grey),
            contentPadding: EdgeInsets.all(15),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  String nameValidator(value) {
    if (value.length == 0) {
      return "Name Empty";
    }
  }

  String addressValidator(value) {
    if (value.length == 0) {
      return "Address Empty";
    }
  }

  String cityValidator(value) {
    if (value.length == 0) {
      return "City Empty";
    }
  }

  String stateValidator(value) {
    if (value.length == 0) {
      return "State Empty";
    }
  }

  String zipCodeValidator(value) {
    if (value.length == 0) {
      return "Zip Code Empty";
    } else if (value.length != 6) {
      return "Invalid Zip Code";
    }
  }

  Future<void> addAddress(
      {@required FormData data, @required BuildContext context}) async {
    setLoading(true);
    try {
      ApiResponseModel apiResponse =
          await _addressApi.addAddress(data: data, context: context);
      print("Add Address Api response data :- ");
      print(apiResponse.response);

      if (apiResponse.success == true && apiResponse.response != null) {
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

  Future<void> updateAddress(
      {@required FormData data, @required BuildContext context}) async {
    setLoading(true);
    try {
      ApiResponseModel apiResponse =
          await _addressApi.updateAddress(data: data, context: context);
      print("Add Address Api response data :- ");
      print(apiResponse.response);

      if (apiResponse.success == true && apiResponse.response != null) {
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
}
