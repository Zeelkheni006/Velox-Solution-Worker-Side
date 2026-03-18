import 'package:flutter/material.dart';

double rs(BuildContext context, double value) {
  double width = MediaQuery.of(context).size.width;

  if (width < 600) return value;
  if (width < 900) return value * 1.2;
  return value * 1.4;
}
