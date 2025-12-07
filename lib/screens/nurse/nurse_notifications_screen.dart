import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class NurseNotificationsScreen extends StatefulWidget {
  const NurseNotificationsScreen({super.key});

  @override
  State<NurseNotificationsScreen> createState() =>
      _NurseNotificationsScreenState();
}

class _NurseNotificationsScreenState extends State<NurseNotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        backgroundColor: AppColors.cardTeal,
        foregroundColor: AppColors.white,
        title: const Text('Notifications'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          tabs: const [
            Tab(text: 'Notifications'),
            Tab(text: 'Doctor Availability'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsTab(),
          _buildDoctorAvailabilityTab(),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final iconColor = _getNotificationColor(notification['type']);
    final icon = _getNotificationIcon(notification['type']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: notification['isUnread']
            ? Border.all(color: AppColors.cardTeal.withOpacity(0.3))
            : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(notification['title'],
                            style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: notification['isUnread']
                                    ? FontWeight.w600
                                    : FontWeight.normal))),
                    if (notification['isUnread'])
                      Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: AppColors.cardTeal,
                              shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(notification['message'],
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 14, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(notification['time'],
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textHint)),
                    if (notification['action'] != null) ...[
                      const Spacer(),
                      TextButton(
                        onPressed: () =>
                            _handleNotificationAction(notification),
                        child: Text(notification['action']),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'patient':
        return AppColors.cardBlue;
      case 'doctor':
        return AppColors.cardGreen;
      case 'urgent':
        return AppColors.error;
      case 'system':
        return AppColors.cardPurple;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'patient':
        return Icons.person;
      case 'doctor':
        return Icons.medical_services;
      case 'urgent':
        return Icons.priority_high;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  void _handleNotificationAction(Map<String, dynamic> notification) {
    setState(() => notification['isUnread'] = false);

    final action = notification['action'];
    if (action == 'Send Patient') {
      _showSendPatientDialog(notification);
    } else if (action == 'View' || action == 'View Results') {
      _showNotificationDetailsDialog(notification);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action: $action')));
    }
  }

  void _showSendPatientDialog(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cardGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.send, color: AppColors.cardGreen),
            ),
            const SizedBox(width: 12),
            const Text('Send Next Patient'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Next Queue Patient',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.cardBlue.withOpacity(0.1),
                        child: const Text('M',
                            style: TextStyle(
                                color: AppColors.cardBlue,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Maria Santos',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(fontWeight: FontWeight.w600)),
                          Text('Queue #02 • Follow-up checkup',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Doctor: ${notification['title'].toString().replaceAll(' is now available', '')}',
                style: AppTextStyles.bodySmall),
            const SizedBox(height: 8),
            Text('Room: 105',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Patient notified to proceed to Room 105'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            icon: const Icon(Icons.notifications_active, size: 18),
            label: const Text('Notify Patient'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.cardTeal),
          ),
        ],
      ),
    );
  }

  void _showNotificationDetailsDialog(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getNotificationColor(notification['type']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_getNotificationIcon(notification['type']),
                  color: _getNotificationColor(notification['type'])),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(notification['title'], style: AppTextStyles.h6)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification['message'], style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(notification['time'],
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textHint)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (notification['action'] == 'View Results')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening lab results...')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.cardTeal),
              child: const Text('View Results'),
            ),
        ],
      ),
    );
  }

  String? _selectedPatient;
  String? _selectedDoctor;

  Widget _buildDoctorAvailabilityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Notify Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quick Notify', style: AppTextStyles.h6),
                const SizedBox(height: 12),
                Text('Notify a doctor that a patient is ready for consultation',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedPatient,
                        dropdownColor: AppColors.inputBackground,
                        style: const TextStyle(color: AppColors.inputText),
                        decoration: const InputDecoration(
                          labelText: 'Select Patient',
                          hintText: 'Choose patient',
                        ),
                        items: [
                          'Queue #02 - Maria Santos',
                          'Queue #03 - Pedro Garcia',
                          'Queue #04 - Ana Reyes'
                        ]
                            .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e,
                                    style: const TextStyle(
                                        color: AppColors.inputText))))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedPatient = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedDoctor,
                        dropdownColor: AppColors.inputBackground,
                        style: const TextStyle(color: AppColors.inputText),
                        decoration: const InputDecoration(
                          labelText: 'Select Doctor',
                          hintText: 'Choose doctor',
                        ),
                        items: ['Dr. Maria Santos', 'Dr. Ana Reyes']
                            .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e,
                                    style: const TextStyle(
                                        color: AppColors.inputText))))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedDoctor = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Doctor notified successfully')));
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Notify Doctor'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cardTeal),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Doctor List
          Text('Doctor Availability', style: AppTextStyles.h6),
          const SizedBox(height: 16),
          ..._doctors.map((doctor) => _buildDoctorCard(doctor)),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    final isAvailable = doctor['status'] == 'Available';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: isAvailable
                ? AppColors.success.withOpacity(0.1)
                : AppColors.grey200,
            child: Icon(Icons.person,
                color: isAvailable ? AppColors.success : AppColors.grey400,
                size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor['name'],
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(doctor['specialty'],
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? AppColors.success
                            : AppColors.cardOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      doctor['status'],
                      style: AppTextStyles.caption.copyWith(
                        color: isAvailable
                            ? AppColors.success
                            : AppColors.cardOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!isAvailable) ...[
                      const SizedBox(width: 8),
                      Text('• ${doctor['currentPatient']}',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Queue: ${doctor['queueCount']}',
                  style: AppTextStyles.bodySmall
                      .copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Room ${doctor['room']}',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: isAvailable
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text('Notification sent to ${doctor['name']}')));
                  }
                : null,
            icon: Icon(Icons.notifications_active,
                color: isAvailable ? AppColors.cardTeal : AppColors.grey300),
          ),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> _notifications = [
    {
      'type': 'doctor',
      'title': 'Dr. Maria Santos is now available',
      'message': 'Room 105 is ready for the next patient.',
      'time': '2 min ago',
      'isUnread': true,
      'action': 'Send Patient'
    },
    {
      'type': 'urgent',
      'title': 'Urgent Case Alert',
      'message':
          'Patient Maria Santos (Queue #02) requires immediate attention.',
      'time': '10 min ago',
      'isUnread': true,
      'action': 'View'
    },
    {
      'type': 'patient',
      'title': 'New Walk-in Patient',
      'message': 'Jose Rizal has been added to the queue.',
      'time': '15 min ago',
      'isUnread': false,
      'action': null
    },
    {
      'type': 'system',
      'title': 'Lab Results Available',
      'message': 'CBC results for Juan Dela Cruz are ready.',
      'time': '30 min ago',
      'isUnread': false,
      'action': 'View Results'
    },
    {
      'type': 'doctor',
      'title': 'Dr. Juan Cruz completed consultation',
      'message':
          'Patient Ana Reyes consultation completed. Ready for next patient.',
      'time': '1 hour ago',
      'isUnread': false,
      'action': null
    },
  ];

  final List<Map<String, dynamic>> _doctors = [
    {
      'name': 'Dr. Maria Santos',
      'specialty': 'General Medicine',
      'status': 'Available',
      'room': '105',
      'queueCount': 3,
      'currentPatient': null
    },
    {
      'name': 'Dr. Juan Cruz',
      'specialty': 'Internal Medicine',
      'status': 'In Consultation',
      'room': '106',
      'queueCount': 5,
      'currentPatient': 'Juan Dela Cruz'
    },
    {
      'name': 'Dr. Ana Reyes',
      'specialty': 'Pediatrics',
      'status': 'Available',
      'room': '107',
      'queueCount': 2,
      'currentPatient': null
    },
    {
      'name': 'Dr. Jose Garcia',
      'specialty': 'Cardiology',
      'status': 'In Consultation',
      'room': '108',
      'queueCount': 4,
      'currentPatient': 'Pedro Garcia'
    },
  ];
}
