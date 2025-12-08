import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/dashboard_tile.dart';
import '../../widgets/sidebar_item.dart';
import '../../widgets/info_card.dart';
import '../auth/login_screen.dart';
import 'consultation_screen.dart';
import 'patient_records_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  final AuthService _authService = AuthService();
  int _selectedNavIndex = 0;
  bool _isSidebarExpanded = true;

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard'),
    _NavItem(
        icon: Icons.people_outlined, label: 'Patient Queue', badgeCount: 5),
    _NavItem(icon: Icons.folder_outlined, label: 'Patient Records'),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1200;
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
                    color: AppColors.grey100,
                    child: Row(
                      children: [
                        Expanded(
                            flex: isSmallScreen ? 1 : 3,
                            child: _buildMainContent()),
                        if (!isMobile)
                          SizedBox(
                              width: isSmallScreen ? 280 : 320,
                              child: _buildRightPanel()),
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
        color: AppColors.cardBlue,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
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
                child: Text('DOCTOR',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: AppColors.success, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('Available',
                    style:
                        AppTextStyles.caption.copyWith(color: AppColors.white)),
              ],
            ),
          ),
          const SizedBox(width: 16),
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
                        size: 18, color: AppColors.cardBlue)),
                const SizedBox(width: 8),
                Text('Dr. Maria Santos',
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
      decoration: const BoxDecoration(color: Color(0xFF1A3A5F)),
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: AppColors.cardBlue,
                borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good Morning, Dr. Santos!',
                          style: AppTextStyles.h4
                              .copyWith(color: AppColors.white)),
                      const SizedBox(height: 4),
                      Text('You have 5 patients waiting in your queue.',
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
          _buildStatsRow(),
          const SizedBox(height: 24),
          Text('Quick Actions', style: AppTextStyles.h6),
          const SizedBox(height: 16),
          _buildDashboardGrid(),
          const SizedBox(height: 24),
          _buildPatientQueue(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
            child: _buildStatCard(
                'In Queue', '5', AppColors.cardOrange, Icons.people)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildStatCard(
                'Completed Today', '8', AppColors.success, Icons.check_circle)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildStatCard(
                'Follow-ups', '3', AppColors.cardPurple, Icons.event_repeat)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildStatCard(
                'Pending Labs', '2', AppColors.cardCyan, Icons.science)),
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
      _TileData(Icons.person_add, 'Accept Patient', AppColors.cardGreen),
      _TileData(Icons.assignment, 'New Diagnosis', AppColors.cardBlue),
      _TileData(Icons.medication, 'Write Prescription', AppColors.cardPurple),
      _TileData(Icons.description, 'Issue Certificate', AppColors.cardOrange),
      _TileData(Icons.science, 'Order Lab Test', AppColors.cardCyan),
      _TileData(Icons.search, 'Search Records', AppColors.cardIndigo),
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

  Widget _buildPatientQueue() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Patient Queue', style: AppTextStyles.h6),
              ElevatedButton.icon(
                onPressed: () => _navigateTo(const ConsultationScreen()),
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Accept Next'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardGreen),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._queuePatients.map((p) => _buildQueuePatientRow(p)),
        ],
      ),
    );
  }

  Widget _buildQueuePatientRow(Map<String, dynamic> patient) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
        border: patient['urgent'] == true
            ? Border.all(color: AppColors.error)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: AppColors.cardBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Center(
                child: Text(patient['queue'],
                    style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.cardBlue))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(patient['name'],
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w600)),
                    if (patient['urgent'] == true) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(4)),
                        child: Text('URGENT',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.white, fontSize: 10)),
                      ),
                    ],
                  ],
                ),
                Text('${patient['age']} • ${patient['complaint']}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(patient['waitTime'],
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => _acceptPatient(patient),
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            color: AppColors.cardBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel() {
    return Container(
      color: AppColors.grey100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InfoCard(
              title: 'Today\'s Schedule',
              child: Column(
                children: [
                  _buildScheduleItem('8:00 AM', 'OPD Start'),
                  _buildScheduleItem('12:00 PM', 'Lunch Break'),
                  _buildScheduleItem('1:00 PM', 'Resume OPD'),
                  _buildScheduleItem('5:00 PM', 'OPD End'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(String time, String activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(time,
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.cardBlue, fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          Text(activity, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity',
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _buildActivityItem(
              'Completed consultation', 'Juan Dela Cruz', '10 min ago'),
          _buildActivityItem('Issued prescription', 'Ana Reyes', '25 min ago'),
          _buildActivityItem('Ordered lab test', 'Pedro Garcia', '1 hour ago'),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String action, String patient, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 4),
            decoration: const BoxDecoration(
                color: AppColors.cardBlue, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(action, style: AppTextStyles.bodySmall),
                Text(patient,
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

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        return;
      case 1:
        _navigateTo(const ConsultationScreen());
        break;
      case 2:
        _navigateTo(const PatientRecordsScreen());
        break;
    }
  }

  void _handleTileTap(String label) {
    switch (label) {
      case 'Accept Patient':
      case 'New Diagnosis':
      case 'Write Prescription':
      case 'Issue Certificate':
      case 'Order Lab Test':
        _navigateTo(const ConsultationScreen());
        break;
      case 'Search Records':
        _navigateTo(const PatientRecordsScreen());
        break;
    }
  }

  void _acceptPatient(Map<String, dynamic> patient) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ConsultationScreen(patient: patient)));
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  final List<Map<String, dynamic>> _queuePatients = [
    {
      'queue': '02',
      'name': 'Maria Santos',
      'age': '32 yrs, F',
      'complaint': 'Follow-up checkup',
      'waitTime': '15 min',
      'urgent': true
    },
    {
      'queue': '03',
      'name': 'Pedro Garcia',
      'age': '28 yrs, M',
      'complaint': 'Cough and cold',
      'waitTime': '25 min',
      'urgent': false
    },
    {
      'queue': '04',
      'name': 'Ana Reyes',
      'age': '55 yrs, F',
      'complaint': 'BP monitoring',
      'waitTime': '35 min',
      'urgent': false
    },
    {
      'queue': '05',
      'name': 'Jose Rizal',
      'age': '62 yrs, M',
      'complaint': 'Diabetes follow-up',
      'waitTime': '45 min',
      'urgent': false
    },
    {
      'queue': '06',
      'name': 'Rosa Luna',
      'age': '40 yrs, F',
      'complaint': 'Headache',
      'waitTime': '55 min',
      'urgent': false
    },
  ];
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
