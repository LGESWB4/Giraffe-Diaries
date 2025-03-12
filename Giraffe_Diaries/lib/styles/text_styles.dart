import 'package:flutter/material.dart';

class AppTextStyle {
  static const TextStyle light = TextStyle(
    fontFamily: 'AppleSDGothicNeoM',
    fontWeight: FontWeight.w300,
  );

  static const TextStyle regular = TextStyle(
    fontFamily: 'AppleSDGothicNeoM',
    fontWeight: FontWeight.w400,
  );

  static const TextStyle medium = TextStyle(
    fontFamily: 'AppleSDGothicNeoM',
    fontWeight: FontWeight.w500,
  );

  static const TextStyle semiBold = TextStyle(
    fontFamily: 'AppleSDGothicNeoM',
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bold = TextStyle(
    fontFamily: 'AppleSDGothicNeoM',
    fontWeight: FontWeight.w700,
  );

  // 자주 사용하는 크기별 스타일
  static TextStyle heading1 = bold.copyWith(fontSize: 24);
  static TextStyle heading2 = semiBold.copyWith(fontSize: 20);
  static TextStyle body1 = regular.copyWith(fontSize: 16);
  static TextStyle body2 = light.copyWith(fontSize: 14);
  static TextStyle caption = regular.copyWith(fontSize: 12);
} 