import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/dashboard_tile.dart';
import '../../widgets/sidebar_item.dart';
import '../../widgets/info_card.dart';
import '../../widgets/simple_calendar.dart';
import '../auth/login_screen.dart';
import 'profile_screen.dart';
import 'queue_screen.dart';
import 'appointments_screen.dart';
import 'records_screen.dart';
import 'notifications_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _selectedNavIndex = 0;
  bool _isSidebarExpanded = true;

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard'),
    _NavItem(icon: Icons.person_outline, label: 'My Profile'),
    _NavItem(
        icon: Icons.confirmation_number_outlined,
        label: 'Queue & Tickets',
        badgeCount: 1),
    _NavItem(icon: Icons.calendar_today_outlined, label: 'Appointments'),
    _NavItem(icon: Icons.folder_outlined, label: 'Medical Records'),
    _NavItem(
        icon: Icons.notifications_outlined,
        label: 'Notifications',
        badgeCount: 3),
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
                        // if (!isMobile)
                        //   SizedBox(
                        //     width: isSmallScreen ? 280 : 320,
                        //     child: _buildRightPanel(),
                        //   ),
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
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo
          Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 36,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_hospital,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Text(
                'Medical Ticketing System',
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          // User Profile
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: AppColors.white),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.accent,
                      child: Text(
                        'JD',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'John Doe',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isSidebarExpanded ? 220 : 60,
      decoration: const BoxDecoration(
        color: AppColors.secondary,
      ),
      child: Column(
        children: [
          // Toggle Button
          Container(
            padding: const EdgeInsets.all(8),
            child: IconButton(
              icon: Icon(
                _isSidebarExpanded ? Icons.menu_open : Icons.menu,
                color: AppColors.white,
              ),
              onPressed: () {
                setState(() {
                  _isSidebarExpanded = !_isSidebarExpanded;
                });
              },
            ),
          ),
          const Divider(color: AppColors.secondaryLight, height: 1),
          // Nav Items
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
                    setState(() {
                      _selectedNavIndex = index;
                    });
                    _handleNavigation(index);
                  },
                );
              },
            ),
          ),
          // Logout
          const Divider(color: AppColors.secondaryLight, height: 1),
          SidebarItem(
            icon: Icons.logout,
            label: 'Logout',
            isExpanded: _isSidebarExpanded,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
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
          // Breadcrumb
          Row(
            children: [
              const Icon(Icons.home, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                'Home',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                'Dashboard',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Welcome Message
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, John Doe',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'How can we help you today?',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.waving_hand,
                    color: AppColors.accent,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Dashboard Tiles Grid
          _buildDashboardGrid(),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid() {
    final tiles = [
      _TileData(
          Icons.confirmation_number_outlined, 'View Queue', AppColors.cardRed,
          badgeCount: 1),
      _TileData(
          Icons.receipt_long_outlined, 'Ticket History', AppColors.cardYellow),
      _TileData(Icons.calendar_today_outlined, 'Book Appointment',
          AppColors.cardBlue),
      _TileData(
          Icons.event_note_outlined, 'My Appointments', AppColors.cardTeal),
      _TileData(Icons.folder_outlined, 'Medical Records', AppColors.cardGreen),
      _TileData(Icons.person_outline, 'My Profile', AppColors.cardIndigo),
      _TileData(
          Icons.notifications_outlined, 'Notifications', AppColors.cardOrange,
          badgeCount: 3),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 5;
        if (constraints.maxWidth < 1000) crossAxisCount = 4;
        if (constraints.maxWidth < 800) crossAxisCount = 3;
        if (constraints.maxWidth < 600) crossAxisCount = 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: tiles.length,
          itemBuilder: (context, index) {
            final tile = tiles[index];
            return DashboardTile(
              icon: tile.icon,
              label: tile.label,
              backgroundColor: tile.color,
              badgeCount: tile.badgeCount,
              onTap: () => _handleTileTap(tile.label),
            );
          },
        );
      },
    );
  }

  Widget _buildRightPanel() {
    return Container(
      color: AppColors.grey100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Outstanding Balance Card
            InfoCard(
              title: 'Outstanding Balance',
              value: 'PHP 2,500.00',
              valueColor: AppColors.accent,
            ),
            const SizedBox(height: 16),
            // Calendar Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const SimpleCalendar(),
            ),
            const SizedBox(height: 16),
            // Notice Board
            InfoCard(
              title: 'Notice Board',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNoticeItem(
                    'System Maintenance',
                    'Scheduled maintenance on Dec 15, 2025',
                    Icons.build_circle_outlined,
                  ),
                  const Divider(),
                  _buildNoticeItem(
                    'Holiday Hours',
                    'Modified hours during the holiday season',
                    Icons.schedule_outlined,
                  ),
                  const Divider(),
                  _buildNoticeItem(
                    'New Feature',
                    'Online prescription refill now available',
                    Icons.new_releases_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoticeItem(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0: // Dashboard - stay on current screen
        return;
      case 1: // My Profile
        _navigateTo(const ProfileScreen());
        break;
      case 2: // Queue & Tickets
        _navigateTo(const QueueScreen());
        break;
      case 3: // Appointments
        _navigateTo(const AppointmentsScreen());
        break;
      case 4: // Medical Records
        _navigateTo(const RecordsScreen());
        break;
      case 5: // Notifications
        _navigateTo(const NotificationsScreen());
        break;
    }
  }

  void _handleTileTap(String label) {
    switch (label) {
      case 'View Queue':
      case 'Ticket History':
        _navigateTo(const QueueScreen());
        break;
      case 'Book Appointment':
      case 'My Appointments':
        _navigateTo(const AppointmentsScreen());
        break;
      case 'Medical Records':
        _navigateTo(const RecordsScreen());
        break;
      case 'My Profile':
        _navigateTo(const ProfileScreen());
        break;
      case 'Notifications':
        _navigateTo(const NotificationsScreen());
        break;
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final int? badgeCount;

  _NavItem({
    required this.icon,
    required this.label,
    this.badgeCount,
  });
}

class _TileData {
  final IconData icon;
  final String label;
  final Color color;
  final int? badgeCount;

  _TileData(this.icon, this.label, this.color, {this.badgeCount});
}
