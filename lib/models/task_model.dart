import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final ParseObject? parseObject;
  
  // New V2 Fields
  final String? courseName;
  final String? courseColorHex;
  final double weight;
  final DateTime? dueDate;
  final String status; // 'todo', 'in_progress', 'completed'
  final bool isRecurring;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.createdAt,
    this.parseObject,
    this.courseName,
    this.courseColorHex,
    this.weight = 0.0,
    this.dueDate,
    this.status = 'todo',
    this.isRecurring = false,
  });

  Color? get courseColor {
    if (courseColorHex == null || courseColorHex!.isEmpty) return null;
    try {
      return Color(int.parse(courseColorHex!.replaceFirst('#', '0xff')));
    } catch (e) {
      return null;
    }
  }

  int? get daysRemaining {
    if (dueDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due.difference(today).inDays;
  }

  factory TaskModel.fromParse(ParseObject object) {
    // If it was completed in V1, ensure status reflects that
    final bool isDone = object.get<bool>('isCompleted') ?? false;
    String currentStatus = object.get<String>('status') ?? (isDone ? 'completed' : 'todo');

    return TaskModel(
      id: object.objectId ?? '',
      title: object.get<String>('title') ?? '',
      description: object.get<String>('description') ?? '',
      isCompleted: isDone,
      createdAt: object.createdAt ?? DateTime.now(),
      parseObject: object,
      courseName: object.get<String>('courseName'),
      courseColorHex: object.get<String>('courseColorHex'),
      weight: (object.get<num>('weight') ?? 0.0).toDouble(),
      dueDate: object.get<DateTime>('dueDate'),
      status: currentStatus,
      isRecurring: object.get<bool>('isRecurring') ?? false,
    );
  }
}
