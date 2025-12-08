import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:medical_ticketing/screens/admin/admin_home_screen.dart';
import 'package:medical_ticketing/screens/doctor/doctor_home_screen.dart';
import 'package:medical_ticketing/screens/nurse/nurse_home_screen.dart';
import 'package:medical_ticketing/screens/patient/patient_home_screen.dart';
import 'config/app_theme.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyAp_5W0O_nSGFihfn-2sbh12VtSBbA0jNI",
          authDomain: "medical-ticketing.firebaseapp.com",
          projectId: "medical-ticketing",
          storageBucket: "medical-ticketing.firebasestorage.app",
          messagingSenderId: "177236370054",
          appId: "1:177236370054:web:f02fdd19f91ecaf20f2707"));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Ticketing System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
