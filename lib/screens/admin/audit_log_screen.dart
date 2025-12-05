import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  String _selectedCategory = 'All';
  String _selectedDateRange = 'Today';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: AppColors.white,
        title: const Text('Audit Log'),
        actions: [
          IconButton(
              icon: const Icon(Icons.download),
              onPressed: _exportLogs,
              tooltip: 'Export Logs'),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search logs...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: AppColors.grey100,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildFilterDropdown(
                    'Category',
                    _selectedCategory,
                    [
                      'All',
                      'Login',
                      'Medical Records',
                      'Ticketing',
                      'User Management'
                    ],
                    (v) => setState(() => _selectedCategory = v!)),
                const SizedBox(width: 16),
                _buildFilterDropdown(
                    'Date Range',
                    _selectedDateRange,
                    [
                      'Today',
                      'Yesterday',
                      'Last 7 Days',
                      'Last 30 Days',
                      'Custom'
                    ],
                    (v) => setState(() => _selectedDateRange = v!)),
              ],
            ),
          ),
          // Stats Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                _buildStatChip('Total Logs', '1,245', AppColors.cardBlue),
                const SizedBox(width: 16),
                _buildStatChip('Login Events', '456', AppColors.cardGreen),
                const SizedBox(width: 16),
                _buildStatChip('Record Changes', '389', AppColors.cardOrange),
                const SizedBox(width: 16),
                _buildStatChip('Ticket Changes', '400', AppColors.cardPurple),
              ],
            ),
          ),
          // Log List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _auditLogs.length,
              itemBuilder: (context, index) => _buildLogCard(_auditLogs[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: AppColors.grey100, borderRadius: BorderRadius.circular(8)),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: items
            .map((i) => DropdownMenuItem(value: i, child: Text(i)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.caption.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildLogCard(Map<String, dynamic> log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: (log['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(log['icon'] as IconData,
                color: log['color'] as Color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: (log['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(log['category'] as String,
                          style: AppTextStyles.caption.copyWith(
                              color: log['color'] as Color,
                              fontWeight: FontWeight.w600)),
                    ),
                    const Spacer(),
                    Text(log['timestamp'] as String,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textHint)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(log['action'] as String,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(log['details'] as String,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 14, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(log['user'] as String,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary)),
                    const SizedBox(width: 16),
                    Icon(Icons.computer, size: 14, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(log['ip'] as String,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textHint)),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            onSelected: (action) => _handleLogAction(action, log),
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'view',
                  child: Row(children: [
                    Icon(Icons.visibility, size: 18),
                    SizedBox(width: 8),
                    Text('View Details')
                  ])),
              const PopupMenuItem(
                  value: 'export',
                  child: Row(children: [
                    Icon(Icons.download, size: 18),
                    SizedBox(width: 8),
                    Text('Export')
                  ])),
            ],
          ),
        ],
      ),
    );
  }

  void _handleLogAction(String action, Map<String, dynamic> log) {
    if (action == 'view') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(log['action'] as String),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Category', log['category'] as String),
                _buildDetailRow('Timestamp', log['timestamp'] as String),
                _buildDetailRow('User', log['user'] as String),
                _buildDetailRow('IP Address', log['ip'] as String),
                _buildDetailRow('Details', log['details'] as String),
                if (log['before'] != null)
                  _buildDetailRow('Before', log['before'] as String),
                if (log['after'] != null)
                  _buildDetailRow('After', log['after'] as String),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'))
          ],
        ),
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 100,
              child: Text(label,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary))),
          Expanded(child: Text(value, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }

  void _exportLogs() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Exporting audit logs...')));
  }

  final List<Map<String, dynamic>> _auditLogs = [
    {
      'category': 'Login',
      'action': 'User Login',
      'details': 'Dr. Maria Santos logged in successfully',
      'user': 'Dr. Maria Santos',
      'ip': '192.168.1.45',
      'timestamp': 'Dec 6, 2024 8:30 AM',
      'icon': Icons.login,
      'color': AppColors.cardGreen
    },
    {
      'category': 'Medical Records',
      'action': 'Patient Record Updated',
      'details': 'Updated diagnosis for patient Juan Dela Cruz',
      'user': 'Dr. Maria Santos',
      'ip': '192.168.1.45',
      'timestamp': 'Dec 6, 2024 9:15 AM',
      'icon': Icons.edit,
      'color': AppColors.cardOrange,
      'before': 'Diagnosis: Pending',
      'after': 'Diagnosis: Hypertension Stage 1'
    },
    {
      'category': 'Ticketing',
      'action': 'New Ticket Generated',
      'details': 'Ticket #GEN-0042 created for Maria Santos',
      'user': 'Nurse Ana Reyes',
      'ip': '192.168.1.32',
      'timestamp': 'Dec 6, 2024 9:20 AM',
      'icon': Icons.confirmation_number,
      'color': AppColors.cardPurple
    },
    {
      'category': 'Ticketing',
      'action': 'Patient Called',
      'details': 'Patient Maria Santos called to Room 101',
      'user': 'Nurse Ana Reyes',
      'ip': '192.168.1.32',
      'timestamp': 'Dec 6, 2024 9:35 AM',
      'icon': Icons.campaign,
      'color': AppColors.cardBlue
    },
    {
      'category': 'Medical Records',
      'action': 'Prescription Issued',
      'details': 'Prescription issued for patient Pedro Garcia',
      'user': 'Dr. Juan Cruz',
      'ip': '192.168.1.48',
      'timestamp': 'Dec 6, 2024 10:00 AM',
      'icon': Icons.medication,
      'color': AppColors.cardCyan
    },
    {
      'category': 'User Management',
      'action': 'New User Created',
      'details': 'New patient account created: Rosa Luna',
      'user': 'Admin',
      'ip': '192.168.1.10',
      'timestamp': 'Dec 6, 2024 10:30 AM',
      'icon': Icons.person_add,
      'color': AppColors.cardGreen
    },
    {
      'category': 'Login',
      'action': 'Failed Login Attempt',
      'details': 'Failed login attempt for user: unknown@email.com',
      'user': 'Unknown',
      'ip': '192.168.1.99',
      'timestamp': 'Dec 6, 2024 10:45 AM',
      'icon': Icons.warning,
      'color': AppColors.error
    },
    {
      'category': 'Medical Records',
      'action': 'Lab Results Uploaded',
      'details': 'CBC results uploaded for Ana Reyes',
      'user': 'Lab Tech',
      'ip': '192.168.1.55',
      'timestamp': 'Dec 6, 2024 11:00 AM',
      'icon': Icons.upload_file,
      'color': AppColors.cardIndigo
    },
  ];
}
