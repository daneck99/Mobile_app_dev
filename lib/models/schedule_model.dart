class Schedule {
  final String id; // Firestore에서는 id를 String으로 관리합니다.
  final String content;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final int colorID;
  final DateTime createdAt;

  Schedule({
    required this.id,
    required this.content,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.colorID,
    required this.createdAt,
  });

  // JSON에서 Schedule 객체로 변환
  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      content: json['content'],
      date: DateTime.parse(json['date']),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      colorID: json['colorID'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Schedule 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'date': date.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'colorID': colorID,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
