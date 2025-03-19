class DiaryEntry {
  final String username;
  final DateTime date;
  final String content;
  final String emotion;
  final List<String> hashtags;
  final String imageUrl;
  final String style;
  final String keywords;

  DiaryEntry({
    required this.username,
    required this.date,
    required this.content,
    required this.emotion,
    required this.hashtags,
    required this.imageUrl,
    required this.style,
    required this.keywords,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      username: json['username'],
      date: DateTime.parse(json['date']),
      content: json['content'],
      emotion: json['emotion'],
      hashtags: List<String>.from(json['hashtags']),
      imageUrl: json['imageUrl'],
      style: json['style'],
      keywords: json['keywords'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'date': date.toIso8601String(),
      'content': content,
      'emotion': emotion,
      'hashtags': hashtags,
      'imageUrl': imageUrl,
      'style': style,
      'keywords': keywords,
    };
  }
}
