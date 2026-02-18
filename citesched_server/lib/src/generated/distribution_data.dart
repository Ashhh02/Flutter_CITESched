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

abstract class DistributionData
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  DistributionData._({
    required this.label,
    required this.count,
  });

  factory DistributionData({
    required String label,
    required int count,
  }) = _DistributionDataImpl;

  factory DistributionData.fromJson(Map<String, dynamic> jsonSerialization) {
    return DistributionData(
      label: jsonSerialization['label'] as String,
      count: jsonSerialization['count'] as int,
    );
  }

  String label;

  int count;

  /// Returns a shallow copy of this [DistributionData]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DistributionData copyWith({
    String? label,
    int? count,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DistributionData',
      'label': label,
      'count': count,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DistributionData',
      'label': label,
      'count': count,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _DistributionDataImpl extends DistributionData {
  _DistributionDataImpl({
    required String label,
    required int count,
  }) : super._(
         label: label,
         count: count,
       );

  /// Returns a shallow copy of this [DistributionData]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DistributionData copyWith({
    String? label,
    int? count,
  }) {
    return DistributionData(
      label: label ?? this.label,
      count: count ?? this.count,
    );
  }
}
