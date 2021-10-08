// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Person _$PersonFromJson(Map<String, dynamic> json) {
  return Person(
    json['id'] as String? ?? '',
    json['name'] as String? ?? '',
    json['email'] as String? ?? '',
  );
}

Map<String, dynamic> _$PersonToJson(Person instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
    };
