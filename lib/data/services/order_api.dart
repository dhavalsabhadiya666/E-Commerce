import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/dio_client.dart';
import 'package:prabodham/data/endpoints.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';

class OrderApi {
  DioClient _client = DioClient();

  Future<dynamic> getAllOrders(
      {@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse =
          await _client.post('${Endpoints.getAllOrders}', data: data);
      print(apiResponse.response);

      if (apiResponse.success == true) {
        return apiResponse;
      } else {
        Functions.toast(apiResponse.message);
        return apiResponse;
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      // showCustomDialog(context, 'Error', errorMessage);
      final snackBar = SnackBar(
        content: Text(errorMessage),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return null;
    }
  }

  Future<dynamic> postOrder(
      {@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse =
          await _client.post('${Endpoints.postOrder}', data: data);
      print("Test1");
      print(apiResponse.response);
      print("Test2");

      if (apiResponse.success == true) {
        print("Test3");
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

  Future<dynamic> getOrderById(
      {@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse =
          await _client.post('${Endpoints.getOrderById}', data: data);
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

  Future<dynamic> cancelOrderById(
      {@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse =
          await _client.post('${Endpoints.deleteOrderById}', data: data);
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

  Future<dynamic> getAvailability(
      {@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse =
          await _client.post('${Endpoints.getAvailability}', data: data);
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
