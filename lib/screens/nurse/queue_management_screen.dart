import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class QueueManagementScreen extends StatefulWidget {
  const QueueManagementScreen({super.key});

  @override
  State<QueueManagementScreen> createState() => _QueueManagementScreenState();
}

class _QueueManagementScreenState extends State<QueueManagementScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Waiting',
    'In Consultation',
    'Completed'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        backgroundColor: AppColors.cardTeal,
        foregroundColor: AppColors.white,
        title: const Text('Queue Management'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewTicketDialog,
        backgroundColor: AppColors.cardTeal,
        icon: const Icon(Icons.add),
        label: const Text('New Ticket'),
      ),
      body: Column(
        children: [
          // Stats Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: Row(
              children: [
                _buildQuickStat('Waiting', '8', AppColors.cardOrange),
                _buildQuickStat('In Consultation', '3', AppColors.cardBlue),
                _buildQuickStat('Completed', '12', AppColors.success),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _callNextPatient,
                  icon: const Icon(Icons.campaign),
                  label: const Text('Call Next'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cardBlue),
                ),
              ],
            ),
          ),
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.white,
            child: Row(
              children: _filters
                  .map((f) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(f),
                          selected: _selectedFilter == f,
                          selectedColor: AppColors.cardTeal.withOpacity(0.2),
                          onSelected: (s) =>
                              setState(() => _selectedFilter = f),
                        ),
                      ))
                  .toList(),
            ),
          ),
          // Queue List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _queueList.length,
              itemBuilder: (context, index) =>
                  _buildQueueCard(_queueList[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 24),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text('$label: ',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
          Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildQueueCard(Map<String, dynamic> patient) {
    final statusColor = _getStatusColor(patient['status']);
    final isUrgent = patient['urgent'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: isUrgent ? Border.all(color: AppColors.error, width: 2) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Queue Number
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      patient['queue'],
                      style: AppTextStyles.h4.copyWith(
                          color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(patient['name'],
                              style: AppTextStyles.bodyLarge
                                  .copyWith(fontWeight: FontWeight.w600)),
                          if (isUrgent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text('URGENT',
                                  style: AppTextStyles.caption.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${patient['type']} • ${patient['time']}',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(patient['status'],
                      style: AppTextStyles.caption.copyWith(
                          color: statusColor, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          // Actions
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                if (patient['status'] == 'Waiting') ...[
                  _buildActionButton('Call', Icons.campaign, AppColors.cardBlue,
                      () => _callPatient(patient)),
                  const SizedBox(width: 8),
                  _buildActionButton('Prioritize', Icons.priority_high,
                      AppColors.cardOrange, () => _prioritizePatient(patient)),
                ],
                if (patient['status'] == 'In Consultation') ...[
                  _buildActionButton('Complete', Icons.check_circle,
                      AppColors.success, () => _completePatient(patient)),
                ],
                const Spacer(),
                _buildActionButton('View', Icons.visibility,
                    AppColors.textSecondary, () => _viewPatient(patient)),
                const SizedBox(width: 8),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert,
                      color: AppColors.textSecondary),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'vitals', child: Text('Record Vitals')),
                    const PopupMenuItem(
                        value: 'forward', child: Text('Forward to Doctor')),
                    const PopupMenuItem(
                        value: 'cancel', child: Text('Cancel Ticket')),
                  ],
                  onSelected: (value) => _handleMenuAction(value, patient),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(color: color)),
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

  void _showNewTicketDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate New Ticket'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  decoration: const InputDecoration(
                      labelText: 'Patient Name',
                      prefixIcon: Icon(Icons.person))),
              const SizedBox(height: 16),
              TextField(
                  decoration: const InputDecoration(
                      labelText: 'Contact Number',
                      prefixIcon: Icon(Icons.phone))),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    labelText: 'Visit Type', prefixIcon: Icon(Icons.category)),
                items: [
                  'General Consultation',
                  'Follow-up',
                  'Laboratory',
                  'Pharmacy'
                ]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (_) {},
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Mark as Urgent'),
                value: false,
                onChanged: (_) {},
                secondary:
                    const Icon(Icons.priority_high, color: AppColors.error),
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
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Ticket #09 generated successfully')));
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.cardTeal),
            child: const Text('Generate Ticket'),
          ),
        ],
      ),
    );
  }

  void _callNextPatient() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(children: [
          const Icon(Icons.campaign, color: AppColors.cardBlue),
          const SizedBox(width: 8),
          const Text('Calling Next Patient'),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Queue #02',
                style: AppTextStyles.h3.copyWith(color: AppColors.cardBlue)),
            const SizedBox(height: 8),
            Text('Maria Santos', style: AppTextStyles.h5),
            const SizedBox(height: 16),
            const Text(
                'Patient has been notified. Please wait for them to arrive.'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Skip')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Confirm')),
        ],
      ),
    );
  }

  void _callPatient(Map<String, dynamic> patient) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Calling ${patient['name']}...')));
  }

  void _prioritizePatient(Map<String, dynamic> patient) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${patient['name']} marked as urgent')));
  }

  void _completePatient(Map<String, dynamic> patient) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${patient['name']} consultation completed')));
  }

  void _viewPatient(Map<String, dynamic> patient) {
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
              Row(
                children: [
                  CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(patient['name'][0],
                          style: AppTextStyles.h4
                              .copyWith(color: AppColors.primary))),
                  const SizedBox(width: 16),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(patient['name'], style: AppTextStyles.h5),
                        Text('Queue #${patient['queue']} • ${patient['type']}',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textSecondary)),
                      ]),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoRow('Status', patient['status']),
              _buildInfoRow('Time In', patient['time']),
              _buildInfoRow('Contact', '+63 912 345 6789'),
              _buildInfoRow('Reason', 'General Consultation'),
              const Divider(height: 32),
              Text('Vital Signs', style: AppTextStyles.h6),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _buildVitalCard('BP', '120/80', 'mmHg')),
                const SizedBox(width: 12),
                Expanded(child: _buildVitalCard('Temp', '36.5', '°C')),
                const SizedBox(width: 12),
                Expanded(child: _buildVitalCard('Weight', '65', 'kg')),
              ]),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cardTeal),
                  child: const Text('Forward to Doctor'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
          Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildVitalCard(String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.grey100, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(value,
                style: AppTextStyles.h5.copyWith(color: AppColors.primary)),
            Text(' $unit', style: AppTextStyles.caption),
          ]),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, Map<String, dynamic> patient) {
    switch (action) {
      case 'vitals':
        _showRecordVitalsDialog(patient);
        break;
      case 'forward':
        _showForwardDialog(patient);
        break;
      case 'cancel':
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ticket for ${patient['name']} cancelled')));
        break;
    }
  }

  void _showRecordVitalsDialog(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Record Vitals - ${patient['name']}'),
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
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Vitals recorded successfully')));
              },
              child: const Text('Save')),
        ],
      ),
    );
  }

  void _showForwardDialog(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forward Patient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Forward ${patient['name']} to:',
                style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),
            ListTile(
              leading:
                  const Icon(Icons.medical_services, color: AppColors.cardBlue),
              title: const Text('Doctor'),
              subtitle: const Text('For consultation'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Patient forwarded to doctor')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.science, color: AppColors.cardPurple),
              title: const Text('Laboratory'),
              subtitle: const Text('For lab tests'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Patient forwarded to laboratory')));
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.local_pharmacy, color: AppColors.cardGreen),
              title: const Text('Pharmacy'),
              subtitle: const Text('For medications'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Patient forwarded to pharmacy')));
              },
            ),
          ],
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> _queueList = [
    {
      'queue': '01',
      'name': 'Juan Dela Cruz',
      'type': 'Walk-in',
      'status': 'In Consultation',
      'time': '8:30 AM',
      'urgent': false
    },
    {
      'queue': '02',
      'name': 'Maria Santos',
      'type': 'Appointment',
      'status': 'Waiting',
      'time': '8:45 AM',
      'urgent': true
    },
    {
      'queue': '03',
      'name': 'Pedro Garcia',
      'type': 'Walk-in',
      'status': 'Waiting',
      'time': '9:00 AM',
      'urgent': false
    },
    {
      'queue': '04',
      'name': 'Ana Reyes',
      'type': 'Follow-up',
      'status': 'Waiting',
      'time': '9:15 AM',
      'urgent': false
    },
    {
      'queue': '05',
      'name': 'Jose Rizal',
      'type': 'Walk-in',
      'status': 'Waiting',
      'time': '9:30 AM',
      'urgent': false
    },
    {
      'queue': '06',
      'name': 'Rosa Luna',
      'type': 'Walk-in',
      'status': 'Waiting',
      'time': '9:45 AM',
      'urgent': true
    },
  ];
}
