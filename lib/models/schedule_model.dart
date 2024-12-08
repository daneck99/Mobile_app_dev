class Schedule {
  final String id; // Firestore document ID
  final String title;
  final String content;
  final String creator;
  final String assignee;
  final DateTime date; // Date of the schedule
  final DateTime startTime; // Start time of the schedule
  final DateTime endTime; // End time of the schedule
  final int colorID; // Color identifier for visual differentiation
  final DateTime createdAt; // When the schedule was created
  final String userId; // User ID of the creator/owner
  final bool isCompleted; // Whether the schedule is completed
  final DateTime? completedAt; // Timestamp for when the schedule was marked as completed
  final String? location; // Optional location for the schedule
  final List<String>? tags; // Tags for categorizing or filtering schedules

  Schedule({
    required this.id,
    required this.title,
    required this.content,
    required this.creator,
    required this.assignee,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.colorID,
    required this.createdAt,
    required this.userId,
    this.isCompleted = false, // Default to not completed
    this.completedAt,
    this.location,
    this.tags,
  });

  // Convert JSON to Schedule object
  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      title: json['title'],
      content: json['content'] ?? '',
      creator: json['creator'] ?? '',
      assignee: json['assignee'] ?? '',
      date: DateTime.parse(json['date']),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      colorID: json['colorID'],
      createdAt: DateTime.parse(json['createdAt']),
      userId: json['userId'],
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      location: json['location'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }

  // Convert Schedule object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'creator': creator,
      'assignee': assignee,
      'date': date.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'colorID': colorID,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'location': location,
      'tags': tags,
    };
  }
}
