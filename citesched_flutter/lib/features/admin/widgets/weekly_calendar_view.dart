import 'package:citesched_client/citesched_client.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeeklyCalendarView extends StatelessWidget {
  final List<ScheduleInfo> schedules;
  final Function(Schedule)? onEdit;
  final Color maroonColor;
  final bool isInstructorView;
  final Faculty? selectedFaculty;

  const WeeklyCalendarView({
    super.key,
    required this.schedules,
    required this.maroonColor,
    this.isInstructorView = false,
    this.selectedFaculty,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gridColor = isDark ? Colors.white12 : Colors.black12;

    // Config
    const double hourHeight = 100.0;
    const double dayWidth = 150.0;
    const int startHour = 7;
    const int endHour = 21;
    final List<DayOfWeek> days = [
      DayOfWeek.mon,
      DayOfWeek.tue,
      DayOfWeek.wed,
      DayOfWeek.thu,
      DayOfWeek.fri,
      DayOfWeek.sat,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          width: 80 + (dayWidth * days.length),
          height: hourHeight * (endHour - startHour + 1),
          child: Stack(
            children: [
              // 1. Grid Background & Headers
              _buildGrid(
                context,
                days,
                startHour,
                endHour,
                hourHeight,
                dayWidth,
                gridColor,
              ),

              // 2. Shift Preference Watermarks (Faded vertical labels)
              if (selectedFaculty != null)
                ...days.map(
                  (day) => _buildShiftWatermark(
                    day,
                    days,
                    startHour,
                    hourHeight,
                    dayWidth,
                  ),
                ),

              // 3. Schedule Blocks
              ...schedules.map(
                (info) => _buildScheduleBlock(
                  context,
                  info,
                  days,
                  startHour,
                  hourHeight,
                  dayWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    List<DayOfWeek> days,
    int startHour,
    int endHour,
    double hourHeight,
    double dayWidth,
    Color gridColor,
  ) {
    final prefRange = _getPreferenceRange();

    return Column(
      children: [
        // Day Headers
        Row(
          children: [
            const SizedBox(width: 80),
            ...days.map(
              (day) => Container(
                width: dayWidth,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _isDayHighlighted(day)
                      ? maroonColor.withOpacity(0.1)
                      : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(color: gridColor),
                    left: BorderSide(color: gridColor),
                  ),
                ),
                child: Text(
                  _getDayName(day),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: _isDayHighlighted(day) ? maroonColor : null,
                  ),
                ),
              ),
            ),
          ],
        ),
        // Time Rows
        Expanded(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: endHour - startHour + 1,
            itemBuilder: (context, index) {
              final hour = startHour + index;
              final isPreferredTime =
                  prefRange != null &&
                  hour >= prefRange.start &&
                  hour < prefRange.end;

              return Container(
                height: hourHeight,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: gridColor)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.all(4),
                      decoration: isPreferredTime
                          ? BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                            )
                          : null,
                      child: Column(
                        children: [
                          Text(
                            _formatHour(hour),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          if (isPreferredTime)
                            Text(
                              'PREF',
                              style: GoogleFonts.poppins(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                        ],
                      ),
                    ),
                    ...days.map(
                      (day) => Container(
                        width: dayWidth,
                        decoration: BoxDecoration(
                          color: isPreferredTime
                              ? Colors.green.withOpacity(0.02)
                              : (_isDayHighlighted(day) &&
                                        _isTimeHighlighted(hour)
                                    ? maroonColor.withOpacity(0.03)
                                    : Colors.transparent),
                          border: Border(left: BorderSide(color: gridColor)),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  _PreferenceRange? _getPreferenceRange() {
    if (selectedFaculty == null) return null;

    final shift = selectedFaculty!.shiftPreference;
    if (shift == null) return null;

    switch (shift) {
      case FacultyShiftPreference.morning:
        return _PreferenceRange(7, 12);
      case FacultyShiftPreference.afternoon:
        return _PreferenceRange(13, 18);
      case FacultyShiftPreference.evening:
        return _PreferenceRange(18, 21);
      case FacultyShiftPreference.any:
        return _PreferenceRange(7, 21);
      case FacultyShiftPreference.custom:
        if (selectedFaculty!.preferredHours == null) return null;
        return _parseCustomHours(selectedFaculty!.preferredHours!);
    }
  }

  _PreferenceRange? _parseCustomHours(String hours) {
    try {
      // Expected format: "7:00 AM - 12:00 PM"
      final parts = hours.split('-');
      if (parts.length != 2) return null;

      final startStr = parts[0].trim();
      final endStr = parts[1].trim();

      final startTime = _parseTimeString(startStr);
      final endTime = _parseTimeString(endStr);

      return _PreferenceRange(
        startTime.hour,
        endTime.hour + (endTime.minute > 0 ? 1 : 0),
      );
    } catch (e) {
      debugPrint('Error parsing custom hours: $e');
      return null;
    }
  }

  TimeOfDay _parseTimeString(String timeStr) {
    // Format: "7:00 AM" or "12:00 PM"
    final timeParts = timeStr.split(' ');
    final amPm = timeParts[1].toUpperCase();
    final parts = timeParts[0].split(':');

    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    if (amPm == 'PM' && hour != 12) hour += 12;
    if (amPm == 'AM' && hour == 12) hour = 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

  Widget _buildShiftWatermark(
    DayOfWeek day,
    List<DayOfWeek> days,
    int startHour,
    double hourHeight,
    double dayWidth,
  ) {
    final prefRange = _getPreferenceRange();
    if (prefRange == null) return const SizedBox.shrink();

    final dayIndex = days.indexOf(day);
    final double top = 40 + (prefRange.start - startHour) * hourHeight;
    final double height = (prefRange.end - prefRange.start) * hourHeight;
    final double left = 80 + (dayIndex * dayWidth);

    String label = '';
    switch (selectedFaculty!.shiftPreference) {
      case FacultyShiftPreference.morning:
        label = 'MORNING SHIFT';
        break;
      case FacultyShiftPreference.afternoon:
        label = 'AFTERNOON SHIFT';
        break;
      case FacultyShiftPreference.evening:
        label = 'EVENING SHIFT';
        break;
      case FacultyShiftPreference.any:
        label = 'FLEXIBLE SHIFT';
        break;
      case FacultyShiftPreference.custom:
        label = 'PREFERRED HOURS';
        break;
      case null:
        break;
    }

    return Positioned(
      top: top,
      left: left,
      width: dayWidth,
      height: height,
      child: IgnorePointer(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: RotatedBox(
            quarterTurns: 3,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.green.withOpacity(0.04),
                letterSpacing: 4,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleBlock(
    BuildContext context,
    ScheduleInfo info,
    List<DayOfWeek> days,
    int startHour,
    double hourHeight,
    double dayWidth,
  ) {
    final schedule = info.schedule;
    final timeslot = schedule.timeslot;
    if (timeslot == null) return const SizedBox.shrink();

    final dayIndex = days.indexOf(timeslot.day);
    if (dayIndex == -1) return const SizedBox.shrink();

    final startTime = _parseTime(timeslot.startTime);
    final endTime = _parseTime(timeslot.endTime);

    final double top =
        40 +
        (startTime.hour - startHour + startTime.minute / 60.0) * hourHeight;
    final double height =
        (endTime.hour -
            startTime.hour +
            (endTime.minute - startTime.minute) / 60.0) *
        hourHeight;
    final double left = 80 + (dayIndex * dayWidth);

    final bool hasConflict = info.conflicts.isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use a more professional color scheme for the "Instructor Label" view
    final Color blockColor = selectedFaculty != null
        ? (isDark ? Colors.blueGrey[900]! : Colors.white).withOpacity(0.9)
        : (hasConflict
              ? Colors.red.withOpacity(0.08)
              : maroonColor.withOpacity(0.05));

    final Color borderColor = hasConflict
        ? Colors.red.shade400
        : (selectedFaculty != null
              ? maroonColor
              : maroonColor.withOpacity(0.3));

    return Positioned(
      top: top + 2,
      left: left + 4,
      width: dayWidth - 8,
      height: height - 4,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showScheduleDetails(context, info),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: blockColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor,
                width: selectedFaculty != null || hasConflict ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
                if (hasConflict)
                  BoxShadow(
                    color: Colors.red.withOpacity(0.15),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  selectedFaculty != null
                      ? selectedFaculty!.name.toUpperCase()
                      : (schedule.faculty?.name ?? 'UNASSIGNED'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: maroonColor,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: maroonColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    schedule.subject?.code ?? 'N/A',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: maroonColor,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${timeslot.startTime} – ${timeslot.endTime}',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                if (hasConflict) ...[
                  const Spacer(),
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: Colors.red[700],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showScheduleDetails(BuildContext context, ScheduleInfo info) {
    final schedule = info.schedule;
    final hasConflict = info.conflicts.isNotEmpty;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              hasConflict ? Icons.warning_rounded : Icons.event_note,
              color: hasConflict ? Colors.red : maroonColor,
            ),
            const SizedBox(width: 12),
            const Text('Schedule Details'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('Subject', schedule.subject?.name ?? 'N/A'),
            _buildDetailItem('Code', schedule.subject?.code ?? 'N/A'),
            _buildDetailItem(
              'Instructor',
              schedule.faculty?.name ?? 'Unassigned',
            ),
            _buildDetailItem('Room', schedule.room?.name ?? 'N/A'),
            _buildDetailItem('Section', schedule.section),
            _buildDetailItem(
              'Time',
              '${schedule.timeslot?.day.name.toUpperCase()} ${schedule.timeslot?.startTime} - ${schedule.timeslot?.endTime}',
            ),
            if (hasConflict) ...[
              const Divider(height: 24),
              Text(
                'CONFLICT DETECTED:',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              ...info.conflicts.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${c.message}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.red[800],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onEdit?.call(schedule);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: maroonColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Edit Schedule'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  bool _isDayHighlighted(DayOfWeek day) {
    if (!isInstructorView) return false;
    return schedules.any((s) => s.schedule.timeslot?.day == day);
  }

  bool _isTimeHighlighted(int hour) {
    if (!isInstructorView) return false;
    return schedules.any((s) {
      final ts = s.schedule.timeslot;
      if (ts == null) return false;
      final start = _parseTime(ts.startTime);
      final end = _parseTime(ts.endTime);
      return hour >= start.hour && hour < end.hour;
    });
  }

  TimeOfDay _parseTime(String time) {
    // Expected format: "08:30" or "14:15"
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }

  String _getDayName(DayOfWeek day) {
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
}

class _PreferenceRange {
  final int start;
  final int end;
  _PreferenceRange(this.start, this.end);
}
