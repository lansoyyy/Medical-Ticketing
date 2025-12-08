import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String role; // patient, nurse, doctor, admin
  final String? gender;
  final DateTime? birthDate;
  final String? address;
  final String? profileImageUrl;
  final String? department;
  final String? specialization;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;

  // Medical profile fields (for patients)
  final String? bloodType;
  final String? height;
  final String? weight;
  final List<String>? allergies;
  final List<String>? currentMedications;
  final List<String>? medicalConditions;

  // Emergency contact
  final String? emergencyContactName;
  final String? emergencyContactRelation;
  final String? emergencyContactPhone;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.role,
    this.gender,
    this.birthDate,
    this.address,
    this.profileImageUrl,
    this.department,
    this.specialization,
    required this.createdAt,
    this.lastLogin,
    this.isActive = true,
    this.bloodType,
    this.height,
    this.weight,
    this.allergies,
    this.currentMedications,
    this.medicalConditions,
    this.emergencyContactName,
    this.emergencyContactRelation,
    this.emergencyContactPhone,
  });

  String get fullName => '$firstName $lastName';

  String get initials =>
      '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
          .toUpperCase();

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'patient',
      gender: data['gender'],
      birthDate: data['birthDate'] != null
          ? (data['birthDate'] as Timestamp).toDate()
          : null,
      address: data['address'],
      profileImageUrl: data['profileImageUrl'],
      department: data['department'],
      specialization: data['specialization'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastLogin: data['lastLogin'] != null
          ? (data['lastLogin'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? true,
      bloodType: data['bloodType'],
      height: data['height'],
      weight: data['weight'],
      allergies: data['allergies'] != null
          ? List<String>.from(data['allergies'])
          : null,
      currentMedications: data['currentMedications'] != null
          ? List<String>.from(data['currentMedications'])
          : null,
      medicalConditions: data['medicalConditions'] != null
          ? List<String>.from(data['medicalConditions'])
          : null,
      emergencyContactName: data['emergencyContactName'],
      emergencyContactRelation: data['emergencyContactRelation'],
      emergencyContactPhone: data['emergencyContactPhone'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'role': role,
      'gender': gender,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'department': department,
      'specialization': specialization,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'isActive': isActive,
      'bloodType': bloodType,
      'height': height,
      'weight': weight,
      'allergies': allergies,
      'currentMedications': currentMedications,
      'medicalConditions': medicalConditions,
      'emergencyContactName': emergencyContactName,
      'emergencyContactRelation': emergencyContactRelation,
      'emergencyContactPhone': emergencyContactPhone,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? role,
    String? gender,
    DateTime? birthDate,
    String? address,
    String? profileImageUrl,
    String? department,
    String? specialization,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
    String? bloodType,
    String? height,
    String? weight,
    List<String>? allergies,
    List<String>? currentMedications,
    List<String>? medicalConditions,
    String? emergencyContactName,
    String? emergencyContactRelation,
    String? emergencyContactPhone,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      department: department ?? this.department,
      specialization: specialization ?? this.specialization,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      bloodType: bloodType ?? this.bloodType,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      allergies: allergies ?? this.allergies,
      currentMedications: currentMedications ?? this.currentMedications,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactRelation:
          emergencyContactRelation ?? this.emergencyContactRelation,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
    );
  }
}
