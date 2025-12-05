import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'This Month';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: AppColors.white,
        title: const Text('Reports & Analytics'),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: DropdownButton<String>(
              value: _selectedPeriod,
              dropdownColor: const Color(0xFF1A1A2E),
              style: const TextStyle(color: AppColors.white),
              underline: const SizedBox(),
              items: ['Today', 'This Week', 'This Month', 'This Year']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedPeriod = v!),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
              icon: const Icon(Icons.download),
              onPressed: _exportReport,
              tooltip: 'Export Report'),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.6),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Patients'),
            Tab(text: 'Consultations'),
            Tab(text: 'Staff Activity'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildPatientsTab(),
          _buildConsultationsTab(),
          _buildStaffActivityTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: _buildStatCard('Total Patients', '1,245', '+12%',
                      AppColors.cardGreen, Icons.people)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildStatCard('Consultations', '856', '+8%',
                      AppColors.cardBlue, Icons.medical_services)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildStatCard('Prescriptions', '623', '+15%',
                      AppColors.cardPurple, Icons.medication)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildStatCard('Avg Wait Time', '18 min', '-5%',
                      AppColors.cardOrange, Icons.timer)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 2,
                  child: _buildChartCard('Patient Visits', _buildLineChart())),
              const SizedBox(width: 24),
              Expanded(
                  child: _buildChartCard('Queue Status', _buildPieChart())),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildTopDiagnosesCard()),
              const SizedBox(width: 24),
              Expanded(child: _buildDepartmentStatsCard()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, String change, Color color, IconData icon) {
    final isPositive = change.startsWith('+') ||
        change.startsWith('-') && title.contains('Wait');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
                Text(value, style: AppTextStyles.h4.copyWith(color: color)),
                Row(children: [
                  Icon(isPositive ? Icons.trending_up : Icons.trending_down,
                      size: 14,
                      color: isPositive ? AppColors.success : AppColors.error),
                  const SizedBox(width: 4),
                  Text(change,
                      style: AppTextStyles.caption.copyWith(
                          color: isPositive
                              ? AppColors.success
                              : AppColors.error)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h6),
          const SizedBox(height: 20),
          chart,
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['60', '45', '30', '15', '0']
                  .map((l) => Text(l,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textHint)))
                  .toList()),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBar('Mon', 35, 60, AppColors.cardBlue),
                _buildBar('Tue', 42, 60, AppColors.cardBlue),
                _buildBar('Wed', 38, 60, AppColors.cardBlue),
                _buildBar('Thu', 55, 60, AppColors.cardBlue),
                _buildBar('Fri', 48, 60, AppColors.cardBlue),
                _buildBar('Sat', 25, 60, AppColors.cardBlue),
                _buildBar('Sun', 0, 60, AppColors.grey300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double value, double max, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
            width: 32,
            height: (value / max) * 160,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(height: 8),
        Text(label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
      ],
    );
  }

  Widget _buildPieChart() {
    return SizedBox(
      height: 200,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                        value: 0.75,
                        strokeWidth: 16,
                        backgroundColor: AppColors.grey200,
                        valueColor:
                            AlwaysStoppedAnimation(AppColors.cardGreen))),
                Text('75%', style: AppTextStyles.h4),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _buildLegendItem('Completed', AppColors.cardGreen),
            const SizedBox(width: 16),
            _buildLegendItem('Pending', AppColors.grey300),
          ]),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(children: [
      Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: AppTextStyles.caption),
    ]);
  }

  Widget _buildTopDiagnosesCard() {
    final diagnoses = [
      {'name': 'Upper Respiratory Infection', 'count': 156, 'percent': 18},
      {'name': 'Hypertension', 'count': 134, 'percent': 16},
      {'name': 'Type 2 Diabetes', 'count': 98, 'percent': 11},
      {'name': 'Gastroenteritis', 'count': 76, 'percent': 9},
      {'name': 'Urinary Tract Infection', 'count': 65, 'percent': 8},
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Diagnoses', style: AppTextStyles.h6),
          const SizedBox(height: 16),
          ...diagnoses.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  Expanded(
                      child: Text(d['name'] as String,
                          style: AppTextStyles.bodySmall)),
                  Text('${d['count']}',
                      style: AppTextStyles.bodySmall
                          .copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  SizedBox(
                      width: 60,
                      child: LinearProgressIndicator(
                          value: (d['percent'] as int) / 100,
                          backgroundColor: AppColors.grey200,
                          valueColor:
                              AlwaysStoppedAnimation(AppColors.cardPurple))),
                  const SizedBox(width: 8),
                  Text('${d['percent']}%',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary)),
                ]),
              )),
        ],
      ),
    );
  }

  Widget _buildDepartmentStatsCard() {
    final depts = [
      {
        'name': 'General Medicine',
        'patients': 345,
        'color': AppColors.cardBlue
      },
      {'name': 'Pediatrics', 'patients': 234, 'color': AppColors.cardGreen},
      {'name': 'OB-GYN', 'patients': 156, 'color': AppColors.cardPurple},
      {'name': 'Emergency', 'patients': 121, 'color': AppColors.cardRed},
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Patients by Department', style: AppTextStyles.h6),
          const SizedBox(height: 16),
          ...depts.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                          color: d['color'] as Color,
                          borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(d['name'] as String,
                          style: AppTextStyles.bodySmall)),
                  Text('${d['patients']}',
                      style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: d['color'] as Color)),
                ]),
              )),
        ],
      ),
    );
  }

  Widget _buildPatientsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Patient Logs', style: AppTextStyles.h5),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12)),
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('New Patients')),
                DataColumn(label: Text('Follow-ups')),
                DataColumn(label: Text('Total')),
                DataColumn(label: Text('Avg Wait')),
              ],
              rows: [
                _buildDataRow('Dec 5, 2024', '28', '14', '42', '15 min'),
                _buildDataRow('Dec 4, 2024', '32', '12', '44', '18 min'),
                _buildDataRow('Dec 3, 2024', '25', '18', '43', '12 min'),
                _buildDataRow('Dec 2, 2024', '30', '15', '45', '20 min'),
                _buildDataRow('Dec 1, 2024', '22', '10', '32', '14 min'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(
      String date, String newP, String followUp, String total, String wait) {
    return DataRow(cells: [
      DataCell(Text(date)),
      DataCell(Text(newP)),
      DataCell(Text(followUp)),
      DataCell(
          Text(total, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(wait)),
    ]);
  }

  Widget _buildConsultationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
                child: _buildMiniStatCard(
                    'Total Consultations', '856', AppColors.cardBlue)),
            const SizedBox(width: 16),
            Expanded(
                child:
                    _buildMiniStatCard('Completed', '789', AppColors.success)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildMiniStatCard('Cancelled', '67', AppColors.error)),
          ]),
          const SizedBox(height: 24),
          Text('Monthly Summary', style: AppTextStyles.h5),
          const SizedBox(height: 16),
          _buildConsultationsList(),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(title,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.h3.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildConsultationsList() {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildConsultationRow(
              'Dr. Maria Santos', 'General Medicine', 156, 145),
          _buildConsultationRow('Dr. Juan Cruz', 'Pediatrics', 134, 128),
          _buildConsultationRow('Dr. Ana Reyes', 'OB-GYN', 98, 92),
          _buildConsultationRow('Dr. Pedro Garcia', 'Surgery', 76, 70),
        ],
      ),
    );
  }

  Widget _buildConsultationRow(
      String doctor, String dept, int total, int completed) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.grey200))),
      child: Row(
        children: [
          CircleAvatar(
              backgroundColor: AppColors.cardPurple.withOpacity(0.1),
              child: Text(doctor[4],
                  style: TextStyle(color: AppColors.cardPurple))),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(doctor,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(dept,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
              ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$total consultations', style: AppTextStyles.bodySmall),
            Text('$completed completed',
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.success)),
          ]),
        ],
      ),
    );
  }

  Widget _buildStaffActivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Staff Activity Logs', style: AppTextStyles.h5),
          const SizedBox(height: 16),
          _buildActivitySection('Nurses', _nurseActivity),
          const SizedBox(height: 24),
          _buildActivitySection('Doctors', _doctorActivity),
        ],
      ),
    );
  }

  Widget _buildActivitySection(
      String title, List<Map<String, dynamic>> activities) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h6),
          const SizedBox(height: 16),
          ...activities.map((a) => _buildActivityRow(a)),
        ],
      ),
    );
  }

  Widget _buildActivityRow(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.grey100, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          CircleAvatar(
              radius: 18,
              backgroundColor: (activity['color'] as Color).withOpacity(0.1),
              child: Icon(activity['icon'] as IconData,
                  size: 18, color: activity['color'] as Color)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(activity['name'] as String,
                    style: AppTextStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(activity['action'] as String,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
              ])),
          Text(activity['time'] as String,
              style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
        ],
      ),
    );
  }

  void _exportReport() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Exporting report...')));
  }

  final List<Map<String, dynamic>> _nurseActivity = [
    {
      'name': 'Ana Reyes',
      'action': 'Recorded vitals for 12 patients',
      'time': '2 hours ago',
      'icon': Icons.favorite,
      'color': AppColors.cardRed
    },
    {
      'name': 'Rosa Luna',
      'action': 'Updated 8 patient records',
      'time': '3 hours ago',
      'icon': Icons.edit,
      'color': AppColors.cardBlue
    },
  ];

  final List<Map<String, dynamic>> _doctorActivity = [
    {
      'name': 'Dr. Maria Santos',
      'action': 'Completed 15 consultations',
      'time': '1 hour ago',
      'icon': Icons.check_circle,
      'color': AppColors.success
    },
    {
      'name': 'Dr. Juan Cruz',
      'action': 'Issued 10 prescriptions',
      'time': '2 hours ago',
      'icon': Icons.medication,
      'color': AppColors.cardPurple
    },
  ];
}
