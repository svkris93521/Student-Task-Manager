import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../core/theme.dart';

class RescheduleAssistant extends StatefulWidget {
  final List<TaskModel> overdueTasks;

  const RescheduleAssistant({super.key, required this.overdueTasks});

  @override
  State<RescheduleAssistant> createState() => _RescheduleAssistantState();
}

class _RescheduleAssistantState extends State<RescheduleAssistant> {
  bool _isProcessing = false;

  void _reschedule(DateTime newDate) async {
    setState(() => _isProcessing = true);
    final provider = Provider.of<TaskProvider>(context, listen: false);

    for (var task in widget.overdueTasks) {
      await provider.updateTask(task, dueDate: newDate);
    }

    if (mounted) {
      setState(() => _isProcessing = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Overdue tasks rescheduled!'), backgroundColor: AppTheme.secondary),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppTheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 64, color: AppTheme.error),
            const SizedBox(height: 16),
            Text(
              'Overdue Triage',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              'You have ${widget.overdueTasks.length} overdue tasks. Don\'t stress! Let\'s reschedule them.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            if (_isProcessing)
              const CircularProgressIndicator()
            else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _reschedule(DateTime.now()),
                  child: const Text('Move to Today'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondary),
                  onPressed: () => _reschedule(DateTime.now().add(const Duration(days: 1))),
                  child: const Text('Move to Tomorrow', style: TextStyle(color: Colors.black)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => _reschedule(DateTime.now().add(const Duration(days: 7))),
                  child: const Text('Push to Next Week'),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
