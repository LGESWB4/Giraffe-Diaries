import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giraffe_diaries/controllers/emoji_controller.dart';
import 'package:giraffe_diaries/screens/diary_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/calendar_controller.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../styles/text_styles.dart';
import '../screens/diary_write_screen.dart';
import '../services/diary_service.dart';

class HomeScreen extends GetView<CalendarController> {
  const HomeScreen({super.key});

  // 커스텀 색상 정의
  static const Color customBlue = Color(0xFF2563EB);
  static const Color customOrange = Color(0xFFEA580C);
  static const Color primaryColor = Color(0xFFF6AD62);
  static const Color primaryLightColor = Color(0xFFFFF6EC);

  // 공통 스타일 정의
  static const EdgeInsets datePadding = EdgeInsets.symmetric(horizontal: 8, vertical: 4);

  // 공통 메서드
  void showDiaryWriteScreen(DateTime date) {
    Get.to(() => DiaryWriteScreen(selectedDate: date));
  }

  void showMonthPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => const MonthPickerSheet(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
    );
  }

  Widget buildDateContainer({
    required Widget child,
    BoxDecoration? decoration,
  }) {
    return Center(
      child: Container(
        padding: datePadding,
        decoration: decoration,
        child: child,
      ),
    );
  }

  // 날짜 선택 시 처리하는 메서드 추가
  void onDayTapped(DateTime selectedDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // 미래 날짜는 선택 불가
    if (selectedDate.isAfter(today)) {
      return;
    }

    // 오늘 날짜면 일기 작성 화면으로
    if (isSameDay(selectedDate, today)) {
      showDiaryWriteScreen(selectedDate);
      return;
    }

    // 과거 날짜의 경우 일기가 있으면 보기 화면으로
    final diaryEntry = Get.find<DiaryService>().getDiaryEntry(selectedDate);
    if (diaryEntry != null) {
      // 일기 보기 화면으로 이동
      String emojiImagePath = getEmojiPath(diaryEntry.emotion);
      Get.to(() => DiaryScreen(
            generatedImageUrl: diaryEntry.imageUrl,
            selectedDate: selectedDate,
            contenttext: diaryEntry.content,
            emojiImage: emojiImagePath,
          ));
    } else{
      showDiaryWriteScreen(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    Get.put(CalendarController());
    // 한국어 로케일 초기화
    initializeDateFormatting('ko_KR', null);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => InkWell(
                    onTap: () => showMonthPicker(context),
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${controller.focusedDay.value.year}년 ${controller.focusedDay.value.month}월',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down, size: 24),
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
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() => Stack(
                children: [
                  TableCalendar(
                    firstDay: DateTime.utc(2021, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: controller.focusedDay.value,
                    locale: 'ko_KR',
                    selectedDayPredicate: (day) =>
                        isSameDay(controller.selectedDay.value, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      controller.onDaySelected(selectedDay, focusedDay);
                      onDayTapped(selectedDay);
                    },
                    calendarFormat: CalendarFormat.month,
                    pageAnimationEnabled: true,
                    pageAnimationDuration: const Duration(milliseconds: 300),
                    pageAnimationCurve: Curves.easeInOut,
                    startingDayOfWeek: StartingDayOfWeek.sunday,
                    availableCalendarFormats: const {
                      CalendarFormat.month: '',
                    },
                    onPageChanged: controller.onPageChanged,
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      holidayTextStyle: TextStyle(color: customOrange),
                      selectedDecoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      selectedTextStyle: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                      todayTextStyle: AppTextStyles.bodyLarge.copyWith(
                        color: primaryColor,
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
                      titleCentered: false,
                      leftChevronVisible: false,
                      rightChevronVisible: false,
                      titleTextStyle: const TextStyle(height: 0, fontSize: 0),
                      headerPadding: EdgeInsets.zero,
                      headerMargin: EdgeInsets.zero,
                      titleTextFormatter: (date, locale) => '',
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                    ),
                    daysOfWeekHeight: 24,
                    daysOfWeekStyle: DaysOfWeekStyle(
                      dowTextFormatter: (date, locale) {
                        if (date.weekday == DateTime.sunday) return '일';
                        if (date.weekday == DateTime.saturday) return '토';
                        return ['월', '화', '수', '목', '금'][date.weekday - 1];
                      },
                      decoration: const BoxDecoration(color: Colors.transparent),
                      weekdayStyle: AppTextStyles.calendarWeekday,
                      weekendStyle: AppTextStyles.calendarWeekday,
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        // 오늘 날짜
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final targetDate = DateTime(date.year, date.month, date.day);

                        // 미래 날짜인 경우 클릭 불가능한 마커 표시
                        if (targetDate.isAfter(today)) {
                          return Container(
                            width: 35,
                            height: 35,
                            margin: const EdgeInsets.only(top: 12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFF5F5F5),
                            ),
                          );
                        }

                        if (isSameDay(date, today)) {
                          return Container(
                            width: 35,
                            height: 35,
                            margin: const EdgeInsets.only(top: 12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryLightColor,
                            ),
                            child: Icon(
                              Icons.add,
                              color: primaryColor,
                              size: 24,
                            ),
                          );
                        }
                        print("date: $date");
                        // 일기가 있는 날짜는 이모지로 표시
                        final diaryEntry =
                                Get.find<DiaryService>().getDiaryEntry(date);
                        print("diaryEntry: $diaryEntry");
                        if (diaryEntry != null) {
                              String emojiImagePath =
                                  getEmojiPath(diaryEntry.emotion);
                              return Container(
                                width: 35,
                                height: 35,
                                margin: const EdgeInsets.only(top: 12),
                                child: Image.asset(
                                  emojiImagePath,
                                  fit: BoxFit.contain,
                                ),
                              );
                            }

                        // 과거 날짜는 기본 마커로 표시
                        if (targetDate.isBefore(today)) {
                          return Container(
                            width: 35,
                            height: 35,
                            margin: const EdgeInsets.only(top: 12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFE5E5E5),
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                      defaultBuilder: (context, day, focusedDay) {
                        Widget? customText;

                        if (day.weekday == DateTime.saturday) {
                          customText = Text(
                            '${day.day}',
                            style: AppTextStyles.bodyLarge.copyWith(color: customBlue),
                          );
                        } else if (day.weekday == DateTime.sunday) {
                          customText = Text(
                            '${day.day}',
                            style: AppTextStyles.bodyLarge.copyWith(color: customOrange),
                          );
                        } else {
                          customText = Text(
                            '${day.day}',
                            style: AppTextStyles.bodyLarge,
                          );
                        }
                        return buildDateContainer(
                          child: customText,
                        );
                      },
                      selectedBuilder: (context, day, focusedDay) {
                        Widget? customText;
                        if (day.weekday == DateTime.saturday) {
                          customText = Text(
                            '${day.day}',
                            style: AppTextStyles.bodyLarge.copyWith(color: customBlue),
                          );
                        } else if (day.weekday == DateTime.sunday) {
                          customText = Text(
                            '${day.day}',
                            style: AppTextStyles.bodyLarge.copyWith(color: customOrange),
                          );
                        } else {
                          customText = Text(
                            '${day.day}',
                            style: AppTextStyles.bodyLarge,
                          );
                        }
                        return buildDateContainer(
                          child: customText,
                        );
                      },
                      todayBuilder: (context, day, focusedDay) {
                        return buildDateContainer(
                          child: Text(
                            '${day.day}',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      dowBuilder: (context, day) {
                        if (day.weekday == DateTime.sunday) {
                          return Center(
                            child: Text(
                              '일',
                              style: AppTextStyles.calendarWeekday.copyWith(
                                color: customOrange,
                              ),
                            ),
                          );
                        }
                        if (day.weekday == DateTime.saturday) {
                          return Center(
                            child: Text(
                              '토',
                              style: AppTextStyles.calendarWeekday.copyWith(
                                color: customBlue,
                              ),
                            ),
                          );
                        }
                        return Center(
                          child: Text(
                            ['월', '화', '수', '목', '금'][day.weekday - 1],
                            style: AppTextStyles.calendarWeekday,
                          ),
                        );
                      },
                    ),
                  ),
                  if (controller.isLoading.value)
                    Container(
                      color: Colors.white.withOpacity(0.6),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: primaryColor,
                        ),
                      ),
                    ),
                ],
              )),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
        child: FloatingActionButton(
          onPressed: () {
            final today = DateTime.now();
            final todayDate = DateTime(today.year, today.month, today.day);
            controller.onDaySelected(todayDate, todayDate);
            showDiaryWriteScreen(todayDate);
          },
          backgroundColor: primaryColor,
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class MonthPickerSheet extends StatefulWidget {
  const MonthPickerSheet({super.key});

  @override
  State<MonthPickerSheet> createState() => _MonthPickerSheetState();
}

class _MonthPickerSheetState extends State<MonthPickerSheet> {
  late CalendarController controller;
  late DateTime currentDate;
  static const int firstYear = 2021;
  static const int lastYear = 2030;

  @override
  void initState() {
    super.initState();
    controller = Get.find<CalendarController>();
    currentDate = controller.focusedDay.value;
  }

  void changeYear(bool increment) {
    setState(() {
      final newYear = increment ? currentDate.year + 1 : currentDate.year - 1;
      if (newYear >= firstYear && newYear <= lastYear) {
        currentDate = DateTime(
          newYear,
          currentDate.month,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                onPressed: currentDate.year <= firstYear ? null : () => changeYear(false),
                color: currentDate.year <= firstYear ? Colors.grey : null,
              ),
              Text(
                '${currentDate.year}년',
                style: AppTextStyles.heading3.copyWith(
                  color: HomeScreen.primaryColor,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 20),
                onPressed: currentDate.year >= lastYear ? null : () => changeYear(true),
                color: currentDate.year >= lastYear ? Colors.grey : null,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final isSelected = currentDate.month == index + 1;
                return InkWell(
                  onTap: () {
                    final selectedDate = DateTime(
                      currentDate.year,
                      index + 1,
                      1,
                    );
                    controller.focusedDay.value = selectedDate;
                    controller.updateEventsForMonth(selectedDate);
                    Get.back();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? HomeScreen.primaryLightColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? HomeScreen.primaryColor : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      '${index + 1}월',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? HomeScreen.primaryColor : Colors.black,
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
  }
}