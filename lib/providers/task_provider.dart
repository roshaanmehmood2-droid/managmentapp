import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../database/db_helper.dart';
import '../services/notification_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isDarkMode = false;

  List<Task> get tasks => _tasks;
  bool get isDarkMode => _isDarkMode;

  List<Task> get activeTasks => _tasks.where((task) => !task.isCompleted).toList();

  List<Task> get todayTasks {
    final now = DateTime.now();
    return _tasks.where((task) {
      return !task.isCompleted &&
          task.dueDate.year == now.year &&
          task.dueDate.month == now.month &&
          task.dueDate.day == now.day;
    }).toList();
  }

  List<Task> get upcomingTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _tasks.where((task) {
      final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      return !task.isCompleted && taskDate.isAfter(today);
    }).toList();
  }

  List<Task> get completedTasks => _tasks.where((task) => task.isCompleted).toList();
  List<Task> get repeatedTasks => _tasks.where((task) => task.repeat != 'none').toList();

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  Future<void> loadTasks() async {
    _tasks = await DBHelper().getTasks();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    int id = await DBHelper().insertTask(task);
    task.id = id;
    
    await NotificationService().showInstantNotification(
      'OPERATION_INITIALIZED',
      'Protocol "${task.title}" has been added to system.',
    );
    
    await NotificationService().scheduleTaskNotification(task);
    await loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await DBHelper().updateTask(task);
    await NotificationService().scheduleTaskNotification(task);
    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await DBHelper().deleteTask(id);
    await NotificationService().cancelNotification(id);
    await loadTasks();
  }

  Future<void> toggleTaskCompletion(Task task) async {
    task.isCompleted = !task.isCompleted;
    if (task.isCompleted) {
      await NotificationService().cancelNotification(task.id!);
      
      await NotificationService().showInstantNotification(
        'PROTOCOL_COMPLETED',
        'Operation "${task.title}" successfully finalized.',
      );

      if (task.repeat != 'none') {
        DateTime nextDate;
        if (task.repeat == 'daily') {
          nextDate = task.dueDate.add(const Duration(days: 1));
        } else {
          nextDate = task.dueDate.add(const Duration(days: 7));
        }
        final newTask = Task(
          title: task.title,
          description: task.description,
          dueDate: nextDate,
          repeat: task.repeat,
          subtasks: task.subtasks.map((s) => SubTask(title: s.title)).toList(),
          priority: task.priority,
        );
        await addTask(newTask);
      }
    } else {
      await NotificationService().scheduleTaskNotification(task);
    }
    await updateTask(task);
  }
}
