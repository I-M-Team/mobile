import 'package:app/extensions.dart';
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
    for (var item in LocalProvider.events) {
      if (isEventComplete(item)) {
        personEvents.add(item.id);
      }
    }

    var personLevel = LocalProvider.levels.first;
    for (var level in LocalProvider.levels.reversed) {
      if (level.events.every((element) => personEvents.contains(element))) {
        return level;
      }
    }

    return personLevel;
  }

  Level? getNextLevel() {
    return LocalProvider.levels.getOrNull(getLevel().number + 1);
  }

  bool isEventComplete(Event item) {
    var progress = (eventsProgress[item.id] as int?).orDefault();
    return progress >= item.conditions;
  }

  Event? getNextLevelEvent() {
    List<String> personEvents = [];
    for (var event in LocalProvider.events) {
      if (isEventComplete(event)) {
        personEvents.add(event.id);
      }
    }
    var events = (getNextLevel()
        ?.events
        .filter((e) => !personEvents.contains(e))).orDefault();
    print('getNextLevelEvent=$events');
    return events.isEmpty
        ? null
        : LocalProvider.invisibleEvents.find((e) => events.contains(e.id));
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
