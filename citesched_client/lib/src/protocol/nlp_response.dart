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
import 'nlp_intent.dart' as _i2;
import 'schedule.dart' as _i3;
import 'package:citesched_client/src/protocol/protocol.dart' as _i4;

abstract class NLPResponse implements _i1.SerializableModel {
  NLPResponse._({
    required this.text,
    required this.intent,
    this.schedules,
    this.dataJson,
  });

  factory NLPResponse({
    required String text,
    required _i2.NLPIntent intent,
    List<_i3.Schedule>? schedules,
    String? dataJson,
  }) = _NLPResponseImpl;

  factory NLPResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return NLPResponse(
      text: jsonSerialization['text'] as String,
      intent: _i2.NLPIntent.fromJson((jsonSerialization['intent'] as String)),
      schedules: jsonSerialization['schedules'] == null
          ? null
          : _i4.Protocol().deserialize<List<_i3.Schedule>>(
              jsonSerialization['schedules'],
            ),
      dataJson: jsonSerialization['dataJson'] as String?,
    );
  }

  String text;

  _i2.NLPIntent intent;

  List<_i3.Schedule>? schedules;

  String? dataJson;

  /// Returns a shallow copy of this [NLPResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  NLPResponse copyWith({
    String? text,
    _i2.NLPIntent? intent,
    List<_i3.Schedule>? schedules,
    String? dataJson,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'NLPResponse',
      'text': text,
      'intent': intent.toJson(),
      if (schedules != null)
        'schedules': schedules?.toJson(valueToJson: (v) => v.toJson()),
      if (dataJson != null) 'dataJson': dataJson,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _NLPResponseImpl extends NLPResponse {
  _NLPResponseImpl({
    required String text,
    required _i2.NLPIntent intent,
    List<_i3.Schedule>? schedules,
    String? dataJson,
  }) : super._(
         text: text,
         intent: intent,
         schedules: schedules,
         dataJson: dataJson,
       );

  /// Returns a shallow copy of this [NLPResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  NLPResponse copyWith({
    String? text,
    _i2.NLPIntent? intent,
    Object? schedules = _Undefined,
    Object? dataJson = _Undefined,
  }) {
    return NLPResponse(
      text: text ?? this.text,
      intent: intent ?? this.intent,
      schedules: schedules is List<_i3.Schedule>?
          ? schedules
          : this.schedules?.map((e0) => e0.copyWith()).toList(),
      dataJson: dataJson is String? ? dataJson : this.dataJson,
    );
  }
}
