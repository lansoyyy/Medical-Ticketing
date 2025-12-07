import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class ConsultationScreen extends StatefulWidget {
  final Map<String, dynamic>? patient;
  const ConsultationScreen({super.key, this.patient});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _currentPatient;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentPatient = widget.patient ?? _queuePatients.first;
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
        backgroundColor: AppColors.cardBlue,
        foregroundColor: AppColors.white,
        title: const Text('Consultation'),
        actions: [
          TextButton.icon(
            onPressed: _completeConsultation,
            icon: const Icon(Icons.check_circle, color: AppColors.white),
            label: Text('Complete', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
      body: Row(
        children: [
          // Patient Queue Sidebar
          Container(
            width: 280,
            color: AppColors.white,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.grey100,
                  child: Row(
                    children: [
                      Text('Patient Queue',
                          style: AppTextStyles.bodyMedium
                              .copyWith(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: AppColors.cardOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12)),
                        child: Text('${_queuePatients.length}',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.cardOrange,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _queuePatients.length,
                    itemBuilder: (context, index) {
                      final patient = _queuePatients[index];
                      final isSelected =
                          _currentPatient?['name'] == patient['name'];
                      return _buildQueueItem(patient, isSelected);
                    },
                  ),
                ),
              ],
            ),
          ),
          // Main Consultation Area
          Expanded(
            child: _currentPatient != null
                ? _buildConsultationArea()
                : _buildEmptyState(),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueItem(Map<String, dynamic> patient, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => _currentPatient = patient),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cardBlue.withOpacity(0.1) : null,
          border: Border(
              left: BorderSide(
                  color: isSelected ? AppColors.cardBlue : Colors.transparent,
                  width: 3)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: AppColors.cardBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Center(
                  child: Text(patient['queue'],
                      style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.cardBlue))),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text(patient['name'],
                              style: AppTextStyles.bodySmall
                                  .copyWith(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis)),
                      if (patient['urgent'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(2)),
                          child: Text('!',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.white, fontSize: 10)),
                        ),
                    ],
                  ),
                  Text(patient['complaint'],
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
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
          Icon(Icons.people_outline, size: 64, color: AppColors.grey400),
          const SizedBox(height: 16),
          Text('No patient selected',
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text('Select a patient from the queue to start consultation',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textHint)),
        ],
      ),
    );
  }

  Widget _buildConsultationArea() {
    return Column(
      children: [
        // Patient Header
        Container(
          padding: const EdgeInsets.all(20),
          color: AppColors.white,
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.cardBlue.withOpacity(0.1),
                child: Text(_currentPatient!['name'][0],
                    style:
                        AppTextStyles.h4.copyWith(color: AppColors.cardBlue)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_currentPatient!['name'], style: AppTextStyles.h5),
                        if (_currentPatient!['urgent'] == true) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(4)),
                            child: Text('URGENT',
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.white)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                        '${_currentPatient!['age']} • Queue #${_currentPatient!['queue']}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              _buildVitalChip('BP', '120/80'),
              const SizedBox(width: 8),
              _buildVitalChip('Temp', '36.5°C'),
              const SizedBox(width: 8),
              _buildVitalChip('Weight', '65kg'),
            ],
          ),
        ),
        // Tabs
        Container(
          color: AppColors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.cardBlue,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.cardBlue,
            tabs: const [
              Tab(text: 'Consultation'),
              Tab(text: 'Medical History'),
              Tab(text: 'Documents'),
            ],
          ),
        ),
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildConsultationTab(),
              _buildHistoryTab(),
              _buildDocumentsTab(),
            ],
          ),
        ),
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
              style: AppTextStyles.bodySmall
                  .copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildConsultationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column - Diagnosis & Notes
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildFormCard('Chief Complaint',
                    child: TextField(
                      maxLines: 2,
                      decoration: InputDecoration(
                          hintText: _currentPatient!['complaint'],
                          border: const OutlineInputBorder()),
                    )),
                const SizedBox(height: 16),
                _buildFormCard('Diagnosis',
                    child: TextField(
                      maxLines: 3,
                      decoration: const InputDecoration(
                          hintText: 'Enter diagnosis...',
                          border: OutlineInputBorder()),
                    )),
                const SizedBox(height: 16),
                _buildFormCard('Assessment & Notes',
                    child: TextField(
                      maxLines: 4,
                      decoration: const InputDecoration(
                          hintText: 'Enter assessment and medical notes...',
                          border: OutlineInputBorder()),
                    )),
                const SizedBox(height: 16),
                _buildFormCard('Treatment Plan',
                    child: TextField(
                      maxLines: 3,
                      decoration: const InputDecoration(
                          hintText: 'Enter treatment plan...',
                          border: OutlineInputBorder()),
                    )),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Right Column - Actions
          Expanded(
            child: Column(
              children: [
                _buildActionCard('Prescription', Icons.medication,
                    AppColors.cardPurple, _showPrescriptionDialog),
                const SizedBox(height: 12),
                _buildActionCard('Lab Order', Icons.science, AppColors.cardCyan,
                    _showLabOrderDialog),
                const SizedBox(height: 12),
                _buildActionCard('Medical Certificate', Icons.description,
                    AppColors.cardOrange, _showCertificateDialog),
                const SizedBox(height: 12),
                _buildActionCard('Follow-up', Icons.event, AppColors.cardGreen,
                    _showFollowUpDialog),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _completeConsultation,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Complete Consultation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(String title, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Text(title,
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w600)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHistoryCard(
            'Nov 28, 2024',
            'Follow-up Checkup',
            'Dr. Maria Santos',
            'Hypertension - BP controlled. Continue current medication.'),
        _buildHistoryCard(
            'Oct 15, 2024',
            'General Consultation',
            'Dr. Juan Cruz',
            'Mild upper respiratory infection. Prescribed antibiotics.'),
        _buildHistoryCard(
            'Sep 10, 2024',
            'Initial Consultation',
            'Dr. Maria Santos',
            'Diagnosis: Essential Hypertension. Started on Lisinopril 10mg.'),
      ],
    );
  }

  Widget _buildHistoryCard(
      String date, String type, String doctor, String notes) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(12)),
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
              style: AppTextStyles.caption.copyWith(color: AppColors.cardBlue)),
          const SizedBox(height: 8),
          Text(notes, style: AppTextStyles.bodySmall),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Details')),
              TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Download')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildDocumentCard('CBC Results', 'Lab Result', 'Nov 25, 2024',
            Icons.science, AppColors.cardCyan),
        _buildDocumentCard('Chest X-Ray', 'Imaging', 'Oct 15, 2024',
            Icons.image, AppColors.cardPurple),
        _buildDocumentCard('ECG Report', 'Diagnostic', 'Sep 10, 2024',
            Icons.monitor_heart, AppColors.cardRed),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _showUploadDialog,
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload Document'),
          style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16)),
        ),
      ],
    );
  }

  Widget _buildDocumentCard(
      String title, String type, String date, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                Text('$type • $date',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.visibility)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.download)),
        ],
      ),
    );
  }

  void _showPrescriptionDialog() {
    String? selectedFrequency;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Issue Prescription'),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                            style: const TextStyle(color: AppColors.inputText),
                            decoration: const InputDecoration(
                                labelText: 'Medication Name',
                                hintText: 'Enter medication'))),
                    const SizedBox(width: 12),
                    SizedBox(
                        width: 100,
                        child: TextField(
                            style: const TextStyle(color: AppColors.inputText),
                            decoration: const InputDecoration(
                                labelText: 'Dosage',
                                hintText: 'mg'))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: DropdownButtonFormField<String>(
                            value: selectedFrequency,
                            dropdownColor: AppColors.inputBackground,
                            style: const TextStyle(color: AppColors.inputText),
                            decoration: const InputDecoration(
                                labelText: 'Frequency',
                                hintText: 'Select frequency'),
                            items: [
                              'Once daily',
                              'Twice daily',
                              'Three times daily',
                              'As needed'
                            ]
                                .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e,
                                        style: const TextStyle(
                                            color: AppColors.inputText))))
                                .toList(),
                            onChanged: (v) =>
                                setDialogState(() => selectedFrequency = v))),
                    const SizedBox(width: 12),
                    SizedBox(
                        width: 120,
                        child: TextField(
                            style: const TextStyle(color: AppColors.inputText),
                            decoration: const InputDecoration(
                                labelText: 'Duration',
                                hintText: 'Days',
                                suffixText: 'days',
                                suffixStyle:
                                    TextStyle(color: AppColors.inputHint)))),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                    style: const TextStyle(color: AppColors.inputText),
                    decoration: const InputDecoration(
                        labelText: 'Instructions',
                        hintText: 'e.g., Take after meals'),
                    maxLines: 2),
                const SizedBox(height: 16),
                Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add),
                        label: const Text('Add Another Medication'))),
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Prescription issued successfully')));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardPurple),
                child: const Text('Issue Prescription')),
          ],
        ),
      ),
    );
  }

  void _showLabOrderDialog() {
    List<String> selectedTests = [];
    String? selectedPriority;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Order Laboratory Test'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Tests:',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'CBC',
                    'Urinalysis',
                    'Lipid Profile',
                    'FBS',
                    'HbA1c',
                    'Liver Panel',
                    'Kidney Panel',
                    'Thyroid Panel'
                  ]
                      .map((test) => FilterChip(
                          label: Text(test),
                          selected: selectedTests.contains(test),
                          selectedColor: AppColors.cardCyan.withOpacity(0.2),
                          checkmarkColor: AppColors.cardCyan,
                          onSelected: (selected) {
                            setDialogState(() {
                              if (selected) {
                                selectedTests.add(test);
                              } else {
                                selectedTests.remove(test);
                              }
                            });
                          }))
                      .toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                    style: const TextStyle(color: AppColors.inputText),
                    decoration: const InputDecoration(
                        labelText: 'Special Instructions',
                        hintText: 'Enter any special instructions'),
                    maxLines: 2),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                    value: selectedPriority,
                    dropdownColor: AppColors.inputBackground,
                    style: const TextStyle(color: AppColors.inputText),
                    decoration: const InputDecoration(
                        labelText: 'Priority', hintText: 'Select priority'),
                    items: ['Routine', 'Urgent', 'STAT']
                        .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e,
                                style: const TextStyle(
                                    color: AppColors.inputText))))
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => selectedPriority = v)),
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Lab order created successfully')));
                },
                style:
                    ElevatedButton.styleFrom(backgroundColor: AppColors.cardCyan),
                child: const Text('Order Tests')),
          ],
        ),
      ),
    );
  }

  void _showCertificateDialog() {
    String? selectedType;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Issue Medical Certificate'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                    value: selectedType,
                    dropdownColor: AppColors.inputBackground,
                    style: const TextStyle(color: AppColors.inputText),
                    decoration: const InputDecoration(
                        labelText: 'Certificate Type',
                        hintText: 'Select type'),
                    items: [
                      'Medical Certificate',
                      'Fit to Work',
                      'Medical Clearance',
                      'Sick Leave'
                    ]
                        .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e,
                                style: const TextStyle(
                                    color: AppColors.inputText))))
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => selectedType = v)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                            style: const TextStyle(color: AppColors.inputText),
                            decoration: const InputDecoration(
                                labelText: 'Valid From',
                                prefixIcon: Icon(Icons.calendar_today)),
                            readOnly: true,
                            controller:
                                TextEditingController(text: 'Dec 5, 2024'))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: TextField(
                            style: const TextStyle(color: AppColors.inputText),
                            decoration: const InputDecoration(
                                labelText: 'Valid Until',
                                prefixIcon: Icon(Icons.calendar_today)),
                            readOnly: true,
                            controller:
                                TextEditingController(text: 'Dec 8, 2024'))),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                    style: const TextStyle(color: AppColors.inputText),
                    decoration: const InputDecoration(
                        labelText: 'Purpose / Remarks',
                        hintText: 'Enter purpose or remarks'),
                    maxLines: 3),
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Certificate issued successfully')));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardOrange),
                child: const Text('Issue Certificate')),
          ],
        ),
      ),
    );
  }

  void _showFollowUpDialog() {
    String? selectedTime;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Schedule Follow-up'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    style: const TextStyle(color: AppColors.inputText),
                    decoration: const InputDecoration(
                        labelText: 'Recommended Date',
                        hintText: 'Select date',
                        prefixIcon: Icon(Icons.calendar_today)),
                    readOnly: true,
                    controller: TextEditingController(text: 'Dec 12, 2024')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                    value: selectedTime,
                    dropdownColor: AppColors.inputBackground,
                    style: const TextStyle(color: AppColors.inputText),
                    decoration: const InputDecoration(
                        labelText: 'Time Slot', hintText: 'Select time'),
                    items: [
                      '9:00 AM',
                      '10:00 AM',
                      '11:00 AM',
                      '2:00 PM',
                      '3:00 PM',
                      '4:00 PM'
                    ]
                        .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e,
                                style: const TextStyle(
                                    color: AppColors.inputText))))
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => selectedTime = v)),
                const SizedBox(height: 12),
                TextField(
                    style: const TextStyle(color: AppColors.inputText),
                    decoration: const InputDecoration(
                        labelText: 'Reason for Follow-up',
                        hintText: 'Enter reason'),
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Follow-up scheduled successfully')));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardGreen),
                child: const Text('Schedule')),
          ],
        ),
      ),
    );
  }

  void _showUploadDialog() {
    String? selectedType;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Upload Document'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey300),
                    borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_upload,
                          size: 40, color: AppColors.grey400),
                      const SizedBox(height: 8),
                      TextButton(
                          onPressed: () {}, child: const Text('Browse files')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                  value: selectedType,
                  dropdownColor: AppColors.inputBackground,
                  style: const TextStyle(color: AppColors.inputText),
                  decoration: const InputDecoration(
                      labelText: 'Document Type',
                      hintText: 'Select document type'),
                  items: ['Lab Result', 'Imaging', 'Report', 'Other']
                      .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e,
                              style:
                                  const TextStyle(color: AppColors.inputText))))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => selectedType = v)),
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
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary),
                child: const Text('Upload')),
          ],
        ),
      ),
    );
  }

  void _completeConsultation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Consultation'),
        content: Text(
            'Are you sure you want to complete the consultation for ${_currentPatient!['name']}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Consultation completed successfully')));
              setState(() {
                _queuePatients.remove(_currentPatient);
                _currentPatient =
                    _queuePatients.isNotEmpty ? _queuePatients.first : null;
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> _queuePatients = [
    {
      'queue': '02',
      'name': 'Maria Santos',
      'age': '32 yrs, F',
      'complaint': 'Follow-up checkup',
      'urgent': true
    },
    {
      'queue': '03',
      'name': 'Pedro Garcia',
      'age': '28 yrs, M',
      'complaint': 'Cough and cold',
      'urgent': false
    },
    {
      'queue': '04',
      'name': 'Ana Reyes',
      'age': '55 yrs, F',
      'complaint': 'BP monitoring',
      'urgent': false
    },
    {
      'queue': '05',
      'name': 'Jose Rizal',
      'age': '62 yrs, M',
      'complaint': 'Diabetes follow-up',
      'urgent': false
    },
  ];
}
