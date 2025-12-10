import 'package:cloud_firestore/cloud_firestore.dart';

class ConsultationModel {
  final String id;
  final String ticketId;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String? department;
  final String? chiefComplaint;
  final String? diagnosis;
  final String? treatment;
  final List<String>? prescriptions;
  final List<String>? labOrders;
  final String? notes;
  final String? followUpDate;
  final String? vitalSigns;
  final DateTime consultationDate;
  final DateTime createdAt;

  ConsultationModel({
    required this.id,
    required this.ticketId,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    this.department,
    this.chiefComplaint,
    this.diagnosis,
    this.treatment,
    this.prescriptions,
    this.labOrders,
    this.notes,
    this.followUpDate,
    this.vitalSigns,
    required this.consultationDate,
    required this.createdAt,
  });

  factory ConsultationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConsultationModel(
      id: doc.id,
      ticketId: data['ticketId'] ?? '',
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      department: data['department'],
      chiefComplaint: data['chiefComplaint'],
      diagnosis: data['diagnosis'],
      treatment: data['treatment'],
      prescriptions: data['prescriptions'] != null
          ? List<String>.from(data['prescriptions'])
          : null,
      labOrders: data['labOrders'] != null
          ? List<String>.from(data['labOrders'])
          : null,
      notes: data['notes'],
      followUpDate: data['followUpDate'],
      vitalSigns: data['vitalSigns'],
      consultationDate:
          (data['consultationDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ticketId': ticketId,
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'department': department,
      'chiefComplaint': chiefComplaint,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'prescriptions': prescriptions,
      'labOrders': labOrders,
      'notes': notes,
      'followUpDate': followUpDate,
      'vitalSigns': vitalSigns,
      'consultationDate': Timestamp.fromDate(consultationDate),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ConsultationModel copyWith({
    String? id,
    String? ticketId,
    String? patientId,
    String? patientName,
    String? doctorId,
    String? doctorName,
    String? department,
    String? chiefComplaint,
    String? diagnosis,
    String? treatment,
    List<String>? prescriptions,
    List<String>? labOrders,
    String? notes,
    String? followUpDate,
    String? vitalSigns,
    DateTime? consultationDate,
    DateTime? createdAt,
  }) {
    return ConsultationModel(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      department: department ?? this.department,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      diagnosis: diagnosis ?? this.diagnosis,
      treatment: treatment ?? this.treatment,
      prescriptions: prescriptions ?? this.prescriptions,
      labOrders: labOrders ?? this.labOrders,
      notes: notes ?? this.notes,
      followUpDate: followUpDate ?? this.followUpDate,
      vitalSigns: vitalSigns ?? this.vitalSigns,
      consultationDate: consultationDate ?? this.consultationDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
