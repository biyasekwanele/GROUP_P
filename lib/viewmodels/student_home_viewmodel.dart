/**
 * Student Numbers: 221049921, 221050534, 222010648, 221014841
 * Student Names  : Kwanele Biyase, Motheo Sekgweleo, Thapelo Sikithi, Paki Gabriel Sekotlo
 * Question: Student Home ViewModel
 */

import 'package:flutter/material.dart';
import '../models/application.dart';
import '../services/supabase_service.dart';

class StudentHomeViewModel extends ChangeNotifier {
  List<ApplicationModel> _applications = [];
  bool _isLoading = false;
  String? _error;

  List<ApplicationModel> get applications => _applications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadApplications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _applications = await SupabaseService.getStudentApplications();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}