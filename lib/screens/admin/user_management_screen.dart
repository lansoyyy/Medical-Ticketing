import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedStatus = 'All Status';
  final TextEditingController _searchController = TextEditingController();

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
        title: const Text('User Management'),
        actions: [
          ElevatedButton.icon(
            onPressed: _showAddUserDialog,
            icon: const Icon(Icons.person_add),
            label: const Text('Add User'),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.cardGreen),
          ),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.6),
          tabs: const [
            Tab(text: 'Patients', icon: Icon(Icons.person, size: 20)),
            Tab(text: 'Nurses', icon: Icon(Icons.medical_services, size: 20)),
            Tab(text: 'Doctors', icon: Icon(Icons.local_hospital, size: 20)),
            Tab(
                text: 'Admins',
                icon: Icon(Icons.admin_panel_settings, size: 20)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: AppColors.grey100,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedStatus,
                  items: ['All Status', 'Active', 'Inactive', 'Pending']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedStatus = value ?? 'All Status');
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUserList(_patients, 'Patient'),
                _buildUserList(_nurses, 'Nurse'),
                _buildUserList(_doctors, 'Doctor'),
                _buildUserList(_admins, 'Admin'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<Map<String, dynamic>> users, String role) {
    var filtered = users;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((u) => u['name']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Filter by status
    if (_selectedStatus != 'All Status') {
      filtered = filtered
          .where((u) => u['status'] == _selectedStatus)
          .toList();
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: AppColors.grey400),
            const SizedBox(height: 16),
            Text('No users found',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text(
              _selectedStatus != 'All Status'
                  ? 'No $role with "$_selectedStatus" status'
                  : 'Try a different search',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildUserCard(filtered[index], role),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, String role) {
    final isActive = user['status'] == 'Active';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: _getRoleColor(role).withOpacity(0.1),
            child: Text(user['name'][0],
                style: AppTextStyles.bodyLarge.copyWith(
                    color: _getRoleColor(role), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(user['name'],
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(user['status'],
                          style: AppTextStyles.caption.copyWith(
                              color: isActive
                                  ? AppColors.success
                                  : AppColors.error)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(user['email'],
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
                if (user['department'] != null)
                  Text(user['department'],
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.cardBlue)),
              ],
            ),
          ),
          Text('ID: ${user['id']}',
              style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
          const SizedBox(width: 16),
          PopupMenuButton<String>(
            onSelected: (action) => _handleUserAction(action, user, role),
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'view',
                  child: Row(children: [
                    Icon(Icons.visibility, size: 18),
                    SizedBox(width: 8),
                    Text('View Details')
                  ])),
              const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit')
                  ])),
              const PopupMenuItem(
                  value: 'permissions',
                  child: Row(children: [
                    Icon(Icons.security, size: 18),
                    SizedBox(width: 8),
                    Text('Permissions')
                  ])),
              PopupMenuItem(
                  value: 'toggle',
                  child: Row(children: [
                    Icon(isActive ? Icons.block : Icons.check_circle, size: 18),
                    SizedBox(width: 8),
                    Text(isActive ? 'Deactivate' : 'Activate')
                  ])),
              const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete, size: 18, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: AppColors.error))
                  ])),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Patient':
        return AppColors.cardGreen;
      case 'Nurse':
        return AppColors.cardBlue;
      case 'Doctor':
        return AppColors.cardPurple;
      case 'Admin':
        return AppColors.cardRed;
      default:
        return AppColors.grey500;
    }
  }

  void _handleUserAction(
      String action, Map<String, dynamic> user, String role) {
    switch (action) {
      case 'view':
        _showUserDetailsDialog(user, role);
        break;
      case 'edit':
        _showEditUserDialog(user, role);
        break;
      case 'permissions':
        _showPermissionsDialog(user, role);
        break;
      case 'toggle':
        _toggleUserStatus(user);
        break;
      case 'delete':
        _confirmDeleteUser(user);
        break;
    }
  }

  void _showAddUserDialog() {
    String? selectedRole;
    String? selectedDepartment;
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New User'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  dropdownColor: AppColors.inputBackground,
                  style: const TextStyle(color: AppColors.inputText),
                  decoration: const InputDecoration(
                    labelText: 'User Role',
                    hintText: 'Select role',
                  ),
                  items: ['Patient', 'Nurse', 'Doctor', 'Admin']
                      .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(r,
                              style:
                                  const TextStyle(color: AppColors.inputText))))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedRole = value);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: AppColors.inputText),
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter full name',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: AppColors.inputText),
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter email address',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  style: const TextStyle(color: AppColors.inputText),
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    hintText: 'Enter phone number',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedDepartment,
                  dropdownColor: AppColors.inputBackground,
                  style: const TextStyle(color: AppColors.inputText),
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    hintText: 'Select department',
                  ),
                  items: [
                    'General Medicine',
                    'Pediatrics',
                    'OB-GYN',
                    'Surgery',
                    'Emergency'
                  ]
                      .map((d) => DropdownMenuItem(
                          value: d,
                          child: Text(d,
                              style:
                                  const TextStyle(color: AppColors.inputText))))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedDepartment = value);
                  },
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
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User created successfully')));
                },
                style:
                    ElevatedButton.styleFrom(backgroundColor: AppColors.cardOrange),
                child: const Text('Create User')),
          ],
        ),
      ),
    );
  }

  void _showUserDetailsDialog(Map<String, dynamic> user, String role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(children: [
          CircleAvatar(
              backgroundColor: _getRoleColor(role).withOpacity(0.1),
              child: Text(user['name'][0],
                  style: TextStyle(color: _getRoleColor(role)))),
          const SizedBox(width: 12),
          Text(user['name']),
        ]),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('ID', user['id']),
              _buildDetailRow('Email', user['email']),
              _buildDetailRow('Phone', user['phone'] ?? 'N/A'),
              _buildDetailRow('Role', role),
              if (user['department'] != null)
                _buildDetailRow('Department', user['department']),
              _buildDetailRow('Status', user['status']),
              _buildDetailRow('Created', user['created'] ?? 'Jan 15, 2024'),
              _buildDetailRow('Last Login', user['lastLogin'] ?? 'Dec 5, 2024'),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'))
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
              width: 100,
              child: Text(label,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary))),
          Expanded(child: Text(value, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user, String role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${user['name']}'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  controller: TextEditingController(text: user['name'])),
              const SizedBox(height: 12),
              TextField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  controller: TextEditingController(text: user['email'])),
              const SizedBox(height: 12),
              TextField(
                  decoration: const InputDecoration(labelText: 'Phone'),
                  controller: TextEditingController(text: user['phone'] ?? '')),
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
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User updated successfully')));
              },
              child: const Text('Save')),
        ],
      ),
    );
  }

  void _showPermissionsDialog(Map<String, dynamic> user, String role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permissions: ${user['name']}'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                  title: const Text('View Patient Records'),
                  value: true,
                  onChanged: (_) {}),
              SwitchListTile(
                  title: const Text('Edit Patient Records'),
                  value: role != 'Patient',
                  onChanged: (_) {}),
              SwitchListTile(
                  title: const Text('Manage Queue'),
                  value: role == 'Nurse' || role == 'Admin',
                  onChanged: (_) {}),
              SwitchListTile(
                  title: const Text('Issue Prescriptions'),
                  value: role == 'Doctor',
                  onChanged: (_) {}),
              SwitchListTile(
                  title: const Text('System Administration'),
                  value: role == 'Admin',
                  onChanged: (_) {}),
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
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Permissions updated')));
              },
              child: const Text('Save')),
        ],
      ),
    );
  }

  void _toggleUserStatus(Map<String, dynamic> user) {
    setState(() =>
        user['status'] = user['status'] == 'Active' ? 'Inactive' : 'Active');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'User ${user['status'] == 'Active' ? 'activated' : 'deactivated'}')));
  }

  void _confirmDeleteUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
            'Are you sure you want to delete ${user['name']}? This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User deleted')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Delete')),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> _patients = [
    {
      'id': 'P-001',
      'name': 'Juan Dela Cruz',
      'email': 'juan@email.com',
      'phone': '+63 912 345 6789',
      'status': 'Active'
    },
    {
      'id': 'P-002',
      'name': 'Maria Santos',
      'email': 'maria@email.com',
      'phone': '+63 917 123 4567',
      'status': 'Active'
    },
    {
      'id': 'P-003',
      'name': 'Pedro Garcia',
      'email': 'pedro@email.com',
      'phone': '+63 918 765 4321',
      'status': 'Inactive'
    },
  ];

  final List<Map<String, dynamic>> _nurses = [
    {
      'id': 'N-001',
      'name': 'Ana Reyes',
      'email': 'ana.reyes@clinic.com',
      'department': 'General Ward',
      'status': 'Active'
    },
    {
      'id': 'N-002',
      'name': 'Rosa Luna',
      'email': 'rosa.luna@clinic.com',
      'department': 'Emergency',
      'status': 'Active'
    },
  ];

  final List<Map<String, dynamic>> _doctors = [
    {
      'id': 'D-001',
      'name': 'Dr. Maria Santos',
      'email': 'dr.santos@clinic.com',
      'department': 'General Medicine',
      'status': 'Active'
    },
    {
      'id': 'D-002',
      'name': 'Dr. Juan Cruz',
      'email': 'dr.cruz@clinic.com',
      'department': 'Pediatrics',
      'status': 'Active'
    },
  ];

  final List<Map<String, dynamic>> _admins = [
    {
      'id': 'A-001',
      'name': 'System Admin',
      'email': 'admin@clinic.com',
      'status': 'Active'
    },
    {
      'id': 'A-002',
      'name': 'IT Support',
      'email': 'support@clinic.com',
      'status': 'Active'
    },
  ];
}
