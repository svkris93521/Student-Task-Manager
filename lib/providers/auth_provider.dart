import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../services/parse_service.dart';

class AuthProvider extends ChangeNotifier {
  ParseUser? _currentUser;
  bool _isLoading = true;
  String? _error;

  ParseUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // Gamification Getters
  int get xp => _currentUser?.get<int>('xp') ?? 0;
  int get level => _currentUser?.get<int>('level') ?? 1;
  int get currentStreak => _currentUser?.get<int>('streak') ?? 0;

  AuthProvider() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    _setLoading(true);
    try {
      final user = await ParseService.getCurrentUser();
      if (user != null) {
        await _updateStreak(user);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      final user = await ParseService.loginUser(email, password);
      if (user != null) {
        await _updateStreak(user);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      final user = await ParseService.registerUser(email, password);
      if (user != null) {
        // Initialize stats
        user.set('xp', 0);
        user.set('level', 1);
        user.set('streak', 1);
        user.set('lastLoginDate', DateTime.now());
        await user.save();
        _currentUser = user;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await ParseService.logoutUser();
      _currentUser = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addXP(int amount) async {
    if (_currentUser == null) return;
    int newXP = xp + amount;
    int newLevel = (newXP ~/ 100) + 1; // Every 100 XP is a level

    _currentUser!.set('xp', newXP);
    _currentUser!.set('level', newLevel);
    await _currentUser!.save();
    notifyListeners();
  }

  Future<void> _updateStreak(ParseUser user) async {
    final lastLogin = user.get<DateTime>('lastLoginDate');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int streak = user.get<int>('streak') ?? 0;

    if (lastLogin != null) {
      final lastLoginDay = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);
      final difference = today.difference(lastLoginDay).inDays;

      if (difference == 1) {
        streak += 1;
      } else if (difference > 1) {
        streak = 1; // Reset streak if missed a day
      }
      // if 0, already logged in today, do nothing to streak
    } else {
      streak = 1;
    }

    user.set('streak', streak);
    user.set('lastLoginDate', now);
    
    // Attempt to save. If offline, this might fail, but that's okay for now.
    try {
      await user.save();
    } catch (_) {}
    
    _currentUser = user;
    notifyListeners();
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
