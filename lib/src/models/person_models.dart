import 'package:json_annotation/json_annotation.dart';

part 'person_models.g.dart';

@JsonSerializable()
class Person {
  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: '')
  final String email;

  Person(this.id, this.name, this.email);

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);

  Map<String, dynamic> toJson() => _$PersonToJson(this);
}
