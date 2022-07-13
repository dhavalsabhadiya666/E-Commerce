import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/dio_client.dart';
import 'package:prabodham/data/endpoints.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/model/referrral_transaction.dart';
import 'package:prabodham/model/wallet_transaction.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';

class WalletApi {
  DioClient _client = DioClient();

  Future<List<WalletTransaction>> getWalletTransaction(
      {@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse =
          await _client.post('${Endpoints.getWalletTransaction}', data: data);
      print(apiResponse.response);

      if (apiResponse.success == true) {
        var list = apiResponse.response as List;
        List<WalletTransaction> transactionList = list.map((element) {
          return WalletTransaction.fromJson(element);
        }).toList();
        print("Length :- ${transactionList.length}");
        return transactionList;
      } else {
        Functions.toast(apiResponse.message);
        return [];
      }
    } catch (e) {
      print(e.toString());
      final errorMessage = DioExceptions.fromDioError(e).toString();
      showCustomDialog(context, 'Error', errorMessage);
      return null;
    }
  }

  Future<List<ReferralTransaction>> getReferralTransaction(
      {@required BuildContext context, FormData data}) async {
    try {
      ApiResponseModel apiResponse =
          await _client.post('${Endpoints.getReferralTransaction}', data: data);
      print(apiResponse.response);

      if (apiResponse.success == true) {
        var list = apiResponse.response as List;
        List<ReferralTransaction> referralTransactionList = list.map((element) {
          return ReferralTransaction.fromJson(element);
        }).toList();
        print("Length :- ${referralTransactionList.length}");
        return referralTransactionList;
      } else {
        Functions.toast(apiResponse.message);
        return [];
      }
    } catch (e) {
      print(e.toString());
      final errorMessage = DioExceptions.fromDioError(e).toString();
      showCustomDialog(context, 'Error', errorMessage);
      return null;
    }
  }
}
