import 'package:citesched_flutter/features/admin/screens/admin_layout.dart';
import 'package:citesched_flutter/features/auth/providers/auth_provider.dart';
import 'package:citesched_flutter/features/auth/screens/login_screen.dart';
import 'package:citesched_flutter/features/student/screens/student_schedule_screen.dart';
import 'package:citesched_flutter/features/faculty/screens/faculty_dashboard_screen.dart';
import 'package:citesched_flutter/features/common/layout/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RootScreen extends ConsumerWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    // If not signed in, show login
    if (authState == null) {
      return const LoginScreen();
    }

    // specific role checks
    if (authNotifier.isAdmin) {
      return const AdminLayout();
    }

    // specific role screens
    if (authNotifier.isStudent) {
      return const AppLayout(
        title: 'Student Schedule',
        child: StudentScheduleScreen(),
      );
    }

    if (authNotifier.isFaculty) {
      return const AppLayout(
        title: 'Faculty Dashboard',
        child: FacultyDashboardScreen(),
      );
    }

    // Default fallback (e.g., no role assigned yet)
    return const Scaffold(
      body: Center(
        child: Text("Welcome! Please contact admin to assign a role."),
      ),
    );
  }
}
