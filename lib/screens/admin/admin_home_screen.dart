import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/dashboard_tile.dart';
import '../../widgets/sidebar_item.dart';
import '../auth/login_screen.dart';
import 'user_management_screen.dart';
import 'system_config_screen.dart';
import 'reports_screen.dart';
import 'audit_log_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  UserModel? _currentUser;
  int _selectedNavIndex = 0;
  bool _isSidebarExpanded = true;
  int _totalUsers = 0;
  int _totalDoctors = 0;
  int _totalNurses = 0;
  int _todayTickets = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await _authService.getCurrentUserData();
    if (user != null && mounted) {
      setState(() => _currentUser = user);
    }
    // Get stats
    final stats = await _firestoreService.getAdminDashboardStats();
    if (mounted) {
      setState(() {
        _totalUsers = stats['totalUsers'] ?? 0;
        _totalDoctors = stats['totalDoctors'] ?? 0;
        _totalNurses = stats['totalNurses'] ?? 0;
        _todayTickets = stats['todayTickets'] ?? 0;
      });
    }
  }

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard'),
    _NavItem(icon: Icons.people_outlined, label: 'User Management'),
    _NavItem(icon: Icons.settings_outlined, label: 'System Config'),
    _NavItem(icon: Icons.analytics_outlined, label: 'Reports'),
    _NavItem(icon: Icons.history_outlined, label: 'Audit Log'),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;
    if (isMobile) _isSidebarExpanded = false;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Row(
              children: [
                _buildSidebar(),
                Expanded(
                    child: Container(
                        color: AppColors.grey100, child: _buildMainContent())),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Image.asset('assets/images/logo.png',
              height: 36,
              errorBuilder: (_, __, ___) => const Icon(Icons.local_hospital,
                  color: AppColors.white, size: 36)),
          const SizedBox(width: 12),
          Text('Medical Ticketing',
              style: AppTextStyles.h5.copyWith(color: AppColors.white)),
          Container(
            margin: const EdgeInsets.only(left: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
                color: AppColors.cardRed.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4)),
            child: Text('ADMIN',
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.white, fontWeight: FontWeight.bold)),
          ),
          const Spacer(),
          IconButton(
              icon: const Icon(Icons.notifications_outlined,
                  color: AppColors.white),
              onPressed: () {}),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                const CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.cardRed,
                    child: Icon(Icons.admin_panel_settings,
                        size: 16, color: AppColors.white)),
                const SizedBox(width: 8),
                Text(_currentUser?.fullName ?? 'Admin',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isSidebarExpanded ? 220 : 60,
      decoration: const BoxDecoration(color: Color(0xFF16213E)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: IconButton(
              icon: Icon(_isSidebarExpanded ? Icons.menu_open : Icons.menu,
                  color: AppColors.white),
              onPressed: () =>
                  setState(() => _isSidebarExpanded = !_isSidebarExpanded),
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                return SidebarItem(
                  icon: item.icon,
                  label: item.label,
                  isSelected: _selectedNavIndex == index,
                  isExpanded: _isSidebarExpanded,
                  onTap: () {
                    setState(() => _selectedNavIndex = index);
                    _handleNavigation(index);
                  },
                );
              },
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          SidebarItem(
              icon: Icons.logout,
              label: 'Logout',
              isExpanded: _isSidebarExpanded,
              onTap: () async {
                await _authService.logout();
                if (mounted) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
                }
              }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Admin Dashboard', style: AppTextStyles.h4),
          Text('System overview and quick actions',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          _buildStatsRow(),
          const SizedBox(height: 24),
          Text('Quick Actions', style: AppTextStyles.h6),
          const SizedBox(height: 16),
          _buildQuickActionsGrid(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildRecentActivity()),
              const SizedBox(width: 24),
              Expanded(child: _buildSystemStatus()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
            child: _buildStatCard('Total Users', '$_totalUsers',
                AppColors.cardBlue, Icons.people, 'All registered users')),
        const SizedBox(width: 16),
        Expanded(
            child: _buildStatCard(
                'Today\'s Tickets',
                '$_todayTickets',
                AppColors.cardGreen,
                Icons.confirmation_number,
                'Queue tickets')),
        const SizedBox(width: 16),
        Expanded(
            child: _buildStatCard(
                'Doctors',
                '$_totalDoctors',
                AppColors.cardPurple,
                Icons.medical_services,
                'Registered doctors')),
        const SizedBox(width: 16),
        Expanded(
            child: _buildStatCard(
                'Nurses',
                '$_totalNurses',
                AppColors.cardOrange,
                Icons.health_and_safety,
                'Registered nurses')),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AppTextStyles.h3.copyWith(color: color)),
                Text(label,
                    style: AppTextStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textHint)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    final tiles = [
      _TileData(Icons.person_add, 'Add User', AppColors.cardBlue),
      _TileData(Icons.schedule, 'Manage Schedules', AppColors.cardGreen),
      _TileData(Icons.meeting_room, 'Departments', AppColors.cardPurple),
      _TileData(Icons.assessment, 'View Reports', AppColors.cardOrange),
      _TileData(Icons.rule, 'Queue Rules', AppColors.cardCyan),
      _TileData(Icons.security, 'Audit Logs', AppColors.cardIndigo),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2),
      itemCount: tiles.length,
      itemBuilder: (context, index) {
        final tile = tiles[index];
        return DashboardTile(
            icon: tile.icon,
            label: tile.label,
            backgroundColor: tile.color,
            onTap: () => _handleTileTap(tile.label));
      },
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Activity', style: AppTextStyles.h6),
              TextButton(
                  onPressed: () => _navigateTo(const AuditLogScreen()),
                  child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 16),
          _buildActivityItem('New patient registered', 'Juan Dela Cruz',
              '5 min ago', Icons.person_add, AppColors.cardGreen),
          _buildActivityItem('Doctor schedule updated', 'Dr. Maria Santos',
              '15 min ago', Icons.schedule, AppColors.cardBlue),
          _buildActivityItem('User role changed', 'Nurse Ana Reyes',
              '1 hour ago', Icons.admin_panel_settings, AppColors.cardPurple),
          _buildActivityItem('Medical record edited', 'Pedro Garcia',
              '2 hours ago', Icons.edit, AppColors.cardOrange),
          _buildActivityItem('New nurse account created', 'Rosa Luna',
              '3 hours ago', Icons.person_add, AppColors.cardCyan),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
      String action, String user, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.grey100, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(action,
                    style: AppTextStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(user,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(time,
              style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
        ],
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System Status', style: AppTextStyles.h6),
          const SizedBox(height: 16),
          _buildStatusItem('Server', 'Online', AppColors.success),
          _buildStatusItem('Database', 'Connected', AppColors.success),
          _buildStatusItem('Queue Service', 'Running', AppColors.success),
          _buildStatusItem('Backup', 'Scheduled', AppColors.cardOrange),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Text('User Summary',
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _buildUserCount('Patients', 120, AppColors.cardGreen),
          _buildUserCount('Nurses', 15, AppColors.cardBlue),
          _buildUserCount('Doctors', 12, AppColors.cardPurple),
          _buildUserCount('Admins', 4, AppColors.cardRed),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Text(label, style: AppTextStyles.bodySmall),
          const Spacer(),
          Text(status,
              style: AppTextStyles.caption
                  .copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildUserCount(String role, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Text(role, style: AppTextStyles.bodySmall),
          const Spacer(),
          Text('$count',
              style: AppTextStyles.bodySmall
                  .copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        return;
      case 1:
        _navigateTo(const UserManagementScreen());
        break;
      case 2:
        _navigateTo(const SystemConfigScreen());
        break;
      case 3:
        _navigateTo(const ReportsScreen());
        break;
      case 4:
        _navigateTo(const AuditLogScreen());
        break;
    }
  }

  void _handleTileTap(String label) {
    switch (label) {
      case 'Add User':
        _navigateTo(const UserManagementScreen());
        break;
      case 'Manage Schedules':
      case 'Departments':
      case 'Queue Rules':
        _navigateTo(const SystemConfigScreen());
        break;
      case 'View Reports':
        _navigateTo(const ReportsScreen());
        break;
      case 'Audit Logs':
        _navigateTo(const AuditLogScreen());
        break;
    }
  }

  void _navigateTo(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}

class _NavItem {
  final IconData icon;
  final String label;
  _NavItem({required this.icon, required this.label});
}

class _TileData {
  final IconData icon;
  final String label;
  final Color color;
  _TileData(this.icon, this.label, this.color);
}
