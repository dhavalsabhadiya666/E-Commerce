import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/data/services/category_api.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/model/category.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';

class CategoryProvider with ChangeNotifier {
  CategoryApi _categoryApi = CategoryApi();
  List<Category> _categories;

  List<Category> get categories => _categories;

  bool isLoading = false;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> getCategory({@required FormData data, @required BuildContext context}) async {
    setLoading(true);
    try {
      ApiResponseModel apiResponse = await _categoryApi.getCategory(context: context, data: data);
      print("Get Categories Api response data :- ");
      print(apiResponse.response);

      if (apiResponse.success == true && apiResponse.response != null) {
        var list = apiResponse.response as List;
        _categories = list.map((element) {
          return Category.fromJson(element);
        }).toList();
        notifyListeners();
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
