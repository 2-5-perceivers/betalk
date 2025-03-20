// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_package.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataPackage _$DataPackageFromJson(Map<String, dynamic> json) => DataPackage(
      json['id'] as String,
      type: $enumDecode(_$DataPackageTypeEnumMap, json['type']),
      loginName: json['loginName'] as String?,
      message: json['message'] == null
          ? null
          : Message.fromJson(json['message'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DataPackageToJson(DataPackage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'loginName': instance.loginName,
      'message': instance.message,
      'type': _$DataPackageTypeEnumMap[instance.type]!,
    };

const _$DataPackageTypeEnumMap = {
  DataPackageType.login: 'login',
  DataPackageType.message: 'message',
};
