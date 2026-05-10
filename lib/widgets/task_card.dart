import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/task_model.dart';
import '../core/theme.dart';
import '../screens/pomodoro_screen.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ValueChanged<String?> onStatusChange;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onDelete,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDone = task.status == 'completed';
    final int? daysLeft = task.daysRemaining;
    
    Color daysColor = AppTheme.primary;
    if (daysLeft != null) {
      if (daysLeft < 0) {
        daysColor = AppTheme.error;
      } else if (daysLeft <= 2) {
        daysColor = AppTheme.secondary;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (task.courseName != null && task.courseName!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: task.courseColor ?? AppTheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        task.courseName!,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    )
                  else
                    const SizedBox(),
                  
                  if (daysLeft != null && !isDone)
                    Text(
                      daysLeft < 0 ? 'Overdue' : (daysLeft == 0 ? 'Due Today' : '$daysLeft days left'),
                      style: TextStyle(color: daysColor, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: isDone,
                      onChanged: (val) => onStatusChange(val == true ? 'completed' : 'todo'),
                      activeColor: AppTheme.secondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                decoration: isDone ? TextDecoration.lineThrough : null,
                                color: isDone ? AppTheme.textSecondary.withValues(alpha: 0.5) : AppTheme.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: isDone ? AppTheme.textSecondary.withValues(alpha: 0.5) : AppTheme.textSecondary,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (task.weight > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Weight: ${task.weight.round()}%',
                              style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.timer_outlined, color: AppTheme.secondary),
                        tooltip: 'Start Focus Session',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PomodoroScreen(task: task)),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }
}
