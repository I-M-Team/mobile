import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

class Person {
  @JsonKey(defaultValue: '')
  final String path;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: '')
  final String email;

  Person(this.path, this.name, this.email);

  factory Person.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var json = snapshot.data()!;
    return Person(
      snapshot.reference.path,
      json['name'] as String? ?? '',
      json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'email': email,
        'created_at': Timestamp.now(),
      };
}
