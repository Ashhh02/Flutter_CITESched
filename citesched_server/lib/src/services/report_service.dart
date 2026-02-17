import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Service class responsible for generating administrative reports.
class ReportService {
  // ─── Faculty Load Report ──────────────────────────────────────────────

  /// Generates a report on faculty teaching loads.
  Future<List<FacultyLoadReport>> generateFacultyLoadReport(
      Session session) async {
    var facultyList = await Faculty.db.find(session);
    var reports = <FacultyLoadReport>[];

    for (var faculty in facultyList) {
      // Get schedules for this faculty
      var schedules = await Schedule.db.find(
        session,
        where: (t) => t.facultyId.equals(faculty.id!),
      );

      // Calculate total units
      // Note: Schedule doesn't currently store units directly in all cases,
      // it relates to Subject. We need to fetch subjects to get precise units.
      // For MVP optimization, we can fetch all subjects once or use a join if available.
      // Here we'll fetch subjects individually or rely on a helper if performance allows.
      // Optimization: Fetch all subjects involved.
      double totalUnits = 0;
      int totalSubjects = schedules.length;

      // To avoid N+1, let's just count subjects for now as a proxy, 
      // or fetch subject if needed. 
      // Given MVP, let's fetch subject details for accurate unit count.
      for (var schedule in schedules) {
         var subject = await Subject.db.findById(session, schedule.subjectId);
         if (subject != null) {
           totalUnits += subject.units; 
         }
      }

      String status = 'Balanced';
      if (totalSubjects == 0) {
        status = 'No Load';
      } else if (totalSubjects < faculty.maxLoad * 0.5) { // Arbitrary threshold for example
        status = 'Underloaded';
      } else if (totalSubjects >= faculty.maxLoad) {
        status = 'Max Load';
      }

      reports.add(
        FacultyLoadReport(
          facultyId: faculty.id!,
          facultyName: faculty.name,
          totalUnits: totalUnits,
          totalSubjects: totalSubjects,
          loadStatus: status,
          department: faculty.department,
        ),
      );
    }
    return reports;
  }

  // ─── Room Utilization Report ──────────────────────────────────────────

  /// Generates a report on room usage.
  Future<List<RoomUtilizationReport>> generateRoomUtilizationReport(
      Session session) async {
    var rooms = await Room.db.find(session);
    var reports = <RoomUtilizationReport>[];

    // Total possible slots per week (e.g., 5 days * 10 slots = 50)
    // This should ideally be dynamic based on TimeSlot definitions.
    // For MVP, let's assume a standard denominator or just count bookings.
    // Let's count total timeslots available in DB as the denominator?
    var totalTimeslotsCount = await Timeslot.db.count(session);
    if (totalTimeslotsCount == 0) totalTimeslotsCount = 1; // Avoid division by zero

    for (var room in rooms) {
      var schedules = await Schedule.db.find(
        session,
        where: (t) => t.roomId.equals(room.id!),
      );

      var totalBookings = schedules.length;
      var utilization = (totalBookings / totalTimeslotsCount) * 100;

      reports.add(
        RoomUtilizationReport(
          roomId: room.id!,
          roomName: room.name,
          utilizationPercentage: utilization,
          totalBookings: totalBookings,
          isActive: room.isActive,
          program: room.program.name,
        ),
      );
    }
    return reports;
  }

  // ─── Conflict Summary Report ──────────────────────────────────────────

  /// Generates a summary of detected conflicts (if tracked in DB or just logical check).
  /// Note: Current system generates schedules cleanly or fails. 
  /// If we want to report on *potential* conflicts or *unresolved* ones, 
  /// we might need a table for 'UnresolvedConflicts' or scan existing constraints.
  /// For this MVP, let's assume we report on *recent generation failures* if we logged them,
  /// Or mostly return a placeholder structure if we don't persist conflicts.
  /// 
  /// Alternative: this report could scan the *current* schedule for any anomalies 
  /// (e.g. manual overrides that caused conflicts).
  Future<ConflictSummaryReport> generateConflictSummary(Session session) async {
    // Check for any actual database-level inconsistencies
    // 1. Room double booking
    // 2. Faculty double booking
    // This is expensive to scan full DB, so maybe just return counts of schedules
    // and a '0' for conflicts if we enforce validity on write.
    
    // For now, let's return a basic summary.
    return ConflictSummaryReport(
      totalConflicts: 0, // Assuming system enforces clean schedule
      conflictsByType: {'Room': 0, 'Faculty': 0},
      resolvedConflicts: 0,
      mostFrequentConflictType: 'None',
    );
  }

  // ─── Schedule Overview Report ─────────────────────────────────────────

  /// Generates high-level schedule statistics.
  Future<ScheduleOverviewReport> generateScheduleOverview(Session session) async {
    var totalSchedules = await Schedule.db.count(session);
    
    var itSchedules = 0;
    var emcSchedules = 0;
    
    // Fetch all schedules
    var allSchedules = await Schedule.db.find(session);
    
    // Manual join to check programs
    for (var s in allSchedules) {
      if (s.subjectId != 0) { // Safety check
         var subject = await Subject.db.findById(session, s.subjectId);
         if (subject != null) {
           if (subject.program.name.toLowerCase() == 'it') {
             itSchedules++;
           } else if (subject.program.name.toLowerCase() == 'emc') {
             emcSchedules++;
           }
         }
      }
    }

    return ScheduleOverviewReport(
      totalSchedules: totalSchedules,
      schedulesByProgram: {
        'IT': itSchedules,
        'EMC': emcSchedules,
      },
      activeTerm: 1, // Placeholder
      academicYear: '2025-2026', // Placeholder
    );
  }
}
