import 'package:flutter/material.dart';
import '../../models/ticket_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
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
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  TicketModel? _activeTicket;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await _authService.getCurrentUserData();
    if (user != null && mounted) {
      final activeTicket =
          await _firestoreService.getPatientActiveTicket(user.id);
      setState(() {
        _currentUser = user;
        _activeTicket = activeTicket;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCurrentQueueTab(),
                _buildTicketHistoryTab(),
              ],
            ),
      floatingActionButton: null,
    );
  }

  Widget _buildCurrentQueueTab() {
    if (_activeTicket == null) {
      return _buildNoActiveTicket();
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildActiveQueueCard(),
          const SizedBox(height: 24),
          _buildQueueStatusCard(),
          const SizedBox(height: 24),
          _buildQueueProgressCard(),
        ],
      ),
    );
  }

  Widget _buildNoActiveTicket() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.confirmation_number_outlined,
                size: 80, color: AppColors.grey300),
            const SizedBox(height: 24),
            Text('No Active Ticket',
                style: AppTextStyles.h5.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(
              'Please proceed to the nurse station to create your queue ticket.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
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
              '${_activeTicket!.queueNumber}',
              style: AppTextStyles.h1.copyWith(
                fontSize: 56,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusBgColor(_activeTicket!.status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getStatusIcon(_activeTicket!.status),
                    color: AppColors.white, size: 18),
                const SizedBox(width: 8),
                Text(_activeTicket!.statusDisplay,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusBgColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.waiting:
        return AppColors.cardBlue;
      case TicketStatus.called:
        return AppColors.accent;
      case TicketStatus.inProgress:
        return AppColors.cardOrange;
      case TicketStatus.completed:
        return AppColors.success;
      case TicketStatus.cancelled:
      case TicketStatus.noShow:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon(TicketStatus status) {
    switch (status) {
      case TicketStatus.waiting:
        return Icons.hourglass_top;
      case TicketStatus.called:
        return Icons.notifications_active;
      case TicketStatus.inProgress:
        return Icons.medical_services;
      case TicketStatus.completed:
        return Icons.check_circle;
      case TicketStatus.cancelled:
      case TicketStatus.noShow:
        return Icons.cancel;
    }
  }

  Widget _buildQueueStatusCard() {
    final ticket = _activeTicket!;
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
          _buildDetailRow('Ticket ID', ticket.id.substring(0, 8).toUpperCase()),
          if (ticket.chiefComplaint != null &&
              ticket.chiefComplaint!.isNotEmpty)
            _buildDetailRow('Reason', ticket.chiefComplaint!),
          if (ticket.assignedDoctorName != null)
            _buildDetailRow('Doctor', ticket.assignedDoctorName!),
          _buildDetailRow('Date', _formatDate(ticket.createdAt)),
          _buildDetailRow('Time Issued', _formatTime(ticket.createdAt)),
          const Divider(height: 24),
          if (ticket.status == TicketStatus.waiting ||
              ticket.status == TicketStatus.called)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _cancelTicket(ticket.id),
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text('Cancel Ticket'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _cancelTicket(String ticketId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ticket'),
        content: const Text('Are you sure you want to cancel this ticket?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _firestoreService.cancelTicket(ticketId);
      setState(() => _activeTicket = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket cancelled'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
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
          Flexible(
            child: Text(value,
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueProgressCard() {
    final ticket = _activeTicket!;
    final isIssued = true;
    final isWaiting = ticket.status == TicketStatus.waiting ||
        ticket.status == TicketStatus.called ||
        ticket.status == TicketStatus.inProgress ||
        ticket.status == TicketStatus.completed;
    final isCalled = ticket.status == TicketStatus.called ||
        ticket.status == TicketStatus.inProgress ||
        ticket.status == TicketStatus.completed;
    final isInProgress = ticket.status == TicketStatus.inProgress ||
        ticket.status == TicketStatus.completed;
    final isCompleted = ticket.status == TicketStatus.completed;

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
          _buildProgressStep('Ticket Issued', _formatTime(ticket.createdAt),
              isIssued, isWaiting),
          _buildProgressStep('Waiting in Queue', '', isWaiting, isCalled),
          _buildProgressStep(
              'Called',
              ticket.calledAt != null ? _formatTime(ticket.calledAt!) : '',
              isCalled,
              isInProgress),
          _buildProgressStep('In Consultation', '', isInProgress, isCompleted),
          _buildProgressStep(
              'Completed',
              ticket.completedAt != null
                  ? _formatTime(ticket.completedAt!)
                  : '',
              isCompleted,
              false),
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
    if (_currentUser == null) {
      return const Center(child: Text('Please log in to view history'));
    }

    return StreamBuilder<List<TicketModel>>(
      stream: _firestoreService.getPatientTickets(_currentUser!.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }

        final tickets = snapshot.data ?? [];

        if (tickets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: AppColors.grey300),
                const SizedBox(height: 16),
                Text('No ticket history',
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final ticket = tickets[index];
            return _buildTicketHistoryItem(ticket);
          },
        );
      },
    );
  }

  Widget _buildTicketHistoryItem(TicketModel ticket) {
    final statusColor = _getStatusColorFromEnum(ticket.status);

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
              '${ticket.queueNumber}',
              style: AppTextStyles.h6.copyWith(color: statusColor),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ticket.chiefComplaint ?? 'General Consultation',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                if (ticket.assignedDoctorName != null)
                  Text(ticket.assignedDoctorName!,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary)),
                Text(_formatDate(ticket.createdAt),
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
              ticket.statusDisplay,
              style: AppTextStyles.caption
                  .copyWith(color: statusColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColorFromEnum(TicketStatus status) {
    switch (status) {
      case TicketStatus.completed:
        return AppColors.success;
      case TicketStatus.cancelled:
        return AppColors.error;
      case TicketStatus.noShow:
        return AppColors.cardOrange;
      case TicketStatus.waiting:
      case TicketStatus.called:
        return AppColors.cardBlue;
      case TicketStatus.inProgress:
        return AppColors.primary;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }
}
