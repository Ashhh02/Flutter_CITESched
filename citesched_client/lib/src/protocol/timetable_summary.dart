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

abstract class TimetableSummary implements _i1.SerializableModel {
  TimetableSummary._({
    required this.totalSubjects,
    required this.totalUnits,
    required this.totalWeeklyHours,
    required this.conflictCount,
  });

  factory TimetableSummary({
    required int totalSubjects,
    required double totalUnits,
    required double totalWeeklyHours,
    required int conflictCount,
  }) = _TimetableSummaryImpl;

  factory TimetableSummary.fromJson(Map<String, dynamic> jsonSerialization) {
    return TimetableSummary(
      totalSubjects: jsonSerialization['totalSubjects'] as int,
      totalUnits: (jsonSerialization['totalUnits'] as num).toDouble(),
      totalWeeklyHours: (jsonSerialization['totalWeeklyHours'] as num)
          .toDouble(),
      conflictCount: jsonSerialization['conflictCount'] as int,
    );
  }

  int totalSubjects;

  double totalUnits;

  double totalWeeklyHours;

  int conflictCount;

  /// Returns a shallow copy of this [TimetableSummary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TimetableSummary copyWith({
    int? totalSubjects,
    double? totalUnits,
    double? totalWeeklyHours,
    int? conflictCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TimetableSummary',
      'totalSubjects': totalSubjects,
      'totalUnits': totalUnits,
      'totalWeeklyHours': totalWeeklyHours,
      'conflictCount': conflictCount,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _TimetableSummaryImpl extends TimetableSummary {
  _TimetableSummaryImpl({
    required int totalSubjects,
    required double totalUnits,
    required double totalWeeklyHours,
    required int conflictCount,
  }) : super._(
         totalSubjects: totalSubjects,
         totalUnits: totalUnits,
         totalWeeklyHours: totalWeeklyHours,
         conflictCount: conflictCount,
       );

  /// Returns a shallow copy of this [TimetableSummary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TimetableSummary copyWith({
    int? totalSubjects,
    double? totalUnits,
    double? totalWeeklyHours,
    int? conflictCount,
  }) {
    return TimetableSummary(
      totalSubjects: totalSubjects ?? this.totalSubjects,
      totalUnits: totalUnits ?? this.totalUnits,
      totalWeeklyHours: totalWeeklyHours ?? this.totalWeeklyHours,
      conflictCount: conflictCount ?? this.conflictCount,
    );
  }
}
