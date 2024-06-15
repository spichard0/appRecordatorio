// models/task_manager.dart
import 'task.dart';

class TaskManager {
  List<Task> tasks = [];

  void addTask(Task task) {
    tasks.add(task);
  }

  void deleteTask(Task task) {
    tasks.remove(task);
  }

  void clearTasks() {
    tasks.clear();
  }
}
