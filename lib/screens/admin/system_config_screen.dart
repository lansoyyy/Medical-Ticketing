import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class SystemConfigScreen extends StatefulWidget {
  const SystemConfigScreen({super.key});

  @override
  State<SystemConfigScreen> createState() => _SystemConfigScreenState();
}

class _SystemConfigScreenState extends State<SystemConfigScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: AppColors.white,
        title: const Text('System Configuration'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.6),
          tabs: const [
            Tab(text: 'Schedules', icon: Icon(Icons.schedule, size: 20)),
            Tab(text: 'Doctors', icon: Icon(Icons.medical_services, size: 20)),
            Tab(text: 'Departments', icon: Icon(Icons.meeting_room, size: 20)),
            Tab(text: 'Queue Rules', icon: Icon(Icons.rule, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSchedulesTab(),
          _buildDoctorAvailabilityTab(),
          _buildDepartmentsTab(),
          _buildQueueRulesTab(),
        ],
      ),
    );
  }

  Widget _buildSchedulesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Clinic Schedules', style: AppTextStyles.h5),
              ElevatedButton.icon(
                  onPressed: _showAddScheduleDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Schedule')),
            ],
          ),
          const SizedBox(height: 20),
          _buildScheduleCard('Monday - Friday', '8:00 AM - 5:00 PM',
              'Regular OPD Hours', true),
          _buildScheduleCard(
              'Saturday', '8:00 AM - 12:00 PM', 'Half Day', true),
          _buildScheduleCard('Sunday', 'Closed', 'No Operations', false),
          const SizedBox(height: 24),
          Text('Special Schedules', style: AppTextStyles.h6),
          const SizedBox(height: 12),
          _buildScheduleCard('Dec 25, 2024', 'Closed', 'Christmas Day', false),
          _buildScheduleCard('Dec 30, 2024', 'Closed', 'Rizal Day', false),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(
      String day, String time, String note, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: isActive
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.grey200,
                borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.calendar_today,
                color: isActive ? AppColors.success : AppColors.grey500),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(time,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: isActive
                            ? AppColors.success
                            : AppColors.textSecondary)),
              ],
            ),
          ),
          Text(note,
              style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
          const SizedBox(width: 16),
          Switch(value: isActive, onChanged: (_) {}),
          IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildDoctorAvailabilityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Doctor Availability', style: AppTextStyles.h5),
          const SizedBox(height: 20),
          ..._doctors.map((d) => _buildDoctorScheduleCard(d)),
        ],
      ),
    );
  }

  Widget _buildDoctorScheduleCard(Map<String, dynamic> doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                  backgroundColor: AppColors.cardPurple.withOpacity(0.1),
                  child: Text(doctor['name'][4],
                      style: TextStyle(color: AppColors.cardPurple))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor['name'],
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w600)),
                    Text(doctor['department'],
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.cardBlue)),
                  ],
                ),
              ),
              ElevatedButton(
                  onPressed: () => _showEditDoctorScheduleDialog(doctor),
                  child: const Text('Edit Schedule')),
            ],
          ),
          const Divider(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (doctor['schedule'] as List)
                .map<Widget>((s) => Chip(
                      label: Text('${s['day']}: ${s['time']}',
                          style: AppTextStyles.caption),
                      backgroundColor: AppColors.grey100,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Departments & Rooms', style: AppTextStyles.h5),
              ElevatedButton.icon(
                  onPressed: _showAddDepartmentDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Department')),
            ],
          ),
          const SizedBox(height: 20),
          ..._departments.map((d) => _buildDepartmentCard(d)),
        ],
      ),
    );
  }

  Widget _buildDepartmentCard(Map<String, dynamic> dept) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: (dept['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(dept['icon'] as IconData,
                    color: dept['color'] as Color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dept['name'],
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w600)),
                    Text('${dept['rooms']} rooms • ${dept['doctors']} doctors',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Switch(value: dept['active'] as bool, onChanged: (_) {}),
              IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
              IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  onPressed: () {}),
            ],
          ),
          const SizedBox(height: 12),
          Text('Rooms:',
              style:
                  AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: (dept['roomList'] as List)
                .map<Widget>((r) =>
                    Chip(label: Text(r), backgroundColor: AppColors.grey100))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueRulesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Queue & Patient Flow Rules', style: AppTextStyles.h5),
          const SizedBox(height: 20),
          _buildRuleCard('Max Queue Size', 'Maximum patients per doctor queue',
              '20', Icons.people),
          _buildRuleCard(
              'Priority Patients',
              'Senior citizens and PWD priority',
              'Enabled',
              Icons.accessibility),
          _buildRuleCard(
              'Auto-Assignment',
              'Automatically assign patients to available doctors',
              'Enabled',
              Icons.auto_awesome),
          _buildRuleCard(
              'Queue Timeout',
              'Remove patient from queue after timeout',
              '2 hours',
              Icons.timer),
          _buildRuleCard(
              'Follow-up Priority',
              'Give priority to follow-up patients',
              'Enabled',
              Icons.event_repeat),
          const SizedBox(height: 24),
          Text('Ticketing Rules', style: AppTextStyles.h6),
          const SizedBox(height: 12),
          _buildRuleCard('Ticket Format', 'Format for ticket numbers',
              'DEPT-NNNN', Icons.confirmation_number),
          _buildRuleCard('Daily Reset', 'Reset ticket numbers daily', 'Enabled',
              Icons.refresh),
          _buildRuleCard('Pre-booking', 'Allow advance ticket booking',
              'Up to 7 days', Icons.calendar_month),
        ],
      ),
    );
  }

  Widget _buildRuleCard(
      String title, String description, String value, IconData icon) {
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
                color: AppColors.cardBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppColors.cardBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(description,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(8)),
            child: Text(value,
                style: AppTextStyles.bodySmall
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditRuleDialog(title, value)),
        ],
      ),
    );
  }

  void _showAddScheduleDialog() {
    String? selectedDay;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Schedule'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                  value: selectedDay,
                  dropdownColor: AppColors.inputBackground,
                  style: const TextStyle(color: AppColors.inputText),
                  decoration: const InputDecoration(
                      labelText: 'Day/Date', hintText: 'Select day'),
                  items: [
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday',
                    'Saturday',
                    'Sunday',
                    'Specific Date'
                  ]
                      .map((d) => DropdownMenuItem(
                          value: d,
                          child: Text(d,
                              style:
                                  const TextStyle(color: AppColors.inputText))))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedDay = v)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: TextField(
                        style: const TextStyle(color: AppColors.inputText),
                        decoration: const InputDecoration(
                            labelText: 'Start Time', hintText: '8:00 AM'),
                        controller: TextEditingController(text: '8:00 AM'))),
                const SizedBox(width: 12),
                Expanded(
                    child: TextField(
                        style: const TextStyle(color: AppColors.inputText),
                        decoration: const InputDecoration(
                            labelText: 'End Time', hintText: '5:00 PM'),
                        controller: TextEditingController(text: '5:00 PM'))),
              ]),
              const SizedBox(height: 12),
              TextField(
                  style: const TextStyle(color: AppColors.inputText),
                  decoration: const InputDecoration(
                      labelText: 'Note', hintText: 'Enter note')),
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
                      const SnackBar(content: Text('Schedule added')));
                },
                child: const Text('Add')),
          ],
        ),
      ),
    );
  }

  void _showEditDoctorScheduleDialog(Map<String, dynamic> doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Schedule: ${doctor['name']}'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
                .map((day) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(children: [
                        SizedBox(width: 100, child: Text(day)),
                        Expanded(
                            child: TextField(
                                style:
                                    const TextStyle(color: AppColors.inputText),
                                decoration: const InputDecoration(
                                    hintText: '8:00 AM - 5:00 PM'))),
                        Checkbox(value: true, onChanged: (_) {}),
                      ]),
                    ))
                .toList(),
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
                    const SnackBar(content: Text('Schedule updated')));
              },
              child: const Text('Save')),
        ],
      ),
    );
  }

  void _showAddDepartmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Department'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                style: const TextStyle(color: AppColors.inputText),
                decoration: const InputDecoration(
                    labelText: 'Department Name',
                    hintText: 'Enter department name')),
            const SizedBox(height: 12),
            TextField(
                style: const TextStyle(color: AppColors.inputText),
                decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter description')),
            const SizedBox(height: 12),
            TextField(
                style: const TextStyle(color: AppColors.inputText),
                decoration: const InputDecoration(
                    labelText: 'Rooms (comma separated)',
                    hintText: 'Room 101, Room 102, ...')),
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
                    const SnackBar(content: Text('Department added')));
              },
              child: const Text('Add')),
        ],
      ),
    );
  }

  void _showEditRuleDialog(String title, String currentValue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit: $title'),
        content: TextField(
            style: const TextStyle(color: AppColors.inputText),
            decoration: const InputDecoration(
                labelText: 'Value', hintText: 'Enter value'),
            controller: TextEditingController(text: currentValue)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rule updated')));
              },
              child: const Text('Save')),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> _doctors = [
    {
      'name': 'Dr. Maria Santos',
      'department': 'General Medicine',
      'schedule': [
        {'day': 'Mon', 'time': '8AM-5PM'},
        {'day': 'Wed', 'time': '8AM-5PM'},
        {'day': 'Fri', 'time': '8AM-12PM'}
      ]
    },
    {
      'name': 'Dr. Juan Cruz',
      'department': 'Pediatrics',
      'schedule': [
        {'day': 'Tue', 'time': '8AM-5PM'},
        {'day': 'Thu', 'time': '8AM-5PM'}
      ]
    },
    {
      'name': 'Dr. Ana Reyes',
      'department': 'OB-GYN',
      'schedule': [
        {'day': 'Mon', 'time': '1PM-5PM'},
        {'day': 'Wed', 'time': '1PM-5PM'},
        {'day': 'Fri', 'time': '1PM-5PM'}
      ]
    },
  ];

  final List<Map<String, dynamic>> _departments = [
    {
      'name': 'General Medicine',
      'rooms': 5,
      'doctors': 3,
      'active': true,
      'color': AppColors.cardBlue,
      'icon': Icons.medical_services,
      'roomList': ['Room 101', 'Room 102', 'Room 103', 'Room 104', 'Room 105']
    },
    {
      'name': 'Pediatrics',
      'rooms': 3,
      'doctors': 2,
      'active': true,
      'color': AppColors.cardGreen,
      'icon': Icons.child_care,
      'roomList': ['Room 201', 'Room 202', 'Room 203']
    },
    {
      'name': 'OB-GYN',
      'rooms': 2,
      'doctors': 2,
      'active': true,
      'color': AppColors.cardPurple,
      'icon': Icons.pregnant_woman,
      'roomList': ['Room 301', 'Room 302']
    },
    {
      'name': 'Emergency',
      'rooms': 4,
      'doctors': 4,
      'active': true,
      'color': AppColors.cardRed,
      'icon': Icons.emergency,
      'roomList': ['ER 1', 'ER 2', 'ER 3', 'ER 4']
    },
  ];
}
