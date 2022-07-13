import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/dio_client.dart';
import 'package:prabodham/data/endpoints.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';

class AddressApi {
  DioClient _client = DioClient();

  Future<dynamic> getCountry() async {
    try {
      ApiResponseModel response =
          await _client.get('${Endpoints.getCountries}');
      print(response.message);
      return response;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<dynamic> addAddress(
      {@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse =
          await _client.post('${Endpoints.addAddress}', data: data);
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

  Future<dynamic> getAddress(
      {@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse =
          await _client.post('${Endpoints.getAddress}', data: data);
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

  Future<dynamic> updateAddress(
      {@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse =
          await _client.post('${Endpoints.updateAddress}', data: data);
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

  Future<dynamic> changeDefaultAddress(
      {@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse =
          await _client.post('${Endpoints.updateDefaultAddress}', data: data);
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

  Future<dynamic> deleteAddress(
      {@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse =
          await _client.post('${Endpoints.deleteAddress}', data: data);
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
}
