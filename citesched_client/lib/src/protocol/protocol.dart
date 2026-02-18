/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dashboard_stats.dart' as _i2;
import 'day_of_week.dart' as _i3;
import 'distribution_data.dart' as _i4;
import 'employment_status.dart' as _i5;
import 'faculty.dart' as _i6;
import 'faculty_load_data.dart' as _i7;
import 'faculty_shift_preference.dart' as _i8;
import 'generate_schedule_request.dart' as _i9;
import 'generate_schedule_response.dart' as _i10;
import 'greetings/greeting.dart' as _i11;
import 'nlp_intent.dart' as _i12;
import 'nlp_response.dart' as _i13;
import 'program.dart' as _i14;
import 'reports/conflict_summary_report.dart' as _i15;
import 'reports/faculty_load_report.dart' as _i16;
import 'reports/room_utilization_report.dart' as _i17;
import 'reports/schedule_overview_report.dart' as _i18;
import 'room.dart' as _i19;
import 'room_type.dart' as _i20;
import 'schedule.dart' as _i21;
import 'schedule_conflict.dart' as _i22;
import 'schedule_info.dart' as _i23;
import 'student.dart' as _i24;
import 'subject.dart' as _i25;
import 'subject_type.dart' as _i26;
import 'timeslot.dart' as _i27;
import 'timetable_filter_request.dart' as _i28;
import 'timetable_summary.dart' as _i29;
import 'user_role.dart' as _i30;
import 'package:citesched_client/src/protocol/user_role.dart' as _i31;
import 'package:citesched_client/src/protocol/faculty.dart' as _i32;
import 'package:citesched_client/src/protocol/student.dart' as _i33;
import 'package:citesched_client/src/protocol/room.dart' as _i34;
import 'package:citesched_client/src/protocol/subject.dart' as _i35;
import 'package:citesched_client/src/protocol/timeslot.dart' as _i36;
import 'package:citesched_client/src/protocol/schedule.dart' as _i37;
import 'package:citesched_client/src/protocol/schedule_conflict.dart' as _i38;
import 'package:citesched_client/src/protocol/reports/faculty_load_report.dart'
    as _i39;
import 'package:citesched_client/src/protocol/reports/room_utilization_report.dart'
    as _i40;
import 'package:citesched_client/src/protocol/schedule_info.dart' as _i41;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i42;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i43;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i44;
export 'dashboard_stats.dart';
export 'day_of_week.dart';
export 'distribution_data.dart';
export 'employment_status.dart';
export 'faculty.dart';
export 'faculty_load_data.dart';
export 'faculty_shift_preference.dart';
export 'generate_schedule_request.dart';
export 'generate_schedule_response.dart';
export 'greetings/greeting.dart';
export 'nlp_intent.dart';
export 'nlp_response.dart';
export 'program.dart';
export 'reports/conflict_summary_report.dart';
export 'reports/faculty_load_report.dart';
export 'reports/room_utilization_report.dart';
export 'reports/schedule_overview_report.dart';
export 'room.dart';
export 'room_type.dart';
export 'schedule.dart';
export 'schedule_conflict.dart';
export 'schedule_info.dart';
export 'student.dart';
export 'subject.dart';
export 'subject_type.dart';
export 'timeslot.dart';
export 'timetable_filter_request.dart';
export 'timetable_summary.dart';
export 'user_role.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.DashboardStats) {
      return _i2.DashboardStats.fromJson(data) as T;
    }
    if (t == _i3.DayOfWeek) {
      return _i3.DayOfWeek.fromJson(data) as T;
    }
    if (t == _i4.DistributionData) {
      return _i4.DistributionData.fromJson(data) as T;
    }
    if (t == _i5.EmploymentStatus) {
      return _i5.EmploymentStatus.fromJson(data) as T;
    }
    if (t == _i6.Faculty) {
      return _i6.Faculty.fromJson(data) as T;
    }
    if (t == _i7.FacultyLoadData) {
      return _i7.FacultyLoadData.fromJson(data) as T;
    }
    if (t == _i8.FacultyShiftPreference) {
      return _i8.FacultyShiftPreference.fromJson(data) as T;
    }
    if (t == _i9.GenerateScheduleRequest) {
      return _i9.GenerateScheduleRequest.fromJson(data) as T;
    }
    if (t == _i10.GenerateScheduleResponse) {
      return _i10.GenerateScheduleResponse.fromJson(data) as T;
    }
    if (t == _i11.Greeting) {
      return _i11.Greeting.fromJson(data) as T;
    }
    if (t == _i12.NLPIntent) {
      return _i12.NLPIntent.fromJson(data) as T;
    }
    if (t == _i13.NLPResponse) {
      return _i13.NLPResponse.fromJson(data) as T;
    }
    if (t == _i14.Program) {
      return _i14.Program.fromJson(data) as T;
    }
    if (t == _i15.ConflictSummaryReport) {
      return _i15.ConflictSummaryReport.fromJson(data) as T;
    }
    if (t == _i16.FacultyLoadReport) {
      return _i16.FacultyLoadReport.fromJson(data) as T;
    }
    if (t == _i17.RoomUtilizationReport) {
      return _i17.RoomUtilizationReport.fromJson(data) as T;
    }
    if (t == _i18.ScheduleOverviewReport) {
      return _i18.ScheduleOverviewReport.fromJson(data) as T;
    }
    if (t == _i19.Room) {
      return _i19.Room.fromJson(data) as T;
    }
    if (t == _i20.RoomType) {
      return _i20.RoomType.fromJson(data) as T;
    }
    if (t == _i21.Schedule) {
      return _i21.Schedule.fromJson(data) as T;
    }
    if (t == _i22.ScheduleConflict) {
      return _i22.ScheduleConflict.fromJson(data) as T;
    }
    if (t == _i23.ScheduleInfo) {
      return _i23.ScheduleInfo.fromJson(data) as T;
    }
    if (t == _i24.Student) {
      return _i24.Student.fromJson(data) as T;
    }
    if (t == _i25.Subject) {
      return _i25.Subject.fromJson(data) as T;
    }
    if (t == _i26.SubjectType) {
      return _i26.SubjectType.fromJson(data) as T;
    }
    if (t == _i27.Timeslot) {
      return _i27.Timeslot.fromJson(data) as T;
    }
    if (t == _i28.TimetableFilterRequest) {
      return _i28.TimetableFilterRequest.fromJson(data) as T;
    }
    if (t == _i29.TimetableSummary) {
      return _i29.TimetableSummary.fromJson(data) as T;
    }
    if (t == _i30.UserRole) {
      return _i30.UserRole.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.DashboardStats?>()) {
      return (data != null ? _i2.DashboardStats.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.DayOfWeek?>()) {
      return (data != null ? _i3.DayOfWeek.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.DistributionData?>()) {
      return (data != null ? _i4.DistributionData.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.EmploymentStatus?>()) {
      return (data != null ? _i5.EmploymentStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.Faculty?>()) {
      return (data != null ? _i6.Faculty.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.FacultyLoadData?>()) {
      return (data != null ? _i7.FacultyLoadData.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.FacultyShiftPreference?>()) {
      return (data != null ? _i8.FacultyShiftPreference.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i9.GenerateScheduleRequest?>()) {
      return (data != null ? _i9.GenerateScheduleRequest.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i10.GenerateScheduleResponse?>()) {
      return (data != null
              ? _i10.GenerateScheduleResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i11.Greeting?>()) {
      return (data != null ? _i11.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.NLPIntent?>()) {
      return (data != null ? _i12.NLPIntent.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.NLPResponse?>()) {
      return (data != null ? _i13.NLPResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.Program?>()) {
      return (data != null ? _i14.Program.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.ConflictSummaryReport?>()) {
      return (data != null ? _i15.ConflictSummaryReport.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i16.FacultyLoadReport?>()) {
      return (data != null ? _i16.FacultyLoadReport.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.RoomUtilizationReport?>()) {
      return (data != null ? _i17.RoomUtilizationReport.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i18.ScheduleOverviewReport?>()) {
      return (data != null ? _i18.ScheduleOverviewReport.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i19.Room?>()) {
      return (data != null ? _i19.Room.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.RoomType?>()) {
      return (data != null ? _i20.RoomType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.Schedule?>()) {
      return (data != null ? _i21.Schedule.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.ScheduleConflict?>()) {
      return (data != null ? _i22.ScheduleConflict.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.ScheduleInfo?>()) {
      return (data != null ? _i23.ScheduleInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.Student?>()) {
      return (data != null ? _i24.Student.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i25.Subject?>()) {
      return (data != null ? _i25.Subject.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i26.SubjectType?>()) {
      return (data != null ? _i26.SubjectType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i27.Timeslot?>()) {
      return (data != null ? _i27.Timeslot.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i28.TimetableFilterRequest?>()) {
      return (data != null ? _i28.TimetableFilterRequest.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i29.TimetableSummary?>()) {
      return (data != null ? _i29.TimetableSummary.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i30.UserRole?>()) {
      return (data != null ? _i30.UserRole.fromJson(data) : null) as T;
    }
    if (t == List<_i7.FacultyLoadData>) {
      return (data as List)
              .map((e) => deserialize<_i7.FacultyLoadData>(e))
              .toList()
          as T;
    }
    if (t == List<_i22.ScheduleConflict>) {
      return (data as List)
              .map((e) => deserialize<_i22.ScheduleConflict>(e))
              .toList()
          as T;
    }
    if (t == List<_i4.DistributionData>) {
      return (data as List)
              .map((e) => deserialize<_i4.DistributionData>(e))
              .toList()
          as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i21.Schedule>) {
      return (data as List).map((e) => deserialize<_i21.Schedule>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<_i21.Schedule>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i21.Schedule>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == _i1.getType<List<_i22.ScheduleConflict>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i22.ScheduleConflict>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == Map<String, int>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<int>(v)),
          )
          as T;
    }
    if (t == List<_i26.SubjectType>) {
      return (data as List)
              .map((e) => deserialize<_i26.SubjectType>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i26.SubjectType>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i26.SubjectType>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i31.UserRole>) {
      return (data as List).map((e) => deserialize<_i31.UserRole>(e)).toList()
          as T;
    }
    if (t == List<_i32.Faculty>) {
      return (data as List).map((e) => deserialize<_i32.Faculty>(e)).toList()
          as T;
    }
    if (t == List<_i33.Student>) {
      return (data as List).map((e) => deserialize<_i33.Student>(e)).toList()
          as T;
    }
    if (t == List<_i34.Room>) {
      return (data as List).map((e) => deserialize<_i34.Room>(e)).toList() as T;
    }
    if (t == List<_i35.Subject>) {
      return (data as List).map((e) => deserialize<_i35.Subject>(e)).toList()
          as T;
    }
    if (t == List<_i36.Timeslot>) {
      return (data as List).map((e) => deserialize<_i36.Timeslot>(e)).toList()
          as T;
    }
    if (t == List<_i37.Schedule>) {
      return (data as List).map((e) => deserialize<_i37.Schedule>(e)).toList()
          as T;
    }
    if (t == List<_i38.ScheduleConflict>) {
      return (data as List)
              .map((e) => deserialize<_i38.ScheduleConflict>(e))
              .toList()
          as T;
    }
    if (t == List<_i39.FacultyLoadReport>) {
      return (data as List)
              .map((e) => deserialize<_i39.FacultyLoadReport>(e))
              .toList()
          as T;
    }
    if (t == List<_i40.RoomUtilizationReport>) {
      return (data as List)
              .map((e) => deserialize<_i40.RoomUtilizationReport>(e))
              .toList()
          as T;
    }
    if (t == List<_i41.ScheduleInfo>) {
      return (data as List)
              .map((e) => deserialize<_i41.ScheduleInfo>(e))
              .toList()
          as T;
    }
    try {
      return _i42.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i43.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i44.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.DashboardStats => 'DashboardStats',
      _i3.DayOfWeek => 'DayOfWeek',
      _i4.DistributionData => 'DistributionData',
      _i5.EmploymentStatus => 'EmploymentStatus',
      _i6.Faculty => 'Faculty',
      _i7.FacultyLoadData => 'FacultyLoadData',
      _i8.FacultyShiftPreference => 'FacultyShiftPreference',
      _i9.GenerateScheduleRequest => 'GenerateScheduleRequest',
      _i10.GenerateScheduleResponse => 'GenerateScheduleResponse',
      _i11.Greeting => 'Greeting',
      _i12.NLPIntent => 'NLPIntent',
      _i13.NLPResponse => 'NLPResponse',
      _i14.Program => 'Program',
      _i15.ConflictSummaryReport => 'ConflictSummaryReport',
      _i16.FacultyLoadReport => 'FacultyLoadReport',
      _i17.RoomUtilizationReport => 'RoomUtilizationReport',
      _i18.ScheduleOverviewReport => 'ScheduleOverviewReport',
      _i19.Room => 'Room',
      _i20.RoomType => 'RoomType',
      _i21.Schedule => 'Schedule',
      _i22.ScheduleConflict => 'ScheduleConflict',
      _i23.ScheduleInfo => 'ScheduleInfo',
      _i24.Student => 'Student',
      _i25.Subject => 'Subject',
      _i26.SubjectType => 'SubjectType',
      _i27.Timeslot => 'Timeslot',
      _i28.TimetableFilterRequest => 'TimetableFilterRequest',
      _i29.TimetableSummary => 'TimetableSummary',
      _i30.UserRole => 'UserRole',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('citesched.', '');
    }

    switch (data) {
      case _i2.DashboardStats():
        return 'DashboardStats';
      case _i3.DayOfWeek():
        return 'DayOfWeek';
      case _i4.DistributionData():
        return 'DistributionData';
      case _i5.EmploymentStatus():
        return 'EmploymentStatus';
      case _i6.Faculty():
        return 'Faculty';
      case _i7.FacultyLoadData():
        return 'FacultyLoadData';
      case _i8.FacultyShiftPreference():
        return 'FacultyShiftPreference';
      case _i9.GenerateScheduleRequest():
        return 'GenerateScheduleRequest';
      case _i10.GenerateScheduleResponse():
        return 'GenerateScheduleResponse';
      case _i11.Greeting():
        return 'Greeting';
      case _i12.NLPIntent():
        return 'NLPIntent';
      case _i13.NLPResponse():
        return 'NLPResponse';
      case _i14.Program():
        return 'Program';
      case _i15.ConflictSummaryReport():
        return 'ConflictSummaryReport';
      case _i16.FacultyLoadReport():
        return 'FacultyLoadReport';
      case _i17.RoomUtilizationReport():
        return 'RoomUtilizationReport';
      case _i18.ScheduleOverviewReport():
        return 'ScheduleOverviewReport';
      case _i19.Room():
        return 'Room';
      case _i20.RoomType():
        return 'RoomType';
      case _i21.Schedule():
        return 'Schedule';
      case _i22.ScheduleConflict():
        return 'ScheduleConflict';
      case _i23.ScheduleInfo():
        return 'ScheduleInfo';
      case _i24.Student():
        return 'Student';
      case _i25.Subject():
        return 'Subject';
      case _i26.SubjectType():
        return 'SubjectType';
      case _i27.Timeslot():
        return 'Timeslot';
      case _i28.TimetableFilterRequest():
        return 'TimetableFilterRequest';
      case _i29.TimetableSummary():
        return 'TimetableSummary';
      case _i30.UserRole():
        return 'UserRole';
    }
    className = _i42.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i43.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth.$className';
    }
    className = _i44.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'DashboardStats') {
      return deserialize<_i2.DashboardStats>(data['data']);
    }
    if (dataClassName == 'DayOfWeek') {
      return deserialize<_i3.DayOfWeek>(data['data']);
    }
    if (dataClassName == 'DistributionData') {
      return deserialize<_i4.DistributionData>(data['data']);
    }
    if (dataClassName == 'EmploymentStatus') {
      return deserialize<_i5.EmploymentStatus>(data['data']);
    }
    if (dataClassName == 'Faculty') {
      return deserialize<_i6.Faculty>(data['data']);
    }
    if (dataClassName == 'FacultyLoadData') {
      return deserialize<_i7.FacultyLoadData>(data['data']);
    }
    if (dataClassName == 'FacultyShiftPreference') {
      return deserialize<_i8.FacultyShiftPreference>(data['data']);
    }
    if (dataClassName == 'GenerateScheduleRequest') {
      return deserialize<_i9.GenerateScheduleRequest>(data['data']);
    }
    if (dataClassName == 'GenerateScheduleResponse') {
      return deserialize<_i10.GenerateScheduleResponse>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i11.Greeting>(data['data']);
    }
    if (dataClassName == 'NLPIntent') {
      return deserialize<_i12.NLPIntent>(data['data']);
    }
    if (dataClassName == 'NLPResponse') {
      return deserialize<_i13.NLPResponse>(data['data']);
    }
    if (dataClassName == 'Program') {
      return deserialize<_i14.Program>(data['data']);
    }
    if (dataClassName == 'ConflictSummaryReport') {
      return deserialize<_i15.ConflictSummaryReport>(data['data']);
    }
    if (dataClassName == 'FacultyLoadReport') {
      return deserialize<_i16.FacultyLoadReport>(data['data']);
    }
    if (dataClassName == 'RoomUtilizationReport') {
      return deserialize<_i17.RoomUtilizationReport>(data['data']);
    }
    if (dataClassName == 'ScheduleOverviewReport') {
      return deserialize<_i18.ScheduleOverviewReport>(data['data']);
    }
    if (dataClassName == 'Room') {
      return deserialize<_i19.Room>(data['data']);
    }
    if (dataClassName == 'RoomType') {
      return deserialize<_i20.RoomType>(data['data']);
    }
    if (dataClassName == 'Schedule') {
      return deserialize<_i21.Schedule>(data['data']);
    }
    if (dataClassName == 'ScheduleConflict') {
      return deserialize<_i22.ScheduleConflict>(data['data']);
    }
    if (dataClassName == 'ScheduleInfo') {
      return deserialize<_i23.ScheduleInfo>(data['data']);
    }
    if (dataClassName == 'Student') {
      return deserialize<_i24.Student>(data['data']);
    }
    if (dataClassName == 'Subject') {
      return deserialize<_i25.Subject>(data['data']);
    }
    if (dataClassName == 'SubjectType') {
      return deserialize<_i26.SubjectType>(data['data']);
    }
    if (dataClassName == 'Timeslot') {
      return deserialize<_i27.Timeslot>(data['data']);
    }
    if (dataClassName == 'TimetableFilterRequest') {
      return deserialize<_i28.TimetableFilterRequest>(data['data']);
    }
    if (dataClassName == 'TimetableSummary') {
      return deserialize<_i29.TimetableSummary>(data['data']);
    }
    if (dataClassName == 'UserRole') {
      return deserialize<_i30.UserRole>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i42.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i43.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i44.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i42.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i43.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i44.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
