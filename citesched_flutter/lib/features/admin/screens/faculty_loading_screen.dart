import 'package:citesched_client/citesched_client.dart';
import 'package:citesched_flutter/core/utils/date_utils.dart';
import 'package:citesched_flutter/main.dart';
import 'package:citesched_flutter/features/admin/screens/faculty_load_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:citesched_flutter/core/providers/conflict_provider.dart';

import 'package:citesched_flutter/core/providers/admin_providers.dart';
import 'package:citesched_flutter/core/utils/responsive_helper.dart';

class FacultyLoadingScreen extends ConsumerStatefulWidget {
  const FacultyLoadingScreen({super.key});

  @override
  ConsumerState<FacultyLoadingScreen> createState() =>
      _FacultyLoadingScreenState();
}

class _FacultyLoadingScreenState extends ConsumerState<FacultyLoadingScreen> {
  String _searchQuery = '';
  String? _selectedFaculty;
  bool _showConflictDetails = false;
  final TextEditingController _searchController = TextEditingController();

  // Color scheme matching admin sidebar
  final Color maroonColor = const Color(0xFF720045);
  final Color innerMenuBg = const Color(0xFF7b004f);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showNewAssignmentModal() {
    showDialog(
      context: context,
      builder: (context) => _NewAssignmentModal(
        maroonColor: maroonColor,
        onSuccess: () {
          ref.invalidate(schedulesProvider);
        },
      ),
    );
  }

  void _showEditAssignmentModal(Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => _EditAssignmentModal(
        schedule: schedule,
        maroonColor: maroonColor,
        onSuccess: () {
          ref.invalidate(schedulesProvider);
        },
      ),
    );
  }

  void _deleteSchedule(Schedule schedule) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete Assignment',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this schedule assignment?',
            style: GoogleFonts.poppins(
              color: isDark ? Colors.grey[300] : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Delete', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      try {
        await client.admin.deleteSchedule(schedule.id!);
        ref.invalidate(schedulesProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Assignment deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting assignment: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final schedulesAsync = ref.watch(schedulesProvider);
    final facultyAsync = ref.watch(facultyListProvider);
    final subjectsAsync = ref.watch(subjectsProvider);
    final roomsAsync = ref.watch(roomsProvider);
    final timeslotsAsync = ref.watch(timeslotsProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final isMobile = ResponsiveHelper.isMobile(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Banner
              isMobile
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            maroonColor,
                            const Color(0xFF8e005b),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: maroonColor.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.assignment_ind_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Faculty Loading',
                                      style: GoogleFonts.poppins(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    Text(
                                      'Manage schedules and workload',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _showNewAssignmentModal,
                              icon: const Icon(Icons.add_rounded, size: 20),
                              label: Text(
                                'Assign Subject',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: maroonColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            maroonColor,
                            const Color(0xFF8e005b),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: maroonColor.withValues(alpha: 0.3),
                            blurRadius: 25,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.assignment_ind_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Faculty Loading',
                                    style: GoogleFonts.poppins(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Manage faculty schedule assignments, workload limits, and program distributions',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: _showNewAssignmentModal,
                            icon: const Icon(Icons.add_rounded, size: 20),
                            label: Text(
                              'Assign Subject',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: maroonColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 8,
                              shadowColor: Colors.black.withValues(alpha: 0.2),
                            ),
                          ),
                        ],
                      ),
                    ),
              const SizedBox(height: 24),

              // Conflict Warning Banner
              _buildConflictBanner(schedulesAsync, facultyAsync),
              const SizedBox(height: 20),

              // Search and Filter Row
              isMobile
                  ? Column(
                      children: [
                        _buildSearchBar(isDark),
                        const SizedBox(height: 16),
                        _buildFacultyFilter(facultyAsync, isDark),
                      ],
                    )
                  : Row(
                      children: [
                        // Search Bar
                        Expanded(
                          flex: 3,
                          child: _buildSearchBar(isDark),
                        ),
                        const SizedBox(width: 16),

                        // Faculty Filter
                        Expanded(
                          flex: 2,
                          child: _buildFacultyFilter(facultyAsync, isDark),
                        ),
                      ],
                    ),
              const SizedBox(height: 24),

              // Tab Bar
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.transparent : Colors.grey[300]!,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: maroonColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: maroonColor.withValues(alpha: 0.2),
                    ),
                  ),
                  indicatorColor: maroonColor,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: maroonColor,
                  unselectedLabelColor: Colors.grey[600],
                  labelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  tabs: const [
                    Tab(text: 'Faculty Loading Summary'),
                    Tab(text: 'Subject Assignments'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Main Content Area
              Expanded(
                child: TabBarView(
                  children: [
                    _buildFacultySummaryView(
                      schedulesAsync,
                      facultyAsync,
                      subjectsAsync,
                      roomsAsync,
                      timeslotsAsync,
                      isDark,
                    ),
                    _buildSubjectAssignmentsView(
                      schedulesAsync,
                      facultyAsync,
                      subjectsAsync,
                      roomsAsync,
                      timeslotsAsync,
                      isDark,
                      maroonColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectAssignmentsView(
    AsyncValue<List<Schedule>> schedulesAsync,
    AsyncValue<List<Faculty>> facultyAsync,
    AsyncValue<List<Subject>> subjectsAsync,
    AsyncValue<List<Room>> roomsAsync,
    AsyncValue<List<Timeslot>> timeslotsAsync,
    bool isDark,
    Color maroonColor,
  ) {
    return Column(
      children: [
        Expanded(
          child: schedulesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading schedules',
                    style: GoogleFonts.poppins(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(schedulesProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (schedules) {
              return facultyAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => const Center(child: Text('Error')),
                data: (facultyList) {
                  return subjectsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => const Center(child: Text('Error')),
                    data: (subjectList) {
                      return roomsAsync.when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (error, stack) =>
                            const Center(child: Text('Error')),
                        data: (roomList) {
                          return timeslotsAsync.when(
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (error, stack) =>
                                const Center(child: Text('Error')),
                            data: (timeslotList) {
                              // Create maps for lookup
                              final facultyMap = {
                                for (var f in facultyList) f.id!: f,
                              };
                              final subjectMap = {
                                for (var s in subjectList) s.id!: s,
                              };
                              final roomMap = {
                                for (var r in roomList) r.id!: r,
                              };
                              final timeslotMap = {
                                for (var t in timeslotList) t.id!: t,
                              };

                              final filteredSchedules = schedules.where((
                                schedule,
                              ) {
                                final matchesSearch =
                                    _searchQuery.isEmpty ||
                                    () {
                                      final faculty =
                                          facultyMap[schedule.facultyId];
                                      final subject =
                                          subjectMap[schedule.subjectId];
                                      return (faculty?.name
                                                  .toLowerCase()
                                                  .contains(_searchQuery) ??
                                              false) ||
                                          (subject?.name.toLowerCase().contains(
                                                _searchQuery,
                                              ) ??
                                              false) ||
                                          schedule.section
                                              .toLowerCase()
                                              .contains(_searchQuery);
                                    }();

                                final matchesFaculty =
                                    _selectedFaculty == null ||
                                    schedule.facultyId.toString() ==
                                        _selectedFaculty;

                                return matchesSearch && matchesFaculty;
                              }).toList();

                              if (filteredSchedules.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.assignment_outlined,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _searchQuery.isEmpty
                                            ? 'No assignments yet'
                                            : 'No assignments found',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      if (_searchQuery.isEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          'Click "New Assignment" to get started',
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              }

                              if (ResponsiveHelper.isMobile(context)) {
                                return _buildMobileSubjectAssignmentsList(
                                  filteredSchedules,
                                  facultyMap,
                                  subjectMap,
                                  roomMap,
                                  timeslotMap,
                                  isDark,
                                  maroonColor,
                                );
                              }

                              return Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.transparent
                                        : Colors.grey[300]!,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: maroonColor.withOpacity(
                                          0.05,
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.assignment_rounded,
                                            color: maroonColor,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Schedule Assignments',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: maroonColor,
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: maroonColor,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              '${filteredSchedules.length} Total',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          return SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                minWidth: constraints.maxWidth,
                                              ),
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.vertical,
                                                child: DataTable(
                                                  headingRowColor:
                                                      WidgetStateProperty.all(
                                                        maroonColor,
                                                      ),
                                                  headingTextStyle:
                                                      GoogleFonts.poppins(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                        letterSpacing: 0.5,
                                                      ),
                                                  dataRowMinHeight: 70,
                                                  dataRowMaxHeight: 90,
                                                  columnSpacing: 28,
                                                  horizontalMargin: 24,
                                                  decoration:
                                                      const BoxDecoration(
                                                        color:
                                                            Colors.transparent,
                                                      ),
                                                  columns: const [
                                                    DataColumn(
                                                      label: Text('FACULTY'),
                                                    ),
                                                    DataColumn(
                                                      label: Text('SUBJECT'),
                                                    ),
                                                    DataColumn(
                                                      label: Text('SECTION'),
                                                    ),
                                                    DataColumn(
                                                      label: Text('LOAD'),
                                                    ),
                                                    DataColumn(
                                                      label: Text('UNITS'),
                                                    ),
                                                    DataColumn(
                                                      label: Text('HOURS'),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'ROOM & SCHEDULE',
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text('STATUS'),
                                                    ),
                                                    DataColumn(
                                                      label: Text('ACTIONS'),
                                                    ),
                                                  ],
                                                  rows: filteredSchedules.asMap().entries.map((
                                                    entry,
                                                  ) {
                                                    final schedule =
                                                        entry.value;
                                                    final index = entry.key;
                                                    final faculty =
                                                        facultyMap[schedule
                                                            .facultyId];
                                                    final subject =
                                                        subjectMap[schedule
                                                            .subjectId];
                                                    final room =
                                                        roomMap[schedule
                                                            .roomId];
                                                    final timeslot =
                                                        timeslotMap[schedule
                                                            .timeslotId];

                                                    final isAutoAssign =
                                                        schedule.roomId == -1 ||
                                                        schedule.timeslotId ==
                                                            -1;

                                                    return DataRow(
                                                      color: WidgetStateProperty.resolveWith<Color?>(
                                                        (states) {
                                                          if (states.contains(
                                                            WidgetState.hovered,
                                                          )) {
                                                            return maroonColor
                                                                .withValues(
                                                                  alpha: 0.05,
                                                                );
                                                          }
                                                          return index.isEven
                                                              ? (isDark
                                                                    ? Colors
                                                                          .white
                                                                          .withValues(
                                                                            alpha:
                                                                                0.02,
                                                                          )
                                                                    : Colors
                                                                          .grey
                                                                          .withValues(
                                                                            alpha:
                                                                                0.02,
                                                                          ))
                                                              : null;
                                                        },
                                                      ),
                                                      cells: [
                                                        DataCell(
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width: 40,
                                                                height: 40,
                                                                decoration: BoxDecoration(
                                                                  gradient: LinearGradient(
                                                                    colors: [
                                                                      maroonColor,
                                                                      maroonColor.withValues(
                                                                        alpha:
                                                                            0.7,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        10,
                                                                      ),
                                                                ),
                                                                child: Center(
                                                                  child: Text(
                                                                    (faculty?.name.isNotEmpty ??
                                                                            false)
                                                                        ? faculty!
                                                                              .name[0]
                                                                              .toUpperCase()
                                                                        : '?',
                                                                    style: GoogleFonts.poppins(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 12,
                                                              ),
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    faculty?.name ??
                                                                        'Unknown',
                                                                    style: GoogleFonts.poppins(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                                  ),
                                                                  if (faculty
                                                                          ?.facultyId !=
                                                                      null)
                                                                    Text(
                                                                      'ID: ${faculty!.facultyId}',
                                                                      style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            11,
                                                                        color: Colors
                                                                            .grey[600],
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                subject?.name ??
                                                                    'Unknown',
                                                                style: GoogleFonts.poppins(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 13,
                                                                ),
                                                              ),
                                                              if (subject
                                                                      ?.code !=
                                                                  null)
                                                                Text(
                                                                  subject!.code,
                                                                  style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        11,
                                                                    color: Colors
                                                                        .grey[600],
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 8,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: maroonColor
                                                                  .withValues(
                                                                    alpha: 0.08,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10,
                                                                  ),
                                                            ),
                                                            child: Text(
                                                              schedule.section,
                                                              style: GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 13,
                                                                color:
                                                                    maroonColor,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 4,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  _getLoadTypeColor(
                                                                    schedule
                                                                        .loadTypes,
                                                                  ).withValues(
                                                                    alpha: 0.1,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                              border: Border.all(
                                                                color:
                                                                    _getLoadTypeColor(
                                                                      schedule
                                                                          .loadTypes,
                                                                    ).withValues(
                                                                      alpha:
                                                                          0.3,
                                                                    ),
                                                              ),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Icon(
                                                                  _getLoadTypeIcon(
                                                                    (schedule.loadTypes !=
                                                                                null &&
                                                                            schedule.loadTypes!.isNotEmpty)
                                                                        ? schedule
                                                                              .loadTypes!
                                                                              .first
                                                                        : null,
                                                                  ),
                                                                  size: 14,
                                                                  color: _getLoadTypeColor(
                                                                    schedule
                                                                        .loadTypes,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 4,
                                                                ),
                                                                Text(
                                                                  _getLoadTypeText(
                                                                    schedule
                                                                        .loadTypes,
                                                                  ),
                                                                  style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        11,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: _getLoadTypeColor(
                                                                      schedule
                                                                          .loadTypes,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Text(
                                                            schedule.units
                                                                    ?.toString() ??
                                                                'N/A',
                                                            style:
                                                                GoogleFonts.poppins(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Text(
                                                            schedule.hours
                                                                    ?.toString() ??
                                                                'N/A',
                                                            style:
                                                                GoogleFonts.poppins(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .meeting_room_rounded,
                                                                    size: 16,
                                                                    color:
                                                                        isAutoAssign
                                                                        ? Colors
                                                                              .orange
                                                                        : maroonColor,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 6,
                                                                  ),
                                                                  Text(
                                                                    room?.name ??
                                                                        'Waiting for AI...',
                                                                    style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color:
                                                                          isAutoAssign
                                                                          ? Colors.orange
                                                                          : Colors.black87,
                                                                      fontStyle:
                                                                          isAutoAssign
                                                                          ? FontStyle.italic
                                                                          : null,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .access_time_rounded,
                                                                    size: 16,
                                                                    color:
                                                                        isAutoAssign
                                                                        ? Colors
                                                                              .orange
                                                                        : Colors
                                                                              .grey[600],
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 6,
                                                                  ),
                                                                  Text(
                                                                    timeslot !=
                                                                            null
                                                                        ? '${_getDayAbbr(timeslot.day)} ${timeslot.startTime}-${timeslot.endTime}'
                                                                        : 'Waiting for AI...',
                                                                    style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          11,
                                                                      color:
                                                                          isAutoAssign
                                                                          ? Colors.orange
                                                                          : Colors.grey[700],
                                                                      fontStyle:
                                                                          isAutoAssign
                                                                          ? FontStyle.italic
                                                                          : null,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      14,
                                                                  vertical: 8,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              gradient: LinearGradient(
                                                                colors:
                                                                    isAutoAssign
                                                                    ? [
                                                                        Colors
                                                                            .orange,
                                                                        Colors.orange.withValues(
                                                                          alpha:
                                                                              0.7,
                                                                        ),
                                                                      ]
                                                                    : [
                                                                        Colors
                                                                            .green,
                                                                        Colors.green.withValues(
                                                                          alpha:
                                                                              0.7,
                                                                        ),
                                                                      ],
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    20,
                                                                  ),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color:
                                                                      (isAutoAssign
                                                                              ? Colors.orange
                                                                              : Colors.green)
                                                                          .withValues(
                                                                            alpha:
                                                                                0.3,
                                                                          ),
                                                                  blurRadius: 8,
                                                                  offset:
                                                                      const Offset(
                                                                        0,
                                                                        2,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Icon(
                                                                  isAutoAssign
                                                                      ? Icons
                                                                            .pending_actions
                                                                      : Icons
                                                                            .check_circle,
                                                                  size: 14,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                const SizedBox(
                                                                  width: 6,
                                                                ),
                                                                Text(
                                                                  isAutoAssign
                                                                      ? 'Pending AI'
                                                                      : 'Scheduled',
                                                                  style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Material(
                                                                color: Colors
                                                                    .transparent,
                                                                child: InkWell(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                  onTap: () =>
                                                                      _showEditAssignmentModal(
                                                                        schedule,
                                                                      ),
                                                                  child: Container(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                          8,
                                                                        ),
                                                                    decoration: BoxDecoration(
                                                                      color: maroonColor.withValues(
                                                                        alpha:
                                                                            0.1,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            8,
                                                                          ),
                                                                    ),
                                                                    child: Icon(
                                                                      Icons
                                                                          .edit_outlined,
                                                                      color:
                                                                          maroonColor,
                                                                      size: 18,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              Material(
                                                                color: Colors
                                                                    .transparent,
                                                                child: InkWell(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                  onTap: () =>
                                                                      _deleteSchedule(
                                                                        schedule,
                                                                      ),
                                                                  child: Container(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                          8,
                                                                        ),
                                                                    decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .red
                                                                          .withValues(
                                                                            alpha:
                                                                                0.1,
                                                                          ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            8,
                                                                          ),
                                                                    ),
                                                                    child: const Icon(
                                                                      Icons
                                                                          .delete_outline,
                                                                      color: Colors
                                                                          .red,
                                                                      size: 18,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFacultySummaryView(
    AsyncValue<List<Schedule>> schedulesAsync,
    AsyncValue<List<Faculty>> facultyAsync,
    AsyncValue<List<Subject>> subjectsAsync,
    AsyncValue<List<Room>> roomsAsync,
    AsyncValue<List<Timeslot>> timeslotsAsync,
    bool isDark,
  ) {
    final maroonColor = const Color(0xFF4f003b);

    return schedulesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (schedules) => facultyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (facultyList) {
          final subjectList = subjectsAsync.maybeWhen(
            data: (d) => d,
            orElse: () => <Subject>[],
          );
          final timeslotList = timeslotsAsync.maybeWhen(
            data: (d) => d,
            orElse: () => <Timeslot>[],
          );

          final subjectMap = {for (var s in subjectList) s.id ?? -1: s};
          final timeslotMap = {for (var t in timeslotList) t.id ?? -1: t};
          final allConflicts = ref.watch(allConflictsProvider);

          // Pre-calculate stats for each faculty to avoid work in build/rows
          final List<Map<String, dynamic>> facultyStats = facultyList
              .where((f) {
                if (_searchQuery.isEmpty) return true;
                return f.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
              })
              .map((faculty) {
                final assignments = schedules
                    .where((s) => s.facultyId == faculty.id)
                    .toList();

                double totalUnits = 0;
                double totalHours = 0;
                bool hasConflicts = false;

                for (var schedule in assignments) {
                  // Units from schedule or fallback to subject
                  totalUnits +=
                      schedule.units ??
                      (subjectMap[schedule.subjectId]?.units.toDouble() ?? 0.0);

                  // Hours (prefer explicit hours field, fallback to timeslot)
                  if (schedule.hours != null) {
                    totalHours += schedule.hours!;
                  } else if (schedule.timeslotId != null) {
                    final t = timeslotMap[schedule.timeslotId];
                    if (t != null) {
                      try {
                        final startParts = t.startTime.split(':');
                        final endParts = t.endTime.split(':');
                        final startMin =
                            int.parse(startParts[0]) * 60 +
                            int.parse(startParts[1]);
                        final endMin =
                            int.parse(endParts[0]) * 60 +
                            int.parse(endParts[1]);
                        totalHours += (endMin - startMin) / 60.0;
                      } catch (e) {
                        /* ignore */
                      }
                    }
                  }

                  // Conflicts check
                  final conflictsForSchedule = allConflicts.maybeWhen(
                    data: (conflicts) => conflicts
                        .where(
                          (c) =>
                              c.facultyId == faculty.id ||
                              c.conflictingScheduleId == schedule.id ||
                              c.scheduleId == schedule.id,
                        )
                        .isNotEmpty,
                    orElse: () => false,
                  );

                  if (conflictsForSchedule) hasConflicts = true;
                }

                return {
                  'faculty': faculty,
                  'assignedSubjects': assignments.length,
                  'totalUnits': totalUnits,
                  'totalHours': totalHours,
                  'hasConflicts': hasConflicts,
                  'remainingLoad': faculty.maxLoad - totalHours,
                };
              })
              .toList();

          if (ResponsiveHelper.isMobile(context)) {
            return _buildMobileFacultySummaryList(
              facultyStats,
              isDark,
              maroonColor,
            );
          }

          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.transparent : Colors.grey[300]!,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width - 64,
                ),
                child: DataTable(
                  columnSpacing: 24,
                  showCheckboxColumn: false,
                  headingRowColor: WidgetStateProperty.all(
                    maroonColor.withOpacity(0.05),
                  ),
                  columns: [
                    DataColumn(
                      label: Text(
                        'FACULTY NAME',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'SUBJECTS',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'UNITS',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'HOURS',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'REMAINING',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'STATUS',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                  rows: facultyStats.map((stats) {
                    final f = stats['faculty'] as Faculty;
                    final hasC = stats['hasConflicts'] as bool;
                    final remLoad = stats['remainingLoad'] as double;

                    return DataRow(
                      onSelectChanged: (_) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FacultyLoadDetailsScreen(
                              faculty: f,
                              initialSchedules: schedules
                                  .where((s) => s.facultyId == f.id)
                                  .toList(),
                            ),
                          ),
                        );
                      },
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              if (hasC)
                                const Icon(
                                  Icons.warning_rounded,
                                  color: Colors.orange,
                                  size: 16,
                                ),
                              if (hasC) const SizedBox(width: 4),
                              Text(
                                f.name,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Text(
                            stats['assignedSubjects'].toString(),
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                        DataCell(
                          Text(
                            stats['totalUnits'].toString(),
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${(stats['totalHours'] as double).toStringAsFixed(1)}h',
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: remLoad < 0
                                  ? Colors.red.withValues(alpha: 0.1)
                                  : Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              remLoad.toStringAsFixed(1),
                              style: GoogleFonts.poppins(
                                color: remLoad < 0 ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          hasC
                              ? const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                )
                              : const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getLoadTypeColor(List<SubjectType>? types) {
    if (types == null || types.isEmpty) return Colors.grey;
    if (types.contains(SubjectType.lecture) &&
        types.contains(SubjectType.laboratory))
      return Colors.orange;
    if (types.contains(SubjectType.lecture)) return Colors.purple;
    if (types.contains(SubjectType.laboratory)) return Colors.teal;
    return Colors.blue;
  }

  String _getLoadTypeText(List<SubjectType>? types) {
    if (types == null || types.isEmpty) return 'N/A';
    return types.map((t) => t.name.toUpperCase()).join(' / ');
  }

  IconData _getLoadTypeIcon(SubjectType? type) {
    if (type == null) return Icons.help_outline;
    switch (type) {
      case SubjectType.lecture:
        return Icons.menu_book;
      case SubjectType.laboratory:
        return Icons.science;
      case SubjectType.blended:
        return Icons.layers_outlined;
    }
  }

  String _getDayAbbr(DayOfWeek day) {
    switch (day) {
      case DayOfWeek.mon:
        return 'Mon';
      case DayOfWeek.tue:
        return 'Tue';
      case DayOfWeek.wed:
        return 'Wed';
      case DayOfWeek.thu:
        return 'Thu';
      case DayOfWeek.fri:
        return 'Fri';
      case DayOfWeek.sat:
        return 'Sat';
      case DayOfWeek.sun:
        return 'Sun';
    }
  }

  Widget _buildConflictBanner(
    AsyncValue<List<Schedule>> schedulesAsync,
    AsyncValue<List<Faculty>> facultyAsync,
  ) {
    final allConflicts = ref.watch(allConflictsProvider);
    return allConflicts.when(
      loading: () => const SizedBox(),
      error: (error, stack) => const SizedBox(),
      data: (conflictsList) {
        final conflicts = conflictsList.map((c) => c.message).toList();
        final hasConflicts = conflicts.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: hasConflicts ? Colors.red[50] : Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasConflicts ? Colors.red[200]! : Colors.green[200]!,
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: () {
              if (hasConflicts) {
                setState(() {
                  _showConflictDetails = !_showConflictDetails;
                });
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        hasConflicts
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_outline_rounded,
                        color: hasConflicts
                            ? Colors.red[700]
                            : Colors.green[700],
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasConflicts
                                  ? 'Schedule Conflicts Detected'
                                  : 'No Schedule Conflicts',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: hasConflicts
                                    ? Colors.red[900]
                                    : Colors.green[900],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hasConflicts
                                  ? 'System found ${conflicts.length} overlapping assignments'
                                  : 'All faculty assignments are conflict-free',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: hasConflicts
                                    ? Colors.red[700]
                                    : Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (hasConflicts)
                        Icon(
                          _showConflictDetails
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: Colors.red[900],
                          size: 28,
                        ),
                    ],
                  ),
                ),
                if (hasConflicts && _showConflictDetails)
                  Container(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 20,
                    ),
                    child: Column(
                      children: [
                        const Divider(),
                        const SizedBox(height: 12),
                        ...conflicts.map(
                          (msg) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    msg,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.red[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.transparent : Colors.grey[300]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: maroonColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              cursorColor: isDark ? Colors.white : Colors.black87,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                filled: false,
                fillColor: Colors.transparent,
                hintText: 'Search faculty or subjects...',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: Colors.grey[600]),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFacultyFilter(
    AsyncValue<List<Faculty>> facultyAsync,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: facultyAsync.when(
        loading: () => const SizedBox(),
        error: (_, __) => const SizedBox(),
        data: (facultyList) {
          return DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: _selectedFaculty,
              hint: Row(
                children: [
                  Icon(Icons.filter_list_rounded, color: maroonColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Filter by Faculty',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    'All Faculty',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ),
                ...facultyList.map((f) {
                  return DropdownMenuItem<String>(
                    value: f.id.toString(),
                    child: Text(
                      f.name,
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFaculty = value;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileFacultySummaryList(
    List<Map<String, dynamic>> facultyStats,
    bool isDark,
    Color maroonColor,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: facultyStats.length,
      itemBuilder: (context, index) {
        final stats = facultyStats[index];
        final f = stats['faculty'] as Faculty;
        final hasC = stats['hasConflicts'] as bool;
        final remLoad = stats['remainingLoad'] as double;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDark ? Colors.white10 : Colors.grey[200]!,
            ),
          ),
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: maroonColor.withOpacity(0.1),
              child: Text(
                f.name.isNotEmpty ? f.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: maroonColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Row(
              children: [
                if (hasC)
                  const Icon(
                    Icons.warning_rounded,
                    color: Colors.orange,
                    size: 16,
                  ),
                if (hasC) const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    f.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Text(
              '${stats['assignedSubjects']} Subjects • ${stats['totalUnits']} Units',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSummaryDetailRow(
                      'Total Hours',
                      '${(stats['totalHours'] as double).toStringAsFixed(1)}h',
                    ),
                    _buildSummaryDetailRow(
                      'Remaining Load',
                      remLoad.toStringAsFixed(1),
                      valueColor: remLoad < 0 ? Colors.red : Colors.green,
                    ),
                    _buildSummaryDetailRow(
                      'Status',
                      hasC ? 'Conflicts Found' : 'Clean',
                      valueColor: hasC ? Colors.red : Colors.green,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FacultyLoadDetailsScreen(
                                faculty: f,
                                initialSchedules:
                                    (ref.read(schedulesProvider).value ?? [])
                                        .where((s) => s.facultyId == f.id)
                                        .toList(),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: maroonColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('View Full Details'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryDetailRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 13)),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileSubjectAssignmentsList(
    List<Schedule> assignments,
    Map<int, Faculty> facultyMap,
    Map<int, Subject> subjectMap,
    Map<int, Room> roomMap,
    Map<int, Timeslot> timeslotMap,
    bool isDark,
    Color maroonColor,
  ) {
    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_late_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No assignments found',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final s = assignments[index];
        final sub = subjectMap[s.subjectId];
        final fac = facultyMap[s.facultyId];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDark ? Colors.white10 : Colors.grey[200]!,
            ),
          ),
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        s.section,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: maroonColor,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (val) {
                        if (val == 'edit') {
                          _showEditAssignmentModal(s);
                        } else if (val == 'delete') {
                          _deleteSchedule(s);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  sub?.name ?? 'Unknown Subject',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fac?.name ?? 'Unknown Faculty',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn('Room', s.roomId?.toString() ?? 'Auto'),
                    _buildInfoColumn(
                      'Time',
                      s.timeslotId?.toString() ?? 'Auto',
                    ),
                    _buildInfoColumn('Units', s.units?.toString() ?? '-'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// New Assignment Modal
class _NewAssignmentModal extends ConsumerStatefulWidget {
  final Color maroonColor;
  final VoidCallback onSuccess;

  const _NewAssignmentModal({
    required this.maroonColor,
    required this.onSuccess,
  });

  @override
  ConsumerState<_NewAssignmentModal> createState() =>
      _NewAssignmentModalState();
}

class _NewAssignmentModalState extends ConsumerState<_NewAssignmentModal> {
  final _formKey = GlobalKey<FormState>();
  final _sectionController = TextEditingController();
  final _unitsController = TextEditingController();
  final _hoursController = TextEditingController();

  int? _selectedFacultyId;
  int? _selectedSubjectId;
  int? _selectedRoomId;
  int? _selectedTimeslotId;
  final List<SubjectType> _selectedLoadTypes = [];
  bool _isAutoAssign = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _sectionController.dispose();
    _unitsController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final schedule = Schedule(
        facultyId: _selectedFacultyId!,
        subjectId: _selectedSubjectId!,
        roomId: _isAutoAssign ? null : _selectedRoomId,
        timeslotId: _isAutoAssign ? null : _selectedTimeslotId,
        section: _sectionController.text.trim(),
        loadTypes: _selectedLoadTypes,
        units: double.tryParse(_unitsController.text),
        hours: double.tryParse(_hoursController.text),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await client.admin.createSchedule(schedule);

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assignment created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final facultyAsync = ref.watch(facultyListProvider);
    final subjectsAsync = ref.watch(subjectsProvider);
    final roomsAsync = ref.watch(roomsProvider);
    final timeslotsAsync = ref.watch(timeslotsProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryPurple = widget.maroonColor;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final bgBody = isDark ? const Color(0xFF0F172A) : const Color(0xFFEEF1F6);
    final textPrimary = isDark
        ? const Color(0xFFE2E8F0)
        : const Color(0xFF333333);
    final textMuted = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF666666);
    final isMobile = ResponsiveHelper.isMobile(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: isMobile ? double.infinity : 650,
        constraints: BoxConstraints(
          maxHeight: isMobile ? MediaQuery.of(context).size.height * 0.9 : 750,
        ),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: primaryPurple.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section with Gradient
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 28,
                vertical: isMobile ? 20 : 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryPurple,
                    const Color(0xFFb5179e),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(19),
                ),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.assignment_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Assignment',
                          style: GoogleFonts.poppins(
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Assign a subject to a faculty member',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),

            // Main Body
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 20 : 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Faculty Selection
                      _buildLabel(
                        'Select Faculty',
                        Icons.person_outline_rounded,
                        textPrimary,
                      ),
                      facultyAsync.when(
                        loading: () => Center(
                          child: CircularProgressIndicator(
                            color: primaryPurple,
                          ),
                        ),
                        error: (error, stack) => Text(
                          'Error loading faculty',
                          style: TextStyle(color: Colors.red),
                        ),
                        data: (facultyList) => _buildDropdown<int>(
                          value: _selectedFacultyId,
                          bgBody: bgBody,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
                          primaryPurple: primaryPurple,
                          items: facultyList.map((f) => f.id!).toList(),
                          itemLabel: (id) =>
                              facultyList.firstWhere((f) => f.id == id).name,
                          onChanged: (value) =>
                              setState(() => _selectedFacultyId = value),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Subject Selection
                      _buildLabel(
                        'Select Subject',
                        Icons.book_outlined,
                        textPrimary,
                      ),
                      subjectsAsync.when(
                        loading: () => Center(
                          child: CircularProgressIndicator(
                            color: primaryPurple,
                          ),
                        ),
                        error: (error, stack) => Text(
                          'Error loading subjects',
                          style: TextStyle(color: Colors.red),
                        ),
                        data: (subjectList) => _buildDropdown<int>(
                          value: _selectedSubjectId,
                          bgBody: bgBody,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
                          primaryPurple: primaryPurple,
                          items: subjectList.map((s) => s.id!).toList(),
                          itemLabel: (id) =>
                              subjectList.firstWhere((s) => s.id == id).name,
                          onChanged: (value) {
                            if (value == null) return;
                            final subject = subjectList.firstWhere(
                              (s) => s.id == value,
                            );
                            setState(() {
                              _selectedSubjectId = value;
                              _unitsController.text = subject.units.toString();
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Section
                      _buildLabel(
                        'Class Section',
                        Icons.groups_outlined,
                        textPrimary,
                      ),
                      TextFormField(
                        controller: _sectionController,
                        decoration: _buildInputDecoration(
                          'e.g. BSIT 4A',
                          bgBody,
                          primaryPurple,
                          textMuted,
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: textPrimary,
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),

                      // Units and Hours
                      isMobile
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(
                                  'Units',
                                  Icons.numbers_rounded,
                                  textPrimary,
                                ),
                                TextFormField(
                                  controller: _unitsController,
                                  decoration: _buildInputDecoration(
                                    '3',
                                    bgBody,
                                    primaryPurple,
                                    textMuted,
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: textPrimary,
                                  ),
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Required'
                                      : null,
                                ),
                                const SizedBox(height: 20),
                                _buildLabel(
                                  'Hours',
                                  Icons.timer_outlined,
                                  textPrimary,
                                ),
                                TextFormField(
                                  controller: _hoursController,
                                  decoration: _buildInputDecoration(
                                    '3',
                                    bgBody,
                                    primaryPurple,
                                    textMuted,
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: textPrimary,
                                  ),
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Required'
                                      : null,
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel(
                                        'Units',
                                        Icons.numbers_rounded,
                                        textPrimary,
                                      ),
                                      TextFormField(
                                        controller: _unitsController,
                                        decoration: _buildInputDecoration(
                                          '3',
                                          bgBody,
                                          primaryPurple,
                                          textMuted,
                                        ),
                                        keyboardType: TextInputType.number,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          color: textPrimary,
                                        ),
                                        validator: (value) =>
                                            value?.isEmpty ?? true
                                            ? 'Required'
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel(
                                        'Hours',
                                        Icons.timer_outlined,
                                        textPrimary,
                                      ),
                                      TextFormField(
                                        controller: _hoursController,
                                        decoration: _buildInputDecoration(
                                          '3',
                                          bgBody,
                                          primaryPurple,
                                          textMuted,
                                        ),
                                        keyboardType: TextInputType.number,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          color: textPrimary,
                                        ),
                                        validator: (value) =>
                                            value?.isEmpty ?? true
                                            ? 'Required'
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(height: 24),

                      // Load Types (Chips)
                      _buildLabel(
                        'Subject Types',
                        Icons.category_outlined,
                        textPrimary,
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: SubjectType.values.map((type) {
                          final isSelected = _selectedLoadTypes.contains(type);
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedLoadTypes.remove(type);
                                } else {
                                  _selectedLoadTypes.add(type);
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? primaryPurple : bgBody,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? primaryPurple
                                      : Colors.black.withOpacity(0.05),
                                ),
                              ),
                              child: Text(
                                type.name.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : textMuted,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Auto-Assign Toggle
                      InkWell(
                        onTap: () => setState(() {
                          _isAutoAssign = !_isAutoAssign;
                          if (_isAutoAssign) {
                            _selectedRoomId = null;
                            _selectedTimeslotId = null;
                          }
                        }),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: bgBody,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.black.withOpacity(0.05),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                size: 20,
                                color: textMuted,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Auto-Assign Room & Time',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Let the system find the best slot',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isAutoAssign,
                                onChanged: (value) => setState(() {
                                  _isAutoAssign = value;
                                  if (_isAutoAssign) {
                                    _selectedRoomId = null;
                                    _selectedTimeslotId = null;
                                  }
                                }),
                                activeColor: primaryPurple,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Manual Assignment (Hidden if Auto-Assign)
                      if (!_isAutoAssign) ...[
                        _buildLabel(
                          'Select Room',
                          Icons.room_outlined,
                          textPrimary,
                        ),
                        roomsAsync.when(
                          loading: () => Center(
                            child: CircularProgressIndicator(
                              color: primaryPurple,
                            ),
                          ),
                          error: (error, stack) => Text(
                            'Error loading rooms',
                            style: TextStyle(color: Colors.red),
                          ),
                          data: (roomList) => _buildDropdown<int>(
                            value: _selectedRoomId,
                            bgBody: bgBody,
                            textPrimary: textPrimary,
                            textMuted: textMuted,
                            primaryPurple: primaryPurple,
                            items: roomList.map((r) => r.id!).toList(),
                            itemLabel: (id) =>
                                roomList.firstWhere((r) => r.id == id).name,
                            onChanged: (value) =>
                                setState(() => _selectedRoomId = value),
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildLabel(
                          'Select Timeslot',
                          Icons.schedule_rounded,
                          textPrimary,
                        ),
                        timeslotsAsync.when(
                          loading: () => Center(
                            child: CircularProgressIndicator(
                              color: primaryPurple,
                            ),
                          ),
                          error: (error, stack) => Text(
                            'Error loading timeslots',
                            style: TextStyle(color: Colors.red),
                          ),
                          data: (timeslotList) => _buildDropdown<int>(
                            value: _selectedTimeslotId,
                            bgBody: bgBody,
                            textPrimary: textPrimary,
                            textMuted: textMuted,
                            primaryPurple: primaryPurple,
                            items: timeslotList.map((t) => t.id!).toList(),
                            itemLabel: (id) {
                              final t = timeslotList.firstWhere(
                                (t) => t.id == id,
                              );
                              return CITESchedDateUtils.formatTimeslot(
                                t.day,
                                t.startTime,
                                t.endTime,
                              );
                            },
                            onChanged: (value) =>
                                setState(() => _selectedTimeslotId = value),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBg,
                border: Border(
                  top: BorderSide(color: Colors.black.withOpacity(0.05)),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(19),
                  bottomRight: Radius.circular(19),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 20 : 28,
                  0,
                  isMobile ? 20 : 28,
                  isMobile ? 20 : 28,
                ),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              disabledBackgroundColor: primaryPurple
                                  .withOpacity(0.5),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check_rounded, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Create Assignment',
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.black.withOpacity(0.1),
                                ),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Colors.black.withOpacity(0.1),
                                  ),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                disabledBackgroundColor: primaryPurple
                                    .withOpacity(0.5),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.check_rounded,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Create Assignment',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color.withOpacity(0.7)),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String hintText,
    Color bgBody,
    Color primaryPurple,
    Color textMuted,
  ) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(color: textMuted, fontSize: 14),
      filled: true,
      fillColor: bgBody,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryPurple, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemLabel,
    required Color bgBody,
    required Color textPrimary,
    required Color textMuted,
    required Color primaryPurple,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: bgBody,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: textMuted),
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: textPrimary,
            fontWeight: FontWeight.w500,
          ),
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel(item)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// Edit Assignment Modal (similar structure to New Assignment)
class _EditAssignmentModal extends ConsumerStatefulWidget {
  final Schedule schedule;
  final Color maroonColor;
  final VoidCallback onSuccess;

  const _EditAssignmentModal({
    required this.schedule,
    required this.maroonColor,
    required this.onSuccess,
  });

  @override
  ConsumerState<_EditAssignmentModal> createState() =>
      _EditAssignmentModalState();
}

class _EditAssignmentModalState extends ConsumerState<_EditAssignmentModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _sectionController;
  late TextEditingController _unitsController;
  late TextEditingController _hoursController;

  late int _selectedFacultyId;
  late int _selectedSubjectId;
  int? _selectedRoomId;
  int? _selectedTimeslotId;
  List<SubjectType> _selectedLoadTypes = [];
  bool _isAutoAssign = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sectionController = TextEditingController(text: widget.schedule.section);
    _unitsController = TextEditingController(
      text: widget.schedule.units?.toString() ?? '',
    );
    _hoursController = TextEditingController(
      text: widget.schedule.hours?.toString() ?? '',
    );
    _selectedFacultyId = widget.schedule.facultyId;
    _selectedSubjectId = widget.schedule.subjectId;
    _selectedRoomId = widget.schedule.roomId == -1
        ? null
        : widget.schedule.roomId;
    _selectedTimeslotId = widget.schedule.timeslotId == -1
        ? null
        : widget.schedule.timeslotId;
    _selectedLoadTypes = List.from(widget.schedule.loadTypes ?? []);
    _isAutoAssign =
        widget.schedule.roomId == -1 || widget.schedule.timeslotId == -1;
  }

  @override
  void dispose() {
    _sectionController.dispose();
    _unitsController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedSchedule = Schedule(
        id: widget.schedule.id,
        facultyId: _selectedFacultyId,
        subjectId: _selectedSubjectId,
        roomId: _isAutoAssign ? null : _selectedRoomId,
        timeslotId: _isAutoAssign ? null : _selectedTimeslotId,
        section: _sectionController.text.trim(),
        loadTypes: _selectedLoadTypes,
        units: double.tryParse(_unitsController.text),
        hours: double.tryParse(_hoursController.text),
        createdAt: widget.schedule.createdAt,
        updatedAt: DateTime.now(),
      );

      await client.admin.updateSchedule(updatedSchedule);

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assignment updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final facultyAsync = ref.watch(facultyListProvider);
    final subjectsAsync = ref.watch(subjectsProvider);
    final roomsAsync = ref.watch(roomsProvider);
    final timeslotsAsync = ref.watch(timeslotsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 750),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.black45 : Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.edit_rounded,
                    color: isDark ? Colors.white : Colors.black,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Edit Schedule Assignment',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                    ),
                  ),
                ],
              ),
            ),

            // Form (same structure as New Assignment)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Faculty Dropdown
                      facultyAsync.when(
                        loading: () => const CircularProgressIndicator(),
                        error: (error, stack) =>
                            const Text('Error loading faculty'),
                        data: (facultyList) => _buildDropdown<int>(
                          label: 'Faculty',
                          value: _selectedFacultyId,
                          items: facultyList.map((f) => f.id!).toList(),
                          itemLabel: (id) =>
                              facultyList.firstWhere((f) => f.id == id).name,
                          onChanged: (value) =>
                              setState(() => _selectedFacultyId = value!),
                          validator: (value) =>
                              value == null ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Subject Dropdown
                      subjectsAsync.when(
                        loading: () => const CircularProgressIndicator(),
                        error: (error, stack) =>
                            const Text('Error loading subjects'),
                        data: (subjectList) => _buildDropdown<int>(
                          label: 'Subject',
                          value: _selectedSubjectId,
                          items: subjectList.map((s) => s.id!).toList(),
                          itemLabel: (id) =>
                              subjectList.firstWhere((s) => s.id == id).name,
                          onChanged: (value) =>
                              setState(() => _selectedSubjectId = value!),
                          validator: (value) =>
                              value == null ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Section
                      _buildTextField(
                        controller: _sectionController,
                        label: 'Section',
                        icon: Icons.class_,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      // Load Type
                      // Load Types
                      Text(
                        'Subject Types',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: SubjectType.values.map((type) {
                          final isSelected = _selectedLoadTypes.contains(type);
                          return FilterChip(
                            label: Text(type.name.toUpperCase()),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedLoadTypes.add(type);
                                } else {
                                  _selectedLoadTypes.remove(type);
                                }
                              });
                            },
                            selectedColor: widget.maroonColor.withValues(
                              alpha: 0.2,
                            ),
                            checkmarkColor: widget.maroonColor,
                            labelStyle: GoogleFonts.poppins(
                              color: isSelected
                                  ? widget.maroonColor
                                  : (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white70
                                        : Colors.black87),
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Units
                      _buildTextField(
                        controller: _unitsController,
                        label: 'Units',
                        icon: Icons.numbers,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Hours
                      _buildTextField(
                        controller: _hoursController,
                        label: 'Hours',
                        icon: Icons.access_time,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),

                      // Auto-Assign Checkbox
                      CheckboxListTile(
                        value: _isAutoAssign,
                        onChanged: (value) {
                          setState(() {
                            _isAutoAssign = value ?? false;
                            if (_isAutoAssign) {
                              _selectedRoomId = null;
                              _selectedTimeslotId = null;
                            }
                          });
                        },
                        title: Text(
                          'Auto-Assign Room & Timeslot',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Let the system automatically assign room and time',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        activeColor: widget.maroonColor,
                      ),
                      const SizedBox(height: 16),

                      // Room & Timeslot (if not auto-assign)
                      if (!_isAutoAssign) ...[
                        roomsAsync.when(
                          loading: () => const CircularProgressIndicator(),
                          error: (error, stack) =>
                              const Text('Error loading rooms'),
                          data: (roomList) => _buildDropdown<int>(
                            label: 'Room',
                            value: _selectedRoomId,
                            items: roomList.map((r) => r.id!).toList(),
                            itemLabel: (id) =>
                                roomList.firstWhere((r) => r.id == id).name,
                            onChanged: (value) =>
                                setState(() => _selectedRoomId = value),
                          ),
                        ),
                        const SizedBox(height: 16),
                        timeslotsAsync.when(
                          loading: () => const CircularProgressIndicator(),
                          error: (error, stack) =>
                              const Text('Error loading timeslots'),
                          data: (timeslotList) => _buildDropdown<int>(
                            label: 'Timeslot',
                            value: _selectedTimeslotId,
                            items: timeslotList.map((t) => t.id!).toList(),
                            itemLabel: (id) {
                              final t = timeslotList.firstWhere(
                                (t) => t.id == id,
                              );
                              return CITESchedDateUtils.formatTimeslot(
                                t.day,
                                t.startTime,
                                t.endTime,
                              );
                            },
                            onChanged: (value) =>
                                setState(() => _selectedTimeslotId = value),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.black45 : Colors.grey[200]!,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.maroonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        prefixIcon: Icon(icon, color: widget.maroonColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: widget.maroonColor, width: 2),
        ),
      ),
      style: GoogleFonts.poppins(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black87,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: widget.maroonColor, width: 2),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(itemLabel(item), style: GoogleFonts.poppins()),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      style: GoogleFonts.poppins(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black87,
      ),
    );
  }
}
