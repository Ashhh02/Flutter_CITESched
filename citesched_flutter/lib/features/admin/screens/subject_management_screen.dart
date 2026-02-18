import 'package:citesched_client/citesched_client.dart';
import 'package:citesched_flutter/core/providers/subject_provider.dart';
import 'package:citesched_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'subject_details_screen.dart';
import 'package:citesched_flutter/core/providers/conflict_provider.dart';

// Local provider removed in favor of shared subjectsProvider

class SubjectManagementScreen extends ConsumerStatefulWidget {
  const SubjectManagementScreen({super.key});

  @override
  ConsumerState<SubjectManagementScreen> createState() =>
      _SubjectManagementScreenState();
}

class _SubjectManagementScreenState
    extends ConsumerState<SubjectManagementScreen> {
  String _searchQuery = '';
  int? _selectedYearLevel;
  Program? _selectedProgram;
  final TextEditingController _searchController = TextEditingController();

  final Color maroonColor = const Color(0xFF720045);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddSubjectModal() {
    showDialog(
      context: context,
      builder: (context) => _AddSubjectModal(
        maroonColor: maroonColor,
        onSuccess: () {
          ref.invalidate(subjectsProvider);
        },
      ),
    );
  }

  void _showEditSubjectModal(Subject subject) {
    showDialog(
      context: context,
      builder: (context) => _EditSubjectModal(
        subject: subject,
        maroonColor: maroonColor,
        onSuccess: () {
          ref.invalidate(subjectsProvider);
        },
      ),
    );
  }

  void _deleteSubject(Subject subject) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
        final textPrimary = isDark ? Colors.white : const Color(0xFF333333);
        final textMuted = isDark ? Colors.grey[400] : Colors.grey[600];

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 400,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red[700]!, Colors.red[500]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_forever_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Delete Subject',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Are you sure you want to delete ${subject.name}?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This action cannot be undone.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(color: textMuted),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Delete',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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

    if (confirm == true && mounted) {
      try {
        await client.admin.deleteSubject(subject.id!);
        ref.invalidate(subjectsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subject deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting subject: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectsProvider);
    final conflictsAsync = ref.watch(allConflictsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: bgColor,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subject Management',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage academic subjects, units, and program assignments',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _showAddSubjectModal,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(
                    'Add Subject',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.transparent : Colors.grey[300]!,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(30, 41, 59, 1)
                              .withOpacity(
                                0.03,
                              ),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: maroonColor,
                          size: 22,
                        ),
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
                              hintText: 'Search by code or title...',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
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
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildYearFilter(isDark),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildProgramFilter(isDark),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Table
            Expanded(
              child: subjectsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
                data: (subjects) {
                  final filtered = subjects.where((s) {
                    final matchesSearch =
                        s.code.toLowerCase().contains(_searchQuery) ||
                        s.name.toLowerCase().contains(_searchQuery);
                    final matchesYear =
                        _selectedYearLevel == null ||
                        s.yearLevel == _selectedYearLevel;
                    final matchesProgram =
                        _selectedProgram == null ||
                        s.program == _selectedProgram;
                    return matchesSearch && matchesYear && matchesProgram;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No subjects found'));
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
                                Icons.book_rounded,
                                color: maroonColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Subjects',
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
                                  '${filtered.length} Total',
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
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                      columns: const [
                                        DataColumn(label: Text('CODE')),
                                        DataColumn(label: Text('TITLE')),
                                        DataColumn(label: Text('UNITS')),
                                        DataColumn(label: Text('PROGRAM')),
                                        DataColumn(label: Text('YEAR/TERM')),
                                        DataColumn(label: Text('TYPE')),
                                        DataColumn(label: Text('STUDENTS')),
                                        DataColumn(label: Text('ACTIONS')),
                                      ],
                                      rows: filtered.asMap().entries.map((
                                        entry,
                                      ) {
                                        final subject = entry.value;
                                        final index = entry.key;

                                        return DataRow(
                                          onSelectChanged: (selected) {
                                            if (selected == true) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      SubjectDetailsScreen(
                                                        subject: subject,
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
                                              Row(
                                                children: [
                                                  if (conflictsAsync.maybeWhen(
                                                    data: (conflicts) => conflicts
                                                        .hasConflictForSubject(
                                                          subject.id!,
                                                        ),
                                                    orElse: () => false,
                                                  ))
                                                    const Tooltip(
                                                      message:
                                                          'Subject has a schedule conflict',
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                              right: 8,
                                                            ),
                                                        child: Icon(
                                                          Icons.warning_rounded,
                                                          color: Colors.orange,
                                                          size: 20,
                                                        ),
                                                      ),
                                                    ),
                                                  Text(
                                                    subject.code,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            DataCell(Text(subject.name)),
                                            DataCell(
                                              Text(subject.units.toString()),
                                            ),
                                            DataCell(
                                              Text(
                                                subject.program.name
                                                    .toUpperCase(),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                '${subject.yearLevel ?? "-"} / ${subject.term ?? "-"}',
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                subject.types
                                                    .map(
                                                      (t) =>
                                                          t.name.toUpperCase(),
                                                    )
                                                    .join(' / '),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                subject.studentsCount
                                                    .toString(),
                                              ),
                                            ),
                                            DataCell(
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.edit,
                                                      color: Colors.blue,
                                                    ),
                                                    onPressed: () =>
                                                        _showEditSubjectModal(
                                                          subject,
                                                        ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                    onPressed: () =>
                                                        _deleteSubject(
                                                          subject,
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

  Widget _buildYearFilter(bool isDark) {
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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedYearLevel,
          hint: Row(
            children: [
              Icon(Icons.calendar_today_outlined, color: maroonColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Year Level',
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
            DropdownMenuItem(
              value: null,
              child: Text(
                'All Years',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ),
            ...List.generate(
              4,
              (i) => DropdownMenuItem(
                value: i + 1,
                child: Text(
                  'Year ${i + 1}',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ),
            ),
          ],
          onChanged: (v) => setState(() => _selectedYearLevel = v),
        ),
      ),
    );
  }

  Widget _buildProgramFilter(bool isDark) {
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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Program>(
          value: _selectedProgram,
          hint: Row(
            children: [
              Icon(Icons.school_outlined, color: maroonColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Program',
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
            DropdownMenuItem(
              value: null,
              child: Text(
                'All Programs',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ),
            ...Program.values.map(
              (p) => DropdownMenuItem(
                value: p,
                child: Text(
                  p.name.toUpperCase(),
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ),
            ),
          ],
          onChanged: (v) => setState(() => _selectedProgram = v),
        ),
      ),
    );
  }
}

class _AddSubjectModal extends StatefulWidget {
  final Color maroonColor;
  final VoidCallback onSuccess;

  const _AddSubjectModal({required this.maroonColor, required this.onSuccess});

  @override
  State<_AddSubjectModal> createState() => _AddSubjectModalState();
}

class _AddSubjectModalState extends State<_AddSubjectModal> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _unitsController = TextEditingController(text: '3');
  final _studentsCountController = TextEditingController(text: '40');

  int? _yearLevel;
  int? _term;
  List<SubjectType> _selectedTypes = [];
  Program _program = Program.it;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF333333);
    final textMuted = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.1);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 650,
        constraints: const BoxConstraints(maxHeight: 800),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: widget.maroonColor.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [widget.maroonColor, const Color(0xFFb5179e)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
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
                      Icons.library_add_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add New Subject',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Enter subject details below',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(
                        'Subject Information',
                        Icons.info_outline,
                        textPrimary,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Subject Code',
                              _codeController,
                              isDark,
                              hint: 'e.g., ITEC 101',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              'Units',
                              _unitsController,
                              isDark,
                              isNumber: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Subject Title',
                        _nameController,
                        isDark,
                        hint: 'e.g., Introduction to Computing',
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle(
                        'Classification',
                        Icons.category_outlined,
                        textPrimary,
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<Program>(
                        value: _program,
                        decoration: _inputDecoration('Program', isDark),
                        dropdownColor: cardBg,
                        items: Program.values
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(
                                  p.name.toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    color: textPrimary,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _program = v!),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Subject Types',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.grey[300]
                                        : Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: SubjectType.values.map((type) {
                                    final isSelected = _selectedTypes.contains(
                                      type,
                                    );
                                    return FilterChip(
                                      label: Text(type.name.toUpperCase()),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            _selectedTypes.add(type);
                                          } else {
                                            _selectedTypes.remove(type);
                                          }
                                        });
                                      },
                                      selectedColor: widget.maroonColor
                                          .withOpacity(0.2),
                                      checkmarkColor: widget.maroonColor,
                                      labelStyle: GoogleFonts.poppins(
                                        color: isSelected
                                            ? widget.maroonColor
                                            : textPrimary,
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              'Student Count',
                              _studentsCountController,
                              isDark,
                              isNumber: true,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle(
                        'Schedule Placement',
                        Icons.calendar_month_outlined,
                        textPrimary,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _yearLevel,
                              decoration: _inputDecoration(
                                'Year Level',
                                isDark,
                              ),
                              dropdownColor: cardBg,
                              items: List.generate(
                                4,
                                (i) => DropdownMenuItem(
                                  value: i + 1,
                                  child: Text(
                                    'Year ${i + 1}',
                                    style: GoogleFonts.poppins(
                                      color: textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              onChanged: (v) => setState(() => _yearLevel = v!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _term,
                              decoration: _inputDecoration('Semester', isDark),
                              dropdownColor: cardBg,
                              items: [1, 2]
                                  .map(
                                    (i) => DropdownMenuItem(
                                      value: i,
                                      child: Text(
                                        i == 1
                                            ? '1st Semester'
                                            : '2nd Semester',
                                        style: GoogleFonts.poppins(
                                          color: textPrimary,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() => _term = v!),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(color: textMuted),
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
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 20),
                    label: Text(
                      _isLoading ? 'Saving...' : 'Create Subject',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.maroonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: widget.maroonColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool isDark, {
    bool isNumber = false,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: _inputDecoration(null, isDark, hint: hint),
          validator: (value) =>
              value == null || value.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String? label, bool isDark, {String? hint}) {
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.05);

    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 13),
      labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
      filled: true,
      fillColor: bgColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: widget.maroonColor, width: 2),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final subject = Subject(
        code: _codeController.text,
        name: _nameController.text,
        units: int.parse(_unitsController.text),
        studentsCount: int.parse(_studentsCountController.text),
        yearLevel: _yearLevel,
        term: _term,
        types: _selectedTypes,
        program: _program,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await client.admin.createSubject(subject);
      widget.onSuccess();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _EditSubjectModal extends StatefulWidget {
  final Subject subject;
  final Color maroonColor;
  final VoidCallback onSuccess;

  const _EditSubjectModal({
    required this.subject,
    required this.maroonColor,
    required this.onSuccess,
  });

  @override
  State<_EditSubjectModal> createState() => _EditSubjectModalState();
}

class _EditSubjectModalState extends State<_EditSubjectModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _unitsController;
  late TextEditingController _studentsCountController;

  late int _yearLevel;
  late int _term;
  late List<SubjectType> _selectedTypes;
  late Program _program;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.subject.code);
    _nameController = TextEditingController(text: widget.subject.name);
    _unitsController = TextEditingController(
      text: widget.subject.units.toString(),
    );
    _studentsCountController = TextEditingController(
      text: widget.subject.studentsCount.toString(),
    );
    _yearLevel = widget.subject.yearLevel ?? 1;
    _term = widget.subject.term ?? 1;
    _selectedTypes = List.from(widget.subject.types);
    _program = widget.subject.program;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF333333);
    final textMuted = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.1);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 650,
        constraints: const BoxConstraints(maxHeight: 800),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: widget.maroonColor.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [widget.maroonColor, const Color(0xFFb5179e)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
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
                      Icons.edit_note_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Subject',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Update subject details below',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(
                        'Subject Information',
                        Icons.info_outline,
                        textPrimary,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Subject Code',
                              _codeController,
                              isDark,
                              hint: 'e.g., ITEC 101',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              'Units',
                              _unitsController,
                              isDark,
                              isNumber: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Subject Title',
                        _nameController,
                        isDark,
                        hint: 'e.g., Introduction to Computing',
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle(
                        'Classification',
                        Icons.category_outlined,
                        textPrimary,
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<Program>(
                        value: _program,
                        decoration: _inputDecoration('Program', isDark),
                        dropdownColor: cardBg,
                        items: Program.values
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(
                                  p.name.toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    color: textPrimary,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _program = v!),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'Subject Types',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: SubjectType.values.map((type) {
                          final isSelected = _selectedTypes.contains(type);
                          return FilterChip(
                            label: Text(type.name.toUpperCase()),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedTypes.add(type);
                                } else {
                                  _selectedTypes.remove(type);
                                }
                              });
                            },
                            selectedColor: widget.maroonColor.withOpacity(0.2),
                            checkmarkColor: widget.maroonColor,
                            labelStyle: GoogleFonts.poppins(
                              color: isSelected
                                  ? widget.maroonColor
                                  : textPrimary,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),
                      _buildTextField(
                        'Student Count',
                        _studentsCountController,
                        isDark,
                        isNumber: true,
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle(
                        'Schedule Placement',
                        Icons.calendar_month_outlined,
                        textPrimary,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _yearLevel,
                              decoration: _inputDecoration(
                                'Year Level',
                                isDark,
                              ),
                              dropdownColor: cardBg,
                              items: List.generate(
                                4,
                                (i) => DropdownMenuItem(
                                  value: i + 1,
                                  child: Text(
                                    'Year ${i + 1}',
                                    style: GoogleFonts.poppins(
                                      color: textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              onChanged: (v) => setState(() => _yearLevel = v!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _term,
                              decoration: _inputDecoration('Semester', isDark),
                              dropdownColor: cardBg,
                              items: [1, 2]
                                  .map(
                                    (i) => DropdownMenuItem(
                                      value: i,
                                      child: Text(
                                        i == 1
                                            ? '1st Semester'
                                            : '2nd Semester',
                                        style: GoogleFonts.poppins(
                                          color: textPrimary,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() => _term = v!),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(color: textMuted),
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
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 20),
                    label: Text(
                      _isLoading ? 'Saving...' : 'Save Changes',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.maroonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: widget.maroonColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool isDark, {
    bool isNumber = false,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: _inputDecoration(null, isDark, hint: hint),
          validator: (value) =>
              value == null || value.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String? label, bool isDark, {String? hint}) {
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.05);

    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 13),
      labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
      filled: true,
      fillColor: bgColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: widget.maroonColor, width: 2),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final subject = widget.subject.copyWith(
        code: _codeController.text,
        name: _nameController.text,
        units: int.parse(_unitsController.text),
        studentsCount: int.parse(_studentsCountController.text),
        yearLevel: _yearLevel,
        term: _term,
        types: _selectedTypes,
        program: _program,
        updatedAt: DateTime.now(),
      );
      await client.admin.updateSubject(subject);
      widget.onSuccess();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
