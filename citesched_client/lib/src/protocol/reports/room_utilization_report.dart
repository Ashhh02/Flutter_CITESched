import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class RoomUtilizationReport implements _i1.SerializableModel {
  RoomUtilizationReport._({
    required this.roomId,
    required this.roomName,
    required this.utilizationPercentage,
    required this.totalBookings,
    required this.isActive,
    this.program,
  });

  factory RoomUtilizationReport({
    required int roomId,
    required String roomName,
    required double utilizationPercentage,
    required int totalBookings,
    required bool isActive,
    String? program,
  }) = _RoomUtilizationReportImpl;

  factory RoomUtilizationReport.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return RoomUtilizationReport(
      roomId: jsonSerialization['roomId'] as int,
      roomName: jsonSerialization['roomName'] as String,
      utilizationPercentage: (jsonSerialization['utilizationPercentage'] as num)
          .toDouble(),
      totalBookings: jsonSerialization['totalBookings'] as int,
      isActive: jsonSerialization['isActive'] as bool,
      program: jsonSerialization['program'] as String?,
    );
  }

  int roomId;

  String roomName;

  double utilizationPercentage;

  int totalBookings;

  bool isActive;

  String? program;

  @_i1.useResult
  RoomUtilizationReport copyWith({
    int? roomId,
    String? roomName,
    double? utilizationPercentage,
    int? totalBookings,
    bool? isActive,
    String? program,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RoomUtilizationReport',
      'roomId': roomId,
      'roomName': roomName,
      'utilizationPercentage': utilizationPercentage,
      'totalBookings': totalBookings,
      'isActive': isActive,
      if (program != null) 'program': program,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RoomUtilizationReportImpl extends RoomUtilizationReport {
  _RoomUtilizationReportImpl({
    required int roomId,
    required String roomName,
    required double utilizationPercentage,
    required int totalBookings,
    required bool isActive,
    String? program,
  }) : super._(
         roomId: roomId,
         roomName: roomName,
         utilizationPercentage: utilizationPercentage,
         totalBookings: totalBookings,
         isActive: isActive,
         program: program,
       );

  @_i1.useResult
  @override
  RoomUtilizationReport copyWith({
    int? roomId,
    String? roomName,
    double? utilizationPercentage,
    int? totalBookings,
    bool? isActive,
    Object? program = _Undefined,
  }) {
    return RoomUtilizationReport(
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      utilizationPercentage:
          utilizationPercentage ?? this.utilizationPercentage,
      totalBookings: totalBookings ?? this.totalBookings,
      isActive: isActive ?? this.isActive,
      program: program is String? ? program : this.program,
    );
  }
}
