import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarController extends GetxController {
  final Rx<DateTime> selectedDay = DateTime.now().obs;
  final Rx<DateTime> focusedDay = DateTime.now().obs;
  final RxMap<DateTime, List<dynamic>> events = <DateTime, List<dynamic>>{}.obs;

  void onDaySelected(DateTime selected, DateTime focused) {
    if (!isSameDay(selectedDay.value, selected)) {
      selectedDay.value = selected;
      focusedDay.value = focused;
      // TODO: 선택된 날짜의 일기를 불러오는 로직 추가
    }
  }

  bool hasEvents(DateTime day) {
    final eventForDay = events[day] ?? [];
    return eventForDay.isNotEmpty;
  }

  void addEvent(DateTime date, dynamic event) {
    if (events[date] != null) {
      events[date]!.add(event);
    } else {
      events[date] = [event];
    }
    update();
  }
}