import 'package:cloud_firestore/cloud_firestore.dart';

enum TicketStatus { waiting, called, inProgress, completed, cancelled, noShow }

enum TicketPriority { normal, priority, emergency }

class TicketModel {
  final String id;
  final String patientId;
  final String patientName;
  final int queueNumber;
  final TicketStatus status;
  final TicketPriority priority;
  final String? assignedDoctorId;
  final String? assignedDoctorName;
  final String? department;
  final String? chiefComplaint;
  final String? vitalSigns;
  final String? notes;
  final DateTime createdAt;
  final DateTime? calledAt;
  final DateTime? completedAt;

  TicketModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.queueNumber,
    required this.status,
    this.priority = TicketPriority.normal,
    this.assignedDoctorId,
    this.assignedDoctorName,
    this.department,
    this.chiefComplaint,
    this.vitalSigns,
    this.notes,
    required this.createdAt,
    this.calledAt,
    this.completedAt,
  });

  factory TicketModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TicketModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      queueNumber: data['queueNumber'] ?? 0,
      status: TicketStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TicketStatus.waiting,
      ),
      priority: TicketPriority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => TicketPriority.normal,
      ),
      assignedDoctorId: data['assignedDoctorId'],
      assignedDoctorName: data['assignedDoctorName'],
      department: data['department'],
      chiefComplaint: data['chiefComplaint'],
      vitalSigns: data['vitalSigns'],
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      calledAt: (data['calledAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'queueNumber': queueNumber,
      'status': status.name,
      'priority': priority.name,
      'assignedDoctorId': assignedDoctorId,
      'assignedDoctorName': assignedDoctorName,
      'department': department,
      'chiefComplaint': chiefComplaint,
      'vitalSigns': vitalSigns,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'calledAt': calledAt != null ? Timestamp.fromDate(calledAt!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  TicketModel copyWith({
    String? id,
    String? patientId,
    String? patientName,
    int? queueNumber,
    TicketStatus? status,
    TicketPriority? priority,
    String? assignedDoctorId,
    String? assignedDoctorName,
    String? department,
    String? chiefComplaint,
    String? vitalSigns,
    String? notes,
    DateTime? createdAt,
    DateTime? calledAt,
    DateTime? completedAt,
  }) {
    return TicketModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      queueNumber: queueNumber ?? this.queueNumber,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedDoctorId: assignedDoctorId ?? this.assignedDoctorId,
      assignedDoctorName: assignedDoctorName ?? this.assignedDoctorName,
      department: department ?? this.department,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      vitalSigns: vitalSigns ?? this.vitalSigns,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      calledAt: calledAt ?? this.calledAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  String get statusDisplay {
    switch (status) {
      case TicketStatus.waiting:
        return 'Waiting';
      case TicketStatus.called:
        return 'Called';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.completed:
        return 'Completed';
      case TicketStatus.cancelled:
        return 'Cancelled';
      case TicketStatus.noShow:
        return 'No Show';
    }
  }

  String get priorityDisplay {
    switch (priority) {
      case TicketPriority.normal:
        return 'Normal';
      case TicketPriority.priority:
        return 'Priority';
      case TicketPriority.emergency:
        return 'Emergency';
    }
  }
}
