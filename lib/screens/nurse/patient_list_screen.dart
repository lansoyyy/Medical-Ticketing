import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String _safeValue(String? value) {
    final v = value?.trim();
    return (v == null || v.isEmpty) ? 'N/A' : v;
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }

  int? _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return null;
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    final birthdayThisYear = DateTime(now.year, birthDate.month, birthDate.day);
    if (now.isBefore(birthdayThisYear)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        backgroundColor: AppColors.cardTeal,
        foregroundColor: AppColors.white,
        title: const Text('Patient List'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search patients...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        })
                    : null,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: AppColors.grey100,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: _firestoreService.getActivePatients(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary));
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Failed to load patients',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary)));
                }
                final allPatients = snapshot.data ?? [];
                final filteredPatients = allPatients
                    .where((p) => p.fullName
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                    .toList();

                if (filteredPatients.isEmpty) {
                  return Center(
                      child: Text('No patients found',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredPatients.length,
                  itemBuilder: (context, index) =>
                      _buildPatientCard(filteredPatients[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(UserModel patient) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: StreamBuilder<Map<String, dynamic>?>(
        stream: _firestoreService.getLatestTicketDataForPatient(patient.id),
        builder: (context, snapshot) {
          final data = snapshot.data;
          final caseNo = data?['caseNo'] as String?;

          DateTime? admissionDate;
          final rawAdmissionDate = data?['admissionDate'];
          if (rawAdmissionDate is Timestamp) {
            admissionDate = rawAdmissionDate.toDate();
          } else if (rawAdmissionDate is DateTime) {
            admissionDate = rawAdmissionDate;
          }

          final subtitleParts = <String>[];
          subtitleParts.add('Case No: ${_safeValue(caseNo)}');
          subtitleParts.add(
              'Admission: ${admissionDate == null ? 'N/A' : _formatDate(admissionDate)}');

          return ExpansionTile(
            tilePadding: const EdgeInsets.all(16),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                  patient.fullName.isNotEmpty ? patient.fullName[0] : '?',
                  style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
            title: Text(patient.fullName,
                style: AppTextStyles.bodyLarge
                    .copyWith(fontWeight: FontWeight.w600)),
            subtitle: Text(subtitleParts.join(' • '),
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary)),
            children: [
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showPatientDetails(
                        patient,
                        caseNo: caseNo,
                        admissionDate: admissionDate,
                      ),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('View Details'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPatientDetails(
    UserModel patient, {
    String? caseNo,
    DateTime? admissionDate,
  }) {
    final age = _calculateAge(patient.birthDate);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: AppColors.grey300,
                            borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Text('Patient Profile',
                    style:
                        AppTextStyles.h5.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Row(children: [
                  CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                          patient.fullName.isNotEmpty
                              ? patient.fullName[0]
                              : '?',
                          style: AppTextStyles.h4
                              .copyWith(color: AppColors.primary))),
                  const SizedBox(width: 16),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(patient.fullName, style: AppTextStyles.h5),
                        Text('Case No: ${_safeValue(caseNo)}',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textSecondary)),
                      ])),
                ]),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                        child: _buildInfoItem(
                            'Admission Date',
                            admissionDate == null
                                ? 'N/A'
                                : _formatDate(admissionDate))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildInfoItem(
                            'Age', age == null ? 'N/A' : '$age')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _buildInfoItem(
                            'Birthdate',
                            patient.birthDate == null
                                ? 'N/A'
                                : _formatDate(patient.birthDate!))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildInfoItem(
                            'Sex/Gender', _safeValue(patient.gender))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _buildInfoItem(
                            'Address', _safeValue(patient.address))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildInfoItem(
                            'Occupation', _safeValue(patient.occupation))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _buildInfoItem(
                            'Birthplace', _safeValue(patient.birthplace))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildInfoItem(
                            'Civil Status', _safeValue(patient.civilStatus))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _buildInfoItem('Health Insurance',
                            _safeValue(patient.healthInsurance))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildInfoItem(
                            'Religion', _safeValue(patient.religion))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _buildInfoItem(
                            'Nationality', _safeValue(patient.nationality))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildInfoItem('Parents/Guardian',
                            _safeValue(patient.parentsOrGuardian))),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cardTeal),
                      child: const Text('Close'),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        Text(value,
            style:
                AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
