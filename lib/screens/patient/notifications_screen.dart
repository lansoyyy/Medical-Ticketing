import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import 'queue_screen.dart';
import 'appointments_screen.dart';
import 'records_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Queue', 'Appointment', 'System'];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUserData();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    }
  }

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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _currentUser == null
              ? const Center(child: Text('Please log in'))
              : Column(
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
                                selectedColor:
                                    AppColors.primary.withOpacity(0.2),
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
                    Expanded(child: _buildNotificationsList()),
                  ],
                ),
    );
  }

  Widget _buildNotificationsList() {
    return StreamBuilder<List<NotificationModel>>(
      stream: _firestoreService.getUserNotifications(_currentUser!.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }

        final allNotifications = snapshot.data ?? [];
        final notifications = _selectedFilter == 'All'
            ? allNotifications
            : allNotifications
                .where((n) => _getFilterCategory(n.type) == _selectedFilter)
                .toList();

        if (notifications.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            return _buildNotificationCard(notifications[index]);
          },
        );
      },
    );
  }

  String _getFilterCategory(NotificationType type) {
    switch (type) {
      case NotificationType.queue:
        return 'Queue';
      case NotificationType.appointment:
        return 'Appointment';
      case NotificationType.system:
      case NotificationType.alert:
        return 'System';
    }
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

  Widget _buildNotificationCard(NotificationModel notification) {
    final iconData = _getNotificationIcon(notification.type);
    final iconColor = _getNotificationColor(notification.type);

    return GestureDetector(
      onTap: () => _handleNotificationTap(notification),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: !notification.isRead
              ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 1)
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
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(iconData, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: !notification.isRead
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
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
                    notification.message,
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
                        _formatTime(notification.createdAt),
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
                          notification.typeDisplay,
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
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.queue:
        return Icons.confirmation_number_outlined;
      case NotificationType.appointment:
        return Icons.event_available;
      case NotificationType.system:
        return Icons.info_outline;
      case NotificationType.alert:
        return Icons.warning_amber_outlined;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.queue:
        return AppColors.cardBlue;
      case NotificationType.appointment:
        return AppColors.cardGreen;
      case NotificationType.system:
        return AppColors.cardPurple;
      case NotificationType.alert:
        return AppColors.cardOrange;
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read
    if (!notification.isRead) {
      _firestoreService.markNotificationAsRead(notification.id);
    }

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
                    color: _getNotificationColor(notification.type)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: _getNotificationColor(notification.type),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.title, style: AppTextStyles.h6),
                      Text(_formatTime(notification.createdAt),
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(notification.message, style: AppTextStyles.bodyMedium),
            if (notification.actionUrl != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleNotificationAction(notification);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary),
                  child: const Text('View Details'),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _handleNotificationAction(NotificationModel notification) {
    switch (notification.type) {
      case NotificationType.queue:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const QueueScreen()));
        break;
      case NotificationType.appointment:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AppointmentsScreen()));
        break;
      case NotificationType.system:
      case NotificationType.alert:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const RecordsScreen()));
        break;
    }
  }

  void _markAllAsRead() async {
    if (_currentUser != null) {
      await _firestoreService.markAllNotificationsAsRead(_currentUser!.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications marked as read')),
      );
    }
  }
}
