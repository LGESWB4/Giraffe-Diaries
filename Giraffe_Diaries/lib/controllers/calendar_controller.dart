import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import '../services/diary_service.dart';

class CalendarController extends GetxController {
  final selectedDay = DateTime.now().obs;
  final focusedDay = DateTime.now().obs;
  final events = RxMap<DateTime, List<String>>({});
  final isLoading = false.obs;
  final DiaryService _diaryService = Get.find<DiaryService>();

  static const Color defaultMarkerColor = Color(0xFFE5E5E5);  // 과거 날짜 마커 색상
  static const Color futureMarkerColor = Color(0xFFFAFAFA);  // 미래 날짜 마커 색상

  @override
  void onInit() {
    super.onInit();
    updateEventsForMonth(focusedDay.value);
  }

  Future<void> updateEventsForMonth(DateTime month) async {
    isLoading.value = true;
    events.clear();

    // 해당 월의 일기 데이터 로드
    final entries = _diaryService.getEntriesForMonth(month);
    for (var entry in entries) {
      final date = DateTime(entry.date.year, entry.date.month, entry.date.day);
      events[date] = ['diary'];
    }

    // 로딩 효과를 위해 약간의 지연 추가
    await Future.delayed(const Duration(milliseconds: 300));

    isLoading.value = false;
  }

  void onDaySelected(DateTime selected, DateTime focused) {
    if (!isSameDay(selectedDay.value, selected)) {
      selectedDay.value = selected;
      focusedDay.value = focused;
    }
  }

  void onPageChanged(DateTime focusedDay) {
    this.focusedDay.value = focusedDay;
    updateEventsForMonth(focusedDay);
  }

  Color getMarkerColor(String eventStr) {
    final colorValue = int.tryParse(eventStr.split('|')[1]);
    return Color(colorValue ?? defaultMarkerColor.value);
  }
}