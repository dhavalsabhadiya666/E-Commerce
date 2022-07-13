import 'package:flutter/material.dart';

void showCustomDialog(BuildContext ctx, String title, String description) {
  showDialog(
    context: ctx,
    builder: (context) => AlertDialog(
      // title: Text(title),
      content: Text(
        description,
        style: Theme.of(context).textTheme.subtitle.copyWith(fontSize: 16),
      ),
      actions: [
        FlatButton(
          child: Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        )
      ],
    ),
  );
}
