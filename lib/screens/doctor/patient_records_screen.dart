import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class PatientRecordsScreen extends StatefulWidget {
  const PatientRecordsScreen({super.key});

  @override
  State<PatientRecordsScreen> createState() => _PatientRecordsScreenState();
}

class _PatientRecordsScreenState extends State<PatientRecordsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, dynamic>? _selectedPatient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        backgroundColor: AppColors.cardBlue,
        foregroundColor: AppColors.white,
        title: const Text('Patient Records'),
      ),
      body: Row(
        children: [
          // Search & List Panel
          Container(
            width: 350,
            color: AppColors.white,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
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
                  child: ListView.builder(
                    itemCount: _filteredPatients.length,
                    itemBuilder: (context, index) {
                      final patient = _filteredPatients[index];
                      final isSelected =
                          _selectedPatient?['id'] == patient['id'];
                      return _buildPatientListItem(patient, isSelected);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              child: _selectedPatient != null
                  ? _buildPatientDetails()
                  : _buildEmptyState()),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredPatients {
    if (_searchQuery.isEmpty) return _patients;
    return _patients
        .where((p) => p['name']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Widget _buildPatientListItem(Map<String, dynamic> patient, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => _selectedPatient = patient),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cardBlue.withOpacity(0.1) : null,
          border: Border(
              left: BorderSide(
                  color: isSelected ? AppColors.cardBlue : Colors.transparent,
                  width: 3),
              bottom: BorderSide(color: AppColors.grey200)),
        ),
        child: Row(
          children: [
            CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(patient['name'][0],
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patient['name'],
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600)),
                  Text('${patient['age']} • ${patient['gender']}',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search, size: 64, color: AppColors.grey400),
          const SizedBox(height: 16),
          Text('Search for a patient',
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text('Select a patient from the list to view their records',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textHint)),
        ],
      ),
    );
  }

  Widget _buildPatientDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.cardBlue.withOpacity(0.1),
                    child: Text(_selectedPatient!['name'][0],
                        style: AppTextStyles.h3
                            .copyWith(color: AppColors.cardBlue))),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selectedPatient!['name'], style: AppTextStyles.h5),
                      const SizedBox(height: 4),
                      Text(
                          '${_selectedPatient!['age']} • ${_selectedPatient!['gender']} • ${_selectedPatient!['contact']}',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Row(children: [
                        _buildInfoChip('Patient ID', _selectedPatient!['id']),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                            'Blood Type', _selectedPatient!['bloodType']),
                      ]),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _scheduleFollowUp(),
                  icon: const Icon(Icons.event),
                  label: const Text('Schedule Follow-up'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cardBlue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Medical Info
          Row(
            children: [
              Expanded(
                  child: _buildMedicalInfoCard('Allergies',
                      _selectedPatient!['allergies'], AppColors.cardRed)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildMedicalInfoCard('Conditions',
                      _selectedPatient!['conditions'], AppColors.cardOrange)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildMedicalInfoCard('Medications',
                      _selectedPatient!['medications'], AppColors.cardPurple)),
            ],
          ),
          const SizedBox(height: 24),
          Text('Consultation History', style: AppTextStyles.h6),
          const SizedBox(height: 16),
          ..._selectedPatient!['consultations']
              .map<Widget>((c) => _buildConsultationCard(c))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: AppColors.grey100, borderRadius: BorderRadius.circular(16)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('$label: ',
            style:
                AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        Text(value,
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildMedicalInfoCard(String title, List<String> items, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6)),
                child: Icon(Icons.info_outline, color: color, size: 16)),
            const SizedBox(width: 8),
            Text(title,
                style: AppTextStyles.bodySmall
                    .copyWith(fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Text('None recorded',
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.textHint))
          else
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(item, style: AppTextStyles.bodySmall),
                  ]),
                )),
        ],
      ),
    );
  }

  Widget _buildConsultationCard(Map<String, dynamic> c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppColors.cardBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.medical_services,
                    color: AppColors.cardBlue)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(c['diagnosis'],
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600)),
                  Text(c['doctor'],
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.cardBlue)),
                ])),
            Text(c['date'],
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary)),
          ]),
          const Divider(height: 24),
          Text('Complaint: ${c['complaint']}', style: AppTextStyles.bodySmall),
          const SizedBox(height: 8),
          Text('Notes: ${c['notes']}',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Row(children: [
            TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.visibility, size: 16),
                label: const Text('View Details')),
            TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Download')),
          ]),
        ],
      ),
    );
  }

  void _scheduleFollowUp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Follow-up'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                decoration: const InputDecoration(
                    labelText: 'Date', prefixIcon: Icon(Icons.calendar_today)),
                readOnly: true,
                controller: TextEditingController(text: 'Dec 12, 2024')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Time'),
                items: ['9:00 AM', '10:00 AM', '2:00 PM', '3:00 PM']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (_) {}),
            const SizedBox(height: 12),
            TextField(
                decoration: const InputDecoration(labelText: 'Reason'),
                maxLines: 2),
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
                    const SnackBar(content: Text('Follow-up scheduled')));
              },
              child: const Text('Schedule')),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> _patients = [
    {
      'id': 'P-2024-001',
      'name': 'Juan Dela Cruz',
      'age': '45 yrs',
      'gender': 'Male',
      'contact': '+63 912 345 6789',
      'bloodType': 'O+',
      'allergies': ['Penicillin'],
      'conditions': ['Hypertension', 'Type 2 Diabetes'],
      'medications': ['Lisinopril 10mg', 'Metformin 500mg'],
      'consultations': [
        {
          'date': 'Nov 28, 2024',
          'diagnosis': 'Hypertension Follow-up',
          'doctor': 'Dr. Maria Santos',
          'complaint': 'BP monitoring',
          'notes': 'BP controlled at 120/80. Continue current medication.'
        },
        {
          'date': 'Oct 15, 2024',
          'diagnosis': 'Diabetes Follow-up',
          'doctor': 'Dr. Maria Santos',
          'complaint': 'Routine checkup',
          'notes': 'HbA1c improved to 6.8%. Good progress.'
        },
      ],
    },
    {
      'id': 'P-2024-002',
      'name': 'Maria Santos',
      'age': '32 yrs',
      'gender': 'Female',
      'contact': '+63 917 123 4567',
      'bloodType': 'A+',
      'allergies': [],
      'conditions': [],
      'medications': [],
      'consultations': [
        {
          'date': 'Dec 1, 2024',
          'diagnosis': 'Upper Respiratory Infection',
          'doctor': 'Dr. Juan Cruz',
          'complaint': 'Cough and cold for 3 days',
          'notes': 'Prescribed antibiotics and rest.'
        },
      ],
    },
    {
      'id': 'P-2024-003',
      'name': 'Pedro Garcia',
      'age': '55 yrs',
      'gender': 'Male',
      'contact': '+63 918 765 4321',
      'bloodType': 'B+',
      'allergies': ['Sulfa drugs', 'Aspirin'],
      'conditions': ['Asthma'],
      'medications': ['Salbutamol inhaler'],
      'consultations': [
        {
          'date': 'Nov 20, 2024',
          'diagnosis': 'Asthma Exacerbation',
          'doctor': 'Dr. Ana Reyes',
          'complaint': 'Difficulty breathing',
          'notes': 'Nebulization given. Added oral steroids.'
        },
      ],
    },
  ];
}
