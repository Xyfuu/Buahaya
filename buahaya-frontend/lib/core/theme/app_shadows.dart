import 'package:flutter/material.dart';

abstract final class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
  ];
  static const List<BoxShadow> elevated = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 6, spreadRadius: -1, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x1A000000), blurRadius: 4, spreadRadius: -2, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> sheet = [
    BoxShadow(color: Color(0x40000000), blurRadius: 50, spreadRadius: -12, offset: Offset(0, 25)),
  ];
  static const List<BoxShadow> header = [
    BoxShadow(color: Color(0x0F175E41), blurRadius: 12, offset: Offset(0, 1)),
  ];
  static const List<BoxShadow> navBar = [
    BoxShadow(color: Color(0x14347758), blurRadius: 20, offset: Offset(0, -4)),
  ];
  static const List<BoxShadow> fab = [
    BoxShadow(color: Color(0x66347758), blurRadius: 24, spreadRadius: -4, offset: Offset(0, 8)),
  ];
}
