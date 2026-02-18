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
import 'schedule.dart' as _i2;
import 'schedule_conflict.dart' as _i3;
import 'package:citesched_client/src/protocol/protocol.dart' as _i4;

abstract class ScheduleInfo implements _i1.SerializableModel {
  ScheduleInfo._({
    required this.schedule,
    required this.conflicts,
  });

  factory ScheduleInfo({
    required _i2.Schedule schedule,
    required List<_i3.ScheduleConflict> conflicts,
  }) = _ScheduleInfoImpl;

  factory ScheduleInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return ScheduleInfo(
      schedule: _i4.Protocol().deserialize<_i2.Schedule>(
        jsonSerialization['schedule'],
      ),
      conflicts: _i4.Protocol().deserialize<List<_i3.ScheduleConflict>>(
        jsonSerialization['conflicts'],
      ),
    );
  }

  _i2.Schedule schedule;

  List<_i3.ScheduleConflict> conflicts;

  /// Returns a shallow copy of this [ScheduleInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ScheduleInfo copyWith({
    _i2.Schedule? schedule,
    List<_i3.ScheduleConflict>? conflicts,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ScheduleInfo',
      'schedule': schedule.toJson(),
      'conflicts': conflicts.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ScheduleInfoImpl extends ScheduleInfo {
  _ScheduleInfoImpl({
    required _i2.Schedule schedule,
    required List<_i3.ScheduleConflict> conflicts,
  }) : super._(
         schedule: schedule,
         conflicts: conflicts,
       );

  /// Returns a shallow copy of this [ScheduleInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ScheduleInfo copyWith({
    _i2.Schedule? schedule,
    List<_i3.ScheduleConflict>? conflicts,
  }) {
    return ScheduleInfo(
      schedule: schedule ?? this.schedule.copyWith(),
      conflicts:
          conflicts ?? this.conflicts.map((e0) => e0.copyWith()).toList(),
    );
  }
}
