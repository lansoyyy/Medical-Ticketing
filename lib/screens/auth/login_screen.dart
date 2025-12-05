import 'package:flutter/material.dart';
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
  String _selectedRole = 'Patient';

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
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? AppColors.white : AppColors.textSecondary,
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
      onSelected: (_) {
        setState(() {
          _selectedRole = label;
        });
      },
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildRoleChip('Patient', Icons.person_outline),
              _buildRoleChip('Nurse', Icons.medical_services_outlined),
              _buildRoleChip('Doctor', Icons.local_hospital_outlined),
              _buildRoleChip('Admin', Icons.admin_panel_settings_outlined),
            ],
          ),
          const SizedBox(height: 24),

          // Login Button
          PrimaryButton(
            text: 'Log In',
            onPressed: _handleLogin,
          ),
          const SizedBox(height: 32),

          // Guest Access Text
          Text(
            'Some features may allow guest access',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Guest Access Button
          SecondaryButton(
            text: 'Access as a guest',
            onPressed: _handleGuestAccess,
          ),
          const SizedBox(height: 48),

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
                mainAxisAlignment: MainAxisAlignment.center,
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

  void _handleLogin() {
    // Navigate to patient home screen (for UI demo)
    _navigateToRoleHome();
  }

  void _handleGuestAccess() {
    // Navigate to patient home screen as guest
    _navigateToRoleHome();
  }

  void _navigateToRoleHome() {
    Widget screen;
    switch (_selectedRole) {
      case 'Nurse':
        screen = const NurseHomeScreen();
        break;
      case 'Doctor':
        screen = const DoctorHomeScreen();
        break;
      case 'Admin':
        screen = const AdminHomeScreen();
        break;
      case 'Patient':
      default:
        screen = const PatientHomeScreen();
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _handlePrivacyPolicy() {
    // TODO: Implement privacy policy navigation
    debugPrint('Privacy policy pressed');
  }
}
