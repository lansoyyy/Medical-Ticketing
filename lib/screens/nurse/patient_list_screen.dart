import 'package:flutter/material.dart';
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
              stream: _firestoreService.getUsersByRole('patient'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary));
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
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(patient.fullName.isNotEmpty ? patient.fullName[0] : '?',
              style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.bold)),
        ),
        title: Text(patient.fullName,
            style:
                AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(patient.email,
            style:
                AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        children: [
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: _buildInfoItem('Gender', patient.gender ?? 'N/A')),
              Expanded(child: _buildInfoItem('Contact', patient.phone)),
              Expanded(
                  child:
                      _buildInfoItem('Blood Type', patient.bloodType ?? 'N/A')),
            ],
          ),
          const SizedBox(height: 16),
          if (patient.allergies?.isNotEmpty == true) ...[
            Text('Allergies',
                style: AppTextStyles.bodySmall
                    .copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(patient.allergies!.join(', '),
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showPatientDetails(patient),
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('View Details'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showRecordVitalsDialog(patient),
                  icon: const Icon(Icons.monitor_heart, size: 18),
                  label: const Text('Record Vitals'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cardTeal),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPatientDetails(UserModel patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
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
            Row(children: [
              CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                      patient.fullName.isNotEmpty ? patient.fullName[0] : '?',
                      style:
                          AppTextStyles.h4.copyWith(color: AppColors.primary))),
              const SizedBox(width: 16),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(patient.fullName, style: AppTextStyles.h5),
                    Text(patient.email,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary)),
                  ])),
            ]),
            const SizedBox(height: 24),
            _buildInfoItem('Phone', patient.phone),
            _buildInfoItem('Gender', patient.gender ?? 'N/A'),
            _buildInfoItem('Blood Type', patient.bloodType ?? 'N/A'),
            if (patient.height != null)
              _buildInfoItem('Height', '${patient.height} cm'),
            if (patient.weight != null)
              _buildInfoItem('Weight', '${patient.weight} kg'),
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
    );
  }

  void _showRecordVitalsDialog(UserModel patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Record Vitals - ${patient.fullName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                decoration: const InputDecoration(
                    labelText: 'Blood Pressure', suffixText: 'mmHg')),
            const SizedBox(height: 12),
            TextField(
                decoration: const InputDecoration(
                    labelText: 'Temperature', suffixText: '°C')),
            const SizedBox(height: 12),
            TextField(
                decoration: const InputDecoration(
                    labelText: 'Weight', suffixText: 'kg')),
            const SizedBox(height: 12),
            TextField(
                decoration: const InputDecoration(
                    labelText: 'Heart Rate', suffixText: 'bpm')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vitals recorded')));
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.cardTeal),
            child: const Text('Save'),
          ),
        ],
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
