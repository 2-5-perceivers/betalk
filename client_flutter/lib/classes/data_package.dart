import 'package:betalk/classes/message.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'data_package.g.dart';

@JsonSerializable()
class DataPackage {
  const DataPackage(
    this.id, {
    required this.type,
    this.loginName,
    this.message,
  })  : assert(message != null || loginName != null),
        assert(!(type == DataPackageType.message && message == null)),
        assert(!(type == DataPackageType.login && loginName == null));

  DataPackage.newMessagePackage(this.message)
      : id = const Uuid().v4(),
        type = DataPackageType.message,
        loginName = null;

  DataPackage.newLoginPackage(this.loginName)
      : id = const Uuid().v4(),
        type = DataPackageType.login,
        message = null;

  final String id;
  final String? loginName;
  final Message? message;
  final DataPackageType type;

  factory DataPackage.fromJson(Map<String, dynamic> json) =>
      _$DataPackageFromJson(json);
  Map<String, dynamic> toJson() => _$DataPackageToJson(this);
}

enum DataPackageType {
  @JsonValue("login")
  login,

  @JsonValue("message")
  message,
}
