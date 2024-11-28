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
    title: '야간 순찰',
    description: '건물 내외부 야간 순찰 및 보안 점검',
    assignee: '이순찰',
    priority: Priority.high,
    taskType: TaskType.regular,
    startTime: DateTime.parse('2024-01-15 22:00:00'),
    endTime: DateTime.parse('2024-01-16 06:00:00'),
    author: '박관리',
  ),

  Task(
    id: '3',
    title: 'CCTV 모니터링',
    description: '전체 구역 CCTV 실시간 모니터링 및 이상 상황 기록',
    assignee: '김감시',
    priority: Priority.high,
    taskType: TaskType.regular,
    startTime: DateTime.parse('2024-01-15 14:00:00'),
    endTime: DateTime.parse('2024-01-15 22:00:00'),
    author: '박관리',
  ),

  Task(
    id: '4',
    title: '주차관리',
    description: '방문차량 확인 및 주차질서 관리, 불법주차 단속',
    assignee: '정주차',
    priority: Priority.medium,
    taskType: TaskType.regular,
    startTime: DateTime.parse('2024-01-15 09:00:00'),
    endTime: DateTime.parse('2024-01-15 18:00:00'),
    author: '박관리',
  ),

  Task(
    id: '5',
    title: '화재경보기 점검',
    description: '전체 구역 화재경보기 작동 상태 점검 및 보고',
    assignee: '최안전',
    priority: Priority.high,
    taskType: TaskType.irregular,
    startTime: DateTime.parse('2024-01-16 10:00:00'),
    endTime: DateTime.parse('2024-01-16 12:00:00'),
    author: '박관리',
  ),

  Task(
    id: '6',
    title: '출입자 통제',
    description: '방문객 확인 및 출입증 발급, 출입 기록 관리',
    assignee: '강출입',
    priority: Priority.medium,
    taskType: TaskType.regular,
    startTime: DateTime.parse('2024-01-15 08:00:00'),
    endTime: DateTime.parse('2024-01-15 17:00:00'),
    author: '박관리',
  ),
];