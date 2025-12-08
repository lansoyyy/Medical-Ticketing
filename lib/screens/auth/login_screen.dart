import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/widgets.dart';
import '../patient/patient_home_screen.dart';
import '../nurse/nurse_home_screen.dart';
import '../doctor/doctor_home_screen.dart';
import '../admin/admin_home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  String _selectedRole = 'Patient';
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 900;

    return Scaffold(
      body: Row(
        children: [
          // Left Panel - Login Form
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
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: _buildLoginForm(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Right Panel - Background Image/Design
          if (!isSmallScreen)
            Expanded(
              flex: 3,
              child: _buildRightPanel(),
            ),
        ],
      ),
    );
  }

  Widget _buildRoleChip(String label, IconData icon) {
    final isSelected = _selectedRole == label;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                key: ValueKey('$label-$isSelected'),
                size: 16,
                color: isSelected ? AppColors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        selected: isSelected,
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.grey100,
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: isSelected ? AppColors.white : AppColors.textSecondary,
        ),
        showCheckmark: true,
        checkmarkColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        onSelected: (_) {
          setState(() {
            _selectedRole = label;
          });
        },
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo
          Image.asset(
            'assets/images/logo.png',
            height: 120,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          // Subtitle
          Text(
            'Medical Ticketing System',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Username Field
          CustomTextField(
            controller: _usernameController,
            hintText: 'Username or ID',
            prefixIcon: Icons.person_outline,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 16),

          // Password Field
          CustomTextField(
            controller: _passwordController,
            hintText: 'Password',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: 24),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Login as',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Role selection with consistent alignment
          Row(
            children: [
              Expanded(
                child: _buildRoleChip('Patient', Icons.person_outline),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRoleChip('Nurse', Icons.medical_services_outlined),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRoleChip('Doctor', Icons.local_hospital_outlined),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Admin on separate row for better alignment
          Align(
            alignment: Alignment.centerLeft,
            child: _buildRoleChip('Admin', Icons.admin_panel_settings_outlined),
          ),
          const SizedBox(height: 24),

          // Login Button
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : PrimaryButton(
                  text: 'Log In',
                  onPressed: _handleLogin,
                ),
          const SizedBox(height: 16),

          // Forgot Password Link
          Center(
            child: TextButton(
              onPressed: _showForgotPasswordDialog,
              child: Text(
                'Forgot Password?',
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Register Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterScreen()),
                  );
                },
                child: Text(
                  'Register',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Privacy Policy Link
          TextButton(
            onPressed: _handlePrivacyPolicy,
            child: Text(
              'Privacy Policy',
              style: AppTextStyles.linkSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary,
            AppColors.secondaryDark,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative Elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ),
          // Main Content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Medical Icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.local_hospital_rounded,
                      size: 80,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Medical Ticketing',
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.white,
                      fontSize: 42,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Streamline your healthcare support',
                    style: AppTextStyles.h5.copyWith(
                      color: AppColors.white.withOpacity(0.8),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Feature Highlights
                  _buildFeatureItem(
                    Icons.speed_rounded,
                    'Fast & Efficient',
                    'Quick ticket resolution',
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureItem(
                    Icons.security_rounded,
                    'Secure & Private',
                    'HIPAA compliant system',
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureItem(
                    Icons.support_agent_rounded,
                    '24/7 Support',
                    'Always available assistance',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryLight,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.h6.copyWith(
                color: AppColors.white,
              ),
            ),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    final email = _usernameController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter email and password'),
            backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.loginWithEmailAndPassword(
      email: email,
      password: password,
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
      _navigateToRoleHome(result.user!.role);
    }
  }

  void _handleGuestAccess() {
    // Guest access navigates to patient home without auth
    _navigateToRoleHome('patient');
  }

  void _navigateToRoleHome(String role) {
    Widget screen;
    switch (role.toLowerCase()) {
      case 'nurse':
        screen = const NurseHomeScreen();
        break;
      case 'doctor':
        screen = const DoctorHomeScreen();
        break;
      case 'admin':
        screen = const AdminHomeScreen();
        break;
      case 'patient':
      default:
        screen = const PatientHomeScreen();
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Enter your email address to receive a password reset link.'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final error =
                  await _authService.resetPassword(emailController.text);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error ?? 'Password reset email sent!'),
                    backgroundColor:
                        error != null ? AppColors.error : AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  void _handlePrivacyPolicy() {
    // TODO: Implement privacy policy navigation
    debugPrint('Privacy policy pressed');
  }
}
