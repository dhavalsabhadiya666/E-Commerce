import 'package:flutter/widgets.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/data/services/promocode_api.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/model/promocode.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';

class PromoCodeProvider with ChangeNotifier {
  List<PromoCode> _promocodes;

  List<PromoCode> get promocodes => _promocodes;

  PromocodeApi _promocodeApi = PromocodeApi();

  bool isLoading = false;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> getPromocode({@required BuildContext context}) async {
    setLoading(true);
    try {
      ApiResponseModel apiResponse =
          await _promocodeApi.getAllPromoCodes(context: context);
      print("getPromoCodes Api response data :- ");
      print(apiResponse.response);

      if (apiResponse.success == true && apiResponse.response != null) {
        var list = apiResponse.response as List;
        _promocodes = list.map((element) {
          return PromoCode.fromJson(element);
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
