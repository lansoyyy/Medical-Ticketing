import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen>
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
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text('Queue & Tickets',
            style: AppTextStyles.h5.copyWith(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Current Queue'),
            Tab(text: 'Ticket History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCurrentQueueTab(),
          _buildTicketHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildCurrentQueueTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Active Queue Card
          _buildActiveQueueCard(),
          const SizedBox(height: 24),
          // Queue Status Card
          _buildQueueStatusCard(),
          const SizedBox(height: 24),
          // Queue Progress
          _buildQueueProgressCard(),
        ],
      ),
    );
  }

  Widget _buildActiveQueueCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('Your Queue Number',
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.white.withOpacity(0.9))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'A-042',
              style: AppTextStyles.h1.copyWith(
                fontSize: 56,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQueueInfoItem(Icons.people_outline, 'Position', '5th'),
              Container(
                height: 40,
                width: 1,
                color: AppColors.white.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(horizontal: 24),
              ),
              _buildQueueInfoItem(Icons.access_time, 'Est. Wait', '~25 min'),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined,
                    color: AppColors.white, size: 18),
                const SizedBox(width: 8),
                Text('Now Serving: A-037',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.white.withOpacity(0.8), size: 24),
        const SizedBox(height: 8),
        Text(label,
            style: AppTextStyles.caption
                .copyWith(color: AppColors.white.withOpacity(0.8))),
        const SizedBox(height: 4),
        Text(value,
            style: AppTextStyles.h5
                .copyWith(color: AppColors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildQueueStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text('Ticket Details', style: AppTextStyles.h6),
          const SizedBox(height: 16),
          _buildDetailRow('Ticket ID', 'TKT-2024-00456'),
          _buildDetailRow('Department', 'General Medicine'),
          _buildDetailRow('Doctor', 'Dr. Maria Santos'),
          _buildDetailRow('Date', 'December 4, 2024'),
          _buildDetailRow('Time Issued', '9:30 AM'),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.cardBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.hourglass_top,
                          color: AppColors.cardBlue, size: 18),
                      const SizedBox(width: 8),
                      Text('Waiting',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.cardBlue,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildQueueProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text('Queue Progress', style: AppTextStyles.h6),
          const SizedBox(height: 20),
          _buildProgressStep('Ticket Issued', '9:30 AM', true, true),
          _buildProgressStep('Waiting in Queue', '9:30 AM', true, false),
          _buildProgressStep('Called by Nurse', '', false, false),
          _buildProgressStep('Consultation', '', false, false),
          _buildProgressStep('Completed', '', false, false),
        ],
      ),
    );
  }

  Widget _buildProgressStep(
      String title, String time, bool isCompleted, bool hasLine) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primary : AppColors.grey300,
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: AppColors.white, size: 14)
                  : null,
            ),
            if (title != 'Completed')
              Container(
                width: 2,
                height: 40,
                color: hasLine ? AppColors.primary : AppColors.grey300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight:
                        isCompleted ? FontWeight.w600 : FontWeight.normal,
                    color: isCompleted
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                if (time.isNotEmpty)
                  Text(time,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _ticketHistory.length,
      itemBuilder: (context, index) {
        final ticket = _ticketHistory[index];
        return _buildTicketHistoryItem(ticket);
      },
    );
  }

  Widget _buildTicketHistoryItem(Map<String, dynamic> ticket) {
    final statusColor = _getStatusColor(ticket['status']);

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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              ticket['queueNumber'],
              style: AppTextStyles.h6.copyWith(color: statusColor),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ticket['department'],
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(ticket['doctor'],
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
                Text(ticket['date'],
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              ticket['status'],
              style: AppTextStyles.caption
                  .copyWith(color: statusColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppColors.success;
      case 'Cancelled':
        return AppColors.error;
      case 'No Show':
        return AppColors.cardOrange;
      default:
        return AppColors.cardBlue;
    }
  }

  final List<Map<String, dynamic>> _ticketHistory = [
    {
      'queueNumber': 'A-038',
      'department': 'General Medicine',
      'doctor': 'Dr. Maria Santos',
      'date': 'Nov 28, 2024',
      'status': 'Completed'
    },
    {
      'queueNumber': 'B-012',
      'department': 'Cardiology',
      'doctor': 'Dr. Juan Cruz',
      'date': 'Nov 20, 2024',
      'status': 'Completed'
    },
    {
      'queueNumber': 'A-055',
      'department': 'General Medicine',
      'doctor': 'Dr. Maria Santos',
      'date': 'Nov 15, 2024',
      'status': 'Completed'
    },
    {
      'queueNumber': 'C-003',
      'department': 'Dermatology',
      'doctor': 'Dr. Ana Reyes',
      'date': 'Nov 10, 2024',
      'status': 'Cancelled'
    },
    {
      'queueNumber': 'A-021',
      'department': 'General Medicine',
      'doctor': 'Dr. Jose Garcia',
      'date': 'Oct 25, 2024',
      'status': 'Completed'
    },
    {
      'queueNumber': 'D-008',
      'department': 'Pediatrics',
      'doctor': 'Dr. Lisa Tan',
      'date': 'Oct 18, 2024',
      'status': 'No Show'
    },
  ];
}
