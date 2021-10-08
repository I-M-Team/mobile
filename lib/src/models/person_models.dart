import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
  final String path;
  final String name;
  final String email;
  final String photoUrl;

  Person(this.path, this.name, this.email, this.photoUrl);

  String get nameOrEmail => name.isEmpty ? email : name;

  factory Person.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var json = snapshot.data()!;
    return Person(
      snapshot.reference.path,
      json['name'] as String? ?? '',
      json['email'] as String? ?? '',
      json['photoUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'created_at': Timestamp.now(),
      };
}
