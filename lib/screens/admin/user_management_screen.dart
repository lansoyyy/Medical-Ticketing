import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedStatus = 'All Status';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
                _buildUserStream('patient'),
                _buildUserStream('nurse'),
                _buildUserStream('admin'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStream(String role) {
    return StreamBuilder<List<UserModel>>(
      key: ValueKey('users-$role'),
      stream: _firestoreService.getUsersByRole(role),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Failed to load users',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          );
        }

        final users = snapshot.data ?? [];
        return _buildUserListFromModels(users, role);
      },
    );
  }

  Widget _buildUserListFromModels(List<UserModel> users, String role) {
    var filtered = users;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((u) =>
              u.fullName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_selectedStatus != 'All Status') {
      filtered = filtered
          .where((u) =>
              (u.isActive && _selectedStatus == 'Active') ||
              (!u.isActive && _selectedStatus == 'Inactive'))
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
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) =>
          _buildUserCardFromModel(filtered[index], role),
    );
  }

  Widget _buildUserCardFromModel(UserModel user, String role) {
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
            child: Text(user.fullName.isNotEmpty ? user.fullName[0] : '?',
                style: AppTextStyles.bodyLarge.copyWith(
                    color: _getRoleColor(role), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(user.fullName,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: user.isActive
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(user.isActive ? 'Active' : 'Inactive',
                        style: AppTextStyles.caption.copyWith(
                            color: user.isActive
                                ? AppColors.success
                                : AppColors.error)),
                  ),
                ]),
                const SizedBox(height: 4),
                Text(user.email,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text('ID: ${user.id.substring(0, 8)}...',
              style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
          const SizedBox(width: 16),
          PopupMenuButton<String>(
            onSelected: (action) => _handleUserActionFromModel(action, user),
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'view',
                  child: Row(children: [
                    Icon(Icons.visibility, size: 18),
                    SizedBox(width: 8),
                    Text('View')
                  ])),
              const PopupMenuItem(
                  value: 'toggle',
                  child: Row(children: [
                    Icon(Icons.sync, size: 18),
                    SizedBox(width: 8),
                    Text('Toggle Status')
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

  void _handleUserActionFromModel(String action, UserModel user) async {
    switch (action) {
      case 'view':
        _showUserDetailsFromModel(user);
        break;
      case 'toggle':
        await _firestoreService
            .updateUser(user.id, {'isActive': !user.isActive});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('User ${user.isActive ? 'deactivated' : 'activated'}')));
        break;
      case 'delete':
        _confirmDeleteUserFromModel(user);
        break;
    }
  }

  void _showUserDetailsFromModel(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(children: [
          CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(user.fullName.isNotEmpty ? user.fullName[0] : '?',
                  style: TextStyle(color: AppColors.primary))),
          const SizedBox(width: 12),
          Text(user.fullName),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Email', user.email),
            _buildDetailRow('Phone', user.phone),
            _buildDetailRow('Role', user.role),
            _buildDetailRow('Status', user.isActive ? 'Active' : 'Inactive'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'))
        ],
      ),
    );
  }

  void _confirmDeleteUserFromModel(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.fullName}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _firestoreService.deleteUser(user.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('User deleted')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'patient':
        return AppColors.cardGreen;
      case 'nurse':
        return AppColors.cardBlue;
      case 'admin':
        return AppColors.cardRed;
      default:
        return AppColors.grey500;
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
                  items: ['Patient', 'Nurse', 'Admin']
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('User created successfully')));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardOrange),
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
}
