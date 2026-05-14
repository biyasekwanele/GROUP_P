/**
 * Student Numbers: 221049921, 221050534, 222010648, 221014841
 * Student Names  : Kwanele Biyase, Motheo Sekgweleo, Thapelo Sikithi, Paki Gabriel Sekotlo
 * Question: Application Form ViewModel
 */

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/supabase_service.dart';

class ApplicationFormViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  bool _hasExistingApplication = false;
  PlatformFile? _selectedFile;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasExistingApplication => _hasExistingApplication;
  PlatformFile? get selectedFile => _selectedFile;

  final List<String> academicLevels = [
    'First Year',
    'Second Year',
    'Third Year',
  ];
  final List<String> modules = [
    'TPG111D',
    'TPG121D',
    'TPG211D',
    'TPG221D',
    'TPG311C',
    'TPG316C',
    'TPG321C',
  ];

  Future<void> checkExistingApplication() async {
    try {
      _hasExistingApplication = await SupabaseService.hasExistingApplication();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> pickDocument() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      _selectedFile = result.files.first;
      notifyListeners();
    }
  }

  Future<bool> submitApplication({
    required int yearOfStudy,
    required String module1Level,
    required String module1Name,
    String? module2Level,
    String? module2Name,
    required bool eligibilityConfirmed,
    String? existingId,
    String? existingDocumentUrl,
  }) async {
    if (!eligibilityConfirmed) {
      _error = 'You must confirm eligibility';
      notifyListeners();
      return false;
    }

    if (module2Level != null && module2Name == null) {
      _error = 'Module 2 name is required when level is selected';
      notifyListeners();
      return false;
    }

    if (module2Name != null && module2Level == null) {
      _error = 'Module 2 level is required when name is selected';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (existingId != null) {
        await SupabaseService.updateApplication(
          id: existingId,
          yearOfStudy: yearOfStudy,
          module1Level: module1Level,
          module1Name: module1Name,
          module2Level: module2Level,
          module2Name: module2Name,
          eligibilityConfirmed: eligibilityConfirmed,
          document: _selectedFile,
          existingDocumentUrl: existingDocumentUrl,
        );
      } else {
        if (_hasExistingApplication) {
          throw Exception('You have already submitted an application');
        }
        await SupabaseService.createApplication(
          yearOfStudy: yearOfStudy,
          module1Level: module1Level,
          module1Name: module1Name,
          module2Level: module2Level,
          module2Name: module2Name,
          eligibilityConfirmed: eligibilityConfirmed,
          document: _selectedFile,
        );
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
}

