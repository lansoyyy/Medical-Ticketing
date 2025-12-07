import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredPatients = _patients
        .where((p) => p['name']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        backgroundColor: AppColors.cardTeal,
        foregroundColor: AppColors.white,
        title: const Text('Patient List'),
      ),
      body: Column(
        children: [
          // Search Bar
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
          // Patient List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredPatients.length,
              itemBuilder: (context, index) =>
                  _buildPatientCard(filteredPatients[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient) {
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
          child: Text(patient['name'][0],
              style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.bold)),
        ),
        title: Text(patient['name'],
            style:
                AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text('Queue #${patient['queue']} • ${patient['visitType']}',
            style:
                AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(patient['status']).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(patient['status'],
              style: AppTextStyles.caption.copyWith(
                  color: _getStatusColor(patient['status']),
                  fontWeight: FontWeight.w600)),
        ),
        children: [
          const Divider(),
          const SizedBox(height: 8),
          // Patient Info
          Row(
            children: [
              Expanded(child: _buildInfoItem('Age', patient['age'])),
              Expanded(child: _buildInfoItem('Gender', patient['gender'])),
              Expanded(child: _buildInfoItem('Contact', patient['contact'])),
            ],
          ),
          const SizedBox(height: 16),
          // Vital Signs
          Text('Vital Signs',
              style: AppTextStyles.bodySmall
                  .copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildVitalChip('BP', patient['vitals']['bp'])),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildVitalChip('Temp', patient['vitals']['temp'])),
              const SizedBox(width: 8),
              Expanded(
                  child:
                      _buildVitalChip('Weight', patient['vitals']['weight'])),
            ],
          ),
          const SizedBox(height: 16),
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showEditPatientDialog(patient),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit Info'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showRecordVitalsDialog(patient),
                  icon: const Icon(Icons.monitor_heart, size: 18),
                  label: const Text('Vitals'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showNursingNotesDialog(patient),
                  icon: const Icon(Icons.note_add, size: 18),
                  label: const Text('Notes'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cardTeal),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showMedicalHistory(patient),
                  icon: const Icon(Icons.history, size: 18),
                  label: const Text('History'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showUploadDialog(patient),
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: const Text('Upload'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showForwardDialog(patient),
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text('Forward'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cardBlue),
                ),
              ),
            ],
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

  Widget _buildVitalChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: AppColors.grey100, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary)),
          Text(value,
              style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Waiting':
        return AppColors.cardOrange;
      case 'In Consultation':
        return AppColors.cardBlue;
      case 'Completed':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showEditPatientDialog(Map<String, dynamic> patient) {
    String? selectedGender = patient['gender'];
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit Patient - ${patient['name']}'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                    initialValue: patient['name'],
                    style: const TextStyle(color: AppColors.inputText),
                    decoration: const InputDecoration(
                        labelText: 'Full Name', hintText: 'Enter full name')),
                const SizedBox(height: 12),
                TextFormField(
                    initialValue: patient['contact'],
                    style: const TextStyle(color: AppColors.inputText),
                    decoration: const InputDecoration(
                        labelText: 'Contact Number',
                        hintText: 'Enter contact number')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: TextFormField(
                            initialValue: patient['age'],
                            style: const TextStyle(color: AppColors.inputText),
                            decoration: const InputDecoration(
                                labelText: 'Age', hintText: 'Age'))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedGender,
                        dropdownColor: AppColors.inputBackground,
                        style: const TextStyle(color: AppColors.inputText),
                        decoration: const InputDecoration(
                            labelText: 'Gender', hintText: 'Select'),
                        items: ['Male', 'Female']
                            .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e,
                                    style: const TextStyle(
                                        color: AppColors.inputText))))
                            .toList(),
                        onChanged: (v) =>
                            setDialogState(() => selectedGender = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                    style: const TextStyle(color: AppColors.inputText),
                    decoration: const InputDecoration(
                        labelText: 'Address', hintText: 'Enter address'),
                    maxLines: 2),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Patient information updated')));
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecordVitalsDialog(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Record Vitals - ${patient['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                    child: TextField(
                        style: const TextStyle(color: AppColors.inputText),
                        decoration: const InputDecoration(
                            labelText: 'Systolic',
                            hintText: '120',
                            suffixText: 'mmHg',
                            suffixStyle:
                                TextStyle(color: AppColors.inputHint)))),
                const SizedBox(width: 8),
                const Text('/'),
                const SizedBox(width: 8),
                Expanded(
                    child: TextField(
                        style: const TextStyle(color: AppColors.inputText),
                        decoration: const InputDecoration(
                            labelText: 'Diastolic',
                            hintText: '80',
                            suffixText: 'mmHg',
                            suffixStyle:
                                TextStyle(color: AppColors.inputHint)))),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
                style: const TextStyle(color: AppColors.inputText),
                decoration: const InputDecoration(
                    labelText: 'Temperature',
                    hintText: '36.5',
                    suffixText: '°C',
                    suffixStyle: TextStyle(color: AppColors.inputHint))),
            const SizedBox(height: 12),
            TextField(
                style: const TextStyle(color: AppColors.inputText),
                decoration: const InputDecoration(
                    labelText: 'Weight',
                    hintText: '65',
                    suffixText: 'kg',
                    suffixStyle: TextStyle(color: AppColors.inputHint))),
            const SizedBox(height: 12),
            TextField(
                style: const TextStyle(color: AppColors.inputText),
                decoration: const InputDecoration(
                    labelText: 'Heart Rate',
                    hintText: '72',
                    suffixText: 'bpm',
                    suffixStyle: TextStyle(color: AppColors.inputHint))),
            const SizedBox(height: 12),
            TextField(
                style: const TextStyle(color: AppColors.inputText),
                decoration: const InputDecoration(
                    labelText: 'Respiratory Rate',
                    hintText: '16',
                    suffixText: '/min',
                    suffixStyle: TextStyle(color: AppColors.inputHint))),
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
                  const SnackBar(content: Text('Vital signs recorded')));
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.cardTeal),
            child: const Text('Save Vitals'),
          ),
        ],
      ),
    );
  }

  void _showNursingNotesDialog(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nursing Notes - ${patient['name']}'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Previous Notes',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Text('Patient complains of mild headache. No fever.',
                        style: AppTextStyles.bodySmall),
                    Text('- Nurse Anna, Dec 4, 2024 9:30 AM',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textHint)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                style: const TextStyle(color: AppColors.inputText),
                decoration: const InputDecoration(
                    labelText: 'Add New Note',
                    hintText: 'Enter nursing notes...',
                    alignLabelWithHint: true),
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note added successfully')));
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.cardTeal),
            child: const Text('Add Note'),
          ),
        ],
      ),
    );
  }

  void _showMedicalHistory(Map<String, dynamic> patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
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
              Text('Medical History - ${patient['name']}',
                  style: AppTextStyles.h5),
              const SizedBox(height: 20),
              _buildHistoryItem('Nov 28, 2024', 'General Consultation',
                  'Dr. Maria Santos', 'Hypertension follow-up. BP controlled.'),
              _buildHistoryItem('Oct 15, 2024', 'Laboratory', 'Dr. Juan Cruz',
                  'CBC, Lipid Profile - All within normal range'),
              _buildHistoryItem(
                  'Sep 10, 2024',
                  'General Consultation',
                  'Dr. Maria Santos',
                  'Initial diagnosis of hypertension. Started on Lisinopril 10mg.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
      String date, String type, String doctor, String notes) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.grey100, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(type,
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600)),
              Text(date,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          Text(doctor,
              style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
          const SizedBox(height: 8),
          Text(notes, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  void _showUploadDialog(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Documents'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(
                    color: AppColors.grey300, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_upload,
                        size: 48, color: AppColors.grey400),
                    const SizedBox(height: 8),
                    Text('Drag and drop files here',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    TextButton(
                        onPressed: () {}, child: const Text('or browse files')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              dropdownColor: AppColors.inputBackground,
              style: const TextStyle(color: AppColors.inputText),
              decoration: const InputDecoration(
                  labelText: 'Document Type', hintText: 'Select type'),
              items: ['Lab Results', 'X-Ray', 'Medical Report', 'Other']
                  .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e,
                          style: const TextStyle(color: AppColors.inputText))))
                  .toList(),
              onChanged: (_) {},
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Document uploaded successfully')));
              },
              child: const Text('Upload')),
        ],
      ),
    );
  }

  void _showForwardDialog(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Forward ${patient['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppColors.cardBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.medical_services,
                      color: AppColors.cardBlue)),
              title: const Text('Doctor'),
              subtitle: const Text('For medical consultation'),
              onTap: () {
                Navigator.pop(context);
                _showSelectDoctorDialog(patient);
              },
            ),
            ListTile(
              leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppColors.cardPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child:
                      const Icon(Icons.science, color: AppColors.cardPurple)),
              title: const Text('Laboratory'),
              subtitle: const Text('For diagnostic tests'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Patient forwarded to Laboratory')));
              },
            ),
            ListTile(
              leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppColors.cardGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.local_pharmacy,
                      color: AppColors.cardGreen)),
              title: const Text('Pharmacy'),
              subtitle: const Text('For medication dispensing'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Patient forwarded to Pharmacy')));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSelectDoctorDialog(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Doctor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDoctorOption('Dr. Maria Santos', 'General Medicine', true),
            _buildDoctorOption('Dr. Juan Cruz', 'Internal Medicine', false),
            _buildDoctorOption('Dr. Ana Reyes', 'Pediatrics', true),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorOption(String name, String specialty, bool available) {
    return ListTile(
      leading: CircleAvatar(
          backgroundColor: available
              ? AppColors.success.withOpacity(0.1)
              : AppColors.grey200,
          child: Icon(Icons.person,
              color: available ? AppColors.success : AppColors.grey400)),
      title: Text(name),
      subtitle: Text(specialty),
      trailing: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              color: available ? AppColors.success : AppColors.grey400,
              shape: BoxShape.circle)),
      enabled: available,
      onTap: available
          ? () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Patient forwarded to $name')));
            }
          : null,
    );
  }

  final List<Map<String, dynamic>> _patients = [
    {
      'queue': '01',
      'name': 'Juan Dela Cruz',
      'age': '45',
      'gender': 'Male',
      'contact': '+63 912 345 6789',
      'visitType': 'Walk-in',
      'status': 'In Consultation',
      'vitals': {'bp': '120/80', 'temp': '36.5°C', 'weight': '72kg'}
    },
    {
      'queue': '02',
      'name': 'Maria Santos',
      'age': '32',
      'gender': 'Female',
      'contact': '+63 917 123 4567',
      'visitType': 'Appointment',
      'status': 'Waiting',
      'vitals': {'bp': '110/70', 'temp': '36.8°C', 'weight': '58kg'}
    },
    {
      'queue': '03',
      'name': 'Pedro Garcia',
      'age': '28',
      'gender': 'Male',
      'contact': '+63 918 765 4321',
      'visitType': 'Walk-in',
      'status': 'Waiting',
      'vitals': {'bp': '--', 'temp': '--', 'weight': '--'}
    },
    {
      'queue': '04',
      'name': 'Ana Reyes',
      'age': '55',
      'gender': 'Female',
      'contact': '+63 919 876 5432',
      'visitType': 'Follow-up',
      'status': 'Waiting',
      'vitals': {'bp': '130/85', 'temp': '36.4°C', 'weight': '65kg'}
    },
    {
      'queue': '05',
      'name': 'Jose Rizal',
      'age': '62',
      'gender': 'Male',
      'contact': '+63 920 111 2222',
      'visitType': 'Walk-in',
      'status': 'Completed',
      'vitals': {'bp': '125/82', 'temp': '36.6°C', 'weight': '78kg'}
    },
  ];
}
