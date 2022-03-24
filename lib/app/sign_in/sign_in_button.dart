import 'package:bill_tracker/common_widgets/custom_raised_button.dart';
import 'package:flutter/material.dart';


class SignInButton extends CustomRaisedButton {
  SignInButton({
    required String text,
    required Color? color,
    required Color textColor,
    required VoidCallback onPressed,
  }) : assert(text != null),
        super(
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: 15.0),
        ),
        color: color,
        onPressed: onPressed,
      );
}
