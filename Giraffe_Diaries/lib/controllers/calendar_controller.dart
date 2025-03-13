import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class CalendarController extends GetxController {
  final selectedDay = DateTime.now().obs;
  final focusedDay = DateTime.now().obs;
  final events = RxMap<DateTime, List<String>>({});

  static const Color defaultMarkerColor = Color(0xFFE5E5E5);  // 과거 날짜 마커 색상
  static const Color futureMarkerColor = Color(0xFFFAFAFA);  // 미래 날짜 마커 색상

  void _addDefaultEvents() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);

    for (var d = firstDay; d.isBefore(lastDay.add(const Duration(days: 1))); d = d.add(const Duration(days: 1))) {
      final currentDate = DateTime(d.year, d.month, d.day);
      final color = currentDate.isBefore(today) || currentDate.isAtSameMomentAs(today)
          ? defaultMarkerColor
          : futureMarkerColor;
      events[DateTime.utc(d.year, d.month, d.day)] = ['default|${color.value}'];
    }
  }

  void updateEventsForMonth(DateTime month) {
    events.clear();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    for (var d = firstDay; d.isBefore(lastDay.add(const Duration(days: 1))); d = d.add(const Duration(days: 1))) {
      final currentDate = DateTime(d.year, d.month, d.day);
      final color = currentDate.isBefore(today) || currentDate.isAtSameMomentAs(today)
          ? defaultMarkerColor
          : futureMarkerColor;
      events[DateTime.utc(d.year, d.month, d.day)] = ['default|${color.value}'];
    }
  }

  @override
  void onInit() {
    super.onInit();
    _addDefaultEvents();
  }

  void onDaySelected(DateTime selected, DateTime focused) {
    if (!isSameDay(selectedDay.value, selected)) {
      selectedDay.value = selected;
      focusedDay.value = focused;
    }
  }

  Color getMarkerColor(String eventStr) {
    final colorValue = int.tryParse(eventStr.split('|')[1]);
    return Color(colorValue ?? defaultMarkerColor.value);
  }
}