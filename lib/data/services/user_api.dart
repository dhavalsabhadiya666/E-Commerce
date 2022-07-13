import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/dio_client.dart';
import 'package:prabodham/data/endpoints.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/model/app_version.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';
import 'dart:io' show Platform;

import 'package:shared_preferences/shared_preferences.dart';

class UserApi {
  DioClient _client = DioClient();

  Future<dynamic> signUp({@required FormData data}) async {
    print("data");
    ApiResponseModel response =
        await _client.post('${Endpoints.signUp}', data: data);
    print(response.message);
    return response;
  }

  Future<dynamic> signIn({@required FormData data}) async {
    print(data.fields);

    ApiResponseModel response =
        await _client.post('${Endpoints.signIn}', data: data);
    print("Test 3");
    print(response.toString());
    return response;
  }

  Future<dynamic> updateUserDetails(
      {@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse =
          await _client.post('${Endpoints.updateUserDetails}', data: data);

      print(apiResponse.response);

      if (apiResponse.success == true) {
        return apiResponse;
      } else {
        Functions.toast(apiResponse.message);
        return apiResponse;
      }
    } catch (e) {
      print(e.toString());
      final errorMessage = DioExceptions.fromDioError(e).toString();
      showCustomDialog(context, 'Error', errorMessage);
      return null;
    }
  }

  Future<dynamic> resetPassword(
      {@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse =
          await _client.post('${Endpoints.resetPassword}', data: data);

      print(apiResponse.response);

      if (apiResponse.success == true) {
        return apiResponse;
      } else {
        Functions.toast(apiResponse.message);
        return apiResponse;
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      showCustomDialog(context, 'Error', errorMessage);
      return null;
    }
  }

  Future<dynamic> forgetPassword(
      {@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse =
          await _client.post('${Endpoints.forgotPassword}', data: data);

      print(apiResponse.response);

      if (apiResponse.success == true) {
        return apiResponse;
      } else {
        Functions.toast(apiResponse.message);
        return apiResponse;
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      showCustomDialog(context, 'Error', errorMessage);
      return null;
    }
  }

  Future<dynamic> getUserDetails(
      {@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse =
          await _client.post('${Endpoints.getUserDetails}', data: data);
      print(apiResponse.response);

      if (apiResponse.success == true) {
        return apiResponse;
      } else {
        Functions.toast(apiResponse.message);
        return apiResponse;
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      showCustomDialog(context, 'Error', errorMessage);
      return null;
    }
  }

  Future<dynamic> appVersion(
      {@required BuildContext context, FormData data}) async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      ApiResponseModel apiResponse =
          await _client.get('${Endpoints.appVersion}');
      // print(apiResponse.response);
      // print("3");
      if (apiResponse.success == true) {
        AppVersion appVersion = AppVersion.fromJson(apiResponse.response);

        if (Platform.isAndroid) {
          String version = packageInfo.version;
          if (appVersion.android == version) {
            return false;
          } else {
            if (appVersion.isForceUpdate == 1) {
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              preferences.clear();
              return true;
            }
            return false;
          }
        } else if (Platform.isIOS) {
          String version = packageInfo.version;
          if (appVersion.android == version) {
            return false;
          } else {
            if (appVersion.isForceUpdate == 1) {
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              preferences.clear();
              return true;
            }
            return false;
          }
        } else {
          return false;
        }
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      print(errorMessage);
      return false;
    }
  }
}
