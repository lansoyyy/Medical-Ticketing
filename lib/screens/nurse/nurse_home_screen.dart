import 'package:flutter/material.dart';
import '../../models/ticket_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/dashboard_tile.dart';
import '../../widgets/sidebar_item.dart';
import '../auth/login_screen.dart';
import 'queue_management_screen.dart';
import 'patient_list_screen.dart';
import 'nurse_notifications_screen.dart';

class NurseHomeScreen extends StatefulWidget {
  const NurseHomeScreen({super.key});

  @override
  State<NurseHomeScreen> createState() => _NurseHomeScreenState();
}

class _NurseHomeScreenState extends State<NurseHomeScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  UserModel? _currentUser;
  int _selectedNavIndex = 0;
  bool _isSidebarExpanded = true;
  int _waitingCount = 0;
  int _inProgressCount = 0;
  int _completedCount = 0;
  List<TicketModel> _queueTickets = [];

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
    // Listen to today's tickets
    _firestoreService.getTodayTickets().listen((tickets) {
      if (mounted) {
        setState(() {
          _queueTickets = tickets
              .where((t) =>
                  t.status == TicketStatus.waiting ||
                  t.status == TicketStatus.called ||
                  t.status == TicketStatus.inProgress)
              .take(5)
              .toList();
          _waitingCount = tickets
              .where((t) =>
                  t.status == TicketStatus.waiting ||
                  t.status == TicketStatus.called ||
                  t.status == TicketStatus.inProgress)
              .length;
          _inProgressCount =
              tickets.where((t) => t.status == TicketStatus.inProgress).length;
          _completedCount =
              tickets.where((t) => t.status == TicketStatus.completed).length;
        });
      }
    });
  }

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard'),
    _NavItem(
        icon: Icons.confirmation_number_outlined,
        label: 'Queue Management',
        badgeCount: 8),
    _NavItem(icon: Icons.people_outlined, label: 'Patient List'),
    _NavItem(
        icon: Icons.notifications_outlined,
        label: 'Notifications',
        badgeCount: 2),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1200;
    final isMobile = screenWidth < 800;

    if (isMobile) {
      _isSidebarExpanded = false;
    }

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
                    color: AppColors.grey100,
                    child: Row(
                      children: [
                        Expanded(
                          flex: isSmallScreen ? 1 : 3,
                          child: _buildMainContent(),
                        ),
                      ],
                    ),
                  ),
                ),
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
        color: AppColors.cardTeal,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Row(
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
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4)),
                child: Text('NURSE',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.white, fontWeight: FontWeight.bold)),
              ),
            ],
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
                    backgroundColor: AppColors.white,
                    child: Icon(Icons.person,
                        size: 18, color: AppColors.cardTeal)),
                const SizedBox(width: 8),
                Text(_currentUser?.fullName ?? 'Nurse',
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
      decoration: const BoxDecoration(color: Color(0xFF1A4A4A)),
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
                  badgeCount: item.badgeCount,
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
            },
          ),
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
          Row(
            children: [
              const Icon(Icons.home, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('Home',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary)),
              const Icon(Icons.chevron_right,
                  size: 16, color: AppColors.textSecondary),
              Text('Dashboard',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 16),
          // Welcome Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: AppColors.cardTeal,
                borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Good Morning, ${_currentUser?.firstName ?? 'Nurse'}!',
                          style: AppTextStyles.h4
                              .copyWith(color: AppColors.white)),
                      const SizedBox(height: 4),
                      Text('You have $_waitingCount tickets in process today.',
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white.withOpacity(0.9))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(50)),
                  child: const Icon(Icons.medical_services,
                      color: AppColors.white, size: 32),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Stats Cards
          _buildStatsRow(),
          const SizedBox(height: 24),
          // Quick Actions
          Text('Quick Actions', style: AppTextStyles.h6),
          const SizedBox(height: 16),
          _buildDashboardGrid(),
          const SizedBox(height: 24),
          // Recent Activity
          const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final urgentCount = _queueTickets
        .where((t) => t.priority == TicketPriority.emergency)
        .length;
    return Row(
      children: [
        Expanded(
            child: _buildStatCard('In Process', '$_waitingCount',
                AppColors.cardOrange, Icons.hourglass_empty)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildStatCard('In Progress', '$_inProgressCount',
                AppColors.cardBlue, Icons.medical_services)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildStatCard('Completed', '$_completedCount',
                AppColors.success, Icons.check_circle)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildStatCard('Urgent', '$urgentCount', AppColors.error,
                Icons.priority_high)),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon) {
    return Container(
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTextStyles.h4.copyWith(color: color)),
              Text(label,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid() {
    final tiles = [
      _TileData(Icons.add_box_outlined, 'New Ticket', AppColors.cardRed),
      _TileData(Icons.confirmation_number_outlined, 'Queue Management',
          AppColors.cardBlue),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 600 ? 2 : 3;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: tiles.length,
          itemBuilder: (context, index) {
            final tile = tiles[index];
            return DashboardTile(
              icon: tile.icon,
              label: tile.label,
              backgroundColor: tile.color,
              onTap: () => _handleTileTap(tile.label),
            );
          },
        );
      },
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        return;
      case 1:
        _navigateTo(const QueueManagementScreen());
        break;
      case 2:
        _navigateTo(const PatientListScreen());
        break;
      case 3:
        _navigateTo(const NurseNotificationsScreen());
        break;
    }
  }

  void _handleTileTap(String label) {
    switch (label) {
      case 'New Ticket':
      case 'Queue Management':
        _navigateTo(const QueueManagementScreen());
        break;
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final int? badgeCount;
  _NavItem({required this.icon, required this.label, this.badgeCount});
}

class _TileData {
  final IconData icon;
  final String label;
  final Color color;
  _TileData(this.icon, this.label, this.color);
}
