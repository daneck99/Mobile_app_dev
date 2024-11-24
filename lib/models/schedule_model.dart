
class Schedule {
  final int id;
  final String content;
  final DateTime date;
  final int startTime;
  final int endTime;
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
}
