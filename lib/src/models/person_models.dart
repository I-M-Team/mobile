import 'package:app/src/resources/local_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'models.dart';

class Person {
  final String path;
  final String name;
  final String email;
  final String photoUrl;
  final String level;
  final int points;
  final Map<String, dynamic> eventsProgress;

  Person.create(this.path, this.name, this.email, this.photoUrl)
      : level = 'Новичок',
        points = 0,
        eventsProgress = {};

  Person(this.path, this.name, this.email, this.photoUrl, this.level,
      this.points, this.eventsProgress);

  String get nameOrEmail => name.isEmpty ? email : name;

  Level getLevel() {
    List<String> personEvents = [];
    var progress = eventsProgress;
    for (var event in LocalProvider.events) {
      if (progress[event.id] == event.conditions) {
        personEvents.add(event.id);
      }
    }

    Level personLevel = LocalProvider.levels.first;
    for (var level in LocalProvider.levels.reversed) {
      if (level.events == personEvents) {
        personLevel = level;
      }
    }

    return personLevel;
  }

  Level getNextLevel() {
    return LocalProvider.levels[getLevel().number + 1];
  }

  factory Person.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var json = snapshot.data()!;
    return Person(
      snapshot.reference.path,
      json['name'] as String? ?? '',
      json['email'] as String? ?? '',
      json['photoUrl'] as String? ?? '',
      json['level'] as String? ?? '',
      json['points'] as int? ?? 0,
      json['eventsProgress'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'level': level,
        'points': points,
        'created_at': Timestamp.now(),
      };
}
