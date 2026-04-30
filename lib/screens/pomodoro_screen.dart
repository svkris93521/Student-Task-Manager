import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/task_model.dart';
import '../core/theme.dart';

class PomodoroScreen extends StatefulWidget {
  final TaskModel task;

  const PomodoroScreen({super.key, required this.task});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  static const int _focusDurationSeconds = 25 * 60; // 25 minutes
  int _secondsRemaining = _focusDurationSeconds;
  Timer? _timer;
  bool _isRunning = false;

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _stopTimer();
        _showCompletionDialog();
      }
    });
  }

  void _pauseTimer() {
    setState(() => _isRunning = false);
    _timer?.cancel();
  }

  void _stopTimer() {
    _pauseTimer();
    setState(() => _secondsRemaining = _focusDurationSeconds);
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Focus Session Complete! 🎉'),
        content: const Text('Great job! Take a 5-minute break.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to Home
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    double progress = 1 - (_secondsRemaining / _focusDurationSeconds);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Focus Mode'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Focusing on:',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.textSecondary),
              ).animate().fadeIn(),
              const SizedBox(height: 8),
              Text(
                widget.task.title,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                textAlign: TextAlign.center,
              ).animate().fadeIn().slideY(begin: 0.2),
              const SizedBox(height: 64),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8, // Thinner for minimalist look
                      backgroundColor: AppTheme.surface,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    ),
                  ),
                  Text(
                    _formattedTime,
                    style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.white),
                  ).animate(target: _isRunning ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05)),
                ],
              ),
              const SizedBox(height: 64),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isRunning && _secondsRemaining != _focusDurationSeconds)
                    IconButton(
                      iconSize: 48,
                      color: AppTheme.error,
                      icon: const Icon(Icons.stop_circle_outlined),
                      onPressed: _stopTimer,
                    ).animate().scale(),
                  const SizedBox(width: 24),
                  IconButton(
                    iconSize: 80,
                    color: AppTheme.primary,
                    icon: Icon(_isRunning ? Icons.pause_circle_filled : Icons.play_circle_fill),
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                  ).animate().scale(curve: Curves.easeOutBack),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
