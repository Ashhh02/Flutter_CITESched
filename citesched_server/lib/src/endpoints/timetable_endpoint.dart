import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/timetable_service.dart';
import '../auth/scopes.dart';

class TimetableEndpoint extends Endpoint {
  final TimetableService _timetableService = TimetableService();

  @override
  bool get requireLogin => true;

  Future<List<ScheduleInfo>> getSchedules(
    Session session,
    TimetableFilterRequest filter,
  ) async {
    return await _timetableService.fetchSchedulesWithFilters(session, filter);
  }

  Future<TimetableSummary> getSummary(
    Session session,
    TimetableFilterRequest filter,
  ) async {
    return await _timetableService.fetchSectionSummary(session, filter);
  }

  Future<List<ScheduleInfo>> getPersonalSchedule(Session session) async {
    var authInfo = await session.authenticated;
    if (authInfo == null) {
      throw Exception('Authentication required');
    }

    // Check scopes/roles to determine if Student or Faculty
    var scopes = authInfo.scopes;

    if (scopes.contains(AppScopes.student)) {
      var student = await Student.db.findFirstRow(
        session,
        where: (t) => t.email.equals(authInfo.userIdentifier),
      );
      if (student == null) return [];

      return await _timetableService.fetchSchedulesWithFilters(
        session,
        TimetableFilterRequest(section: student.section),
      );
    } else if (scopes.contains(AppScopes.faculty)) {
      var faculty = await Faculty.db.findFirstRow(
        session,
        where: (t) => t.email.equals(authInfo.userIdentifier),
      );
      if (faculty == null) return [];

      return await _timetableService.fetchSchedulesWithFilters(
        session,
        TimetableFilterRequest(facultyId: faculty.id!),
      );
    }

    return [];
  }
}
