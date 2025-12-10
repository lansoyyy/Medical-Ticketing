import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentStatus { scheduled, confirmed, completed, cancelled, noShow }

class AppointmentModel {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String? department;
  final DateTime appointmentDate;
  final String timeSlot;
  final AppointmentStatus status;
  final String? reason;
  final String? notes;
  final DateTime createdAt;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    this.department,
    required this.appointmentDate,
    required this.timeSlot,
    required this.status,
    this.reason,
    this.notes,
    required this.createdAt,
  });

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      department: data['department'],
      appointmentDate:
          (data['appointmentDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      timeSlot: data['timeSlot'] ?? '',
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => AppointmentStatus.scheduled,
      ),
      reason: data['reason'],
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'department': department,
      'appointmentDate': Timestamp.fromDate(appointmentDate),
      'timeSlot': timeSlot,
      'status': status.name,
      'reason': reason,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? doctorId,
    String? doctorName,
    String? department,
    DateTime? appointmentDate,
    String? timeSlot,
    AppointmentStatus? status,
    String? reason,
    String? notes,
    DateTime? createdAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      department: department ?? this.department,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get statusDisplay {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Scheduled';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.noShow:
        return 'No Show';
    }
  }
}
