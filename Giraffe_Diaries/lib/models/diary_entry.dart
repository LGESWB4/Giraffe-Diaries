import 'package:flutter/material.dart';

class DiaryEntry {
  final DateTime date;
  final String content;
  final String emotion;
  final List<String> hashtags;

  DiaryEntry({
    required this.date,
    required this.content,
    required this.emotion,
    required this.hashtags,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      date: DateTime.parse(json['date']),
      content: json['content'],
      emotion: json['emotion'],
      hashtags: List<String>.from(json['hashtags']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'content': content,
      'emotion': emotion,
      'hashtags': hashtags,
    };
  }
}