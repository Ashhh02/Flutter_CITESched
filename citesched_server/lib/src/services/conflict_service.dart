import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Service class responsible for validating all scheduling constraints.
/// Ensures the timetable remains conflict-free.
class ConflictService {
  // ─── Conflict Detection Methods ─────────────────────────────────────

  /// Check if a room is available at a given timeslot.
  /// Returns the conflicting schedule if room is already booked, null otherwise.
  Future<Schedule?> checkRoomAvailability(
    Session session, {
    required int? roomId,
    required int? timeslotId,
    int? excludeScheduleId, // For updates, exclude the current schedule
  }) async {
    if (roomId == null || timeslotId == null) {
      return null;
    }

    var query = Schedule.db.find(
      session,
      where: (t) => t.roomId.equals(roomId) & t.timeslotId.equals(timeslotId),
    );

    var conflicts = await query;

    // Filter out the schedule being updated
    if (excludeScheduleId != null) {
      conflicts = conflicts.where((s) => s.id != excludeScheduleId).toList();
    }

    return conflicts.isNotEmpty ? conflicts.first : null;
  }

  /// Check if a faculty member is available at a given timeslot.
  /// Returns the conflicting schedule if faculty is already assigned, null otherwise.
  Future<Schedule?> checkFacultyAvailability(
    Session session, {
    required int facultyId,
    required int? timeslotId,
    int? excludeScheduleId,
  }) async {
    if (timeslotId == null) return null;

    var query = Schedule.db.find(
      session,
      where: (t) =>
          t.facultyId.equals(facultyId) & t.timeslotId.equals(timeslotId),
    );

    var conflicts = await query;

    // Filter out the schedule being updated
    if (excludeScheduleId != null) {
      conflicts = conflicts.where((s) => s.id != excludeScheduleId).toList();
    }

    return conflicts.isNotEmpty ? conflicts.first : null;
  }

  /// Check if a section is available at a given timeslot.
  /// Returns the conflicting schedule if section is already in class, null otherwise.
  Future<Schedule?> checkSectionAvailability(
    Session session, {
    required String section,
    required int? timeslotId,
    int? excludeScheduleId,
  }) async {
    if (timeslotId == null || section.isEmpty) return null;

    var query = Schedule.db.find(
      session,
      where: (t) => t.section.equals(section) & t.timeslotId.equals(timeslotId),
    );

    var conflicts = await query;

    if (excludeScheduleId != null) {
      conflicts = conflicts.where((s) => s.id != excludeScheduleId).toList();
    }

    return conflicts.isNotEmpty ? conflicts.first : null;
  }

  /// Check if a faculty member has exceeded their maximum teaching load.
  /// Returns true if faculty can take more classes, false otherwise.
  Future<bool> checkFacultyMaxLoad(
    Session session, {
    required int facultyId,
    double newUnits = 0,
    int? excludeScheduleId,
  }) async {
    // Get faculty details
    var faculty = await Faculty.db.findById(session, facultyId);
    if (faculty == null) {
      // If faculty not found, we can't enforce load, so assume safe or throw?
      // Let's return true to not block, but log warning.
      session.log(
        'Warning: Faculty not found for ID $facultyId during max load check.',
        level: LogLevel.warning,
      );
      return true;
    }

    // Sum units of current schedules for this faculty
    var schedules = await Schedule.db.find(
      session,
      where: (t) => t.facultyId.equals(facultyId),
    );

    // Filter out the schedule being updated
    if (excludeScheduleId != null) {
      schedules = schedules.where((s) => s.id != excludeScheduleId).toList();
    }

    double currentLoad = 0;
    for (var s in schedules) {
      currentLoad += s.units ?? 0;
    }

    session.log(
      '[DEBUG] checkFacultyMaxLoad: facultyId=$facultyId, currentLoad=$currentLoad, newUnits=$newUnits, maxLoad=${faculty.maxLoad}',
    );

    return (currentLoad + newUnits) <= faculty.maxLoad;
  }

  /// Validate a schedule entry against all conflict rules.
  /// Throws an exception with details if any conflict is found.
  /// Returns a list of conflicts (empty if valid).
  Future<List<ScheduleConflict>> validateSchedule(
    Session session,
    Schedule schedule, {
    int? excludeScheduleId,
  }) async {
    var conflicts = <ScheduleConflict>[];

    // 1. Check Room Availability
    var roomId = schedule.roomId;
    var timeslotId = schedule.timeslotId;

    if (roomId != null && timeslotId != null) {
      var roomConflict = await checkRoomAvailability(
        session,
        roomId: roomId,
        timeslotId: timeslotId,
        excludeScheduleId: excludeScheduleId,
      );

      if (roomConflict != null) {
        conflicts.add(
          ScheduleConflict(
            type: 'room_conflict',
            message: 'Room is already booked for this timeslot',
            conflictingScheduleId: roomConflict.id,
            facultyId: schedule.facultyId,
            roomId: roomId,
            subjectId: schedule.subjectId,
            details:
                'Room ID ${schedule.roomId} is already assigned to schedule ID ${roomConflict.id}',
          ),
        );
      }

      // Fetch Room and Subject for property checks
      var subject = await Subject.db.findById(session, schedule.subjectId);
      var room = await Room.db.findById(session, roomId);

      if (subject != null && room != null) {
        // 2. Program Match Check
        if (subject.program != room.program) {
          conflicts.add(
            ScheduleConflict(
              type: 'program_mismatch',
              message: 'Subject program does not match Room program',
              facultyId: schedule.facultyId,
              roomId: roomId,
              subjectId: schedule.subjectId,
              details:
                  'Subject program is ${subject.program.name}, but Room program is ${room.program.name}',
            ),
          );
        }

        // 3. Capacity Check
        if (room.capacity < subject.studentsCount) {
          conflicts.add(
            ScheduleConflict(
              type: 'capacity_exceeded',
              message: 'Room capacity is smaller than subject student count',
              facultyId: schedule.facultyId,
              roomId: roomId,
              subjectId: schedule.subjectId,
              details:
                  'Room capacity is ${room.capacity}, but Subject has ${subject.studentsCount} students',
            ),
          );
        }

        // 4. Room Active Check
        if (!room.isActive) {
          conflicts.add(
            ScheduleConflict(
              type: 'room_inactive',
              message: 'The selected room is currently inactive',
              facultyId: schedule.facultyId,
              roomId: roomId,
              subjectId: schedule.subjectId,
              details: 'Room ${room.name} must be active for assignment',
            ),
          );
        }
      }
    }

    // 5. Check Faculty Availability
    if (schedule.timeslotId != null) {
      var facultyConflict = await checkFacultyAvailability(
        session,
        facultyId: schedule.facultyId,
        timeslotId: schedule.timeslotId,
        excludeScheduleId: excludeScheduleId,
      );

      if (facultyConflict != null) {
        conflicts.add(
          ScheduleConflict(
            type: 'faculty_conflict',
            message:
                'Faculty is already assigned to another class at this timeslot',
            conflictingScheduleId: facultyConflict.id,
            facultyId: schedule.facultyId,
            roomId: schedule.roomId,
            subjectId: schedule.subjectId,
            details:
                'Faculty ID ${schedule.facultyId} is already assigned to schedule ID ${facultyConflict.id}',
          ),
        );
      }
    }

    // 6. Check Section Availability
    if (schedule.timeslotId != null && schedule.section.isNotEmpty) {
      var sectionConflict = await checkSectionAvailability(
        session,
        section: schedule.section,
        timeslotId: schedule.timeslotId,
        excludeScheduleId: excludeScheduleId,
      );

      if (sectionConflict != null) {
        conflicts.add(
          ScheduleConflict(
            type: 'section_conflict',
            message: 'Section is already in another class at this timeslot',
            conflictingScheduleId: sectionConflict.id,
            facultyId: schedule.facultyId,
            roomId: schedule.roomId,
            subjectId: schedule.subjectId,
            details:
                'Section ${schedule.section} is already assigned to schedule ID ${sectionConflict.id}',
          ),
        );
      }
    }

    // 7. Check Faculty Max Load
    var canTakeMore = await checkFacultyMaxLoad(
      session,
      facultyId: schedule.facultyId,
      newUnits: schedule.units ?? 0,
      excludeScheduleId: excludeScheduleId,
    );

    if (!canTakeMore) {
      var faculty = await Faculty.db.findById(session, schedule.facultyId);
      conflicts.add(
        ScheduleConflict(
          type: 'max_load_exceeded',
          message: 'Faculty has reached maximum teaching load',
          facultyId: schedule.facultyId,
          subjectId: schedule.subjectId,
          details:
              'Faculty ${faculty?.name ?? 'ID ${schedule.facultyId}'} has reached max load of ${faculty?.maxLoad ?? 0} units',
        ),
      );
    }

    return conflicts;
  }

  /// Scans the entire schedule system for conflicts (Room and Faculty overlaps).
  Future<List<ScheduleConflict>> getAllConflicts(Session session) async {
    var allSchedules = await Schedule.db.find(session);
    List<ScheduleConflict> conflicts = [];

    var schedulesByTime = <int, List<Schedule>>{};
    for (var s in allSchedules) {
      var tid = s.timeslotId;
      if (tid != null) {
        schedulesByTime.putIfAbsent(tid, () => []).add(s);
      }
    }

    for (var timeslotId in schedulesByTime.keys) {
      var concurrent = schedulesByTime[timeslotId]!;

      // Check Room Conflicts
      var schedulesByRoom = <int, List<Schedule>>{};
      for (var s in concurrent) {
        var rid = s.roomId;
        if (rid != null) {
          schedulesByRoom.putIfAbsent(rid, () => []).add(s);
        }
      }

      schedulesByRoom.forEach((roomId, roomSchedules) {
        if (roomSchedules.length > 1) {
          conflicts.add(
            ScheduleConflict(
              type: 'Room Conflict',
              message:
                  'Multiple classes in Room $roomId at Timeslot $timeslotId',
              roomId: roomId,
              details:
                  'Schedules: ${roomSchedules.map((s) => s.id).join(', ')}',
            ),
          );
        }
      });

      // Check Faculty Conflicts
      var schedulesByFaculty = <int, List<Schedule>>{};
      for (var s in concurrent) {
        schedulesByFaculty.putIfAbsent(s.facultyId, () => []).add(s);
      }
      schedulesByFaculty.forEach((facultyId, facSchedules) {
        if (facSchedules.length > 1) {
          conflicts.add(
            ScheduleConflict(
              type: 'Faculty Conflict',
              message:
                  'Faculty $facultyId has multiple classes at Timeslot $timeslotId',
              facultyId: facultyId,
              details: 'Schedules: ${facSchedules.map((s) => s.id).join(', ')}',
            ),
          );
        }
      });
    }

    return conflicts;
  }
}
