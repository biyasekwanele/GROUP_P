/**
 * Student Numbers: 221049921, 221050534, 222010648, 221014841
 * Student Names  : Kwanele Biyase, Motheo Sekgweleo, Thapelo Sikithi, Paki Gabriel Sekotlo
 * Question: Application Model
 */

class ApplicationModel {
  final String id;
  final String studentId;
  final int yearOfStudy;
  final String module1Level;
  final String module1Name;
  final String? module2Level;
  final String? module2Name;
  final bool eligibilityConfirmed;
  final String? documentUrl;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ApplicationModel({
    required this.id,
    required this.studentId,
    required this.yearOfStudy,
    required this.module1Level,
    required this.module1Name,
    this.module2Level,
    this.module2Name,
    required this.eligibilityConfirmed,
    this.documentUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApplicationModel.fromMap(Map<String, dynamic> map) {
    return ApplicationModel(
      id: map['id'] as String,
      studentId: map['student_id'] as String,
      yearOfStudy: map['year_of_study'] as int,
      module1Level: map['module1_level'] as String,
      module1Name: map['module1_name'] as String,
      module2Level: map['module2_level'] as String?,
      module2Name: map['module2_name'] as String?,
      eligibilityConfirmed: map['eligibility_confirmed'] as bool,
      documentUrl: map['document_url'] as String?,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'year_of_study': yearOfStudy,
      'module1_level': module1Level,
      'module1_name': module1Name,
      'module2_level': module2Level,
      'module2_name': module2Name,
      'eligibility_confirmed': eligibilityConfirmed,
      'document_url': documentUrl,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

