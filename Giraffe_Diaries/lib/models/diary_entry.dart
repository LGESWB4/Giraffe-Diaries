import 'package:flutter/material.dart';

class DiaryEntry {
  final String nickname;
  final DateTime date;
  final String content;
  final String emotion;
  final List<String> hashtags;
  final String imageUrl;
  final String style;

  DiaryEntry({
    required this.nickname,
    required this.date,
    required this.content,
    required this.emotion,
    required this.hashtags,
    required this.imageUrl,
    required this.style,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      nickname: json['nickname'],
      date: DateTime.parse(json['date']),
      content: json['content'],
      emotion: json['emotion'],
      hashtags: List<String>.from(json['hashtags']),
      imageUrl: json['imageUrl'],
      style: json['style'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname' : nickname,
      'date': date.toIso8601String(),
      'content': content,
      'emotion': emotion,
      'hashtags': hashtags,
      'imageUrl': imageUrl,
      'style': style,
    };
  }
}