import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Queue', 'Appointments', 'System'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text('Notifications',
            style: AppTextStyles.h5.copyWith(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all, size: 18),
            label: const Text('Mark all read'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                      onSelected: (selected) {
                        setState(() => _selectedFilter = filter);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Notifications List
          Expanded(
            child: _filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = _filteredNotifications[index];
                      return _buildNotificationCard(notification, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedFilter == 'All') return _notifications;
    return _notifications
        .where((n) => n['category'] == _selectedFilter)
        .toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 64, color: AppColors.grey400),
          const SizedBox(height: 16),
          Text('No notifications',
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text('You\'re all caught up!',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textHint)),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final isUnread = notification['isUnread'] as bool;
    final iconData = _getNotificationIcon(notification['type']);
    final iconColor = _getNotificationColor(notification['type']);

    return Dismissible(
      key: Key(notification['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: AppColors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          _notifications.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                setState(() {
                  _notifications.insert(index, notification);
                });
              },
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _handleNotificationTap(notification),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: isUnread
                ? Border.all(
                    color: AppColors.primary.withOpacity(0.3), width: 1)
                : null,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(iconData, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: isUnread
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['message'],
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 14, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(
                          notification['time'],
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textHint),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.grey200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            notification['category'],
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'queue_update':
        return Icons.people_outline;
      case 'queue_called':
        return Icons.campaign_outlined;
      case 'appointment_confirmed':
        return Icons.event_available;
      case 'appointment_reminder':
        return Icons.notifications_active_outlined;
      case 'doctor_ready':
        return Icons.medical_services_outlined;
      case 'nurse_ready':
        return Icons.health_and_safety_outlined;
      case 'system':
        return Icons.info_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'queue_update':
        return AppColors.cardBlue;
      case 'queue_called':
        return AppColors.success;
      case 'appointment_confirmed':
        return AppColors.cardGreen;
      case 'appointment_reminder':
        return AppColors.cardOrange;
      case 'doctor_ready':
        return AppColors.primary;
      case 'nurse_ready':
        return AppColors.cardCyan;
      case 'system':
        return AppColors.cardPurple;
      default:
        return AppColors.textSecondary;
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    setState(() {
      notification['isUnread'] = false;
    });

    // Show notification details
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification['type'])
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getNotificationIcon(notification['type']),
                    color: _getNotificationColor(notification['type']),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification['title'], style: AppTextStyles.h6),
                      Text(notification['time'],
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(notification['message'], style: AppTextStyles.bodyMedium),
            if (notification['action'] != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Handle action based on notification type
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary),
                  child: Text(notification['action']),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isUnread'] = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'type': 'queue_called',
      'category': 'Queue',
      'title': 'Your Turn is Coming!',
      'message':
          'You are now 2nd in queue. Please proceed to the waiting area near Room 105.',
      'time': '5 minutes ago',
      'isUnread': true,
      'action': 'View Queue Status',
    },
    {
      'id': '2',
      'type': 'appointment_confirmed',
      'category': 'Appointments',
      'title': 'Appointment Confirmed',
      'message':
          'Your appointment with Dr. Maria Santos on December 10, 2024 at 10:00 AM has been confirmed.',
      'time': '1 hour ago',
      'isUnread': true,
      'action': 'View Appointment',
    },
    {
      'id': '3',
      'type': 'nurse_ready',
      'category': 'Queue',
      'title': 'Nurse is Ready',
      'message':
          'The nurse is ready to take your vital signs. Please proceed to the nursing station.',
      'time': '2 hours ago',
      'isUnread': true,
      'action': null,
    },
    {
      'id': '4',
      'type': 'appointment_reminder',
      'category': 'Appointments',
      'title': 'Appointment Reminder',
      'message':
          'Reminder: You have an appointment tomorrow with Dr. Juan Cruz at 2:00 PM.',
      'time': 'Yesterday',
      'isUnread': false,
      'action': 'View Details',
    },
    {
      'id': '5',
      'type': 'queue_update',
      'category': 'Queue',
      'title': 'Queue Status Update',
      'message':
          'Your position in queue has changed. Current position: 5th. Estimated wait time: ~25 minutes.',
      'time': 'Yesterday',
      'isUnread': false,
      'action': null,
    },
    {
      'id': '6',
      'type': 'doctor_ready',
      'category': 'Queue',
      'title': 'Doctor is Ready',
      'message':
          'Dr. Maria Santos is ready to see you. Please proceed to Room 105.',
      'time': '2 days ago',
      'isUnread': false,
      'action': null,
    },
    {
      'id': '7',
      'type': 'system',
      'category': 'System',
      'title': 'Lab Results Available',
      'message':
          'Your Complete Blood Count (CBC) results are now available. You can view them in your medical records.',
      'time': '3 days ago',
      'isUnread': false,
      'action': 'View Results',
    },
    {
      'id': '8',
      'type': 'system',
      'category': 'System',
      'title': 'Prescription Ready',
      'message':
          'Your prescription has been prepared. You can pick it up at the pharmacy.',
      'time': '1 week ago',
      'isUnread': false,
      'action': null,
    },
  ];
}
