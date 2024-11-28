enum Priority { high, medium, low }
enum TaskType { regular, irregular }

class Task {
  final String id;
  final String title;
  final String description;
  final String assignee;
  final Priority priority;
  final TaskType taskType;
  final DateTime startTime;
  final DateTime endTime;
  final String author;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.assignee,
    required this.priority,
    required this.taskType,
    required this.startTime,
    required this.endTime,
    required this.author,
  });

  // JSON 직렬화를 위한 팩토리 메서드
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      assignee: json['assignee'],
      priority: Priority.values.byName(json['priority']),
      taskType: TaskType.values.byName(json['taskType']),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      author: json['author'],
    );
  }

  // JSON 직렬화를 위한 메서드
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assignee': assignee,
      'priority': priority.name,
      'taskType': taskType.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'author': author,
    };
  }
}

// 목업 데이터 예시
final List<Task> mockTasks = [
  Task(
    id: '1',
    title: '주간 보고서 작성',
    description: '이번 주 업무 진행상황 보고서 작성',
    assignee: '홍길동',
    priority: Priority.high,
    taskType: TaskType.regular,
    startTime: DateTime.parse('2024-01-15 09:00:00'),
    endTime: DateTime.parse('2024-01-15 18:00:00'),
    author: '김관리',
  ),
  Task(
    id: '2',
    title: '고객 미팅',
    description: '신규 프로젝트 관련 고객 미팅',
    assignee: '김철수',
    priority: Priority.medium,
    taskType: TaskType.irregular,
    startTime: DateTime.parse('2024-01-16 14:00:00'),
    endTime: DateTime.parse('2024-01-16 16:00:00'),
    author: '박팀장',
  ),
  // 추가 목업 데이터...
];