import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/dio_client.dart';
import 'package:prabodham/data/endpoints.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/model/review.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';

class ReviewApi {
  DioClient _client = DioClient();

  Future<dynamic> getReviewByProduct({@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse =
          await _client.post('${Endpoints.getReviewByProduct}', data: data);
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

  Future<List<Review>> getMyReviews({@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse = await _client.post('${Endpoints.getMyReview}', data: data);
      print(apiResponse.response);

      if (apiResponse.success == true) {
        var list = apiResponse.response as List;
        List<Review> reviewList = list.map((element) {
          return Review.fromJson(element);
        }).toList();
        return reviewList;
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

  Future<dynamic> postReview({@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse = await _client.post('${Endpoints.postReview}', data: data);
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
