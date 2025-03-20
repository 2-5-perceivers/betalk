// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      json['messageID'] as String,
      messageAuthor: json['messageAuthor'] as String?,
      messageTextContent: json['messageTextContent'] as String?,
      messageFileContent: _$JsonConverterFromJson<List<int>, Uint8List>(
          json['messageFileContent'], const Uint8ListConverter().fromJson),
      time: json['time'] as String,
      type: $enumDecode(_$MessageTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'messageID': instance.messageID,
      'messageAuthor': instance.messageAuthor,
      'messageTextContent': instance.messageTextContent,
      'messageFileContent': _$JsonConverterToJson<List<int>, Uint8List>(
          instance.messageFileContent, const Uint8ListConverter().toJson),
      'time': instance.time,
      'type': _$MessageTypeEnumMap[instance.type]!,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

const _$MessageTypeEnumMap = {
  MessageType.userMessage: 'user-message',
  MessageType.systemMessage: 'system-message',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
