/**
 * Student Numbers: 221049921, 221050534, 222010648, 221014841
 * Student Names  : Kwanele Biyase, Motheo Sekgweleo, Thapelo Sikithi, Paki Gabriel Sekotlo
 * Question: Auth ViewModel
 */

import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/user_role.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  UserRole? _role;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserRole? get role => _role;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await SupabaseService.signIn(email, password);
      final roleStr = await SupabaseService.getUserRole();
      if (roleStr == 'admin') {
        _role = UserRole.admin;
      } else {
        _role = UserRole.student;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await SupabaseService.signOut();
    _role = null;
    notifyListeners();
  }
}// Motheo Sekgweleo filler at 2026-05-09 15:48:07
