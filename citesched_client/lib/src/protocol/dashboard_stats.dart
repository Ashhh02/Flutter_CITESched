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
import 'faculty_load_data.dart' as _i2;
import 'schedule_conflict.dart' as _i3;
import 'distribution_data.dart' as _i4;
import 'package:citesched_client/src/protocol/protocol.dart' as _i5;

abstract class DashboardStats implements _i1.SerializableModel {
  DashboardStats._({
    required this.totalSchedules,
    required this.totalFaculty,
    required this.totalStudents,
    required this.totalSubjects,
    required this.totalRooms,
    required this.totalConflicts,
    required this.facultyLoad,
    required this.recentConflicts,
    required this.sectionDistribution,
    required this.yearLevelDistribution,
  });

  factory DashboardStats({
    required int totalSchedules,
    required int totalFaculty,
    required int totalStudents,
    required int totalSubjects,
    required int totalRooms,
    required int totalConflicts,
    required List<_i2.FacultyLoadData> facultyLoad,
    required List<_i3.ScheduleConflict> recentConflicts,
    required List<_i4.DistributionData> sectionDistribution,
    required List<_i4.DistributionData> yearLevelDistribution,
  }) = _DashboardStatsImpl;

  factory DashboardStats.fromJson(Map<String, dynamic> jsonSerialization) {
    return DashboardStats(
      totalSchedules: jsonSerialization['totalSchedules'] as int,
      totalFaculty: jsonSerialization['totalFaculty'] as int,
      totalStudents: jsonSerialization['totalStudents'] as int,
      totalSubjects: jsonSerialization['totalSubjects'] as int,
      totalRooms: jsonSerialization['totalRooms'] as int,
      totalConflicts: jsonSerialization['totalConflicts'] as int,
      facultyLoad: _i5.Protocol().deserialize<List<_i2.FacultyLoadData>>(
        jsonSerialization['facultyLoad'],
      ),
      recentConflicts: _i5.Protocol().deserialize<List<_i3.ScheduleConflict>>(
        jsonSerialization['recentConflicts'],
      ),
      sectionDistribution: _i5.Protocol()
          .deserialize<List<_i4.DistributionData>>(
            jsonSerialization['sectionDistribution'],
          ),
      yearLevelDistribution: _i5.Protocol()
          .deserialize<List<_i4.DistributionData>>(
            jsonSerialization['yearLevelDistribution'],
          ),
    );
  }

  int totalSchedules;

  int totalFaculty;

  int totalStudents;

  int totalSubjects;

  int totalRooms;

  int totalConflicts;

  List<_i2.FacultyLoadData> facultyLoad;

  List<_i3.ScheduleConflict> recentConflicts;

  List<_i4.DistributionData> sectionDistribution;

  List<_i4.DistributionData> yearLevelDistribution;

  /// Returns a shallow copy of this [DashboardStats]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DashboardStats copyWith({
    int? totalSchedules,
    int? totalFaculty,
    int? totalStudents,
    int? totalSubjects,
    int? totalRooms,
    int? totalConflicts,
    List<_i2.FacultyLoadData>? facultyLoad,
    List<_i3.ScheduleConflict>? recentConflicts,
    List<_i4.DistributionData>? sectionDistribution,
    List<_i4.DistributionData>? yearLevelDistribution,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DashboardStats',
      'totalSchedules': totalSchedules,
      'totalFaculty': totalFaculty,
      'totalStudents': totalStudents,
      'totalSubjects': totalSubjects,
      'totalRooms': totalRooms,
      'totalConflicts': totalConflicts,
      'facultyLoad': facultyLoad.toJson(valueToJson: (v) => v.toJson()),
      'recentConflicts': recentConflicts.toJson(valueToJson: (v) => v.toJson()),
      'sectionDistribution': sectionDistribution.toJson(
        valueToJson: (v) => v.toJson(),
      ),
      'yearLevelDistribution': yearLevelDistribution.toJson(
        valueToJson: (v) => v.toJson(),
      ),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _DashboardStatsImpl extends DashboardStats {
  _DashboardStatsImpl({
    required int totalSchedules,
    required int totalFaculty,
    required int totalStudents,
    required int totalSubjects,
    required int totalRooms,
    required int totalConflicts,
    required List<_i2.FacultyLoadData> facultyLoad,
    required List<_i3.ScheduleConflict> recentConflicts,
    required List<_i4.DistributionData> sectionDistribution,
    required List<_i4.DistributionData> yearLevelDistribution,
  }) : super._(
         totalSchedules: totalSchedules,
         totalFaculty: totalFaculty,
         totalStudents: totalStudents,
         totalSubjects: totalSubjects,
         totalRooms: totalRooms,
         totalConflicts: totalConflicts,
         facultyLoad: facultyLoad,
         recentConflicts: recentConflicts,
         sectionDistribution: sectionDistribution,
         yearLevelDistribution: yearLevelDistribution,
       );

  /// Returns a shallow copy of this [DashboardStats]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DashboardStats copyWith({
    int? totalSchedules,
    int? totalFaculty,
    int? totalStudents,
    int? totalSubjects,
    int? totalRooms,
    int? totalConflicts,
    List<_i2.FacultyLoadData>? facultyLoad,
    List<_i3.ScheduleConflict>? recentConflicts,
    List<_i4.DistributionData>? sectionDistribution,
    List<_i4.DistributionData>? yearLevelDistribution,
  }) {
    return DashboardStats(
      totalSchedules: totalSchedules ?? this.totalSchedules,
      totalFaculty: totalFaculty ?? this.totalFaculty,
      totalStudents: totalStudents ?? this.totalStudents,
      totalSubjects: totalSubjects ?? this.totalSubjects,
      totalRooms: totalRooms ?? this.totalRooms,
      totalConflicts: totalConflicts ?? this.totalConflicts,
      facultyLoad:
          facultyLoad ?? this.facultyLoad.map((e0) => e0.copyWith()).toList(),
      recentConflicts:
          recentConflicts ??
          this.recentConflicts.map((e0) => e0.copyWith()).toList(),
      sectionDistribution:
          sectionDistribution ??
          this.sectionDistribution.map((e0) => e0.copyWith()).toList(),
      yearLevelDistribution:
          yearLevelDistribution ??
          this.yearLevelDistribution.map((e0) => e0.copyWith()).toList(),
    );
  }
}
