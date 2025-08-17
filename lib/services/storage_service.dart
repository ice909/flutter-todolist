import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';

abstract class StorageService {
  Future<List<Task>> getTasks();
  Future<Task> addTask(String title, {String? parentId});
  Future<void> saveTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
  Future<void> clearAllTasks();
}

class SharedPreferencesStorage implements StorageService {
  static const String _tasksKey = 'tasks';

  @override
  Future<List<Task>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString(_tasksKey);

    if (tasksJson == null) return [];

    final List<dynamic> tasksList = json.decode(tasksJson);
    // sort by SortOrder Desc
    tasksList.sort((a, b) => b['sortOrder'].compareTo(a['sortOrder']));
    return tasksList.map((json) => Task.fromJson(json)).toList();
  }

  // get max sortOrder
  Future<int> _getMaxSortOrder() async {
    final tasks = await getTasks();
    if (tasks.isEmpty) return -2000000000000;
    return tasks.map((task) => task.sortOrder).reduce((a, b) => a > b ? a : b);
  }

  @override
  Future<Task> addTask(String title, {String? parentId} ) async {
    final newTask = Task(
      id: const Uuid().v4(),
      title: title.trim(),
      parentId: parentId ?? "",
      content: "",
      completed: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      expanded: false,
      sortOrder: await _getMaxSortOrder() + 1000,
    );

    // 保存到存储
    final tasks = await getTasks();
    // add to list top
    tasks.insert(0, newTask);
    await _saveTasks(tasks);

    return newTask;
  }

  @override
  Future<void> saveTask(Task task) async {
    final tasks = await getTasks();

    // 生成新的ID
    task.id = Uuid().v4();

    tasks.add(task);
    await _saveTasks(tasks);
  }

  @override
  Future<void> updateTask(Task task) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);

    if (index != -1) {
      tasks[index] = task;
      await _saveTasks(tasks);
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    final tasks = await getTasks();
    tasks.removeWhere((task) => task.id == id);
    await _saveTasks(tasks);
  }

  @override
  Future<void> clearAllTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksKey);
  }

  Future<void> _saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = json.encode(tasks.map((task) => task.toJson()).toList());
    await prefs.setString(_tasksKey, tasksJson);
  }
}

