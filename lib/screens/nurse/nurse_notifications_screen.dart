import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class NurseNotificationsScreen extends StatefulWidget {
  const NurseNotificationsScreen({super.key});

  @override
  State<NurseNotificationsScreen> createState() =>
      _NurseNotificationsScreenState();
}

class _NurseNotificationsScreenState extends State<NurseNotificationsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getCurrentUserData();
    if (mounted && user != null) setState(() => _currentUserId = user.id);
  }

  @override
  void dispose() {
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
      ),
      body: _buildNotificationsTab(),
    );
  }

  Widget _buildNotificationsTab() {
    if (_currentUserId == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    return StreamBuilder<List<NotificationModel>>(
      stream: _firestoreService.getUserNotifications(_currentUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        final notifications = snapshot.data ?? [];
        if (notifications.isEmpty) {
          return Center(
              child: Text('No notifications',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          itemBuilder: (context, index) =>
              _buildNotificationCardFromModel(notifications[index]),
        );
      },
    );
  }

  Widget _buildNotificationCardFromModel(NotificationModel notification) {
    final iconColor = _getNotificationColorFromType(notification.type);
    final icon = _getNotificationIconFromType(notification.type);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: !notification.isRead
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
                Row(children: [
                  Expanded(
                      child: Text(notification.title,
                          style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: !notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.normal))),
                  if (!notification.isRead)
                    Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.cardTeal, shape: BoxShape.circle)),
                ]),
                const SizedBox(height: 4),
                Text(notification.message,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.access_time, size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(_formatTime(notification.createdAt),
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textHint)),
                  const Spacer(),
                  if (!notification.isRead)
                    TextButton(
                      onPressed: () => _firestoreService
                          .markNotificationAsRead(notification.id),
                      child: const Text('Mark Read'),
                    ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getNotificationColorFromType(NotificationType type) {
    switch (type) {
      case NotificationType.queue:
        return AppColors.cardBlue;
      case NotificationType.appointment:
        return AppColors.cardGreen;
      case NotificationType.alert:
        return AppColors.error;
      case NotificationType.system:
        return AppColors.cardPurple;
    }
  }

  IconData _getNotificationIconFromType(NotificationType type) {
    switch (type) {
      case NotificationType.queue:
        return Icons.person;
      case NotificationType.appointment:
        return Icons.medical_services;
      case NotificationType.alert:
        return Icons.priority_high;
      case NotificationType.system:
        return Icons.info;
    }
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }
}
