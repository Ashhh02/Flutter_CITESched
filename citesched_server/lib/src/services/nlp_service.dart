import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'conflict_service.dart';

class NLPService {
  final ConflictService _conflictService = ConflictService();

  Future<NLPResponse> processQuery(
    Session session,
    String query,
    String? userId,
    List<String> scopes,
  ) async {
    final lowerQuery = query.toLowerCase();
    final isAdmin = scopes.contains('admin');

    // 1. Conflict Queries (Admin Only)
    if (lowerQuery.contains('conflict') || lowerQuery.contains('issue')) {
      if (!isAdmin) {
        return NLPResponse(
          text:
              "I'm sorry, access to conflict details is restricted to administrators.",
          intent: NLPIntent.unknown,
        );
      }
      return await _handleConflictQuery(session);
    }

    // 2. Faculty Load Queries (Admin Only)
    if (lowerQuery.contains('load') ||
        lowerQuery.contains('units') ||
        lowerQuery.contains('teaching hours')) {
      if (!isAdmin) {
        return NLPResponse(
          text:
              "Detailed faculty load information is only available to administrators.",
          intent: NLPIntent.unknown,
        );
      }
      return await _handleLoadQuery(session, lowerQuery);
    }

    // 3. Room Status/Availability Queries
    if (lowerQuery.contains('room') ||
        lowerQuery.contains('lab') ||
        lowerQuery.contains('lecture hall') ||
        lowerQuery.contains('available') ||
        lowerQuery.contains('free')) {
      return await _handleRoomQuery(session, lowerQuery);
    }

    // 4. Section/Schedule Queries
    if (lowerQuery.contains('schedule') ||
        lowerQuery.contains('timetable') ||
        lowerQuery.contains('class') ||
        _containsSectionPattern(lowerQuery)) {
      return await _handleScheduleQuery(session, lowerQuery);
    }

    return NLPResponse(
      text:
          "I'm your CITESched Assistant. You can ask me about 'room availability' or 'class schedules'. Administrators can also query 'conflicts' and 'faculty load'.",
      intent: NLPIntent.unknown,
    );
  }

  bool _containsSectionPattern(String query) {
    // Regex for common section patterns (e.g., IT 1A, IT-2B, 3-C, etc.)
    final sectionRegex = RegExp(r'\b([a-zA-Z]{1,4})?\s?\d[a-zA-Z]\b');
    return sectionRegex.hasMatch(query);
  }

  Future<NLPResponse> _handleConflictQuery(Session session) async {
    final conflicts = await _conflictService.getAllConflicts(session);
    if (conflicts.isEmpty) {
      return NLPResponse(
        text:
            "Great news! There are currently no conflicts detected in the system.",
        intent: NLPIntent.conflict,
      );
    }

    // Group by type for better summary
    final roomConflicts = conflicts
        .where((c) => c.type.toLowerCase().contains('room'))
        .length;
    final facultyConflicts = conflicts
        .where((c) => c.type.toLowerCase().contains('faculty'))
        .length;

    var summary = "I found ${conflicts.length} conflict(s): ";
    if (roomConflicts > 0) summary += "$roomConflicts room double-booking(s). ";
    if (facultyConflicts > 0)
      summary += "$facultyConflicts faculty overlap(s). ";

    return NLPResponse(
      text:
          "$summary You can view details in the Conflict Module or use the Timetable to resolve them.",
      intent: NLPIntent.conflict,
      dataJson:
          '{"count": ${conflicts.length}, "room": $roomConflicts, "faculty": $facultyConflicts}',
    );
  }

  Future<NLPResponse> _handleLoadQuery(Session session, String query) async {
    final facultyList = await Faculty.db.find(session);
    Faculty? foundFaculty;

    // Entity extraction: find faculty by name
    for (var f in facultyList) {
      if (query.contains(f.name.toLowerCase())) {
        foundFaculty = f;
        break;
      }
    }

    if (foundFaculty != null) {
      final schedules = await Schedule.db.find(
        session,
        where: (t) => t.facultyId.equals(foundFaculty!.id!),
        include: Schedule.include(
          subject: Subject.include(),
          timeslot: Timeslot.include(),
        ),
      );

      double totalUnits = 0;
      double totalHours = 0;

      for (var s in schedules) {
        totalUnits += s.units ?? 0;
        if (s.timeslot != null) {
          try {
            var start = DateTime.parse('2000-01-01 ${s.timeslot!.startTime}');
            var end = DateTime.parse('2000-01-01 ${s.timeslot!.endTime}');
            totalHours += end.difference(start).inMinutes / 60.0;
          } catch (_) {
            totalHours += 3.0;
          }
        }
      }

      return NLPResponse(
        text:
            "${foundFaculty.name} is teaching ${schedules.length} classes, totaling ${totalUnits.toStringAsFixed(1)} units and ${totalHours.toStringAsFixed(1)} hours per week. (Limit: ${foundFaculty.maxLoad})",
        intent: NLPIntent.facultyLoad,
        schedules: schedules,
      );
    }

    return NLPResponse(
      text:
          "I can check faculty load. Try asking 'What is the load of Prof. [Name]?'",
      intent: NLPIntent.facultyLoad,
    );
  }

  Future<NLPResponse> _handleRoomQuery(Session session, String query) async {
    final rooms = await Room.db.find(session);
    Room? foundRoom;

    for (var r in rooms) {
      if (query.contains(r.name.toLowerCase())) {
        foundRoom = r;
        break;
      }
    }

    if (foundRoom != null) {
      final schedules = await Schedule.db.find(
        session,
        where: (t) => t.roomId.equals(foundRoom!.id!),
        include: Schedule.include(
          subject: Subject.include(),
          timeslot: Timeslot.include(),
        ),
      );

      return NLPResponse(
        text:
            "Room ${foundRoom.name} (${foundRoom.type.name}) currently has ${schedules.length} assigned sessions. It has a capacity of ${foundRoom.capacity} students.",
        intent: NLPIntent.roomStatus,
        schedules: schedules,
        dataJson: '{"id": ${foundRoom.id}, "capacity": ${foundRoom.capacity}}',
      );
    }

    return NLPResponse(
      text:
          "I can check room status. Try asking 'Is [Room Name] available?' or 'How busy is [Room Name]?'",
      intent: NLPIntent.roomStatus,
    );
  }

  Future<NLPResponse> _handleScheduleQuery(
    Session session,
    String query,
  ) async {
    // Extract section (e.g., IT 3A)
    final sectionMatch = RegExp(
      r'\b([a-zA-Z]{1,4})?\s?(\d[a-zA-Z])\b',
    ).firstMatch(query.toUpperCase());

    if (sectionMatch != null) {
      final section = sectionMatch.group(0)!;
      final schedules = await Schedule.db.find(
        session,
        where: (t) => t.section.equals(section),
        include: Schedule.include(
          subject: Subject.include(),
          faculty: Faculty.include(),
          room: Room.include(),
          timeslot: Timeslot.include(),
        ),
      );

      if (schedules.isEmpty) {
        return NLPResponse(
          text: "I couldn't find any classes scheduled for section $section.",
          intent: NLPIntent.schedule,
        );
      }

      return NLPResponse(
        text: "Found ${schedules.length} classes for section $section.",
        intent: NLPIntent.schedule,
        schedules: schedules,
      );
    }

    return NLPResponse(
      text:
          "I can find schedules for specific sections. Try asking 'Show schedule for IT 3A'.",
      intent: NLPIntent.schedule,
    );
  }
}
