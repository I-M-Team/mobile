import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
  final String path;
  final String name;
  final String email;
  final String photoUrl;
  final String level;
  final int points;
  final Map<String, int> eventsProgress;

  Person.create(this.path, this.name, this.email, this.photoUrl)
      : level = 'Новичок',
        points = 0,
        eventsProgress = {};

  Person(
      this.path, this.name, this.email, this.photoUrl, this.level, this.points, this.eventsProgress);

  String get nameOrEmail => name.isEmpty ? email : name;

  factory Person.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var json = snapshot.data()!;
    return Person(
      snapshot.reference.path,
      json['name'] as String? ?? '',
      json['email'] as String? ?? '',
      json['photoUrl'] as String? ?? '',
      json['level'] as String? ?? '',
      json['points'] as int? ?? 0,
      json['eventsProgress'] as Map<String, int>? ?? {},
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'level': level,
        'points': points,
        'created_at': Timestamp.now(),
        'eventsProgress': eventsProgress,
      };
}
