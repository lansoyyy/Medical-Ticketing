import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/widgets.dart';
import '../patient/patient_home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  DateTime? _birthDate;
  String? _selectedGender;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 900;

    return Scaffold(
      body: Row(
        children: [
          // Left Panel - Registration Form
          Expanded(
            flex: isSmallScreen ? 1 : 2,
            child: Container(
              color: AppColors.white,
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 24 : 60,
                      vertical: 40,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: _buildRegistrationForm(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Right Panel
          if (!isSmallScreen)
            Expanded(
              flex: 3,
              child: _buildRightPanel(),
            ),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              height: 80,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Create Your Account',
              style: AppTextStyles.h3.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Fill in the details below to register',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 32),

          // Name Fields
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  icon: Icons.person_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Email
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          // Phone
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          // Birth Date & Gender
          Row(
            children: [
              Expanded(
                child: _buildDatePicker(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGenderDropdown(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Password
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            icon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: 16),

          // Confirm Password
          _buildTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            icon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: 24),

          // Terms Checkbox
          Row(
            children: [
              Checkbox(
                value: _agreeToTerms,
                onChanged: (value) =>
                    setState(() => _agreeToTerms = value ?? false),
                activeColor: AppColors.primary,
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'I agree to the ',
                    style: AppTextStyles.bodySmall,
                    children: [
                      TextSpan(
                        text: 'Terms of Service',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Register Button
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : PrimaryButton(
                  text: 'Register',
                  onPressed: _handleRegister,
                  backgroundColor: AppColors.primary,
                ),
          const SizedBox(height: 24),

          // Login Link
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  child: Text(
                    'Login',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller,
          hintText: label,
          prefixIcon: icon,
          keyboardType: keyboardType ?? TextInputType.text,
          obscureText: obscureText,
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date of Birth',
            style:
                AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime(2000),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null) setState(() => _birthDate = date);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    color: AppColors.inputIcon, size: 20),
                const SizedBox(width: 12),
                Text(
                  _birthDate != null
                      ? '${_birthDate!.month}/${_birthDate!.day}/${_birthDate!.year}'
                      : 'Select Date',
                  style: AppTextStyles.inputText.copyWith(
                    color: _birthDate != null
                        ? AppColors.inputText
                        : AppColors.inputHint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender',
            style:
                AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGender,
              isExpanded: true,
              hint: Text('Select', style: AppTextStyles.inputHint),
              dropdownColor: AppColors.secondary,
              style: AppTextStyles.inputText,
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.inputIcon),
              items: ['Male', 'Female', 'Other'].map((gender) {
                return DropdownMenuItem(value: gender, child: Text(gender));
              }).toList(),
              onChanged: (value) => setState(() => _selectedGender = value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRightPanel() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.how_to_reg_rounded,
                  size: 80, color: AppColors.white),
            ),
            const SizedBox(height: 40),
            Text(
              'Join Our Healthcare\nCommunity',
              style: AppTextStyles.h1
                  .copyWith(color: AppColors.white, fontSize: 38),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Get access to online appointments,\nmedical records, and more',
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.white.withOpacity(0.8)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    // Validation
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in all required fields'),
            backgroundColor: AppColors.error),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: AppColors.error),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password must be at least 6 characters'),
            backgroundColor: AppColors.error),
      );
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please agree to the Terms of Service'),
            backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.registerWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim(),
      role: 'patient', // Default role for self-registration
      gender: _selectedGender,
      birthDate: _birthDate,
    );

    setState(() => _isLoading = false);

    if (result.error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result.error!), backgroundColor: AppColors.error),
        );
      }
      return;
    }

    if (result.user != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: AppColors.success),
      );
      // Navigate to patient home screen after successful registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PatientHomeScreen()),
      );
    }
  }
}
