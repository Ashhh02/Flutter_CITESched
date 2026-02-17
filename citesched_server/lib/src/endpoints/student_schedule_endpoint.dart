import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class StudentScheduleEndpoint extends Endpoint {
  
  /// Fetches the schedule for the logged-in student based on their section.
  Future<List<Schedule>> fetchMySchedule(Session session) async {
    // 1. Authentication Check
    final user = await session.authenticated;
    if (user == null) {
      throw Exception('Unauthorized: You must be logged in.');
    }

    // 2. Role Check (Optional but recommended, though user.id linkage implies it)
    // We assume the frontend handles role-based routing, but robust backend should verify.
    // For now, checks if a Student record exists linked to this user.

    // 3. Fetch Student Profile
    final student = await Student.db.findFirstRow(
      session,
      where: (s) => s.userInfoId.equals(user.userId),
    );

    if (student == null) {
      throw Exception('Student profile not found.');
    }

    if (student.section == null || student.section!.isEmpty) {
      // Return empty list if no section is assigned
      return [];
    }

    // 4. Fetch Schedules for the Student's Section
    // We include related data for the UI (Subject, Faculty, Room, Timeslot)
    final schedules = await Schedule.db.find(
      session,
      where: (s) => s.section.equals(student.section),
      include: Schedule.include(
        subject: Subject.include(),
        faculty: Faculty.include(),
        room: Room.include(),
        timeslot: Timeslot.include(), // Assuming Timeslot relation exists and needed
      ),
      orderBy: (s) => s.timeslotId, // Order by time roughly
    );

    return schedules;
  }
}
