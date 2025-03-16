import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_entry.dart';

class DiaryService extends GetxService {
  static const String _storageKey = 'diary_entries';
  final _entries = RxMap<String, DiaryEntry>({});
  late SharedPreferences _prefs;

  Future<DiaryService> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadEntries();
    return this;
  }

  Future<void> _loadEntries() async {
    final String? entriesJson = _prefs.getString(_storageKey);
    if (entriesJson != null) {
      final Map<String, dynamic> entriesMap = json.decode(entriesJson);
      _entries.value = entriesMap.map(
        (key, value) => MapEntry(key, DiaryEntry.fromJson(value)),
      );
    }
  }

  Future<void> _saveEntries() async {
    final entriesMap = _entries.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    await _prefs.setString(_storageKey, json.encode(entriesMap));
  }

  String _getKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> saveDiaryEntry(DiaryEntry entry) async {
    final key = _getKey(entry.date);
    _entries[key] = entry;
    await _saveEntries();
  }

  DiaryEntry? getDiaryEntry(DateTime date) {
    final key = _getKey(date);
    return _entries[key];
  }

  List<DiaryEntry> getEntriesForMonth(DateTime month) {
    return _entries.values.where((entry) =>
      entry.date.year == month.year && entry.date.month == month.month
    ).toList();
  }

  void printAllDiaries() {
    print('=== 저장된 모든 일기 ===');
    _entries.values.forEach((diary) {
      print('날짜: ${diary.date}');
      print('내용: ${diary.content}');
      print('감정: ${diary.emotion}');
      print('선택된 스타일: ${diary.style}');
      print('------------------------');
    });
  }

  void printDiaryForDate(DateTime date) {
    final key = _getKey(date);
    final diary = _entries[key];
    if (diary != null) {
      print('=== ${date} 일기 ===');
      print('내용: ${diary.content}');
      print('감정: ${diary.emotion}');
      print('선택된 스타일: ${diary.style}');
    } else {
      print('${date}에 저장된 일기가 없습니다.');
    }
  }
}