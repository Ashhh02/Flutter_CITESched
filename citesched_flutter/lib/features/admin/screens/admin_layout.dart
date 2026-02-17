import 'package:citesched_flutter/core/theme/app_theme.dart';
import 'package:citesched_flutter/features/admin/screens/admin_dashboard_screen.dart';
import 'package:citesched_flutter/features/admin/screens/faculty_management_screen.dart';
import 'package:citesched_flutter/features/admin/screens/faculty_loading_screen.dart';
import 'package:citesched_flutter/features/admin/screens/subject_management_screen.dart';
import 'package:citesched_flutter/features/admin/screens/room_management_screen.dart';
import 'package:citesched_flutter/features/admin/screens/timetable_screen.dart';
import 'package:citesched_flutter/features/admin/screens/conflict_screen.dart';
import 'package:citesched_flutter/features/admin/screens/report_screen.dart';
import 'package:citesched_flutter/features/admin/widgets/admin_sidebar.dart';

import 'package:flutter/material.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const FacultyManagementScreen(),
    const FacultyLoadingScreen(),
    const SubjectManagementScreen(),
    const RoomManagementScreen(),
    const TimetableScreen(),
    const ConflictScreen(),
    const ReportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.startBackground,
      body: Row(
        children: [
          AdminSidebar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              if (index == 8) {
                // Logout case - handled in Sidebar usually, or here if we pass a callback.
                // For now, let's assume index 8 is logout and we'll handle it there or via a specific callback.
                return;
              }
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
