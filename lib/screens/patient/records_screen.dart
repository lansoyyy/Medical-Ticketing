import 'package:flutter/material.dart';
import '../../models/consultation_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await _authService.getCurrentUserData();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text('Medical Records',
            style: AppTextStyles.h5.copyWith(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  onChanged: (value) {
                    // TODO: Implement search filtering
                  },
                  decoration: InputDecoration(
                    hintText: 'Search records...',
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.grey100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Consultations'),
                  Tab(text: 'Prescriptions'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _currentUser == null
              ? const Center(child: Text('Please log in to view records'))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildConsultationsTab(),
                    _buildPrescriptionsTab(),
                  ],
                ),
    );
  }

  Widget _buildConsultationsTab() {
    return StreamBuilder<List<ConsultationModel>>(
      stream: _firestoreService.getPatientConsultations(_currentUser!.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }

        final consultations = snapshot.data ?? [];

        if (consultations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medical_services_outlined,
                    size: 64, color: AppColors.grey400),
                const SizedBox(height: 16),
                Text('No consultation records',
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Text('Your consultation history will appear here',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textHint)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: consultations.length,
          itemBuilder: (context, index) {
            return _buildConsultationCard(consultations[index]);
          },
        );
      },
    );
  }

  Widget _buildConsultationCard(ConsultationModel consultation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.medical_services, color: AppColors.primary),
        ),
        title: Text(consultation.diagnosis ?? 'Consultation',
            style:
                AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(consultation.doctorName,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary)),
            Text(_formatDate(consultation.consultationDate),
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
        children: [
          const Divider(),
          const SizedBox(height: 8),
          if (consultation.chiefComplaint != null)
            _buildDetailSection(
                'Chief Complaint', consultation.chiefComplaint!),
          if (consultation.diagnosis != null)
            _buildDetailSection('Diagnosis', consultation.diagnosis!),
          if (consultation.treatment != null)
            _buildDetailSection('Treatment Plan', consultation.treatment!),
          if (consultation.prescriptions != null &&
              consultation.prescriptions!.isNotEmpty)
            _buildDetailSection(
                'Prescriptions', consultation.prescriptions!.join(', ')),
          if (consultation.notes != null)
            _buildDetailSection('Notes', consultation.notes!),
          if (consultation.followUpDate != null)
            _buildDetailSection('Follow-up', consultation.followUpDate!),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(content, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildPrescriptionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _prescriptions.length,
      itemBuilder: (context, index) {
        final prescription = _prescriptions[index];
        return _buildPrescriptionCard(prescription);
      },
    );
  }

  Widget _buildPrescriptionCard(Map<String, dynamic> prescription) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.cardGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.medication,
                    color: AppColors.cardGreen, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Prescription #${prescription['id']}',
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w600)),
                    Text(prescription['date'],
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: prescription['status'] == 'Active'
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.grey300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  prescription['status'],
                  style: AppTextStyles.caption.copyWith(
                    color: prescription['status'] == 'Active'
                        ? AppColors.success
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Text('Prescribed by ${prescription['doctor']}',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          ...List.generate(
            (prescription['medications'] as List).length,
            (index) => _buildMedicationItem(prescription['medications'][index]),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Download'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showRefillRequestDialog(prescription),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refill Request'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationItem(Map<String, String> medication) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(medication['name']!,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(
                  '${medication['dosage']} - ${medication['frequency']} - ${medication['duration']}',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Available medications for refill request
  final List<Map<String, String>> _availableMedications = [
    {
      'name': 'Metformin',
      'dosage': '500mg',
      'description': 'Diabetes management'
    },
    {
      'name': 'Lisinopril',
      'dosage': '10mg',
      'description': 'Blood pressure control'
    },
    {
      'name': 'Cetirizine',
      'dosage': '10mg',
      'description': 'Antihistamine for allergies'
    },
    {
      'name': 'Amlodipine',
      'dosage': '5mg',
      'description': 'Calcium channel blocker'
    },
    {
      'name': 'Ibuprofen',
      'dosage': '400mg',
      'description': 'Pain relief and anti-inflammatory'
    },
    {
      'name': 'Insulin',
      'dosage': 'Various',
      'description': 'Diabetes management'
    },
    {
      'name': 'Losartan',
      'dosage': '50mg',
      'description': 'Blood pressure control'
    },
    {
      'name': 'Metoprolol',
      'dosage': '25mg',
      'description': 'Beta blocker for heart'
    },
    {
      'name': 'Vitamin B1',
      'dosage': '100mg',
      'description': 'Vitamin supplement'
    },
    {
      'name': 'Aspirin',
      'dosage': '81mg',
      'description': 'Blood thinner and pain relief'
    },
  ];

  void _showRefillRequestDialog(Map<String, dynamic> prescription) {
    final searchController = TextEditingController();
    List<Map<String, String>> filteredMeds = List.from(_availableMedications);
    List<Map<String, String>> selectedMeds = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.cardGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.medication, color: AppColors.cardGreen),
              ),
              const SizedBox(width: 12),
              const Text('Refill Request'),
            ],
          ),
          content: SizedBox(
            width: 500,
            height: 450,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Field
                TextField(
                  controller: searchController,
                  style: const TextStyle(color: AppColors.inputText),
                  decoration: InputDecoration(
                    hintText: 'Search medications...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setDialogState(() {
                                searchController.clear();
                                filteredMeds = List.from(_availableMedications);
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setDialogState(() {
                      filteredMeds = _availableMedications
                          .where((med) => med['name']!
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                          .toList();
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Selected medications
                if (selectedMeds.isNotEmpty) ...[
                  Text('Selected Medications (${selectedMeds.length})',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedMeds
                        .map((med) => Chip(
                              label: Text('${med['name']} ${med['dosage']}',
                                  style: AppTextStyles.caption),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () {
                                setDialogState(() {
                                  selectedMeds.remove(med);
                                });
                              },
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.1),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                ],

                // Medications list
                Text('Available Medications',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredMeds.length,
                    itemBuilder: (context, index) {
                      final med = filteredMeds[index];
                      final isSelected = selectedMeds.contains(med);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.grey100,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: AppColors.primary, width: 1)
                              : null,
                        ),
                        child: ListTile(
                          dense: true,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.cardGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.medication,
                                color: AppColors.cardGreen, size: 20),
                          ),
                          title: Text(med['name']!,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              '${med['dosage']} • ${med['description']}',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.textSecondary)),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: AppColors.primary)
                              : const Icon(Icons.add_circle_outline,
                                  color: AppColors.textSecondary),
                          onTap: () {
                            setDialogState(() {
                              if (isSelected) {
                                selectedMeds.remove(med);
                              } else {
                                selectedMeds.add(med);
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: selectedMeds.isEmpty
                  ? null
                  : () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Refill request submitted for ${selectedMeds.length} medication(s)'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
              icon: const Icon(Icons.send, size: 18),
              label: Text('Submit Request (${selectedMeds.length})'),
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedMeds.isEmpty
                    ? AppColors.grey400
                    : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sample Data (keeping prescriptions for UI demonstration)

  final List<Map<String, dynamic>> _prescriptions = [
    {
      'id': 'RX-2024-001',
      'date': 'November 28, 2024',
      'doctor': 'Dr. Maria Santos',
      'status': 'Active',
      'medications': [
        {
          'name': 'Metformin',
          'dosage': '500mg',
          'frequency': 'Twice daily',
          'duration': '90 days'
        },
        {
          'name': 'Lisinopril',
          'dosage': '10mg',
          'frequency': 'Once daily',
          'duration': '90 days'
        },
      ],
    },
    {
      'id': 'RX-2024-002',
      'date': 'October 15, 2024',
      'doctor': 'Dr. Ana Reyes',
      'status': 'Expired',
      'medications': [
        {
          'name': 'Cetirizine',
          'dosage': '10mg',
          'frequency': 'Once daily',
          'duration': '14 days'
        },
      ],
    },
  ];
}
