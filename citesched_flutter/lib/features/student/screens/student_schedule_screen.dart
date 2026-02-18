import 'package:citesched_client/citesched_client.dart';
import 'package:citesched_flutter/core/api/api_service.dart';
import 'package:citesched_flutter/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentScheduleScreen extends ConsumerWidget {
  const StudentScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(studentScheduleProvider);
    final profileAsync = ref.watch(studentProfileProvider);
    final user = ref.watch(authProvider);

    final maroonDark = const Color(0xFF4f003b);
    final bgColor = const Color(0xFFF4F7F9);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'My Academic Schedule',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: maroonDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            onPressed: () {
              // Printing functionality could be added here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Print functionality coming soon!'),
                ),
              );
            },
            tooltip: 'Print Schedule',
          ),
          IconButton(
            onPressed: () => ref.read(authProvider.notifier).signOut(),
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Banner Section
            profileAsync.when(
              data: (profile) => _buildBanner(profile, user?.userName),
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => _buildBanner(null, user?.userName),
            ),
            const SizedBox(height: 24),

            // Schedule Table Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: scheduleAsync.when(
                  data: (schedules) => _buildScheduleTable(schedules, context),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(100),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (err, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(100),
                      child: Text('Error loading schedule: $err'),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
            Text(
              '© 2026 CITESched Academic Management System. All rights reserved.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(Student? profile, String? userName) {
    final maroonDark = const Color(0xFF4f003b);
    final maroonLight = const Color(0xFF720045);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [maroonDark, maroonLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'UNIVERSITY ENROLLMENT RECORD',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.75),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                (profile?.name ?? userName ?? 'STUDENT').toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.school, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Section: ',
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                  Text(
                    profile?.section ?? 'Not Assigned',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '2nd Semester | 2025-2026',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTable(List<Schedule> schedules, BuildContext context) {
    if (schedules.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(80),
        child: Column(
          children: [
            Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No schedules found for your section.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    double totalUnits = 0;
    // Assuming each schedule represents a subject and we can sum units
    // In a real app, we'd group by subjectId to avoid duplicates if needed
    for (var s in schedules) {
      totalUnits += s.subject?.units ?? 0;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
              columnSpacing: 24,
              columns: [
                DataColumn(
                  label: Text(
                    'SUBJECT DETAILS',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'UNITS',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'INSTRUCTOR',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'ROOM',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'SCHEDULE',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
              rows: [
                ...schedules.map((s) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFfdf2f8),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFfbcfe8),
                                  ),
                                ),
                                child: Text(
                                  s.subject?.code ?? 'N/A',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF4f003b),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.subject?.name ?? 'Unknown Subject',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: Text(
                            s.subject?.units.toString() ?? '0',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          (s.faculty?.name ?? 'TBA').toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            s.room?.name ?? 'TBA',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              s.timeslot?.day.name.toUpperCase() ?? 'N/A',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4f003b),
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${s.timeslot?.startTime} - ${s.timeslot?.endTime}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
                DataRow(
                  cells: [
                    DataCell(
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'TOTAL ACADEMIC LOAD:',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: Text(
                          '${totalUnits.toStringAsFixed(1)} Units',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ),
                    const DataCell(SizedBox()),
                    const DataCell(SizedBox()),
                    const DataCell(SizedBox()),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
