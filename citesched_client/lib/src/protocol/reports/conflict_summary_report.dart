import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'package:citesched_client/src/protocol/protocol.dart' as _i2;

abstract class ConflictSummaryReport implements _i1.SerializableModel {
  ConflictSummaryReport._({
    required this.totalConflicts,
    required this.conflictsByType,
    required this.resolvedConflicts,
    this.mostFrequentConflictType,
  });

  factory ConflictSummaryReport({
    required int totalConflicts,
    required Map<String, int> conflictsByType,
    required int resolvedConflicts,
    String? mostFrequentConflictType,
  }) = _ConflictSummaryReportImpl;

  factory ConflictSummaryReport.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ConflictSummaryReport(
      totalConflicts: jsonSerialization['totalConflicts'] as int,
      conflictsByType: _i2.Protocol().deserialize<Map<String, int>>(
        jsonSerialization['conflictsByType'],
      ),
      resolvedConflicts: jsonSerialization['resolvedConflicts'] as int,
      mostFrequentConflictType:
          jsonSerialization['mostFrequentConflictType'] as String?,
    );
  }

  int totalConflicts;

  Map<String, int> conflictsByType;

  int resolvedConflicts;

  String? mostFrequentConflictType;

  @_i1.useResult
  ConflictSummaryReport copyWith({
    int? totalConflicts,
    Map<String, int>? conflictsByType,
    int? resolvedConflicts,
    String? mostFrequentConflictType,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ConflictSummaryReport',
      'totalConflicts': totalConflicts,
      'conflictsByType': conflictsByType.toJson(),
      'resolvedConflicts': resolvedConflicts,
      if (mostFrequentConflictType != null)
        'mostFrequentConflictType': mostFrequentConflictType,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ConflictSummaryReportImpl extends ConflictSummaryReport {
  _ConflictSummaryReportImpl({
    required int totalConflicts,
    required Map<String, int> conflictsByType,
    required int resolvedConflicts,
    String? mostFrequentConflictType,
  }) : super._(
         totalConflicts: totalConflicts,
         conflictsByType: conflictsByType,
         resolvedConflicts: resolvedConflicts,
         mostFrequentConflictType: mostFrequentConflictType,
       );

  @_i1.useResult
  @override
  ConflictSummaryReport copyWith({
    int? totalConflicts,
    Map<String, int>? conflictsByType,
    int? resolvedConflicts,
    Object? mostFrequentConflictType = _Undefined,
  }) {
    return ConflictSummaryReport(
      totalConflicts: totalConflicts ?? this.totalConflicts,
      conflictsByType:
          conflictsByType ??
          this.conflictsByType.map(
            (
              key0,
              value0,
            ) => MapEntry(
              key0,
              value0,
            ),
          ),
      resolvedConflicts: resolvedConflicts ?? this.resolvedConflicts,
      mostFrequentConflictType: mostFrequentConflictType is String?
          ? mostFrequentConflictType
          : this.mostFrequentConflictType,
    );
  }
}
