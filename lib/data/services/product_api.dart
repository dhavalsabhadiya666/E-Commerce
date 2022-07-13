import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/dio_client.dart';
import 'package:prabodham/data/endpoints.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/model/product.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';

class ProductApi {
  DioClient _client = DioClient();

  Future<dynamic> getBestSellerProducts(
      {@required BuildContext context, FormData data}) async {
    print("Seller called");
    try {
      ApiResponseModel apiResponse =
          await _client.post('${Endpoints.bestSellerProducts}', data: data);
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

  Future<dynamic> getNewArrivalProducts(
      {@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse =
          await _client.post('${Endpoints.newArrivalProducts}', data: data);
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

  Future<dynamic> getProductByCategory(
      {@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse =
          await _client.post('${Endpoints.getProductByCategory}', data: data);
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

  Future<dynamic> getProductBySearch(
      {@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse =
          await _client.post('${Endpoints.getProductBySearch}', data: data);
      print(apiResponse.response);

      if (apiResponse.success == true) {
        return apiResponse;
      } else {
        Functions.toast(apiResponse.message);
        return apiResponse;
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      // print(errorMessage);
      // final snackBar = SnackBar(
      //   content: Text(errorMessage),
      // );
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return null;
    }
  }

  Future<dynamic> getFavouriteProducts(
      {@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse =
          await _client.post('${Endpoints.getFavouriteProduct}', data: data);
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
        duration: Duration(milliseconds: 800),
      );
      //ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return null;
    }
  }

  Future<dynamic> getRecommendedProducts(
      {@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse =
          await _client.post('${Endpoints.getRecommendedProduct}', data: data);
      print(apiResponse.response);

      if (apiResponse.success == true) {
        var list = apiResponse.response as List;
        List<Product> productList = list.map((element) {
          return Product.fromJson(element);
        }).toList();
        return productList;
      } else {
        Functions.toast(apiResponse.message);
        return [];
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      showCustomDialog(context, 'Error', errorMessage);
      return null;
    }
  }

  Future<dynamic> getProductById(
      {@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse =
          await _client.post('${Endpoints.getProductById}', data: data);
      print(apiResponse.response);

      if (apiResponse.success == true) {
        return apiResponse;
      } else {
        Functions.toast(apiResponse.message);
        return apiResponse;
      }
    } catch (e) {
      print(e);
      final errorMessage = DioExceptions.fromDioError(e).toString();
      showCustomDialog(context, 'Error', errorMessage);
      return null;
    }
  }

  Future<dynamic> addProductFavourite(
      {@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse =
          await _client.post('${Endpoints.addProductFavourite}', data: data);
      print(apiResponse.response);

      if (apiResponse.success == true) {
        return apiResponse;
      } else {
        Functions.toast(apiResponse.message);
        return apiResponse;
      }
    } catch (e) {
      print(e);
      final errorMessage = DioExceptions.fromDioError(e).toString();
      showCustomDialog(context, 'Error', errorMessage);
      return null;
    }
  }

  Future<dynamic> removeProductFavourite(
      {@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse =
          await _client.post('${Endpoints.removeProductFavourite}', data: data);
      print(apiResponse.response);

      if (apiResponse.success == true) {
        return apiResponse;
      } else {
        Functions.toast(apiResponse.message);
        return apiResponse;
      }
    } catch (e) {
      print(e);
      final errorMessage = DioExceptions.fromDioError(e).toString();
      showCustomDialog(context, 'Error', errorMessage);
      return null;
    }
  }

  Future<dynamic> updateProductFavourite(
      {@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse =
          await _client.post('${Endpoints.updateProductFavourite}', data: data);
      print(apiResponse.response);

      if (apiResponse.success == true) {
        return apiResponse;
      } else {
        Functions.toast(apiResponse.message);
        return apiResponse;
      }
    } catch (e) {
      print(e);
      final errorMessage = DioExceptions.fromDioError(e).toString();
      showCustomDialog(context, 'Error', errorMessage);
      return null;
    }
  }
}
