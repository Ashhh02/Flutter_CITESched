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

abstract class ScheduleConflict
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ScheduleConflict._({
    required this.type,
    required this.message,
    this.scheduleId,
    this.conflictingScheduleId,
    this.facultyId,
    this.roomId,
    this.subjectId,
    this.details,
  });

  factory ScheduleConflict({
    required String type,
    required String message,
    int? scheduleId,
    int? conflictingScheduleId,
    int? facultyId,
    int? roomId,
    int? subjectId,
    String? details,
  }) = _ScheduleConflictImpl;

  factory ScheduleConflict.fromJson(Map<String, dynamic> jsonSerialization) {
    return ScheduleConflict(
      type: jsonSerialization['type'] as String,
      message: jsonSerialization['message'] as String,
      scheduleId: jsonSerialization['scheduleId'] as int?,
      conflictingScheduleId: jsonSerialization['conflictingScheduleId'] as int?,
      facultyId: jsonSerialization['facultyId'] as int?,
      roomId: jsonSerialization['roomId'] as int?,
      subjectId: jsonSerialization['subjectId'] as int?,
      details: jsonSerialization['details'] as String?,
    );
  }

  String type;

  String message;

  int? scheduleId;

  int? conflictingScheduleId;

  int? facultyId;

  int? roomId;

  int? subjectId;

  String? details;

  /// Returns a shallow copy of this [ScheduleConflict]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ScheduleConflict copyWith({
    String? type,
    String? message,
    int? scheduleId,
    int? conflictingScheduleId,
    int? facultyId,
    int? roomId,
    int? subjectId,
    String? details,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ScheduleConflict',
      'type': type,
      'message': message,
      if (scheduleId != null) 'scheduleId': scheduleId,
      if (conflictingScheduleId != null)
        'conflictingScheduleId': conflictingScheduleId,
      if (facultyId != null) 'facultyId': facultyId,
      if (roomId != null) 'roomId': roomId,
      if (subjectId != null) 'subjectId': subjectId,
      if (details != null) 'details': details,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ScheduleConflict',
      'type': type,
      'message': message,
      if (scheduleId != null) 'scheduleId': scheduleId,
      if (conflictingScheduleId != null)
        'conflictingScheduleId': conflictingScheduleId,
      if (facultyId != null) 'facultyId': facultyId,
      if (roomId != null) 'roomId': roomId,
      if (subjectId != null) 'subjectId': subjectId,
      if (details != null) 'details': details,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ScheduleConflictImpl extends ScheduleConflict {
  _ScheduleConflictImpl({
    required String type,
    required String message,
    int? scheduleId,
    int? conflictingScheduleId,
    int? facultyId,
    int? roomId,
    int? subjectId,
    String? details,
  }) : super._(
         type: type,
         message: message,
         scheduleId: scheduleId,
         conflictingScheduleId: conflictingScheduleId,
         facultyId: facultyId,
         roomId: roomId,
         subjectId: subjectId,
         details: details,
       );

  /// Returns a shallow copy of this [ScheduleConflict]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ScheduleConflict copyWith({
    String? type,
    String? message,
    Object? scheduleId = _Undefined,
    Object? conflictingScheduleId = _Undefined,
    Object? facultyId = _Undefined,
    Object? roomId = _Undefined,
    Object? subjectId = _Undefined,
    Object? details = _Undefined,
  }) {
    return ScheduleConflict(
      type: type ?? this.type,
      message: message ?? this.message,
      scheduleId: scheduleId is int? ? scheduleId : this.scheduleId,
      conflictingScheduleId: conflictingScheduleId is int?
          ? conflictingScheduleId
          : this.conflictingScheduleId,
      facultyId: facultyId is int? ? facultyId : this.facultyId,
      roomId: roomId is int? ? roomId : this.roomId,
      subjectId: subjectId is int? ? subjectId : this.subjectId,
      details: details is String? ? details : this.details,
    );
  }
}
