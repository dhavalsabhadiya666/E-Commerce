import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/dio_client.dart';
import 'package:prabodham/data/endpoints.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';

class CategoryApi {
  DioClient _client = DioClient();

  Future<dynamic> getCategory({@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse = await _client.post('${Endpoints.getCategories}', data: data);

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
