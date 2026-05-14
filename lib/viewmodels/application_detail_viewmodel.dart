/**
 * Student Numbers: 221049921, 221050534, 222010648, 221014841
 * Student Names  : Kwanele Biyase, Motheo Sekgweleo, Thapelo Sikithi, Paki Gabriel Sekotlo
 * Question: Application Detail ViewModel
 */

import 'package:flutter/material.dart';
import '../models/application.dart';
import '../services/supabase_service.dart';

class ApplicationDetailViewModel extends ChangeNotifier {
  ApplicationModel? _application;
  bool _isLoading = false;
  String? _error;

  ApplicationModel? get application => _application;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadApplication(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _application = await SupabaseService.getApplicationById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteApplication(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await SupabaseService.deleteApplication(id);
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

  bool get canEdit => _application?.status == 'pending';
}
