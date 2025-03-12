import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/calendar_controller.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomeScreen extends GetView<CalendarController> {
  const HomeScreen({Key? key}) : super(key: key);

  // 커스텀 색상 정의
  static const Color customBlue = Color(0xFF2563EB);
  static const Color customOrange = Color(0xFFEA580C);

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    Get.put(CalendarController());
    // 한국어 로케일 초기화
    initializeDateFormatting('ko_KR', null);

    return Scaffold(
      backgroundColor: Colors.white,  // 배경색 지정
      body: SafeArea(  // SafeArea로 감싸서 상단 상태바 영역 보호
        child: Column(
          children: [
            const SizedBox(height: 20),  // 상단 여백 추가
            Obx(() => TableCalendar(
              firstDay: DateTime.utc(2021, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: controller.focusedDay.value,
              locale: 'ko_KR',
              selectedDayPredicate: (day) =>
                  isSameDay(controller.selectedDay.value, day),
              onDaySelected: controller.onDaySelected,
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {
                CalendarFormat.month: '',
              },
              eventLoader: (day) => controller.events[day] ?? [],
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                holidayTextStyle: TextStyle(color: customOrange),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: false,  // 왼쪽 정렬
                leftChevronVisible: false,
                rightChevronVisible: false,
                headerPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
                titleTextFormatter: (date, locale) => '',  // 빈 문자열 반환
              ),
              // 커스텀 헤더 빌더
              calendarBuilders: CalendarBuilders(
                headerTitleBuilder: (context, day) {
                  return InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            height: 300,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Text(
                                  '${day.year}년',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Expanded(
                                  child: GridView.builder(
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      childAspectRatio: 1.5,
                                    ),
                                    itemCount: 12,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          final selectedDate = DateTime(
                                            day.year,
                                            index + 1,
                                            1,
                                          );
                                          controller.focusedDay.value = selectedDate;
                                          Get.back();
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          margin: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: day.month == index + 1
                                                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                                : null,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${index + 1}월',
                                            style: TextStyle(
                                              fontWeight: day.month == index + 1
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${day.year}년 ${day.month}월',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_drop_down,
                          size: 24,
                        ),
                      ],
                    ),
                  );
                },
                dowBuilder: (context, day) {
                  if (day.weekday == DateTime.sunday) {
                    return Center(
                      child: Text(
                        '일',
                        style: const TextStyle(
                          color: customOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return null;
                },
                defaultBuilder: (context, day, focusedDay) {
                  if (day.weekday == DateTime.saturday) {
                    return Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: customBlue),  // 토요일 날짜 색상
                      ),
                    );
                  } else if (day.weekday == DateTime.sunday) {
                    return Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: customOrange),  // 일요일 날짜 색상
                      ),
                    );
                  }
                  return null;
                },
              ),
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 일기 작성 화면으로 이동
          Get.snackbar(
            '알림',
            '${controller.selectedDay.value.month}월 ${controller.selectedDay.value.day}일의 일기를 작성합니다.',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}