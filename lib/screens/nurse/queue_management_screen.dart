import 'package:flutter/material.dart';
import '../../models/ticket_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class QueueManagementScreen extends StatefulWidget {
  const QueueManagementScreen({super.key});

  @override
  State<QueueManagementScreen> createState() => _QueueManagementScreenState();
}

class _QueueManagementScreenState extends State<QueueManagementScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Waiting', 'In Progress', 'Completed'];
  int _waitingCount = 0;
  int _inProgressCount = 0;
  int _completedCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        backgroundColor: AppColors.cardTeal,
        foregroundColor: AppColors.white,
        title: const Text('Queue Management'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => setState(() {})),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewTicketDialog,
        backgroundColor: AppColors.cardTeal,
        icon: const Icon(Icons.add),
        label: const Text('New Ticket'),
      ),
      body: StreamBuilder<List<TicketModel>>(
        stream: _firestoreService.getTodayTickets(),
        builder: (context, snapshot) {
          final allTickets = snapshot.data ?? [];

          // Update counts
          _waitingCount = allTickets
              .where((t) =>
                  t.status == TicketStatus.waiting ||
                  t.status == TicketStatus.called)
              .length;
          _inProgressCount = allTickets
              .where((t) => t.status == TicketStatus.inProgress)
              .length;
          _completedCount = allTickets
              .where((t) => t.status == TicketStatus.completed)
              .length;

          // Filter tickets
          final tickets = _selectedFilter == 'All'
              ? allTickets
              : allTickets.where((t) => _matchesFilter(t.status)).toList();

          return Column(
            children: [
              // Stats Bar
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.white,
                child: Row(
                  children: [
                    _buildQuickStat(
                        'Waiting', '$_waitingCount', AppColors.cardOrange),
                    _buildQuickStat(
                        'In Progress', '$_inProgressCount', AppColors.cardBlue),
                    _buildQuickStat(
                        'Completed', '$_completedCount', AppColors.success),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _callNextPatient(allTickets),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.white,
                child: Row(
                  children: _filters
                      .map((f) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(f),
                              selected: _selectedFilter == f,
                              selectedColor:
                                  AppColors.cardTeal.withOpacity(0.2),
                              onSelected: (s) =>
                                  setState(() => _selectedFilter = f),
                            ),
                          ))
                      .toList(),
                ),
              ),
              // Queue List
              Expanded(
                child: tickets.isEmpty
                    ? Center(
                        child: Text('No tickets',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.textSecondary)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: tickets.length,
                        itemBuilder: (context, index) =>
                            _buildQueueCard(tickets[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _matchesFilter(TicketStatus status) {
    switch (_selectedFilter) {
      case 'Waiting':
        return status == TicketStatus.waiting || status == TicketStatus.called;
      case 'In Progress':
        return status == TicketStatus.inProgress;
      case 'Completed':
        return status == TicketStatus.completed;
      default:
        return true;
    }
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

  Widget _buildQueueCard(TicketModel ticket) {
    final statusColor = _getTicketStatusColor(ticket.status);
    final isUrgent = ticket.priority == TicketPriority.emergency;

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
                      '${ticket.queueNumber}',
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
                          Text(ticket.patientName,
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
                      Text(
                          '${ticket.chiefComplaint ?? "General"} • ${_formatTime(ticket.createdAt)}',
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
                  child: Text(ticket.statusDisplay,
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
                if (ticket.status == TicketStatus.waiting) ...[
                  _buildActionButton('Call', Icons.campaign, AppColors.cardBlue,
                      () => _callTicket(ticket)),
                  const SizedBox(width: 8),
                  _buildActionButton('Prioritize', Icons.priority_high,
                      AppColors.cardOrange, () => _prioritizeTicket(ticket)),
                ],
                if (ticket.status == TicketStatus.called ||
                    ticket.status == TicketStatus.inProgress) ...[
                  _buildActionButton('Complete', Icons.check_circle,
                      AppColors.success, () => _completeTicket(ticket)),
                ],
                const Spacer(),
                _buildActionButton('View', Icons.visibility,
                    AppColors.textSecondary, () => _viewTicket(ticket)),
                const SizedBox(width: 8),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert,
                      color: AppColors.textSecondary),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'forward', child: Text('Forward to Doctor')),
                    const PopupMenuItem(
                        value: 'cancel', child: Text('Cancel Ticket')),
                  ],
                  onSelected: (value) => _handleMenuAction(value, ticket),
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

  Color _getTicketStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.waiting:
        return AppColors.cardOrange;
      case TicketStatus.called:
      case TicketStatus.inProgress:
        return AppColors.cardBlue;
      case TicketStatus.completed:
        return AppColors.success;
      case TicketStatus.cancelled:
      case TicketStatus.noShow:
        return AppColors.error;
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${hour == 0 ? 12 : hour}:${dateTime.minute.toString().padLeft(2, '0')} $amPm';
  }

  void _callTicket(TicketModel ticket) async {
    await _firestoreService.callPatient(ticket.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Calling ${ticket.patientName}...')));
    }
  }

  void _prioritizeTicket(TicketModel ticket) async {
    await _firestoreService
        .updateTicket(ticket.id, {'priority': TicketPriority.emergency.name});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${ticket.patientName} marked as urgent')));
    }
  }

  void _completeTicket(TicketModel ticket) async {
    await _firestoreService.completeTicket(ticket.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${ticket.patientName} consultation completed')));
    }
  }

  void _viewTicket(TicketModel ticket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Row(children: [
              CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(ticket.patientName[0],
                      style:
                          AppTextStyles.h4.copyWith(color: AppColors.primary))),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(ticket.patientName, style: AppTextStyles.h5),
                Text(
                    'Queue #${ticket.queueNumber} • ${ticket.chiefComplaint ?? "General"}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ]),
            ]),
            const SizedBox(height: 24),
            _buildInfoRow('Status', ticket.statusDisplay),
            _buildInfoRow('Time In', _formatTime(ticket.createdAt)),
            _buildInfoRow('Priority', ticket.priorityDisplay),
            if (ticket.department != null)
              _buildInfoRow('Department', ticket.department!),
            const SizedBox(height: 24),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cardTeal),
                  child: const Text('Close'),
                )),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action, TicketModel ticket) async {
    switch (action) {
      case 'forward':
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${ticket.patientName} forwarded to doctor')));
        break;
      case 'cancel':
        await _firestoreService.cancelTicket(ticket.id);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Ticket for ${ticket.patientName} cancelled')));
        break;
    }
  }

  void _showNewTicketDialog() {
    String? selectedVisitType;
    bool isUrgent = false;
    final patientNameController = TextEditingController();
    final contactController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Generate New Ticket'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: patientNameController,
                  style: const TextStyle(color: AppColors.inputText),
                  decoration: const InputDecoration(
                    labelText: 'Patient Name',
                    hintText: 'Enter patient name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contactController,
                  style: const TextStyle(color: AppColors.inputText),
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Contact Number',
                    hintText: 'Enter contact number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedVisitType,
                  dropdownColor: AppColors.inputBackground,
                  style: const TextStyle(color: AppColors.inputText),
                  decoration: const InputDecoration(
                    labelText: 'Visit Type',
                    hintText: 'Select visit type',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: [
                    'General Consultation',
                    'Follow-up',
                    'Laboratory',
                    'Pharmacy'
                  ]
                      .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e,
                              style:
                                  const TextStyle(color: AppColors.inputText))))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedVisitType = value);
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Mark as Urgent'),
                  value: isUrgent,
                  onChanged: (value) {
                    setDialogState(() => isUrgent = value);
                  },
                  activeColor: AppColors.error,
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
      ),
    );
  }

  void _callNextPatient(List<TicketModel> tickets) {
    final waitingTickets =
        tickets.where((t) => t.status == TicketStatus.waiting).toList();
    if (waitingTickets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No patients waiting in queue')));
      return;
    }

    final nextTicket = waitingTickets.first;
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
            Text('Queue #${nextTicket.queueNumber}',
                style: AppTextStyles.h3.copyWith(color: AppColors.cardBlue)),
            const SizedBox(height: 8),
            Text(nextTicket.patientName, style: AppTextStyles.h5),
            const SizedBox(height: 16),
            const Text(
                'Patient will be notified. Please wait for them to arrive.'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _firestoreService.callPatient(nextTicket.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('${nextTicket.patientName} has been called')));
            },
            child: const Text('Confirm Call'),
          ),
        ],
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
}
