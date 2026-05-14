/**
 * Student Numbers: 221049921, 221050534, 222010648, 221014841
 * Student Names  : Kwanele Biyase, Motheo Sekgweleo, Thapelo Sikithi, Paki Gabriel Sekotlo
 * Question: Main / Entry Point
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/constants.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/student_home_viewmodel.dart';
import 'viewmodels/application_form_viewmodel.dart';
import 'viewmodels/application_detail_viewmodel.dart';
import 'viewmodels/admin_dashboard_viewmodel.dart';
import 'views/login_screen.dart';
import 'views/student_home_screen.dart';
import 'views/application_form_screen.dart';
import 'views/application_detail_screen.dart';
import 'views/admin_dashboard_screen.dart';
import 'views/signup_screen.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: Constants.supabaseUrl,
    anonKey: Constants.supabaseAnonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => StudentHomeViewModel()),
        ChangeNotifierProvider(create: (_) => ApplicationFormViewModel()),
        ChangeNotifierProvider(create: (_) => ApplicationDetailViewModel()),
        ChangeNotifierProvider(create: (_) => AdminDashboardViewModel()),
      ],
      child: MaterialApp(
        title: 'Student Assistant Application System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const AuthWrapper(),
        routes: {
          '/student_home': (context) => const StudentHomeScreen(),
          '/application_form': (context) => const ApplicationFormScreen(),
          '/application_detail': (context) => const ApplicationDetailScreen(),
          '/admin_dashboard': (context) => const AdminDashboardScreen(),
          '/signup': (context) => const SignUpScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SupabaseService.client.auth.currentSession;

    if (session == null) {
      return const LoginScreen();
    }

    return FutureBuilder<String?>(
      future: SupabaseService.getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == 'admin') {
          return const AdminDashboardScreen();
        }
        return const StudentHomeScreen();
      },
    );
  }
}
