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
import 'package:serverpod/serverpod.dart' as _i1;
import 'package:citesched_server/src/generated/protocol.dart' as _i2;

abstract class ScheduleOverviewReport
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ScheduleOverviewReport._({
    required this.totalSchedules,
    required this.schedulesByProgram,
    this.activeTerm,
    this.academicYear,
  });

  factory ScheduleOverviewReport({
    required int totalSchedules,
    required Map<String, int> schedulesByProgram,
    int? activeTerm,
    String? academicYear,
  }) = _ScheduleOverviewReportImpl;

  factory ScheduleOverviewReport.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ScheduleOverviewReport(
      totalSchedules: jsonSerialization['totalSchedules'] as int,
      schedulesByProgram: _i2.Protocol().deserialize<Map<String, int>>(
        jsonSerialization['schedulesByProgram'],
      ),
      activeTerm: jsonSerialization['activeTerm'] as int?,
      academicYear: jsonSerialization['academicYear'] as String?,
    );
  }

  int totalSchedules;

  Map<String, int> schedulesByProgram;

  int? activeTerm;

  String? academicYear;

  /// Returns a shallow copy of this [ScheduleOverviewReport]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ScheduleOverviewReport copyWith({
    int? totalSchedules,
    Map<String, int>? schedulesByProgram,
    int? activeTerm,
    String? academicYear,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ScheduleOverviewReport',
      'totalSchedules': totalSchedules,
      'schedulesByProgram': schedulesByProgram.toJson(),
      if (activeTerm != null) 'activeTerm': activeTerm,
      if (academicYear != null) 'academicYear': academicYear,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ScheduleOverviewReport',
      'totalSchedules': totalSchedules,
      'schedulesByProgram': schedulesByProgram.toJson(),
      if (activeTerm != null) 'activeTerm': activeTerm,
      if (academicYear != null) 'academicYear': academicYear,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ScheduleOverviewReportImpl extends ScheduleOverviewReport {
  _ScheduleOverviewReportImpl({
    required int totalSchedules,
    required Map<String, int> schedulesByProgram,
    int? activeTerm,
    String? academicYear,
  }) : super._(
         totalSchedules: totalSchedules,
         schedulesByProgram: schedulesByProgram,
         activeTerm: activeTerm,
         academicYear: academicYear,
       );

  /// Returns a shallow copy of this [ScheduleOverviewReport]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ScheduleOverviewReport copyWith({
    int? totalSchedules,
    Map<String, int>? schedulesByProgram,
    Object? activeTerm = _Undefined,
    Object? academicYear = _Undefined,
  }) {
    return ScheduleOverviewReport(
      totalSchedules: totalSchedules ?? this.totalSchedules,
      schedulesByProgram:
          schedulesByProgram ??
          this.schedulesByProgram.map(
            (
              key0,
              value0,
            ) => MapEntry(
              key0,
              value0,
            ),
          ),
      activeTerm: activeTerm is int? ? activeTerm : this.activeTerm,
      academicYear: academicYear is String? ? academicYear : this.academicYear,
    );
  }
}
