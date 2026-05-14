/**
 * Student Numbers: 221049921, 221050534, 222010648, 221014841
 * Student Names  : Kwanele Biyase, Motheo Sekgweleo, Thapelo Sikithi, Paki Gabriel Sekotlo
 * Question: Admin Dashboard ViewModel
 */

import 'package:flutter/material.dart';
import '../models/application.dart';
import '../services/supabase_service.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  List<ApplicationModel> _applications = [];
  List<ApplicationModel> _filteredApplications = [];
  bool _isLoading = false;
  String? _error;
  String _filterStatus = 'All';

  List<ApplicationModel> get applications => _filteredApplications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filterStatus => _filterStatus;

  Future<void> loadApplications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _applications = await SupabaseService.getAllApplications();
      _applyFilter();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String status) {
    _filterStatus = status;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_filterStatus == 'All') {
      _filteredApplications = List.from(_applications);
    } else {
      _filteredApplications = _applications
          .where((app) => app.status == _filterStatus.toLowerCase())
          .toList();
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await SupabaseService.updateApplicationStatus(id, status);
      await loadApplications();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteApplication(String id) async {
    try {
      await SupabaseService.adminDeleteApplication(id);
      await loadApplications();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
// kwanele Biyase filler at 2026-05-09 16:14:38
