import 'package:flutter/widgets.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/data/services/address_api.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/model/country.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';

class CountryProvider with ChangeNotifier {
  List<Country> _countries;

  List<Country> get countries => _countries;

  AddressApi _addressApi = AddressApi();

  bool isLoading = false;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> getCountry({@required BuildContext context}) async {
    setLoading(true);
    try {
      ApiResponseModel apiResponse = await _addressApi.getCountry();
      print("getCountry Api response data :- ");
      print(apiResponse.response);
      print("Test ----- 0");

      if (apiResponse.success == true && apiResponse.response != null) {
        print("Test ----- 1");
        var list = apiResponse.response as List;
        _countries = list.map((element) {
          return Country.fromJson(element);
        }).toList();
        print("Test ----- 2");
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
