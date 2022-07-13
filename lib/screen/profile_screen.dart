import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/data/services/user_api.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/global/variable/custom_app_theme.dart';
import 'package:prabodham/global/variable/images.dart';
import 'package:prabodham/helper/preference_keys.dart';
import 'package:prabodham/model/customer.dart';
import 'package:prabodham/widgets/component_widgets/loader.dart';
import 'package:prabodham/widgets/custom_app_bar.dart';
import 'package:prabodham/widgets/custom_image.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserApi _userApi = UserApi();
  final _profileForm = GlobalKey<FormState>();
  Customer userDetail;
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();
  bool isLoading = true;
  bool isUpdating = false;
  DateTime selectedDate;
  DateFormat dateFormat = DateFormat('dd , MMMM yyyy');

  @override
  void initState() {
    getProfileData();
    super.initState();
  }

  getProfileData() async {
    Functions.checkConnectivity().then((value) async {
      String userjson = await PreferenceKeys.getUserDetail();
      setState(() {
        userDetail = Customer.fromJson(jsonDecode(userjson));
        nameController.text = userDetail.customerName ?? "No Name";
        print(userDetail.customerMobileNumber.toString());
        phoneNumberController.text =
            userDetail.customerMobileNumber.toString() ?? "No Number";
        dateOfBirthController.text = userDetail.customerDateOfBirth != null
            ? dateFormat.format(userDetail.customerDateOfBirth)
            : "";
        isLoading = false;
      });
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1950),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate) {
      setState(() {
        print(picked.year);
        selectedDate = picked;
        dateOfBirthController.text = dateFormat.format(picked);
      });
    }
  }

  Future<File> cropImage({BuildContext context, File image}) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio4x3,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));

    return croppedFile;
  }

  Future<void> updateProfileImage({ImageSource imageSource}) async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.getImage(source: imageSource, imageQuality: 30);

    if (pickedFile != null) {
      cropImage(context: context, image: File(pickedFile.path))
          .then((croppedFile) {
        if (croppedFile != null) {
          Functions.checkConnectivity().then((value) async {
            setState(() {
              isUpdating = true;
            });
            if (value != null && value == true) {
              FormData data = FormData.fromMap({
                'customer_id': userDetail.customerId,
                'customer_profile_image':
                    await MultipartFile.fromFile(croppedFile.path),
              });
              try {
                ApiResponseModel apiResponse = await _userApi.updateUserDetails(
                    context: context, data: data);
                print("User Details Api response data :- ");
                if (apiResponse.success == true &&
                    apiResponse.response != null) {
                  PreferenceKeys.setUserDetail(
                      jsonEncode(apiResponse.response));
                  setState(() {
                    getProfileData();
                    isUpdating = false;
                  });
                  print(Customer.fromJson(apiResponse.response).customerName);
                  // setState(() {
                  //   userDetail = Customer.fromJson(apiResponse.response);
                  // });
                } else {
                  setState(() {
                    isUpdating = false;
                  });
                  Functions.toast(apiResponse.message);
                }
              } catch (e) {
                setState(() {
                  isUpdating = false;
                });
                print(e.toString());
                final errorMessage = DioExceptions.fromDioError(e).toString();
                showCustomDialog(context, 'Error', errorMessage);
              }
            }
          });
        }
      });
    }
  }

  Future<void> updateUserDetails({@required BuildContext context}) async {
    Functions.checkConnectivity().then((value) async {
      setState(() {
        isUpdating = true;
      });
      if (value != null && value == true) {
        FormData data = new FormData.fromMap({
          'customer_id': userDetail.customerId,
          'customer_name': nameController.text,
          'customer_mobile_number': phoneNumberController.text.toString(),
          'customer_date_of_birth': selectedDate
        });
        try {
          ApiResponseModel apiResponse =
              await _userApi.updateUserDetails(context: context, data: data);
          print("User Details Api response data :- ");

          if (apiResponse.success == true && apiResponse.response != null) {
            PreferenceKeys.setUserDetail(jsonEncode(apiResponse.response));
            setState(() {
              isUpdating = false;
            });
            print(Customer.fromJson(apiResponse.response).customerName);
            // setState(() {
            //   userDetail = Customer.fromJson(apiResponse.response);
            // });
          } else {
            setState(() {
              isUpdating = false;
            });
            Functions.toast(apiResponse.message);
          }
        } catch (e) {
          setState(() {
            isUpdating = false;
          });
          print(e.toString());
          final errorMessage = DioExceptions.fromDioError(e).toString();
          showCustomDialog(context, 'Error', errorMessage);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          title: Text("My Profile"),
          centerTitle: true,
          elevation: 2,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: Stack(
          children: [
            isLoading
                ? Loader(
                    bgColor: CustomAppTheme.white,
                    loaderColor: Theme.of(context).primaryColor,
                  )
                : Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: SingleChildScrollView(
                        child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          uerInfo(),
                          SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    )),
                  ),
            Container(
              child: isUpdating
                  ? Loader(
                      bgColor: Colors.black87,
                      loaderColor: Colors.white,
                    )
                  : Container(),
            ),
          ],
        ));
  }

  Future<void> _profileImageSourceDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0)),
              title: Text(
                "From where do you want to take  photo ?",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.body2,
              ),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  GestureDetector(
                    child: Container(
                        height: 30,
                        width: 70,
                        color: CustomAppTheme.primaryColor,
                        child: Center(
                            child: Text(
                          "Gallery",
                          style: TextStyle(
                              fontSize: 14, color: CustomAppTheme.white),
                        ))),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await updateProfileImage(
                          imageSource: ImageSource.gallery);
                    },
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  GestureDetector(
                    child: Container(
                        height: 30,
                        width: 80,
                        color: CustomAppTheme.primaryColor,
                        child: Center(
                            child: Text(
                          "Camera",
                          style: TextStyle(
                              fontSize: 14, color: CustomAppTheme.white),
                        ))),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await updateProfileImage(imageSource: ImageSource.camera);
                    },
                  )
                ],
              ));
        });
  }

  Widget uerInfo() {
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          userImage(),
          SizedBox(
            height: 10,
          ),
          Text(
            userDetail.customerName ?? "",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            userDetail.customerEmail ?? "No Email",
            //restaurantDetail!.restaurantEmail!,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey[800]),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                " Referral Code : ",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                userDetail.customerReferralCode ?? "No Referral Code",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).primaryColor),
              ),
            ],
          ),
          SizedBox(
            height: 25,
          ),
          // editProfileButton(),
          Container(
            child: Form(
              key: _profileForm,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: CustomInputField(
                      controller: nameController,
                      validator: nameValidator,
                      label: "Name",
                      inputType: TextInputType.emailAddress,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: CustomInputField(
                      controller: phoneNumberController,
                      validator: phoneNumberValidator,
                      label: "Phone Number",
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _selectDate(context);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: CustomInputField(
                        controller: dateOfBirthController,
                        //validator: passwordValidator,
                        enabled: false,
                        label: "Date of Birth",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Container(
            child: GestureDetector(
              onTap: () async {
                FocusScope.of(context).unfocus();
                if (_profileForm.currentState.validate()) {
                  await updateUserDetails(context: context);
                }
              },
              child: Container(
                height: 40,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Center(
                    child: Text(
                  "UPDATE",
                  style: Theme.of(context).textTheme.button,
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget userImage() {
    //print(restaurantDetail!.restaurantImage);
    return Stack(
      children: [
        Container(
          height: 90,
          width: 90,
          decoration: BoxDecoration(shape: BoxShape.circle),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(45),
            child: userDetail.customerProfileImage == null
                ? Image.asset(Images.USER_PLACEHOLDER)
                : CustomImage(
                    fit: BoxFit.cover, imgURL: userDetail.customerProfileImage),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () async {
              _profileImageSourceDialog();
            },
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor),
              child: Icon(
                Icons.photo_camera_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget editProfileButton() {
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => EditProfileScreen(user: user!)))
        //     .then((value) {
        //   setState(() {});
        // });
      },
      child: Container(
        height: 28,
        width: 130,
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(20)),
        child: Center(
            child: Text(
          "Edit Profile",
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
        )),
      ),
    );
  }

  Widget CustomInputField({
    TextEditingController controller,
    ValueChanged<String> validator,
    bool obscureText = false,
    String label,
    bool enabled,
    TextInputType inputType = TextInputType.text,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      color: Colors.white,
      child: Container(
        child: TextFormField(
          style: Theme.of(context).textTheme.body2,
          controller: controller,
          keyboardType: inputType,
          textInputAction: TextInputAction.next,
          enabled: enabled ?? true,
          obscureText: obscureText,
          validator: validator,
          onTap: () {},
          onChanged: (value) {},
          decoration: InputDecoration(
            labelText: label,
            labelStyle: Theme.of(context)
                .textTheme
                .body1
                .copyWith(color: CustomAppTheme.grey),
            contentPadding: EdgeInsets.all(10),
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

  String phoneNumberValidator(value) {
    if (value.length != 0) {
      if (value.length != 10) {
        return "Enter valid phone number";
      }
    }
  }
}
