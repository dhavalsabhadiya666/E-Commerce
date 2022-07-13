import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

Widget smallLoader({@required BuildContext context, double height}) {
  return Center(
    child: Container(
      height: height ?? 60,
      child: LoadingIndicator(
          indicatorType: Indicator.values[12],
          color: Theme.of(context).primaryColor),
    ),
  );
}
