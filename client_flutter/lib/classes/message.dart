import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  const Message(
    this.messageID, {
    this.messageAuthor,
    this.messageTextContent,
    this.messageFileContent,
    required this.time,
    required this.type,
  }) : assert(messageTextContent != null || messageFileContent != null);

  Message.newMessage(
      {required this.messageAuthor,
      this.messageTextContent,
      this.messageFileContent})
      : messageID = const Uuid().v4(),
        type = MessageType.userMessage,
        time = DateTime.now().toUtc().toIso8601String(),
        assert(messageTextContent != null || messageFileContent != null);

  final String messageID;
  final String? messageAuthor, messageTextContent;
  @Uint8ListConverter()
  final Uint8List? messageFileContent;
  final String time;
  final MessageType type;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

enum MessageType {
  @JsonValue("user-message")
  userMessage,
  @JsonValue("system-message")
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
