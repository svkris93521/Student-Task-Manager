import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../core/theme.dart';

class AddEditTaskScreen extends StatefulWidget {
  final TaskModel? task;

  const AddEditTaskScreen({
    super.key,
    this.task,
  });

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _courseController;
  
  double _weight = 0.0;
  DateTime? _dueDate;
  String _status = 'todo';
  String _selectedColor = '#6C63FF'; // Default Primary
  bool _isSaving = false;

  final List<String> _colors = [
    '#6C63FF', // Primary
    '#03DAC6', // Secondary
    '#CF6679', // Error/Red
    '#FFB74D', // Orange
    '#64B5F6', // Blue
    '#81C784', // Green
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title);
    _descController = TextEditingController(text: widget.task?.description);
    _courseController = TextEditingController(text: widget.task?.courseName);
    
    if (widget.task != null) {
      _weight = widget.task!.weight;
      _dueDate = widget.task!.dueDate;
      _status = widget.task!.status;
      if (widget.task!.courseColorHex != null && _colors.contains(widget.task!.courseColorHex)) {
         _selectedColor = widget.task!.courseColorHex!;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    bool success;

    if (widget.task == null) {
      // Create new
      success = await taskProvider.createTask(
        _titleController.text.trim(),
        _descController.text.trim(),
        courseName: _courseController.text.trim().isEmpty ? null : _courseController.text.trim(),
        courseColorHex: _selectedColor,
        weight: _weight,
        dueDate: _dueDate,
        status: _status,
      );
    } else {
      // Update existing
      success = await taskProvider.updateTask(
        widget.task!,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        courseName: _courseController.text.trim().isEmpty ? null : _courseController.text.trim(),
        courseColorHex: _selectedColor,
        weight: _weight,
        dueDate: _dueDate,
        status: _status,
      );
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(taskProvider.error ?? 'Failed to save task'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: bottomPadding + 24),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.task == null ? 'Create New Task' : 'Edit Task',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Task Title', hintText: 'e.g., Complete Assignment'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description', hintText: 'Details about the task...'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _courseController,
                      decoration: const InputDecoration(labelText: 'Course Tag (Optional)', hintText: 'e.g., CS101'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: _colors.map((colorHex) {
                  final color = Color(int.parse(colorHex.replaceFirst('#', '0xff')));
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = colorHex),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor == colorHex ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Due Date'),
                subtitle: Text(_dueDate == null ? 'Not set' : DateFormat('MMM dd, yyyy').format(_dueDate!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Priority Weight: '),
                  Expanded(
                    child: Slider(
                      value: _weight,
                      min: 0,
                      max: 100,
                      divisions: 20,
                      label: '${_weight.round()}%',
                      onChanged: (val) => setState(() => _weight = val),
                      activeColor: AppTheme.secondary,
                    ),
                  ),
                  Text('${_weight.round()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'todo', child: Text('To Do')),
                  DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                  DropdownMenuItem(value: 'completed', child: Text('Completed')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
              ),
              const SizedBox(height: 32),
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveTask,
                      child: Text(widget.task == null ? 'Create Task' : 'Save Changes'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
