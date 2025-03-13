import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/calendar_controller.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../controllers/image_generation_controller.dart';
import '../screens/image_loading_screen.dart';
import '../styles/text_styles.dart';
import '../screens/diary_write_screen.dart';

class HomeScreen extends GetView<CalendarController> {
  const HomeScreen({Key? key}) : super(key: key);

  // 커스텀 색상 정의
  static const Color customBlue = Color(0xFF2563EB);
  static const Color customOrange = Color(0xFFEA580C);

  // 공통 스타일 정의
  static const EdgeInsets datePadding = EdgeInsets.symmetric(horizontal: 8, vertical: 4);
  static const TextStyle boldBlackStyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );

  // 공통 메서드
  void showDiaryWriteScreen(DateTime date) {
    Get.to(() => DiaryWriteScreen(selectedDate: date));
  }

  Widget buildDateContainer({
    required Widget child,
    BoxDecoration? decoration,
  }) {
    return AbsorbPointer(
      child: Center(
        child: Container(
          padding: datePadding,
          decoration: decoration,
          child: child,
        ),
      ),
    );
  }

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            height: 300,
                            padding: const EdgeInsets.all(20),
                            color: Colors.white,  // 바텀시트 배경색을 흰색으로 설정
                            child: Column(
                              children: [
                                Text(
                                  '${controller.focusedDay.value.year}년',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: customOrange,
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
                                            controller.focusedDay.value.year,
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
                                            color: controller.focusedDay.value.month == index + 1
                                                ? Colors.transparent
                                                : null,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${index + 1}월',
                                            style: TextStyle(
                                              fontWeight: controller.focusedDay.value.month == index + 1
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
                          '${controller.focusedDay.value.year}년 ${controller.focusedDay.value.month}월',
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
                  )),
                  Image.asset(
                    'assets/images/giraffe_logo.png',
                    height: 50,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(  // 캘린더를 Expanded로 감싸서 남은 공간을 차지하도록 함
              child: Obx(() => TableCalendar(
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
                onPageChanged: (focusedDay) {
                  controller.updateEventsForMonth(focusedDay);
                },
                eventLoader: (day) => controller.events[day] ?? [],
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  holidayTextStyle: TextStyle(color: customOrange),
                  selectedDecoration: BoxDecoration(
                    color: const Color(0xFFF8D088),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  selectedTextStyle: const TextStyle(
                    color: Colors.black,  // 선택된 날짜 텍스트 스타일 기본값으로
                    fontWeight: FontWeight.bold,
                  ),
                  todayDecoration:  BoxDecoration(
                    color: Colors.transparent,  // 오늘 날짜 효과 제거
                  ),
                  todayTextStyle: TextStyle(
                    color: const Color(0xFFF8D088),  // 오늘 날짜 텍스트 스타일 기본값으로
                    fontWeight: FontWeight.bold,
                  ),
                  markersMaxCount: 1,
                  markerSize: 35,
                  markerMargin: const EdgeInsets.only(top: 12),
                  cellMargin: EdgeInsets.zero,
                  cellPadding: EdgeInsets.zero,
                ),
                rowHeight: 100,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: false,  // 왼쪽 정렬
                  leftChevronVisible: false,
                  rightChevronVisible: false,
                  titleTextStyle: const TextStyle(height: 0),  // 헤더 텍스트 숨기기
                  headerPadding: EdgeInsets.zero,  // 헤더 패딩 제거
                  titleTextFormatter: (date, locale) => '',  // 빈 문자열 반환
                ),
                daysOfWeekHeight: 25,  // 요일 행의 높이 1/3 감소 (40 -> 25)
                // 커스텀 헤더 빌더
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isEmpty) return const SizedBox.shrink();

                    // 오늘 날짜인 경우 특별한 + 버튼 표시
                    if (isSameDay(date, DateTime.now())) {
                      return InkWell(
                        onTap: () {
                          controller.onDaySelected(date, date);
                          showDiaryWriteScreen(date);
                        },
                        child: Container(
                          width: 35,
                          height: 35,
                          margin: const EdgeInsets.only(top: 12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFF6EC),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Color(0xFFF6AD62),
                            size: 24,
                          ),
                        ),
                      );
                    }
                    // 일반 날짜의 마커
                    return InkWell(
                      onTap: () {
                        controller.onDaySelected(date, date);
                        showDiaryWriteScreen(date);
                      },
                      child: Container(
                        width: 35,
                        height: 35,
                        margin: const EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: controller.getMarkerColor('default|${controller.events[date]?.first.split('|')[1]}'),
                        ),
                      ),
                    );
                  },
                  defaultBuilder: (context, day, focusedDay) {
                    Widget? customText;
                    BoxDecoration? decoration;

                    // 선택된 날짜인 경우 타원 배경 추가
                    if (isSameDay(day, controller.selectedDay.value)) {
                      decoration = BoxDecoration(
                        color: const Color(0xFFF8D088),
                        borderRadius: BorderRadius.circular(8),
                      );
                    }

                    if (day.weekday == DateTime.saturday) {
                      customText = Text(
                        '${day.day}',
                        style: const TextStyle(color: customBlue),
                      );
                    } else if (day.weekday == DateTime.sunday) {
                      customText = Text(
                        '${day.day}',
                        style: const TextStyle(color: customOrange),
                      );
                    } else {
                      customText = Text('${day.day}');
                    }
                    return buildDateContainer(
                      decoration: decoration,
                      child: customText,
                    );
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    return buildDateContainer(
                      child: Text('${day.day}'),
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    return buildDateContainer(
                      child: Text('${day.day}'),
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
                    if (day.weekday == DateTime.saturday) {
                      return Center(
                        child: Text(
                          '토',
                          style: const TextStyle(
                            color: customBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              )),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDiaryWriteScreen(controller.selectedDay.value),
        backgroundColor: const Color(0xFFF6AD62),
        child: const Icon(Icons.add),
      ),
    );
  }
}