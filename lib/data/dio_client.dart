import 'dart:io';

import 'package:dio/dio.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/app_exception.dart';
import 'package:prabodham/data/endpoints.dart';
import 'package:prabodham/global/functions/global_functions.dart';

class DioClient {
  static BaseOptions options = new BaseOptions(
    baseUrl: Endpoints.baseUrl,
    connectTimeout: Endpoints.connectionTimeout,
    receiveTimeout: Endpoints.receiveTimeout,
  );
  Dio _dio = Dio(options);

  Future<dynamic> get(
    String uri, {
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onReceiveProgress,
  }) async {
    //Check Internet...
    await Functions.checkConnectivity();

    try {
      final Response response = await _dio.get(
        uri,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      print(response.data.toString());
      return apiResponseModel(response.data);
    } on SocketException {
      throw NoInternetException(
          "Something went wrong with server connection, please check after some time");
    } catch (error) {
      throw error;
    }
  }

  Future<dynamic> post(
    String uri, {
    data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
  }) async {
    //Check Internet...
    await Functions.checkConnectivity();

    try {
      final Response response = await _dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      print("Post Method Response :-");
      print("Testp1");
      print(response.data.toString());
      print("Testp2");
      return apiResponseModel(response.data);
    } on SocketException {
      throw NoInternetException(
          "Something went wrong with server connection, please check after some time");
    } catch (error) {
      throw error;
    }
  }

  Future<ApiResponseModel> apiResponseModel(dynamic response) async {
    ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(response);
    if (apiResponseModel.success == false) {
      Functions.toast(apiResponseModel.message);
    }
    return apiResponseModel;
  }
}
