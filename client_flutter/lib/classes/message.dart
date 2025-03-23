import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  const Message(
    this.id, {
    this.author,
    this.textContent,
    this.fileContent,
    required this.time,
    required this.type,
  }) : assert(textContent != null || fileContent != null);

  Message.newMessage({required this.author, this.textContent, this.fileContent})
      : id = const Uuid().v4(),
        type = MessageType.userMessage,
        time = DateTime.now().toUtc().toIso8601String(),
        assert(textContent != null || fileContent != null);

  final String id;
  final String? author, textContent;
  @Uint8ListConverter()
  final Uint8List? fileContent;
  final String time;
  final MessageType type;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

enum MessageType {
  @JsonValue("USER_MESSAGE")
  userMessage,
  @JsonValue("SYSTEM_MESSAGE")
  systemMessage,
}

class Uint8ListConverter implements JsonConverter<Uint8List, List<int>> {
  const Uint8ListConverter();

  @override
  Uint8List fromJson(List<int> json) {
    return Uint8List.fromList(json);
  }

  @override
  List<int> toJson(Uint8List object) {
    return object.toList();
  }
}
