import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';
import '../nurse/nurse_home_screen.dart';
import '../admin/admin_home_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        // User is logged in
        if (snapshot.hasData && snapshot.data != null) {
          return const _RoleBasedRedirect();
        }

        // User is not logged in
        return const LoginScreen();
      },
    );
  }
}

class _RoleBasedRedirect extends StatefulWidget {
  const _RoleBasedRedirect();

  @override
  State<_RoleBasedRedirect> createState() => _RoleBasedRedirectState();
}

class _RoleBasedRedirectState extends State<_RoleBasedRedirect> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  String? _role;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final role = await _authService.getCurrentUserRole();
      if (mounted) {
        setState(() {
          _role = role;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 100,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.local_hospital,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              const Text('Loading your dashboard...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await _authService.logout();
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      );
    }

    // Route based on role
    switch (_role?.toLowerCase()) {
      case 'nurse':
        return const NurseHomeScreen();
      case 'admin':
        return const AdminHomeScreen();
      default:
        return _UnsupportedRoleLogout(authService: _authService);
    }
  }
}

class _UnsupportedRoleLogout extends StatefulWidget {
  final AuthService authService;
  const _UnsupportedRoleLogout({required this.authService});

  @override
  State<_UnsupportedRoleLogout> createState() => _UnsupportedRoleLogoutState();
}

class _UnsupportedRoleLogoutState extends State<_UnsupportedRoleLogout> {
  @override
  void initState() {
    super.initState();
    widget.authService.logout();
  }

  @override
  Widget build(BuildContext context) {
    return const LoginScreen();
  }
}
