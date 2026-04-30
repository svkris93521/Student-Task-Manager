import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/parse_service.dart';

class TaskProvider extends ChangeNotifier {
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Getters for Status Dashboard
  List<TaskModel> get todoTasks => _tasks.where((t) => t.status == 'todo').toList();
  List<TaskModel> get inProgressTasks => _tasks.where((t) => t.status == 'in_progress').toList();
  List<TaskModel> get completedTasks => _tasks.where((t) => t.status == 'completed').toList();

  Future<void> fetchTasks() async {
    _setLoading(true);
    _clearError();
    try {
      _tasks = await ParseService.getTasks();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createTask(
    String title, 
    String description, {
    String? courseName,
    String? courseColorHex,
    double weight = 0.0,
    DateTime? dueDate,
    String status = 'todo',
    bool isRecurring = false,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final newTask = await ParseService.createTask(
        title, 
        description,
        courseName: courseName,
        courseColorHex: courseColorHex,
        weight: weight,
        dueDate: dueDate,
        status: status,
        isRecurring: isRecurring,
      );
      _tasks.insert(0, newTask);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateTask(
    TaskModel task, {
    String? title, 
    String? description, 
    bool? isCompleted,
    String? courseName,
    String? courseColorHex,
    double? weight,
    DateTime? dueDate,
    String? status,
    bool? isRecurring,
  }) async {
    _clearError();
    try {
      final updatedTask = await ParseService.updateTask(
        task,
        newTitle: title,
        newDescription: description,
        newIsCompleted: isCompleted,
        courseName: courseName,
        courseColorHex: courseColorHex,
        weight: weight,
        dueDate: dueDate,
        status: status,
        isRecurring: isRecurring,
      );
      
      final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(String id) async {
    _clearError();
    try {
      await ParseService.deleteTask(id);
      _tasks.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
