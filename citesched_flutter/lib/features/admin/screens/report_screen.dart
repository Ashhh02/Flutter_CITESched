import 'package:citesched_client/citesched_client.dart';
import 'package:citesched_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final maroonColor = const Color(0xFF720045);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Vibrant Header
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [maroonColor, const Color(0xFFb5179e)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: maroonColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analytical Reports',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Comprehensive system metrics and utilization analysis',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'AY 2025-2026',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Selector
          Container(
            color: cardBg,
            child: TabBar(
              controller: _tabController,
              labelColor: maroonColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: maroonColor,
              indicatorWeight: 4,
              labelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              tabs: const [
                Tab(text: 'Faculty Load'),
                Tab(text: 'Room Usage'),
                Tab(text: 'Conflicts'),
                Tab(text: 'Schedule Stats'),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _FacultyLoadTab(),
                  _RoomUtilizationTab(),
                  _ConflictSummaryTab(),
                  _ScheduleOverviewTab(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FacultyLoadTab extends StatelessWidget {
  const _FacultyLoadTab();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FacultyLoadReport>>(
      future: client.admin.getFacultyLoadReport(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));

        final data = snapshot.data ?? [];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

        return Card(
          color: cardBg,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.badge_outlined, color: const Color(0xFF720045)),
                    const SizedBox(width: 12),
                    Text(
                      'Faculty Teaching Load Analysis',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
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
                              columnSpacing: 32,
                              headingTextStyle: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                              rows: data.map((item) {
                                Color statusColor;
                                if (item.loadStatus == 'Overloaded')
                                  statusColor = Colors.red;
                                else if (item.loadStatus == 'Underloaded')
                                  statusColor = Colors.orange;
                                else
                                  statusColor = Colors.green;

                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        item.facultyName,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(item.program ?? 'N/A')),
                                    DataCell(
                                      Text(
                                        '${item.totalUnits} Units',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: statusColor.withOpacity(0.5),
                                          ),
                                        ),
                                        child: Text(
                                          item.loadStatus.toUpperCase(),
                                          style: GoogleFonts.poppins(
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                              columns: const [
                                DataColumn(label: Text('FACULTY')),
                                DataColumn(label: Text('PROGRAM')),
                                DataColumn(label: Text('TOTAL LOAD')),
                                DataColumn(label: Text('STATUS')),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RoomUtilizationTab extends StatelessWidget {
  const _RoomUtilizationTab();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RoomUtilizationReport>>(
      future: client.admin.getRoomUtilizationReport(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));

        final data = snapshot.data ?? [];
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.4,
          ),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            final color = item.utilizationPercentage > 80
                ? Colors.red
                : (item.utilizationPercentage > 50
                      ? Colors.orange
                      : Colors.green);

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(color: color.withOpacity(0.2), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.roomName,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.meeting_room_rounded, color: color),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Utilization',
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                          Text(
                            '${item.utilizationPercentage.toStringAsFixed(1)}%',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: item.utilizationPercentage / 100,
                          backgroundColor: color.withOpacity(0.1),
                          color: color,
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${item.totalBookings} timeslots assigned',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ConflictSummaryTab extends StatelessWidget {
  const _ConflictSummaryTab();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ConflictSummaryReport>(
      future: client.admin.getConflictSummaryReport(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));

        final data = snapshot.data;
        if (data == null) return const Center(child: Text('No data'));

        return Center(
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: data.totalConflicts == 0
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    data.totalConflicts == 0
                        ? Icons.verified_user_rounded
                        : Icons.warning_rounded,
                    size: 80,
                    color: data.totalConflicts == 0 ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  '${data.totalConflicts} Conflicts Detected',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  data.totalConflicts == 0
                      ? 'Great job! The system is free of scheduling conflicts. All sessions are properly assigned and resource-optimized.'
                      : 'Action required. There are active scheduling conflicts that need to be resolved to ensure system integrity.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                if (data.totalConflicts > 0)
                  ElevatedButton(
                    onPressed: () {}, // Navigate to conflict screen if desired
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF720045),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'VIEW ALL CONFLICTS',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ScheduleOverviewTab extends StatelessWidget {
  const _ScheduleOverviewTab();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ScheduleOverviewReport>(
      future: client.admin.getScheduleOverviewReport(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));

        final data = snapshot.data;
        if (data == null) return const Center(child: Text('No data'));

        return Column(
          children: [
            Row(
              children: [
                _buildStatTile(
                  context,
                  'Total Schedules',
                  data.totalSchedules.toString(),
                  Icons.event_note_rounded,
                  Colors.blue,
                ),
                const SizedBox(width: 24),
                _buildStatTile(
                  context,
                  'Active Programs',
                  data.schedulesByProgram.length.toString(),
                  Icons.account_tree_rounded,
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildProgramBreakdown(
                      context,
                      data.schedulesByProgram,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildTermBreakdown(context, data.schedulesByTerm),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatTile(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramBreakdown(BuildContext context, Map<String, int> data) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Program Distribution',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ...data.entries
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e.key.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${e.value} Classes',
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.7, // Placeholder ratio
                          backgroundColor: Colors.grey.withOpacity(0.1),
                          color: const Color(0xFF720045),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildTermBreakdown(BuildContext context, Map<String, int> data) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enrollment by Term',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ...data.entries
              .map(
                (e) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF720045),
                    child: Icon(Icons.flash_on, color: Colors.white, size: 16),
                  ),
                  title: Text(
                    'Term ${e.key}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    '${e.value} Subjects',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF720045),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
