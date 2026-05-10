import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/reschedule_assistant.dart';
import 'add_edit_task_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/task_model.dart';
import '../core/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).fetchTasks();
    });
  }

  void _showTaskDialog({TaskModel? task}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditTaskScreen(task: task),
    );
  }

  void _showTriage(List<TaskModel> overdueTasks) {
    showDialog(
      context: context,
      builder: (context) => RescheduleAssistant(overdueTasks: overdueTasks),
    );
  }

// Helper method to build task lists for each tab
  Widget _buildTaskList(List<TaskModel> tasks, TaskProvider provider) {
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          'Nothing here!',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),
        ).animate().fadeIn(),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => provider.fetchTasks(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskCard(
            task: task,
            onTap: () => _showTaskDialog(task: task),
            onStatusChange: (newStatus) {
              if (newStatus != null) {
                provider.updateTask(task, status: newStatus);
              }
            },
            onDelete: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Task'),
                  content: const Text('Are you sure you want to delete this task?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true) provider.deleteTask(task.id);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Status Dashboard'),
          bottom: const TabBar(
            indicatorColor: AppTheme.secondary,
            tabs: [
              Tab(text: 'To Do'),
              Tab(text: 'In Progress'),
              Tab(text: 'Done'),
            ],
          ),
          actions: [
            Consumer<TaskProvider>(
              builder: (context, provider, child) {
                final overdue = provider.tasks.where((t) => t.daysRemaining != null && t.daysRemaining! < 0 && t.status != 'completed').toList();
                if (overdue.isNotEmpty) {
                  return IconButton(
                    icon: const Icon(Icons.warning_amber_rounded, color: AppTheme.error),
                    tooltip: 'Triage Overdue',
                    onPressed: () => _showTriage(overdue),
                  ).animate().shake(hz: 4, curve: Curves.easeInOutCubic);
                }
                return const SizedBox();
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async => await authProvider.logout(),
            ),
          ],
        ),
        body: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            if (taskProvider.isLoading && taskProvider.tasks.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return TabBarView(
              children: [
                _buildTaskList(taskProvider.todoTasks, taskProvider),
                _buildTaskList(taskProvider.inProgressTasks, taskProvider),
                _buildTaskList(taskProvider.completedTasks, taskProvider),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showTaskDialog(),
          icon: const Icon(Icons.add),
          label: const Text('New Task'),
        ).animate().scale(delay: 500.ms, curve: Curves.easeOutBack),
      ),
    );
  }
}
