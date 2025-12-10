import 'package:cloud_firestore/cloud_firestore.dart';

enum AuditAction {
  userCreated,
  userUpdated,
  userDeleted,
  userLogin,
  userLogout,
  ticketCreated,
  ticketUpdated,
  ticketCompleted,
  ticketCancelled,
  appointmentCreated,
  appointmentUpdated,
  appointmentCancelled,
  consultationCreated,
  consultationUpdated,
  systemConfigUpdated,
  other
}

class AuditLogModel {
  final String id;
  final String userId;
  final String userName;
  final String userRole;
  final AuditAction action;
  final String description;
  final String? targetId;
  final String? targetType;
  final Map<String, dynamic>? details;
  final String? ipAddress;
  final DateTime createdAt;

  AuditLogModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.action,
    required this.description,
    this.targetId,
    this.targetType,
    this.details,
    this.ipAddress,
    required this.createdAt,
  });

  factory AuditLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AuditLogModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userRole: data['userRole'] ?? '',
      action: AuditAction.values.firstWhere(
        (e) => e.name == data['action'],
        orElse: () => AuditAction.other,
      ),
      description: data['description'] ?? '',
      targetId: data['targetId'],
      targetType: data['targetType'],
      details: data['details'] != null
          ? Map<String, dynamic>.from(data['details'])
          : null,
      ipAddress: data['ipAddress'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'action': action.name,
      'description': description,
      'targetId': targetId,
      'targetType': targetType,
      'details': details,
      'ipAddress': ipAddress,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String get actionDisplay {
    switch (action) {
      case AuditAction.userCreated:
        return 'User Created';
      case AuditAction.userUpdated:
        return 'User Updated';
      case AuditAction.userDeleted:
        return 'User Deleted';
      case AuditAction.userLogin:
        return 'User Login';
      case AuditAction.userLogout:
        return 'User Logout';
      case AuditAction.ticketCreated:
        return 'Ticket Created';
      case AuditAction.ticketUpdated:
        return 'Ticket Updated';
      case AuditAction.ticketCompleted:
        return 'Ticket Completed';
      case AuditAction.ticketCancelled:
        return 'Ticket Cancelled';
      case AuditAction.appointmentCreated:
        return 'Appointment Created';
      case AuditAction.appointmentUpdated:
        return 'Appointment Updated';
      case AuditAction.appointmentCancelled:
        return 'Appointment Cancelled';
      case AuditAction.consultationCreated:
        return 'Consultation Created';
      case AuditAction.consultationUpdated:
        return 'Consultation Updated';
      case AuditAction.systemConfigUpdated:
        return 'System Config Updated';
      case AuditAction.other:
        return 'Other';
    }
  }
}
