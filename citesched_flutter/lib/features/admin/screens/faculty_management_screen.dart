import 'package:citesched_client/citesched_client.dart';
import 'package:citesched_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'faculty_details_screen.dart';
import 'package:citesched_flutter/core/providers/conflict_provider.dart';
import 'package:citesched_flutter/core/utils/responsive_helper.dart';

// Provider for faculty list
final facultyListProvider = FutureProvider<List<Faculty>>((ref) async {
  return await client.admin.getAllFaculty();
});

// Helper extension for conflicts (already in core/providers/conflict_provider.dart)

class FacultyManagementScreen extends ConsumerStatefulWidget {
  const FacultyManagementScreen({super.key});

  @override
  ConsumerState<FacultyManagementScreen> createState() =>
      _FacultyManagementScreenState();
}

class _FacultyManagementScreenState
    extends ConsumerState<FacultyManagementScreen> {
  String _searchQuery = '';
  String? _selectedProgram;
  final TextEditingController _searchController = TextEditingController();

  // Color scheme matching admin sidebar
  final Color maroonColor = const Color(0xFF720045);
  final Color innerMenuBg = const Color(0xFF7b004f);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddFacultyModal() {
    debugPrint('Opening Add Faculty Modal...');
    showDialog(
      context: context,
      builder: (context) => _AddFacultyModal(
        maroonColor: maroonColor,
        onSuccess: () {
          debugPrint('Add Faculty Success!');
          ref.refresh(facultyListProvider);
        },
      ),
    );
  }

  void _showEditFacultyModal(Faculty faculty) {
    debugPrint('Opening Edit Faculty Modal for: ${faculty.name}');
    showDialog(
      context: context,
      builder: (context) => _EditFacultyModal(
        faculty: faculty,
        maroonColor: maroonColor,
        onSuccess: () {
          debugPrint('Edit Faculty Success!');
          ref.refresh(facultyListProvider);
        },
      ),
    );
  }

  void _deleteFaculty(Faculty faculty) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Faculty',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete ${faculty.name}? This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
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
      ),
    );

    if (confirm == true && mounted) {
      try {
        await client.admin.deleteFaculty(faculty.id!);
        ref.refresh(facultyListProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Faculty deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting faculty: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final facultyAsync = ref.watch(facultyListProvider);
    final conflictsAsync = ref.watch(allConflictsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA);

    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Faculty Management',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage faculty members and their information',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _showAddFacultyModal,
                          icon: const Icon(Icons.add_rounded),
                          label: Text(
                            'Add Faculty',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: maroonColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Faculty Management',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage faculty members and their information',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _showAddFacultyModal,
                        icon: const Icon(Icons.add_rounded),
                        label: Text(
                          'Add Faculty',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: maroonColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 32),

            // Search and Filter Row
            isMobile
                ? Column(
                    children: [
                      _buildSearchBar(isDark),
                      const SizedBox(height: 16),
                      _buildProgramFilter(facultyAsync, isDark),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildSearchBar(isDark),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildProgramFilter(facultyAsync, isDark),
                      ),
                    ],
                  ),
            const SizedBox(height: 32),
            const SizedBox(height: 24),

            // Faculty Table
            Expanded(
              child: facultyAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading faculty',
                        style: GoogleFonts.poppins(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(facultyListProvider),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (facultyList) {
                  final filteredFaculty = facultyList.where((faculty) {
                    // Search filter
                    final matchesSearch =
                        _searchQuery.isEmpty ||
                        faculty.name.toLowerCase().contains(_searchQuery) ||
                        faculty.email.toLowerCase().contains(_searchQuery) ||
                        (faculty.facultyId.toLowerCase().contains(
                          _searchQuery,
                        ));

                    // Program filter
                    final matchesProgram =
                        _selectedProgram == null ||
                        faculty.program.name.toUpperCase() == _selectedProgram;

                    return matchesSearch && matchesProgram;
                  }).toList();

                  if (filteredFaculty.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No faculty members yet'
                                : 'No faculty found',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (_searchQuery.isEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Click "Add Faculty" to get started',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  if (isMobile) {
                    return _buildMobileFacultyList(filteredFaculty, isDark);
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border(
                        left: BorderSide(color: maroonColor, width: 4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Table Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: maroonColor.withOpacity(0.05),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.people_rounded,
                                color: maroonColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Faculty Members',
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
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${filteredFaculty.length} Total',
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

                        // Table Content
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
                                      headingRowColor: WidgetStateProperty.all(
                                        maroonColor,
                                      ),
                                      headingTextStyle: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        letterSpacing: 0.5,
                                      ),
                                      dataRowMinHeight: 65,
                                      dataRowMaxHeight: 85,
                                      columnSpacing: 32,
                                      horizontalMargin: 24,
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                      columns: const [
                                        DataColumn(label: Text('FACULTY ID')),
                                        DataColumn(label: Text('NAME')),
                                        DataColumn(label: Text('EMAIL')),
                                        DataColumn(label: Text('PROGRAM')),
                                        DataColumn(label: Text('STATUS')),
                                        DataColumn(label: Text('CONFLICTS')),
                                        DataColumn(label: Text('SHIFT')),
                                        DataColumn(label: Text('MAX LOAD')),
                                        DataColumn(label: Text('ACTIONS')),
                                      ],
                                      rows: filteredFaculty.asMap().entries.map((
                                        entry,
                                      ) {
                                        final faculty = entry.value;
                                        final index = entry.key;

                                        return DataRow(
                                          onSelectChanged: (selected) {
                                            if (selected == true) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      FacultyDetailsScreen(
                                                        faculty: faculty,
                                                      ),
                                                ),
                                              );
                                            }
                                          },
                                          color:
                                              WidgetStateProperty.resolveWith<
                                                Color?
                                              >(
                                                (states) {
                                                  if (states.contains(
                                                    WidgetState.hovered,
                                                  )) {
                                                    return maroonColor
                                                        .withOpacity(
                                                          0.05,
                                                        );
                                                  }
                                                  return index.isEven
                                                      ? (isDark
                                                            ? Colors.white
                                                                  .withOpacity(
                                                                    0.02,
                                                                  )
                                                            : Colors.grey
                                                                  .withOpacity(
                                                                    0.02,
                                                                  ))
                                                      : null;
                                                },
                                              ),
                                          cells: [
                                            DataCell(
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: maroonColor
                                                      .withOpacity(0.08),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        8,
                                                      ),
                                                ),
                                                child: Text(
                                                  faculty.facultyId,
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                    color: maroonColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      color: maroonColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        faculty.name.isNotEmpty
                                                            ? faculty.name[0]
                                                                  .toUpperCase()
                                                            : '?',
                                                        style:
                                                            GoogleFonts.poppins(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    faculty.name,
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            DataCell(
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.email_outlined,
                                                    size: 16,
                                                    color: Colors.grey[600],
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    faculty.email,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                faculty.program.name
                                                    .toUpperCase(),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 7,
                                                    ),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      _getStatusColor(
                                                        faculty
                                                            .employmentStatus,
                                                      ),
                                                      _getStatusColor(
                                                        faculty
                                                            .employmentStatus,
                                                      ).withOpacity(0.7),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        20,
                                                      ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: _getStatusColor(
                                                        faculty
                                                            .employmentStatus,
                                                      ).withOpacity(0.3),
                                                      blurRadius: 8,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      _getStatusIcon(
                                                        faculty
                                                            .employmentStatus,
                                                      ),
                                                      size: 14,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      _getStatusText(
                                                        faculty
                                                            .employmentStatus,
                                                      ),
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.white,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              conflictsAsync.when(
                                                loading: () => const SizedBox(),
                                                error: (_, __) =>
                                                    const SizedBox(),
                                                data: (conflicts) {
                                                  final hasConflict = conflicts
                                                      .hasConflictForFaculty(
                                                        faculty.id!,
                                                      );
                                                  return Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: hasConflict
                                                          ? Colors.red
                                                                .withOpacity(
                                                                  0.1,
                                                                )
                                                          : Colors.green
                                                                .withOpacity(
                                                                  0.1,
                                                                ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                      border: Border.all(
                                                        color: hasConflict
                                                            ? Colors.red
                                                                  .withOpacity(
                                                                    0.3,
                                                                  )
                                                            : Colors.green
                                                                  .withOpacity(
                                                                    0.3,
                                                                  ),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      hasConflict
                                                          ? 'CONFLICT'
                                                          : 'CLEAR',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: hasConflict
                                                                ? Colors.red
                                                                : Colors.green,
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: _getShiftColor(
                                                    faculty.shiftPreference,
                                                  ).withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        16,
                                                      ),
                                                  border: Border.all(
                                                    color: _getShiftColor(
                                                      faculty.shiftPreference,
                                                    ).withOpacity(0.3),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      _getShiftIcon(
                                                        faculty.shiftPreference,
                                                      ),
                                                      size: 14,
                                                      color: _getShiftColor(
                                                        faculty.shiftPreference,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      _getShiftText(
                                                        faculty.shiftPreference,
                                                      ),
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: _getShiftColor(
                                                          faculty
                                                              .shiftPreference,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.schedule,
                                                    size: 16,
                                                    color: Colors.grey[600],
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    '${faculty.maxLoad} hrs',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      onTap: () =>
                                                          _showEditFacultyModal(
                                                            faculty,
                                                          ),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: maroonColor
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        child: Icon(
                                                          Icons.edit_outlined,
                                                          color: maroonColor,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      onTap: () =>
                                                          _deleteFaculty(
                                                            faculty,
                                                          ),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.red
                                                              .withOpacity(
                                                                0.1,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        child: const Icon(
                                                          Icons.delete_outline,
                                                          color: Colors.red,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(EmploymentStatus status) {
    switch (status) {
      case EmploymentStatus.fullTime:
        return Colors.green;
      case EmploymentStatus.partTime:
        return Colors.orange;
    }
  }

  String _getStatusText(EmploymentStatus status) {
    switch (status) {
      case EmploymentStatus.fullTime:
        return 'Full-Time';
      case EmploymentStatus.partTime:
        return 'Part-Time';
    }
  }

  IconData _getStatusIcon(EmploymentStatus status) {
    switch (status) {
      case EmploymentStatus.fullTime:
        return Icons.verified;
      case EmploymentStatus.partTime:
        return Icons.schedule;
    }
  }

  Color _getShiftColor(FacultyShiftPreference? preference) {
    if (preference == null) return Colors.grey;
    switch (preference) {
      case FacultyShiftPreference.morning:
        return Colors.orange;
      case FacultyShiftPreference.afternoon:
        return Colors.blue;
      case FacultyShiftPreference.evening:
        return Colors.indigo;
      case FacultyShiftPreference.any:
        return Colors.teal;
      case FacultyShiftPreference.custom:
        return Colors.purple;
    }
  }

  String _getShiftText(FacultyShiftPreference? preference) {
    if (preference == null) return 'Any';
    switch (preference) {
      case FacultyShiftPreference.morning:
        return 'Morning';
      case FacultyShiftPreference.afternoon:
        return 'Afternoon';
      case FacultyShiftPreference.evening:
        return 'Evening';
      case FacultyShiftPreference.any:
        return 'Any';
      case FacultyShiftPreference.custom:
        return 'Custom';
    }
  }

  IconData _getShiftIcon(FacultyShiftPreference? preference) {
    if (preference == null) return Icons.access_time;
    switch (preference) {
      case FacultyShiftPreference.morning:
        return Icons.wb_sunny;
      case FacultyShiftPreference.afternoon:
        return Icons.wb_cloudy;
      case FacultyShiftPreference.evening:
        return Icons.nightlight_round;
      case FacultyShiftPreference.any:
        return Icons.all_inclusive;
      case FacultyShiftPreference.custom:
        return Icons.tune;
    }
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(30, 41, 59, 1).withOpacity(0.03),
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
                hintText: 'Search faculty...',
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

  Widget _buildProgramFilter(
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
          final programs =
              facultyList
                  .map((f) => f.program.name.toUpperCase())
                  .toSet()
                  .toList()
                ..sort();

          return DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedProgram,
              hint: Row(
                children: [
                  Icon(Icons.filter_list_rounded, color: maroonColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Filter by Program',
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
                    'All Programs',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ),
                ...programs.map((prog) {
                  return DropdownMenuItem<String>(
                    value: prog,
                    child: Text(
                      prog,
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedProgram = value;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileFacultyList(List<Faculty> facultyList, bool isDark) {
    return ListView.builder(
      itemCount: facultyList.length,
      itemBuilder: (context, index) {
        final faculty = facultyList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: maroonColor.withOpacity(0.1),
              child: Text(
                faculty.name[0],
                style: GoogleFonts.poppins(
                  color: maroonColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              faculty.name,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              faculty.program.name.toUpperCase(),
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow(Icons.email, 'Email', faculty.email),
                    _buildDetailRow(
                      Icons.badge,
                      'ID',
                      faculty.facultyId,
                    ),
                    _buildDetailRow(
                      Icons.verified,
                      'Status',
                      _getStatusText(faculty.employmentStatus),
                      color: _getStatusColor(faculty.employmentStatus),
                    ),
                    _buildDetailRow(
                      Icons.schedule,
                      'Shift',
                      _getShiftText(faculty.shiftPreference),
                      color: _getShiftColor(faculty.shiftPreference),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => _showEditFacultyModal(faculty),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit'),
                        ),
                        TextButton.icon(
                          onPressed: () => _deleteFaculty(faculty),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          label: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
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

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
          ),
          const Spacer(),
          Text(
            value,
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
}

// Add Faculty Modal
class _AddFacultyModal extends StatefulWidget {
  final Color maroonColor;
  final VoidCallback onSuccess;

  const _AddFacultyModal({
    required this.maroonColor,
    required this.onSuccess,
  });

  @override
  State<_AddFacultyModal> createState() => _AddFacultyModalState();
}

class _AddFacultyModalState extends State<_AddFacultyModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _facultyIdController = TextEditingController();
  final _maxLoadController = TextEditingController(text: '21');
  final _preferredHoursController = TextEditingController();

  EmploymentStatus _employmentStatus = EmploymentStatus.fullTime;
  FacultyShiftPreference _shiftPreference = FacultyShiftPreference.morning;
  Program _program = Program.it;
  bool _isActive = true;
  bool _isLoading = false;
  String? _customPreferredHours;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _facultyIdController.dispose();
    _maxLoadController.dispose();
    _preferredHoursController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    debugPrint('Submitting Add Faculty form...');
    if (!_formKey.currentState!.validate()) {
      debugPrint('Add Faculty validation failed');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final faculty = Faculty(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        facultyId: _facultyIdController.text.trim(),
        maxLoad: int.parse(_maxLoadController.text),
        employmentStatus: _employmentStatus,
        shiftPreference: _shiftPreference,
        preferredHours: _customPreferredHours,
        userInfoId: 0, // Placeholder, will be set by backend
        program: _program,
        isActive: _isActive,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await client.admin.createFaculty(faculty);

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Faculty added successfully'),
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

  Future<void> _showCustomHoursPicker() async {
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
      helpText: 'Select Start Time',
    );

    if (startTime == null || !mounted) return;

    final TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: startTime.hour + 2,
        minute: startTime.minute,
      ),
      helpText: 'Select End Time',
    );

    if (endTime == null || !mounted) return;

    // Basic validation
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    if (endMinutes <= startMinutes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be later than start time'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _customPreferredHours =
          '${startTime.format(context)} - ${endTime.format(context)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building _AddFacultyModal...');
    final isMobile = ResponsiveHelper.isMobile(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: isMobile ? double.infinity : 900,
        constraints: BoxConstraints(
          maxHeight: isMobile ? MediaQuery.of(context).size.height * 0.9 : 700,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.maroonColor,
                    widget.maroonColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.maroonColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (!isMobile) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Faculty',
                          style: GoogleFonts.poppins(
                            fontSize: isMobile ? 18 : 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (!isMobile)
                          Text(
                            'Fill in the details to create a new faculty profile',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),

            // Main Body
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 0),
                  child: Flex(
                    direction: isMobile ? Axis.vertical : Axis.horizontal,
                    crossAxisAlignment: isMobile
                        ? CrossAxisAlignment.stretch
                        : CrossAxisAlignment.start,
                    children: [
                      // Context/Info (Hidden or simplified on mobile)
                      if (!isMobile)
                        SizedBox(
                          width: 300, // Fixed width for desktop sidebar
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              border: Border(
                                right: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoSection(
                                  icon: Icons.info_outline,
                                  title: 'Faculty Information',
                                  description:
                                      'Enter basic information about the faculty member including their name, email, and faculty ID.',
                                ),
                                const SizedBox(height: 24),
                                _buildInfoSection(
                                  icon: Icons.work_outline,
                                  title: 'Employment Details',
                                  description:
                                      'Specify the employment status (Full-Time or Part-Time) and program assignment.',
                                ),
                                const SizedBox(height: 24),
                                _buildInfoSection(
                                  icon: Icons.schedule,
                                  title: 'Schedule Preferences',
                                  description:
                                      'Set the maximum teaching load (in hours) and preferred shift times for scheduling.',
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Input Form
                      if (isMobile)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildForm(context),
                        )
                      else
                        Expanded(child: _buildForm(context)),
                    ],
                  ),
                ),
              ),
            ),

            // -------------------------
            // 3. Footer Actions
            // -------------------------
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submit,
                    icon: _isLoading
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
                        : const Icon(Icons.add_rounded, size: 20),
                    label: Text(
                      'Add Faculty Member',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.maroonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
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

  // -------------------------
  // Helper Widgets
  // -------------------------

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.maroonColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: widget.maroonColor, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    return Padding(
      padding: EdgeInsets.all(isMobile ? 0 : 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.maroonColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person,
              helperText: 'Complete name of the faculty',
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email,
              helperText: 'Official email address',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                if (!value!.contains('@')) return 'Invalid email';
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _facultyIdController,
              label: 'Faculty ID',
              icon: Icons.badge,
              helperText: 'Unique identifier',
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            Text(
              'Employment & Schedule',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.maroonColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _maxLoadController,
              label: 'Max Load (hours)',
              icon: Icons.access_time,
              helperText: 'Max teaching hours per week',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                if (int.tryParse(value!) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildDropdown<EmploymentStatus>(
              label: 'Employment Status',
              value: _employmentStatus,
              items: EmploymentStatus.values,
              onChanged: (value) => setState(() => _employmentStatus = value!),
              itemLabel: (status) => status == EmploymentStatus.fullTime
                  ? 'Full-Time'
                  : 'Part-Time',
            ),
            const SizedBox(height: 20),
            _buildDropdown<FacultyShiftPreference>(
              label: 'Shift Preference',
              value: _shiftPreference,
              items: FacultyShiftPreference.values,
              onChanged: (value) => setState(() => _shiftPreference = value!),
              itemLabel: (pref) {
                switch (pref) {
                  case FacultyShiftPreference.any:
                    return 'Any Time (Flexible)';
                  case FacultyShiftPreference.morning:
                    return 'Morning (7:00 AM – 12:00 PM)';
                  case FacultyShiftPreference.afternoon:
                    return 'Afternoon (1:00 PM – 6:00 PM)';
                  case FacultyShiftPreference.evening:
                    return 'Evening (6:00 PM – 9:00 PM)';
                  case FacultyShiftPreference.custom:
                    return 'Custom';
                }
              },
            ),
            const SizedBox(height: 20),
            Text(
              'TIME PREFERENCES',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _showCustomHoursPicker,
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: Text(
                _customPreferredHours == null
                    ? 'Add Custom Hours'
                    : 'Change Custom Hours',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: BorderSide(color: widget.maroonColor, width: 2),
                foregroundColor: widget.maroonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (_customPreferredHours != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border(
                    left: BorderSide(color: Colors.green[400]!, width: 4),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Custom Hours Applied',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          Text(
                            _customPreferredHours!,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () =>
                          setState(() => _customPreferredHours = null),
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            _buildDropdown<Program>(
              label: 'Program',
              value: _program,
              items: Program.values,
              onChanged: (value) => setState(() => _program = value!),
              itemLabel: (prog) => prog.name.toUpperCase(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Is Active',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                  activeColor: widget.maroonColor,
                ),
              ],
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
    required String helperText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,

        // Label is grey when inactive
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
        helperStyle: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 12),
        hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),

        // FIXED: Label stays grey even when focused/floating
        floatingLabelStyle: GoogleFonts.poppins(
          color: Colors.grey[600], // Changed from maroon to grey
          fontWeight: FontWeight.w600,
        ),

        prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: widget.maroonColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[300]!),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemLabel,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemLabel(item),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),

        // FIXED: Label stays grey even when focused/floating
        floatingLabelStyle: GoogleFonts.poppins(
          color: Colors.grey[600], // Changed from maroon to grey
          fontWeight: FontWeight.w600,
        ),

        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: widget.maroonColor, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

// Edit Faculty Modal (similar to Add but with pre-filled data)
class _EditFacultyModal extends StatefulWidget {
  final Faculty faculty;
  final Color maroonColor;
  final VoidCallback onSuccess;

  const _EditFacultyModal({
    required this.faculty,
    required this.maroonColor,
    required this.onSuccess,
  });

  @override
  State<_EditFacultyModal> createState() => _EditFacultyModalState();
}

class _EditFacultyModalState extends State<_EditFacultyModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _facultyIdController;
  late TextEditingController _maxLoadController;
  late TextEditingController _preferredHoursController;

  late EmploymentStatus _employmentStatus;
  late FacultyShiftPreference _shiftPreference;
  late Program _program;
  late bool _isActive;
  bool _isLoading = false;
  String? _customPreferredHours;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.faculty.name);
    _emailController = TextEditingController(text: widget.faculty.email);
    _facultyIdController = TextEditingController(
      text: widget.faculty.facultyId,
    );
    _maxLoadController = TextEditingController(
      text: widget.faculty.maxLoad.toString(),
    );
    _preferredHoursController = TextEditingController(
      text: widget.faculty.preferredHours ?? '',
    );
    _employmentStatus = widget.faculty.employmentStatus;
    _shiftPreference =
        widget.faculty.shiftPreference ?? FacultyShiftPreference.any;
    _program = widget.faculty.program;
    _isActive = widget.faculty.isActive;
    _customPreferredHours = widget.faculty.preferredHours;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _facultyIdController.dispose();
    _maxLoadController.dispose();
    _preferredHoursController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    debugPrint('Submitting Edit Faculty form...');
    if (!_formKey.currentState!.validate()) {
      debugPrint('Edit Faculty validation failed');
      return;
    }
    setState(() => _isLoading = true);

    try {
      final updatedFaculty = Faculty(
        id: widget.faculty.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        facultyId: _facultyIdController.text.trim(),
        maxLoad: int.parse(_maxLoadController.text),
        employmentStatus: _employmentStatus,
        shiftPreference: _shiftPreference,
        preferredHours: _customPreferredHours,
        userInfoId: widget.faculty.userInfoId,
        program: _program,
        isActive: _isActive,
        createdAt: widget.faculty.createdAt,
        updatedAt: DateTime.now(),
      );

      await client.admin.updateFaculty(updatedFaculty);

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Faculty updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showCustomHoursPicker() async {
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
      helpText: 'Select Start Time',
    );

    if (startTime == null || !mounted) return;

    final TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: startTime.hour + 2,
        minute: startTime.minute,
      ),
      helpText: 'Select End Time',
    );

    if (endTime == null || !mounted) return;

    // Basic validation
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    if (endMinutes <= startMinutes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be later than start time'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _customPreferredHours =
          '${startTime.format(context)} - ${endTime.format(context)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building _EditFacultyModal...');
    final isMobile = ResponsiveHelper.isMobile(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: isMobile ? double.infinity : 1000,
        constraints: BoxConstraints(
          maxHeight: isMobile ? MediaQuery.of(context).size.height * 0.9 : 800,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.maroonColor,
                    widget.maroonColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  if (!isMobile) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Faculty',
                          style: GoogleFonts.poppins(
                            fontSize: isMobile ? 18 : 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (!isMobile)
                          Text(
                            'Update faculty information and preferences',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),

            // Form Content Area
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 0),
                  child: Flex(
                    direction: isMobile ? Axis.vertical : Axis.horizontal,
                    crossAxisAlignment: isMobile
                        ? CrossAxisAlignment.stretch
                        : CrossAxisAlignment.start,
                    children: [
                      // Left Side: Instructions (Hidden on mobile)
                      if (!isMobile)
                        SizedBox(
                          width: 300,
                          child: Container(
                            width: 300,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              border: Border(
                                right: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildInfoSection(
                                  Icons.info_outline,
                                  'Faculty Information',
                                  'Update basic identification details.',
                                ),
                                const SizedBox(height: 24),
                                _buildInfoSection(
                                  Icons.work_outline,
                                  'Employment Details',
                                  'Modify status and program.',
                                ),
                                const SizedBox(height: 24),
                                _buildInfoSection(
                                  Icons.schedule,
                                  'Schedule Preferences',
                                  'Adjust load and shift times.',
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Right Side: Form
                      if (isMobile)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildForm(context),
                        )
                      else
                        Expanded(child: _buildForm(context)),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submit,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_rounded),
                    label: const Text('Save Changes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.maroonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
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

  Widget _buildInfoSection(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.maroonColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: widget.maroonColor, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
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
  }

  Widget _buildForm(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    return Padding(
      padding: EdgeInsets.all(isMobile ? 0 : 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.maroonColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person,
              helperText: 'Enter complete name',
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email,
              helperText: 'Official email address',
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  (v != null && !v.contains('@')) ? 'Invalid email' : null,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _facultyIdController,
              label: 'Faculty ID',
              icon: Icons.badge,
              helperText: 'Unique identifier',
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 32),
            Text(
              'Employment & Schedule',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.maroonColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _maxLoadController,
              label: 'Maximum Load (hours)',
              icon: Icons.access_time,
              helperText: 'Maximum teaching hours per week',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _buildDropdown<EmploymentStatus>(
              label: 'Employment Status',
              value: _employmentStatus,
              items: EmploymentStatus.values,
              onChanged: (val) => setState(() => _employmentStatus = val!),
              itemLabel: (s) =>
                  s == EmploymentStatus.fullTime ? 'Full-Time' : 'Part-Time',
            ),
            const SizedBox(height: 20),
            _buildDropdown<FacultyShiftPreference>(
              label: 'Shift Preference',
              value: _shiftPreference,
              items: FacultyShiftPreference.values,
              onChanged: (val) => setState(() => _shiftPreference = val!),
              itemLabel: (pref) {
                switch (pref) {
                  case FacultyShiftPreference.any:
                    return 'Any Time (Flexible)';
                  case FacultyShiftPreference.morning:
                    return 'Morning (7:00 AM – 12:00 PM)';
                  case FacultyShiftPreference.afternoon:
                    return 'Afternoon (1:00 PM – 6:00 PM)';
                  case FacultyShiftPreference.evening:
                    return 'Evening (6:00 PM – 9:00 PM)';
                  case FacultyShiftPreference.custom:
                    return 'Custom';
                }
              },
            ),
            const SizedBox(height: 20),
            Text(
              'TIME PREFERENCES',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _showCustomHoursPicker,
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: Text(
                _customPreferredHours == null
                    ? 'Add Custom Hours'
                    : 'Change Custom Hours',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: BorderSide(color: widget.maroonColor, width: 2),
                foregroundColor: widget.maroonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (_customPreferredHours != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border(
                    left: BorderSide(color: Colors.green[400]!, width: 4),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Custom Hours Applied',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          Text(
                            _customPreferredHours!,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () =>
                          setState(() => _customPreferredHours = null),
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            _buildDropdown<Program>(
              label: 'Program',
              value: _program,
              items: Program.values,
              onChanged: (value) => setState(() => _program = value!),
              itemLabel: (prog) => prog.name.toUpperCase(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Is Active',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                  activeColor: widget.maroonColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // YOUR CUSTOM STYLED TEXTFIELD
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String helperText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator ?? (v) => v?.isEmpty ?? true ? 'Required' : null,
      style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
        helperStyle: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 12),
        floatingLabelStyle: GoogleFonts.poppins(
          color: Colors.grey[600],
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: widget.maroonColor, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  // YOUR CUSTOM STYLED DROPDOWN
  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemLabel,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemLabel(item),
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
        floatingLabelStyle: GoogleFonts.poppins(
          color: Colors.grey[600],
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: widget.maroonColor, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
