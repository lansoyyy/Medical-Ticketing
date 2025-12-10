import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();
  bool _isEditing = false;
  bool _isLoading = true;
  UserModel? _user;

  // Personal Info Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  DateTime? _birthDate;
  String _gender = 'Male';

  // Medical Info Controllers
  final _bloodTypeController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyRelationController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUserData();
    if (user != null && mounted) {
      setState(() {
        _user = user;
        _firstNameController.text = user.firstName;
        _lastNameController.text = user.lastName;
        _emailController.text = user.email;
        _phoneController.text = user.phone;
        _addressController.text = user.address ?? '';
        _birthDate = user.birthDate;
        _gender = user.gender ?? 'Male';
        _bloodTypeController.text = user.bloodType ?? '';
        _heightController.text = user.height ?? '';
        _weightController.text = user.weight ?? '';
        _allergiesController.text = (user.allergies ?? []).join(', ');
        _medicationsController.text =
            (user.currentMedications ?? []).join(', ');
        _conditionsController.text = (user.medicalConditions ?? []).join(', ');
        _emergencyNameController.text = user.emergencyContactName ?? '';
        _emergencyRelationController.text = user.emergencyContactRelation ?? '';
        _emergencyPhoneController.text = user.emergencyContactPhone ?? '';
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bloodTypeController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _conditionsController.dispose();
    _emergencyNameController.dispose();
    _emergencyRelationController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text('My Profile',
            style: AppTextStyles.h5.copyWith(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isEditing)
            TextButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit'),
            )
          else
            Row(
              children: [
                TextButton(
                  onPressed: () => setState(() => _isEditing = false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: _saveProfile,
                  child:
                      Text('Save', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Personal Information'),
            Tab(text: 'Medical Profile'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPersonalInfoTab(),
                _buildMedicalProfileTab(),
              ],
            ),
    );
  }

  Widget _buildEditableMedicalRow(
      String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 160,
            child: _isEditing
                ? TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: AppColors.grey100,
                    ),
                  )
                : Text(
                    controller.text.isEmpty ? 'Not set' : controller.text,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.right,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalTextArea({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      maxLines: 3,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        hintText: hintText,
        helperText: 'Separate multiple items with commas',
        helperStyle:
            AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        alignLabelWithHint: true,
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: AppColors.grey100,
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Profile Picture Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
              ],
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary,
                      child: Text(_user?.initials ?? 'U',
                          style: AppTextStyles.h2
                              .copyWith(color: AppColors.white)),
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt,
                              size: 16, color: AppColors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(_user?.fullName ?? 'User', style: AppTextStyles.h4),
                const SizedBox(height: 4),
                Text(
                    'Patient ID: ${_user?.id.substring(0, 8).toUpperCase() ?? 'N/A'}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Personal Details Card
          Container(
            padding: const EdgeInsets.all(24),
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
                Text('Personal Details', style: AppTextStyles.h6),
                const SizedBox(height: 20),
                _buildInfoRow(
                    'First Name', _firstNameController, Icons.person_outline),
                _buildInfoRow(
                    'Last Name', _lastNameController, Icons.person_outline),
                _buildInfoRow('Email', _emailController, Icons.email_outlined),
                _buildInfoRow('Phone', _phoneController, Icons.phone_outlined),
                _buildDateRow(),
                _buildGenderRow(),
                _buildInfoRow(
                    'Address', _addressController, Icons.location_on_outlined,
                    maxLines: 2),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Emergency Contact Card
          Container(
            padding: const EdgeInsets.all(24),
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
                Text('Emergency Contact', style: AppTextStyles.h6),
                const SizedBox(height: 20),
                _buildStaticInfoRow(
                    'Name',
                    _user?.emergencyContactName ?? 'Not set',
                    Icons.person_outline),
                _buildStaticInfoRow(
                    'Relationship',
                    _user?.emergencyContactRelation ?? 'Not set',
                    Icons.family_restroom),
                _buildStaticInfoRow(
                    'Phone',
                    _user?.emergencyContactPhone ?? 'Not set',
                    Icons.phone_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Basic Medical Info Card
          _buildMedicalCard(
            'Basic Information',
            [
              _buildEditableMedicalRow('Blood Type', _bloodTypeController),
              _buildEditableMedicalRow(
                'Height (cm)',
                _heightController,
                keyboardType: TextInputType.number,
              ),
              _buildEditableMedicalRow(
                'Weight (kg)',
                _weightController,
                keyboardType: TextInputType.number,
              ),
              _buildMedicalRow('BMI', _calculateBMI()),
            ],
          ),
          const SizedBox(height: 16),

          // Allergies Card
          _buildMedicalCard(
            'Allergies',
            [
              if (_isEditing)
                _buildMedicalTextArea(
                  controller: _allergiesController,
                  hintText: 'e.g. Penicillin, Aspirin, Peanuts',
                )
              else if ((_user?.allergies ?? []).isNotEmpty)
                _buildTagRow(_user!.allergies!)
              else
                Text(
                  'No allergies recorded',
                  style:
                      AppTextStyles.caption.copyWith(color: AppColors.textHint),
                ),
            ],
            icon: Icons.warning_amber_outlined,
            iconColor: AppColors.cardOrange,
          ),
          const SizedBox(height: 16),

          // Current Medications Card
          _buildMedicalCard(
            'Current Medications',
            [
              if (_isEditing)
                _buildMedicalTextArea(
                  controller: _medicationsController,
                  hintText:
                      'e.g. Metformin 500mg twice daily, Lisinopril 10mg once daily',
                )
              else if ((_user?.currentMedications ?? []).isNotEmpty)
                ..._user!.currentMedications!
                    .map((med) => _buildMedicationRow(med, '', ''))
                    .toList()
              else
                Text(
                  'No medications recorded',
                  style:
                      AppTextStyles.caption.copyWith(color: AppColors.textHint),
                ),
            ],
            icon: Icons.medication_outlined,
          ),
          const SizedBox(height: 16),

          // Medical Conditions Card
          _buildMedicalCard(
            'Medical Conditions',
            [
              if (_isEditing)
                _buildMedicalTextArea(
                  controller: _conditionsController,
                  hintText: 'e.g. Type 2 Diabetes, Hypertension',
                )
              else if ((_user?.medicalConditions ?? []).isNotEmpty)
                ..._user!.medicalConditions!
                    .map((cond) => _buildConditionRow(cond, '', 'Ongoing'))
                    .toList()
              else
                Text(
                  'No conditions recorded',
                  style:
                      AppTextStyles.caption.copyWith(color: AppColors.textHint),
                ),
            ],
            icon: Icons.medical_information_outlined,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      String label, TextEditingController controller, IconData icon,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                _isEditing
                    ? TextField(
                        controller: controller,
                        maxLines: maxLines,
                        style: AppTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: AppColors.grey100,
                        ),
                      )
                    : Text(controller.text, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const Icon(Icons.cake_outlined,
              size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date of Birth',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                _isEditing
                    ? InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _birthDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) setState(() => _birthDate = date);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            _birthDate != null
                                ? '${_birthDate!.month}/${_birthDate!.day}/${_birthDate!.year}'
                                : 'Select date',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      )
                    : Text(
                        _birthDate != null
                            ? '${_birthDate!.month}/${_birthDate!.day}/${_birthDate!.year}'
                            : 'Not set',
                        style: AppTextStyles.bodyMedium,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const Icon(Icons.wc_outlined,
              size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gender',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                _isEditing
                    ? DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: AppColors.grey100,
                        ),
                        items: ['Male', 'Female', 'Other']
                            .map((g) =>
                                DropdownMenuItem(value: g, child: Text(g)))
                            .toList(),
                        onChanged: (value) => setState(() => _gender = value!),
                      )
                    : Text(_gender, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalCard(String title, List<Widget> children,
      {IconData? icon, Color? iconColor}) {
    return Container(
      width: double.infinity,
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
            children: [
              if (icon != null) ...[
                Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
                const SizedBox(width: 8),
              ],
              Text(title, style: AppTextStyles.h6),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMedicalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTagRow(List<String> tags) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.cardOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardOrange.withOpacity(0.3)),
          ),
          child: Text(tag,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.cardOrange)),
        );
      }).toList(),
    );
  }

  Widget _buildMedicationRow(String name, String dosage, String frequency) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.medication,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                Text('$dosage - $frequency',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionRow(String condition, String diagnosed, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(condition,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(diagnosed,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status == 'Controlled'
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.cardBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: AppTextStyles.caption.copyWith(
                color: status == 'Controlled'
                    ? AppColors.success
                    : AppColors.cardBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurgeryRow(String name, String date, String location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                Text('$date • $location',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyHistoryRow(String relation, String conditions) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(relation,
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(conditions,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  List<String> _parseCommaSeparatedList(String value) {
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String _calculateBMI() {
    if (_user?.height == null || _user?.weight == null) return 'Not available';
    try {
      final height =
          double.tryParse(_user!.height!.replaceAll(RegExp(r'[^0-9.]'), '')) ??
              0;
      final weight =
          double.tryParse(_user!.weight!.replaceAll(RegExp(r'[^0-9.]'), '')) ??
              0;
      if (height == 0 || weight == 0) return 'Not available';
      final heightInMeters = height / 100;
      final bmi = weight / (heightInMeters * heightInMeters);
      String category;
      if (bmi < 18.5)
        category = 'Underweight';
      else if (bmi < 25)
        category = 'Normal';
      else if (bmi < 30)
        category = 'Overweight';
      else
        category = 'Obese';
      return '${bmi.toStringAsFixed(1)} ($category)';
    } catch (e) {
      return 'Not available';
    }
  }

  Future<void> _saveProfile() async {
    if (_user == null) return;

    setState(() => _isLoading = true);

    final updateData = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'gender': _gender,
      'birthDate': _birthDate != null ? Timestamp.fromDate(_birthDate!) : null,
      'bloodType': _bloodTypeController.text.trim(),
      'height': _heightController.text.trim(),
      'weight': _weightController.text.trim(),
      'allergies': _parseCommaSeparatedList(_allergiesController.text),
      'currentMedications':
          _parseCommaSeparatedList(_medicationsController.text),
      'medicalConditions': _parseCommaSeparatedList(_conditionsController.text),
      'emergencyContactName': _emergencyNameController.text.trim(),
      'emergencyContactRelation': _emergencyRelationController.text.trim(),
      'emergencyContactPhone': _emergencyPhoneController.text.trim(),
    };

    final error = await _authService.updateUserProfile(_user!.id, updateData);

    setState(() {
      _isLoading = false;
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Profile updated successfully'),
          backgroundColor: error != null ? AppColors.error : AppColors.success,
        ),
      );
    }

    // Reload user data
    if (error == null) {
      _loadUserData();
    }
  }
}
