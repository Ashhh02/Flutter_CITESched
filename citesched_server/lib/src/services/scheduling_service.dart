import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'conflict_service.dart';

/// Service class for handling scheduling logic.
/// Uses [ConflictService] to validate schedule entries and generates schedules.
class SchedulingService {
  final ConflictService _conflictService = ConflictService();

  // ─── Schedule Generation ────────────────────────────────────────────

  /// Generate schedules using a greedy algorithm.
  /// Attempts to assign each subject to available timeslots while respecting all constraints.
  Future<GenerateScheduleResponse> generateSchedule(
    Session session,
    GenerateScheduleRequest request,
  ) async {
    var generatedSchedules = <Schedule>[];
    var conflicts = <ScheduleConflict>[];

    // Validate input
    if (request.subjectIds.isEmpty) {
      return GenerateScheduleResponse(
        success: false,
        message: 'No subjects provided for schedule generation',
      );
    }

    if (request.sections.isEmpty) {
      return GenerateScheduleResponse(
        success: false,
        message: 'No sections provided for schedule generation',
      );
    }

    // Fetch all entities
    var subjects = await Future.wait(
      request.subjectIds.map((id) => Subject.db.findById(session, id)),
    );
    var faculties = await Future.wait(
      request.facultyIds.map((id) => Faculty.db.findById(session, id)),
    );
    var rooms = await Future.wait(
      request.roomIds.map((id) => Room.db.findById(session, id)),
    );
    var timeslots = await Future.wait(
      request.timeslotIds.map((id) => Timeslot.db.findById(session, id)),
    );

    // Filter out nulls
    var validSubjects = subjects.whereType<Subject>().toList();
    var validFaculties = faculties.whereType<Faculty>().toList();
    var validRooms = rooms.whereType<Room>().toList();
    var validTimeslots = timeslots.whereType<Timeslot>().toList();

    // Track faculty assignments for load balancing
    var facultyAssignments = <int, int>{};
    for (var faculty in validFaculties) {
      facultyAssignments[faculty.id!] = 0;
    }

    // Greedy algorithm: For each subject and section, try to assign to available slot
    for (var subject in validSubjects) {
      for (var section in request.sections) {
        var assigned = false;

        // Try each faculty
        for (var faculty in validFaculties) {
          if (assigned) break;

          // Check if faculty can take more classes (Basic maxLoad check)
          // Detailed check happens inside ConflictService
          var currentLoad = facultyAssignments[faculty.id!] ?? 0;
          if (currentLoad >= faculty.maxLoad) continue;

          // Try each timeslot
          for (var timeslot in validTimeslots) {
            if (assigned) break;

            // Try each room
            for (var room in validRooms) {
              if (assigned) break;

              // Create candidate schedule
              var candidate = Schedule(
                subjectId: subject.id!,
                facultyId: faculty.id!,
                roomId: room.id!,
                timeslotId: timeslot.id!,
                section: section,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              // Check if this assignment is valid using ConflictService
              var validationConflicts = await _conflictService.validateSchedule(session, candidate);

              if (validationConflicts.isEmpty) {
                // Valid assignment - add to generated schedules
                generatedSchedules.add(candidate);
                facultyAssignments[faculty.id!] =
                    (facultyAssignments[faculty.id!] ?? 0) + 1;
                assigned = true;
              } else {
                // Conflict found, try next combination
                // Optionally log debug info here if needed
                continue;
              }
            }
          }
        }

        // If we couldn't assign this subject-section combination
        if (!assigned) {
          conflicts.add(
            ScheduleConflict(
              type: 'generation_failed',
              message:
                  'Could not find valid assignment for ${subject.name} (${subject.code}) - Section $section',
              details:
                  'No available faculty, room, or timeslot combination found that satisfies all constraints',
            ),
          );
        }
      }
    }

    // Return results
    if (conflicts.isEmpty) {
      return GenerateScheduleResponse(
        success: true,
        schedules: generatedSchedules,
        message:
            'Successfully generated ${generatedSchedules.length} schedule entries',
      );
    } else {
      return GenerateScheduleResponse(
        success: false,
        schedules: generatedSchedules,
        conflicts: conflicts,
        message:
            'Partial generation: ${generatedSchedules.length} schedules generated, ${conflicts.length} failed',
      );
    }
  }
}
