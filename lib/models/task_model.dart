import 'dart:convert';

class Task {
  int? id;
  String title;
  String description;
  DateTime dueDate;
  bool isCompleted;
  String repeat; // 'none', 'daily', 'weekly'
  List<SubTask> subtasks;
  String? notificationSound;
  String priority; // 'ALPHA', 'BETA', 'GAMMA'

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.repeat = 'none',
    this.subtasks = const [],
    this.notificationSound,
    this.priority = 'BETA',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'repeat': repeat,
      'subtasks': jsonEncode(subtasks.map((e) => e.toMap()).toList()),
      'notificationSound': notificationSound,
      'priority': priority,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      isCompleted: map['isCompleted'] == 1,
      repeat: map['repeat'],
      subtasks: (jsonDecode(map['subtasks'] ?? '[]') as List)
          .map((e) => SubTask.fromMap(e))
          .toList(),
      notificationSound: map['notificationSound'],
      priority: map['priority'] ?? 'BETA',
    );
  }

  double get progress {
    if (subtasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    int completedCount = subtasks.where((s) => s.isCompleted).length;
    return completedCount / subtasks.length;
  }
}

class SubTask {
  String title;
  bool isCompleted;

  SubTask({required this.title, this.isCompleted = false});

  Map<String, dynamic> toMap() {
    return {'title': title, 'isCompleted': isCompleted};
  }

  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(title: map['title'], isCompleted: map['isCompleted']);
  }
}
