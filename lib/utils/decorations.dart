import 'package:flutter/material.dart';

class CustomInputDecoration extends InputDecoration {
  final Widget leadingIcon;
  final String text;

  CustomInputDecoration({
    required this.leadingIcon,
    required this.text,
  }) : super(
    prefixIcon: leadingIcon,
    prefixIconColor: Colors.purple,
    isDense: true,
    labelText: text,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );
}
