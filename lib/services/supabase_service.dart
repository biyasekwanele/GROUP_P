/**
 * Student Numbers: 221049921, 221050534, 222010648, 221014841
 * Student Names  : Kwanele Biyase, Motheo Sekgweleo, Thapelo Sikithi, Paki Gabriel Sekotlo
 * Question: Supabase Service
 */



import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application.dart';
import '../utils/constants.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  static SupabaseClient get client => _client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Constants.supabaseUrl,
      anonKey: Constants.supabaseAnonKey,
    );
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static User? get currentUser => _client.auth.currentUser;

  static Future<String?> getUserRole() async {
    final user = currentUser;
    if (user == null) return null;
    final response = await _client
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .single();
    return response['role'] as String?;
  }

  static Future<List<ApplicationModel>> getStudentApplications() async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');
    final response = await _client
        .from('applications')
        .select()
        .eq('student_id', user.id)
        .order('created_at', ascending: false);
    return (response as List).map((e) => ApplicationModel.fromMap(e)).toList();
  }

  static Future<ApplicationModel?> getApplicationById(String id) async {
    final response = await _client
        .from('applications')
        .select()
        .eq('id', id)
        .single();
    return ApplicationModel.fromMap(response);
  }

  static Future<bool> hasExistingApplication() async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');
    final response = await _client
        .from('applications')
        .select('id')
        .eq('student_id', user.id)
        .limit(1);
    return (response as List).isNotEmpty;
  }

  static Future<ApplicationModel> createApplication({
    required int yearOfStudy,
    required String module1Level,
    required String module1Name,
    String? module2Level,
    String? module2Name,
    required bool eligibilityConfirmed,
    PlatformFile? document,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');

    final hasExisting = await hasExistingApplication();
    if (hasExisting) throw Exception('Student already has an application');

    String? documentUrl;
    if (document != null && document.bytes != null) {
      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}_${document.name}';
      await _client.storage.from('documents').uploadBinary(fileName, document.bytes!);
      documentUrl = _client.storage.from('documents').getPublicUrl(fileName);
    }

    final now = DateTime.now();
    final data = {
      'student_id': user.id,
      'year_of_study': yearOfStudy,
      'module1_level': module1Level,
      'module1_name': module1Name,
      'module2_level': module2Level,
      'module2_name': module2Name,
      'eligibility_confirmed': eligibilityConfirmed,
      'document_url': documentUrl,
      'status': 'pending',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    final response = await _client.from('applications').insert(data).select().single();
    return ApplicationModel.fromMap(response);
  }

  static Future<ApplicationModel> updateApplication({
    required String id,
    required int yearOfStudy,
    required String module1Level,
    required String module1Name,
    String? module2Level,
    String? module2Name,
    required bool eligibilityConfirmed,
    PlatformFile? document,
    String? existingDocumentUrl,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');

    String? documentUrl = existingDocumentUrl;
    if (document != null && document.bytes != null) {
      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}_${document.name}';
      await _client.storage.from('documents').uploadBinary(fileName, document.bytes!);
      documentUrl = _client.storage.from('documents').getPublicUrl(fileName);
    }

    final now = DateTime.now();
    final data = {
      'year_of_study': yearOfStudy,
      'module1_level': module1Level,
      'module1_name': module1Name,
      'module2_level': module2Level,
      'module2_name': module2Name,
      'eligibility_confirmed': eligibilityConfirmed,
      'document_url': documentUrl,
      'updated_at': now.toIso8601String(),
    };

    final response = await _client
        .from('applications')
        .update(data)
        .eq('id', id)
        .eq('student_id', user.id)
        .select()
        .single();
    return ApplicationModel.fromMap(response);
  }

  static Future<void> deleteApplication(String id) async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');
    await _client
        .from('applications')
        .delete()
        .eq('id', id)
        .eq('student_id', user.id);
  }

  static Future<List<ApplicationModel>> getAllApplications() async {
    final response = await _client
        .from('applications')
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((e) => ApplicationModel.fromMap(e)).toList();
  }

  static Future<void> updateApplicationStatus(String id, String status) async {
    await _client
        .from('applications')
        .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }

  static Future<void> adminDeleteApplication(String id) async {
    await _client.from('applications').delete().eq('id', id);
  }
}// kwanele Biyase filler at 2026-05-04 11:23:47
// Paki Gabriel Sekotlo filler at 2026-05-08 11:00:40
